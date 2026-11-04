import AvatarDressing
import BodyGeometry
import LivingWorld
import Metal
import os
import QuartzCore
import RealityKit
import SwiftUI
import UIKit

/// The home world's 3D layer (v2.5 §3.4, v2.8 §06): the person's figure dressed in the day's look,
/// standing at the origin of a street. The street is real geometry (tools/scenes/build_city_usdz.py)
/// drawn by RealityKit with lighting baked in Blender for this camera; when it cannot be shown, the
/// labelled 2D frame is drawn behind this view instead. Model, garments, city, rain and light are
/// separate layers, so a garment swap never reloads the city and rain never touches the figure.
///
/// The camera matches the city build and the 2D renders: horizontal, 0.45 m above the ground, 3.40 m
/// in front of the figure, 60° vertical field of view. Pinch zoom narrows the field of view only, so
/// the 2D frame can follow with a plain scale. The camera never moves on its own and the street never
/// shifts: only the figure turns, and only by the user's hand (user decision 2026-11-04).
@MainActor
final class WorldStage {
    static let cameraHeight: Float = 0.45
    static let cameraDistance: Float = 3.40
    static let baseFOV: Float = 60

    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "city")

    let root = Entity()
    private let city = Entity()
    private var cityResource: String?
    private var cityWet: Bool?
    private var cityGroups: [String: [ModelEntity]] = [:]
    private var cityLoads = 0
    /// Frames counted between update-rate reports (RealityKit scene updates, about one per frame).
    private var frameCount = 0
    private var frameClock: TimeInterval = 0
    var onFrameRate: ((Double) -> Void)?
    private let pivot = Entity()
    private let body = Entity()
    private let garments = Entity()
    private let camera = PerspectiveCamera()
    private let lights = Entity()
    private let rain = Entity()
    /// Today's spotlight: a light from above whose lamp is never in frame (user decision 2026-11-04).
    private let spot = Entity()
    private let shadow = WorldStage.contactShadow()
    private var updates: EventSubscription?

    private(set) var yaw: Float = 0
    /// Hand-turn momentum (rad/s): a flick keeps the figure turning and it slows to rest, like a
    /// turntable. Nothing else ever turns or moves the figure.
    private(set) var spin = TurntableSpin()
    /// Called once when a flick has come to rest, with the final angle.
    var onSpinSettled: ((Float) -> Void)?

    /// Garment meshes by (form, body revision): built once, so a look swap only swaps entities.
    private var meshCache: [String: [(GarmentMesh.Role, MeshResource, [ShapeResource])]] = [:]
    private var shownBody: BodyMesh?
    private var shownOutfit: DressedOutfit?
    private var shownLight: WorldLight?
    private(set) var selectedSlot: GarmentSlotID?

    func build(in content: inout RealityViewCameraContent) {
        content.camera = .virtual
        camera.camera.fieldOfViewInDegrees = Self.baseFOV
        camera.camera.near = 0.05
        // The sky dome sits 420 m from the camera.
        camera.camera.far = 1_200
        camera.look(at: SIMD3(0, Self.cameraHeight, 0), from: SIMD3(0, Self.cameraHeight, Self.cameraDistance), relativeTo: nil)
        content.add(camera)
        content.add(lights)
        content.add(city)
        pivot.addChild(body)
        pivot.addChild(garments)
        root.addChild(pivot)
        root.addChild(shadow)
        root.addChild(spot)
        root.addChild(rain)
        content.add(root)
        updates = content.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            MainActor.assumeIsolated { self?.tick(event.deltaTime) }
        }
    }

    // MARK: Figure

    func show(body mesh: BodyMesh) {
        guard mesh != shownBody else { return }
        shownBody = mesh
        meshCache.removeAll()
        shownOutfit = nil
        var skin = PhysicallyBasedMaterial()
        // Covered, matte, linen-toned form (§108.3): a neutral figure, not skin.
        skin.baseColor = .init(tint: UIColor(red: 0.80, green: 0.73, blue: 0.64, alpha: 1))
        skin.roughness = .init(floatLiteral: 0.85)
        body.children.removeAll()
        for piece in mesh.pieces {
            guard let resource = try? MeshResource.generate(from: [descriptor(piece.positions, piece.normals, piece.indices, piece.part.rawValue)]) else { continue }
            let entity = ModelEntity(mesh: resource, materials: [skin])
            entity.name = "body"
            entity.components.set(CollisionComponent(shapes: [.generateConvex(from: piece.positions)]))
            body.addChild(entity)
        }
    }

    /// Prepare the meshes of looks that may be shown next, so "new outfit" never waits on geometry.
    func prewarm(_ outfits: [DressedOutfit], snapshot: AvatarSnapshot) {
        for outfit in outfits { for item in outfit.items.values { _ = meshes(item.form, snapshot) } }
    }

    /// Dress the figure: one entity per slot, named by the slot so a ray hit names what was touched.
    func dress(_ outfit: DressedOutfit, snapshot: AvatarSnapshot) {
        guard outfit != shownOutfit else { return }
        shownOutfit = outfit
        garments.children.removeAll()
        for slot in outfit.slots {
            guard let item = outfit[slot], let parts = meshes(item.form, snapshot) else { continue }
            let entity = Entity()
            entity.name = slot.rawValue
            for (role, resource, shapes) in parts {
                let model = ModelEntity(mesh: resource, materials: [Self.material(item, role)])
                model.name = slot.rawValue
                model.components.set(CollisionComponent(shapes: shapes))
                entity.addChild(model)
            }
            garments.addChild(entity)
        }
        highlight(selectedSlot)
    }

    private func meshes(_ form: GarmentForm, _ snapshot: AvatarSnapshot) -> [(GarmentMesh.Role, MeshResource, [ShapeResource])]? {
        let key = "\(form.rawValue)#\(snapshot.bodyRevision)#\(snapshot.silhouette.heightCm)"
        if let cached = meshCache[key] { return cached }
        guard let garment = try? GarmentMesh.make(form, on: snapshot) else { return nil }
        // Pieces with the same role share one resource; each piece gets its own convex hull for hits.
        var byRole: [GarmentMesh.Role: [GarmentMesh.Piece]] = [:]
        for piece in garment.pieces { byRole[piece.role, default: []].append(piece) }
        var result: [(GarmentMesh.Role, MeshResource, [ShapeResource])] = []
        for (role, pieces) in byRole.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let descriptors = pieces.enumerated().map { descriptor($1.positions, $1.normals, $1.indices, "\(form.rawValue)-\(role.rawValue)-\($0)") }
            guard let resource = try? MeshResource.generate(from: descriptors) else { continue }
            result.append((role, resource, pieces.map { ShapeResource.generateConvex(from: $0.positions) }))
        }
        meshCache[key] = result
        return result
    }

    private func descriptor(_ p: [SIMD3<Float>], _ n: [SIMD3<Float>], _ i: [UInt32], _ name: String) -> MeshDescriptor {
        var d = MeshDescriptor(name: name)
        d.positions = MeshBuffers.Positions(p)
        d.normals = MeshBuffers.Normals(n)
        d.primitives = .triangles(i)
        return d
    }

    /// Fabric-like PBR per shape family: knits and wool have sheen and no shine, leather is smoother.
    static func material(_ item: DressItem, _ role: GarmentMesh.Role) -> PhysicallyBasedMaterial {
        var m = PhysicallyBasedMaterial()
        let base = UIColor(rgb: item.colorHex)
        m.faceCulling = .none
        switch role {
        case .sole:
            m.baseColor = .init(tint: item.form == .sneakers ? UIColor(white: 0.93, alpha: 1) : UIColor(white: 0.12, alpha: 1))
            m.roughness = 0.7
            return m
        case .hardware:
            m.baseColor = .init(tint: UIColor(red: 0.78, green: 0.66, blue: 0.45, alpha: 1))
            m.metallic = 1.0
            m.roughness = 0.32
            return m
        case .trim:
            m.baseColor = .init(tint: base.shaded(by: item.form == .knit ? 0.92 : 0.86))
        case .shell:
            m.baseColor = .init(tint: base)
        }
        switch item.form {
        case .knit, .coat, .scarf:
            m.roughness = 0.95
            m.sheen = .init(tint: base.shaded(by: 1.25))
        case .tee, .longSleeveTee:
            m.roughness = 0.88
        case .shirt:
            m.roughness = 0.72
        case .jacket, .trousers:
            m.roughness = 0.78
            m.sheen = .init(tint: base.shaded(by: 1.1))
        case .jeans, .shorts, .skirt:
            m.roughness = 0.84
        case .sneakers:
            m.roughness = 0.55
        case .boots, .loafers, .belt, .tote:
            m.roughness = 0.38
            m.clearcoat = 0.4
            m.clearcoatRoughness = 0.3
        }
        return m
    }

    /// The touched garment: a thin warm edge glow, not an animation (v2.5 §5.3).
    func highlight(_ slot: GarmentSlotID?) {
        selectedSlot = slot
        for entity in garments.children {
            let on = entity.name == slot?.rawValue
            for case let model as ModelEntity in entity.children {
                guard var materials = model.model?.materials as? [PhysicallyBasedMaterial] else { continue }
                for k in materials.indices {
                    materials[k].emissiveColor = .init(color: on ? UIColor(red: 0.85, green: 0.62, blue: 0.42, alpha: 1) : .black)
                    materials[k].emissiveIntensity = on ? 0.18 : 0
                }
                model.model?.materials = materials
            }
        }
    }

    // MARK: Turning, zoom and hits

    /// Turn the figure to `yaw`. Animated turns are eased by this stage's own frame tick (no
    /// RealityKit transform animation, which would own the pivot's transform afterwards).
    func place(yaw: Float, animated: Bool, duration: TimeInterval = 0.45) {
        spin.stop()
        if animated, duration > 0 {
            tween = Tween(from: self.yaw, to: yaw, duration: Float(duration))
        } else {
            tween = nil
        }
        if tween == nil { apply(yaw) }
    }

    /// An ease-out turn in progress.
    private struct Tween {
        let from: Float, to: Float, duration: Float
        var elapsed: Float = 0
        var value: Float {
            let t = min(max(elapsed / duration, 0), 1)
            let e = 1 - pow(1 - t, 3)
            return from + (to - from) * e
        }
        var done: Bool { elapsed >= duration }
    }
    private var tween: Tween?

    private func apply(_ yaw: Float) {
        self.yaw = yaw
        pivot.transform = Transform(scale: .one, rotation: simd_quatf(angle: yaw, axis: SIMD3(0, 1, 0)), translation: .zero)
    }

    /// Zoom by field of view only (the camera does not move), so the backdrop scales with it exactly.
    func setZoom(_ zoom: Float) {
        let half = atan(tan(Self.baseFOV / 2 * .pi / 180) / zoom)
        camera.camera.fieldOfViewInDegrees = 2 * half * 180 / .pi
    }

    /// The slot under a point in the view, by a RealityKit ray cast from the camera through the point.
    func slot(at point: CGPoint, in size: CGSize) -> GarmentSlotID? {
        guard let scene = root.scene, size.width > 0, size.height > 0 else { return nil }
        let fov = camera.camera.fieldOfViewInDegrees * .pi / 180
        let t = tan(fov / 2)
        let aspect = Float(size.width / size.height)
        let x = (2 * Float(point.x / size.width) - 1) * t * aspect
        let y = (1 - 2 * Float(point.y / size.height)) * t
        let orientation = camera.orientation(relativeTo: nil)
        let direction = simd_normalize(orientation.act(SIMD3(x, y, -1)))
        let origin = camera.position(relativeTo: nil)
        let hits = scene.raycast(origin: origin, direction: direction, length: 10, query: .nearest, mask: .all, relativeTo: nil)
        guard let name = hits.first?.entity.name else { return nil }
        return GarmentSlotID(rawValue: name)
    }

    /// Let go after a hand turn: keep turning at `velocity` (rad/s) and slow to rest.
    func fling(velocity: Float) {
        tween = nil
        spin.fling(velocity)
    }

    private func tick(_ dt: TimeInterval) {
        // Even paused: a still, hidden stage must not hold the shared render thread (DirectPresentation).
        DirectPresentation.keep()
        guard !paused else { return }
        countFrame(dt)
        if var t = tween {
            t.elapsed += Float(min(dt, 0.1))
            tween = t.done ? nil : t
            apply(t.value)
            return
        }
        guard spin.isSpinning else { return }
        apply(yaw + spin.step(dt))
        if !spin.isSpinning { onSpinSettled?(yaw) }
    }

    private func countFrame(_ dt: TimeInterval) {
        frameCount += 1
        frameClock += dt
        guard frameClock >= 2 else { return }
        let rate = Double(frameCount) / frameClock
        frameCount = 0
        frameClock = 0
        onFrameRate?(rate)
    }

    // MARK: City

    var showsCity: Bool { city.isEnabled && !city.children.isEmpty }

    /// Show the 3D street of `model` with the baked textures for the surface state, or none. Loading
    /// happens once per city; a weather change only swaps textures. Throws when the asset is missing
    /// or damaged, so the caller can fall back to the labelled 2D frame.
    func showCity(_ model: CityModel3D?, wet: Bool) async throws {
        cityLoads += 1
        let ticket = cityLoads
        guard let model else {
            city.children.removeAll()
            cityResource = nil
            cityGroups = [:]
            return
        }
        if cityResource != model.resource {
            let start = ContinuousClock.now
            let street = try await Entity(named: model.resource, in: .main)
            guard ticket == cityLoads else { return }
            var groups: [String: [ModelEntity]] = [:]
            street.visit { entity in
                guard let m = entity as? ModelEntity, let group = Self.group(of: m) else { return }
                groups[group, default: []].append(m)
            }
            guard Set(groups.keys) == Set(CityModel3D.groups) else { throw CityError.missingGroups(groups.keys.sorted()) }
            city.children.removeAll()
            city.addChild(street)
            cityResource = model.resource
            cityGroups = groups
            cityWet = nil
            Self.log.info("city \(model.resource, privacy: .public) loaded in \(start.duration(to: .now), privacy: .public)")
        }
        guard cityWet != wet else { return }
        var materials: [String: UnlitMaterial] = [:]
        for group in CityModel3D.groups {
            let name = model.texture(group: group, wet: wet)
            guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") else { throw CityError.missingTexture(name) }
            let texture = try await TextureResource(contentsOf: url, options: .init(semantic: .color, mipmapsMode: .allocateAndGenerateAll))
            var material = UnlitMaterial(applyPostProcessToneMap: false)
            material.color = .init(tint: .white, texture: .init(texture, sampler: Self.sampler))
            materials[group] = material
        }
        guard ticket == cityLoads else { return }
        for (group, entities) in cityGroups {
            guard let material = materials[group] else { continue }
            for entity in entities { entity.model?.materials = [material] }
        }
        cityWet = wet
    }

    func setCityVisible(_ visible: Bool) { city.isEnabled = visible }

    /// Out of sight (the profile cover is up, or another tab is chosen): the frame tick does
    /// nothing, so a flick stops, no turn is eased and no update rate is reported. A rate measured
    /// while hidden must not step the scene quality down. The scene itself is left as it is:
    /// turning its entities off left RealityViews made meanwhile (the profile's 3D body) undrawn on
    /// the simulator (2026-11-04).
    private(set) var paused = false
    func setPaused(_ paused: Bool) {
        guard paused != self.paused else { return }
        self.paused = paused
        if paused { spin.stop(); tween = nil }
    }

    enum CityError: Error {
        case missingGroups([String])
        case missingTexture(String)
    }

    /// The street's mesh group from the nearest `city_<group>` ancestor (the Blender object name).
    private static func group(of entity: Entity) -> String? {
        var e: Entity? = entity
        while let current = e {
            if current.name.hasPrefix("city_") { return String(current.name.dropFirst(5)) }
            e = current.parent
        }
        return nil
    }

    /// Trilinear and anisotropic, so the street does not shimmer at grazing angles.
    private static let sampler: MaterialParameters.Texture.Sampler = {
        let d = MTLSamplerDescriptor()
        d.minFilter = .linear
        d.magFilter = .linear
        d.mipFilter = .linear
        d.maxAnisotropy = 8
        d.sAddressMode = .clampToEdge
        d.tAddressMode = .clampToEdge
        return MaterialParameters.Texture.Sampler(d)
    }()

    // MARK: Light and weather

    /// Figure lighting that agrees with the backdrop, so the person does not look pasted in.
    func light(_ light: WorldLight) {
        guard light != shownLight else { return }
        shownLight = light
        lights.children.removeAll()
        for spec in light.directionals {
            let d = DirectionalLight()
            d.light.color = spec.color
            d.light.intensity = spec.intensity
            d.look(at: SIMD3(0, 0.9, 0), from: spec.from, relativeTo: nil)
            lights.addChild(d)
        }
    }

    /// A spotlight straight above the figure: a real RealityKit spot light (lights the figure and its
    /// garments from the top, with a shadow), a warm pool of light on the ground and a faint beam that
    /// fades out well below the top of the frame, so the lamp itself is never seen.
    private var shownSpot: Bool?
    func spotlight(_ on: Bool) {
        guard on != shownSpot else { return }
        shownSpot = on
        spot.children.removeAll()
        guard on else { return }
        let light = SpotLight()
        light.light.color = UIColor(red: 1.0, green: 0.93, blue: 0.82, alpha: 1)
        light.light.intensity = 26_000
        light.light.innerAngleInDegrees = 16
        light.light.outerAngleInDegrees = 34
        light.light.attenuationRadius = 9
        light.shadow = SpotLightComponent.Shadow()
        light.look(at: SIMD3(0, 0.9, 0), from: SIMD3(0.15, 4.6, 0.55), relativeTo: nil)
        spot.addChild(light)
        spot.addChild(Self.lightPool())
        if let beam = Self.beam() { spot.addChild(beam) }
    }

    /// Warm radial glow on the ground under the figure.
    private static func lightPool() -> Entity {
        let size = 256
        let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let colors = [CGColor(red: 1, green: 0.90, blue: 0.74, alpha: 0.55), CGColor(red: 1, green: 0.88, blue: 0.70, alpha: 0.22),
                      CGColor(red: 1, green: 0.86, blue: 0.68, alpha: 0)] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.45, 1])!
        let c = CGPoint(x: size / 2, y: size / 2)
        ctx.drawRadialGradient(gradient, startCenter: c, startRadius: 0, endCenter: c, endRadius: CGFloat(size) / 2, options: [])
        var material = UnlitMaterial(applyPostProcessToneMap: false)
        if let image = ctx.makeImage(), let texture = try? TextureResource(image: image, options: .init(semantic: .color)) {
            material.color = .init(tint: .white, texture: .init(texture))
        }
        material.blending = .transparent(opacity: 1.0)
        let plane = ModelEntity(mesh: .generatePlane(width: 1.9, depth: 1.3), materials: [material])
        plane.position = SIMD3(0, 0.003, 0.05)
        plane.name = "spotPool"
        return plane
    }

    /// A soft shaft of light behind the figure: transparent in its upper part (no visible source),
    /// a faint warm glow towards the ground, falling off sideways like haze in a beam.
    private static func beam() -> Entity? {
        let w = 128, h = 256
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        for y in 0..<h {
            // y = 0 is the top row of the image (the top of the shaft).
            let v = Double(y) / Double(h - 1)
            let vertical = v < 0.38 ? 0 : pow((v - 0.38) / 0.62, 1.6) * 0.16
            let spread = 0.10 + 0.30 * v   // the shaft widens towards the ground
            for x in 0..<w {
                let u = (Double(x) / Double(w - 1) - 0.5)
                let side = exp(-(u * u) / (2 * spread * spread))
                let a = vertical * side
                let i = (y * w + x) * 4
                pixels[i] = UInt8(255 * a); pixels[i + 1] = UInt8(236 * a); pixels[i + 2] = UInt8(205 * a); pixels[i + 3] = UInt8(255 * a)
            }
        }
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let image = CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent),
              let texture = try? TextureResource(image: image, options: .init(semantic: .color)) else { return nil }
        var material = UnlitMaterial(applyPostProcessToneMap: false)
        material.color = .init(tint: .white, texture: .init(texture))
        material.blending = .transparent(opacity: 1.0)
        let plane = ModelEntity(mesh: .generatePlane(width: 2.6, height: 3.6), materials: [material])
        plane.position = SIMD3(0, 1.8, -0.35)
        plane.name = "spotBeam"
        return plane
    }

    /// Rain in depth around the figure and small splashes where drops meet the ground (§3.3).
    /// `intensity` 0 removes both; nothing is drawn as an overlay on the figure.
    func rain(_ intensity: Float) {
        rain.children.removeAll()
        guard intensity > 0 else { return }
        var drops = ParticleEmitterComponent()
        drops.emitterShape = .box
        drops.emitterShapeSize = SIMD3(5.5, 0.05, 5.0)
        drops.birthLocation = .volume
        drops.emissionDirection = SIMD3(0.06, -1, 0)
        drops.speed = 7.5
        drops.speedVariation = 1.0
        drops.mainEmitter.birthRate = 1_400 * intensity
        drops.mainEmitter.lifeSpan = 0.55
        drops.mainEmitter.size = 0.006
        drops.mainEmitter.stretchFactor = 14
        drops.mainEmitter.color = .constant(.single(UIColor(white: 0.92, alpha: 0.32)))
        drops.mainEmitter.isLightingEnabled = false
        drops.mainEmitter.blendMode = .additive
        let dropEntity = Entity()
        dropEntity.components.set(drops)
        dropEntity.position = SIMD3(0, 3.6, -0.5)
        rain.addChild(dropEntity)

        var splash = ParticleEmitterComponent()
        splash.emitterShape = .plane
        splash.emitterShapeSize = SIMD3(5.0, 0, 4.0)
        splash.birthLocation = .surface
        splash.emissionDirection = SIMD3(0, 1, 0)
        splash.speed = 0.55
        splash.speedVariation = 0.25
        splash.mainEmitter.birthRate = 320 * intensity
        splash.mainEmitter.lifeSpan = 0.16
        splash.mainEmitter.size = 0.006
        splash.mainEmitter.spreadingAngle = 0.9
        splash.mainEmitter.acceleration = SIMD3(0, -9.8, 0)
        splash.mainEmitter.color = .constant(.single(UIColor(white: 0.95, alpha: 0.45)))
        splash.mainEmitter.isLightingEnabled = false
        splash.mainEmitter.blendMode = .additive
        let splashEntity = Entity()
        splashEntity.components.set(splash)
        splashEntity.position = SIMD3(0, 0.005, -0.4)
        rain.addChild(splashEntity)
    }

    /// A soft dark ellipse under the feet: the figure stands on the street instead of floating.
    private static func contactShadow() -> Entity {
        let size = 128
        let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let colors = [CGColor(gray: 0, alpha: 0.55), CGColor(gray: 0, alpha: 0)] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceGray(), colors: colors, locations: [0, 1])!
        ctx.drawRadialGradient(gradient, startCenter: CGPoint(x: 64, y: 64), startRadius: 0, endCenter: CGPoint(x: 64, y: 64), endRadius: 64, options: [])
        var material = UnlitMaterial()
        if let image = ctx.makeImage(), let texture = try? TextureResource(image: image, options: .init(semantic: .color)) {
            material.color = .init(tint: .white, texture: .init(texture))
        }
        material.blending = .transparent(opacity: 1.0)
        let plane = ModelEntity(mesh: .generatePlane(width: 0.9, depth: 0.55), materials: [material])
        plane.position = SIMD3(0, 0.002, 0.02)
        plane.name = "shadow"
        return plane
    }
}

/// Lights for the figure, matched to a backdrop.
struct WorldLight: Equatable {
    struct Directional: Equatable {
        let color: UIColor
        let intensity: Float
        let from: SIMD3<Float>
    }
    let directionals: [Directional]

    /// Evening street: warm lamp light from the front right, cool sky from the left, warm rim behind.
    static let evening = WorldLight(directionals: [
        .init(color: UIColor(red: 1.0, green: 0.80, blue: 0.62, alpha: 1), intensity: 2_400, from: SIMD3(1.6, 2.2, 2.4)),
        .init(color: UIColor(red: 0.62, green: 0.70, blue: 0.95, alpha: 1), intensity: 900, from: SIMD3(-2.2, 1.4, 1.6)),
        .init(color: UIColor(red: 1.0, green: 0.72, blue: 0.48, alpha: 1), intensity: 1_600, from: SIMD3(0.4, 2.0, -2.8)),
    ])
    /// Daylight: sun from the upper left, soft sky fill.
    static let day = WorldLight(directionals: [
        .init(color: UIColor(red: 1.0, green: 0.95, blue: 0.86, alpha: 1), intensity: 3_200, from: SIMD3(-1.8, 3.0, 2.2)),
        .init(color: UIColor(red: 0.78, green: 0.86, blue: 1.0, alpha: 1), intensity: 1_100, from: SIMD3(2.0, 1.2, 1.8)),
        .init(color: UIColor(white: 1, alpha: 1), intensity: 900, from: SIMD3(0, 1.8, -2.6)),
    ])
    /// Overcast: flatter, cooler.
    static let overcast = WorldLight(directionals: [
        .init(color: UIColor(red: 0.92, green: 0.94, blue: 1.0, alpha: 1), intensity: 2_000, from: SIMD3(-1.0, 3.0, 2.0)),
        .init(color: UIColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1), intensity: 1_300, from: SIMD3(1.8, 1.4, 1.8)),
        .init(color: UIColor(white: 1, alpha: 1), intensity: 700, from: SIMD3(0, 1.8, -2.6)),
    ])
    /// Studio: the neutral stage when no city is chosen.
    static let studio = WorldLight(directionals: [
        .init(color: .white, intensity: 2_600, from: SIMD3(1.2, 2.4, 2.2)),
        .init(color: .white, intensity: 900, from: SIMD3(-2, 1, 1.5)),
        .init(color: .white, intensity: 1_400, from: SIMD3(0, 1.8, -2.5)),
    ])
}

private extension Entity {
    func visit(_ body: (Entity) -> Void) {
        body(self)
        for child in children { child.visit(body) }
    }
}

extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255, green: CGFloat((rgb >> 8) & 0xFF) / 255, blue: CGFloat(rgb & 0xFF) / 255, alpha: 1)
    }

    func shaded(by k: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(r * k, 1), green: min(g * k, 1), blue: min(b * k, 1), alpha: a)
    }
}

import AvatarDressing
import BodyGeometry
import QuartzCore
import RealityKit
import SwiftUI
import UIKit

/// The home world's 3D layer (v2.5 §3.4): the person's figure dressed in the day's look, standing at
/// the origin of a street whose backdrop is drawn behind this view. Model, garments, rain and light
/// are separate layers, so a garment swap never reloads the city and rain never touches the figure.
///
/// The camera matches the backdrop renders (tools/scenes/build_city_scene.py): horizontal, 0.80 m
/// above the ground, 2.73 m in front of the figure, 60° vertical field of view. Pinch zoom narrows
/// the field of view only, so the backdrop can follow with a plain scale about the screen centre.
@MainActor
final class WorldStage {
    static let cameraHeight: Float = 0.45
    static let cameraDistance: Float = 3.40
    static let baseFOV: Float = 60

    let root = Entity()
    private let pivot = Entity()
    private let body = Entity()
    private let garments = Entity()
    private let camera = PerspectiveCamera()
    private let lights = Entity()
    private let rain = Entity()
    private var updates: EventSubscription?

    private(set) var yaw: Float = 0
    private var idleOffset: Float = 0
    private var idleClock: TimeInterval = 0
    private var idleResumesAt: CFTimeInterval = 0
    var idleEnabled = false {
        didSet { if !idleEnabled { idleOffset = 0; pivot.transform.scale = .one } }
    }
    static let swayAmplitude: Float = 0.19
    static let swayPeriod: TimeInterval = 11
    static let breathPeriod: TimeInterval = 4.6
    static let idleResumeDelay: CFTimeInterval = 4

    /// Garment meshes by (form, body revision): built once, so a look swap only swaps entities.
    private var meshCache: [String: [(GarmentMesh.Role, MeshResource, [ShapeResource])]] = [:]
    private var shownBody: BodyMesh?
    private var shownOutfit: DressedOutfit?
    private var shownLight: WorldLight?
    private(set) var selectedSlot: GarmentSlotID?

    func build(in content: inout RealityViewCameraContent) {
        content.camera = .virtual
        camera.camera.fieldOfViewInDegrees = Self.baseFOV
        camera.look(at: SIMD3(0, Self.cameraHeight, 0), from: SIMD3(0, Self.cameraHeight, Self.cameraDistance), relativeTo: nil)
        content.add(camera)
        content.add(lights)
        pivot.addChild(body)
        pivot.addChild(garments)
        root.addChild(pivot)
        root.addChild(Self.contactShadow())
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

    func place(yaw: Float, animated: Bool, duration: TimeInterval = 0.45) {
        self.yaw = yaw
        let target = Transform(scale: .one, rotation: simd_quatf(angle: yaw, axis: SIMD3(0, 1, 0)), translation: .zero)
        if animated {
            pivot.move(to: target, relativeTo: nil, duration: duration, timingFunction: .easeOut)
        } else {
            pivot.stopAllAnimations()
            pivot.transform = target
        }
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

    func takeIdleOffset() -> Float {
        let offset = idleOffset
        idleOffset = 0
        idleClock = 0
        pivot.transform.scale = .one
        idleResumesAt = CACurrentMediaTime() + Self.idleResumeDelay
        return offset
    }

    private func tick(_ dt: TimeInterval) {
        guard idleEnabled, CACurrentMediaTime() >= idleResumesAt else { return }
        idleClock += dt
        idleOffset = Self.swayAmplitude * Float(sin(idleClock * 2 * .pi / Self.swayPeriod))
        let breath = Float(sin(idleClock * 2 * .pi / Self.breathPeriod))
        pivot.transform = Transform(
            scale: SIMD3(1 + 0.004 * breath, 1 + 0.0015 * breath, 1 + 0.006 * breath),
            rotation: simd_quatf(angle: yaw + idleOffset, axis: SIMD3(0, 1, 0)),
            translation: .zero
        )
    }

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

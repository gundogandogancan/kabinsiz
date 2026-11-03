import BodyGeometry
import RealityKit
import SwiftUI

/// The neutral 3D body (ADR-007), turned by the user's own hand: one-finger drag spins it about the
/// vertical axis 1:1 (direct manipulation, no lag), a flick keeps a little momentum, pinch zooms, and
/// front / side / back jump to fixed angles. It never turns by itself. With Reduce Motion on, jumps
/// and momentum are instant (v2.0 §05.2, design-motion-principles: mobile = subtle, frequent = no
/// decoration).
struct BodyModel3DView: View {
    let mesh: BodyMesh
    let summary: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var stage = Stage()
    /// Radians about +y; 0 = facing the viewer.
    @State private var yaw: Float = 0
    @State private var dragStartYaw: Float?
    /// Decided on the first movement: a mostly vertical drag belongs to the list (scrolling), not the model.
    @State private var dragIsTurn: Bool?
    @State private var zoom: Float = 1
    @State private var pinchStartZoom: Float?

    enum Angle: String, CaseIterable, Identifiable {
        case front, side, back
        var id: String { rawValue }
        var yaw: Float {
            switch self {
            case .front: 0
            case .side: .pi / 2
            case .back: .pi
            }
        }
        var title: String {
            switch self {
            case .front: "Ön"
            case .side: "Yan"
            case .back: "Arka"
            }
        }
    }

    var body: some View {
        VStack(spacing: Token.Space.tight) {
            RealityView { content in
                content.camera = .virtual
                stage.build(in: &content)
                stage.show(mesh, dark: colorScheme == .dark)
                stage.place(yaw: yaw, zoom: zoom, animated: false)
            } update: { _ in
                stage.show(mesh, dark: colorScheme == .dark)
            }
            .simultaneousGesture(drag)
            .simultaneousGesture(pinch)
            .accessibilityElement()
            .accessibilityLabel("Vücudunun 3B modeli")
            .accessibilityValue("\(angleDescription). \(summary)")
            .accessibilityHint("Döndürmek için yukarı veya aşağı kaydır.")
            .accessibilityAdjustableAction { direction in
                turn(to: yaw + (direction == .increment ? .pi / 4 : -.pi / 4), animated: false)
            }
            .accessibilityIdentifier("body3D")

            HStack(spacing: Token.Space.tight) {
                ForEach(Angle.allCases) { angle in
                    Button(angle.title) { turn(to: nearest(angle.yaw), animated: true) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(Token.brandInk)
                        .accessibilityIdentifier("bodyAngle-\(angle.rawValue)")
                }
            }
        }
    }

    // MARK: Gestures

    private var drag: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if dragIsTurn == nil { dragIsTurn = abs(value.translation.width) >= abs(value.translation.height) }
                guard dragIsTurn == true else { return }
                let start = dragStartYaw ?? yaw
                dragStartYaw = start
                // Half a turn per screen-width of finger travel, applied directly.
                yaw = start + Float(value.translation.width) / 240 * .pi / 2
                stage.place(yaw: yaw, zoom: zoom, animated: false)
            }
            .onEnded { value in
                defer { dragIsTurn = nil }
                dragStartYaw = nil
                guard dragIsTurn == true, !reduceMotion else { return }
                // A flick carries on a little and settles; a slow release stops where the finger left it.
                let carry = Float(value.predictedEndTranslation.width - value.translation.width) / 240 * .pi / 2
                guard abs(carry) > 0.05 else { return }
                turn(to: yaw + max(-.pi / 2, min(.pi / 2, carry)), animated: true, duration: 0.55)
            }
    }

    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStartZoom ?? zoom
                pinchStartZoom = start
                zoom = max(0.8, min(1.8, start * Float(value.magnification)))
                stage.place(yaw: yaw, zoom: zoom, animated: false)
            }
            .onEnded { _ in pinchStartZoom = nil }
    }

    private func turn(to target: Float, animated: Bool, duration: TimeInterval = 0.45) {
        yaw = target
        stage.place(yaw: yaw, zoom: zoom, animated: animated && !reduceMotion, duration: duration)
    }

    /// The preset angle closest to where the body already is, so "Ön" never spins it a full extra turn.
    private func nearest(_ preset: Float) -> Float {
        let turns = ((yaw - preset) / (2 * .pi)).rounded()
        return preset + turns * 2 * .pi
    }

    private var angleDescription: String {
        let deg = Int((yaw * 180 / .pi).truncatingRemainder(dividingBy: 360) + 360) % 360
        switch deg {
        case 0..<23, 338..<360: return "Önden"
        case 68..<113, 248..<293: return "Yandan"
        case 158..<203: return "Arkadan"
        default: return "Çaprazdan"
        }
    }
}

/// Holds the RealityKit entities across SwiftUI updates.
@MainActor
final class Stage {
    private let pivot = Entity()
    private let body = Entity()
    private let camera = PerspectiveCamera()
    private var shown: BodyMesh?
    private var shownDark: Bool?
    private var heightM: Float = 1.7

    func build(in content: inout RealityViewCameraContent) {
        camera.camera.fieldOfViewInDegrees = 28
        content.add(camera)

        let key = DirectionalLight()
        key.light.intensity = 2_600
        key.look(at: .zero, from: SIMD3(1.2, 2.4, 2.2), relativeTo: nil)
        content.add(key)
        let fill = DirectionalLight()
        fill.light.intensity = 900
        fill.look(at: .zero, from: SIMD3(-2, 1, 1.5), relativeTo: nil)
        content.add(fill)
        let rim = DirectionalLight()
        rim.light.intensity = 1_400
        rim.look(at: .zero, from: SIMD3(0, 1.8, -2.5), relativeTo: nil)
        content.add(rim)

        pivot.addChild(body)
        content.add(pivot)
    }

    func show(_ mesh: BodyMesh, dark: Bool) {
        // Previews during a drag keep the same revision, so the geometry itself is compared.
        guard mesh != shown || dark != shownDark else { return }
        shown = mesh
        shownDark = dark
        heightM = mesh.heightM
        var material = PhysicallyBasedMaterial()
        // Covered, matte, linen-toned: reads as a neutral form, not skin (§108.3 "covered").
        material.baseColor = .init(tint: dark ? UIColor(red: 0.71, green: 0.64, blue: 0.56, alpha: 1) : UIColor(red: 0.84, green: 0.77, blue: 0.68, alpha: 1))
        material.roughness = .init(floatLiteral: 0.88)
        material.metallic = .init(floatLiteral: 0)
        body.children.removeAll()
        for piece in mesh.pieces {
            var d = MeshDescriptor(name: piece.part.rawValue)
            d.positions = MeshBuffers.Positions(piece.positions)
            d.normals = MeshBuffers.Normals(piece.normals)
            d.primitives = .triangles(piece.indices)
            guard let resource = try? MeshResource.generate(from: [d]) else { continue }
            body.addChild(ModelEntity(mesh: resource, materials: [material]))
        }
        // Ground: a soft disc that gives the figure weight without decoration.
        let ground = ModelEntity(mesh: .generateCylinder(height: 0.002, radius: 0.32 * heightM / 1.7),
                                 materials: [UnlitMaterial(color: dark ? UIColor(white: 0.22, alpha: 1) : UIColor(white: 0.9, alpha: 1))])
        body.addChild(ground)
        frame()
    }

    func place(yaw: Float, zoom: Float, animated: Bool, duration: TimeInterval = 0.45) {
        let target = Transform(scale: .one, rotation: simd_quatf(angle: yaw, axis: SIMD3(0, 1, 0)), translation: .zero)
        if animated {
            pivot.move(to: target, relativeTo: nil, duration: duration, timingFunction: .easeOut)
        } else {
            pivot.stopAllAnimations()
            pivot.transform = target
        }
        frame(zoom: zoom)
    }

    private var zoom: Float = 1

    /// Whole body in view at zoom 1; closer as the user pinches.
    private func frame(zoom: Float? = nil) {
        if let zoom { self.zoom = zoom }
        let fov = camera.camera.fieldOfViewInDegrees * .pi / 180
        let distance = (heightM * 0.56) / tan(fov / 2) / self.zoom
        let lookAt = SIMD3<Float>(0, heightM * (self.zoom > 1.2 ? 0.62 : 0.5), 0)
        camera.look(at: lookAt, from: lookAt + SIMD3(0, heightM * 0.04, distance), relativeTo: nil)
    }
}

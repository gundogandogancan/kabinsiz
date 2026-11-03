import BodyGeometry
import QuartzCore
import RealityKit
import SwiftUI

/// The neutral 3D body (ADR-007), turned by the user's own hand: one-finger drag spins it about the
/// vertical axis 1:1 (direct manipulation, no lag), a flick keeps a little momentum, pinch zooms, and
/// front / side / back jump to fixed angles. With Reduce Motion on, jumps and momentum are instant
/// (v2.0 §05.2, design-motion-principles: mobile = subtle, frequent = no decoration).
///
/// `alive`: while nobody touches it, the figure breathes and sways a few degrees, so it reads as a
/// living stand-in rather than a diagram. Any touch stops that at once and hands the figure to the
/// finger; it resumes, from where the finger left it, after a few quiet seconds. Callers pass `alive`
/// false under Reduce Motion or a constrained device budget (UI20-T-005, UI20-T-014).
struct BodyModel3DView: View {
    let mesh: BodyMesh
    let summary: String
    var alive = false
    var showsAngleButtons = true
    var identifier = "body3D"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var stage = Stage()
    /// Radians about +y; 0 = facing the viewer.
    @State private var yaw: Float = 0
    @State private var dragStartYaw: Float?
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
                stage.idleEnabled = alive && !reduceMotion
            } update: { _ in
                stage.show(mesh, dark: colorScheme == .dark)
                stage.idleEnabled = alive && !reduceMotion
            }
            // The RealityView's UIView swallows touches, and a SwiftUI DragGesture holds the enclosing
            // scroll view still. So the view takes no touches, and a clear layer carries UIKit
            // recognisers: a pan that only begins when the finger moves sideways (a vertical drag
            // never starts it and scrolls the page), and a two-finger pinch.
            .allowsHitTesting(false)
            .overlay {
                Color.clear
                    .contentShape(.rect)
                    .gesture(SidewaysPan(changed: dragChanged, ended: dragEnded))
                    .gesture(PinchZoom(changed: pinchChanged, ended: { pinchStartZoom = nil }))
            }
            .accessibilityElement()
            .accessibilityLabel("Vücudunun 3B modeli")
            .accessibilityValue("\(angleDescription). \(summary)")
            .accessibilityHint("Döndürmek için yukarı veya aşağı kaydır.")
            .accessibilityAdjustableAction { direction in
                turn(to: yaw + (direction == .increment ? .pi / 4 : -.pi / 4), animated: false)
            }
            .accessibilityIdentifier(identifier)

            if showsAngleButtons {
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
    }

    // MARK: Gestures

    private func dragChanged(_ dx: CGFloat) {
        if dragStartYaw == nil { yaw += stage.takeIdleOffset() }
        let start = dragStartYaw ?? yaw
        dragStartYaw = start
        // Half a turn per screen-width of finger travel, applied directly.
        yaw = start + Float(dx) / 240 * .pi / 2
        stage.place(yaw: yaw, zoom: zoom, animated: false)
    }

    private func dragEnded(_ velocity: CGFloat) {
        dragStartYaw = nil
        guard !reduceMotion else { return }
        // A flick carries on a little and settles (about a quarter second of the release speed);
        // a slow release stops where the finger left it.
        let carry = Float(velocity / 4) / 240 * .pi / 2
        guard abs(carry) > 0.05 else { return }
        turn(to: yaw + max(-.pi / 2, min(.pi / 2, carry)), animated: true, duration: 0.55)
    }

    private func pinchChanged(_ scale: CGFloat) {
        if pinchStartZoom == nil { yaw += stage.takeIdleOffset() }
        let start = pinchStartZoom ?? zoom
        pinchStartZoom = start
        zoom = max(0.8, min(1.8, start * Float(scale)))
        stage.place(yaw: yaw, zoom: zoom, animated: false)
    }

    private func turn(to target: Float, animated: Bool, duration: TimeInterval = 0.45) {
        _ = stage.takeIdleOffset()
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
    private var yaw: Float = 0
    private var updates: EventSubscription?

    /// Idle breathing and sway (see `BodyModel3DView.alive`).
    var idleEnabled = false {
        didSet { if !idleEnabled, oldValue { resetIdlePose() } }
    }
    private var idleClock: Double = 0
    private var idleResumesAt: Double = 0
    private var idleOffset: Float = 0
    /// Quiet time after a touch before the figure starts breathing again.
    private static let idleResumeDelay: Double = 4
    /// Sway amplitude (radians, ≈ 11°) and periods (seconds): slow enough to read as calm, not as a spin.
    private static let swayAmplitude: Float = 0.19
    private static let swayPeriod: Double = 11
    private static let breathPeriod: Double = 4.6

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
        updates = content.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            MainActor.assumeIsolated { self?.tick(event.deltaTime) }
        }
    }

    /// Per frame: only while idle is on and nobody touched the figure recently.
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

    /// A touch takes over: returns the sway the figure had, so the caller's yaw continues from the
    /// pose on screen (no jump), and holds the idle motion off for a few seconds.
    func takeIdleOffset() -> Float {
        let offset = idleOffset
        resetIdlePose()
        idleResumesAt = CACurrentMediaTime() + Self.idleResumeDelay
        return offset
    }

    private func resetIdlePose() {
        idleOffset = 0
        idleClock = 0
        pivot.transform.scale = .one
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
        self.yaw = yaw
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

/// One-finger pan that begins only when the finger first moves more sideways than up or down, so a
/// vertical drag over the figure is left to the scroll view. Reports horizontal travel, then the
/// horizontal release speed (pt/s).
private struct SidewaysPan: UIGestureRecognizerRepresentable {
    let changed: (CGFloat) -> Void
    let ended: (CGFloat) -> Void

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { Coordinator() }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer()
        pan.maximumNumberOfTouches = 1
        pan.delegate = context.coordinator
        return pan
    }

    func handleUIGestureRecognizerAction(_ pan: UIPanGestureRecognizer, context: Context) {
        switch pan.state {
        case .began, .changed: changed(pan.translation(in: pan.view).x)
        case .ended: ended(pan.velocity(in: pan.view).x)
        case .cancelled, .failed: ended(0)
        default: break
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer else { return true }
            let v = pan.velocity(in: pan.view)
            return abs(v.x) > abs(v.y)
        }
    }
}

/// Two-finger pinch; reports the scale since the fingers came down.
private struct PinchZoom: UIGestureRecognizerRepresentable {
    let changed: (CGFloat) -> Void
    let ended: () -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPinchGestureRecognizer { UIPinchGestureRecognizer() }

    func handleUIGestureRecognizerAction(_ pinch: UIPinchGestureRecognizer, context: Context) {
        switch pinch.state {
        case .began, .changed: changed(pinch.scale)
        case .ended, .cancelled, .failed: ended()
        default: break
        }
    }
}

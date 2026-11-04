import BodyGeometry
import LivingWorld
import QuartzCore
import RealityKit
import SwiftUI

/// The neutral 3D body (ADR-007), turned by the user's own hand: one-finger drag spins it about the
/// vertical axis 1:1 (direct manipulation, no lag), a flick keeps a little momentum, pinch zooms, and
/// front / side / back jump to fixed angles. With Reduce Motion on, jumps and momentum are instant
/// (v2.0 §05.2, design-motion-principles: mobile = subtle, frequent = no decoration).
///
/// It never moves on its own: no sway, no breathing (user decision 2026-11-04, ADR-016). Only the
/// user's hand turns it.
struct BodyModel3DView: View {
    let mesh: BodyMesh
    let summary: String
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
                stage.onSpinSettled = { yaw = $0 }
            } update: { _ in
                stage.show(mesh, dark: colorScheme == .dark)
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
        // The finger takes the figure: any momentum stops where it is.
        if dragStartYaw == nil { yaw = stage.currentYaw }
        let start = dragStartYaw ?? yaw
        dragStartYaw = start
        // Half a turn per screen-width of finger travel, applied directly.
        yaw = start + Float(dx) / 240 * .pi / 2
        stage.place(yaw: yaw, zoom: zoom, animated: false)
    }

    private func dragEnded(_ velocity: CGFloat) {
        dragStartYaw = nil
        guard !reduceMotion else { return }
        // A flick keeps turning and slows to rest like a turntable (the same motion as the home
        // figure); a slow release stops where the finger left it. 480 pt of travel = half a turn.
        stage.fling(velocity: TurntableSpin.velocity(forFingerSpeed: Double(velocity), width: 480))
    }

    private func pinchChanged(_ scale: CGFloat) {
        if stage.isSpinning { yaw = stage.currentYaw }
        let start = pinchStartZoom ?? zoom
        pinchStartZoom = start
        zoom = max(0.8, min(1.8, start * Float(scale)))
        stage.place(yaw: yaw, zoom: zoom, animated: false)
    }

    private func turn(to target: Float, animated: Bool, duration: TimeInterval = 0.45) {
        if stage.isSpinning { yaw = stage.currentYaw }
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
    private var spin = TurntableSpin()
    private var tween: (from: Float, to: Float, duration: Float, elapsed: Float)?
    private var updates: EventSubscription?
    /// Called once when a flick has come to rest, with the final angle.
    var onSpinSettled: ((Float) -> Void)?
    var currentYaw: Float { yaw }
    var isSpinning: Bool { spin.isSpinning }

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
        // Turns are eased by this frame tick, never by a RealityKit transform animation: a
        // `move(to:)` left the pivot's transform owned by the animation on iOS 26 and later
        // writes were ignored (seen on the home figure, ADR-016).
        updates = content.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            MainActor.assumeIsolated { self?.tick(event.deltaTime) }
        }
    }

    func fling(velocity: Float) {
        tween = nil
        spin.fling(velocity)
    }

    private func tick(_ dt: TimeInterval) {
        if var t = tween {
            t.elapsed += Float(min(dt, 0.1))
            let k = min(t.elapsed / t.duration, 1)
            tween = k >= 1 ? nil : t
            apply(t.from + (t.to - t.from) * (1 - pow(1 - k, 3)))
            return
        }
        guard spin.isSpinning else { return }
        apply(yaw + spin.step(dt))
        if !spin.isSpinning { onSpinSettled?(yaw) }
    }

    private func apply(_ yaw: Float) {
        self.yaw = yaw
        pivot.transform = Transform(scale: .one, rotation: simd_quatf(angle: yaw, axis: SIMD3(0, 1, 0)), translation: .zero)
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
        spin.stop()
        if animated, duration > 0, yaw != self.yaw {
            tween = (self.yaw, yaw, Float(duration), 0)
        } else {
            tween = nil
            apply(yaw)
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

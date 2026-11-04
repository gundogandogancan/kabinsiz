import BodyGeometry
import Combine
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
            stageView
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
                let step: Float = direction == .increment ? .pi / 4 : -.pi / 4
                turn(to: yaw + step, animated: false)
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

    /// The RealityKit stage. It takes no touches (a SwiftUI DragGesture would hold the enclosing
    /// scroll view still). A clear overlay carries UIKit recognisers instead: a pan that only begins
    /// when the finger moves sideways (a vertical drag never starts it and scrolls the page), and a
    /// two-finger pinch.
    private var stageView: some View {
        // Only the angle's binding is captured, never `self`: through `self` the callback would hold
        // this view's state, which holds the stage, and the stage would never be freed.
        let settledYaw = $yaw
        return StageView(stage: stage, mesh: mesh, dark: colorScheme == .dark, yaw: yaw, zoom: zoom,
                         onSettled: { settledYaw.wrappedValue = $0 })
            .allowsHitTesting(false)
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
    private var updates: (any Cancellable)?
    /// Called once when a flick has come to rest, with the final angle.
    var onSpinSettled: ((Float) -> Void)?
    var currentYaw: Float { yaw }
    var isSpinning: Bool { spin.isSpinning }

    private let anchor = AnchorEntity(world: .zero)

    func build(in view: ARView) {
        camera.camera.fieldOfViewInDegrees = 28
        anchor.addChild(camera)

        let key = DirectionalLight()
        key.light.intensity = 2_600
        key.look(at: .zero, from: SIMD3(1.2, 2.4, 2.2), relativeTo: nil)
        anchor.addChild(key)
        let fill = DirectionalLight()
        fill.light.intensity = 900
        fill.look(at: .zero, from: SIMD3(-2, 1, 1.5), relativeTo: nil)
        anchor.addChild(fill)
        let rim = DirectionalLight()
        rim.light.intensity = 1_400
        rim.look(at: .zero, from: SIMD3(0, 1.8, -2.5), relativeTo: nil)
        anchor.addChild(rim)

        pivot.addChild(body)
        anchor.addChild(pivot)
        view.scene.addAnchor(anchor)
        // Turns are eased by this frame tick, never by a RealityKit transform animation: a
        // `move(to:)` left the pivot's transform owned by the animation on iOS 26 and later
        // writes were ignored (seen on the home figure, ADR-016).
        updates = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self, weak view] event in
            MainActor.assumeIsolated {
                // Before this frame is drawn: present it directly (see `DirectARView`).
                (view as? DirectARView)?.keepDirectPresentation()
                self?.tick(event.deltaTime)
            }
        }
    }

    /// The view is gone: stop the frame tick and empty the scene, so nothing keeps it rendering.
    func tearDown(_ view: ARView) {
        updates?.cancel()
        updates = nil
        view.scene.anchors.removeAll()
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

/// RealityKit's view for the profile figure, made here instead of through `RealityView` so its Metal
/// layer can be kept on direct presentation (ADR-016 "Bilinen açık", root cause found 2026-11-04 on
/// the simulator). Measured there: in the profile cover RealityKit's layer had `presentsWithTransaction`
/// on (the home layer had it off) and it stayed on while the screen was still. RealityKit's own
/// snapshot showed each new body, the screen kept the first frame, and later RealityKit's shared render
/// thread waited a second in `nextDrawable` for every frame while the main thread waited for it, so
/// every 3D view froze and touches were lost. Turning it off before each frame removed all of that.
final class DirectARView: ARView {
    private weak var metal: CAMetalLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        keepDirectPresentation()
    }

    /// Present frames directly. A resize may show one frame before the new layout; nothing waits.
    func keepDirectPresentation() {
        if metal == nil { metal = Self.metalLayer(in: layer) }
        guard let metal, metal.presentsWithTransaction else { return }
        metal.presentsWithTransaction = false
    }

    private static func metalLayer(in layer: CALayer, depth: Int = 0) -> CAMetalLayer? {
        if let metal = layer as? CAMetalLayer { return metal }
        guard depth < 3 else { return nil }
        for sub in layer.sublayers ?? [] {
            if let found = metalLayer(in: sub, depth: depth + 1) { return found }
        }
        return nil
    }
}

/// Hosts `DirectARView` for the profile figure and feeds it the mesh.
private struct StageView: UIViewRepresentable {
    let stage: Stage
    let mesh: BodyMesh
    let dark: Bool
    let yaw: Float
    let zoom: Float
    let onSettled: (Float) -> Void

    func makeCoordinator() -> Stage { stage }

    func makeUIView(context: Context) -> DirectARView {
        let view = DirectARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.environment.background = .color(.clear)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        stage.build(in: view)
        stage.show(mesh, dark: dark)
        stage.place(yaw: yaw, zoom: zoom, animated: false)
        stage.onSpinSettled = onSettled
        return view
    }

    func updateUIView(_ view: DirectARView, context: Context) {
        stage.show(mesh, dark: dark)
    }

    static func dismantleUIView(_ view: DirectARView, coordinator: Stage) {
        coordinator.tearDown(view)
    }
}

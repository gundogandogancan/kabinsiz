import AvatarDressing
import BodyGeometry
import RealityKit
import SwiftUI

/// The dressed figure in the world (v2.5 §2.3): a sideways drag turns it through 360° (a vertical
/// drag is left alone), two fingers zoom, a tap on a garment selects its slot by a RealityKit ray
/// cast. Rotation and selection never fight: the pan only begins on sideways motion, a tap only
/// fires when the finger did not move.
struct DressedAvatarView: View {
    let body3D: BodyMesh
    let snapshot: AvatarSnapshot
    let outfit: DressedOutfit
    let prewarm: [DressedOutfit]
    let light: WorldLight
    let rainIntensity: Float
    let alive: Bool
    @Binding var selectedSlot: GarmentSlotID?
    @Binding var zoom: Float
    @Binding var yaw: Float
    var onTapSlot: (GarmentSlotID?) -> Void = { _ in }
    /// VoiceOver's way to a garment: one action per worn slot (v2.8 §06.3).
    var onSlotAction: (GarmentSlotID) -> Void = { _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stage = WorldStage()
    @State private var dragStartYaw: Float?
    @State private var pinchStartZoom: Float?
    @State private var shownRain: Float = -1

    var body: some View {
        GeometryReader { geo in
            RealityView { content in
                stage.build(in: &content)
                sync()
                stage.place(yaw: yaw, animated: false)
            } update: { _ in
                sync()
            }
            .allowsHitTesting(false)
            .overlay {
                Color.clear
                    .contentShape(.rect)
                    .gesture(WorldPan(changed: dragChanged, ended: dragEnded))
                    .gesture(WorldPinch(changed: pinchChanged, ended: { pinchStartZoom = nil }))
                    .onTapGesture(coordinateSpace: .local) { point in
                        let slot = stage.slot(at: point, in: geo.size)
                        onTapSlot(slot)
                    }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("3B modelin, bugünün kombiniyle")
        .accessibilityValue(accessibilitySummary)
        .accessibilityHint("Döndürmek için yukarı veya aşağı kaydır. Bir parçayı değiştirmek için eylemleri kullan.")
        .accessibilityAdjustableAction { direction in
            turn(to: yaw + (direction == .increment ? .pi / 4 : -.pi / 4), animated: false)
        }
        .accessibilityActions {
            ForEach(GarmentSlotID.allCases.filter { outfit[$0] != nil || [.outerwear, .bag, .belt].contains($0) }, id: \.self) { slot in
                Button("\(slot.displayName) değiştir") { onSlotAction(slot) }
            }
        }
        .accessibilityIdentifier("worldAvatar")
    }

    private func sync() {
        stage.light(light)
        stage.show(body: body3D)
        stage.prewarm(prewarm, snapshot: snapshot)
        stage.dress(outfit, snapshot: snapshot)
        if stage.selectedSlot != selectedSlot { stage.highlight(selectedSlot) }
        stage.idleEnabled = alive && !reduceMotion
        stage.setZoom(zoom)
        if shownRain != rainIntensity {
            stage.rain(reduceMotion ? 0 : rainIntensity)
            DispatchQueue.main.async { shownRain = rainIntensity }
        }
        if abs(stage.yaw - yaw) > 0.0001, dragStartYaw == nil { stage.place(yaw: yaw, animated: !reduceMotion) }
    }

    private var accessibilitySummary: String {
        let pieces = outfit.slots.compactMap { outfit[$0] }.map { "\($0.slot.displayName): \($0.name)" }
        return pieces.isEmpty ? "Kıyafet yok" : pieces.joined(separator: ", ") + ". Temsili görünüm."
    }

    private func dragChanged(_ dx: CGFloat) {
        if dragStartYaw == nil { yaw += stage.takeIdleOffset() }
        let start = dragStartYaw ?? yaw
        dragStartYaw = start
        yaw = start + Float(dx) / 240 * .pi / 2
        stage.place(yaw: yaw, animated: false)
    }

    private func dragEnded(_ velocity: CGFloat) {
        dragStartYaw = nil
        guard !reduceMotion else { return }
        let carry = Float(velocity / 4) / 240 * .pi / 2
        guard abs(carry) > 0.05 else { return }
        turn(to: yaw + max(-.pi / 2, min(.pi / 2, carry)), animated: true)
    }

    private func pinchChanged(_ scale: CGFloat) {
        let start = pinchStartZoom ?? zoom
        pinchStartZoom = start
        zoom = max(1, min(2.4, start * Float(scale)))
    }

    private func turn(to target: Float, animated: Bool) {
        _ = stage.takeIdleOffset()
        yaw = target
        stage.place(yaw: yaw, animated: animated && !reduceMotion, duration: 0.55)
    }
}

/// One-finger pan that begins only on sideways motion.
private struct WorldPan: UIGestureRecognizerRepresentable {
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

private struct WorldPinch: UIGestureRecognizerRepresentable {
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

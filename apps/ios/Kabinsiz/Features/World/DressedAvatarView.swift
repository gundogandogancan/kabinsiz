import AvatarDressing
import BodyGeometry
import LivingWorld
import RealityKit
import SwiftUI

/// The dressed figure in the world (v2.5 §2.3, user decision 2026-11-04): it stands still until the
/// user turns it. A sideways drag turns it 1:1 under the finger (a vertical drag is left alone); a
/// flick keeps it turning on a turntable that slows to rest; two fingers zoom; a tap on a garment
/// selects its slot by a RealityKit ray cast; a garment dragged from the dress-up tray and dropped on
/// the figure goes on. Nothing moves by itself: no sway, no breathing, no camera drift.
struct DressedAvatarView: View {
    let body3D: BodyMesh
    let snapshot: AvatarSnapshot
    let outfit: DressedOutfit
    let prewarm: [DressedOutfit]
    let light: WorldLight
    let rainIntensity: Float
    @Binding var selectedSlot: GarmentSlotID?
    @Binding var zoom: Float
    @Binding var yaw: Float
    var onTapSlot: (GarmentSlotID?) -> Void = { _ in }
    /// VoiceOver's way to a garment: one action per worn slot (v2.8 §06.3).
    var onSlotAction: (GarmentSlotID) -> Void = { _ in }
    /// A garment id dropped on the figure from the dress-up tray; returns whether it went on.
    var onDropItem: (String) -> Bool = { _ in false }
    /// The 3D street to stand in, its surface state, and whether it may be shown and drift.
    var city: CityModel3D?
    var wetCity = false
    var showCity = false
    /// Today's spotlight from above (lamp out of frame).
    var spotlight = false
    /// Scene update rate, reported every two seconds.
    var onFrameRate: (Double) -> Void = { _ in }
    /// True once the street is on screen; false when it could not be loaded.
    var onCityReady: (Bool) -> Void = { _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Out of sight: the stage stops its frame work (`WorldStage.setPaused`).
    @Environment(\.worldPaused) private var paused
    @State private var stage = WorldStage()
    @State private var dragStartYaw: Float?
    @State private var pinchStartZoom: Float?
    @State private var shownRain: Float = -1
    @State private var width: CGFloat = 390
    @State private var dropTargeted = false

    var body: some View {
        GeometryReader { geo in
            RealityView { content in
                stage.build(in: &content)
                stage.setPaused(paused)
                sync()
                stage.place(yaw: yaw, animated: false)
            } update: { _ in
                sync()
            }
            .allowsHitTesting(false)
            .onChange(of: paused) { _, now in stage.setPaused(now) }
            .task(id: CityRequest(resource: showCity ? city?.resource : nil, wet: wetCity)) {
                do {
                    try await stage.showCity(showCity ? city : nil, wet: wetCity)
                    guard !Task.isCancelled else { return }
                    stage.setCityVisible(showCity)
                    onCityReady(showCity && stage.showsCity)
                } catch {
                    guard !Task.isCancelled else { return }
                    stage.setCityVisible(false)
                    onCityReady(false)
                }
            }
            .overlay {
                Color.clear
                    .contentShape(.rect)
                    .gesture(WorldPan(changed: dragChanged, ended: dragEnded))
                    .gesture(WorldPinch(changed: pinchChanged, ended: { pinchStartZoom = nil }))
                    .onTapGesture(coordinateSpace: .local) { point in
                        let slot = stage.slot(at: point, in: geo.size)
                        onTapSlot(slot)
                    }
                    .dropDestination(for: String.self) { ids, _ in
                        guard let id = ids.first else { return false }
                        return onDropItem(id)
                    } isTargeted: { dropTargeted = $0 }
            }
            .overlay {
                // While a garment is carried over the figure, a soft ring under the feet says "drop here".
                if dropTargeted {
                    Ellipse().strokeBorder(Atelier.copper.opacity(0.9), lineWidth: 3)
                        .frame(width: geo.size.width * 0.5, height: 44)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.80)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .onAppear { width = geo.size.width }
            .onChange(of: geo.size.width) { width = $1 }
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
        stage.spotlight(spotlight)
        stage.show(body: body3D)
        stage.prewarm(prewarm, snapshot: snapshot)
        stage.dress(outfit, snapshot: snapshot)
        if stage.selectedSlot != selectedSlot { stage.highlight(selectedSlot) }
        // The callbacks capture a binding and a closure, never `self`: through `self` they would hold
        // this view's state, which holds the stage, and the stage and its RealityKit view would
        // never be freed (ADR-016 "Bilinen açık", 2026-11-04).
        if stage.onSpinSettled == nil {
            let settledYaw = $yaw
            stage.onSpinSettled = { final in Task { @MainActor in settledYaw.wrappedValue = final } }
        }
        if stage.onFrameRate == nil {
            let report = onFrameRate
            stage.onFrameRate = { rate in Task { @MainActor in report(rate) } }
        }
        stage.setZoom(zoom)
        if shownRain != rainIntensity {
            stage.rain(reduceMotion ? 0 : rainIntensity)
            DispatchQueue.main.async { shownRain = rainIntensity }
        }
        if abs(stage.yaw - yaw) > 0.0001, dragStartYaw == nil, !stage.spin.isSpinning {
            stage.place(yaw: yaw, animated: !reduceMotion)
        }
    }

    private var accessibilitySummary: String {
        let pieces = outfit.slots.compactMap { outfit[$0] }.map { "\($0.slot.displayName): \($0.name)" }
        return pieces.isEmpty ? "Kıyafet yok" : pieces.joined(separator: ", ") + ". Temsili görünüm."
    }

    /// 1:1 under the finger: one screen width is half a turn. A turn in progress is caught by the finger.
    private func dragChanged(_ dx: CGFloat) {
        if dragStartYaw == nil {
            yaw = stage.yaw          // catch a coasting figure where it is
            dragStartYaw = yaw
        }
        yaw = (dragStartYaw ?? yaw) + TurntableSpin.angle(forDrag: Double(dx), width: Double(width))
        stage.place(yaw: yaw, animated: false)
    }

    /// Let go: a flick coasts and slows to rest (with Reduce Motion it stops where the finger left it).
    private func dragEnded(_ velocity: CGFloat) {
        dragStartYaw = nil
        guard !reduceMotion else { return }
        stage.fling(velocity: TurntableSpin.velocity(forFingerSpeed: Double(velocity), width: Double(width)))
    }

    private func pinchChanged(_ scale: CGFloat) {
        let start = pinchStartZoom ?? zoom
        pinchStartZoom = start
        zoom = max(1, min(2.4, start * Float(scale)))
    }

    private func turn(to target: Float, animated: Bool) {
        yaw = target
        stage.place(yaw: yaw, animated: animated && !reduceMotion, duration: 0.55)
    }
}

private struct CityRequest: Equatable {
    let resource: String?
    let wet: Bool
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

@preconcurrency import AVFoundation
import AvatarDressing
import LiveMirror
import os
import SwiftUI
import Vision

/// LM-03/04 local mirror (v2.5 §4): the front camera, the body pose found on the device by Apple
/// Vision, and the chosen piece drawn over the person following that pose. No frame is stored or sent.
/// Without a camera (the Simulator) or without permission it says so; it never imitates a camera
/// picture and never calls a camera-only picture a try-on.
struct LocalMirrorView: View {
    let item: DressItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var mirror = MirrorPoseModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch mirror.state {
            case .starting:
                ProgressView().tint(.white)
            case .running:
                GeometryReader { geo in
                    ZStack {
                        CameraPreview(session: mirror.camera.session).ignoresSafeArea()
                        Canvas { context, size in
                            guard let pose = mirror.pose else { return }
                            MirrorGarmentPainter(item: item, pose: pose, imageAspect: mirror.imageAspect).draw(in: &context, size: size)
                        }
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()
            case .denied:
                fallback(title: "Kamera izni kapalı",
                         detail: "Canlı Ayna için kamera izni gerekir. Ayarlar'dan açabilirsin. Kamera olmadan modelinde görmek için Bugün sekmesini kullan.",
                         settings: true)
            case .unavailable:
                fallback(title: "Bu cihazda kamera yok",
                         detail: "Canlı Ayna bir iPhone kamerası ister. Simülatörde kamera görüntüsü yoktur; burada sahte bir görüntü gösterilmez.",
                         settings: false)
            }
            VStack {
                topBar
                Spacer()
                if mirror.state == .running { bottomBar }
            }
        }
        .task { await mirror.start() }
        .onDisappear { mirror.stop() }
        .onChange(of: scenePhase) { _, phase in
            // The camera never runs in the background (LM21-07).
            if phase != .active { mirror.stop() } else if mirror.state == .running { Task { await mirror.start() } }
        }
        .statusBarHidden()
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.headline).foregroundStyle(.white)
                    .frame(width: 44, height: 44).background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Aynayı kapat")
            .accessibilityIdentifier("mirrorClose")
            Spacer()
            Label("Yerel Ayna", systemImage: "lock.fill")
                .font(AtelierType.caption.weight(.semibold)).foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .accessibilityLabel("Yerel Ayna, görüntü cihazda kalır")
        }
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if let note = mirror.note {
                Text(note).font(AtelierType.caption.weight(.medium)).foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityIdentifier("mirrorNote")
            }
            VStack(spacing: 4) {
                Text(item.name).font(AtelierType.cardTitle).foregroundStyle(.white)
                Text("Görünüm önizlemesidir · temsili çizim · beden uyumunu göstermez")
                    .font(.caption2).foregroundStyle(.white.opacity(0.85)).multilineTextAlignment(.center)
                    .accessibilityIdentifier("mirrorTruthLabel")
                if let fps = mirror.poseFPS {
                    Text(String(format: "Duruş takibi %.0f kare/sn", fps))
                        .font(.caption2.monospacedDigit()).foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .environment(\.colorScheme, .dark)
        .padding(16)
    }

    private func fallback(title: String, detail: String, settings: Bool) -> some View {
        VStack(spacing: Atelier.Space.m) {
            Image(systemName: "camera.metering.unknown").font(.system(size: 44)).foregroundStyle(.white.opacity(0.8))
            Text(title).font(AtelierType.sectionTitle).foregroundStyle(.white)
            Text(detail).font(AtelierType.secondary).foregroundStyle(.white.opacity(0.8)).multilineTextAlignment(.center)
            if settings, let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Ayarları aç", destination: url).buttonStyle(.borderedProminent).tint(Atelier.brand)
            }
        }
        .padding(32)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("cameraFallbackCard")
    }
}

// MARK: - Model

/// A body pose in image coordinates: x right, y down, both 0...1 of the (rotated, mirrored) frame.
struct MirrorPose: Sendable, Equatable {
    var joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    subscript(_ name: VNHumanBodyPoseObservation.JointName) -> CGPoint? { joints[name] }
}

@Observable
@MainActor
final class MirrorPoseModel {
    enum State: Equatable { case starting, running, denied, unavailable }
    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "mirror")

    private(set) var state: State = .starting
    private(set) var pose: MirrorPose?
    private(set) var imageAspect: CGFloat = 9.0 / 16.0
    private(set) var poseFPS: Double?
    private(set) var note: String?
    let camera = MirrorCamera()

    private var frames = 0
    private var windowStart = Date()
    private var lastSeen = Date.distantPast

    func start() async {
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil else {
            state = .unavailable
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: break
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else { state = .denied; return }
        default:
            state = .denied
            return
        }
        camera.onPose = { [weak self] pose, aspect in
            Task { @MainActor in self?.receive(pose, aspect: aspect) }
        }
        camera.start()
        state = .running
    }

    func stop() {
        camera.stop()
    }

    private func receive(_ new: MirrorPose?, aspect: CGFloat) {
        imageAspect = aspect
        frames += 1
        let now = Date()
        let span = now.timeIntervalSince(windowStart)
        if span >= 1 {
            poseFPS = Double(frames) / span
            Self.log.info("pose fps \(self.poseFPS ?? 0, privacy: .public)")
            frames = 0
            windowStart = now
        }
        if let new {
            lastSeen = now
            pose = smooth(pose, new)
        } else if now.timeIntervalSince(lastSeen) > 0.6 {
            pose = nil
        }
        note = noteFor(now: now)
    }

    private func noteFor(now: Date) -> String? {
        switch ProcessInfo.processInfo.thermalState {
        case .serious, .critical: return "Cihaz ısındı; takip yavaşlayabilir."
        default: break
        }
        if ProcessInfo.processInfo.isLowPowerModeEnabled { return "Düşük güç modu açık." }
        if pose == nil { return "Tüm bedenin görünecek şekilde biraz geri çekil." }
        return nil
    }

    /// Light exponential smoothing against jitter; a joint that appears or vanishes is taken as is.
    private func smooth(_ old: MirrorPose?, _ new: MirrorPose) -> MirrorPose {
        guard let old else { return new }
        var out = new
        for (name, p) in new.joints {
            if let o = old.joints[name] { out.joints[name] = CGPoint(x: o.x * 0.45 + p.x * 0.55, y: o.y * 0.45 + p.y * 0.55) }
        }
        return out
    }
}

/// Front camera session and pose requests on a private queue. Frames live only in memory, one at a time.
final class MirrorCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onPose: (@Sendable (MirrorPose?, CGFloat) -> Void)?
    private let queue = DispatchQueue(label: "app.kabinsiz.mirror.camera", qos: .userInteractive)
    private var configured = false
    private let request = VNDetectHumanBodyPoseRequest()

    func start() {
        queue.async { [self] in
            if !configured { configure() }
            if !session.isRunning { session.startRunning() }
        }
    }

    func stop() {
        queue.async { [self] in if session.isRunning { session.stopRunning() } }
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        if let connection = output.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) { connection.videoRotationAngle = 90 }
            if connection.isVideoMirroringSupported { connection.automaticallyAdjustsVideoMirroring = false; connection.isVideoMirrored = true }
        }
        session.commitConfiguration()
        configured = true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let w = CGFloat(CVPixelBufferGetWidth(buffer)), h = CGFloat(CVPixelBufferGetHeight(buffer))
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        var pose: MirrorPose?
        if (try? handler.perform([request])) != nil, let observation = request.results?.first,
           let points = try? observation.recognizedPoints(.all) {
            var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
            for (name, p) in points where p.confidence > 0.3 {
                joints[name] = CGPoint(x: p.location.x, y: 1 - p.location.y)
            }
            if joints.count >= 4 { pose = MirrorPose(joints: joints) }
        }
        onPose?(pose, w / h)
    }
}

/// The camera picture as the user sees it in a mirror.
private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        if let connection = view.previewLayer.connection {
            if connection.isVideoRotationAngleSupported(90) { connection.videoRotationAngle = 90 }
            if connection.isVideoMirroringSupported { connection.automaticallyAdjustsVideoMirroring = false; connection.isVideoMirrored = true }
        }
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

// MARK: - Drawing

/// Draws a garment over the pose: a torso panel with sleeves for tops, a longer open panel for
/// outerwear, two legs for bottoms, shoes at the ankles. A representative drawing, not cloth.
struct MirrorGarmentPainter {
    let item: DressItem
    let pose: MirrorPose
    let imageAspect: CGFloat

    typealias J = VNHumanBodyPoseObservation.JointName

    func draw(in context: inout GraphicsContext, size: CGSize) {
        // Aspect-fill mapping from the frame to the view, the same as the preview layer.
        let viewAspect = size.width / size.height
        let (sx, sy, ox, oy): (CGFloat, CGFloat, CGFloat, CGFloat)
        if imageAspect > viewAspect {
            let w = size.height * imageAspect
            (sx, sy, ox, oy) = (w, size.height, (size.width - w) / 2, 0)
        } else {
            let h = size.width / imageAspect
            (sx, sy, ox, oy) = (size.width, h, 0, (size.height - h) / 2)
        }
        func p(_ j: J) -> CGPoint? { pose[j].map { CGPoint(x: ox + $0.x * sx, y: oy + $0.y * sy) } }

        let color = Color(rgb: item.colorHex)
        let shade = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [color.opacity(0.95), color.mix(with: .black, by: 0.28).opacity(0.95)]),
            startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height))

        switch item.slot {
        case .top, .outerwear, .dress:
            guard let ls = p(.leftShoulder), let rs = p(.rightShoulder) else { return }
            let lh = p(.leftHip) ?? CGPoint(x: ls.x, y: ls.y + dist(ls, rs) * 1.5)
            let rh = p(.rightHip) ?? CGPoint(x: rs.x, y: rs.y + dist(ls, rs) * 1.5)
            let width = dist(ls, rs)
            let long: CGFloat = item.slot == .outerwear ? (item.form == .coat ? 0.95 : 0.35) : (item.slot == .dress ? 1.1 : 0.08)
            let down = CGPoint(x: (lh.x + rh.x - ls.x - rs.x) / 2, y: (lh.y + rh.y - ls.y - rs.y) / 2)
            let flare = width * (item.slot == .outerwear ? 0.2 : 0.12)
            let out = unit(CGPoint(x: rs.x - ls.x, y: rs.y - ls.y))
            let lsO = CGPoint(x: ls.x - out.x * width * 0.14, y: ls.y - out.y * width * 0.14)
            let rsO = CGPoint(x: rs.x + out.x * width * 0.14, y: rs.y + out.y * width * 0.14)
            let lb = CGPoint(x: lh.x + down.x * long - out.x * flare, y: lh.y + down.y * long - out.y * flare)
            let rb = CGPoint(x: rh.x + down.x * long + out.x * flare, y: rh.y + down.y * long + out.y * flare)
            let neck = CGPoint(x: (ls.x + rs.x) / 2, y: (ls.y + rs.y) / 2 + width * 0.16)

            // Sleeves under the body panel.
            let sleeveToWrist = [.longSleeveTee, .knit, .shirt, .jacket, .coat].contains(item.form)
            for (s, e, w) in [(lsO, p(.leftElbow), p(.leftWrist)), (rsO, p(.rightElbow), p(.rightWrist))] {
                guard let e else { continue }
                var arm = Path()
                arm.move(to: s)
                if sleeveToWrist, let w { arm.addLine(to: e); arm.addLine(to: w) } else {
                    arm.addLine(to: CGPoint(x: s.x + (e.x - s.x) * 0.55, y: s.y + (e.y - s.y) * 0.55))
                }
                context.stroke(arm, with: shade, style: StrokeStyle(lineWidth: width * 0.3, lineCap: .round, lineJoin: .round))
            }

            var body = Path()
            body.move(to: lsO)
            body.addQuadCurve(to: rsO, control: CGPoint(x: neck.x, y: neck.y + width * 0.1))
            body.addLine(to: rb)
            body.addQuadCurve(to: lb, control: CGPoint(x: (lb.x + rb.x) / 2, y: (lb.y + rb.y) / 2 + width * 0.04))
            body.closeSubpath()
            context.fill(body, with: shade)
            // Neckline and, for open outerwear, the front edge.
            var neckline = Path()
            neckline.move(to: CGPoint(x: neck.x - width * 0.16, y: neck.y - width * 0.12))
            neckline.addQuadCurve(to: CGPoint(x: neck.x + width * 0.16, y: neck.y - width * 0.12), control: CGPoint(x: neck.x, y: neck.y + width * 0.08))
            context.stroke(neckline, with: .color(.black.opacity(0.25)), lineWidth: 2)
            if item.slot == .outerwear {
                var front = Path()
                front.move(to: CGPoint(x: neck.x, y: neck.y))
                front.addLine(to: CGPoint(x: (lb.x + rb.x) / 2, y: (lb.y + rb.y) / 2))
                context.stroke(front, with: .color(.black.opacity(0.35)), lineWidth: 2.5)
            }
        case .bottom:
            guard let lh = p(.leftHip), let rh = p(.rightHip) else { return }
            let width = dist(lh, rh) * 1.35
            let short = item.form == .shorts || item.form == .skirt
            for (h, k, a) in [(lh, p(.leftKnee), p(.leftAnkle)), (rh, p(.rightKnee), p(.rightAnkle))] {
                guard let k else { continue }
                var leg = Path()
                leg.move(to: h)
                if short { leg.addLine(to: CGPoint(x: h.x + (k.x - h.x) * 0.6, y: h.y + (k.y - h.y) * 0.6)) } else {
                    leg.addLine(to: k)
                    if let a { leg.addLine(to: a) }
                }
                context.stroke(leg, with: shade, style: StrokeStyle(lineWidth: width * 0.48, lineCap: .butt, lineJoin: .round))
            }
            var seat = Path()
            seat.addEllipse(in: CGRect(x: min(lh.x, rh.x) - width * 0.18, y: (lh.y + rh.y) / 2 - width * 0.14,
                                       width: abs(rh.x - lh.x) + width * 0.36, height: width * 0.4))
            context.fill(seat, with: shade)
        case .footwear:
            for a in [p(.leftAnkle), p(.rightAnkle)].compactMap({ $0 }) {
                let r: CGFloat = 26
                context.fill(Path(ellipseIn: CGRect(x: a.x - r, y: a.y - r * 0.4, width: r * 2, height: r * 1.1)), with: shade)
            }
        default:
            break
        }
    }

    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
    private func unit(_ v: CGPoint) -> CGPoint { let l = max(hypot(v.x, v.y), 0.0001); return CGPoint(x: v.x / l, y: v.y / l) }
}

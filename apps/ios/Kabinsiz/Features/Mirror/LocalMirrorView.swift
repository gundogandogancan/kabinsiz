@preconcurrency import AVFoundation
import AvatarDressing
import CoreML
import LiveMirror
import os
import SwiftUI
import Vision

/// MIR-WP02 Canlı Ayna (v3.2 S13, §8.1): the camera picture is the content; the chosen product is
/// drawn on the person and follows their shoulders, arms, hips and legs. Everything runs on this
/// iPhone: Apple Vision finds the pose, the garment drawing (Blender, OWNED_ORIGINAL) is placed part by
/// part (`GarmentRig`). No frame is stored or sent; a photo exists only when the user presses the
/// shutter, and leaves the phone only if they share it. Without a camera it says so and never imitates
/// one; the Simulator fixture (DEBUG, `-mirrorFixture`) is labelled as a fixture on screen.
struct LocalMirrorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var engine: MirrorEngine
    @State private var showPicker = false
    @State private var captured: CapturedLook?
    @State private var flash = false
    let choices: [DressItem]
    let productLine: String?

    init(item: DressItem, choices: [DressItem] = [], productLine: String? = nil) {
        _engine = State(initialValue: MirrorEngine(item: item))
        self.choices = choices
        self.productLine = productLine
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch engine.state {
            case .starting:
                ProgressView().tint(.white)
            case .running:
                GeometryReader { geo in
                    ZStack {
                        if engine.source == .fixture, let frame = engine.fixtureFrame {
                            Image(uiImage: frame).resizable().scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height).clipped()
                        } else {
                            CameraPreview(session: engine.camera.session, mirrored: engine.position == .front)
                        }
                        Canvas { context, size in engine.draw(in: &context, size: size) }
                            .accessibilityHidden(true)
                        if flash { Color.white.opacity(0.7).transition(.opacity) }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .ignoresSafeArea()
            case .denied:
                fallback(title: "Kamera izni kapalı",
                         detail: "Canlı Ayna kamerayı yalnız bu iPhone'da kullanır. Ayarlar'dan izin verebilirsin; ürünü yine 3D modelinde görebilirsin.",
                         settings: true)
            case .unavailable:
                fallback(title: "Bu cihazda kamera yok",
                         detail: "Canlı Ayna bir iPhone kamerası ister. Simülatörde kamera görüntüsü yoktur; burada sahte bir görüntü gösterilmez.",
                         settings: false)
            case .fault(let fault):
                fallback(title: "Ayna durdu", detail: fault.userMessage, settings: false)
            }
            VStack(spacing: 0) {
                topBar
                Spacer()
                if engine.state == .running { bottomArea }
            }
            if engine.state == .running { sideButtons }
        }
        .task { await engine.start() }
        .onDisappear { engine.stop() }
        .onChange(of: scenePhase) { _, phase in
            // The camera never runs in the background (LM21-07, V32-MIR-07).
            if phase != .active { engine.stop() } else if engine.state == .running { Task { await engine.start() } }
        }
        .sheet(isPresented: $showPicker) { picker.presentationDetents([.height(230)]) }
        .sheet(item: $captured) { look in CapturedLookSheet(look: look) }
        .statusBarHidden()
    }

    // MARK: Chrome

    private var topBar: some View {
        HStack {
            roundButton("chevron.left", label: "Aynayı kapat", id: "mirrorClose") { dismiss() }
            Spacer()
            HStack(spacing: 8) {
                Circle().fill(engine.isTracking ? Color.green : Color.white.opacity(0.5)).frame(width: 9, height: 9)
                Text("Canlı Ayna").font(.headline).foregroundStyle(.white)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(engine.isTracking ? "Canlı Ayna, seni görüyor" : "Canlı Ayna, kişi aranıyor")
            .accessibilityIdentifier("mirrorStatus")
            Spacer()
            Label("Yerel", systemImage: "lock.fill")
                .font(.caption.weight(.semibold)).foregroundStyle(.white)
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .accessibilityLabel("Görüntü bu iPhone'da kalır")
        }
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var sideButtons: some View {
        VStack(spacing: 14) {
            roundButton("camera", label: "Fotoğrafını çek", id: "mirrorCapture") { capture() }
            if engine.canFlip {
                roundButton("arrow.triangle.2.circlepath", label: "Kamerayı çevir", id: "mirrorFlip") { engine.flip() }
            }
            if !choices.isEmpty {
                roundButton("hanger", label: "Ürünü değiştir", id: "mirrorChange") { showPicker = true }
            }
        }
        .environment(\.colorScheme, .dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding(.trailing, 16)
        .padding(.bottom, 120)
    }

    private var bottomArea: some View {
        VStack(spacing: 10) {
            if let note = engine.note {
                Text(note).font(.footnote.weight(.medium)).foregroundStyle(.white).multilineTextAlignment(.center)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .accessibilityIdentifier("mirrorNote")
            }
            HStack(alignment: .center) {
                Button { if !choices.isEmpty { showPicker = true } } label: {
                    GarmentThumb(item: engine.item, padding: 6)
                        .frame(width: 64, height: 78)
                        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white, lineWidth: 2))
                }
                .accessibilityLabel("Denenen ürün: \(engine.item.name)")
                .accessibilityIdentifier("mirrorProduct")
                Spacer()
                Button { capture() } label: {
                    ZStack {
                        Circle().stroke(.white, lineWidth: 4).frame(width: 76, height: 76)
                        Circle().fill(.white).frame(width: 62, height: 62)
                    }
                }
                .accessibilityLabel("Fotoğrafını çek")
                .accessibilityIdentifier("mirrorShutter")
                Spacer()
                Color.clear.frame(width: 64, height: 78)
            }
            VStack(spacing: 2) {
                Text(productLine ?? engine.item.name).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                Text(engine.truthLabel)
                    .font(.caption2).foregroundStyle(.white.opacity(0.85)).multilineTextAlignment(.center)
                    .accessibilityIdentifier("mirrorTruthLabel")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ürünü değiştir").font(AtelierType.cardTitle)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(choices) { item in
                        Button { engine.item = item; showPicker = false } label: {
                            VStack(spacing: 6) {
                                GarmentThumb(item: item).frame(width: 84, height: 96)
                                    .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(item.id == engine.item.id ? Atelier.brand : .clear, lineWidth: 2))
                                Text(item.name).font(.caption).lineLimit(1).frame(width: 84)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("mirrorChoice-\(item.id)")
                    }
                }
            }
        }
        .padding(20)
    }

    private func roundButton(_ symbol: String, label: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.title3.weight(.medium)).foregroundStyle(.white)
                .frame(width: 50, height: 50).background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel(label)
        .accessibilityIdentifier(id)
    }

    private func capture() {
        guard let image = engine.compose() else { return }
        if !reduceMotion {
            withAnimation(.easeOut(duration: 0.08)) { flash = true }
            withAnimation(.easeIn(duration: 0.25).delay(0.08)) { flash = false }
        }
        captured = CapturedLook(image: image, label: engine.truthLabel)
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

/// A photo the user took in the mirror. Not saved anywhere until they choose to share it.
struct CapturedLook: Identifiable {
    let id = UUID()
    let image: UIImage
    let label: String
}

private struct CapturedLookSheet: View {
    let look: CapturedLook
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(uiImage: look.image).resizable().scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .accessibilityLabel("Aynada çektiğin fotoğraf")
                Text(look.label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Text("Fotoğraf kaydedilmedi. Yalnız paylaşırsan bu iPhone'dan çıkar.")
                    .font(.caption).foregroundStyle(.secondary)
                ShareLink(item: Image(uiImage: look.image), preview: SharePreview("Canlı Ayna", image: Image(uiImage: look.image))) {
                    Label("Paylaş", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent).tint(Atelier.brand)
                .accessibilityIdentifier("mirrorShare")
            }
            .padding(20)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("mirrorCaptured")
        }
    }
}

// MARK: - Engine

/// One person's pose in frame coordinates (0…1, x right, y down, as the user sees it).
struct FramePose: Sendable {
    var joints: [BodyJoint: CGPoint]
}

/// What one analysed frame produced.
struct FrameResult: Sendable {
    let sequence: UInt64
    let capturedAt: TimeInterval
    let people: [FramePose]
    let aspect: CGFloat
    let meanLuma: Double
}

@Observable
@MainActor
final class MirrorEngine {
    enum State: Equatable { case starting, running, denied, unavailable, fault(MirrorFault) }
    enum Source: Equatable { case camera, fixture }
    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "mirror")

    var item: DressItem
    private(set) var state: State = .starting
    private(set) var source: Source = .camera
    private(set) var position: AVCaptureDevice.Position = .front
    private(set) var tracking: MirrorTracking = .noPerson
    private(set) var aspect: CGFloat = 9.0 / 16.0
    private(set) var gain: Double = 1
    private(set) var poseFPS: Double?
    private(set) var fixtureFrame: UIImage?
    let camera = MirrorCamera()

    private var gate = FrameGate(maxAge: 0.25)
    private var smoother = PoseSmoother()
    private var frames = 0
    private var windowStart = CACurrentMediaTime()
    private var fixture: MirrorFixture?

    init(item: DressItem) { self.item = item }

    var isTracking: Bool { if case .tracking = tracking { true } else { false } }
    var canFlip: Bool { source == .camera && camera.hasBothCameras }

    var note: String? {
        if source == .fixture, isTracking {
            return fixture?.usesStoredPose == true
                ? "Simülatör örneği: kamera değil, çizilmiş bir figür · poz önceden okundu"
                : "Simülatör örneği: kamera değil, çizilmiş bir figür."
        }
        if let n = tracking.note { return n }
        if GarmentSprites.shared.spec(for: item.form) == nil { return "Bu ürün türünün aynada çizimi yok; yalnız kamera görüntüsü." }
        switch ProcessInfo.processInfo.thermalState {
        case .serious: return DegradeReason.deviceWarm.note
        default: break
        }
        return ProcessInfo.processInfo.isLowPowerModeEnabled ? DegradeReason.lowPower.note : nil
    }

    var truthLabel: String {
        GarmentSprites.shared.spec(for: item.form) == nil ? MirrorFidelity.cameraOnly.truthLabel
            : "Temsilî çizim, kişinin duruşunu izler · kumaş benzetimi değildir · beden uyumunu göstermez"
    }

    func start() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-mirrorFixture"), let fixture = MirrorFixture() {
            self.fixture = fixture
            source = .fixture
            state = .running
            fixture.onFrame = { [weak self] image, result in
                Task { @MainActor in
                    self?.fixtureFrame = image
                    self?.receive(result)
                }
            }
            fixture.start()
            return
        }
        #endif
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
            || AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil else {
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
        if ProcessInfo.processInfo.thermalState == .critical { state = .fault(.deviceTooHot); return }
        camera.onFrame = { [weak self] result in Task { @MainActor in self?.receive(result) } }
        camera.start(position: position)
        state = .running
    }

    func stop() {
        camera.stop()
        fixture?.stop()
        smoother.reset()
    }

    func flip() {
        position = position == .front ? .back : .front
        smoother.reset()
        camera.start(position: position)
    }

    private func receive(_ r: FrameResult) {
        guard gate.admit(sequence: r.sequence, capturedAt: r.capturedAt, now: CACurrentMediaTime()) else { return }
        if ProcessInfo.processInfo.thermalState == .critical {
            stop()
            state = .fault(.deviceTooHot)
            return
        }
        aspect = r.aspect
        gain = FrameLight.gain(meanLuma: r.meanLuma)
        let family = GarmentSprites.shared.spec(for: item.form)?.family ?? "top"
        let poses = r.people.map { BodyPose2D(points: $0.joints) }
        switch MirrorTracking.decide(people: poses, family: family) {
        case .tracking(let pose):
            tracking = .tracking(smoother.smooth(pose, at: r.capturedAt))
        case let other:
            smoother.reset()
            tracking = other
        }
        frames += 1
        let now = CACurrentMediaTime()
        if now - windowStart >= 1 {
            poseFPS = Double(frames) / (now - windowStart)
            Self.log.info("mirror pose fps \(self.poseFPS ?? 0, privacy: .public) dropped \(self.gate.dropped, privacy: .public)")
            frames = 0
            windowStart = now
        }
    }

    // MARK: Drawing

    /// Frame (0…1) → view points, aspect-fill like the preview layer.
    private func mapper(for size: CGSize) -> (CGPoint) -> CGPoint {
        let viewAspect = size.width / size.height
        let (sx, sy, ox, oy): (CGFloat, CGFloat, CGFloat, CGFloat)
        if aspect > viewAspect {
            let w = size.height * aspect
            (sx, sy, ox, oy) = (w, size.height, (size.width - w) / 2, 0)
        } else {
            let h = size.width / aspect
            (sx, sy, ox, oy) = (size.width, h, 0, (size.height - h) / 2)
        }
        return { CGPoint(x: ox + $0.x * sx, y: oy + $0.y * sy) }
    }

    func draw(in context: inout GraphicsContext, size: CGSize) {
        guard case .tracking(let pose) = tracking, let spec = GarmentSprites.shared.spec(for: item.form) else { return }
        let map = mapper(for: size)
        let viewPose = BodyPose2D(points: pose.points.mapValues(map))
        guard case .placed(let parts) = GarmentRig.place(spec, on: viewPose) else { return }
        let tint = Color(rgb: item.colorHex).liftedForTint
        let g = gain
        for placement in parts {
            guard let part = spec.parts[placement.part] else { continue }
            let rect = CGRect(x: 0, y: 0, width: part.size[0], height: part.size[1])
            if let fabric = GarmentSprites.shared.image(part.files["fabric"]) {
                context.drawLayer { layer in
                    layer.concatenate(placement.transform)
                    layer.addFilter(.shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6))
                    layer.addFilter(.colorMultiply(tint))
                    layer.addFilter(.brightness(g - 1))
                    layer.draw(Image(uiImage: fabric), in: rect)
                }
            }
            if let fixed = GarmentSprites.shared.image(part.files["fixed"]) {
                context.drawLayer { layer in
                    layer.concatenate(placement.transform)
                    layer.draw(Image(uiImage: fixed), in: rect)
                }
            }
        }
    }

    /// The current frame with the garment drawn on it, at the frame's own resolution.
    func compose() -> UIImage? {
        let base: UIImage?
        if source == .fixture { base = fixtureFrame } else { base = camera.latestImage() }
        guard let base else { return nil }
        let size = base.size
        let renderer = ImageRenderer(content: ZStack {
            Image(uiImage: base).resizable().frame(width: size.width, height: size.height)
            Canvas { context, s in self.draw(in: &context, size: s) }.frame(width: size.width, height: size.height)
        })
        renderer.scale = 1
        return renderer.uiImage
    }
}

// MARK: - Camera

/// Camera session and pose requests on a private queue. Frames live only in memory, one at a time;
/// the microphone is never used.
final class MirrorCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onFrame: (@Sendable (FrameResult) -> Void)?
    private let queue = DispatchQueue(label: "app.kabinsiz.mirror.camera", qos: .userInteractive)
    private let output = AVCaptureVideoDataOutput()
    private var position: AVCaptureDevice.Position?
    private var sequence: UInt64 = 0
    private var skip = false
    private let lock = NSLock()
    private var lastBuffer: CVPixelBuffer?

    var hasBothCameras: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
            && AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    func start(position: AVCaptureDevice.Position) {
        queue.async { [self] in
            if self.position != position { configure(position) }
            if !session.isRunning { session.startRunning() }
        }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning { session.stopRunning() }
            lock.withLock { lastBuffer = nil }
        }
    }

    func latestImage() -> UIImage? {
        guard let buffer = lock.withLock({ lastBuffer }) else { return nil }
        let ci = CIImage(cvPixelBuffer: buffer)
        guard let cg = CIContext().createCGImage(ci, from: ci.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    private func configure(_ position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720
        for input in session.inputs { session.removeInput(input) }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        if !session.outputs.contains(output) {
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: queue)
            if session.canAddOutput(output) { session.addOutput(output) }
        }
        if let connection = output.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) { connection.videoRotationAngle = 90 }
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = position == .front
            }
        }
        session.commitConfiguration()
        self.position = position
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lock.withLock { lastBuffer = buffer }
        // When warm, analyse every other frame (the picture itself stays live).
        if ProcessInfo.processInfo.thermalState == .serious { skip.toggle(); if skip { return } }
        sequence += 1
        let captured = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        let stamp = captured.isFinite && captured > 0 ? captured : CACurrentMediaTime()
        let w = CGFloat(CVPixelBufferGetWidth(buffer)), h = CGFloat(CVPixelBufferGetHeight(buffer))
        let people = MirrorVision.people(in: VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up))
        onFrame?(FrameResult(sequence: sequence, capturedAt: stamp, people: people, aspect: w / h, meanLuma: Self.meanLuma(buffer)))
    }

    /// Average brightness from a sparse grid of BGRA pixels.
    static func meanLuma(_ buffer: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return 0.5 }
        let w = CVPixelBufferGetWidth(buffer), h = CVPixelBufferGetHeight(buffer), row = CVPixelBufferGetBytesPerRow(buffer)
        let p = base.assumingMemoryBound(to: UInt8.self)
        var sum = 0.0, n = 0.0
        for y in stride(from: 0, to: h, by: max(h / 32, 1)) {
            for x in stride(from: 0, to: w, by: max(w / 32, 1)) {
                let o = y * row + x * 4
                sum += (0.114 * Double(p[o]) + 0.587 * Double(p[o + 1]) + 0.299 * Double(p[o + 2])) / 255
                n += 1
            }
        }
        return n > 0 ? sum / n : 0.5
    }
}

enum MirrorVision {
    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "mirror")
    static let joints: [(VNHumanBodyPoseObservation.JointName, BodyJoint)] = [
        (.nose, .nose), (.neck, .neck), (.leftShoulder, .leftShoulder), (.rightShoulder, .rightShoulder),
        (.leftElbow, .leftElbow), (.rightElbow, .rightElbow), (.leftWrist, .leftWrist), (.rightWrist, .rightWrist),
        (.leftHip, .leftHip), (.rightHip, .rightHip), (.leftKnee, .leftKnee), (.rightKnee, .rightKnee),
        (.leftAnkle, .leftAnkle), (.rightAnkle, .rightAnkle),
    ]

    /// Every person Vision finds, joints above 0.3 confidence, in 0…1 with y down.
    static func people(in handler: VNImageRequestHandler) -> [FramePose] {
        let request = VNDetectHumanBodyPoseRequest()
        #if targetEnvironment(simulator)
        // The Simulator has no Neural Engine; pin the request to the CPU so the fixture path runs.
        if let devices = try? request.supportedComputeStageDevices[.main],
           let cpu = devices.first(where: { if case .cpu = $0 { true } else { false } }) {
            request.setComputeDevice(cpu, for: .main)
        }
        #endif
        do { try handler.perform([request]) } catch {
            log.error("pose request failed: \(error.localizedDescription, privacy: .public)")
            return []
        }
        guard let results = request.results else { return [] }
        return results.compactMap { observation in
            guard let points = try? observation.recognizedPoints(.all) else { return nil }
            var out: [BodyJoint: CGPoint] = [:]
            for (vn, joint) in joints {
                if let p = points[vn], p.confidence > 0.3 { out[joint] = CGPoint(x: p.location.x, y: 1 - p.location.y) }
            }
            return FramePose(joints: out)
        }
    }
}

#if DEBUG
/// Simulator fixture: a plain rendered figure (tools/garments --mannequin, no real person) that sways a
/// little, run through the same Vision pose path as the camera. Shown with a "not a camera" note.
final class MirrorFixture: @unchecked Sendable {
    var onFrame: (@Sendable (UIImage, FrameResult) -> Void)?
    private let base: CGImage
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "app.kabinsiz.mirror.fixture", qos: .userInitiated)
    private var sequence: UInt64 = 0
    private let started = CACurrentMediaTime()
    /// The fixture's pose as macOS Vision read it (tools/garments/fixture_pose.swift). Used only when
    /// Vision cannot run here: the iOS Simulator has no setup for the body-pose request.
    private let storedPose: [BodyJoint: CGPoint]
    private(set) var usesStoredPose = false

    init?() {
        guard let url = Bundle.main.url(forResource: "MirrorFixture", withExtension: "jpg"),
              let image = UIImage(contentsOfFile: url.path)?.cgImage else { return nil }
        base = image
        storedPose = Self.loadStoredPose()
    }

    private static func loadStoredPose() -> [BodyJoint: CGPoint] {
        guard let url = Bundle.main.url(forResource: "MirrorFixturePose", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              json["provenance"] as? String == "OWNED_ORIGINAL",
              let joints = json["joints"] as? [String: [Double]] else { return [:] }
        var out: [BodyJoint: CGPoint] = [:]
        for (name, xy) in joints where xy.count == 2 {
            if let joint = BodyJoint(rawValue: name) { out[joint] = CGPoint(x: xy[0], y: xy[1]) }
        }
        return out
    }

    func start() {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: 1.0 / 12)
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        timer = t
    }

    func stop() { timer?.cancel(); timer = nil }

    private func tick() {
        let time = CACurrentMediaTime() - started
        let w = base.width, h = base.height
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return }
        ctx.setFillColor(CGColor(red: 0.78, green: 0.74, blue: 0.68, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        // Sway: a slow lean and side step around the feet, like someone checking a mirror.
        let lean = CGFloat(sin(time * 0.9)) * 0.045
        let step = CGFloat(sin(time * 0.55)) * CGFloat(w) * 0.05
        let sway = CGAffineTransform(translationX: -CGFloat(w) / 2, y: -CGFloat(h) * 0.26)
            .concatenating(CGAffineTransform(rotationAngle: lean))
            .concatenating(CGAffineTransform(translationX: CGFloat(w) / 2 + step, y: CGFloat(h) * 0.26))
        ctx.concatenate(sway)
        ctx.draw(base, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let frame = ctx.makeImage() else { return }
        sequence += 1
        // Vision first; once it has failed here, do not retry it every frame.
        var people = usesStoredPose ? [] : MirrorVision.people(in: VNImageRequestHandler(cgImage: frame, orientation: .up))
        if people.isEmpty, !storedPose.isEmpty {
            // Same sway applied to the stored joints (CG space is y up; the pose is 0…1, y down).
            usesStoredPose = true
            let W = CGFloat(w), H = CGFloat(h)
            people = [FramePose(joints: storedPose.mapValues { p in
                let q = CGPoint(x: p.x * W, y: (1 - p.y) * H).applying(sway)
                return CGPoint(x: q.x / W, y: 1 - q.y / H)
            })]
        }
        let result = FrameResult(sequence: sequence, capturedAt: CACurrentMediaTime(), people: people,
                                 aspect: CGFloat(w) / CGFloat(h), meanLuma: 0.62)
        onFrame?(UIImage(cgImage: frame), result)
    }
}
#endif

/// The camera picture as the user sees it in a mirror.
private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let mirrored: Bool

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        apply(view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) { apply(uiView) }

    private func apply(_ view: PreviewView) {
        guard let connection = view.previewLayer.connection else { return }
        if connection.isVideoRotationAngleSupported(90) { connection.videoRotationAngle = 90 }
        if connection.isVideoMirroringSupported { connection.automaticallyAdjustsVideoMirroring = false; connection.isVideoMirrored = mirrored }
    }
}

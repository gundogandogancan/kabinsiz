import BodyGeometry
import DomainContracts
import GarmentPattern
import ImageIO
import PhotosUI
import ProductCapture
import SelfModel
import SwiftUI

/// V37 "fotoğrafı çekilen kıyafet 3B kalıp olmalı" (ADR-018 §7): one flat-lay photo becomes a garment
/// sewn from its own pattern, with the photo's own front on it. With an A4 sheet beside the garment its
/// sizes are read; without, the pattern is the basic block on the user's body and says so. Nothing is
/// saved before "Dolaba ekle"; the photo itself is never stored, only the cropped front.
struct PhotoGarmentFlowView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var onAdded: () -> Void = {}

    enum Step { case intro, working, review(PhotoGarmentProposal), failed(String) }

    @State private var step: Step = .intro
    @State private var pickerItem: PhotosPickerItem?
    @State private var kind: GarmentKind = .top
    @State private var name = ""
    @State private var nameEdited = false

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .intro: intro
                case .working:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Giysi iPhone'da ayrılıyor ve ölçülüyor").font(.subheadline).foregroundStyle(Token.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("photoGarmentWorking")
                case let .review(p): review(p)
                case let .failed(message):
                    ContentUnavailableView {
                        Label("Giysi ayrılamadı", systemImage: "tshirt")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Başka fotoğraf seç") { step = .intro }
                    }
                    .accessibilityIdentifier("photoGarmentFailed")
                }
            }
            .navigationTitle("Fotoğraftan 3B giysi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
    }

    // MARK: Intro

    private var intro: some View {
        Form {
            Section {
                Label("Düz, tek renk bir zemine ser; tepeden, önden çek.", systemImage: "camera.viewfinder")
                Label("Yanına bir A4 kâğıt koyarsan ölçüsü de okunur.", systemImage: "doc")
                Label("Önündeki desen ve yazı, 3B giysinin önüne aynen konur.", systemImage: "paintbrush.pointed")
                Label("Fotoğraf iPhone'dan çıkmaz, saklanmaz.", systemImage: "lock.iphone")
            } header: {
                Text("Tek fotoğraf, tek giysi")
            }
            Section {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Fotoğraf seç", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .accessibilityIdentifier("photoGarmentPick")
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-photoGarmentFixture") {
                    Button("Örnek fotoğrafla dene (sentetik fikstür)") { Task { await runFixture() } }
                        .accessibilityIdentifier("photoGarmentFixture")
                }
                #endif
            }
        }
    }

    // MARK: Run

    private func load(_ item: PhotosPickerItem) async {
        step = .working
        guard let data = try? await item.loadTransferable(type: Data.self), let image = SelfModelFlowView.orientedImage(data) else {
            step = .failed("Bu fotoğraf açılamadı.")
            return
        }
        await analyze(image)
    }

    #if DEBUG
    private func runFixture() async {
        step = .working
        guard let url = Bundle.main.url(forResource: "PhotoGarmentFixture", withExtension: "png"),
              let data = try? Data(contentsOf: url), let image = SelfModelFlowView.orientedImage(data)
        else { step = .failed("Fikstür bulunamadı."); return }
        await analyze(image)
    }
    #endif

    private func analyze(_ image: CGImage) async {
        // Vision first; where it has no model (the Simulator) the pixel paths read the same photo.
        let result: Result<PhotoGarmentProposal, PhotoGarmentIntake.Failure>
        do {
            result = .success(try await VisionLane.run { try PhotoGarmentIntake.read(image) })
        } catch {
            do { result = .success(try await VisionLane.run { try PhotoGarmentIntake.read(image, useVision: false) }) }
            catch let e as PhotoGarmentIntake.Failure { result = .failure(e) }
            catch { result = .failure(.noGarmentFound) }
        }
        switch result {
        case let .success(p):
            kind = p.kind
            nameEdited = false
            name = Self.suggestedName(p, kind: p.kind)
            step = .review(p)
        case let .failure(e):
            step = .failed(e.reason)
        }
    }

    static func suggestedName(_ p: PhotoGarmentProposal, kind: GarmentKind) -> String {
        let colour = p.colourName.prefix(1).uppercased() + p.colourName.dropFirst()
        return "\(colour) \(kind.wardrobeName.lowercased(with: Locale(identifier: "tr_TR")))"
    }

    // MARK: Review

    private func review(_ p: PhotoGarmentProposal) -> some View {
        let made = Result { try PhotoGarmentIntake.make(garmentID: "preview", proposal: p, kind: kind, body: model.body, at: .now) }
        return Form {
            Section {
                HStack(alignment: .top, spacing: 14) {
                    if let ui = UIImage(data: p.frontPNG) {
                        Image(uiImage: ui)
                            .resizable()
                            .aspectRatio(p.frontAspect, contentMode: .fit)
                            .frame(width: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel("Giysinin önü, fotoğraftan")
                            .accessibilityIdentifier("photoGarmentFront")
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ön yüz, fotoğrafın kendi pikseli").font(.subheadline.weight(.semibold))
                        Text("Renk: \(p.colourName)").font(.caption).foregroundStyle(Token.textSecondary)
                        Text(p.cutoutMethod == .visionForeground ? "Arka plan cihazda ayrıldı" : "Arka plan renk farkından ayrıldı")
                            .font(.caption).foregroundStyle(Token.textSecondary)
                    }
                }
                Picker("Tür", selection: $kind) {
                    ForEach(PhotoGarmentIntake.sewableKinds, id: \.self) { Text($0.displayName).tag($0) }
                }
                .accessibilityIdentifier("photoGarmentKind")
                .onChange(of: kind) { _, k in if !nameEdited { name = Self.suggestedName(p, kind: k) } }
                TextField("Adı", text: Binding(get: { name }, set: { name = $0; nameEdited = true }))
                    .accessibilityIdentifier("photoGarmentName")
            } header: {
                Text("Giysi")
            }

            Section {
                if let m = p.measurement {
                    ForEach(m.values, id: \.kind) { v in
                        Text(v.line).accessibilityIdentifier("photoGarmentSize-\(v.kind.rawValue)")
                    }
                } else {
                    Text(p.noMeasurementReason ?? "Ölçü yok.")
                        .foregroundStyle(Token.textSecondary)
                        .accessibilityIdentifier("photoGarmentNoSizes")
                }
            } header: {
                Text("Ebat")
            } footer: {
                Text(p.measurement?.limitations.joined(separator: " ") ?? "Ölçü yoksa santimetre uydurmayız.")
            }

            Section {
                switch made {
                case let .success(g):
                    PatternSheetView(pattern: g.pattern)
                        .frame(height: 180)
                        .accessibilityIdentifier("photoGarmentPattern")
                    Text(g.pattern.provenance).font(.caption).foregroundStyle(Token.textSecondary)
                case let .failure(error):
                    Text((error as? PhotoGarmentIntake.Failure)?.reason ?? "Bu türde kalıp çizilemedi; başka bir tür seç.")
                        .foregroundStyle(Token.textSecondary)
                        .accessibilityIdentifier("photoGarmentNoPattern")
                }
            } header: {
                Text("Kalıp")
            } footer: {
                if case let .success(g) = made { Text(g.basis.joined(separator: " ")) }
            }

            Section {
                Button {
                    add(p)
                } label: {
                    Text("Dolaba ekle").frame(maxWidth: .infinity).fontWeight(.semibold)
                }
                .disabled((try? made.get()) == nil || name.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityIdentifier("photoGarmentApply")
            }
        }
    }

    private func add(_ p: PhotoGarmentProposal) {
        let id = "usr-\(UUID().uuidString)"
        guard let photo = try? PhotoGarmentIntake.make(garmentID: id, proposal: p, kind: kind, body: model.body, at: .now) else { return }
        let garment = Garment(
            id: id, name: name.trimmingCharacters(in: .whitespaces), category: kind.wardrobeCategory,
            formalityRange: .casual ... .smart, colorName: p.colourName, isNeutralColor: p.isNeutralColour,
            provenance: .userEntered
        )
        model.addPhotoGarment(garment, photo)
        onAdded()
        dismiss()
    }
}

/// The pattern's pieces side by side at one scale, with the grain line: the "kalıp" itself, not a picture.
struct PatternSheetView: View {
    let pattern: SewingPattern

    var body: some View {
        Canvas { ctx, size in
            let pieces = pattern.pieces
            let gap = 4.0
            let totalW = pieces.map(\.bounds.width).reduce(0, +) + gap * Double(max(0, pieces.count - 1))
            let maxH = pieces.map(\.bounds.height).max() ?? 1
            let scale = min(Double(size.width) / max(totalW, 1), Double(size.height) / max(maxH, 1)) * 0.94
            var x = (Double(size.width) - totalW * scale) / 2
            for piece in pieces {
                let b = piece.bounds
                func p(_ q: PatternPoint) -> CGPoint { CGPoint(x: x + (q.x - b.minX) * scale, y: (q.y - b.minY) * scale + 4) }
                var outline = Path()
                if let first = piece.outline.first {
                    outline.move(to: p(first))
                    for q in piece.outline.dropFirst() { outline.addLine(to: p(q)) }
                    outline.closeSubpath()
                }
                ctx.fill(outline, with: .color(Token.surfaceCard))
                ctx.stroke(outline, with: .color(Token.textPrimary), lineWidth: 1)
                var grain = Path()
                grain.move(to: p(piece.grainline.start))
                grain.addLine(to: p(piece.grainline.end))
                ctx.stroke(grain, with: .color(Token.textSecondary), style: StrokeStyle(lineWidth: 0.8, dash: [3, 2]))
                ctx.draw(Text(piece.name).font(.caption2), at: CGPoint(x: x + b.width * scale / 2, y: b.height * scale / 2 + 4))
                x += (b.width + gap) * scale
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Kalıp: \(pattern.pieces.map(\.name).joined(separator: ", "))")
    }
}

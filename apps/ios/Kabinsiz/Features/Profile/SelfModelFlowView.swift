import BodyGeometry
import DomainContracts
import ImageIO
import PhotosUI
import SelfModel
import ShoppingCopilot
import SwiftUI

/// V37 "Fotoğraftan modelimi kur": one photo the user picks → skin, hair, (opt-in) face, body estimates,
/// what they wear and a printed brand name, each a proposal they tick. Nothing leaves the phone; the photo
/// lives only in memory for the analysis. Simplicity budget (docs/research/rivals/v37-…): one primary
/// action per step, at most five taps from Benim Modelim to a dressed, personal figure.
struct SelfModelFlowView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    enum Step { case intro, working, review(SelfModelProposal, [String]), failed(String) }

    @State private var step: Step = .intro
    @State private var heightText = ""
    @State private var wantsFace = false
    @FocusState private var heightFocused: Bool
    @State private var pickerItem: PhotosPickerItem?
    // Review choices.
    @State private var useLook = true
    @State private var useFace = false
    @State private var likeness = false
    @State private var acceptedBody: Set<BodyParameter> = []
    @State private var acceptedGarments: Set<WornGarment.Slot> = []

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .intro: intro
                case .working:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Fotoğrafın iPhone'da okunuyor").font(.subheadline).foregroundStyle(Token.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("selfModelWorking")
                case let .review(p, notes): review(p, notes)
                case let .failed(message):
                    ContentUnavailableView {
                        Label("Fotoğraf okunamadı", systemImage: "person.crop.rectangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Başka fotoğraf seç") { step = .intro }
                    }
                    .accessibilityIdentifier("selfModelFailed")
                }
            }
            .navigationTitle("Modelimi kur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } }
                // The decimal pad has no return key: without this the keyboard hides the photo buttons.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Bitti") { heightFocused = false }.accessibilityIdentifier("selfModelKeyboardDone")
                }
            }
        }
        // A pull-down must not throw away a running analysis or unsaved review choices; "Kapat" still closes.
        .interactiveDismissDisabled(!isIntro)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
    }

    // MARK: Intro

    private var intro: some View {
        Form {
            Section {
                Label("Fotoğraf iPhone'dan çıkmaz, saklanmaz.", systemImage: "lock.iphone")
                Label("Kimliğin tanınmaz; yalnız ten, saç, beden oranı ve üzerindekiler okunur.", systemImage: "eye.slash")
                Label("Her şeyi sen onaylarsın, istediğin an silersin.", systemImage: "hand.tap")
            } header: {
                Text("Tek fotoğraf: baştan ayağa, önden, tek kişi")
            }
            Section {
                HStack {
                    Text("Boyun")
                    TextField("örn. 172", text: $heightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($heightFocused)
                        .accessibilityIdentifier("selfModelHeight")
                    Text("cm").foregroundStyle(Token.textSecondary)
                }
                Toggle("Yüzümü de modelde göster", isOn: $wantsFace)
                    .accessibilityIdentifier("selfModelWantsFace")
            } footer: {
                Text("Boy, fotoğraftaki tek cetvel: yazmazsan beden okunmaz. Yüz, yalnız açarsan ve \"bu bana benziyor\" dersen modelin başına konur.")
            }
            Section {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Fotoğraf seç", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .accessibilityIdentifier("selfModelPick")
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-selfModelFixture") {
                    Button("Örnek fotoğrafla dene (simülatör fikstürü)") { Task { await runFixture() } }
                        .accessibilityIdentifier("selfModelFixture")
                }
                #endif
            }
        }
    }

    private var isIntro: Bool { if case .intro = step { true } else { false } }

    private var heightCm: Double? {
        Double(heightText.replacingOccurrences(of: ",", with: ".")).flatMap { BodyParameter.height.safeRange.contains($0) ? $0 : nil }
    }

    // MARK: Run

    private func load(_ item: PhotosPickerItem) async {
        heightFocused = false
        step = .working
        guard let data = try? await item.loadTransferable(type: Data.self), let image = Self.orientedImage(data) else {
            step = .failed("Bu fotoğraf açılamadı.")
            return
        }
        await analyze(image, stored: nil)
    }

    /// Upright and at most 2048 px on the long side: EXIF rotation applied, memory bounded.
    static func orientedImage(_ data: Data) -> CGImage? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let opts: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceCreateThumbnailWithTransform: true,
                                     kCGImageSourceThumbnailMaxPixelSize: 2048]
        return CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary)
    }

    #if DEBUG
    private func runFixture() async {
        heightFocused = false
        step = .working
        guard let url = Bundle.main.url(forResource: "SelfModelFixture", withExtension: "jpg"),
              let data = try? Data(contentsOf: url), let image = Self.orientedImage(data),
              let poseURL = Bundle.main.url(forResource: "SelfModelFixturePose", withExtension: "json"),
              let pose = try? JSONDecoder().decode(BodyKeypoints.self, from: Data(contentsOf: poseURL))
        else { step = .failed("Fikstür bulunamadı."); return }
        await analyze(image, stored: pose)
    }
    #endif

    private func analyze(_ image: CGImage, stored: BodyKeypoints?) async {
        let brands = model.catalog.brandWordmarks
        let options = SelfModelPipeline.Options(userHeightCm: heightCm, brands: brands, makeFaceTexture: wantsFace, storedKeypoints: stored)
        let outcome = await SelfModelPipeline.run(image, options: options)
        guard let proposal = outcome.envelope.value else {
            var message = "Fotoğrafta tek bir kişi baştan ayağa ve önden görünmeli. Işıklı, sade bir arka plan en iyisi."
            #if DEBUG
            let nodes = outcome.nodeStates.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: " ")
            message += "\n[debug] \(outcome.envelope.state) \(outcome.envelope.fault.map { "\($0)" } ?? "-") \(nodes)"
            #endif
            step = .failed(message)
            return
        }
        useLook = proposal.appearance != nil
        useFace = wantsFace && proposal.faceTexturePNG != nil
        likeness = false
        acceptedBody = Set(proposal.body?.estimates.map(\.parameter) ?? [])
        acceptedGarments = Set(proposal.worn?.garments.filter { !$0.needsUserChoice }.map(\.slot) ?? [])
        step = .review(proposal, outcome.envelope.limitations)
    }

    // MARK: Review

    private func review(_ p: SelfModelProposal, _ notes: [String]) -> some View {
        let notVision = p.poseSource != "Apple Vision, cihazda"
        return Form {
            // A source other than this phone's own reading (the Simulator fixture) is said first, not last.
            if notVision {
                Section {
                    Label(p.poseSource, systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("selfModelPoseSource")
                }
            }
            if let a = p.appearance {
                Section {
                    Toggle(isOn: $useLook) {
                        HStack(spacing: 12) {
                            swatch(a.skinRGB)
                            if let hair = a.hairRGB { swatch(hair) }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ten \(a.skinToneStep)/10 · saç \(a.hairColourName ?? "görünmüyor"), \(a.hairLength.displayName.lowercased())")
                                Text("Fotoğrafın pikselinden").font(.caption).foregroundStyle(Token.textSecondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("selfModelUseLook")
                    if let png = p.faceTexturePNG, let ui = UIImage(data: png) {
                        Toggle(isOn: $useFace) {
                            HStack(spacing: 12) {
                                Image(uiImage: ui).resizable().frame(width: 44, height: 44).clipShape(Circle())
                                Text("Yüzüm modelde görünsün")
                            }
                        }
                        .accessibilityIdentifier("selfModelUseFace")
                        if useFace {
                            Toggle("Bu bana benziyor", isOn: $likeness)
                                .accessibilityIdentifier("selfModelLikeness")
                        }
                    }
                } header: {
                    Text("Görünüş")
                } footer: {
                    Text(a.limitations.joined(separator: " "))
                }
            }
            if let body = p.body {
                Section {
                    ForEach(body.estimates, id: \.parameter) { e in
                        Toggle(isOn: binding(e.parameter)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(e.parameter == .height ? "\(e.parameter.displayName) \(Int(e.centimeters)) cm"
                                                            : "\(e.parameter.displayName) ≈ \(Int(e.centimeters.rounded())) cm")
                                Text(e.parameter == .height ? "Senin yazdığın" : "Tahmin \(Int(e.low.rounded()))–\(Int(e.high.rounded())) cm · ölçü değil")
                                    .font(.caption).foregroundStyle(Token.textSecondary)
                            }
                        }
                        .accessibilityIdentifier("selfModelBody-\(e.parameter.rawValue)")
                    }
                } header: {
                    Text("Beden")
                } footer: {
                    Text(body.limitations.joined(separator: " "))
                }
            }
            if let worn = p.worn, !worn.garments.isEmpty {
                Section {
                    ForEach(worn.garments, id: \.slot) { g in
                        Toggle(isOn: garmentBinding(g.slot)) {
                            HStack(spacing: 12) {
                                swatch(g.colourRGB)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(g.colourName.capitalized(with: Locale(identifier: "tr_TR"))) \(Self.formName(g.form))")
                                    Text(g.basis).font(.caption).foregroundStyle(Token.textSecondary)
                                }
                            }
                        }
                        .accessibilityIdentifier("selfModelGarment-\(g.slot.rawValue)")
                    }
                    ForEach(p.brands, id: \.brandID) { b in
                        Label("Göğüste \"\(b.displayName)\" yazısı okundu", systemImage: "textformat")
                            .font(.subheadline)
                            .accessibilityIdentifier("selfModelBrand")
                    }
                } header: {
                    Text("Üzerindekiler → Dolabım")
                } footer: {
                    Text(worn.limitations.joined(separator: " "))
                }
            }
            if !notes.isEmpty {
                Section {
                    ForEach(notes, id: \.self) { Text($0).font(.caption) }
                }
            }
            Section {
                Button {
                    Task { await apply(p) }
                } label: {
                    Text("Modelime uygula").frame(maxWidth: .infinity).fontWeight(.semibold)
                }
                .disabled(useFace && !likeness)
                .accessibilityIdentifier("selfModelApply")
            } footer: {
                if useFace && !likeness { Text("Yüzün için önce \"Bu bana benziyor\" de ya da yüzü kapat.") }
            }
        }
    }

    private func apply(_ p: SelfModelProposal) async {
        let look = useLook ? p.look(withFace: useFace, confirmedLikeness: likeness) : nil
        let brand = p.brands.first?.brandID
        let garments: [Garment] = (p.worn?.garments ?? []).filter { acceptedGarments.contains($0.slot) }.map { g in
            Garment(id: "photo-\(g.slot.rawValue.lowercased())-\(UUID().uuidString.prefix(8))",
                    name: "\(g.colourName.capitalized(with: Locale(identifier: "tr_TR"))) \(Self.formName(g.form))",
                    category: g.category, formalityRange: .relaxed ... .casual, colorName: g.colourName,
                    isNeutralColor: GarmentPhotoNeutral.isNeutral(g.colourName),
                    brandID: g.slot == .top ? brand : nil, provenance: .userEntered)
        }
        await model.acceptSelfModel(look: look, bodyEdits: p.bodyEdits(accepting: acceptedBody), garments: garments)
        dismiss()
    }

    private func binding(_ p: BodyParameter) -> Binding<Bool> {
        Binding(get: { acceptedBody.contains(p) }, set: { if $0 { acceptedBody.insert(p) } else { acceptedBody.remove(p) } })
    }

    private func garmentBinding(_ s: WornGarment.Slot) -> Binding<Bool> {
        Binding(get: { acceptedGarments.contains(s) }, set: { if $0 { acceptedGarments.insert(s) } else { acceptedGarments.remove(s) } })
    }

    private func swatch(_ rgb: SIMD3<Double>) -> some View {
        Circle().fill(Color(red: rgb.x, green: rgb.y, blue: rgb.z)).frame(width: 28, height: 28)
            .overlay(Circle().stroke(Token.textSecondary.opacity(0.3)))
            .accessibilityHidden(true)
    }

    static func formName(_ form: String) -> String {
        switch form {
        case "tee": "kısa kollu üst"
        case "longSleeveTee": "uzun kollu üst"
        case "tank": "kolsuz üst"
        case "trousers": "pantolon"
        case "shorts": "şort"
        case "skirt": "etek"
        case "dress": "elbise"
        default: "ayakkabı"
        }
    }
}

/// Neutral closet colours (the gap finder's "nötr temel"), by the analyzer's names.
enum GarmentPhotoNeutral {
    static let names: Set<String> = ["siyah", "beyaz", "krem", "bej", "açık gri", "gri", "antrasit", "lacivert", "kahverengi", "camel"]
    static func isNeutral(_ name: String) -> Bool { names.contains(name) }
}

/// Benim Modelim's entry: build from a photo, or remove the personal look.
struct SelfModelSection: View {
    @Environment(AppModel.self) private var model
    @Binding var showFlow: Bool

    var body: some View {
        Section {
            Button {
                showFlow = true
            } label: {
                Label(model.personalLook == nil ? "Fotoğraftan modelimi kur" : "Modelimi fotoğraftan yenile", systemImage: "person.crop.rectangle")
            }
            .accessibilityIdentifier("selfModelOpen")
            if model.personalLook != nil {
                Button("Yüzümü ve görünüşümü sil", role: .destructive) { model.deletePersonalLook() }
                    .accessibilityIdentifier("selfModelDeleteLook")
            }
        } footer: {
            Text(model.personalLook?.drawsFace == true ? "Modelinde yüzün var; yalnız bu cihazda, şifreli." : "Ten, saç ve istersen yüzün; hepsi bu cihazda.")
        }
    }
}

extension ProductResolver {
    /// Written brand marks the self-model may read: the catalogue's brand names, plus the short print the
    /// synthetic demo brands carry ("ORNEK A"). A licensed partner feed would ship its own wordmarks.
    var brandWordmarks: [BrandWordmark] {
        var seen: [String: BrandWordmark] = [:]
        for p in products where seen[p.brandID] == nil {
            let short = p.brandName.replacingOccurrences(of: "Marka ", with: "")
            seen[p.brandID] = BrandWordmark(brandID: p.brandID, displayName: p.brandName,
                                            marks: Array(Set([p.brandName, short])).sorted())
        }
        return seen.values.sorted { $0.brandID < $1.brandID }
    }
}

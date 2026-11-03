import DomainContracts
import FitPassport
import ShoppingCopilot
import SwiftUI
import SystemContracts

/// "Tara" → product code → one decision card (§60). Camera scanning is P0-deferred (D-002):
/// manual code entry is the documented fallback when the camera is unavailable (§60.3).
struct ScanView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scannedCode) private var scannedCode
    /// Dene passes this: a found product can go straight on the model or into the mirror.
    var onTryOn: ((CatalogProduct) -> Void)?
    @State private var code = ""
    @State private var resolution: ProductResolution?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Token.Space.card) {
                    Card {
                        Text("Ürün kodunu yaz").font(.headline)
                        Text("Etiketteki ürün kodunu gir. Barkod kamerası destekleyen iPhone'larda Dene ekranında.")
                            .font(.subheadline).foregroundStyle(Token.textSecondary)
                        TextField("ör. KB-TEE-01-WHT", text: $code)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .font(.body.monospaced())
                            .padding(12)
                            .background(Token.surfaceBase, in: RoundedRectangle(cornerRadius: Token.Radius.small))
                            .submitLabel(.search)
                            .onSubmit(resolve)
                            .accessibilityIdentifier("productCodeField")
                        Button("Sonucu göster", action: resolve)
                            .buttonStyle(PrimaryButtonStyle())
                            .accessibilityIdentifier("resolveButton")
                    }

                    Card {
                        HStack { Text("Örnek kodlar").font(.subheadline.weight(.semibold)); Spacer(); SyntheticBadge() }
                        FlowLayout {
                            ForEach(["KB-TEE-01-WHT", "KB-JKT-01", "KB-JNS-02-BLU", "KB-SHR-03-NVY", "KB-SNK-04-WHT", "OB-DRS-01-RED", "KB-XXX-99"], id: \.self) { sample in
                                Button { code = sample; resolve() } label: { Chip(text: sample) }.buttonStyle(.plain)
                            }
                        }
                    }

                    if let resolution { ResolutionView(resolution: resolution, onTryOn: onTryOn) { code = $0.code; resolve() } }
                }
                .padding(.horizontal, Token.Space.gutter)
                .padding(.vertical, Token.Space.card)
            }
            .background(Token.surfaceBase)
            .navigationTitle("Denemeye değer mi?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
            .onAppear {
                if let scannedCode, code.isEmpty { code = scannedCode; resolve() }
            }
        }
    }

    private func resolve() {
        withAnimation(.easeOut(duration: 0.2)) { resolution = model.catalog.resolve(code) }
    }
}

private struct ResolutionView: View {
    @Environment(AppModel.self) private var model
    let resolution: ProductResolution
    let onTryOn: ((CatalogProduct) -> Void)?
    let pick: (CatalogProduct) -> Void

    var body: some View {
        switch resolution {
        case .found(let product):
            DecisionCardView(card: DecisionComposer.compose(product: product, passport: model.passport, measurements: model.measurements, wardrobe: model.wardrobe))
            if let onTryOn {
                Button { onTryOn(product) } label: {
                    Label("Dene'de kullan", systemImage: "camera.viewfinder").frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Atelier.brand)
                .accessibilityIdentifier("scanUseInTryOn")
            }
        case .ambiguous(let options):
            Card {
                Text("Hangisi?").font(.headline)
                Text("Bu kod birden fazla varyanta ait. Doğru olanı seç; tahmin etmiyoruz.").font(.subheadline).foregroundStyle(Token.textSecondary)
                ForEach(options) { p in
                    Button { pick(p) } label: {
                        HStack { Text(verbatim: "\(UntrustedText(p.name)) · \(UntrustedText(p.colorName))"); Spacer(); Text(p.code).font(.caption.monospaced()) }.frame(minHeight: 44)
                    }
                }
            }
            .accessibilityIdentifier("ambiguousCard")
        case .notFound(let code):
            Card {
                StatusBadge(text: "Ürün bulunamadı", tone: .caution)
                Text("\(code) kayıtlı katalogda yok. Benzer bir ürünü bunun yerine göstermiyoruz.").font(.subheadline)
            }
            .accessibilityIdentifier("notFoundCard")
        case .invalidInput:
            Card { StatusBadge(text: "Geçersiz kod. Yalnız harf, rakam ve tire; en fazla 40 karakter.", tone: .error) }
        }
    }
}

struct DecisionCardView: View {
    @Environment(AppModel.self) private var model
    let card: ShoppingDecisionCard
    @State private var showFeedback = false

    var body: some View {
        Card {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.product.brandName).font(.caption).foregroundStyle(Token.textSecondary)
                    Text(verbatim: UntrustedText(card.product.name).displayValue).font(.title3.weight(.semibold))
                    Text("\(card.product.colorName) · \(card.product.code)").font(.caption.monospaced()).foregroundStyle(Token.textSecondary)
                }
                Spacer()
                if let label = card.sponsoredLabel { Chip(text: label).accessibilityIdentifier("sponsoredLabel") }
            }
            if card.isSyntheticData { SyntheticBadge() }

            Divider()
            section("Görünüş", symbol: "eye", headline: card.visualTier.displayName, detail: "Üstünde görünüm için ürüne özel 3D varlık gerekir.", tone: .neutral)
            section("Beden", symbol: "ruler", headline: card.size.headline, detail: card.size.detail, tone: tone(card.size.confidence))
            section("Dolabında var mı?", symbol: "hanger", headline: card.wardrobe.headline,
                    detail: card.wardrobe.pairsWith.isEmpty ? nil : "Eşleşir: " + card.wardrobe.pairsWith.map(\.name).joined(separator: ", "),
                    tone: .neutral)

            if !card.missingInformation.isEmpty {
                Text("Eksik bilgi: " + card.missingInformation.joined(separator: ", "))
                    .font(.caption).foregroundStyle(Token.textSecondary)
            }

            Button("Denedim, nasıl oldu?") { showFeedback = true }
                .frame(maxWidth: .infinity, minHeight: 44)
                .accessibilityIdentifier("fitFeedbackButton")
        }
        .accessibilityIdentifier("decisionCard")
        .sheet(isPresented: $showFeedback) { FitFeedbackView(product: card.product) }
    }

    private func section(_ title: String, symbol: String, headline: String, detail: String?, tone: StatusTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol).font(.caption.weight(.semibold)).foregroundStyle(Token.textSecondary)
            Text(headline).font(.body.weight(.medium)).foregroundStyle(tone == .neutral ? Token.textPrimary : tone.color)
            if let detail { Text(detail).font(.footnote).foregroundStyle(Token.textSecondary) }
        }
        .accessibilityElement(children: .combine)
    }

    private func tone(_ c: ConfidenceKind) -> StatusTone {
        switch c {
        case .abstain: .caution
        case .partial: .caution
        case .heuristic, .verifiedFacts: .ok
        }
    }
}

/// "Nasıl oldu?" (§61.2). Saved only on this device.
struct FitFeedbackView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let product: CatalogProduct
    @State private var size = ""
    @State private var outcome = FitOutcome.fits
    @State private var regions: Set<FitRegion> = []

    var body: some View {
        NavigationStack {
            Form {
                Section { Text(verbatim: UntrustedText(product.name).displayValue) }
                TextField("Denediğin beden (ör. M)", text: $size).textInputAutocapitalization(.characters)
                Picker("Sonuç", selection: $outcome) {
                    ForEach(FitOutcome.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.segmented)
                if outcome == .tight || outcome == .loose {
                    Section("Nerede? (isteğe bağlı)") {
                        ForEach(FitRegion.allCases, id: \.self) { region in
                            Toggle(region.displayName, isOn: Binding(
                                get: { regions.contains(region) },
                                set: { if $0 { regions.insert(region) } else { regions.remove(region) } }
                            ))
                        }
                    }
                }
                Section {
                    Text("Bu kayıt yalnız bu telefonda kalır ve yalnız bu marka ve bu ürün türü için kullanılır. İstediğin zaman silebilirsin.")
                        .font(.footnote).foregroundStyle(Token.textSecondary)
                }
            }
            .navigationTitle("Nasıl oldu?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        model.record(FitObservation(
                            garmentCategory: product.category, brandID: product.brandID, productVariantID: product.code,
                            productModelID: product.modelCode,
                            catalogRevision: product.catalogRevision, markedSize: size.isEmpty ? nil : size.uppercased(),
                            observedOutcome: outcome, affectedRegions: regions
                        ))
                        dismiss()
                    }
                    .disabled(size.isEmpty && outcome != .notTried)
                }
            }
        }
    }
}

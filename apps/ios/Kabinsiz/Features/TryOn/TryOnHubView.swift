import AvatarDressing
import DomainContracts
import LiveMirror
import ShoppingCopilot
import SwiftUI
import VisionKit
import WardrobeDomain

/// What brought a product into Dene, so the card can say where it came from (v2.6 §3, v2.7 ID0–ID2).
enum TryOnSource: Equatable {
    case wardrobe
    case example
    /// A catalogue code resolved exactly (variant chosen by the user when ambiguous).
    case catalog(code: String, synthetic: Bool)

    var label: String {
        switch self {
        case .wardrobe: "Dolabından · senin kaydın"
        case .example: "Örnek parça · sentetik"
        case let .catalog(code, synthetic): synthetic ? "Katalog kodu \(code) · sentetik katalog" : "Katalog kodu \(code) · doğrulandı"
        }
    }
}

/// One product in the try-on session: the piece and where it came from.
struct TryOnSelection: Equatable {
    let item: DressItem
    let source: TryOnSource
}

/// Asks Dene to open an intake (the home's "Dene" and other screens use it).
@Observable
@MainActor
final class TryOnRouter {
    enum Intake: Equatable { case code }
    var pending: Intake?
}

/// "Dene" (v2.6 Tara ve Dene, v2.8 D01–D07, ADR-011): one journey instead of two tabs. Bring a
/// product (live barcode, a photo of its label or barcode read on the device, the code, the wardrobe;
/// link says plainly it is not in this build),
/// see where it came from, then look at it on the 3D model or in the local mirror — same selection,
/// same session. The AI video mode is shown as what it is: off, behind consent, contract and cost.
struct TryOnHubView: View {
    @Environment(AppModel.self) private var model
    @Environment(HomeWorldModel.self) private var world
    @Environment(TryOnRouter.self) private var router
    let onShowOnModel: () -> Void

    @State private var selection: TryOnSelection?
    @State private var showCode = false
    @State private var showScanner = false
    @State private var openMirror = false
    @State private var showHow = false
    @State private var unavailable: String?

    private static let mirrorSlots: Set<GarmentSlotID> = [.top, .outerwear, .bottom, .dress, .footwear]

    /// The user's own pieces first; the example closet only when the wardrobe is empty, and labelled.
    private var pool: (items: [DressItem], isExample: Bool) {
        let own = model.wardrobe.garments.filter { $0.condition.isPlannable }
            .compactMap(GarmentAppearance.dressItem(for:)).filter { Self.mirrorSlots.contains($0.slot) }
        if !own.isEmpty { return (own, false) }
        let example = SyntheticCloset.studio.garments.compactMap(GarmentAppearance.dressItem(for:))
            .filter { Self.mirrorSlots.contains($0.slot) }
        return (example, true)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Atelier.Space.l) {
                VStack(alignment: .leading, spacing: Atelier.Space.xs) {
                    Text("Dene").font(AtelierType.display).accessibilityAddTraits(.isHeader)
                    Text("Ürünü getir; modelinde ya da Canlı Ayna'da gör.").font(AtelierType.body).foregroundStyle(.secondary)
                }
                intake
                wardrobeStrip
                if let selection { productCard(selection) }
                modes
                Button("Nasıl çalışır?") { showHow = true }
                    .font(AtelierType.secondary)
                    .frame(maxWidth: .infinity, minHeight: Atelier.minTap)
                    .accessibilityIdentifier("mirrorHow")
            }
            .padding(Atelier.Space.l)
        }
        .background(Atelier.surface.ignoresSafeArea())
        .navigationTitle("Dene")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selection == nil, let first = pool.items.first(where: { $0.slot == .top }) ?? pool.items.first {
                selection = TryOnSelection(item: first, source: pool.isExample ? .example : .wardrobe)
            }
            consumeRoute()
        }
        .onChange(of: router.pending) { consumeRoute() }
        .sheet(isPresented: $showCode) {
            ScanView(onTryOn: { product in
                showCode = false
                use(product)
            })
        }
        // The code sheet opens only after the scanner has gone, so two sheets never race.
        .sheet(isPresented: $showScanner, onDismiss: { if pendingCode != nil { showCode = true } }) {
            BarcodeScannerSheet { code in
                pendingCode = code
                showScanner = false
            }
        }
        .fullScreenCover(isPresented: $openMirror) {
            if let selection { LocalMirrorView(item: selection.item) }
        }
        .sheet(isPresented: $showHow) { MirrorHowSheet() }
        .alert(unavailable ?? "", isPresented: Binding(get: { unavailable != nil }, set: { if !$0 { unavailable = nil } })) {
            Button("Tamam", role: .cancel) {}
        }
        .environment(\.scannedCode, pendingCode)
    }

    @State private var pendingCode: String?

    private func consumeRoute() {
        guard router.pending == .code else { return }
        router.pending = nil
        showCode = true
    }

    private func use(_ product: CatalogProduct) {
        let garment = Garment(id: product.code, name: product.name, category: product.category, formalityRange: product.formalityRange,
                              colorName: product.colorName, isNeutralColor: product.isNeutralColor, condition: .clean,
                              walkingComfort: nil, provenance: product.provenance)
        guard let item = GarmentAppearance.dressItem(for: garment) else {
            unavailable = "Bu ürün türü için henüz 3B görünüm yok. Karar kartı yine geçerli."
            return
        }
        selection = TryOnSelection(item: item, source: .catalog(code: product.code, synthetic: product.provenance.isSynthetic))
    }

    // MARK: Intake

    private var intake: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            Text("Ürünü getir").font(AtelierType.sectionTitle)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                // Without live scanning (older iPhones, the simulator) the barcode is read from a photo instead.
                intakeTile("Barkod tara", detail: scannerAvailable ? "Kamera ile, canlı" : "Fotoğrafından okunur",
                           symbol: "barcode.viewfinder", id: "tryOnBarcode", enabled: true) {
                    if scannerAvailable { showScanner = true } else { pendingCode = nil; showCode = true }
                }
                intakeTile("Kodu yaz", detail: "Etiketteki ürün kodu", symbol: "keyboard", id: "mirrorScan", enabled: true) { pendingCode = nil; showCode = true }
                intakeTile("Fotoğraftan", detail: "Etiket ya da barkod fotoğrafı", symbol: "camera", id: "tryOnPhoto", enabled: true) {
                    pendingCode = nil; showCode = true
                }
                intakeTile("Bağlantı", detail: "Katalog bağlı değil", symbol: "link", id: "tryOnLink", enabled: false) {
                    unavailable = "Mağaza kataloğu bağlı değil; bağlantıdaki ürünü doğrulayamıyoruz. Benzerini gösterip doğruymuş gibi sunmuyoruz."
                }
            }
        }
    }

    private var scannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }

    private func intakeTile(_ title: String, detail: String, symbol: String, id: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: symbol).font(.title3).foregroundStyle(enabled ? Atelier.copper : .secondary)
                Text(title).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
                Text(detail).font(AtelierType.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
            .padding(12)
            .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
            .opacity(enabled ? 1 : 0.7)
            .contentShape(.rect)
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityIdentifier(id)
        .accessibilityValue(enabled ? "" : "Bu sürümde yok")
    }

    private var wardrobeStrip: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            HStack {
                Text("Dolabımdan").font(AtelierType.cardTitle)
                Spacer()
                if pool.isExample { Text("Örnek · sentetik").font(AtelierType.caption).foregroundStyle(.secondary) }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Atelier.Space.s) {
                    ForEach(pool.items) { item in productTile(item) }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func productTile(_ item: DressItem) -> some View {
        let isOn = selection?.item.id == item.id
        return Button { selection = TryOnSelection(item: item, source: pool.isExample ? .example : .wardrobe) } label: {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(rgb: item.colorHex))
                    .frame(width: 104, height: 84)
                    .overlay { Image(systemName: item.slot.symbol).font(.title2).foregroundStyle(.white.opacity(0.9)).shadow(radius: 2) }
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isOn ? Atelier.brand : .primary.opacity(0.12), lineWidth: isOn ? 3 : 1))
                Text(item.name).font(AtelierType.caption.weight(.medium)).lineLimit(2).frame(width: 104, alignment: .leading)
            }
            .frame(width: 104)
            .contentShape(.rect)
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityIdentifier("mirrorItem-\(item.id)")
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    // MARK: Product and the two views

    private func productCard(_ selection: TryOnSelection) -> some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(rgb: selection.item.colorHex))
                    .frame(width: 56, height: 56)
                    .overlay { Image(systemName: selection.item.slot.symbol).foregroundStyle(.white.opacity(0.9)) }
                VStack(alignment: .leading, spacing: 2) {
                    Text(selection.item.name).font(AtelierType.cardTitle)
                    Text(selection.source.label).font(AtelierType.caption).foregroundStyle(.secondary)
                        .accessibilityIdentifier("tryOnSource")
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Label("Görünüm: tahmini 3B, kategori kalıbından (ürüne özel değil)", systemImage: "cube")
                Label("Beden: görünüşten çıkarılmaz; karar kartındaki kanıta bakar", systemImage: "ruler")
            }
            .font(AtelierType.caption)
            .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                PrimaryAction(title: "3D modelimde", systemImage: "figure.stand", id: "tryOnModel") {
                    world.wear(selection.item)
                    onShowOnModel()
                }
                PrimaryAction(title: "Canlı Ayna", systemImage: "camera.aperture", id: "openMirror") { openMirror = true }
            }
        }
        .padding(Atelier.Space.m)
        .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tryOnProductCard")
    }

    private var modes: some View {
        VStack(spacing: 0) {
            modeRow(title: "Yerel Ayna", detail: "Görüntü yalnız bu cihazda işlenir, kaydedilmez.", on: true, enabled: true)
            Divider().padding(.leading, 44)
            modeRow(title: "Yapay zekâ video önizleme", detail: "Bu sürümde kapalı. Açık izin, sağlayıcı sözleşmesi ve ücret sınırı gerekir.",
                    on: false, enabled: false)
        }
        .padding(.vertical, 4)
        .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("mirrorModes")
    }

    private func modeRow(title: String, detail: String, on: Bool, enabled: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: on ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(on ? Atelier.brand : .secondary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(AtelierType.cardTitle)
                Text(detail).font(AtelierType.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .opacity(enabled ? 1 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(on ? .isSelected : [])
        .accessibilityValue(enabled ? "" : "Kapalı")
    }
}

extension EnvironmentValues {
    /// A code read by the barcode scanner, handed to the code sheet to resolve.
    @Entry var scannedCode: String?
}

/// VisionKit live barcode reading. Shown only where `DataScannerViewController` is supported and
/// allowed; frames stay on the device. The first code read is handed back; nothing is stored.
struct BarcodeScannerSheet: View {
    let onCode: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScannerRepresentable(onCode: onCode)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Barkod tara")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
        }
    }
}

private struct ScannerRepresentable: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCode: onCode) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(recognizedDataTypes: [.barcode()], qualityLevel: .balanced,
                                                recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false,
                                                isHighlightingEnabled: true)
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ controller: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ controller: DataScannerViewController, coordinator: Coordinator) {
        controller.stopScanning()
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCode: (String) -> Void
        private var done = false
        init(onCode: @escaping (String) -> Void) { self.onCode = onCode }

        func dataScanner(_ scanner: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !done else { return }
            for case let .barcode(code) in items {
                guard let value = code.payloadStringValue, !value.isEmpty else { continue }
                done = true
                scanner.stopScanning()
                onCode(value)
                return
            }
        }
    }
}

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
    /// The catalogue record when the product came from a code; nil for wardrobe and example pieces.
    var product: CatalogProduct? = nil
    /// The barcode number when the product was read from one.
    var gtin: String? = nil
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
    @State private var showDetail = false
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
                scannerHero
                intake
                if let selection { productCard(selection) }
                wardrobeStrip
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
        .toolbar { ToolbarItem(placement: .topBarTrailing) { ProfileButton() } }
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
            if let selection {
                LocalMirrorView(item: selection.item, choices: pool.items,
                                productLine: selection.product.map { "\($0.brandName) · \($0.name)" })
            }
        }
        .sheet(isPresented: $showDetail) {
            if let selection {
                NavigationStack {
                    ProductDetailView(selection: selection,
                                      onTry: { showDetail = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { openMirror = true } },
                                      onModel: { showDetail = false; world.wear(selection.item); onShowOnModel() })
                }
            }
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
        selection = TryOnSelection(item: item, source: .catalog(code: product.code, synthetic: product.provenance.isSynthetic), product: product)
    }

    // MARK: Intake

    /// "Tara ve Dene" window (v3.2 S10): the scanner is the first thing on the screen.
    private var scannerHero: some View {
        Button { startBarcode() } label: {
            ZStack {
                LinearGradient(colors: [Color(red: 0.36, green: 0.25, blue: 0.18), Color(red: 0.20, green: 0.14, blue: 0.11)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                RadialGradient(colors: [.white.opacity(0.10), .clear], center: .center, startRadius: 4, endRadius: 200)
                ScanCorners().stroke(.white.opacity(0.92), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .padding(EdgeInsets(top: 64, leading: 54, bottom: 64, trailing: 54))
                VStack(spacing: 10) {
                    Image(systemName: "barcode").font(.system(size: 64, weight: .light)).foregroundStyle(.white.opacity(0.92))
                    Text(scannerAvailable ? "Barkodu çerçeveye getir" : "Barkodun ya da etiketin fotoğrafını çek")
                        .font(.subheadline.weight(.medium)).foregroundStyle(.white.opacity(0.9))
                }
                VStack {
                    HStack {
                        Text("Tara ve Dene").font(.system(.title2, design: .serif, weight: .semibold)).foregroundStyle(.white)
                        Spacer()
                        Label("Cihazda okunur", systemImage: "lock.fill").font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(18)
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityLabel(scannerAvailable ? "Barkod tara" : "Barkod ya da etiket fotoğrafı")
        .accessibilityIdentifier("scanHero")
    }

    private func startBarcode() {
        if scannerAvailable { showScanner = true } else { pendingCode = nil; showCode = true }
    }

    /// The ways in, as one row of chips (barcode, photo, code, link).
    private var intake: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Without live scanning (older iPhones, the simulator) the barcode is read from a photo instead.
                intakeTile("Barkod", detail: scannerAvailable ? "Kamera ile, canlı" : "Fotoğrafından okunur",
                           symbol: "barcode.viewfinder", id: "tryOnBarcode", enabled: true) { startBarcode() }
                intakeTile("Fotoğraf", detail: "Etiket ya da barkod fotoğrafı", symbol: "camera", id: "tryOnPhoto", enabled: true) {
                    pendingCode = nil; showCode = true
                }
                intakeTile("Kod", detail: "Etiketteki ürün kodu", symbol: "keyboard", id: "mirrorScan", enabled: true) { pendingCode = nil; showCode = true }
                intakeTile("Bağlantı", detail: "Katalog bağlı değil", symbol: "link", id: "tryOnLink", enabled: false) {
                    unavailable = "Mağaza kataloğu bağlı değil; bağlantıdaki ürünü doğrulayamıyoruz. Benzerini gösterip doğruymuş gibi sunmuyoruz."
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var scannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }

    private func intakeTile(_ title: String, detail: String, symbol: String, id: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(enabled ? Atelier.ink : .secondary)
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .background(Color.white.opacity(enabled ? 0.9 : 0.5), in: Capsule())
                .overlay(Capsule().stroke(Atelier.ink.opacity(0.08)))
                .contentShape(.capsule)
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityIdentifier(id)
        .accessibilityHint(detail)
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
                GarmentThumb(item: item)
                    .frame(width: 104, height: 112)
                    .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
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

    /// The chosen product (visual reference 5): picture, brand, name, one primary action.
    private func productCard(_ selection: TryOnSelection) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Button { showDetail = true } label: {
                HStack(spacing: 14) {
                    GarmentThumb(item: selection.item, padding: 6)
                        .frame(width: 86, height: 96)
                        .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(selection.product?.brandName ?? (selection.source == .wardrobe ? "Dolabından" : "Örnek parça"))
                            .font(.headline.weight(.bold)).foregroundStyle(Atelier.ink)
                        Text(selection.item.name).font(.subheadline).foregroundStyle(Atelier.ink.opacity(0.8))
                        Text(selection.source.label).font(.caption).foregroundStyle(.secondary)
                            .accessibilityIdentifier("tryOnSource")
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Ürün detayını aç")
            .accessibilityIdentifier("tryOnDetail")
            Button { openMirror = true } label: {
                Label("Üzerimde Dene", systemImage: "sparkles").font(.headline).frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(CopperCapsuleStyle())
            .accessibilityIdentifier("openMirror")
            Button {
                world.wear(selection.item)
                onShowOnModel()
            } label: {
                Label("3D modelimde gör", systemImage: "figure.stand").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain).foregroundStyle(Atelier.brand)
            .accessibilityIdentifier("tryOnModel")
            Text("Görünüm temsilîdir; beden uyumunu göstermez.").font(.caption2).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
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

/// Four rounded corner brackets of a scan window.
struct ScanCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let l = min(rect.width, rect.height) * 0.16, r: CGFloat = 14
        for (corner, dx, dy) in [(CGPoint(x: rect.minX, y: rect.minY), 1.0, 1.0), (CGPoint(x: rect.maxX, y: rect.minY), -1.0, 1.0),
                                 (CGPoint(x: rect.minX, y: rect.maxY), 1.0, -1.0), (CGPoint(x: rect.maxX, y: rect.maxY), -1.0, -1.0)] {
            p.move(to: CGPoint(x: corner.x, y: corner.y + dy * l))
            p.addLine(to: CGPoint(x: corner.x, y: corner.y + dy * r))
            p.addQuadCurve(to: CGPoint(x: corner.x + dx * r, y: corner.y), control: corner)
            p.addLine(to: CGPoint(x: corner.x + dx * l, y: corner.y))
        }
        return p
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

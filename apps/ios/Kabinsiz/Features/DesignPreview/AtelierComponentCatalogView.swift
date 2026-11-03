#if DEBUG
import SwiftUI

/// UI20-WP03 component catalogue: all twenty v2.0 §09 atoms with SYNTHETIC_DEMO_ONLY sample values.
/// DEBUG builds only, opened with the `-componentCatalog` launch argument. Every section carries a
/// `catalog-K-0nn` identifier so the UI test can prove all twenty render.
struct AtelierComponentCatalogView: View {
    @State private var waist = 82.0
    @State private var angle: ViewAngle = .front
    @State private var sheetOpen = false
    @State private var loading = false

    private let sampleDate = Date(timeIntervalSince1970: 1_793_696_400)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Atelier.Space.xxl) {
                VStack(alignment: .leading, spacing: Atelier.Space.xs) {
                    EditorialHeading(eyebrow: "Tasarım sistemi", title: "Quiet Atelier", subtitle: "v2.0 bileşen kataloğu · K-001…K-020", level: .display)
                    SyntheticBadge()
                }

                entry("K-001", "AtelierWordmark") { AtelierWordmark() }
                entry("K-002", "PrimaryAction") {
                    PrimaryAction(title: "Kombini gör", id: "catalogPrimary") {}
                    PrimaryAction(title: "Hazırlanıyor", isLoading: true, id: "catalogPrimaryLoading") {}
                    PrimaryAction(title: "Devre dışı", isEnabled: false, id: "catalogPrimaryDisabled") {}
                }
                entry("K-003", "SecondaryAction") { SecondaryAction(title: "Nasıl çalışır?", systemImage: "questionmark.circle", id: "catalogSecondary") {} }
                entry("K-004", "EditorialHeading") {
                    EditorialHeading(eyebrow: "Bugün için", title: "Sakin ama karakterli", subtitle: "Türkçe harfler: İ ı ğ ş ç ö ü", level: .screen)
                }
                entry("K-005", "FashionPhotoCard") {
                    FashionPhotoCard(fallbackSymbol: "tshirt", title: "Keten gömlek", subtitle: "Görsel yok: lisanslı fotoğraf olmadan siluet")
                        .frame(maxWidth: 200)
                }
                entry("K-006", "TodayHero") {
                    TodayHero(eyebrow: "Bugün senin için",
                              content: .outfit(title: "Sakin ama karakterli", reason: "Örnek dolaptan 3 parça · sentetik", itemSymbols: ["tshirt", "hanger", "shoe"]),
                              action: PrimaryAction(title: "Kombini gör", id: "catalogHero") {})
                }
                entry("K-007", "ContextChip") { ContextChip(symbol: "cloud.sun", text: "Parçalı bulutlu", source: "Örnek kaynak", observedAt: sampleDate) }
                entry("K-008", "TrustBadge") {
                    FlowLayout { ForEach(TrustLevel.allCases, id: \.self) { TrustBadge(level: $0) } }
                }
                entry("K-009", "ProductFactRow") {
                    ProductFactRow(label: "Kumaş bileşimi", value: "Pamuk 98, elastan 2", source: "Örnek veri", trust: .synthetic)
                    ProductFactRow(label: "İç dikiş boyu", value: nil, trust: .verified, addAction: {})
                }
                entry("K-010", "FitZoneRow") {
                    FitZoneRow(region: "Bel", verdict: .comfortable, reason: "Ürün ölçüsü ile ölçün arasında rahat pay var (örnek).")
                    FitZoneRow(region: "Kalça", verdict: .abstain, reason: "Ürün kalça ölçüsü bilinmiyor; karar vermiyoruz.")
                }
                entry("K-011", "BodySlider") { BodySlider(title: "Bel", value: $waist, range: 60...120, unit: "cm", id: "catalogWaist") }
                entry("K-012", "PreviewViewport") {
                    PreviewViewport(angle: $angle, allows3D: false, fidelityLabel: "Basit siluet. Görünüm, beden uyumunun kanıtı değildir.") { EmptyView() }
                }
                entry("K-013", "WardrobeTile") {
                    HStack(spacing: Atelier.Space.s) {
                        WardrobeTile(symbol: "tshirt", name: "Beyaz tişört", state: .clean, isSynthetic: true)
                        WardrobeTile(symbol: "shoe", name: "Deri ayakkabı", state: .unknown, isSynthetic: true)
                    }
                }
                entry("K-014", "OutfitReasonChip") {
                    FlowLayout {
                        OutfitReasonChip(kind: .color, text: "Toprak tonları")
                        OutfitReasonChip(kind: .layer, text: "İki katman")
                        OutfitReasonChip(kind: .occasion, text: "Ofis")
                    }
                }
                entry("K-015", "PartnerProductTile") {
                    PartnerProductTile(name: "Örnek yün ceket", brand: "Örnek marka", priceText: nil, source: "Sentetik katalog", isSponsored: true)
                }
                entry("K-016", "StatePanel") {
                    StatePanel(kind: .empty, title: "Ürün bulunamadı", message: "Bu ürünün katalog bilgisine şu anda ulaşamadık.",
                               reassurance: "Gizli beden verilerin mağazaya gönderilmedi.",
                               actions: [.init(title: "Kodu elle yaz", id: "catalogStateAction", run: {})])
                }
                entry("K-017", "NativeTabScaffold") {
                    HStack {
                        ForEach(AtelierTab.allCases) { t in
                            Label(t.title, systemImage: t.symbol).font(AtelierType.caption).frame(maxWidth: .infinity)
                        }
                    }
                    Text("Üç sekme; Tara sekme değil, her sekmede araç çubuğu eylemi.").font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary)
                }
                entry("K-018", "AtelierSheet") {
                    SecondaryAction(title: "Örnek sayfayı aç", id: "catalogOpenSheet") { sheetOpen = true }
                        .atelierSheet(isPresented: $sheetOpen, title: "Neden bu kombin?") {
                            Text("Örnek açıklama · sentetik").font(AtelierType.body).foregroundStyle(Atelier.ink)
                        }
                }
                entry("K-019", "ShimmerlessSkeleton") { ShimmerlessSkeleton() }
                entry("K-020", "SourceDisclosure") {
                    SourceDisclosure(source: SourceInfo(name: "Sentetik katalog", observedAt: sampleDate, rights: "Örnek; gerçek hak yok", trust: .synthetic))
                }
            }
            .padding(.horizontal, Atelier.Space.gutter)
            .padding(.vertical, Atelier.Space.m)
        }
        .background(Atelier.canvas)
        .navigationTitle("Bileşenler")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("componentCatalog")
    }

    private func entry<Content: View>(_ id: String, _ name: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(id).font(AtelierType.caption.monospacedDigit()).foregroundStyle(Atelier.copper)
                Text(name).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("catalog-\(id)")
            content()
            Divider().overlay(Atelier.borderSoft)
        }
    }
}
#endif

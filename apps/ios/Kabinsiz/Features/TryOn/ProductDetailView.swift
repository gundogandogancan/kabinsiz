import AvatarDressing
import DomainContracts
import FitPassport
import ProductCapture
import ShoppingCopilot
import SwiftUI

/// v3.2 S11/S12 product detail: one big picture, brand and name, then each fact with its own source.
/// Size and fabric are shown only from the catalogue that holds them, with that catalogue's label; a
/// picture never becomes a size or fibre claim (V32-FIT-01/02). No price or shop link is invented: the
/// licensed catalogue is not connected, so the screen says so and offers the user's own web search.
struct ProductDetailView: View {
    let selection: TryOnSelection
    let onTry: () -> Void
    let onModel: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var product: CatalogProduct? { selection.product }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero
                header
                actions
                if let chart = product?.sizeChart { sizeSection(chart) }
                materialSection
                identitySection
                storeSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Atelier.surface.ignoresSafeArea())
        .navigationTitle("Ürün Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
        .accessibilityIdentifier("productDetail")
    }

    private var hero: some View {
        ZStack(alignment: .bottom) {
            RadialGradient(colors: [Color.white, Atelier.surface], center: .center, startRadius: 10, endRadius: 260)
            GarmentThumb(item: selection.item, padding: 28)
                .frame(height: 340)
            Text("Temsilî çizim · kategori kalıbından, ürüne özel değil")
                .font(.caption2).foregroundStyle(.secondary)
                .padding(.bottom, 8)
                .accessibilityIdentifier("productHeroLabel")
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product?.brandName ?? "Dolabından").font(.title2.weight(.bold))
            Text(selection.item.name).font(.title3).foregroundStyle(Atelier.ink.opacity(0.8))
            HStack(spacing: 8) {
                Circle().fill(Color(rgb: selection.item.colorHex)).frame(width: 14, height: 14)
                    .overlay(Circle().stroke(.primary.opacity(0.15)))
                Text(selection.item.colorName.capitalized(with: Locale(identifier: "tr_TR"))).font(.subheadline)
                if product?.provenance.isSynthetic ?? (selection.source == .example) {
                    Label("Örnek veri — gerçek değil", systemImage: "flask").font(.caption.weight(.medium))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Atelier.surfaceSecondary, in: Capsule())
                }
            }
            Text(product == nil ? "Fiyat yok: bu senin kaydın." : "Fiyat gösterilmiyor: mağaza kataloğu bağlı değil.")
                .font(.footnote).foregroundStyle(.secondary)
                .accessibilityIdentifier("productPrice")
        }
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button(action: onTry) {
                Label("Üzerimde Dene", systemImage: "sparkles").font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(CopperCapsuleStyle())
            .accessibilityIdentifier("productTryOn")
            Button(action: onModel) {
                Label("Modelimde 360° gör", systemImage: "rotate.3d").font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 46)
            }
            .buttonStyle(.bordered).tint(Atelier.brand)
            .accessibilityIdentifier("productOnModel")
        }
    }

    private func sizeSection(_ chart: SizeChart) -> some View {
        section("Beden tablosu", source: product?.provenance.isSynthetic == true ? "Kaynak: örnek katalog (gerçek değil)" : "Kaynak: marka kataloğu") {
            VStack(spacing: 0) {
                HStack {
                    Text("Beden").frame(width: 70, alignment: .leading)
                    Text("Göğüs (cm)").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Bel (cm)").frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.caption.weight(.semibold)).foregroundStyle(.secondary).padding(.vertical, 8)
                ForEach(chart.rows, id: \.size) { row in
                    Divider()
                    HStack {
                        Text(row.size).font(.body.weight(.semibold)).frame(width: 70, alignment: .leading)
                        Text(range(row.chestCm)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(range(row.waistCm)).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.subheadline.monospacedDigit()).padding(.vertical, 9)
                }
            }
            Text("Bu tablo vücut ölçüsüdür; giysinin bitmiş ölçüsü değildir. Bedenini Beden Pasaportu'ndaki ölçülerinle karşılaştırırız, görüntüden tahmin etmeyiz.")
                .font(.caption).foregroundStyle(.secondary).padding(.top, 6)
        }
        .accessibilityIdentifier("productSizeChart")
    }

    private var materialSection: some View {
        section("Kumaş ve özellikler", source: nil) {
            if let claims = product?.materialClaims, !claims.isEmpty {
                ForEach(claims, id: \.property) { claim in
                    HStack {
                        Image(systemName: symbol(claim.property)).foregroundStyle(Atelier.copper).frame(width: 26)
                        Text(title(claim.property)).font(.subheadline)
                        Spacer()
                        Text(claim.source.isSynthetic ? "örnek veri" : "katalog").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            Text("Elyaf oranı ve bakım talimatı katalogda yok; fotoğraftan ya da renkten çıkarmıyoruz.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("productMaterials")
    }

    private var identitySection: some View {
        section("Ürün kimliği", source: nil) {
            row("Kaynak", selection.source.label)
            if let product {
                row("Ürün kodu", product.code)
                row("Model", product.modelCode)
                row("Katalog sürümü", "\(product.catalogRevision)")
            }
            if let gtin = selection.gtin {
                row("Barkod", gtin)
                Text(GS1Prefix.note(forGTIN: gtin)).font(.caption).foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("productIdentity")
    }

    private var storeSection: some View {
        section("Mağaza", source: nil) {
            Button {} label: {
                Label("Mağazada Gör", systemImage: "bag").frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.bordered)
            .disabled(true)
            .accessibilityHint("Mağaza bağlantısı yok")
            Text("Markanın sitesini kendimiz okumuyoruz: lisanslı mağaza kataloğu bağlanınca fiyat, stok ve bağlantı buraya gelir.")
                .font(.caption).foregroundStyle(.secondary)
            if let code = selection.gtin ?? product?.code, let url = BrandSourceGate.userSearchURL(forCode: code) {
                Button { openURL(url) } label: {
                    Label("Kodu web'de ara", systemImage: "safari").frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered).tint(Atelier.brand)
                .accessibilityIdentifier("productWebSearch")
                Text("Safari'de açılır; aramaya yalnız bu kod gider. Kabinsiz o sayfayı okumaz.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Helpers

    private func section<Content: View>(_ title: String, source: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(AtelierType.cardTitle)
                Spacer()
                if let source { Text(source).font(.caption2).foregroundStyle(.secondary) }
            }
            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.monospaced()).multilineTextAlignment(.trailing)
        }
    }

    private func range(_ r: ClosedRange<Double>?) -> String {
        guard let r else { return "—" }
        return "\(Int(r.lowerBound))–\(Int(r.upperBound))"
    }

    private func title(_ p: MaterialClaim.Property) -> String {
        switch p {
        case .waterResistant: "Suya dayanıklı"
        case .warm: "Sıcak tutar"
        case .breathable: "Nefes alır"
        case .stretch: "Esner"
        }
    }

    private func symbol(_ p: MaterialClaim.Property) -> String {
        switch p {
        case .waterResistant: "drop"
        case .warm: "flame"
        case .breathable: "wind"
        case .stretch: "arrow.left.and.right"
        }
    }
}

/// The copper primary capsule from the visual reference: one per screen.
struct CopperCapsuleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                LinearGradient(colors: [Color(red: 0.62, green: 0.40, blue: 0.24), Color(red: 0.45, green: 0.27, blue: 0.15)],
                               startPoint: .top, endPoint: .bottom),
                in: Capsule())
            .shadow(color: Color(red: 0.45, green: 0.27, blue: 0.15).opacity(0.35), radius: 10, y: 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

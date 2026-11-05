import AvatarDressing
import DomainContracts
import SwiftUI

/// Dolabım (v3.2 S05, visual reference 4): an ivory room with a clean grid of the user's pieces,
/// small category chips and one "+". Pictures are the representative garment drawings tinted to the
/// recorded colour; no photo is read and nothing is shown as owned unless the user added it.
struct WardrobeView: View {
    @Environment(AppModel.self) private var model
    @State private var showAdd = false
    @State private var filter: GarmentCategory?

    private static let chips: [GarmentCategory?] = [nil, .top, .bottom, .outerwear, .shoes, .accessory]
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var shown: [Garment] {
        let all = GarmentCategory.allCases.flatMap { model.wardrobe.garments(in: $0) }
        guard let filter else { return all }
        return all.filter { $0.category == filter || (filter == .outerwear && $0.category == .weatherProtection) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    Text("Dolabım").font(.system(size: 34, weight: .regular, design: .serif)).accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button { showAdd = true } label: {
                        Image(systemName: "plus").font(.title3.weight(.semibold)).foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(Color(red: 0.45, green: 0.27, blue: 0.15), in: Circle())
                            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    }
                    .accessibilityLabel("Kıyafet ekle")
                    .accessibilityIdentifier("addGarment")
                    ProfileButton()
                }
                if model.wardrobe.isEmpty {
                    VStack(spacing: 14) {
                        EmptyState(symbol: "hanger", title: "Dolabın boş", message: "Kıyafetlerini elle ekle ya da örnek dolapla dene. Fotoğraf izni gerekmez.")
                        Button("Örnek dolabı yükle (sentetik)") { model.loadSyntheticCloset() }
                            .buttonStyle(.bordered).tint(Atelier.brand)
                            .accessibilityIdentifier("loadSyntheticCloset")
                    }
                    .padding(.top, 40)
                } else {
                    chipRow
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(shown) { garment in GarmentCard(garment: garment) }
                    }
                    if shown.contains(where: { $0.provenance.isSynthetic }) {
                        Label("Örnek dolap · sentetik veri", systemImage: "flask").font(.caption).foregroundStyle(.secondary)
                    }
                    Text("Görseller temsilî çizimdir; rengini senin yazdığın renkten alır.")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Atelier.surface.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAdd) { AddGarmentView() }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.chips, id: \.self) { chip in
                    let on = filter == chip
                    Button { filter = chip } label: {
                        Text(chip?.displayName ?? "Tümü")
                            .font(.subheadline.weight(on ? .semibold : .regular))
                            .foregroundStyle(on ? .white : Atelier.ink)
                            .padding(.horizontal, 16).frame(minHeight: 38)
                            .background(on ? AnyShapeStyle(Color(red: 0.55, green: 0.36, blue: 0.22)) : AnyShapeStyle(Color.white.opacity(0.75)), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                    .accessibilityIdentifier("wardrobeChip-\(chip?.rawValue ?? "all")")
                }
            }
        }
    }
}

/// One wardrobe piece: picture on a soft card, name, and its state in a menu (clean, worn, …).
struct GarmentCard: View {
    @Environment(AppModel.self) private var model
    let garment: Garment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.75))
                if let item = GarmentAppearance.dressItem(for: garment) {
                    GarmentThumb(item: item, padding: 10)
                } else {
                    Image(systemName: "hanger").font(.title).foregroundStyle(.secondary)
                }
            }
            .aspectRatio(0.86, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                if garment.condition != .clean {
                    Text(garment.condition.displayName).font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.thinMaterial, in: Capsule()).padding(6)
                }
            }
            Text(garment.name).font(.caption.weight(.medium)).lineLimit(2).foregroundStyle(Atelier.ink)
        }
        .contentShape(.rect)
        .contextMenu {
            ForEach(ItemCondition.allCases, id: \.self) { c in
                Button(c.displayName) { model.setCondition(c, garmentID: garment.id) }
            }
            Button("Sil", role: .destructive) { model.removeGarment(id: garment.id) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(garment.name), \(garment.colorName), \(garment.condition.displayName)\(garment.provenance.isSynthetic ? ", örnek veri" : "")")
        .accessibilityIdentifier("garment-\(garment.id)")
    }
}

struct GarmentRow: View {
    @Environment(AppModel.self) private var model
    let garment: Garment

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol(for: garment.category))
                .frame(width: 44, height: 44)
                .background(Token.surfaceBase, in: RoundedRectangle(cornerRadius: Token.Radius.small))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(garment.name).font(.body)
                Text("\(garment.colorName) · \(garment.formalityRange.lowerBound.displayName)–\(garment.formalityRange.upperBound.displayName)")
                    .font(.caption).foregroundStyle(Token.textSecondary)
                if garment.provenance.isSynthetic { Text("Örnek veri").font(.caption2).foregroundStyle(Token.statusCaution) }
            }
            Spacer()
            Menu {
                ForEach(ItemCondition.allCases, id: \.self) { c in
                    Button(c.displayName) { model.setCondition(c, garmentID: garment.id) }
                }
            } label: {
                Text(garment.condition.displayName).font(.caption).frame(minHeight: 44)
            }
            .accessibilityLabel("Durum: \(garment.condition.displayName). Değiştir")
        }
    }

    private func symbol(for category: GarmentCategory) -> String {
        switch category {
        case .top: "tshirt"
        case .shoes: "shoe"
        case .outerwear, .weatherProtection: "cloud.rain"
        case .accessory: "eyeglasses"
        default: "hanger"
        }
    }
}

struct AddGarmentView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category = GarmentCategory.top
    @State private var color = ""
    @State private var low = Formality.casual
    @State private var high = Formality.smart
    @State private var walking: Int = 0
    @State private var weight = ""
    @State private var waterResistantLabel = false
    @State private var showPhoto = false

    var body: some View {
        NavigationStack {
            Form {
                // V37: the simplest way in is the photo; the form below stays for adding by hand.
                Section {
                    Button { showPhoto = true } label: {
                        Label("Fotoğraftan 3B giysi", systemImage: "camera.viewfinder")
                            .fontWeight(.semibold)
                    }
                    .accessibilityIdentifier("photoGarmentOpen")
                } footer: {
                    Text("Giysi kendi kalıbından dikilir; önündeki desen fotoğraftan gelir. Ya da aşağıdan elle ekle.")
                }
                TextField("Adı (ör. Lacivert ceket)", text: $name)
                Picker("Tür", selection: $category) {
                    ForEach(GarmentCategory.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                TextField("Renk", text: $color)
                Picker("En sade kullanım", selection: $low) { ForEach(Formality.allCases, id: \.self) { Text($0.displayName).tag($0) } }
                Picker("En şık kullanım", selection: $high) { ForEach(Formality.allCases, id: \.self) { Text($0.displayName).tag($0) } }
                if category == .shoes {
                    Picker("Uzun yürüyüşe rahat mı?", selection: $walking) {
                        Text("Bilmiyorum").tag(0); Text("Evet").tag(1); Text("Hayır").tag(2)
                    }
                }
                if category == .outerwear || category == .weatherProtection {
                    Toggle("Etiketinde suya dayanıklı yazıyor", isOn: $waterResistantLabel)
                }
                Section {
                    TextField("Ağırlık (kg, tarttıysan)", text: $weight).keyboardType(.decimalPad)
                } footer: {
                    Text("Bilmiyorsan boş bırak. Ağırlığı tahmin etmiyoruz.")
                }
            }
            .navigationTitle("Kıyafet ekle")
            .sheet(isPresented: $showPhoto) { PhotoGarmentFlowView(onAdded: { dismiss() }) }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let range = min(low, high) ... max(low, high)
        let neutral = ["siyah", "beyaz", "gri", "lacivert", "bej", "krem", "haki"].contains(color.lowercased())
        model.upsert(Garment(
            id: "usr-\(UUID().uuidString)", name: name, category: category, formalityRange: range,
            colorName: color.isEmpty ? "belirtilmedi" : color.lowercased(), isNeutralColor: neutral, condition: .unknown,
            materialClaims: waterResistantLabel ? [MaterialClaim(property: .waterResistant, source: .userEntered)] : [],
            walkingComfort: walking == 0 ? nil : walking == 1,
            weightKg: Double(weight.replacingOccurrences(of: ",", with: ".")),
            provenance: .userEntered
        ))
        dismiss()
    }
}

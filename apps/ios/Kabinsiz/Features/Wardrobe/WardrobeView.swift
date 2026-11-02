import DomainContracts
import SwiftUI

struct WardrobeView: View {
    @Environment(AppModel.self) private var model
    @State private var showAdd = false

    var body: some View {
        List {
            if model.wardrobe.isEmpty {
                Section {
                    EmptyState(symbol: "hanger", title: "Dolabın boş", message: "Kıyafetlerini elle ekle veya örnek dolapla dene. Fotoğraf izni gerekmez.")
                    Button("Örnek dolabı yükle (sentetik)") { model.loadSyntheticCloset() }
                        .accessibilityIdentifier("loadSyntheticCloset")
                }
            }
            ForEach(GarmentCategory.allCases, id: \.self) { category in
                let items = model.wardrobe.garments(in: category)
                if !items.isEmpty {
                    Section(category.displayName) {
                        ForEach(items) { garment in
                            GarmentRow(garment: garment)
                                .accessibilityIdentifier("garment-\(garment.id)")
                                .swipeActions {
                                    Button("Sil", role: .destructive) { model.removeGarment(id: garment.id) }
                                }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Token.surfaceBase)
        .navigationTitle("Dolabım")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showAdd = true } label: { Label("Ekle", systemImage: "plus") }
                    .accessibilityIdentifier("addGarment")
            }
        }
        .sheet(isPresented: $showAdd) { AddGarmentView() }
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

    var body: some View {
        NavigationStack {
            Form {
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

import DomainContracts
import SwiftUI
import TravelEngine

/// TRV-08: grouped, deduplicated checklist. Only the user ticks "packed".
struct SuitcaseView: View {
    @Environment(AppModel.self) private var model
    let tripID: String
    @State private var newItem = ""
    @State private var weighing: PackingListItem?
    @State private var weightText = ""

    var body: some View {
        List {
            if let list = model.packingLists[tripID], let trip = model.trip(id: tripID) {
                Section {
                    Text("\(list.packedCount)/\(list.items.count) hazır").font(.headline)
                    weightRow(list, trip)
                }
                ForEach(list.grouped, id: \.0) { category, items in
                    Section(category.displayName) {
                        ForEach(items) { item in
                            row(item, unplanned: list.isUnplannedButPacked(item))
                                .swipeActions(edge: .leading) {
                                    Button("Ağırlık") {
                                        weightText = item.weightKg.map { String(format: "%.2f", $0) } ?? ""
                                        weighing = item
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
                Section("Ekle") {
                    HStack {
                        TextField("ör. Şarj aleti", text: $newItem)
                        Button("Ekle") {
                            model.addManualItem(title: newItem, tripID: tripID)
                            newItem = ""
                        }
                        .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .navigationTitle("Akıllı valiz")
        .accessibilityIdentifier("suitcaseList")
        .alert("Ağırlık (kg)", isPresented: Binding(get: { weighing != nil }, set: { if !$0 { weighing = nil } })) {
            TextField("ör. 0,45", text: $weightText).keyboardType(.decimalPad)
            Button("Kaydet") {
                if let item = weighing {
                    let kg = Double(weightText.replacingOccurrences(of: ",", with: "."))
                    model.setWeight(kg, itemID: item.id, tripID: tripID)
                }
                weighing = nil
            }
            Button("Vazgeç", role: .cancel) { weighing = nil }
        } message: {
            Text("Sadece kendi tarttığın değeri gir. Boş bırakırsan bilinmiyor sayılır.")
        }
    }

    @ViewBuilder
    private func weightRow(_ list: PackingList, _ trip: Trip) -> some View {
        if let total = list.knownTotalWeightKg {
            Text(String(format: "Toplam: %.1f kg", total))
            if list.exceedsLimit(trip.policy.maxWeightKg) == true {
                StatusBadge(text: "Girdiğin sınırı aşıyor", tone: .error)
            }
        } else {
            StatusBadge(text: "Çantanın gerçek ağırlığı bilinmiyor (\(list.weighedItemCount) parça tartıldı)", tone: .neutral)
        }
    }

    private func row(_ item: PackingListItem, unplanned: Bool) -> some View {
        HStack(spacing: 12) {
            Button {
                model.setPacked(!item.isPacked, itemID: item.id, tripID: tripID)
            } label: {
                Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isPacked ? "Valizde, işareti kaldır" : "Valize koydum")
            .accessibilityIdentifier("pack-\(item.id)")

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).strikethrough(item.isPacked)
                HStack(spacing: 6) {
                    if item.missing { StatusBadge(text: "Dolabında yok", tone: .caution) }
                    if unplanned { StatusBadge(text: "Plan artık kullanmıyor", tone: .neutral) }
                    if let kg = item.weightKg { Text(String(format: "%.2f kg", kg)).font(.caption).foregroundStyle(Token.textSecondary) }
                    if !item.assignedSlotIDs.isEmpty {
                        Text("\(Set(item.assignedSlotIDs.map { String($0.prefix(10)) }).count) gün").font(.caption).foregroundStyle(Token.textSecondary)
                    }
                    Text(item.condition.displayName).font(.caption).foregroundStyle(Token.textSecondary)
                }
            }
            Spacer()
            if item.category == .underlayer || item.source == .userEntered {
                Stepper("\(item.quantity)", value: Binding(get: { item.quantity }, set: { model.setQuantity($0, itemID: item.id, tripID: tripID) }), in: 0...30)
                    .fixedSize()
            }
        }
    }
}

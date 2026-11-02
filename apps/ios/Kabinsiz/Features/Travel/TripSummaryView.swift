import DomainContracts
import SwiftUI
import TravelEngine

/// TRV-06 summary + TRV-07 day cards + entry to TRV-08 suitcase and TRV-13 replan.
struct TripSummaryView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let tripID: String
    @State private var confirmDelete = false

    var body: some View {
        if let trip = model.trip(id: tripID) {
            content(trip)
        } else {
            EmptyState(symbol: "suitcase", title: "Seyahat bulunamadı", message: "Silinmiş olabilir.")
        }
    }

    private func content(_ trip: Trip) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Space.card) {
                if trip.isSyntheticDemo { SyntheticBadge() }
                if let plan = model.plans[tripID] {
                    summaryCard(trip, plan)
                    if let pending = model.pendingReplans[tripID] { ReplanCard(tripID: tripID, diff: pending.diff) }
                    NavigationLink { SuitcaseView(tripID: tripID) } label: {
                        Label("Akıllı valiz", systemImage: "checklist").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("openSuitcase")

                    ForEach(Array(trip.dates.enumerated()), id: \.offset) { index, date in
                        DayCard(tripID: tripID, dayIndex: index, date: date, plan: plan)
                    }
                } else {
                    ProgressView("Planın hazırlanıyor…")
                }

                if trip.isSyntheticDemo {
                    Button {
                        Task { await model.simulateWeatherUpdate(tripID: tripID) }
                    } label: {
                        Label("Örnek hava güncellemesi gönder", systemImage: "cloud.sun.rain").frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityIdentifier("simulateWeather")
                }
                Button("Seyahati sil", role: .destructive) { confirmDelete = true }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("deleteTrip")
            }
            .padding(.horizontal, Token.Space.gutter)
            .padding(.vertical, Token.Space.card)
        }
        .background(Token.surfaceBase)
        .navigationTitle(trip.destination.city)
        .confirmationDialog("Seyahat silinsin mi?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Seyahati ve valiz listesini sil", role: .destructive) {
                model.deleteTrip(id: tripID)
                dismiss()
            }
        } message: {
            Text("Dolabın etkilenmez.")
        }
    }

    private func summaryCard(_ trip: Trip, _ plan: TripPlan) -> some View {
        Card {
            Text(trip.destination.displayName).font(.title2.weight(.semibold))
            // Counts come from the computed plan, never hardcoded (§46.3).
            Text("\(trip.dates.count) gün için \(plan.uniquePieceCount) parçayla \(plan.outfitOptionCount) kombin seçeneği")
                .font(.headline)
                .accessibilityIdentifier("capsuleSummary")
            Text("Önce dolabından önerdik.").font(.subheadline).foregroundStyle(Token.textSecondary)
            if !plan.solution.isFeasible {
                StatusBadge(text: "\(plan.solution.uncoveredSlotIDs.count) bölüm için dolabında uygun parça yok", tone: .error)
            }
            let noWeather = plan.slots.filter { $0.weather.evidence == .noData }.count
            if noWeather == plan.slots.count {
                StatusBadge(text: "Bu tarihler için hava tahmini yok. Plan yalnız etkinliklere göre.", tone: .caution)
            } else if noWeather > 0 {
                StatusBadge(text: "Bazı günler için hava tahmini henüz yok", tone: .caution)
            }
            if plan.weatherProvider == "SYNTHETIC_FIXTURE" {
                Text("Hava: örnek (sentetik) veri, gerçek tahmin değil").font(.caption).foregroundStyle(Token.statusCaution)
            }
        }
    }
}

private struct DayCard: View {
    @Environment(AppModel.self) private var model
    let tripID: String
    let dayIndex: Int
    let date: LocalDate
    let plan: TripPlan

    var body: some View {
        Card {
            HStack {
                Text("\(dayIndex + 1). gün").font(.headline)
                Text(date.description).font(.caption).foregroundStyle(Token.textSecondary)
                Spacer()
                if let slot = plan.slots.first(where: { $0.dayIndex == dayIndex }) {
                    // Re-aged at display time: a saved live forecast turns into "Son bilinen tahmin" (finding 5).
                    let weather = plan.displayWeather(for: slot)
                    StatusBadge(text: weather.chipText, tone: weather.evidence == .liveForecast ? .neutral : .caution)
                        .accessibilityIdentifier("weather-\(dayIndex)")
                }
            }
            if let slot = plan.slots.first(where: { $0.dayIndex == dayIndex }), let source = plan.displayWeather(for: slot).provenanceText {
                Text(source).font(.caption2).foregroundStyle(Token.textSecondary)
            }
            ForEach(plan.slots.filter { $0.dayIndex == dayIndex }) { slot in
                SlotView(tripID: tripID, slot: slot, plan: plan)
            }
        }
        .accessibilityIdentifier("dayCard-\(dayIndex)")
    }
}

private struct SlotView: View {
    @Environment(AppModel.self) private var model
    let tripID: String
    let slot: OutfitSlot
    let plan: TripPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(slot.timeBlock == .evening ? "Akşam" : "Gündüz").font(.subheadline.weight(.semibold))
                Spacer()
                if plan.outfit(for: slot.id) != nil {
                    let locked = plan.lockedSlotIDs.contains(slot.id)
                    Button { model.setLocked(!locked, slotID: slot.id, tripID: tripID) } label: {
                        Label(locked ? "Kilitli" : "Kilitle", systemImage: locked ? "lock.fill" : "lock.open")
                            .font(.caption).frame(minHeight: 44)
                    }
                    .accessibilityIdentifier("lock-\(slot.id)")
                }
            }
            if let outfit = plan.outfit(for: slot.id) {
                Text(outfit.garmentIDs.compactMap { model.wardrobe.garment(id: $0)?.name }.joined(separator: " · "))
                    .font(.body)
                FlowLayout { ForEach(outfit.why, id: \.self) { Chip(text: $0) } }
                ForEach(outfit.gaps, id: \.self) { StatusBadge(text: $0, tone: .caution) }
                let alternatives = (plan.candidates[slot.id] ?? []).filter { $0 != outfit }.prefix(3)
                if !alternatives.isEmpty && !plan.lockedSlotIDs.contains(slot.id) {
                    Menu {
                        ForEach(Array(alternatives)) { alt in
                            Button(alt.garmentIDs.compactMap { model.wardrobe.garment(id: $0)?.name }.joined(separator: " · ")) {
                                model.choose(alt, tripID: tripID)
                            }
                        }
                    } label: {
                        Label("Değiştir", systemImage: "arrow.triangle.2.circlepath").font(.caption).frame(minHeight: 44)
                    }
                }
            } else {
                StatusBadge(text: "Bu bölüm için dolabında uygun kombin yok", tone: .error)
                Text("Eksik: \(slot.formality.displayName) bir kombin. Satın alma önermeden önce dolabına ekleyebilirsin.")
                    .font(.footnote).foregroundStyle(Token.textSecondary)
            }
        }
        .padding(.top, 4)
    }
}

/// TRV-13: a replan proposal, applied only on approval.
private struct ReplanCard: View {
    @Environment(AppModel.self) private var model
    let tripID: String
    let diff: TripPlanDiff

    var body: some View {
        Card {
            Label("Hava değişti", systemImage: "cloud.sun.rain").font(.headline)
            if diff.isEmpty {
                Text("Planında değişiklik gerekmiyor.").font(.subheadline)
            } else {
                Text("\(diff.changes.count) bölümde öneri değişti. Kilitli kombinlerin korunuyor.").font(.subheadline)
                ForEach(diff.changes, id: \.slotID) { change in
                    VStack(alignment: .leading) {
                        Text(change.slotID).font(.caption.monospaced()).foregroundStyle(Token.textSecondary)
                        Text("Çıkan: " + names(change.before.filter { !change.after.contains($0) })).font(.caption)
                        Text("Giren: " + names(change.after.filter { !change.before.contains($0) })).font(.caption)
                    }
                }
                if !diff.packedButNoLongerNeeded.isEmpty {
                    Text("Valizde kalabilir: " + names(diff.packedButNoLongerNeeded)).font(.caption).foregroundStyle(Token.textSecondary)
                }
            }
            HStack {
                Button("Yeni öneriyi uygula") { model.approveReplan(tripID: tripID) }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("approveReplan")
                Button("Şimdilik kalsın") { model.rejectReplan(tripID: tripID) }
                    .frame(minHeight: 44)
            }
        }
        .accessibilityIdentifier("replanCard")
    }

    private func names(_ ids: [String]) -> String {
        let n = ids.compactMap { model.wardrobe.garment(id: $0)?.name }
        return n.isEmpty ? "—" : n.joined(separator: ", ")
    }
}

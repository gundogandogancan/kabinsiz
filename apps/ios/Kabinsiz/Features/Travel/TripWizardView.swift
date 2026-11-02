import DomainContracts
import SwiftUI
import TravelEngine

/// 30-second wizard (§41): where/when → what → bag → plan. No permissions, no account.
struct TripWizardView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var query = ""
    @State private var destination: Destination?
    @State private var manualCity = ""
    @State private var manualCountry = ""
    @State private var startDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var lengthValue = 5
    @State private var countNights = false
    @State private var activitiesByDay: [Int: Set<Activity>] = [:]
    @State private var dressCodeByDay: [Int: String] = [:]
    @State private var policy = PackingPolicy()
    @State private var maxWeight = ""

    var body: some View {
        NavigationStack {
            Form {
                switch step {
                case 0: whereWhen
                case 1: activities
                default: bag
                }
            }
            .navigationTitle(["Nereye gidiyorsun?", "Seyahatin nasıl?", "Valiz ve tercihler"][min(step, 2)])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(step == 0 ? "Vazgeç" : "Geri") { step == 0 ? dismiss() : (step -= 1) } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(step < 2 ? "İleri" : "Planı hazırla") { step < 2 ? (step += 1) : create() }
                        .disabled(!canContinue)
                        .accessibilityIdentifier("wizardNext")
                }
            }
        }
    }

    // MARK: Step 1 — destination and dates (TRV-02)

    private var whereWhen: some View {
        Group {
            Section {
                TextField("Şehir ara", text: $query)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("citySearch")
                let results = CityDirectory.search(query)
                if results.count > 1 {
                    Text("Bu adla birden fazla yer var. Hangisi?").font(.footnote).foregroundStyle(Token.statusCaution)
                }
                ForEach(results, id: \.self) { d in
                    Button { destination = d } label: {
                        HStack {
                            VStack(alignment: .leading) { Text(d.city); Text(d.country).font(.caption).foregroundStyle(Token.textSecondary) }
                            Spacer()
                            if destination == d { Image(systemName: "checkmark").accessibilityLabel("Seçildi") }
                        }
                        .frame(minHeight: 44)
                    }
                    .foregroundStyle(Token.textPrimary)
                }
                if !query.isEmpty && results.isEmpty {
                    Text("Listede yok. Aşağıya elle yazabilirsin.").font(.footnote).foregroundStyle(Token.textSecondary)
                }
            } header: {
                Text("Nereye?")
            } footer: {
                Text("Konum izni istemiyoruz; yalnız gideceğin yer gerekiyor.")
            }

            Section("Elle gir") {
                TextField("Şehir", text: $manualCity)
                TextField("Ülke", text: $manualCountry)
                Button("Bu yeri kullan") { destination = CityDirectory.manual(city: manualCity, country: manualCountry) }
                    .disabled(manualCity.trimmingCharacters(in: .whitespaces).isEmpty)
                if let d = destination, !d.timeZoneVerified {
                    StatusBadge(text: "Saat dilimi doğrulanmadı; telefonunun saat dilimi kullanılıyor", tone: .caution)
                }
            }

            Section {
                DatePicker("Gidiş", selection: $startDate, displayedComponents: .date)
                Picker("Süre türü", selection: $countNights) { Text("Gün").tag(false); Text("Gece").tag(true) }
                    .pickerStyle(.segmented)
                Stepper("\(lengthValue) \(countNights ? "gece" : "gün")", value: $lengthValue, in: 1...(countNights ? 13 : 14))
                switch resolvedDates {
                case .success(let dates):
                    Text("\(dates.count) takvim günü: \(dates.first!.description) – \(dates.last!.description)")
                        .font(.footnote).foregroundStyle(Token.textSecondary)
                case .failure(let error):
                    StatusBadge(text: message(error), tone: .error)
                }
            } header: {
                Text("Ne zaman?")
            } footer: {
                Text("Tarihler gittiğin yerin saat dilimine göre hesaplanır. En fazla 14 gün.")
            }
        }
    }

    // MARK: Step 2 — activities per day (TRV-03)

    private var activities: some View {
        ForEach(Array((try? resolvedDates.get()) ?? []).indices, id: \.self) { index in
            let dates = (try? resolvedDates.get()) ?? []
            Section("\(index + 1). gün · \(dates[index].description)") {
                FlowLayout {
                    ForEach(Activity.allCases, id: \.self) { activity in
                        ToggleChip(text: activity.displayName, isOn: activitiesByDay[index, default: []].contains(activity)) {
                            var set = activitiesByDay[index, default: []]
                            if set.contains(activity) { set.remove(activity) } else { set.insert(activity) }
                            activitiesByDay[index] = set
                        }
                    }
                }
                .padding(.vertical, 4)
                if activitiesByDay[index, default: []].contains(where: TripWizardView.takesDressCode) {
                    TextField("Davetiyedeki kıyafet kuralı (isteğe bağlı)", text: Binding(
                        get: { dressCodeByDay[index] ?? "" }, set: { dressCodeByDay[index] = $0 }
                    ))
                }
            }
        }
    }

    // MARK: Step 3 — bag and preferences (TRV-04)

    private var bag: some View {
        Group {
            Section("Valiz") {
                Picker("Valiz", selection: $policy.bagType) { ForEach(BagType.allCases, id: \.self) { Text($0.displayName).tag($0) } }
                TextField("Ağırlık sınırı (kg, biliyorsan)", text: $maxWeight).keyboardType(.decimalPad)
                Text("Havayolu sınırlarını tahmin etmiyoruz. Bilmiyorsan boş bırak.").font(.footnote).foregroundStyle(Token.textSecondary)
            }
            Section("Çamaşır imkânı") {
                Picker("Çamaşır", selection: $policy.laundryAccess) { ForEach(LaundryAccess.allCases, id: \.self) { Text($0.displayName).tag($0) } }
                    .pickerStyle(.segmented)
            }
            Section {
                Picker("Tercih", selection: $policy.preference) { ForEach(PackingPreference.allCases, id: \.self) { Text($0.displayName).tag($0) } }
                    .pickerStyle(.segmented)
            } header: {
                Text("Hafif valiz ↔ çeşit")
            } footer: {
                Text("Önce dolabından öneririz. Eksik olursa ayrıca gösteririz.")
            }
        }
    }

    // MARK: Logic

    private var startLocal: LocalDate {
        LocalDate(instant: startDate, timeZone: Calendar.current.timeZone)
    }

    private var resolvedDates: Result<[LocalDate], TripDateError> {
        let tz = destination?.timeZone ?? .current
        let today = LocalDate(instant: Date(), timeZone: tz)
        let length: TripLength = countNights ? .nights(lengthValue) : .days(lengthValue)
        return TripDates.endDate(start: startLocal, length: length).flatMap {
            TripDates.validate(start: startLocal, end: $0, today: today)
        }
    }

    private var canContinue: Bool {
        switch step {
        case 0: destination != nil && (try? resolvedDates.get()) != nil
        default: true
        }
    }

    private func message(_ error: TripDateError) -> String {
        switch error {
        case .startInPast: "Gidiş tarihi geçmişte kalmış."
        case .endBeforeStart: "Dönüş, gidişten önce olamaz."
        case .tooLong(let max): "Şimdilik en fazla \(max) gün planlanabiliyor."
        case .zeroLength: "Süre en az 1 gün olmalı."
        }
    }

    /// Dress codes matter for any formal or work event, not only evening ones (review finding 10).
    static func takesDressCode(_ activity: Activity) -> Bool {
        [.dinner, .nightOut, .formalEvent, .business].contains(activity)
    }

    private func create() {
        guard let destination, let dates = try? resolvedDates.get() else { return }
        var events: [TripEvent] = []
        for (index, date) in dates.enumerated() {
            for activity in activitiesByDay[index, default: []].sorted(by: { $0.rawValue < $1.rawValue }) {
                let block: TimeBlock = (activity == .dinner || activity == .nightOut || activity == .formalEvent) ? .evening : .fullDay
                let code = dressCodeByDay[index].flatMap { $0.isEmpty ? nil : $0 }
                events.append(TripEvent(
                    id: "ev-\(index)-\(activity.rawValue)", localDate: date, timeBlock: block, activity: activity,
                    userDressCode: TripWizardView.takesDressCode(activity) ? code : nil
                ))
            }
        }
        var p = policy
        p.maxWeightKg = Double(maxWeight.replacingOccurrences(of: ",", with: "."))
        let trip = Trip(
            id: UUID().uuidString, title: destination.city, destination: destination, dates: dates, events: events,
            policy: p, isSyntheticDemo: false
        )
        Task { await model.createTrip(trip) }
        dismiss()
    }
}

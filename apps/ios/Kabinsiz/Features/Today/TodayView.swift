import SwiftUI
import TravelEngine

/// "Bugün" tab. Travel Mode lives here instead of a fourth tab (§46.1).
struct TodayView: View {
    @Environment(AppModel.self) private var model
    @State private var showWizard = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Space.card) {
                Card {
                    Text("Bugünkü kombin").font(.headline)
                    Text("Günlük kombin önerisi bu sürümde yok. Hava verisi olmadan sıcaklık uydurmuyoruz.")
                        .font(.subheadline).foregroundStyle(Token.textSecondary)
                    StatusBadge(text: "Hava verisi yok", tone: .caution)
                }

                Text("Seyahat Modu").font(.title3.weight(.semibold)).padding(.top, 8)

                ForEach(model.trips.sorted { $0.dates[0] < $1.dates[0] }) { trip in
                    NavigationLink(value: trip.id) { TripTile(trip: trip) }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("tripTile-\(trip.id)")
                }

                if model.trips.isEmpty {
                    Card {
                        EmptyState(symbol: "suitcase", title: "Henüz seyahat yok", message: "Önce dolabından öneririz. Konum veya fotoğraf izni gerekmez.")
                    }
                }

                Button { showWizard = true } label: { Label("Seyahatini planla", systemImage: "plus") }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("planTripButton")

                Button {
                    Task { await model.createDemoTrip() }
                } label: {
                    Label("Örnek Barselona seyahati (sentetik)", systemImage: "flask")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .accessibilityIdentifier("demoTripButton")
            }
            .padding(.horizontal, Token.Space.gutter)
            .padding(.vertical, Token.Space.card)
        }
        .background(Token.surfaceBase)
        .navigationTitle("Bugün")
        .navigationDestination(for: String.self) { TripSummaryView(tripID: $0) }
        .sheet(isPresented: $showWizard) { TripWizardView() }
    }
}

struct TripTile: View {
    @Environment(AppModel.self) private var model
    let trip: Trip

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.destination.displayName).font(.headline).foregroundStyle(Token.textPrimary)
                    Text("\(trip.dates.count) gün · \(trip.dates.first!.description) – \(trip.dates.last!.description)")
                        .font(.caption).foregroundStyle(Token.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Token.textSecondary).accessibilityHidden(true)
            }
            if let list = model.packingLists[trip.id] {
                ProgressView(value: Double(list.packedCount), total: Double(max(1, list.items.count))) {
                    Text("Valiz: \(list.packedCount)/\(list.items.count) hazır").font(.caption)
                }
            }
            if trip.isSyntheticDemo { SyntheticBadge() }
        }
    }
}

import BodyGeometry
import SwiftUI
import TravelEngine

/// "Bugün". The heart of the screen is the person's own body: a living 3D figure they can turn with a
/// finger, from the very first launch (an unsaved neutral stand-in until they make it theirs). Under
/// it, the wardrobe in one honest line, "Tara" and the trip shortcut, then Travel Mode. No outfit or
/// temperature is invented: there is no daily outfit engine or weather here yet (UI20-T-009, §08.1.2).
struct TodayView: View {
    @Environment(AppModel.self) private var model
    @State private var showWizard = false
    let onScan: () -> Void
    let onOpenWardrobe: () -> Void
    let onOpenMe: () -> Void

    private var garmentCount: Int { model.wardrobe.garments.count }
    private var wardrobeIsSynthetic: Bool { !model.wardrobe.isEmpty && model.wardrobe.garments.allSatisfy(\.provenance.isSynthetic) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Atelier.Space.xl) {
                // §08.1.1 header: the wordmark in the page, not in a toolbar glass bubble.
                AtelierWordmark()
                ModelHero(action: heroAction)
                wardrobeLine
                quickActions
                travel
            }
            .padding(.horizontal, Atelier.Space.gutter)
            .padding(.vertical, Atelier.Space.m)
        }
        .background(Atelier.canvas)
        .navigationTitle("Bugün")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
        .sheet(isPresented: $showWizard) { TripWizardView() }
    }

    /// The one primary action: make the stand-in theirs, or go and shape the body they already have.
    private var heroAction: PrimaryAction {
        if model.heroIsStandIn {
            PrimaryAction(title: "Modelimi oluştur", systemImage: "person.crop.circle.badge.plus", id: "createModel") {
                Task { await model.createNeutralBody(unit: .centimeters) }
                onOpenMe()
            }
        } else {
            PrimaryAction(title: "Modelimi düzenle", systemImage: "slider.horizontal.3", id: "editModel", action: onOpenMe)
        }
    }

    private var wardrobeLine: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(model.wardrobe.isEmpty ? "Dolabın boş" : "Dolabında \(garmentCount) parça var")
                    .font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
                Spacer()
                if wardrobeIsSynthetic { SyntheticBadge() }
            }
            Text(model.wardrobe.isEmpty
                 ? "İlk parçanı ekle; eşleşmeleri senin dolabından hazırlayalım. Fotoğraf izni gerekmez."
                 : "Günlük kombin önerisi bu sürümde yok. Seyahat Modu kombinlerini dolabından kurar.")
                .font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            if model.wardrobe.isEmpty {
                SecondaryAction(title: "İlk kıyafetimi ekle", systemImage: "hanger", id: "addFirstGarment", action: onOpenWardrobe)
            } else {
                SecondaryAction(title: "Dolabımı aç", systemImage: "hanger", id: "openWardrobe", action: onOpenWardrobe)
            }
        }
        .padding(Atelier.Space.l)
        .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous).stroke(Atelier.borderSoft))
        .accessibilityElement(children: .contain)
    }

    private var quickActions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Atelier.Space.s) { quickActionButtons }
            VStack(spacing: Atelier.Space.s) { quickActionButtons }
        }
    }

    @ViewBuilder private var quickActionButtons: some View {
        SecondaryAction(title: "Ürünü tara", systemImage: "barcode.viewfinder", id: "scanQuickAction", action: onScan)
        SecondaryAction(title: "Seyahat planla", systemImage: "suitcase", id: "planTripButton") { showWizard = true }
    }

    private var travel: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.m) {
            EditorialHeading(title: "Seyahat Modu", subtitle: "Valizini kendi dolabından kur.")

            ForEach(model.trips.sorted { $0.dates[0] < $1.dates[0] }) { trip in
                NavigationLink(value: trip.id) { TripTile(trip: trip) }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("tripTile-\(trip.id)")
            }

            if model.trips.isEmpty {
                Text("Henüz seyahat yok. Konum veya fotoğraf izni gerekmez.")
                    .font(AtelierType.secondary)
                    .foregroundStyle(Atelier.inkSecondary)
                    .atelierWrapping()
            }

            Button {
                Task { await model.createDemoTrip() }
            } label: {
                Label("Örnek Barselona seyahati (sentetik)", systemImage: "flask")
                    .font(AtelierType.secondary)
                    .frame(maxWidth: .infinity, minHeight: Atelier.minTap)
            }
            .accessibilityIdentifier("demoTripButton")
        }
    }
}

/// K-006 TodayHero, body edition: a studio stage with the living figure, its truth label, and the
/// screen's single primary action. Half the screen height, so the body is what the eye lands on.
struct ModelHero: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let action: PrimaryAction

    private var standIn: Bool { model.heroIsStandIn }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [Atelier.surfaceSecondary, Atelier.sand], startPoint: .top, endPoint: .bottom)
                if let mesh = model.heroMesh {
                    BodyModel3DView(mesh: mesh, summary: summary,
                                    showsAngleButtons: false, identifier: "heroBody3D")
                } else {
                    // 2D budget (heat, Low Power): a calm outline instead of the 3D stage.
                    Image(systemName: "figure.stand")
                        .font(.system(size: 120, weight: .ultraLight))
                        .foregroundStyle(Atelier.avatar)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Basit siluet")
                }
                Eyebrow(text: standIn ? "Nötr başlangıç" : "Senin modelin")
                    .padding(Atelier.Space.l)
            }
            .containerRelativeFrame(.vertical) { height, _ in max(320, height * 0.5) }

            VStack(alignment: .leading, spacing: Atelier.Space.s) {
                Text(standIn ? "Bu senin modelin olacak." : "Kendi bedeninde gör.")
                    .font(AtelierType.sectionTitle).foregroundStyle(Atelier.ink).atelierWrapping()
                    .accessibilityAddTraits(.isHeader)
                Text(standIn
                     ? "Ölçü ya da fotoğraf gerekmez. Kaydırıcılarla kendine benzet; her şey bu telefonda kalır."
                     : "Parmağınla çevir, iki parmakla yaklaş. Ölçülerini Ben sekmesinde ayarlarsın.")
                    .font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
                Label(fidelityLabel, systemImage: "info.circle")
                    .font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
                    .accessibilityIdentifier("heroFidelityLabel")
                if let note = model.deviceNote {
                    Label(note, systemImage: "leaf").font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
                }
                action.padding(.top, Atelier.Space.xs)
            }
            .padding(Atelier.Space.l)
        }
        .background(Atelier.surface)
        .clipShape(RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous).stroke(Atelier.borderSoft, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("todayHero")
    }

    private var fidelityLabel: String {
        if model.heroMesh == nil { return "Basit siluet. Görünüm, beden uyumunun kanıtı değildir." }
        return standIn
            ? "Nötr başlangıç şekli, senin ölçülerin değil. Görünüm, beden uyumunun kanıtı değildir."
            : "Nötr 3B model. Görünüm, beden uyumunun kanıtı değildir."
    }

    private var summary: String {
        guard !standIn, let body = model.body else { return "Nötr başlangıç şekli; ölçü girilmedi." }
        return BodyParameter.allCases.map { "\($0.displayName) \(body[$0].length.formatted(body.preferredUnit))" }.joined(separator: ", ")
    }
}

struct TripTile: View {
    @Environment(AppModel.self) private var model
    let trip: Trip

    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.destination.displayName).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
                    Text("\(trip.dates.count) gün · \(trip.dates.first!.description) – \(trip.dates.last!.description)")
                        .font(AtelierType.caption.monospacedDigit()).foregroundStyle(Atelier.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Atelier.inkSecondary).accessibilityHidden(true)
            }
            if let list = model.packingLists[trip.id] {
                ProgressView(value: Double(list.packedCount), total: Double(max(1, list.items.count))) {
                    Text("Valiz: \(list.packedCount)/\(list.items.count) hazır").font(AtelierType.caption.monospacedDigit())
                }
                .tint(Atelier.olive)
            }
            if trip.isSyntheticDemo { SyntheticBadge() }
        }
    }
}

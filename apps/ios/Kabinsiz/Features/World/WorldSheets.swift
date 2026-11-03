import AvatarDressing
import LivingWorld
import SwiftUI
import TodayOutfit
import TravelEngine

/// One slot's sheet (v2.8 H02, `OutfitSwapSheet`): about a third of the screen, the piece on the
/// figure and three alternatives, all of them a tap away; "Tümünü gör" lists the rest. Choosing a
/// piece puts it on the figure at once, and the sheet stays open so pieces can be compared. "Mağazadan"
/// says plainly that no store catalogue is connected and leads to Dene.
struct OutfitSwapSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.dismiss) private var dismiss
    let slot: GarmentSlotID
    let onTryOn: () -> Void

    private enum Source: String, CaseIterable, Identifiable {
        case mine = "Dolabımdan", store = "Mağazadan"
        var id: String { rawValue }
    }
    @State private var source: Source = .mine
    @State private var showAll = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Atelier.Space.m) {
                Picker("Kaynak", selection: $source) {
                    ForEach(Source.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("traySource")

                switch source {
                case .mine: mine
                case .store: store
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Atelier.Space.l)
            .padding(.top, Atelier.Space.s)
            .navigationTitle(slot.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Geri al", systemImage: "arrow.uturn.backward") { world.undo() }
                        .disabled(!world.dressing.canUndo)
                        .accessibilityIdentifier("trayUndo")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitti") { dismiss() }.accessibilityIdentifier("trayDone")
                }
            }
        }
        .accessibilityIdentifier("worldGarmentSheet")
        .presentationDetents([.fraction(0.36), .large])
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.36)))
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(28)
    }

    @ViewBuilder private var mine: some View {
        let all = world.choices(for: slot, wardrobe: model.wardrobe)
        if all.isEmpty {
            VStack(alignment: .leading, spacing: Atelier.Space.xs) {
                Text("Bu bölüm için dolabında parça yok.").font(AtelierType.cardTitle)
                Text("Dolabım sekmesinden ekleyebilir ya da Dene ile bir ürünü getirebilirsin.")
                    .font(AtelierType.secondary).foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("trayEmpty")
        } else {
            let worn = world.outfit[slot]
            let shown = showAll ? all.filter { $0.id != worn?.id } : world.alternatives(for: slot, wardrobe: model.wardrobe)
            HStack {
                Text(worn == nil ? "Öneriler" : "Üzerinde ve \(shown.count) alternatif")
                    .font(AtelierType.caption.weight(.semibold)).foregroundStyle(.secondary)
                if world.isExample { Text("· örnek dolap, sentetik").font(AtelierType.caption).foregroundStyle(.secondary) }
                Spacer()
                if all.count - (worn == nil ? 0 : 1) > shown.count || showAll {
                    Button(showAll ? "Az göster" : "Tümünü gör") { showAll.toggle() }
                        .font(AtelierType.caption.weight(.semibold))
                        .accessibilityIdentifier("trayShowAll")
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Atelier.Space.s) {
                    if let worn { tile(worn) }
                    ForEach(shown) { item in tile(item) }
                }
                .padding(.vertical, 2)
            }
            if worn != nil, ![.top, .bottom, .footwear].contains(slot) {
                Button("\(slot.displayName) çıkar", systemImage: "minus.circle") { world.remove(slot) }
                    .font(AtelierType.secondary)
                    .accessibilityIdentifier("trayRemove")
            }
        }
    }

    private func tile(_ item: DressItem) -> some View {
        let worn = world.outfit[slot]?.id == item.id
        return Button { world.wear(item) } label: {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.75))
                    .frame(width: 96, height: 96)
                    .overlay { GarmentThumb(item: item, padding: 8) }
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(worn ? Atelier.brand : .primary.opacity(0.12), lineWidth: worn ? 3 : 1))
                Text(item.name).font(AtelierType.caption.weight(.medium)).lineLimit(2)
                    .frame(width: 96, alignment: .leading)
                Text(worn ? "Üzerinde" : "Temsilî çizim").font(.caption2).foregroundStyle(.secondary)
                    .lineLimit(1).frame(width: 96, alignment: .leading)
            }
            .frame(width: 96)
            .contentShape(.rect)
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityIdentifier("trayItem-\(item.id)")
        .accessibilityLabel(item.name)
        .accessibilityValue(worn ? "Üzerinde" : "")
        .accessibilityAddTraits(worn ? .isSelected : [])
    }

    private var store: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            Text("Mağaza kataloğu bağlı değil.").font(AtelierType.cardTitle)
            Text("Bir mağazadaki ürünü denemek için Dene'de etiketini tara ya da kodunu yaz; modelinde ya da Canlı Ayna'da görebilirsin.")
                .font(AtelierType.secondary).foregroundStyle(.secondary)
            Button("Dene'ye git", systemImage: "camera.viewfinder", action: onTryOn)
                .buttonStyle(.borderedProminent)
                .tint(Atelier.brand)
                .accessibilityIdentifier("trayScan")
        }
        .accessibilityIdentifier("trayStore")
    }
}

/// "Neden bu kombin": the engine's own reasons, its gaps and what it did not use — nothing invented.
/// The mood row recomposes the day's looks; the lock keeps today's look through weather updates.
struct WhyThisLookSheet: View {
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// What the street behind the figure is, and why it is not the full 3D street when it is not.
    private var sceneText: String {
        let quality = world.quality(reduceMotion: reduceMotion)
        switch world.shownTier(reduceMotion: reduceMotion) {
        case .city3D: return "3B şehir: gerçek zamanlı geometri, ışığı Blender'da önceden hesaplandı. Özgün model, harita verisi yok."
        case .streetPhoto:
            return "Cadde fotoğrafı: Apple Look Around, \(world.street.map { "\($0.city) · \($0.street)" } ?? ""). Fotoğraf 3B değildir; model temsilidir ve önüne yerleştirildi."
        case .city3DReduced: return "3B şehir, azaltılmış: \(quality.reason). Yağmur seyreltildi, kamera kayması kapalı."
        case .frame2D:
            if quality.tier == .frame2D { return "Düz şehir kadrajı (Blender çizimi, 3B değil): \(quality.reason)." }
            return "3B şehir yükleniyor; o sırada düz Blender kadrajı gösteriliyor."
        }
    }

    private var originText: String {
        switch world.origin {
        case .cachedToday: "Bu cihazda bugün için önceden hazırlandı."
        case .computedNow: "Açılışta bu cihazda hazırlandı."
        case .recoveredFromCorruption: "Önbellek okunamadı; açılışta yeniden hazırlandı."
        case nil: "Henüz hazırlanmadı."
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let looks = world.looks?.looks, looks.count > 1 {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(looks.enumerated()), id: \.element.id) { index, look in
                                    LookSuggestionCard(look: look, index: index, isOn: look.outfit == world.outfit) {
                                        world.wearLook(at: index)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .accessibilityIdentifier("lookSuggestions")
                    } header: {
                        Text("Kombin önerileri")
                    } footer: {
                        Text("Hepsi bugün bu cihazda dolabından hazırlandı\(world.isExample ? "; örnek dolap, sentetik" : "").")
                    }
                }
                if let look = world.currentLook {
                    Section("Neden bu kombin") {
                        ForEach(look.reasons, id: \.self) { Text($0) }
                    }
                    if !look.gaps.isEmpty {
                        Section("Eksik kalan") { ForEach(look.gaps, id: \.self) { Text($0) } }
                    }
                    Section("Bilmediklerimiz") {
                        ForEach(look.unsupportedClaims, id: \.self) { Text($0).foregroundStyle(.secondary) }
                    }
                } else {
                    Text("Henüz bir kombin yok.")
                }
                Section("Ruh hâli") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(TodayOutfitEngine.Mood.allCases, id: \.self) { mood in
                                Button(mood.displayName) { world.setMood(mood) }
                                .buttonStyle(.bordered)
                                .tint(world.mood == mood ? Atelier.brand : .secondary)
                                .accessibilityAddTraits(world.mood == mood ? .isSelected : [])
                                .accessibilityIdentifier("mood-\(mood.rawValue)")
                            }
                        }
                    }
                }
                Section {
                    Button(world.isLocked ? "Sabitlemeyi kaldır" : "Bugün bunu giyeceğim", systemImage: world.isLocked ? "lock.open" : "lock") {
                        world.toggleLock()
                    }
                    .accessibilityIdentifier("lookLock")
                } footer: {
                    Text("Sabitlenen kombini hava ya da şehir değişimi bugün değiştirmez.")
                }
                Section("Hazırlık") {
                    Text(originText).font(.footnote).foregroundStyle(.secondary)
                    if let ms = world.warmStartMillis {
                        Text(String(format: "Bugünün planı: %.1f ms (simülatör ya da cihaz, sahne hariç)", ms))
                            .font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    if let ms = world.lastSwapMillis {
                        Text(String(format: "Son kombin değişimi: %.1f ms (model, sahne hariç)", ms))
                            .font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
                    }
                }
                Section("Sahne") {
                    Text(sceneText).font(.footnote).foregroundStyle(.secondary)
                        .accessibilityIdentifier("sceneTier")
                    if let status = world.streetStatusText, world.streetScene == nil {
                        Text(status).font(.footnote).foregroundStyle(.secondary)
                    }
                    if let fps = world.sustainedFrameRate {
                        Text(String(format: "Sahne güncellemesi: %.0f/sn (bu cihazda, son 6 sn)", fps))
                            .font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
                            .accessibilityIdentifier("sceneRate")
                    }
                }
            }
            .navigationTitle("Bugünün kombini")

            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Kapat") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
    }
}

/// One prepared look as a card (v3.2 S07): the pieces as garment drawings, its first true reason,
/// and "Uygula" to put it on the figure. Nothing in the card is a fit or weather claim.
struct LookSuggestionCard: View {
    let look: TodayLook
    let index: Int
    let isOn: Bool
    let apply: () -> Void

    private var pieces: [DressItem] { look.outfit.slots.compactMap { look.outfit[$0] } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(RadialGradient(colors: [.white, Atelier.surface], center: .center, startRadius: 4, endRadius: 140))
                let main = Array(pieces.prefix(3))
                HStack(spacing: -10) {
                    ForEach(main) { item in GarmentThumb(item: item, padding: 4).frame(width: 74, height: 110) }
                }
            }
            .frame(width: 236, height: 132)
            Text("Kombin \(index + 1)").font(AtelierType.cardTitle)
            Text(look.reasons.first ?? "Dolabından hazırlandı")
                .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                .frame(width: 236, alignment: .leading)
            Button(action: apply) {
                Label(isOn ? "Üzerinde" : "Uygula", systemImage: isOn ? "checkmark" : "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(CopperCapsuleStyle())
            .opacity(isOn ? 0.55 : 1)
                .disabled(isOn)
                .accessibilityIdentifier("lookApply-\(index)")
        }
        .padding(12)
        .frame(width: 260)
        .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(isOn ? Atelier.brand : .clear, lineWidth: 2))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("lookCard-\(index)")
    }
}

/// City, scene and weather (v2.8 H04/H05). The city is chosen by hand; no location is read. Weather
/// says where it comes from and how old it is; rain is a preview only when the user asks for one.
/// Travel lives here too (v2.8 §02: Seyahat opens from the city menu).
struct CityPickerSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.dismiss) private var dismiss
    let onPlan: () -> Void
    @State private var locating = false
    @State private var locateNote: String?
    @State private var locator = CoarseCityLocator()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(SceneCity.allCases.filter { SceneAssetManifestV1.manifest(for: $0) != nil }) { city in
                        Button {
                            world.choose(street: nil)
                            world.city = city
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.displayName).foregroundStyle(.primary)
                                    Text(city.sceneDescription).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if world.street == nil, world.city == city { Image(systemName: "checkmark").foregroundStyle(Atelier.brand) }
                            }
                        }
                        .accessibilityIdentifier("city-\(city.rawValue)")
                        .accessibilityAddTraits(world.street == nil && world.city == city ? .isSelected : [])
                    }
                } header: {
                    Text("Kabinsiz sokakları")
                } footer: {
                    Text("Kabinsiz için Blender'da üretilmiş özgün sokaklar; gerçek fotoğraf değildir. Cihaz kaldırırsa 3B, kaldıramazsa düz kadraj olarak gösterilir.")
                }
                Section {
                    Button {
                        Task { await locate() }
                    } label: {
                        Label(locating ? "Konum bulunuyor…" : "Konumumdaki şehir", systemImage: "location")
                    }
                    .disabled(locating)
                    .accessibilityIdentifier("cityLocate")
                    if let status = world.streetStatusText {
                        Text(status).font(.footnote).foregroundStyle(.secondary).accessibilityIdentifier("streetStatus")
                    }
                    if let locateNote {
                        Text(locateNote).font(.footnote).foregroundStyle(.secondary).accessibilityIdentifier("cityLocateNote")
                    }
                    NavigationLink {
                        WorldStreetList()
                    } label: {
                        LabeledContent("Dünya şehirleri", value: world.street.map { "\($0.city) · \($0.street)" } ?? "\(FamousStreetCatalog.all.count) şehir")
                    }
                    .accessibilityIdentifier("worldStreets")
                    Toggle("Cadde fotoğrafı (Apple Look Around)", isOn: Binding(
                        get: { model.streetImageryConsent != .revoked },
                        set: { on in Task { await model.setStreetImageryAllowed(on) } }))
                    .accessibilityIdentifier("streetPhotoToggle")
                } header: {
                    Text("Dünya şehirleri · ünlü cadde")
                } footer: {
                    Text("Konum yalnız \"Konumumdaki şehir\"e dokununca, yaklaşık olarak istenir; telefonda en yakın şehri bulmak için kullanılır, saklanmaz ve gönderilmez. Apple'a giden tek şey seçilen ünlü caddenin sabit noktasıdır. Fotoğraf Apple Look Around'dan gelir, kaydedilmez; model temsilidir ve fotoğrafın önüne yerleştirilir. Fotoğraf yoksa ya da kapalıysa Kabinsiz sokağı veya stüdyo gösterilir.")
                }
                Section {
                    LabeledContent("Durum", value: world.chip.provenance)
                        .accessibilityIdentifier("cityWeatherSource")
                    Toggle("Yağmur önizlemesi", isOn: Binding(
                        get: { world.preview == .rain },
                        set: { world.preview = $0 ? .rain : nil }))
                    .accessibilityIdentifier("cityRainToggle")
                } header: {
                    Text("Hava")
                } footer: {
                    Text("Bu sürümde hava servisi bağlı değil. Yağmur yalnız sen istersen ve önizleme olarak gösterilir; kombin önizlemeye göre değişmez. Cadde fotoğrafının önünde yağmur çizilmez.")
                }
            }
            .navigationTitle("Şehir ve hava")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Seyahat", systemImage: "suitcase") { onPlan() }
                        .labelStyle(.titleAndIcon)
                        .accessibilityLabel("Seyahat ve plan")
                        .accessibilityIdentifier("worldPlan")
                }
                ToolbarItem(placement: .confirmationAction) { Button("Bitti") { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func locate() async {
        locating = true
        defer { locating = false }
        switch await locator.locate() {
        case let .city(street):
            world.choose(street: street)
            locateNote = "\(street.city) · \(street.street)"
        case .noCityNearby: locateNote = "Yakınında listede bir şehir yok; listeden seçebilirsin."
        case .denied: locateNote = "Konum izni yok. Şehri listeden seçebilirsin."
        case .unavailable: locateNote = "Konum şu an alınamadı. Şehri listeden seçebilirsin."
        }
    }
}

/// Every catalogue city with its famous street. Choosing one is the user action that may fetch its photo.
struct WorldStreetList: View {
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(FamousStreetCatalog.all) { street in
            Button {
                world.choose(street: street)
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(street.city).foregroundStyle(.primary)
                        Text(street.street).font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if world.street == street { Image(systemName: "checkmark").foregroundStyle(Atelier.brand) }
                }
            }
            .accessibilityIdentifier("street-\(street.id)")
        }
        .navigationTitle("Dünya şehirleri")
    }
}

extension Color {
    init(rgb: UInt32) {
        self.init(.sRGB, red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF) / 255, blue: Double(rgb & 0xFF) / 255)
    }
}

import SwiftUI

// v2.0 §09 component kit, K-001…K-020. Colours, radii and spacing come only from `Atelier`; type only
// from `AtelierType`. Nothing here invents data: every value a component shows is passed in, and a
// missing value is shown as missing.

// MARK: K-001 AtelierWordmark

struct AtelierWordmark: View {
    var body: some View {
        Text("Kabinsiz")
            .font(AtelierType.wordmark)
            .foregroundStyle(Atelier.ink)
            .atelierWrapping()
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("wordmark")
    }
}

// MARK: K-002 PrimaryAction / K-003 SecondaryAction

/// Press feedback: a slight scale, none under Reduce Motion.
struct AtelierPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(Atelier.Motion.micro(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

/// The one dominant action of a screen (UI20-T-006). Identifier is `primary.<id>`, so a test can count them.
struct PrimaryAction: View {
    let title: String
    var systemImage: String? = "arrow.right"
    var isLoading = false
    var isEnabled = true
    let id: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Atelier.Space.s) {
                if isLoading { ProgressView().tint(Atelier.onBrand) }
                Text(title).font(.headline).multilineTextAlignment(.leading).atelierWrapping()
                Spacer(minLength: Atelier.Space.xs)
                if let systemImage, !isLoading { Image(systemName: systemImage).accessibilityHidden(true) }
            }
            .padding(.horizontal, Atelier.Space.l)
            .padding(.vertical, Atelier.Space.s)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Atelier.onBrand)
            .background(Atelier.brand.opacity(isEnabled ? 1 : 0.45), in: RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(AtelierPressStyle())
        .disabled(!isEnabled || isLoading)
        .accessibilityValue(isLoading ? "Hazırlanıyor" : "")
        .accessibilityIdentifier("primary.\(id)")
    }
}

struct SecondaryAction: View {
    let title: String
    var systemImage: String?
    let id: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Atelier.Space.xs) {
                if let systemImage { Image(systemName: systemImage).accessibilityHidden(true) }
                Text(title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.leading).atelierWrapping()
            }
            .padding(.horizontal, Atelier.Space.m)
            .padding(.vertical, Atelier.Space.xs)
            .frame(maxWidth: .infinity, minHeight: Atelier.minTap)
            .foregroundStyle(Atelier.ink)
            .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous).stroke(Atelier.borderControl, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(AtelierPressStyle())
        .accessibilityIdentifier(id)
    }
}

// MARK: K-004 EditorialHeading

struct EditorialHeading: View {
    enum Level { case display, screen, section }

    var eyebrow: String?
    let title: String
    var subtitle: String?
    var level: Level = .section

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xs) {
            if let eyebrow { Eyebrow(text: eyebrow) }
            Text(title)
                .font(level == .display ? AtelierType.display : level == .screen ? AtelierType.screenTitle : AtelierType.sectionTitle)
                .foregroundStyle(Atelier.ink)
                .atelierWrapping()
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: K-005 FashionPhotoCard

/// 3:4 media. Only a licensed real image may be passed; without one the card shows a category
/// silhouette and the words, never a made-up fashion scene (§05.1).
struct FashionPhotoCard: View {
    var image: Image?
    let fallbackSymbol: String
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xs) {
            Color.clear
                .aspectRatio(3 / 4, contentMode: .fit)
                .overlay {
                    if let image {
                        image.resizable().scaledToFill()
                    } else {
                        ZStack {
                            Atelier.surfaceSecondary
                            Image(systemName: fallbackSymbol).font(.system(size: 44, weight: .light)).foregroundStyle(Atelier.inkSecondary)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
                .accessibilityHidden(image == nil)
            Text(title).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink).atelierWrapping()
            if let subtitle { Text(subtitle).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping() }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: K-006 TodayHero

/// The one strong answer of the home screen with its single CTA. Without an outfit it says so and
/// offers the first step; it never shows a wardrobe the user does not have (UI20-T-009).
struct TodayHero: View {
    enum Content {
        case outfit(title: String, reason: String, itemSymbols: [String])
        case empty(title: String, message: String, symbol: String)
    }

    let eyebrow: String
    let content: Content
    let action: PrimaryAction

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.m) {
            Eyebrow(text: eyebrow)
            switch content {
            case .outfit(let title, let reason, let symbols):
                HStack(spacing: Atelier.Space.s) {
                    ForEach(Array(symbols.prefix(4).enumerated()), id: \.offset) { _, symbol in
                        Image(systemName: symbol)
                            .font(.title2.weight(.light))
                            .foregroundStyle(Atelier.ink)
                            .frame(maxWidth: .infinity, minHeight: 72)
                            .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
                    }
                }
                .accessibilityHidden(true)
                Text(title).font(AtelierType.sectionTitle).foregroundStyle(Atelier.ink).atelierWrapping()
                Text(reason).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            case .empty(let title, let message, let symbol):
                Image(systemName: symbol)
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(Atelier.copper)
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .accessibilityHidden(true)
                Text(title).font(AtelierType.sectionTitle).foregroundStyle(Atelier.ink).atelierWrapping()
                Text(message).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            }
            action
        }
        .padding(Atelier.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous).stroke(Atelier.borderSoft, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("todayHero")
    }
}

// MARK: K-007 ContextChip

/// A context fact (e.g. weather) always carries its source and time. With no source there is no chip.
struct ContextChip: View {
    let symbol: String
    let text: String
    let source: String
    let observedAt: Date

    var body: some View {
        HStack(spacing: Atelier.Space.xs) {
            Image(systemName: symbol).accessibilityHidden(true)
            Text(text).font(AtelierType.secondary)
            Text("· \(source), \(observedAt.formatted(.dateTime.hour().minute().locale(Locale(identifier: "tr_TR"))))")
                .font(AtelierType.caption)
                .foregroundStyle(Atelier.inkSecondary)
        }
        .foregroundStyle(Atelier.ink)
        .padding(.horizontal, Atelier.Space.s)
        .frame(minHeight: 32)
        .background(Atelier.surfaceSecondary, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

// MARK: K-008 TrustBadge

enum TrustLevel: String, CaseIterable {
    case verified, estimated, userProvided, unknown, synthetic

    var text: String {
        switch self {
        case .verified: "Doğrulandı"
        case .estimated: "Tahmini"
        case .userProvided: "Senin girdiğin"
        case .unknown: "Bilinmiyor"
        case .synthetic: "Örnek veri"
        }
    }

    var symbol: String {
        switch self {
        case .verified: "checkmark.seal"
        case .estimated: "ruler"
        case .userProvided: "person.crop.circle"
        case .unknown: "questionmark.circle"
        case .synthetic: "flask"
        }
    }

    var color: Color {
        switch self {
        case .verified: Atelier.success
        case .estimated, .synthetic: Atelier.warning
        case .userProvided: Atelier.brand
        case .unknown: Atelier.inkSecondary
        }
    }
}

/// Icon and words, never colour alone (UI20-T-028).
struct TrustBadge: View {
    let level: TrustLevel

    var body: some View {
        Label(level.text, systemImage: level.symbol)
            .font(AtelierType.caption.weight(.medium))
            .foregroundStyle(level.color)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Güven: \(level.text)")
    }
}

// MARK: K-009 ProductFactRow

/// Label / value / source. A missing value reads "Bilgi henüz yok" and is always `unknown`, whatever
/// trust the caller passed (§09.1).
struct ProductFactRow: View {
    let label: String
    let value: String?
    var source: String?
    var trust: TrustLevel = .unknown
    var addAction: (() -> Void)?

    private var shownTrust: TrustLevel { value == nil ? .unknown : trust }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: Atelier.Space.s) {
                Text(label).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary)
                Spacer(minLength: Atelier.Space.s)
                valueColumn(alignment: .trailing)
            }
            VStack(alignment: .leading, spacing: Atelier.Space.xxs) {
                Text(label).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary)
                valueColumn(alignment: .leading)
            }
        }
        .padding(.vertical, Atelier.Space.xs)
        .accessibilityElement(children: .combine)
    }

    private func valueColumn(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: Atelier.Space.xxs) {
            Text(value ?? "Bilgi henüz yok")
                .font(value == nil ? AtelierType.body : AtelierType.figure)
                .foregroundStyle(value == nil ? Atelier.inkSecondary : Atelier.ink)
                .multilineTextAlignment(alignment == .trailing ? .trailing : .leading)
                .atelierWrapping()
            HStack(spacing: Atelier.Space.xs) {
                TrustBadge(level: shownTrust)
                if let source, value != nil { Text(source).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary) }
            }
            if value == nil, let addAction {
                Button(action: addAction) {
                    Text("Etiketten ekle").font(AtelierType.secondary.weight(.semibold))
                        .frame(minWidth: Atelier.minTap, minHeight: Atelier.minTap)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}

// MARK: K-010 FitZoneRow

enum FitVerdict: CaseIterable {
    case comfortable, snug, loose, abstain

    var text: String {
        switch self {
        case .comfortable: "Rahat"
        case .snug: "Dar olabilir"
        case .loose: "Bol olabilir"
        case .abstain: "Karar yok"
        }
    }

    var symbol: String {
        switch self {
        case .comfortable: "checkmark.circle"
        case .snug: "arrow.right.and.line.vertical.and.arrow.left"
        case .loose: "arrow.left.and.line.vertical.and.arrow.right"
        case .abstain: "questionmark.circle"
        }
    }
}

/// Region + verdict + reason. No percentages: a verdict is a word, and an abstain is shown as an abstain (UI20-T-011).
struct FitZoneRow: View {
    let region: String
    let verdict: FitVerdict
    let reason: String

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xxs) {
            HStack {
                Text(region).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
                Spacer()
                Label(verdict.text, systemImage: verdict.symbol)
                    .font(AtelierType.secondary.weight(.medium))
                    .foregroundStyle(verdict == .abstain ? Atelier.inkSecondary : Atelier.ink)
            }
            Text(Self.withoutPercent(reason)).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
        }
        .padding(.vertical, Atelier.Space.xs)
        .accessibilityElement(children: .combine)
    }

    /// Defence in depth: a reason that slipped a percentage through is not drawn with it.
    static func withoutPercent(_ s: String) -> String {
        s.contains("%") ? "Gerekçe gösterilemiyor." : s
    }
}

// MARK: K-011 BodySlider

/// `− / slider / +` with a spoken value, adjustable action and a light selection haptic.
struct BodySlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    let unit: String
    let id: String
    var onEditingChanged: (Bool) -> Void = { _ in }

    private var spoken: String { "\(Int(value.rounded())) \(unit)" }

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xs) {
            HStack {
                Text(title).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink)
                Spacer()
                Text(spoken).font(AtelierType.figure).foregroundStyle(Atelier.ink).accessibilityIdentifier("value-\(id)")
            }
            HStack(spacing: Atelier.Space.xs) {
                stepButton("minus", label: "\(title) azalt", delta: -step)
                Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged)
                    .tint(Atelier.brand)
                    .accessibilityLabel(title)
                    .accessibilityValue(spoken)
                    .accessibilityIdentifier("slider-\(id)")
                stepButton("plus", label: "\(title) artır", delta: step)
            }
        }
        .sensoryFeedback(.selection, trigger: value)
    }

    private func stepButton(_ symbol: String, label: String, delta: Double) -> some View {
        Button {
            value = min(range.upperBound, max(range.lowerBound, value + delta))
            onEditingChanged(false)
        } label: {
            Image(systemName: symbol)
                .frame(width: Atelier.minTap, height: Atelier.minTap)
                .background(Atelier.surfaceSecondary, in: Circle())
                .foregroundStyle(Atelier.ink)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: K-012 PreviewViewport

enum ViewAngle: String, CaseIterable, Identifiable {
    case front, side, back
    var id: String { rawValue }

    var text: String {
        switch self {
        case .front: "Ön"
        case .side: "Yan"
        case .back: "Arka"
        }
    }
}

/// Neutral matte stage with front/side/back. Without a 3D budget it says what it shows instead.
struct PreviewViewport<Content: View>: View {
    @Binding var angle: ViewAngle
    let allows3D: Bool
    let fidelityLabel: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            ZStack {
                Atelier.surfaceSecondary
                if allows3D {
                    content
                } else {
                    VStack(spacing: Atelier.Space.xs) {
                        Image(systemName: "figure.stand").font(.system(size: 64, weight: .ultraLight)).foregroundStyle(Atelier.avatar)
                        Text("Basit görünüm").font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary)
                    }
                }
            }
            .frame(minHeight: 260)
            .clipShape(RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous))

            HStack(spacing: Atelier.Space.xs) {
                ForEach(ViewAngle.allCases) { a in
                    Button { angle = a } label: {
                        Text(a.text)
                            .font(AtelierType.secondary.weight(a == angle ? .semibold : .regular))
                            .frame(maxWidth: .infinity, minHeight: Atelier.minTap)
                            .foregroundStyle(a == angle ? Atelier.onBrand : Atelier.ink)
                            .background(a == angle ? Atelier.brand : Atelier.surface, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(a == angle ? .isSelected : [])
                    .accessibilityIdentifier("viewAngle-\(a.rawValue)")
                }
            }
            Text(fidelityLabel).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
        }
    }
}

// MARK: K-013 WardrobeTile

enum WearState: CaseIterable {
    case clean, worn, unknown

    var text: String {
        switch self {
        case .clean: "Temiz"
        case .worn: "Giyildi"
        case .unknown: "Durum bilinmiyor"
        }
    }
}

struct WardrobeTile: View {
    let symbol: String
    let name: String
    let state: WearState
    var isSynthetic = false

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xs) {
            Image(systemName: symbol)
                .font(.title2.weight(.light))
                .foregroundStyle(Atelier.ink)
                .frame(maxWidth: .infinity, minHeight: 88)
                .background(Atelier.surfaceSecondary, in: RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
                .accessibilityHidden(true)
            Text(name).font(AtelierType.secondary.weight(.semibold)).foregroundStyle(Atelier.ink).atelierWrapping()
            Text(state.text).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary)
            if isSynthetic { TrustBadge(level: .synthetic) }
        }
        .padding(Atelier.Space.s)
        .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: K-014 OutfitReasonChip

enum OutfitReasonKind: CaseIterable {
    case color, layer, occasion, weather, comfort

    var symbol: String {
        switch self {
        case .color: "paintpalette"
        case .layer: "square.stack.3d.up"
        case .occasion: "calendar"
        case .weather: "cloud.sun"
        case .comfort: "leaf"
        }
    }
}

struct OutfitReasonChip: View {
    let kind: OutfitReasonKind
    let text: String

    var body: some View {
        Label(text, systemImage: kind.symbol)
            .font(AtelierType.caption)
            .foregroundStyle(Atelier.ink)
            .padding(.horizontal, Atelier.Space.s)
            .frame(minHeight: 32)
            .background(Atelier.sand, in: Capsule())
            .accessibilityElement(children: .combine)
    }
}

// MARK: K-015 PartnerProductTile

/// A shop product. "Sponsorlu" is its own line, never a colour trick; an unverified price says so.
struct PartnerProductTile: View {
    let name: String
    let brand: String
    let priceText: String?
    let source: String
    let isSponsored: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.xxs) {
            if isSponsored {
                Text("Sponsorlu").font(AtelierType.eyebrow).foregroundStyle(Atelier.inkSecondary).accessibilityIdentifier("sponsoredLabel")
            }
            Text(brand).font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary)
            Text(name).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink).atelierWrapping()
            Text(priceText ?? "Fiyat doğrulanmadı").font(priceText == nil ? AtelierType.caption : AtelierType.figure)
                .foregroundStyle(priceText == nil ? Atelier.inkSecondary : Atelier.ink)
            Text("Kaynak: \(source)").font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary)
        }
        .padding(Atelier.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous).stroke(Atelier.borderSoft))
        .accessibilityElement(children: .combine)
    }
}

// MARK: K-016 StatePanel

/// One honest state with a way forward (UI-12): never a dead end.
struct StatePanel: View {
    enum Kind: CaseIterable {
        case empty, offline, blocked, broken, permissionDenied, lowConfidence

        var symbol: String {
            switch self {
            case .empty: "tray"
            case .offline: "wifi.slash"
            case .blocked: "lock"
            case .broken: "exclamationmark.triangle"
            case .permissionDenied: "hand.raised"
            case .lowConfidence: "questionmark.circle"
            }
        }
    }

    struct Action: Identifiable {
        let title: String
        let id: String
        let run: () -> Void
    }

    let kind: Kind
    let title: String
    let message: String
    var reassurance: String?
    var actions: [Action] = []

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            Label {
                Text(title).font(AtelierType.cardTitle).foregroundStyle(Atelier.ink).atelierWrapping()
            } icon: {
                Image(systemName: kind.symbol).foregroundStyle(Atelier.copper)
            }
            Text(message).font(AtelierType.secondary).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            ForEach(actions) { a in SecondaryAction(title: a.title, id: a.id, action: a.run) }
            if let reassurance {
                Label(reassurance, systemImage: "lock").font(AtelierType.caption).foregroundStyle(Atelier.inkSecondary).atelierWrapping()
            }
        }
        .padding(Atelier.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Atelier.surface, in: RoundedRectangle(cornerRadius: Atelier.Radius.card, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

// MARK: K-017 NativeTabScaffold

/// The three P0 sections (v2.0 §06). "Tara" is an action, never a tab.
enum AtelierTab: String, CaseIterable, Identifiable {
    case today, wardrobe, me
    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Bugün"
        case .wardrobe: "Dolabım"
        case .me: "Ben"
        }
    }

    var symbol: String {
        switch self {
        case .today: "sun.max"
        case .wardrobe: "hanger"
        case .me: "person.crop.circle"
        }
    }
}

// The scaffold itself is `RootView` (KabinsizApp.swift): a native TabView over `AtelierTab`, one
// NavigationStack per tab, and the same "Tara" toolbar action on every tab.

// MARK: K-018 AtelierSheet

extension View {
    /// Native sheet with a title, a reachable close button and the §08.3 detents.
    func atelierSheet<Body: View>(isPresented: Binding<Bool>, title: String, detents: Set<PresentationDetent> = [.medium, .large],
                                  @ViewBuilder content: @escaping () -> Body) -> some View {
        sheet(isPresented: isPresented) {
            NavigationStack {
                ScrollView { content().padding(Atelier.Space.gutter) }
                    .background(Atelier.canvas)
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") { isPresented.wrappedValue = false }.accessibilityIdentifier("sheetClose")
                        }
                    }
            }
            .presentationDetents(detents)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: K-019 ShimmerlessSkeleton

/// Static, low-energy placeholder: no shimmer, no animation, nothing for Reduce Motion to switch off.
struct ShimmerlessSkeleton: View {
    var lines = 3

    var body: some View {
        VStack(alignment: .leading, spacing: Atelier.Space.s) {
            RoundedRectangle(cornerRadius: Atelier.Radius.small).fill(Atelier.sand).frame(height: 120)
            ForEach(0..<lines, id: \.self) { i in
                RoundedRectangle(cornerRadius: Atelier.Radius.small).fill(Atelier.surfaceSecondary)
                    .frame(height: 14)
                    .frame(maxWidth: i == lines - 1 ? 160 : .infinity, alignment: .leading)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Yükleniyor")
    }
}

// MARK: K-020 SourceDisclosure

struct SourceInfo {
    let name: String
    let observedAt: Date?
    let rights: String
    let trust: TrustLevel
}

/// "Kaynağı gör": date, data rights and trust class in a medium sheet.
struct SourceDisclosure: View {
    let source: SourceInfo
    @State private var isOpen = false

    var body: some View {
        Button { isOpen = true } label: {
            Label("Kaynağı gör", systemImage: "info.circle").font(AtelierType.secondary)
                .frame(minHeight: Atelier.minTap).contentShape(Rectangle())
        }
        .accessibilityIdentifier("sourceDisclosure")
        .atelierSheet(isPresented: $isOpen, title: "Kaynak", detents: [.medium]) {
            VStack(alignment: .leading, spacing: Atelier.Space.m) {
                ProductFactRow(label: "Kaynak", value: source.name, trust: source.trust)
                ProductFactRow(label: "Tarih", value: source.observedAt?.formatted(.dateTime.day().month().year().locale(Locale(identifier: "tr_TR"))), trust: source.trust)
                ProductFactRow(label: "Veri hakkı", value: source.rights, trust: source.trust)
            }
        }
    }
}

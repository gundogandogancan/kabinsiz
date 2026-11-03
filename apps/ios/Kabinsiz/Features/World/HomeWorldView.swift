import AvatarDressing
import BodyGeometry
import LivingWorld
import MorningReady
import SwiftUI
import TodayOutfit
import TravelEngine

/// "Bugün" (v2.8 H01–H05, ADR-011): the person's own figure, dressed in today's prepared look,
/// standing in their city. The scene leads; the chrome is only the wordmark, one city/weather chip
/// and, at the bottom edge, "Yeni kombin" and "Dene". Garments are changed by touching them on the
/// figure (or through VoiceOver actions), which opens one short sheet; the camera lifts the figure so
/// the sheet never hides the face or knees. Nothing is claimed that the app does not know.
struct HomeWorldView: View {
    @Environment(AppModel.self) private var model
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onTryOn: () -> Void
    let onOpenMe: () -> Void
    let onOpenWardrobe: () -> Void
    let onPlan: () -> Void

    /// Front three-quarter (v2.8 §06.1: 20–35°), never the back.
    static let startYaw: Float = 0.55

    @State private var zoom: Float = 1
    @State private var yaw: Float = HomeWorldView.startYaw
    @State private var showWhy = false
    @State private var showCity = false
    @State private var sheetFor: GarmentSlotID?
    @State private var turnedOnce = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                world3D
                    // Reframe while the garment sheet is up: the figure lifts into the top two thirds.
                    .offset(y: sheetFor == nil ? 0 : -geo.size.height * 0.09)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: sheetFor)
                VStack(spacing: 0) {
                    header
                    Spacer(minLength: 0)
                    footer
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .opacity(sheetFor == nil ? 1 : 0)
                .allowsHitTesting(sheetFor == nil)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: sheetFor)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: refresh)
        .onChange(of: model.wardrobe) { refresh() }
        .onChange(of: world.city) { refresh() }
        .onChange(of: avatarRevision) { refresh() }
        .navigationDestination(for: WorldRoute.self) { route in
            switch route {
            case .plan: TodayView(onScan: onTryOn, onOpenWardrobe: onOpenWardrobe, onOpenMe: onOpenMe)
            }
        }
        .navigationDestination(for: String.self) { TripSummaryView(tripID: $0) }
        .sheet(isPresented: $showWhy) { WhyThisLookSheet() }
        .sheet(isPresented: $showCity) { CityPickerSheet(onPlan: { showCity = false; onPlan() }) }
        .sheet(item: $sheetFor, onDismiss: { world.selectedSlot = nil }) { slot in
            OutfitSwapSheet(slot: slot, onTryOn: { sheetFor = nil; onTryOn() })
        }
    }

    private var avatarRevision: String {
        model.heroIsStandIn ? "standin" : "body-\(model.body?.revision ?? 0)"
    }

    private func refresh() {
        world.refresh(wardrobe: model.wardrobe, avatarRevision: avatarRevision)
    }

    private func open(_ slot: GarmentSlotID?) {
        turnedOnce = true
        world.selectedSlot = slot
        sheetFor = slot
    }

    // MARK: Scene

    private var world3D: some View {
        ZStack {
            backdrop
            stage
        }
    }

    /// The city backdrop: an owned Blender render matched to the 3D camera (a 2D image behind the 3D
    /// figure, ADR-011 Karar 6), scaled with zoom about the centre.
    private var backdrop: some View {
        GeometryReader { geo in
            Group {
                if let manifest = world.manifest {
                    Image(world.sceneWeather.wetGround ? manifest.wetBackdrop : manifest.dryBackdrop)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .scaleEffect(CGFloat(zoom))
                        .clipped()
                } else {
                    LinearGradient(colors: [Atelier.surfaceSecondary, Atelier.sand], startPoint: .top, endPoint: .bottom)
                }
            }
            .overlay(alignment: .top) {
                // Scrim behind the header only (v2.8 §04 contrast rule): text never sits on the bare scene.
                LinearGradient(colors: [Color(rgb: 0x221913).opacity(0.55), .clear], startPoint: .top, endPoint: .bottom).frame(height: 170)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(stops: [.init(color: Atelier.canvas.opacity(0), location: 0), .init(color: Atelier.canvas.opacity(0.85), location: 0.6),
                                       .init(color: Atelier.canvas.opacity(0.97), location: 1)], startPoint: .top, endPoint: .bottom).frame(height: 250)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    @ViewBuilder private var stage: some View {
        if let mesh = model.heroMesh, let snapshot = model.heroSnapshot {
            DressedAvatarView(
                body3D: mesh, snapshot: snapshot, outfit: world.outfit, prewarm: world.looks?.looks.map(\.outfit) ?? [],
                light: light, rainIntensity: world.sceneWeather.rainIntensity,
                alive: model.allowsLivelyMotion && !reduceMotion,
                selectedSlot: Binding(get: { world.selectedSlot }, set: { world.selectedSlot = $0 }),
                zoom: $zoom, yaw: $yaw,
                onTapSlot: { slot in
                    guard let slot else { world.selectedSlot = nil; return }
                    open(slot)
                },
                onSlotAction: { open($0) }
            )
            .ignoresSafeArea()
            .onChange(of: yaw) { turnedOnce = true }
        } else {
            // 2D budget: a calm outline and the same controls (v2.5 §10 P3; no 3D is claimed).
            Image(systemName: "figure.stand")
                .font(.system(size: 160, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.85))
                .accessibilityLabel("Basit siluet")
        }
    }

    private var light: WorldLight {
        guard let manifest = world.manifest else { return .studio }
        if world.sceneWeather.wetGround { return manifest.renderedLight == .evening ? .evening : .overcast }
        return manifest.renderedLight == .evening ? .evening : .day
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: Atelier.Space.s) {
                Text("Kabinsiz")
                    .font(.system(.title, design: .serif, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: Atelier.Space.s)
                weatherChip
            }
            if world.isExample {
                Text("Örnek kombin · sentetik")
                    .font(AtelierType.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .lineLimit(1)
                    .accessibilityIdentifier("worldLookKind")
            }
        }
        .padding(.horizontal, Atelier.Space.l)
        .padding(.top, 4)
    }

    private var weatherChip: some View {
        let chip = world.chip
        return Button { showCity = true } label: {
            VStack(alignment: .trailing, spacing: 1) {
                HStack(spacing: 6) {
                    Image(systemName: symbol(for: chip.state)).foregroundStyle(Atelier.copper)
                    Text(world.city.displayName).font(AtelierType.secondary.weight(.semibold))
                }
                Text(chip.weatherLine).font(AtelierType.caption)
                if chip.state != .noData {
                    Text(chip.provenance).font(.caption2).foregroundStyle(Atelier.inkSecondary)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.trailing)
            .foregroundStyle(Atelier.ink)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .frame(minHeight: Atelier.minTap)
            .paperSurface(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(chip.state == .noData ? chip.title : "\(chip.title), \(chip.provenance)")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("weatherChip")
        .accessibilityHint("Şehri, sahneyi ve seyahat planını aç")
    }

    private func symbol(for state: WeatherChipText.State) -> String {
        switch state {
        case .live: world.sceneWeather.wetGround ? "cloud.rain" : "sun.max"
        case .lastKnown: "clock.arrow.circlepath"
        case .noData: "mappin.and.ellipse"
        case .preview: "eye"
        }
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 10) {
            if let notice = world.notice {
                Button { world.undo() } label: {
                    HStack(spacing: 8) {
                        Text(notice)
                        Text("·").foregroundStyle(Atelier.inkSecondary)
                        Label("Geri al", systemImage: "arrow.uturn.backward").labelStyle(.titleAndIcon).foregroundStyle(Atelier.copper)
                    }
                    .font(AtelierType.caption.weight(.semibold))
                    .foregroundStyle(Atelier.ink)
                    .padding(.horizontal, 14)
                    .frame(minHeight: Atelier.minTap)
                    .paperSurface(Capsule())
                }
                .buttonStyle(AtelierPressStyle())
                .disabled(!world.dressing.canUndo)
                .accessibilityLabel("\(notice). Geri al")
                .accessibilityIdentifier("worldUndo")
                .transition(.opacity)
            } else if model.heroIsStandIn {
                Button(action: onOpenMe) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.badge.plus").foregroundStyle(Atelier.copper)
                        Text("Örnek beden · modelini oluştur")
                    }
                    .font(AtelierType.caption.weight(.semibold))
                    .foregroundStyle(Atelier.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                    .frame(minHeight: Atelier.minTap)
                    .paperSurface(Capsule())
                }
                .buttonStyle(AtelierPressStyle())
                .accessibilityLabel("Örnek beden gösteriliyor. Kendi modelini oluştur")
                .accessibilityIdentifier("worldCreateModel")
            } else if !turnedOnce {
                Label("Döndürmek için yana kaydır · parçaya dokun", systemImage: "hand.draw")
                    .font(AtelierType.caption)
                    .foregroundStyle(Atelier.ink)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .paperSurface(Capsule())
            }
            if let look = world.currentLook {
                Button { showWhy = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: world.isLocked ? "lock.fill" : "sparkles").foregroundStyle(Atelier.copper)
                        Text(reasonLine(look)).lineLimit(2)
                        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(Atelier.inkSecondary)
                    }
                    .font(AtelierType.caption.weight(.medium))
                    .foregroundStyle(Atelier.ink)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .frame(minHeight: Atelier.minTap)
                    .paperSurface(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("worldReasonChip")
                .accessibilityHint("Bu kombinin nedenleri, ruh hâli ve sabitleme")
            }
            HStack(spacing: 10) {
                // v2.8 UI28-T018: no "Yeni kombin" when there is no other prepared look to show.
                if (world.looks?.looks.count ?? 0) > 1 {
                    PrimaryAction(title: "Yeni kombin", systemImage: "sparkles", id: "newLook") { world.nextLook() }
                }
                Button(action: onTryOn) {
                    Label("Dene", systemImage: "camera.viewfinder")
                        .font(.headline)
                        .labelStyle(PaperLabelStyle())
                        .foregroundStyle(Atelier.ink)
                        .padding(.horizontal, 18)
                        .frame(minHeight: 52)
                        .paperSurface(RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
                }
                .buttonStyle(AtelierPressStyle())
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityHint("Barkod, dolap ya da Canlı Ayna ile bir ürünü dene")
                .accessibilityIdentifier("homeTryOn")
            }
            Text("Temsili 3B giysi · şehir Blender kadrajı · beden uyumunu göstermez")
                .font(.caption2)
                .foregroundStyle(Atelier.inkSecondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("worldTruthLabel")
        }
        .padding(.horizontal, Atelier.Space.l)
        .padding(.bottom, 8)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: world.notice)
    }

    private func reasonLine(_ look: TodayLook) -> String {
        if world.isLocked { return "Bugün bunu giyeceksin · sabitlendi" }
        // The weather reason leads when there is one; otherwise the colour reason.
        if let weather = look.reasons.first(where: { $0.hasPrefix("Yağmur") }) { return weather }
        return look.reasons.first { $0.contains("dengesi") || $0.contains("tonlar") } ?? look.reasons.first ?? ""
    }
}

private struct PaperLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon.foregroundStyle(Atelier.copper)
            configuration.title
        }
    }
}

extension View {
    /// The brand mark's material (icon, 2026-11-03): warm ivory paper with a soft lift and a hairline
    /// copper edge; filled, it is the copper of the mark. Readable over any part of the street scene.
    func paperSurface<S: InsettableShape>(_ shape: S, filled: Bool = false) -> some View {
        background {
            if filled {
                shape.fill(LinearGradient(colors: [Atelier.copper, Atelier.brand], startPoint: .top, endPoint: .bottom))
            } else {
                shape.fill(Atelier.surface.opacity(0.95))
            }
        }
        .overlay(shape.strokeBorder(filled ? Color.white.opacity(0.25) : Atelier.copper.opacity(0.28), lineWidth: 0.75))
        .shadow(color: Color(red: 0.42, green: 0.29, blue: 0.2).opacity(0.22), radius: 10, y: 4)
    }
}

enum WorldRoute: Hashable {
    case plan
}

extension GarmentSlotID: Identifiable {
    public var id: String { rawValue }
}

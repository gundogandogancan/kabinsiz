import AvatarDressing
import BodyGeometry
import LivingWorld
import MapKit
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
                scrims
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
        .task(id: StreetRequest(id: world.street?.id, allowed: model.streetImageryConsent != .revoked, ready: model.consentLoaded)) {
            // Before the stored consent is read the gate is closed by design; wait instead of saying "off".
            guard model.consentLoaded else { return }
            await world.loadStreetScene(allowed: model.streetImageryConsent != .revoked) { try await model.lookAroundScene(for: $0) }
        }
        .onReceive(NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification).receive(on: RunLoop.main)) { _ in
            world.readDeviceState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange).receive(on: RunLoop.main)) { _ in
            world.readDeviceState()
        }
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

    private var quality: SceneQuality { world.quality(reduceMotion: reduceMotion) }
    private var shownTier: SceneRenderTier { world.shownTier(reduceMotion: reduceMotion) }

    /// The labelled 2D frame: an owned Blender render matched to the 3D camera, shown while the 3D street
    /// loads, when it is stepped down to the frame (heat, very slow frames) or when it failed to load.
    private var backdrop: some View {
        GeometryReader { geo in
            Group {
                if let box = world.streetScene {
                    // Apple's Maps logo and Look Around badge must stay fully visible: the photo ends above the
                    // footer pills (measured on the iPhone 17 simulator: the "Örnek beden" pill clipped it at 250).
                    VStack(spacing: 0) {
                        LookAroundPreview(scene: .constant(box.scene), allowsNavigation: false, showsRoadLabels: false,
                                          pointsOfInterest: .excludingAll, badgePosition: .bottomTrailing)
                            .frame(height: max(0, geo.size.height + geo.safeAreaInsets.top - 290))
                            .allowsHitTesting(false)
                        Atelier.canvas
                    }
                    .ignoresSafeArea()
                } else if let manifest = world.manifest {
                    if shownTier == .frame2D {
                        Image(world.sceneWeather.wetGround ? manifest.wetBackdrop : manifest.dryBackdrop)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .scaleEffect(CGFloat(zoom))
                            .clipped()
                    }
                } else {
                    LinearGradient(colors: [Atelier.surfaceSecondary, Atelier.sand], startPoint: .top, endPoint: .bottom)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    /// Scrims for legibility (v2.8 §04 contrast rule): text never sits on the bare scene. They lie over
    /// the 3D street too, but end above the figure's feet.
    private var scrims: some View {
        ZStack {
            // Spotlight falloff: the figure stays lit, the edges of the street sink a little.
            RadialGradient(colors: [.clear, .clear, Color(rgb: 0x120C08).opacity(0.38)], center: UnitPoint(x: 0.5, y: 0.52),
                           startRadius: 40, endRadius: 520)
            VStack(spacing: 0) {
            LinearGradient(colors: [Color(rgb: 0x221913).opacity(0.55), .clear], startPoint: .top, endPoint: .bottom).frame(height: 170)
            Spacer(minLength: 0)
            LinearGradient(stops: [.init(color: Atelier.canvas.opacity(0), location: 0), .init(color: Atelier.canvas.opacity(0.85), location: 0.6),
                                   .init(color: Atelier.canvas.opacity(0.97), location: 1)], startPoint: .top, endPoint: .bottom).frame(height: 210)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var stage: some View {
        if let mesh = model.heroMesh, let snapshot = model.heroSnapshot {
            DressedAvatarView(
                body3D: mesh, snapshot: snapshot, outfit: world.outfit, prewarm: world.looks?.looks.map(\.outfit) ?? [],
                light: world.streetScene != nil ? .day : light,
                rainIntensity: world.streetScene != nil ? 0 : world.sceneWeather.rainIntensity * quality.rainScale,
                alive: model.allowsLivelyMotion && !reduceMotion,
                selectedSlot: Binding(get: { world.selectedSlot }, set: { world.selectedSlot = $0 }),
                zoom: $zoom, yaw: $yaw,
                onTapSlot: { slot in
                    guard let slot else { world.selectedSlot = nil; return }
                    open(slot)
                },
                onSlotAction: { open($0) },
                city: world.manifest?.model3D,
                wetCity: world.sceneWeather.wetGround,
                showCity: quality.tier != .frame2D && world.streetScene == nil,
                cameraDrift: quality.cameraDrift && model.allowsLivelyMotion,
                spotlight: true,
                onFrameRate: { world.reportFrameRate($0) },
                onCityReady: { world.cityDidLoad($0) }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: Atelier.Space.s) {
                Text("Kabinsiz")
                    .font(.system(size: 34, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 6)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: Atelier.Space.s)
                ProfileButton(dark: true)
            }
            weatherChip
            if world.isExample {
                Text("Örnek kombin · sentetik")
                    .font(AtelierType.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
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
            HStack(spacing: 6) {
                Image(systemName: symbol(for: chip.state))
                Text(world.street?.city ?? world.city.displayName).fontWeight(.semibold)
                Text("·").opacity(0.7)
                Text(chip.weatherLine)
            }
            .font(.subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: Atelier.minTap)
            .background(.ultraThinMaterial.opacity(0.85), in: Capsule())
            .environment(\.colorScheme, .dark)
            .frame(minHeight: Atelier.minTap)
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
                RotateHint()
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Döndürmek için yana kaydır, değiştirmek için parçaya dokun")
            }
            // One primary action (v3.2 S02). Dene lives in its own tab.
            // v2.8 UI28-T018: no "Yeni kombin" when there is no other prepared look to show.
            HStack(spacing: 10) {
                if (world.looks?.looks.count ?? 0) > 1 {
                    Button { world.nextLook() } label: {
                        Label("Yeni kombin", systemImage: "sparkles").font(.headline).frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(CopperCapsuleStyle())
                    .accessibilityIdentifier("primary.newLook")
                }
                // The look's reason is one tap away instead of a sentence on the scene.
                if let look = world.currentLook {
                    Button { showWhy = true } label: {
                        Image(systemName: world.isLocked ? "lock.fill" : "info")
                            .font(.headline).foregroundStyle(Atelier.ink)
                            .frame(width: 54, height: 54)
                            .paperSurface(Circle())
                    }
                    .buttonStyle(AtelierPressStyle())
                    .accessibilityLabel("Neden bu kombin: \(reasonLine(look))")
                    .accessibilityIdentifier("worldReasonChip")
                }
            }
            Text(world.manifest == nil && world.streetScene == nil ? SceneQualityPolicy.studioLine : SceneQualityPolicy.truthLine(shownTier))
                .font(.caption2)
                .foregroundStyle(Atelier.inkSecondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("worldTruthLabel")
                .accessibilityValue(shownTier.rawValue)
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

extension GarmentSlotID: @retroactive Identifiable {
    public var id: String { rawValue }
}

private struct StreetRequest: Equatable {
    let id: String?
    let allowed: Bool
    let ready: Bool
}


/// "360°" with two arcs under the figure (visual reference 2), shown until the first turn.
struct RotateHint: View {
    var body: some View {
        ZStack {
            HStack(spacing: 96) {
                Image(systemName: "arrow.turn.left.down").rotationEffect(.degrees(-20))
                Image(systemName: "arrow.turn.right.down").rotationEffect(.degrees(20))
            }
            .font(.title3.weight(.light))
            Text("360°").font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.45), radius: 4)
        .padding(.vertical, 4)
    }
}

/// The profile entrance at the top right of each tab (v3.2: three tabs, "Ben" secondary).
struct ProfileButton: View {
    var dark = false
    @Environment(\.openProfile) private var openProfile

    var body: some View {
        Button { openProfile() } label: {
            Image(systemName: "person.crop.circle")
                .font(.title2)
                .foregroundStyle(dark ? .white : Atelier.ink)
                .frame(width: 44, height: 44)
                .background(dark ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.white.opacity(0.8)), in: Circle())
                .environment(\.colorScheme, dark ? .dark : .light)
        }
        .accessibilityLabel("Ben: modelim, stilim, verilerim")
        .accessibilityIdentifier("openProfile")
    }
}

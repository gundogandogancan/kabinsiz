import BackgroundTasks
import SwiftUI
import Vault

@main
struct KabinsizApp: App {
    @State private var model: AppModel = {
        // UI tests use their own vault directory and Keychain item, never the real ones. `-resetForUITest`
        // starts empty; `-uiTestVault <name>` reuses a named vault so a relaunch test can check persistence.
        let args = ProcessInfo.processInfo.arguments
        var name: String?
        if args.contains("-resetForUITest") { name = "reset-\(UUID().uuidString)" }
        if let i = args.firstIndex(of: "-uiTestVault"), i + 1 < args.count { name = args[i + 1] }
        if let name {
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent("kabinsiz-uitest-\(name)", isDirectory: true)
            return AppModel(location: VaultLocation(directory: dir, keyStore: KeychainKeyStore(account: name.hasPrefix("reset-") ? "kek.uitest.reset" : "kek.uitest.\(name)"), legacyDirectory: nil))
        }
        return AppModel()
    }()

    init() {
        MorningRefresh.shared.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .task { await model.load() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    MorningRefresh.shared.schedule()
                }
                .tint(Atelier.brand)
        }
    }
}

/// K-017 NativeTabScaffold (ADR-011, v2.8 ADR-UI28-NAV): `Bugün | Dolabım | Dene | Ben`. Bugün is the
/// living world; Dene is one journey for barcode/code, wardrobe and the live mirror (v2.6 "Tara ve
/// Dene"), so there is no separate scan tab or toolbar button. Each tab owns its NavigationStack, so
/// its route survives tab switches; the selected tab survives relaunch.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var world = HomeWorldModel()
    @State private var router = TryOnRouter()
    @State private var todayPath = NavigationPath()
    @SceneStorage("selectedTab") private var selected: AtelierTab = .today
    @State private var showProfile = false

    var body: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-componentCatalog") {
            NavigationStack { AtelierComponentCatalogView() }
        } else {
            tabs
        }
        #else
        tabs
        #endif
    }

    private var tabs: some View {
        TabView(selection: $selected) {
            Tab(AtelierTab.today.title, systemImage: AtelierTab.today.symbol, value: AtelierTab.today) {
                NavigationStack(path: $todayPath) {
                    HomeWorldView(onTryOn: { selected = .tryOn }, onOpenMe: { showProfile = true },
                                  onOpenWardrobe: { selected = .wardrobe }, onPlan: { todayPath.append(WorldRoute.plan) })
                }
            }
            Tab(AtelierTab.wardrobe.title, systemImage: AtelierTab.wardrobe.symbol, value: AtelierTab.wardrobe) { tab { WardrobeView() } }
            Tab(AtelierTab.tryOn.title, systemImage: AtelierTab.tryOn.symbol, value: AtelierTab.tryOn) {
                tab { TryOnHubView(onShowOnModel: { todayPath = NavigationPath(); selected = .today }) }
            }
        }
        // v3.2 / V32-UI-01: three tabs; "Ben" opens from the profile button at the top right.
        .fullScreenCover(isPresented: $showProfile) {
            NavigationStack {
                MyModelView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") { showProfile = false }.accessibilityIdentifier("profileClose")
                        }
                    }
            }
        }
        .onAppear { if selected == .me { selected = .today } }
        .environment(\.openProfile) { showProfile = true }
        .environment(\.worldPaused, showProfile || selected != .today)
        .environment(world)
        .environment(router)
        .environment(\.openScan) {
            selected = .tryOn
            router.pending = .code
        }
        .overlay(alignment: .top) {
            if let error = model.loadError {
                StatusBadge(text: error, tone: .error)
                    .padding(10)
                    .background(Atelier.surface, in: Capsule())
                    .padding(.top, 4)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .kabinsizDidDeleteAll)) { _ in world.forgetAll() }
        .onAppear {
            MorningRefresh.shared.prepare = { [world, model] in
                world.refresh(wardrobe: model.wardrobe, avatarRevision: model.heroIsStandIn ? "standin" : "body-\(model.body?.revision ?? 0)")
            }
        }
    }

    private func tab<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        NavigationStack { content() }
    }
}

extension EnvironmentValues {
    /// Opens "Ben" (model, style, data) from the profile button on any tab.
    @Entry var openProfile: @MainActor () -> Void = {}
    /// Opens Dene's code entry from any screen ("Ürünü Tara" buttons on older screens).
    @Entry var openScan: @MainActor () -> Void = {}
    /// True while the home world is out of sight (the profile cover is up, or another tab is
    /// chosen). Its stage then stops its frame work (`WorldStage.setPaused`).
    @Entry var worldPaused = false
}

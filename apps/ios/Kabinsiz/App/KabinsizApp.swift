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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .task { await model.load() }
                .tint(Atelier.brand)
        }
    }
}

/// K-017 NativeTabScaffold (v2.0 §06 P0): `Bugün | Dolabım | Ben`. "Tara" is not a tab: it is the same
/// toolbar action on every tab plus a visible button on Bugün. Each tab owns its NavigationStack, so
/// its route survives tab switches and the scan sheet; the selected tab survives relaunch.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var showScan = false
    @SceneStorage("selectedTab") private var selected: AtelierTab = .today

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
                tab { TodayView(onScan: { showScan = true }, onOpenWardrobe: { selected = .wardrobe }, onOpenMe: { selected = .me }) }
            }
            Tab(AtelierTab.wardrobe.title, systemImage: AtelierTab.wardrobe.symbol, value: AtelierTab.wardrobe) { tab { WardrobeView() } }
            Tab(AtelierTab.me.title, systemImage: AtelierTab.me.symbol, value: AtelierTab.me) { tab { MyModelView() } }
        }
        .environment(\.openScan) { showScan = true }
        .sheet(isPresented: $showScan) { ScanView() }
        .overlay(alignment: .top) {
            if let error = model.loadError {
                StatusBadge(text: error, tone: .error)
                    .padding(10)
                    .background(Atelier.surface, in: Capsule())
                    .padding(.top, 4)
            }
        }
    }

    private func tab<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        NavigationStack { content().scanAction() }
    }
}

extension EnvironmentValues {
    /// Opens the global "Tara" sheet from any screen of any tab.
    @Entry var openScan: @MainActor () -> Void = {}
}

/// The same "Tara" toolbar action on every screen, pushed ones included, so it is never more than one tap away.
private struct ScanToolbarAction: ViewModifier {
    @Environment(\.openScan) private var openScan

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { openScan() } label: { Label("Tara", systemImage: "barcode.viewfinder") }
                    .accessibilityIdentifier("scanButton")
            }
        }
    }
}

extension View {
    func scanAction() -> some View { modifier(ScanToolbarAction()) }
}

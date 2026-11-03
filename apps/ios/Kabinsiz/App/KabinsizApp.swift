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
                .tint(Token.brandInk)
        }
    }
}

/// 3 tabs + one global action (§4.2). "Tara" sits in the same toolbar spot on every tab.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var showScan = false

    var body: some View {
        TabView {
            Tab("Bugün", systemImage: "sun.max") { tab { TodayView() } }
            Tab("Dolabım", systemImage: "hanger") { tab { WardrobeView() } }
            Tab("Benim Modelim", systemImage: "person.crop.circle") { tab { MyModelView() } }
        }
        .sheet(isPresented: $showScan) { ScanView() }
        .overlay(alignment: .top) {
            if let error = model.loadError {
                StatusBadge(text: error, tone: .error)
                    .padding(10)
                    .background(Token.surfaceCard, in: Capsule())
                    .padding(.top, 4)
            }
        }
    }

    private func tab<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showScan = true } label: { Label("Tara", systemImage: "barcode.viewfinder") }
                            .accessibilityIdentifier("scanButton")
                    }
                }
        }
    }
}

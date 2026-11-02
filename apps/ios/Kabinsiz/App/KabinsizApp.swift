import LocalStore
import SwiftUI

@main
struct KabinsizApp: App {
    @State private var model: AppModel = {
        // UI tests start from an empty, throwaway store so they never touch real data.
        if ProcessInfo.processInfo.arguments.contains("-resetForUITest") {
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent("kabinsiz-uitest-\(UUID().uuidString)")
            return AppModel(store: try? LocalStore(directory: dir))
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

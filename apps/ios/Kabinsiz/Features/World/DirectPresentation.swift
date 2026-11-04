import QuartzCore
import RealityKit
import UIKit

/// Keeps every RealityKit Metal layer in the app's windows on direct presentation
/// (`presentsWithTransaction = false`).
///
/// Measured 2026-11-04 on the simulator (ADR-016 "Bilinen açık"):
/// - While the profile cover was up, the home `RealityView` stayed in the window behind it with
///   `presentsWithTransaction` on.
/// - The home world was paused and still, so no Core Animation commit came. Its frames were never
///   presented and its drawables ran out.
/// - RealityKit's render thread is shared by every 3D view. It waited in `nextDrawable`, and the main
///   thread waited on it (`waitForIdleInternal`, about 85% of samples).
/// - A slider in the profile got its touch-down and then no more events. Its thumb slid on screen,
///   but the value stayed at 82 cm.
///
/// `RealityView` does not expose its layer, so the window's layer tree is scanned (at most twice a
/// second) and the found layers are kept direct on every frame tick. A layer outside RealityKit is
/// never touched.
@MainActor
enum DirectPresentation {
    private static let layers = NSHashTable<CAMetalLayer>.weakObjects()
    private static var lastScan: CFTimeInterval = 0

    /// Called from each 3D stage's frame tick, paused or not.
    static func keep() {
        let now = CACurrentMediaTime()
        if now - lastScan > 0.5 {
            lastScan = now
            for scene in UIApplication.shared.connectedScenes {
                for window in (scene as? UIWindowScene)?.windows ?? [] { collect(window.layer, depth: 0) }
            }
        }
        for layer in layers.allObjects where layer.presentsWithTransaction {
            layer.presentsWithTransaction = false
        }
    }

    private static func collect(_ layer: CALayer, depth: Int) {
        if let metal = layer as? CAMetalLayer {
            if isRealityKit(metal) { layers.add(metal) }
            return
        }
        guard depth < 48 else { return }
        for sub in layer.sublayers ?? [] { collect(sub, depth: depth + 1) }
    }

    /// RealityKit draws through its own render view (`ARRenderView`) inside an `ARView` or a
    /// `RealityView`; the layer's owner, or one of its ancestors, says so.
    private static func isRealityKit(_ metal: CAMetalLayer) -> Bool {
        var view = metal.delegate as? UIView
        for _ in 0..<4 {
            guard let current = view else { return false }
            if current is ARView || NSStringFromClass(type(of: current)).contains("ARRenderView") { return true }
            view = current.superview
        }
        return false
    }
}

import Foundation
import Network
import Octopus
import UIKit

/// Feeds real iOS signals into the §113 governor. Only what iOS exposes: the coarse thermal state (never
/// degrees), Low Power Mode, memory warnings, protected-data availability, foreground/background, the
/// network path and free space for important usage. Battery monitoring stays off because no feature
/// needs it yet, so battery is `unavailable` and the policy treats it conservatively (drill 5).
@MainActor
final class DeviceSignalMonitor {
    let governor: DeviceResourceGovernor
    private let fault: DeviceFault?
    private var tokens: [NSObjectProtocol] = []
    private let path = NWPathMonitor()
    private var started = false

    init(governor: DeviceResourceGovernor, fault: DeviceFault? = DeviceFault.fromLaunchArguments()) {
        self.governor = governor
        self.fault = fault
    }

    func start() {
        guard !started else { return }
        started = true
        let center = NotificationCenter.default
        func on(_ name: Notification.Name, _ handle: @escaping @MainActor () -> Void) {
            tokens.append(center.addObserver(forName: name, object: nil, queue: .main) { _ in
                MainActor.assumeIsolated { handle() }
            })
        }
        on(ProcessInfo.thermalStateDidChangeNotification) { [weak self] in self?.refresh() }
        on(.NSProcessInfoPowerStateDidChange) { [weak self] in self?.refresh() }
        on(UIApplication.protectedDataWillBecomeUnavailableNotification) { [weak self] in self?.apply { $0.presence = .locked } }
        on(UIApplication.protectedDataDidBecomeAvailableNotification) { [weak self] in self?.refresh() }
        on(UIApplication.didEnterBackgroundNotification) { [weak self] in self?.refresh(background: true) }
        on(UIApplication.willEnterForegroundNotification) { [weak self] in self?.refresh() }
        on(UIApplication.didReceiveMemoryWarningNotification) { [weak self] in
            guard let governor = self?.governor else { return }
            Task { await governor.noteMemoryWarning() }
        }
        path.pathUpdateHandler = { [weak self] update in
            let reachable = update.status == .satisfied
            Task { @MainActor in self?.apply { $0.networkReachable = reachable } }
        }
        path.start(queue: DispatchQueue(label: "app.kabinsiz.network-path"))
        refresh()
        if fault == .memoryWarning { Task { await governor.noteMemoryWarning() } }
    }

    /// Re-reads everything iOS reports right now, then applies a test fault on top (DEBUG only).
    private func refresh(background: Bool = false) {
        let info = ProcessInfo.processInfo
        let app = UIApplication.shared
        apply { s in
            s.thermal = ThermalLevel(info.thermalState)
            s.lowPowerMode = info.isLowPowerModeEnabled
            if !app.isProtectedDataAvailable {
                s.presence = .locked
            } else {
                s.presence = background || app.applicationState == .background ? .background : .foreground
            }
            s.diskFreeBytes = EphemeralArea.systemFreeSpace(at: URL.cachesDirectory)
        }
    }

    private func apply(_ change: (inout DeviceSignals) -> Void) {
        let fault = fault
        governor.update { s in
            change(&s)
            fault?.impose(on: &s)
        }
    }
}

extension ThermalLevel {
    init(_ state: ProcessInfo.ThermalState) {
        switch state {
        case .nominal: self = .nominal
        case .fair: self = .fair
        case .serious: self = .serious
        case .critical: self = .critical
        // A state this build does not know is treated as hot, never as cool.
        @unknown default: self = .serious
        }
    }
}

/// Fault injection for UI tests and manual drills (`-deviceFault thermalCritical`). DEBUG builds only;
/// a release build ignores the argument.
enum DeviceFault: String {
    case thermalSerious, thermalCritical, memoryWarning, offline, lowPower

    static func fromLaunchArguments() -> DeviceFault? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-deviceFault"), i + 1 < args.count else { return nil }
        return DeviceFault(rawValue: args[i + 1])
        #else
        return nil
        #endif
    }

    func impose(on s: inout DeviceSignals) {
        switch self {
        case .thermalSerious: s.thermal = max(s.thermal, .serious)
        case .thermalCritical: s.thermal = .critical
        case .memoryWarning: break // sent as a warning at start, so it fades like a real one
        case .offline: s.networkReachable = false
        case .lowPower: s.lowPowerMode = true
        }
    }
}

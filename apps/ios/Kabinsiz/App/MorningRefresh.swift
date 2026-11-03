import BackgroundTasks
import Foundation
import os

/// v2.8 §05.7: an opportunistic app-refresh task that re-prepares today's looks while the app is
/// still in memory. iOS decides if and when it runs; there is no 06:00 guarantee, and the home
/// recomputes in the foreground whenever the cache does not match (WarmStart). A cold background
/// launch does not open the vault: with no prepared model in memory the task ends without work.
@MainActor
final class MorningRefresh {
    static let shared = MorningRefresh()
    static let identifier = "app.kabinsiz.ios.morning-refresh"
    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "morning")

    /// Set by the root view once the app model and the world exist.
    var prepare: (() -> Void)?
    private var registered = false

    func register() {
        guard !registered else { return }
        registered = BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.identifier, using: .main) { task in
            MainActor.assumeIsolated { MorningRefresh.shared.run(task) }
        }
    }

    /// Ask for a run after 05:00 tomorrow, device time. Only a request.
    func schedule(now: Date = Date()) {
        let request = BGAppRefreshTaskRequest(identifier: Self.identifier)
        var calendar = Calendar.current
        calendar.timeZone = .current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
        request.earliestBeginDate = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: tomorrow)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Self.log.info("morning refresh not scheduled: \(String(describing: error), privacy: .public)")
        }
    }

    private func run(_ task: BGTask) {
        schedule()
        guard let prepare else {
            task.setTaskCompleted(success: false)
            return
        }
        prepare()
        Self.log.info("morning refresh ran")
        task.setTaskCompleted(success: true)
    }
}

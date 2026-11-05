import Foundation

/// One Vision request at a time in the whole process.
///
/// Measured 2026-11-05 on macOS 26.4 (package tests): with several requests in flight at once, Vision
/// sometimes returned an empty result for an image it reads every time on its own (body pose on a
/// two-person photo gave "no person"), and person segmentation from the cooperative pool hung in
/// `VNControlledCapacityTasksQueue dispatchGroupWait`. A wrong empty read would turn into a wrong answer
/// ("nobody in the photo"), so every `perform` in the package goes through this lock. Readers stay
/// synchronous; async callers hop to their own queue first (`SelfModel.VisionLane`).
package enum VisionSerial {
    private static let lock = NSRecursiveLock()

    package static func run<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}

/// The queue every async caller hops to before a synchronous Vision read.
///
/// Measured 2026-11-05 (sample of a hung test process): text recognition and person segmentation wait on
/// a semaphore for work that runs on Swift's cooperative pool. When every pool thread is itself blocked
/// in a Vision call (or waiting for `VisionSerial`), that work never starts and the process hangs. So no
/// Vision read may block a pool thread: async code awaits this lane, whose thread is an ordinary
/// dispatch thread, and the pool stays free. The lane itself is concurrent: the pixel work around a
/// request runs side by side, and only the requests take turns (`VisionSerial`), so one long read does not
/// hold up another reader's deadline.
public enum VisionLane {
    static let queue = DispatchQueue(label: "app.kabinsiz.vision", qos: .userInitiated, attributes: .concurrent)

    public static func run<T: Sendable>(_ work: @escaping @Sendable () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { continuation.resume(with: Result { try work() }) }
        }
    }
}

import Foundation
import SystemContracts

/// §116.1 `DerivedEphemeral`: temporary crops, tensors and mesh scratch files. Bounded by a disk
/// reservation (drill 4, V15-T-DEV-06), swept at launch so a kill mid-import leaves no orphan plaintext
/// (drill 2), excluded from backup, and written with complete file protection on iOS.
public final class EphemeralArea: @unchecked Sendable {
    public struct Policy: Hashable, Sendable {
        /// Free space that must remain after a reservation, so the vault and the OS can still write.
        public var reserveFloorBytes: Int64
        /// When the OS does not report free space, only this much may be outstanding at once.
        public var unknownSpaceLimitBytes: Int64

        public init(reserveFloorBytes: Int64 = 512 * 1_024 * 1_024, unknownSpaceLimitBytes: Int64 = 16 * 1_024 * 1_024) {
            self.reserveFloorBytes = reserveFloorBytes
            self.unknownSpaceLimitBytes = unknownSpaceLimitBytes
        }
    }

    private let lock = NSLock()
    private let root: URL
    private let policy: Policy
    private let freeSpace: @Sendable () -> Int64?
    private var outstanding: [UUID: Int64] = [:]

    public init(root: URL, policy: Policy = Policy(), freeSpace: @escaping @Sendable () -> Int64?) throws(FaultCode) {
        self.root = root
        self.policy = policy
        self.freeSpace = freeSpace
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            var url = root
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try url.setResourceValues(values)
        } catch {
            throw .resourceDenied
        }
    }

    /// `volumeAvailableCapacityForImportantUsage` of the volume holding `url`, or nil.
    public static func systemFreeSpace(at url: URL) -> Int64? {
        #if os(iOS)
        let value = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage
        return value
        #else
        return (try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey]).volumeAvailableCapacity).map(Int64.init)
        #endif
    }

    public var outstandingBytes: Int64 { lock.withLock { outstanding.values.reduce(0, +) } }

    /// Deletes everything a previous process left behind. Call once at launch, before any reservation.
    @discardableResult
    public func sweepOrphans() -> Int {
        let fm = FileManager.default
        let items = (try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
        let live: Set<String> = lock.withLock { Set(outstanding.keys.map(\.uuidString)) }
        var removed = 0
        for item in items where !live.contains(item.lastPathComponent) {
            if (try? fm.removeItem(at: item)) != nil { removed += 1 }
        }
        return removed
    }

    /// Reserves room for one temporary file. Refuses with `RESOURCE_DENIED` (recoverable: the user can
    /// free space and retry) instead of filling the disk the vault needs.
    public func reserve(bytes: Int64) throws(FaultCode) -> EphemeralFile {
        guard bytes > 0 else { throw .schemaInvalid }
        let granted: UUID? = lock.withLock {
            let pending = outstanding.values.reduce(0, +)
            if let free = freeSpace() {
                guard free - pending - bytes >= policy.reserveFloorBytes else { return nil }
            } else {
                guard pending + bytes <= policy.unknownSpaceLimitBytes else { return nil }
            }
            let id = UUID()
            outstanding[id] = bytes
            return id
        }
        guard let id = granted else { throw .resourceDenied }
        return EphemeralFile(id: id, url: root.appendingPathComponent(id.uuidString), capacity: bytes, area: self)
    }

    fileprivate func finish(_ id: UUID) {
        _ = lock.withLock { outstanding.removeValue(forKey: id) }
    }
}

/// One reserved temporary file. Writes beyond the reservation are refused; `discard()` removes the
/// file and frees the reservation, and is safe to call more than once.
public final class EphemeralFile: @unchecked Sendable {
    public let url: URL
    public let capacity: Int64
    private let id: UUID
    private weak var area: EphemeralArea?
    private let lock = NSLock()
    private var discarded = false

    fileprivate init(id: UUID, url: URL, capacity: Int64, area: EphemeralArea) {
        self.id = id
        self.url = url
        self.capacity = capacity
        self.area = area
    }

    public func write(_ data: Data) throws(FaultCode) {
        guard lock.withLock({ !discarded }) else { throw .invalidTransition }
        guard Int64(data.count) <= capacity else { throw .resourceDenied }
        var options: Data.WritingOptions = [.atomic]
        #if os(iOS)
        options.insert(.completeFileProtection)
        #endif
        do { try data.write(to: url, options: options) } catch { throw .resourceDenied }
    }

    public func read() throws(FaultCode) -> Data {
        guard lock.withLock({ !discarded }) else { throw .invalidTransition }
        do { return try Data(contentsOf: url) } catch { throw .storageCorrupted }
    }

    public func discard() {
        let first: Bool = lock.withLock {
            defer { discarded = true }
            return !discarded
        }
        guard first else { return }
        try? FileManager.default.removeItem(at: url)
        area?.finish(id)
    }

    deinit { discard() }
}

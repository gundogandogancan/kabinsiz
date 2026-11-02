import Foundation

/// Versioned on-disk wrapper (ADR-002).
public struct Envelope<Payload: Codable & Sendable>: Codable, Sendable {
    public let schemaVersion: Int
    public let savedAt: Date
    public let payload: Payload
}

public enum LocalStoreError: Error, Equatable, Sendable {
    /// File was written by a newer app version. We refuse to read it instead of losing data.
    case newerSchema(found: Int, supported: Int)
    case corrupted(String)
}

/// One JSON file per collection under a private directory. Writes are serialised by the actor
/// and atomic on disk; on iOS the file is protected until first unlock.
public actor LocalStore {
    public nonisolated let directory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directory: URL) throws {
        self.directory = directory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        // Default (Double seconds) round-trips exactly; ISO-8601 drops sub-second precision.
        encoder.dateEncodingStrategy = .deferredToDate
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
    }

    /// Default app location: Application Support/Kabinsiz. Left in the encrypted device backup on purpose,
    /// because local-first must not mean data loss (§68); no iCloud sync.
    public static func applicationSupport() throws -> LocalStore {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return try LocalStore(directory: base.appendingPathComponent("Kabinsiz", isDirectory: true))
    }

    public func save<T: Codable & Sendable>(_ value: T, as collection: String, schemaVersion: Int) throws {
        let envelope = Envelope(schemaVersion: schemaVersion, savedAt: Date(), payload: value)
        let data = try encoder.encode(envelope)
        var options: Data.WritingOptions = [.atomic]
        #if os(iOS)
        options.insert(.completeFileProtectionUntilFirstUserAuthentication)
        #endif
        try data.write(to: url(for: collection), options: options)
    }

    /// Returns `nil` when nothing was saved yet. `migrate` receives older payloads as raw JSON.
    public func load<T: Codable & Sendable>(
        _ type: T.Type,
        from collection: String,
        currentVersion: Int,
        migrate: ((Int, Data) throws -> T)? = nil
    ) throws -> T? {
        let fileURL = url(for: collection)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        let header: VersionHeader
        do {
            header = try decoder.decode(VersionHeader.self, from: data)
        } catch {
            throw LocalStoreError.corrupted(collection)
        }
        if header.schemaVersion > currentVersion {
            throw LocalStoreError.newerSchema(found: header.schemaVersion, supported: currentVersion)
        }
        if header.schemaVersion < currentVersion {
            guard let migrate else { throw LocalStoreError.corrupted("\(collection): no migration from v\(header.schemaVersion)") }
            return try migrate(header.schemaVersion, data)
        }
        do {
            return try decoder.decode(Envelope<T>.self, from: data).payload
        } catch {
            throw LocalStoreError.corrupted(collection)
        }
    }

    public func delete(collection: String) throws {
        let fileURL = url(for: collection)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    public func exists(collection: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: collection).path)
    }

    private func url(for collection: String) -> URL {
        // Collection names are app constants; reject anything that could escape the directory.
        precondition(collection.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }, "invalid collection name")
        return directory.appendingPathComponent("\(collection).json")
    }

    private struct VersionHeader: Decodable { let schemaVersion: Int }
}

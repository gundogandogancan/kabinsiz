import CryptoKit
import Foundation
import SystemContracts

/// The encrypted private vault (§111, §116 `PrivateVault`).
///
/// Layout under `directory`:
/// - `keys.json`: key registry. Vault root wrapped by the Keychain KEK, one data key per domain wrapped by the root.
/// - `index.sealed`: live records, tombstones and active keys, sealed with the root key. Writing it commits a change.
/// - `records/<id>.<generation>.vrec`: one AES-GCM record each.
///
/// Every change writes new files first and the index last, so a crash at any point leaves either the
/// old or the new state; `open` sweeps what the index does not reference (V15-T-CRY-05).
public actor Vault {
    public nonisolated let directory: URL
    private let keyStore: any KeyStore
    private let clock: @Sendable () -> Date
    private var registry: KeyRegistry
    private var index: VaultIndex
    private let rootKey: SymmetricKey
    private let rootKeyID: UUID
    private var dataKeys: [UUID: SymmetricKey] = [:]
    /// Set by `close` and `deleteAll`. A closed instance refuses everything, so it can never write an
    /// index sealed with an old root into a directory that now holds a different vault.
    private var isClosed = false
    private let instanceToken: UUID

    /// Points where tests stop a rotation to simulate a crash.
    enum RotationStep: Sendable { case newKeyStored, recordsReencrypted, indexCommitted }
    var faultInjection: (@Sendable (RotationStep) throws -> Void)?

    private init(directory: URL, keyStore: any KeyStore, clock: @escaping @Sendable () -> Date,
                 registry: KeyRegistry, index: VaultIndex, rootKey: SymmetricKey, rootKeyID: UUID, token: UUID) {
        self.directory = directory
        instanceToken = token
        self.keyStore = keyStore
        self.clock = clock
        self.registry = registry
        self.index = index
        self.rootKey = rootKey
        self.rootKeyID = rootKeyID
    }

    deinit { Self.release(directory, token: instanceToken) }

    /// Ends this instance. Later calls throw `closed`; the directory may then be opened again.
    public func close() {
        isClosed = true
        Self.release(directory, token: instanceToken)
    }

    private func ensureOpen() throws { if isClosed { throw VaultError.closed } }

    // MARK: Open

    /// Opens or creates the vault. Never creates a new key over existing data: a missing or unreadable
    /// KEK with data present throws `keyUnavailable` and leaves every file as it is.
    public static func open(directory: URL, keyStore: any KeyStore, clock: @escaping @Sendable () -> Date = Date.init) throws -> Vault {
        // One live instance per directory: two would overwrite each other's index and sweep each other's files.
        let token = UUID()
        try reserve(directory, token: token)
        do {
            return try openReserved(directory: directory, keyStore: keyStore, clock: clock, token: token)
        } catch {
            release(directory, token: token)
            throw error
        }
    }

    private static func openReserved(directory: URL, keyStore: any KeyStore, clock: @escaping @Sendable () -> Date, token: UUID) throws -> Vault {
        let fm = FileManager.default
        purgeTrash(near: directory)
        let paths = Paths(directory)
        try fm.createDirectory(at: paths.records, withIntermediateDirectories: true)

        var registry: KeyRegistry
        let index: VaultIndex
        let root: SymmetricKey
        let rootID: UUID
        if !fm.fileExists(atPath: paths.keys.path) {
            // Records without keys are unreadable data: stop. An index without keys and without records is
            // the leftover of a first open that crashed before `keys.json` was written: start over.
            let leftovers = (try? fm.contentsOfDirectory(atPath: paths.records.path)) ?? []
            guard leftovers.isEmpty else { throw VaultError.corrupted("keys") }
            try? fm.removeItem(at: paths.index)
            let kek = VaultCrypto.newKey()
            try keyStore.writeKEK(kek)
            root = VaultCrypto.newKey()
            rootID = UUID()
            let draft = KeyRecord(keyID: rootID, purpose: KeyRecord.rootPurpose(), algorithm: VaultCrypto.algorithm, version: 1,
                                  createdAt: clock(), status: .active, wrapped: Data())
            let rootRecord = KeyRecord(keyID: rootID, purpose: draft.purpose, algorithm: draft.algorithm, version: 1, createdAt: draft.createdAt,
                                       status: .active, wrapped: try VaultCrypto.wrap(root, under: kek, record: draft.associatedData))
            registry = KeyRegistry(keys: [rootRecord])
            index = VaultIndex()
            // Index first, keys last: `keys.json` existing means the vault is complete.
            try write(try seal(index, root: root, rootID: rootID), to: paths.index)
            try write(try JSONEncoder.vault.encode(registry), to: paths.keys)
        } else {
            do { registry = try JSONDecoder.vault.decode(KeyRegistry.self, from: Data(contentsOf: paths.keys)) } catch {
                throw VaultError.corrupted("keys")
            }
            guard let kek = try keyStore.readKEK() else { throw VaultError.keyLost }
            guard let rootRecord = registry.root else { throw VaultError.corrupted("keys") }
            root = try VaultCrypto.unwrap(rootRecord, under: kek)
            rootID = rootRecord.keyID
            if let sealed = try? Data(contentsOf: paths.index) {
                index = try unseal(sealed, root: root, rootID: rootID)
            } else {
                // No index and no records: nothing can be lost by starting empty. With records, refuse.
                let leftovers = (try? fm.contentsOfDirectory(atPath: paths.records.path)) ?? []
                guard leftovers.isEmpty else { throw VaultError.corrupted("index") }
                index = VaultIndex()
                try write(try seal(index, root: root, rootID: rootID), to: paths.index)
            }
        }

        if recoverRegistry(&registry, index: index) { try write(try JSONEncoder.vault.encode(registry), to: paths.keys) }
        sweepRecordFiles(paths: paths, index: index)
        return Vault(directory: directory, keyStore: keyStore, clock: clock, registry: registry, index: index,
                     rootKey: root, rootKeyID: rootID, token: token)
    }

    /// Default app location: Application Support/KabinsizVault, protected `complete` (§111.2).
    public static func applicationSupport(keyStore: any KeyStore = KeychainKeyStore()) throws -> Vault {
        try open(directory: defaultDirectory(), keyStore: keyStore)
    }

    public static func defaultDirectory() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return base.appendingPathComponent("KabinsizVault", isDirectory: true)
    }

    // MARK: Read / write

    public func put<T: Encodable>(_ value: T, _ spec: VaultRecordSpec, schemaVersion: Int) throws {
        try ensureOpen()
        guard VaultRecordSpec.isValidIdentifier(spec.id), VaultRecordSpec.isValidIdentifier(spec.type),
              spec.derivedFrom.allSatisfy(VaultRecordSpec.isValidIdentifier), !spec.derivedFrom.contains(spec.id), schemaVersion >= 1
        else { throw VaultError.invalidIdentifier }
        // A derived record must hang off live sources, or it would escape the deletion cascade (V15-T-CRY-10).
        guard spec.derivedFrom.allSatisfy(contains) else { throw VaultError.missingSource }
        let plaintext = try JSONEncoder.vault.encode(value)
        // V15-T-SEC-09: protected-trait keys never reach storage, whoever produced them.
        guard SensitiveAttributeGuard.violations(inJSON: plaintext).isEmpty else { throw VaultError.policy(.policyDenied) }

        let (keyID, key) = try activeDataKey(for: spec.domain)
        let previous = index.records[spec.id]
        let entry = VaultIndex.Entry(type: spec.type, domain: spec.domain, classification: spec.classification, schemaVersion: schemaVersion,
                                     generation: (previous?.generation ?? 0) + 1, keyID: keyID, deleted: false, derivedFrom: spec.derivedFrom)
        try writeRecord(spec.id, entry: entry, key: key, plaintext: plaintext)
        var next = index
        next.records[spec.id] = entry
        next.activeKeys[spec.domain] = keyID
        try commit(next)
        try promoteIfPending(keyID)
        if let previous, !previous.deleted { removeFile(spec.id, generation: previous.generation) }
    }

    /// `nil` when nothing was stored or the record was deleted. `migrate` gets older payloads as raw JSON.
    public func get<T: Decodable>(_ type: T.Type, id: String, currentVersion: Int, migrate: ((Int, Data) throws -> T)? = nil) throws -> T? {
        try ensureOpen()
        guard VaultRecordSpec.isValidIdentifier(id) else { throw VaultError.invalidIdentifier }
        guard let entry = index.records[id], !entry.deleted else { return nil }
        let plaintext = try readPlaintext(id, entry: entry)
        if entry.schemaVersion > currentVersion { throw VaultError.newerSchema(found: entry.schemaVersion, supported: currentVersion) }
        if entry.schemaVersion < currentVersion {
            guard let migrate else { throw VaultError.corrupted("\(entry.type): no migration from v\(entry.schemaVersion)") }
            return try migrate(entry.schemaVersion, plaintext)
        }
        do { return try JSONDecoder.vault.decode(T.self, from: plaintext) } catch { throw VaultError.corrupted(entry.type) }
    }

    public func contains(_ id: String) -> Bool { index.records[id].map { !$0.deleted } ?? false }

    /// Live record count per type, for the privacy screen. Types only, no IDs.
    public func countsByType() -> [String: Int] {
        index.records.values.filter { !$0.deleted }.reduce(into: [:]) { $0[$1.type, default: 0] += 1 }
    }

    // MARK: Delete

    /// Deletes one record and everything derived from it, leaving tombstones (V15-T-SEC-10).
    @discardableResult
    public func delete(_ id: String) throws -> DeletionReceipt {
        try ensureOpen()
        guard VaultRecordSpec.isValidIdentifier(id) else { throw VaultError.invalidIdentifier }
        return try tombstone(cascade(from: [id]), scope: .record, destroying: [])
    }

    /// Deletes a whole domain, its derived records elsewhere, and its data key (crypto-shredding).
    @discardableResult
    public func deleteDomain(_ domain: VaultDomain) throws -> DeletionReceipt {
        try ensureOpen()
        let roots = index.records.filter { !$0.value.deleted && $0.value.domain == domain }.map(\.key)
        let keys = registry.keys.filter { $0.purpose == KeyRecord.dekPurpose(domain) }.map(\.keyID)
        return try tombstone(cascade(from: Set(roots)), scope: .domain, destroying: Set(keys), domain: domain)
    }

    /// Erases everything, including the Keychain KEK, then starts an empty vault with new keys.
    /// The directory is first renamed away in one step, so a crash leaves either all or nothing.
    public func deleteAll() throws -> (receipt: DeletionReceipt, fresh: Vault) {
        try ensureOpen()
        let counts = countsByType()
        let destroyed = registry.keys.count + 1
        // This instance is finished whatever happens next; only the returned one may touch the directory.
        close()
        try Self.destroy(directory: directory, keyStore: keyStore)
        let receipt = DeletionReceipt(completedAt: clock(), scope: .everything, deletedCountsByType: counts, destroyedKeyCount: destroyed)
        return (receipt, try Self.open(directory: directory, keyStore: keyStore, clock: clock))
    }

    /// Works without a readable key, so a vault whose KEK was lost can still be reset by the user.
    public static func destroy(directory: URL, keyStore: any KeyStore) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: directory.path) {
            let trash = directory.deletingLastPathComponent().appendingPathComponent(".\(directory.lastPathComponent)-trash-\(UUID().uuidString)")
            try fm.moveItem(at: directory, to: trash)
            try? fm.removeItem(at: trash)
        }
        try keyStore.deleteKEK()
    }

    // MARK: Rotation

    /// Re-encrypts one domain under a new data key: new key stored → records re-encrypted and verified
    /// → index commit moves the active pointer → old key and files removed (§111.2).
    public func rotateKey(_ domain: VaultDomain) throws {
        try ensureOpen()
        guard let oldID = index.activeKeys[domain] else { return }
        let (newID, newKey) = try createDataKey(for: domain)
        try faultInjection?(.newKeyStored)
        var next = index
        var superseded: [(String, Int)] = []
        for id in index.liveRecordIDs {
            guard let entry = index.records[id], entry.domain == domain, entry.keyID == oldID else { continue }
            let plaintext = try readPlaintext(id, entry: entry)
            var moved = entry
            moved.generation += 1
            moved.keyID = newID
            try writeRecord(id, entry: moved, key: newKey, plaintext: plaintext)
            guard try readPlaintext(id, entry: moved) == plaintext else { throw VaultError.integrityFailure(entry.type) }
            next.records[id] = moved
            superseded.append((id, entry.generation))
        }
        try faultInjection?(.recordsReencrypted)
        next.activeKeys[domain] = newID
        try commit(next)
        try faultInjection?(.indexCommitted)
        registry.keys.removeAll { $0.keyID == oldID }
        dataKeys[oldID] = nil
        try promoteIfPending(newID)
        for (id, generation) in superseded { removeFile(id, generation: generation) }
    }

    /// Key metadata for diagnostics: IDs, purpose, algorithm, status. Never key bytes (§111.2).
    public func keyInventory() -> [String] { registry.keys.map(\.description) }

    // MARK: Internals

    private func cascade(from roots: Set<String>) -> Set<String> {
        var result = Set(roots.filter { index.records[$0].map { !$0.deleted } ?? false })
        var changed = true
        while changed {
            changed = false
            for (id, entry) in index.records where !entry.deleted && !result.contains(id) && !result.isDisjoint(with: entry.derivedFrom) {
                result.insert(id)
                changed = true
            }
        }
        return result
    }

    private func tombstone(_ ids: Set<String>, scope: DeletionReceipt.Scope, destroying keys: Set<UUID>, domain: VaultDomain? = nil) throws -> DeletionReceipt {
        var next = index
        var counts: [String: Int] = [:]
        var removed: [(String, Int)] = []
        for id in ids {
            guard var entry = next.records[id] else { continue }
            counts[entry.type, default: 0] += 1
            removed.append((id, entry.generation))
            entry.generation += 1
            entry.deleted = true
            entry.keyID = nil
            next.records[id] = entry
        }
        if let domain { next.activeKeys[domain] = nil }
        try commit(next)
        if !keys.isEmpty {
            registry.keys.removeAll { keys.contains($0.keyID) }
            for key in keys { dataKeys[key] = nil }
            try Self.write(try JSONEncoder.vault.encode(registry), to: paths.keys)
        }
        for (id, generation) in removed { removeFile(id, generation: generation) }
        return DeletionReceipt(completedAt: clock(), scope: scope, deletedCountsByType: counts, destroyedKeyCount: keys.count)
    }

    private var paths: Paths { Paths(directory) }

    private func activeDataKey(for domain: VaultDomain) throws -> (UUID, SymmetricKey) {
        if let id = index.activeKeys[domain] { return (id, try dataKey(id)) }
        return try createDataKey(for: domain)
    }

    /// Stores the new key as PENDING before anything uses it; recovery drops it if no commit follows.
    private func createDataKey(for domain: VaultDomain) throws -> (UUID, SymmetricKey) {
        let key = VaultCrypto.newKey()
        let id = UUID()
        let draft = KeyRecord(keyID: id, purpose: KeyRecord.dekPurpose(domain), algorithm: VaultCrypto.algorithm, version: 1,
                              createdAt: clock(), status: .pending, wrapped: Data())
        let record = KeyRecord(keyID: id, purpose: draft.purpose, algorithm: draft.algorithm, version: 1, createdAt: draft.createdAt,
                               status: .pending, wrapped: try VaultCrypto.wrap(key, under: rootKey, record: draft.associatedData))
        registry.keys.append(record)
        try Self.write(try JSONEncoder.vault.encode(registry), to: paths.keys)
        dataKeys[id] = key
        return (id, key)
    }

    private func promoteIfPending(_ id: UUID) throws {
        guard let i = registry.keys.firstIndex(where: { $0.keyID == id }), registry.keys[i].status == .pending else { return }
        registry.keys[i].status = .active
        try Self.write(try JSONEncoder.vault.encode(registry), to: paths.keys)
    }

    private func dataKey(_ id: UUID) throws -> SymmetricKey {
        if let cached = dataKeys[id] { return cached }
        guard let record = registry.record(id), record.purpose.hasPrefix("DEK:") else { throw VaultError.integrityFailure("key") }
        let key = try VaultCrypto.unwrap(record, under: rootKey)
        dataKeys[id] = key
        return key
    }

    private func writeRecord(_ id: String, entry: VaultIndex.Entry, key: SymmetricKey, plaintext: Data) throws {
        guard let keyID = entry.keyID else { throw VaultError.corrupted(entry.type) }
        let box = try VaultCrypto.seal(plaintext, key: key, aad: VaultCrypto.recordAAD(id: id, entry: entry, keyID: keyID))
        let record = VaultRecordV1(recordID: id, recordType: entry.type, schemaVersion: entry.schemaVersion, classification: entry.classification,
                                   domain: entry.domain, keyID: keyID, generation: entry.generation,
                                   nonce: Data(box.nonce), ciphertext: box.ciphertext, tag: box.tag)
        try Self.write(try JSONEncoder.vault.encode(record), to: paths.record(id, generation: entry.generation))
    }

    private func readPlaintext(_ id: String, entry: VaultIndex.Entry) throws -> Data {
        guard let keyID = entry.keyID else { throw VaultError.corrupted(entry.type) }
        let record: VaultRecordV1
        do {
            record = try JSONDecoder.vault.decode(VaultRecordV1.self, from: Data(contentsOf: paths.record(id, generation: entry.generation)))
        } catch {
            throw VaultError.corrupted(entry.type)
        }
        let box: AES.GCM.SealedBox
        do {
            box = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: record.nonce), ciphertext: record.ciphertext, tag: record.tag)
        } catch {
            throw VaultError.integrityFailure(entry.type)
        }
        // AAD comes from the sealed index, not from the file, so a file copied into another slot fails (V15-T-CRY-02).
        return try VaultCrypto.open(box, key: dataKey(keyID), aad: VaultCrypto.recordAAD(id: id, entry: entry, keyID: keyID), what: entry.type)
    }

    private func commit(_ next: VaultIndex) throws {
        var next = next
        next.sequence = index.sequence + 1
        try Self.write(try Self.seal(next, root: rootKey, rootID: rootKeyID), to: paths.index)
        index = next
    }

    private func removeFile(_ id: String, generation: Int) {
        try? FileManager.default.removeItem(at: paths.record(id, generation: generation))
    }

    // MARK: Static helpers

    struct Paths {
        let keys: URL, index: URL, records: URL
        init(_ directory: URL) {
            keys = directory.appendingPathComponent("keys.json")
            index = directory.appendingPathComponent("index.sealed")
            records = directory.appendingPathComponent("records", isDirectory: true)
        }
        func record(_ id: String, generation: Int) -> URL { records.appendingPathComponent("\(id).\(generation).vrec") }
    }

    static func seal(_ index: VaultIndex, root: SymmetricKey, rootID: UUID) throws -> Data {
        let box = try VaultCrypto.seal(try JSONEncoder.vault.encode(index), key: root, aad: VaultCrypto.indexAAD(rootKeyID: rootID))
        guard let combined = box.combined else { throw VaultError.corrupted("index") }
        return combined
    }

    static func unseal(_ data: Data, root: SymmetricKey, rootID: UUID) throws -> VaultIndex {
        let box: AES.GCM.SealedBox
        do { box = try AES.GCM.SealedBox(combined: data) } catch { throw VaultError.integrityFailure("index") }
        let plaintext = try VaultCrypto.open(box, key: root, aad: VaultCrypto.indexAAD(rootKeyID: rootID), what: "index")
        do { return try JSONDecoder.vault.decode(VaultIndex.self, from: plaintext) } catch { throw VaultError.corrupted("index") }
    }

    /// Drops data keys the index does not use (an interrupted creation or a finished rotation) and marks
    /// the ones it uses active. Returns whether anything changed.
    static func recoverRegistry(_ registry: inout KeyRegistry, index: VaultIndex) -> Bool {
        let used = Set(index.activeKeys.values).union(index.records.values.compactMap { $0.deleted ? nil : $0.keyID })
        let before = registry.keys
        registry.keys = registry.keys.compactMap { record in
            guard record.purpose.hasPrefix("DEK:") else { return record }
            guard used.contains(record.keyID) else { return nil }
            var kept = record
            kept.status = .active
            return kept
        }
        return registry.keys != before
    }

    /// Removes record files the index does not point at: leftovers of crashes, old generations, deleted records.
    static func sweepRecordFiles(paths: Paths, index: VaultIndex) {
        let fm = FileManager.default
        guard let names = try? fm.contentsOfDirectory(atPath: paths.records.path) else { return }
        for name in names {
            let parts = name.split(separator: ".")
            let keep = parts.count == 3 && parts[2] == "vrec" && Int(parts[1]).map { generation in
                index.records[String(parts[0])].map { !$0.deleted && $0.generation == generation } ?? false
            } ?? false
            if !keep { try? fm.removeItem(at: paths.records.appendingPathComponent(name)) }
        }
    }

    static func purgeTrash(near directory: URL) {
        let parent = directory.deletingLastPathComponent()
        let prefix = ".\(directory.lastPathComponent)-trash-"
        for name in (try? FileManager.default.contentsOfDirectory(atPath: parent.path)) ?? [] where name.hasPrefix(prefix) {
            try? FileManager.default.removeItem(at: parent.appendingPathComponent(name))
        }
    }

    /// Atomic replace, then F_FULLFSYNC on the file and its directory, so the "records first, index last"
    /// order also holds across power loss, not only across an app crash.
    static func write(_ data: Data, to url: URL) throws {
        var options: Data.WritingOptions = [.atomic]
        #if os(iOS)
        options.insert(.completeFileProtection)
        #endif
        try data.write(to: url, options: options)
        fullSync(url)
        fullSync(url.deletingLastPathComponent())
    }

    private static func fullSync(_ url: URL) {
        let fd = Darwin.open(url.path, O_RDONLY)
        guard fd >= 0 else { return }
        defer { Darwin.close(fd) }
        if fcntl(fd, F_FULLFSYNC) != 0 { fsync(fd) }
    }

    // MARK: One instance per directory

    private static let openLock = NSLock()
    nonisolated(unsafe) private static var openInstances: [String: UUID] = [:]

    private static func reserve(_ directory: URL, token: UUID) throws {
        let key = directory.standardizedFileURL.path
        try openLock.withLock {
            guard openInstances[key] == nil else { throw VaultError.alreadyOpen }
            openInstances[key] = token
        }
    }

    private static func release(_ directory: URL, token: UUID) {
        let key = directory.standardizedFileURL.path
        openLock.withLock { if openInstances[key] == token { openInstances[key] = nil } }
    }
}

extension JSONEncoder {
    /// Same settings as `LocalStore`, so payload JSON is byte-compatible: sorted keys, Double dates.
    static var vault: JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        e.dateEncodingStrategy = .deferredToDate
        return e
    }
}

extension JSONDecoder {
    static var vault: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .deferredToDate
        return d
    }
}

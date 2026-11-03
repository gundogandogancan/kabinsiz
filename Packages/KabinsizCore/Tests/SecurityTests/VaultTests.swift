import CryptoKit
import FitPassport
import Foundation
import LocalStore
import SystemContracts
import Testing
import TravelEngine
import WardrobeDomain
@testable import Vault

/// V15-T-CRY suite and SEC-10 for WP15-04. All keys come from `EphemeralKeyStore`; the Keychain store is
/// exercised on the simulator (docs/evidence/WP15-04.yaml).
@Suite("Encrypted vault")
struct VaultTests {
    struct Measurements: Codable, Equatable { var chestCm: Double; var waistCm: Double }
    struct AvatarCache: Codable, Equatable { var bodyRevision: Int; var meshHash: String }

    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("vault-test-\(UUID().uuidString)", isDirectory: true)
    let keys = EphemeralKeyStore()

    func open() throws -> Vault { try Vault.open(directory: dir, keyStore: keys) }

    static let body = VaultRecordSpec(id: "measurements", type: "measurements", domain: .body)
    static let avatar = VaultRecordSpec(id: "avatar-cache", type: "avatar-cache", domain: .body, derivedFrom: ["measurements"])
    static let wardrobe = VaultRecordSpec(id: "wardrobe", type: "wardrobe", domain: .wardrobe)

    func recordFiles() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: dir.appendingPathComponent("records"), includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "vrec" }
    }

    func file(for id: String) throws -> URL {
        try #require(recordFiles().first { $0.lastPathComponent.hasPrefix("\(id).") })
    }

    // MARK: Basics

    @Test("Round trip survives reopening; no plaintext anywhere on disk")
    func roundTripAndNoPlaintext() async throws {
        let vault = try open()
        let secret = Measurements(chestCm: 97.25, waistCm: 81.5)
        try await vault.put(secret, Self.body, schemaVersion: 1)
        try await vault.put(SyntheticCloset.demo, Self.wardrobe, schemaVersion: Wardrobe.schemaVersion)
        await vault.close()

        let reopened = try open()
        #expect(try await reopened.get(Measurements.self, id: "measurements", currentVersion: 1) == secret)
        #expect(try await reopened.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == SyntheticCloset.demo)

        let needles = ["81.5", "97.25", "waistCm", SyntheticCloset.demo.garments[0].name]
        let everything = try FileManager.default.subpathsOfDirectory(atPath: dir.path).compactMap { try? Data(contentsOf: dir.appendingPathComponent($0)) }
        for blob in everything {
            for needle in needles { #expect(blob.range(of: Data(needle.utf8)) == nil, "plaintext \(needle) on disk") }
        }
    }

    @Test("Newer schema is refused instead of misread; older needs a migration")
    func schemaVersions() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 1, waistCm: 2), Self.body, schemaVersion: 3)
        await #expect(throws: VaultError.newerSchema(found: 3, supported: 2)) {
            try await vault.get(Measurements.self, id: "measurements", currentVersion: 2)
        }
        let migrated = try await vault.get(Measurements.self, id: "measurements", currentVersion: 4) { version, raw in
            #expect(version == 3)
            return try JSONDecoder().decode(Measurements.self, from: raw)
        }
        #expect(migrated == Measurements(chestCm: 1, waistCm: 2))
    }

    @Test("Identifiers that could escape the directory or break the AAD are refused")
    func identifiers() async throws {
        let vault = try open()
        for bad in ["../x", "a|b", "a.b", "", String(repeating: "a", count: 129), "ç"] {
            await #expect(throws: VaultError.invalidIdentifier, "\(bad)") {
                try await vault.put(1, VaultRecordSpec(id: bad, type: "x", domain: .preferences), schemaVersion: 1)
            }
        }
    }

    // MARK: V15-T-CRY

    @Test("V15-T-CRY-01: one flipped ciphertext bit fails authentication; no plaintext is returned")
    func tamperedCiphertext() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        let url = try file(for: "measurements")
        var record = try JSONDecoder.vault.decode(VaultRecordV1.self, from: Data(contentsOf: url))
        var bytes = record.ciphertext
        bytes[bytes.startIndex] ^= 0x01
        record = VaultRecordV1(recordID: record.recordID, recordType: record.recordType, schemaVersion: record.schemaVersion,
                               classification: record.classification, domain: record.domain, keyID: record.keyID,
                               generation: record.generation, nonce: record.nonce, ciphertext: bytes, tag: record.tag)
        try JSONEncoder.vault.encode(record).write(to: url)
        await #expect(throws: VaultError.integrityFailure("measurements")) {
            try await vault.get(Measurements.self, id: "measurements", currentVersion: 1)
        }
    }

    @Test("V15-T-CRY-01: a tampered index or key registry fails closed")
    func tamperedIndexAndKeys() async throws {
        do {
            let vault = try open()
            try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
            await vault.close()
        }
        let indexURL = dir.appendingPathComponent("index.sealed")
        var index = try Data(contentsOf: indexURL)
        index[index.count - 1] ^= 0x80
        try index.write(to: indexURL)
        #expect(throws: VaultError.integrityFailure("index")) { try open() }
    }

    @Test("V15-T-CRY-02: a record copied into another record's slot is rejected (AAD binds ID and type)")
    func swappedRecords() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        try await vault.put(Measurements(chestCm: 1, waistCm: 1), VaultRecordSpec(id: "measurements-old", type: "measurements", domain: .body), schemaVersion: 1)
        // Same domain, same key, same generation: only the AAD tells them apart.
        try Data(contentsOf: file(for: "measurements-old")).write(to: file(for: "measurements"))
        await #expect(throws: VaultError.integrityFailure("measurements")) {
            try await vault.get(Measurements.self, id: "measurements", currentVersion: 1)
        }
    }

    @Test("V15-T-CRY-03: every encryption uses a fresh nonce")
    func uniqueNonces() async throws {
        let vault = try open()
        var nonces = Set<Data>()
        var ciphertexts = Set<Data>()
        for i in 0..<300 {
            let spec = VaultRecordSpec(id: "n\(i % 3)", type: "probe", domain: .preferences)
            try await vault.put("same plaintext", spec, schemaVersion: 1)
            let record = try JSONDecoder.vault.decode(VaultRecordV1.self, from: Data(contentsOf: file(for: spec.id)))
            nonces.insert(record.nonce)
            ciphertexts.insert(record.ciphertext)
        }
        #expect(nonces.count == 300)
        #expect(ciphertexts.count == 300, "identical plaintext never yields identical ciphertext")
        let key = SymmetricKey(size: .bits256)
        let raw = (0..<1_000).map { _ in Data(try! VaultCrypto.seal(Data("x".utf8), key: key, aad: Data()).nonce) }
        #expect(Set(raw).count == 1_000)
    }

    @Test("V15-T-CRY-04: after rotation the retired key is gone; a restored old record cannot be read")
    func wrongKeyAfterRotation() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        let oldFile = try file(for: "measurements")
        let oldBytes = try Data(contentsOf: oldFile)
        let oldBodyKeys = await vault.keyInventory().filter { $0.contains("DEK:BODY") }
        #expect(oldBodyKeys.count == 1)
        try await vault.rotateKey(.body)
        let after = await vault.keyInventory()
        #expect(after.filter { $0.contains("DEK:BODY") }.count == 1)
        #expect(!after.contains(oldBodyKeys[0]), "the pre-rotation key must be gone, not just joined by a new one")
        #expect(try await vault.get(Measurements.self, id: "measurements", currentVersion: 1) == Measurements(chestCm: 97, waistCm: 81))

        // Put the pre-rotation file back under the current generation's name: its key no longer exists.
        let current = try file(for: "measurements")
        try oldBytes.write(to: current)
        await #expect(throws: VaultError.integrityFailure("measurements")) {
            try await vault.get(Measurements.self, id: "measurements", currentVersion: 1)
        }
    }

    @Test("V15-T-CRY-04: a different or missing KEK never yields data and never replaces the key")
    func wrongKEK() async throws {
        do {
            let vault = try open()
            try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
            await vault.close()
        }
        let original = try #require(try keys.readKEK())
        try keys.writeKEK(SymmetricKey(size: .bits256))
        #expect(throws: VaultError.integrityFailure("key")) { try open() }
        try keys.deleteKEK()
        #expect(throws: VaultError.keyLost) { try open() }
        #expect(try keys.readKEK() == nil, "opening must not mint a new KEK over existing data")
        try keys.writeKEK(original)
        #expect(try await open().get(Measurements.self, id: "measurements", currentVersion: 1) == Measurements(chestCm: 97, waistCm: 81))
    }

    @Test("V15-T-CRY-06 (logic only): a locked key store fails closed without touching files; device proof is REAL_DEVICE_BLOCKED")
    func lockedKeyStore() async throws {
        do {
            let vault = try open()
            try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
            await vault.close()
        }
        let before = try recordFiles().map(\.lastPathComponent)
        keys.setLocked(true)
        #expect(throws: VaultError.keyUnavailable) { try open() }
        #expect(try recordFiles().map(\.lastPathComponent) == before)
        keys.setLocked(false)
        #expect(try await open().contains("measurements"))
    }

    @Test("V15-T-CRY-05: a rotation interrupted at any step reopens as a coherent old or new vault", arguments: [
        Vault.RotationStep.newKeyStored, .recordsReencrypted, .indexCommitted,
    ])
    func interruptedRotation(step: Vault.RotationStep) async throws {
        struct Crash: Error {}
        let vault = try open()
        let values = (0..<5).map { Measurements(chestCm: Double(90 + $0), waistCm: Double(70 + $0)) }
        for (i, v) in values.enumerated() {
            try await vault.put(v, VaultRecordSpec(id: "m\(i)", type: "measurements", domain: .body), schemaVersion: 1)
        }
        try await vault.put(SyntheticCloset.demo, Self.wardrobe, schemaVersion: Wardrobe.schemaVersion)
        let oldKeys = await vault.keyInventory()
        await vault.setFaultInjection { if $0 == step { throw Crash() } }
        await #expect(throws: Crash.self) { try await vault.rotateKey(.body) }
        await vault.close()

        let recovered = try open()
        for (i, v) in values.enumerated() {
            #expect(try await recovered.get(Measurements.self, id: "m\(i)", currentVersion: 1) == v)
        }
        #expect(try await recovered.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == SyntheticCloset.demo)
        let keysNow = await recovered.keyInventory()
        #expect(keysNow.count == oldKeys.count, "exactly one body key survives: \(keysNow)")
        if step == .indexCommitted { #expect(keysNow != oldKeys, "commit happened: new key is active") } else { #expect(keysNow == oldKeys) }
        #expect(try recordFiles().count == 6, "orphans swept")
        // And the recovered vault can rotate cleanly afterwards.
        try await recovered.rotateKey(.body)
        #expect(try await recovered.get(Measurements.self, id: "m4", currentVersion: 1) == values[4])
    }

    @Test("V15-T-CRY-10: deleting the body profile removes derived private caches; other domains stay")
    func deleteBodyCascades() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        try await vault.put(AvatarCache(bodyRevision: 3, meshHash: "abc"), Self.avatar, schemaVersion: 1)
        try await vault.put(1, VaultRecordSpec(id: "fit-hint", type: "fit-hint", domain: .preferences, derivedFrom: ["avatar-cache"]), schemaVersion: 1)
        try await vault.put(SyntheticCloset.demo, Self.wardrobe, schemaVersion: Wardrobe.schemaVersion)

        let receipt = try await vault.deleteDomain(.body)
        #expect(receipt.deletedCountsByType == ["measurements": 1, "avatar-cache": 1, "fit-hint": 1])
        #expect(receipt.destroyedKeyCount == 1)
        #expect(receipt.unresolvedCopies == DeletionReceipt.UnresolvedCopy.allCases)
        try receipt.validate()
        #expect(try await vault.get(AvatarCache.self, id: "avatar-cache", currentVersion: 1) == nil)
        #expect(try await vault.get(Int.self, id: "fit-hint", currentVersion: 1) == nil)
        #expect(try await vault.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == SyntheticCloset.demo)
        #expect(!(await vault.keyInventory()).contains { $0.contains("DEK:BODY") }, "body key crypto-shredded")
        #expect(try recordFiles().count == 1)
    }

    @Test("V15-T-SEC-10: a deleted avatar cache restored from an old copy does not come back")
    func tombstonePreventsResurrection() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        try await vault.put(AvatarCache(bodyRevision: 3, meshHash: "abc"), Self.avatar, schemaVersion: 1)
        let url = try file(for: "avatar-cache")
        let copy = try Data(contentsOf: url)
        let receipt = try await vault.delete("avatar-cache")
        #expect(receipt.deletedCountsByType == ["avatar-cache": 1])
        try copy.write(to: url)

        #expect(try await vault.get(AvatarCache.self, id: "avatar-cache", currentVersion: 1) == nil)
        await vault.close()
        let reopened = try open()
        #expect(try await reopened.get(AvatarCache.self, id: "avatar-cache", currentVersion: 1) == nil)
        #expect(!FileManager.default.fileExists(atPath: url.path), "stale copy swept on open")
        // A genuinely new cache for a new body revision is a new write, not a resurrection.
        try await reopened.put(AvatarCache(bodyRevision: 4, meshHash: "def"), Self.avatar, schemaVersion: 1)
        #expect(try await reopened.get(AvatarCache.self, id: "avatar-cache", currentVersion: 1)?.bodyRevision == 4)
        #expect(try await reopened.get(Measurements.self, id: "measurements", currentVersion: 1) != nil)
    }

    @Test("Deleting everything erases files and the KEK, and leaves a working empty vault")
    func deleteEverything() async throws {
        let vault = try open()
        try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
        try await vault.put(SyntheticCloset.demo, Self.wardrobe, schemaVersion: Wardrobe.schemaVersion)
        let oldKEK = try #require(try keys.readKEK())
        let (receipt, fresh) = try await vault.deleteAll()
        #expect(receipt.scope == .everything && receipt.deletedRecordCount == 2)
        #expect(try keys.readKEK() != oldKEK)
        #expect(try await fresh.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == nil)
        try await fresh.put(1, Self.wardrobe, schemaVersion: 1)
        // The old instance is dead: it can never write an old-root index into the new vault.
        await #expect(throws: VaultError.closed) { try await vault.put(2, Self.wardrobe, schemaVersion: 1) }
        await fresh.close()
        #expect(try await open().get(Int.self, id: "wardrobe", currentVersion: 1) == 1)
    }

    @Test("A vault whose KEK is lost can still be reset by the user")
    func resetAfterKeyLoss() async throws {
        do {
            let vault = try open()
            try await vault.put(Measurements(chestCm: 97, waistCm: 81), Self.body, schemaVersion: 1)
            await vault.close()
        }
        try keys.deleteKEK()
        #expect(throws: VaultError.keyLost) { try open() }
        try Vault.destroy(directory: dir, keyStore: keys)
        #expect(try await open().contains("measurements") == false)
    }

    @Test("Key inventory and key records never print key bytes")
    func noKeyBytesInDescriptions() async throws {
        let vault = try open()
        try await vault.put(1, Self.wardrobe, schemaVersion: 1)
        let registry = try JSONDecoder.vault.decode(KeyRegistry.self, from: Data(contentsOf: dir.appendingPathComponent("keys.json")))
        let wrapped = registry.keys.map { $0.wrapped.base64EncodedString() }
        var dumped = ""
        dump(registry, to: &dumped)
        let printed = (await vault.keyInventory()).joined() + String(describing: registry.keys) + dumped
        for w in wrapped { #expect(!printed.contains(w)) }
        #expect(!printed.contains(try #require(try keys.readKEK()).withUnsafeBytes { Data($0) }.base64EncodedString()))
    }

    @Test("V15-T-SEC-09 at the storage boundary: protected-trait keys are never written")
    func vaultRejectsProtectedTraits() async throws {
        struct Leaky: Codable { var city = "Roma"; var inferredReligion = "x" }
        let vault = try open()
        await #expect(throws: VaultError.policy(.policyDenied)) {
            try await vault.put(Leaky(), VaultRecordSpec(id: "trip", type: "trips", domain: .travel), schemaVersion: 1)
        }
        #expect(try recordFiles().isEmpty)
    }

    @Test("Every real app record type passes the protected-trait guard")
    func appTypesAreClean() throws {
        let trip = DemoTrip.barcelona(start: try #require(LocalDate(year: 2026, month: 11, day: 10)))
        let encoder = JSONEncoder.vault
        let blobs: [Data] = [
            try encoder.encode(SyntheticCloset.demo), try encoder.encode([trip]), try encoder.encode(FitPassport()),
            try encoder.encode(UserMeasurements(chestCm: 1, waistCm: 2)), try encoder.encode(ConsentLedger()),
        ]
        for blob in blobs { #expect(SensitiveAttributeGuard.violations(inJSON: blob).isEmpty) }
    }

    // MARK: Review counterexamples (AG-12, 2026-11-03)

    @Test("A second live instance on the same directory is refused; closing frees it")
    func singleInstance() async throws {
        let vault = try open()
        #expect(throws: VaultError.alreadyOpen) { try open() }
        await vault.close()
        await #expect(throws: VaultError.closed) { try await vault.get(Int.self, id: "x", currentVersion: 1) }
        let again = try open()
        await again.close()
    }

    @Test("A first open that crashed before keys.json was written starts clean instead of bricking")
    func crashedFirstOpen() async throws {
        do {
            let vault = try open()
            await vault.close()
        }
        // Index is written first; simulate dying right after it.
        try FileManager.default.removeItem(at: dir.appendingPathComponent("keys.json"))
        let vault = try open()
        try await vault.put(1, Self.wardrobe, schemaVersion: 1)
        await vault.close()
        #expect(try await open().get(Int.self, id: "wardrobe", currentVersion: 1) == 1)
    }

    @Test("Keys present but index missing: empty vault opens; with records it refuses (no silent loss)")
    func missingIndex() async throws {
        do { await (try open()).close() }
        let index = dir.appendingPathComponent("index.sealed")
        try FileManager.default.removeItem(at: index)
        let vault = try open()
        try await vault.put(1, Self.wardrobe, schemaVersion: 1)
        await vault.close()
        try FileManager.default.removeItem(at: index)
        #expect(throws: VaultError.corrupted("index")) { try open() }
    }

    @Test("A derived record must point at live sources, or it would escape the deletion cascade")
    func derivedNeedsLiveSource() async throws {
        let vault = try open()
        await #expect(throws: VaultError.missingSource) {
            try await vault.put(AvatarCache(bodyRevision: 1, meshHash: "a"), Self.avatar, schemaVersion: 1)
        }
        try await vault.put(Measurements(chestCm: 1, waistCm: 2), Self.body, schemaVersion: 1)
        try await vault.put(AvatarCache(bodyRevision: 1, meshHash: "a"), Self.avatar, schemaVersion: 1)
        try await vault.delete("measurements")
        await #expect(throws: VaultError.missingSource) {
            try await vault.put(AvatarCache(bodyRevision: 2, meshHash: "b"), Self.avatar, schemaVersion: 1)
        }
    }

    // MARK: Legacy migration

    @Test("Plaintext LocalStore collections move into the vault, and the plaintext file is removed only after verification")
    func legacyMigration() async throws {
        let legacyDir = dir.appendingPathComponent("legacy")
        let legacy = try LocalStore(directory: legacyDir)
        try await legacy.save(SyntheticCloset.demo, as: "wardrobe", schemaVersion: Wardrobe.schemaVersion)
        try "{not json".data(using: .utf8)!.write(to: legacyDir.appendingPathComponent("trips.json"))
        let vault = try Vault.open(directory: dir.appendingPathComponent("vault"), keyStore: keys)
        defer { Task { await vault.close() } }

        let moved = try await LegacyImport.move(Wardrobe.self, collection: "wardrobe", version: Wardrobe.schemaVersion,
                                                from: legacy, into: vault, as: Self.wardrobe)
        #expect(moved == .moved)
        #expect(await legacy.exists(collection: "wardrobe") == false)
        #expect(try await vault.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == SyntheticCloset.demo)

        // A corrupt file stays exactly where it was.
        await #expect(throws: LocalStoreError.self) {
            try await LegacyImport.move([Trip].self, collection: "trips", version: Trip.schemaVersion, from: legacy, into: vault,
                                        as: VaultRecordSpec(id: "trips", type: "trips", domain: .travel))
        }
        #expect(await legacy.exists(collection: "trips"))
        LegacyImport.removeIfEmpty(legacy)
        #expect(FileManager.default.fileExists(atPath: legacyDir.path))

        // Crash after the vault write but before the plaintext delete: the vault copy wins.
        try await legacy.save(Wardrobe(), as: "wardrobe", schemaVersion: Wardrobe.schemaVersion)
        let again = try await LegacyImport.move(Wardrobe.self, collection: "wardrobe", version: Wardrobe.schemaVersion,
                                                from: legacy, into: vault, as: Self.wardrobe)
        #expect(again == .alreadyInVault)
        #expect(try await vault.get(Wardrobe.self, id: "wardrobe", currentVersion: Wardrobe.schemaVersion) == SyntheticCloset.demo)
    }
}

extension Vault {
    func setFaultInjection(_ hook: @escaping @Sendable (RotationStep) throws -> Void) { faultInjection = hook }
}

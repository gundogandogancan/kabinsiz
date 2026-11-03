import CryptoKit
import Foundation
import SystemContracts

/// Logical domains of the private vault (§111.2). Each has its own data key, so one can be deleted or
/// rotated without touching the others. `travel` is added to the constitution's three (D-008).
public enum VaultDomain: String, Codable, CaseIterable, Sendable {
    case body = "BODY"
    case wardrobe = "WARDROBE"
    case preferences = "PREFERENCES"
    case travel = "TRAVEL"
}

public enum VaultError: Error, Equatable, Sendable {
    /// The KEK cannot be read now (device locked) or is gone while data exists. Nothing is created or overwritten.
    case keyUnavailable
    /// Authentication failed: tampered, swapped or wrong-key data. Carries the record type only.
    case integrityFailure(String)
    case newerSchema(found: Int, supported: Int)
    case corrupted(String)
    case invalidIdentifier
    case policy(FaultCode)
    case keychain(OSStatus)
    /// Data exists but the KEK is gone for good (e.g. restored from an unencrypted backup). Only a reset helps.
    case keyLost
    /// This instance was closed or replaced by `deleteAll`.
    case closed
    /// Another live instance already owns this directory.
    case alreadyOpen
    /// `derivedFrom` names a record that does not exist or was deleted.
    case missingSource

    public var faultCode: FaultCode {
        switch self {
        case .keyUnavailable, .closed, .alreadyOpen: .resourceDenied
        case .integrityFailure, .corrupted, .keychain, .keyLost: .storageCorrupted
        case .newerSchema: .schemaNewer
        case .invalidIdentifier, .missingSource: .schemaInvalid
        case .policy(let fault): fault
        }
    }
}

/// Where a record sits and what it is. The record ID is also its file name, so it is restricted to
/// `[A-Za-z0-9_-]`, which also keeps the `|`-separated associated data unambiguous.
public struct VaultRecordSpec: Hashable, Sendable {
    public let id: String
    public let type: String
    public let domain: VaultDomain
    public let classification: DataClassification
    /// Records this one is computed from. Deleting any of them deletes this one too (§112.3, V15-T-CRY-10).
    public let derivedFrom: [String]

    public init(id: String, type: String, domain: VaultDomain, classification: DataClassification = .localPrivate, derivedFrom: [String] = []) {
        self.id = id
        self.type = type
        self.domain = domain
        self.classification = classification
        self.derivedFrom = derivedFrom
    }

    static func isValidIdentifier(_ s: String) -> Bool {
        (1...128).contains(s.count) && s.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") }
    }
}

// MARK: - Key registry

/// Metadata about one key plus its wrapped (encrypted) bytes. Never contains or prints raw key material.
struct KeyRecord: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    enum Status: String, Codable, Sendable { case pending = "PENDING", active = "ACTIVE" }

    let keyID: UUID
    /// `ROOT` or `DEK:<DOMAIN>`.
    let purpose: String
    let algorithm: String
    let version: Int
    let createdAt: Date
    var status: Status
    /// AES.GCM combined box (nonce ‖ ciphertext ‖ tag) of the key, sealed by its parent.
    let wrapped: Data

    var description: String { "KeyRecord(\(purpose), \(keyID), \(algorithm) v\(version), \(status.rawValue))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["keyID": keyID, "purpose": purpose, "status": status.rawValue]) }

    var associatedData: Data { Data("kabinsiz.wrap.v1|\(purpose)|\(keyID.uuidString)|\(algorithm)|\(version)".utf8) }

    static func rootPurpose() -> String { "ROOT" }
    static func dekPurpose(_ domain: VaultDomain) -> String { "DEK:\(domain.rawValue)" }
}

struct KeyRegistry: Codable, Sendable {
    var formatVersion = 1
    var keys: [KeyRecord] = []

    func record(_ id: UUID) -> KeyRecord? { keys.first { $0.keyID == id } }
    var root: KeyRecord? { keys.first { $0.purpose == KeyRecord.rootPurpose() } }
}

// MARK: - Index

/// The authoritative list of live records, tombstones and active domain keys. Sealed with the vault
/// root key, so it is both private and tamper-evident. Writing it is the commit point of every change.
struct VaultIndex: Codable, Sendable {
    struct Entry: Codable, Hashable, Sendable {
        var type: String
        var domain: VaultDomain
        var classification: DataClassification
        var schemaVersion: Int
        /// Bumped by every write and delete. Part of the file name and the AAD, so an old copy of the
        /// file (restored backup, leftover) never matches the index again (V15-T-SEC-10).
        var generation: Int
        var keyID: UUID?
        var deleted: Bool
        var derivedFrom: [String]
    }

    var formatVersion = 1
    var sequence = 0
    var activeKeys: [VaultDomain: UUID] = [:]
    var records: [String: Entry] = [:]

    var liveRecordIDs: [String] { records.filter { !$0.value.deleted }.keys.sorted() }
}

/// One encrypted record on disk (§111.2 `VaultRecord`). Header fields are repeated from the index for
/// diagnosis; decryption always uses the index's values in the AAD, never the file's.
struct VaultRecordV1: Codable, Sendable {
    var formatVersion = 1
    let recordID: String
    let recordType: String
    let schemaVersion: Int
    let classification: DataClassification
    let domain: VaultDomain
    let keyID: UUID
    let generation: Int
    let nonce: Data
    let ciphertext: Data
    let tag: Data
}

// MARK: - Crypto

/// Thin layer over CryptoKit. No custom primitives: AES-256-GCM with a random 96-bit nonce from
/// CryptoKit for every seal (§111.1).
enum VaultCrypto {
    static let algorithm = "AES-256-GCM"

    static func newKey() -> SymmetricKey { SymmetricKey(size: .bits256) }

    /// AAD binds type, ID, schema version (§111.1) plus domain, class, key and generation, so a record
    /// cannot be moved to another slot, domain or generation without failing authentication.
    static func recordAAD(id: String, entry: VaultIndex.Entry, keyID: UUID) -> Data {
        Data("kabinsiz.record.v1|\(entry.type)|\(id)|\(entry.schemaVersion)|\(entry.domain.rawValue)|\(entry.classification.rawValue)|\(keyID.uuidString)|\(entry.generation)".utf8)
    }

    static func indexAAD(rootKeyID: UUID) -> Data { Data("kabinsiz.index.v1|\(rootKeyID.uuidString)".utf8) }

    static func seal(_ plaintext: Data, key: SymmetricKey, aad: Data) throws -> AES.GCM.SealedBox {
        try AES.GCM.seal(plaintext, using: key, nonce: AES.GCM.Nonce(), authenticating: aad)
    }

    static func open(_ box: AES.GCM.SealedBox, key: SymmetricKey, aad: Data, what: String) throws -> Data {
        do { return try AES.GCM.open(box, using: key, authenticating: aad) } catch { throw VaultError.integrityFailure(what) }
    }

    static func wrap(_ key: SymmetricKey, under parent: SymmetricKey, record aad: Data) throws -> Data {
        let box = try seal(key.withUnsafeBytes { Data($0) }, key: parent, aad: aad)
        guard let combined = box.combined else { throw VaultError.corrupted("wrap") }
        return combined
    }

    static func unwrap(_ record: KeyRecord, under parent: SymmetricKey) throws -> SymmetricKey {
        let box: AES.GCM.SealedBox
        do { box = try AES.GCM.SealedBox(combined: record.wrapped) } catch { throw VaultError.integrityFailure("key") }
        let raw = try open(box, key: parent, aad: record.associatedData, what: "key")
        guard raw.count == 32 else { throw VaultError.integrityFailure("key") }
        return SymmetricKey(data: raw)
    }
}

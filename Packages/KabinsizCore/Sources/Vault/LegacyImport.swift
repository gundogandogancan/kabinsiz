import Foundation
import LocalStore

/// Moves one plaintext `LocalStore` collection (ADR-002, pre-v1.5) into the vault.
///
/// Order: read typed → write to vault → read back and compare bytes → only then delete the plaintext
/// file. Any failure leaves the plaintext file where it was, so nothing is lost and the move is retried
/// on the next launch. Deleting a file cannot guarantee flash erasure; the threat model says so.
public enum LegacyImport {
    public enum Outcome: Equatable, Sendable {
        case nothingToMove
        case moved
        /// The vault already had this record (an earlier move crashed before deleting the old file).
        /// The vault copy wins; the stale plaintext file is removed.
        case alreadyInVault
    }

    public static func move<T: Codable & Sendable>(
        _ type: T.Type, collection: String, version: Int, from legacy: LocalStore, into vault: Vault, as spec: VaultRecordSpec
    ) async throws -> Outcome {
        guard await legacy.exists(collection: collection) else { return .nothingToMove }
        if await vault.contains(spec.id) {
            try await legacy.delete(collection: collection)
            return .alreadyInVault
        }
        guard let value = try await legacy.load(type, from: collection, currentVersion: version) else { return .nothingToMove }
        try await vault.put(value, spec, schemaVersion: version)
        guard let back = try await vault.get(type, id: spec.id, currentVersion: version),
              try JSONEncoder.vault.encode(back) == JSONEncoder.vault.encode(value)
        else { throw VaultError.integrityFailure(spec.type) }
        try await legacy.delete(collection: collection)
        return .moved
    }

    /// Removes the legacy directory once nothing is left in it.
    public static func removeIfEmpty(_ legacy: LocalStore) {
        let fm = FileManager.default
        guard let names = try? fm.contentsOfDirectory(atPath: legacy.directory.path),
              names.allSatisfy({ $0.hasPrefix(".") }) else { return }
        try? fm.removeItem(at: legacy.directory)
    }
}

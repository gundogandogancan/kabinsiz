import CryptoKit
import Foundation
import Security

/// Holds the key-encryption key (KEK), the top of the §111.2 hierarchy. Only the KEK lives here;
/// the vault root and domain keys are stored wrapped, next to the data.
public protocol KeyStore: Sendable {
    /// `nil` when no KEK exists yet. Throws `VaultError.keyUnavailable` when one may exist but cannot be
    /// read now (device locked): callers must not create a replacement in that case.
    func readKEK() throws -> SymmetricKey?
    func writeKEK(_ key: SymmetricKey) throws
    func deleteKEK() throws
}

/// The app's KEK in the iOS Keychain.
///
/// Accessibility is `kSecAttrAccessibleWhenUnlocked` (decision D-008): readable only while the device is
/// unlocked, which matches an app with no background work; and, unlike `…ThisDeviceOnly`, it moves with an
/// *encrypted* device backup, so a phone restore keeps the user's wardrobe (§68 local-first must not mean
/// data loss). Residual risk is written in docs/security/THREAT_MODEL.md.
public struct KeychainKeyStore: KeyStore {
    public let service: String
    public let account: String

    public init(service: String = "app.kabinsiz.vault", account: String = "kek.v1") {
        self.service = service
        self.account = account
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecUseDataProtectionKeychain as String: true,
        ]
    }

    public func readKEK() throws -> SymmetricKey? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            guard let data = item as? Data, data.count == 32 else { throw VaultError.corrupted("kek") }
            return SymmetricKey(data: data)
        case errSecItemNotFound:
            return nil
        case errSecInteractionNotAllowed:
            throw VaultError.keyUnavailable
        default:
            throw VaultError.keychain(status)
        }
    }

    public func writeKEK(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        let deleteStatus = SecItemDelete(baseQuery as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else { throw VaultError.keychain(deleteStatus) }
        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw status == errSecInteractionNotAllowed ? VaultError.keyUnavailable : VaultError.keychain(status)
        }
    }

    public func deleteKEK() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw VaultError.keychain(status) }
    }
}

/// In-memory KEK for tests and previews. Never used by the shipping app.
public final class EphemeralKeyStore: KeyStore, @unchecked Sendable {
    private let lock = NSLock()
    private var key: SymmetricKey?
    private var isLocked = false

    public init(key: SymmetricKey? = nil) { self.key = key }

    public func readKEK() throws -> SymmetricKey? {
        try lock.withLock {
            if isLocked { throw VaultError.keyUnavailable }
            return key
        }
    }

    public func writeKEK(_ newKey: SymmetricKey) throws {
        try lock.withLock {
            if isLocked { throw VaultError.keyUnavailable }
            key = newKey
        }
    }

    public func deleteKEK() throws {
        lock.withLock { key = nil }
    }

    /// Simulates a locked device: reads fail as they would with `errSecInteractionNotAllowed`.
    public func setLocked(_ locked: Bool) { lock.withLock { isLocked = locked } }
}

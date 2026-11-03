import CryptoKit
import Foundation
import MorningReady
import Vault

/// Where the morning plan and the day's look lock live (v2.8 §05.2). Both name the user's garments,
/// so both are sealed with AES-GCM under a Keychain key of their own; "delete everything" destroys
/// the key and the files together (UI28-T045). UI tests get their own folder and key.
@MainActor
enum MorningStore {
    private static let isUITest: Bool = {
        let args = ProcessInfo.processInfo.arguments
        return args.contains("-resetForUITest") || args.contains("-uiTestVault")
    }()

    static let directory: URL = isUITest
        ? FileManager.default.temporaryDirectory.appendingPathComponent("kz-uitest-morning-\(UUID().uuidString)")
        : (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("Kabinsiz/MorningReady")

    private static let keyStore = KeychainKeyStore(service: "app.kabinsiz.morning", account: isUITest ? "kek.morning.uitest" : "kek.morning.v1")

    static var planURL: URL { directory.appendingPathComponent("daily-plan.sealed") }
    static var lockURL: URL { directory.appendingPathComponent("look-lock.sealed") }

    /// AES-GCM with the store's key, made on first use. While the device is locked the key cannot be
    /// read: sealing then fails and nothing is written (the home recomputes in the foreground).
    static func codec() -> SealingCodec {
        let key: SymmetricKey?
        do {
            if let existing = try keyStore.readKEK() {
                key = existing
            } else {
                let fresh = SymmetricKey(size: .bits256)
                try keyStore.writeKEK(fresh)
                key = fresh
            }
        } catch {
            key = nil
        }
        guard let key else {
            return SealingCodec(seal: { _ in throw CocoaError(.fileWriteNoPermission) }, open: { _ in throw CocoaError(.fileReadNoPermission) })
        }
        return SealingCodec(
            seal: { data in
                guard let combined = try AES.GCM.seal(data, using: key).combined else { throw CocoaError(.fileWriteUnknown) }
                return combined
            },
            open: { sealed in try AES.GCM.open(AES.GCM.SealedBox(combined: sealed), using: key) }
        )
    }

    /// Crypto-shred: the key first, then the files.
    static func eraseAll() {
        try? keyStore.deleteKEK()
        try? FileManager.default.removeItem(at: directory)
    }
}

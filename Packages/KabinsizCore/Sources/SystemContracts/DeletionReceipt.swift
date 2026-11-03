import Foundation

/// What a deletion did, in counts and types only (§116.3). No record IDs, names or values, so the
/// receipt can be shown and kept without becoming private data itself.
public struct DeletionReceipt: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum Scope: String, Codable, Sendable {
        case record = "RECORD"
        case domain = "DOMAIN"
        case everything = "EVERYTHING"
    }

    /// Copies a device-local deletion cannot reach. Listed on every receipt, never hidden (§111.2).
    public enum UnresolvedCopy: String, Codable, CaseIterable, Sendable {
        case deviceBackups = "DEVICE_BACKUPS"
        case userSharedExports = "USER_SHARED_EXPORTS"
        case flashStorageRemnants = "FLASH_STORAGE_REMNANTS"
    }

    public var schemaVersion: Int
    public var operationID: UUID
    public var completedAt: Date
    public var scope: Scope
    /// Record type → how many records of that type were removed, e.g. `["plan": 2, "trips": 1]`.
    public var deletedCountsByType: [String: Int]
    public var destroyedKeyCount: Int
    public var unresolvedCopies: [UnresolvedCopy]

    public init(operationID: UUID = UUID(), completedAt: Date, scope: Scope, deletedCountsByType: [String: Int], destroyedKeyCount: Int) {
        schemaVersion = Self.currentSchemaVersion
        self.operationID = operationID
        self.completedAt = completedAt
        self.scope = scope
        self.deletedCountsByType = deletedCountsByType
        self.destroyedKeyCount = destroyedKeyCount
        unresolvedCopies = UnresolvedCopy.allCases
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", operationID = "operation_id", completedAt = "completed_at", scope
        case deletedCountsByType = "deleted_counts_by_type", destroyedKeyCount = "destroyed_key_count"
        case unresolvedCopies = "unresolved_copies"
    }

    public var deletedRecordCount: Int { deletedCountsByType.values.reduce(0, +) }

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion, destroyedKeyCount >= 0,
              deletedCountsByType.values.allSatisfy({ $0 > 0 }),
              deletedCountsByType.keys.allSatisfy(Self.isTypeName),
              Set(unresolvedCopies) == Set(UnresolvedCopy.allCases)
        else { throw .schemaInvalid }
    }

    /// Types are short lower-case words (`plan`, `fit-passport`). Digits are refused so a record ID
    /// such as `plan-3F2A…` can never be smuggled in as a "type".
    static func isTypeName(_ name: String) -> Bool {
        (1...32).contains(name.count) && name.first != "-" && name.last != "-"
            && name.allSatisfy { $0.isASCII && ($0.isLowercase || $0 == "-") }
    }
}

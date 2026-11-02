import Foundation

/// A persisted or exchanged contract. Field names are frozen through explicit `CodingKeys`, never
/// through a key strategy, so renaming a Swift property cannot silently rename the JSON key.
public protocol VersionedContract: Codable, Sendable {
    static var currentSchemaVersion: Int { get }
    /// The JSON key holding this type's version (`schema_version`, or `work_order_version` for §121.1).
    static var versionKey: String { get }
    /// Every top-level key this version may contain. Anything else is rejected (§105.1 "strictly typed").
    static var knownKeys: Set<String> { get }
    /// Semantic checks the type system cannot express. Throws instead of repairing.
    func validate() throws(FaultCode)
}

extension VersionedContract {
    public static var versionKey: String { "schema_version" }
}

/// One decode path for every contract: version gate, strict key check, typed decoding, validation.
public enum ContractCoder {
    public static func decode<T: VersionedContract>(_ type: T.Type, from data: Data) throws(FaultCode) -> T {
        guard let object = try? JSONSerialization.jsonObject(with: data), let top = object as? [String: Any] else {
            throw .schemaInvalid
        }
        // `Bool` is bridged to NSNumber too; a version must be a plain integer.
        guard let number = top[T.versionKey] as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID(),
              let version = Int(exactly: number.doubleValue), version >= 1
        else { throw .schemaInvalid }
        // A newer file is refused, never partially read and re-saved as an older version.
        guard version <= T.currentSchemaVersion else { throw .schemaNewer }
        // Unknown keys could smuggle data (e.g. a `latitude` beside a typed payload); same version, same keys.
        guard Set(top.keys).isSubset(of: T.knownKeys) else { throw .schemaInvalid }
        let value: T
        do { value = try decoder.decode(T.self, from: data) } catch { throw classify(error) }
        try value.validate()
        return value
    }

    public static func encode<T: VersionedContract>(_ value: T) throws(FaultCode) -> Data {
        try value.validate()
        do { return try encoder.encode(value) } catch { throw .schemaInvalid }
    }

    /// An unknown data class is its own fault so callers can report it as a privacy event (§112.2).
    private static func classify(_ error: Error) -> FaultCode {
        let path: [CodingKey]
        switch error {
        case DecodingError.dataCorrupted(let c): path = c.codingPath
        case DecodingError.typeMismatch(_, let c), DecodingError.valueNotFound(_, let c): path = c.codingPath
        default: return .schemaInvalid
        }
        let classificationKeys = ["classification", "data_classes"]
        return path.contains { key in classificationKeys.contains { key.stringValue.hasSuffix($0) } } ? .unknownClassification : .schemaInvalid
    }

    /// RFC 3339 with fractional seconds, so a `Date` survives a round trip exactly enough that ordering
    /// checks (`expires_at > collected_at`) give the same answer after reading as before writing.
    /// Files without fractions are still accepted.
    static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date(text, strategy: fractional) { return date }
            if let date = try? Date(text, strategy: whole) { return date }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Not RFC 3339: \(text)"))
        }
        return d
    }

    static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .custom { date, encoder in
            var c = encoder.singleValueContainer()
            try c.encode(date.formatted(fractional))
        }
        e.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return e
    }

    private static let fractional = Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
    private static let whole = Date.ISO8601FormatStyle(timeZone: .gmt)
}

/// Encodes a `Set` as a sorted array so the same value always produces the same bytes.
func sortedRaw<T: RawRepresentable>(_ set: Set<T>) -> [T] where T.RawValue == String {
    set.sorted { $0.rawValue < $1.rawValue }
}

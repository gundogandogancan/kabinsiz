import Foundation

/// A JSON value that can cross concurrency domains. JSON-RPC messages are parsed into this and built
/// from it, so the server never passes `Any` around.
enum JSONValue: Sendable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    init(any value: Any) throws {
        switch value {
        case is NSNull: self = .null
        case let number as NSNumber:
            self = CFGetTypeID(number) == CFBooleanGetTypeID() ? .bool(number.boolValue) : .number(number.doubleValue)
        case let text as String: self = .string(text)
        case let list as [Any]: self = .array(try list.map(JSONValue.init(any:)))
        case let dict as [String: Any]: self = .object(try dict.mapValues(JSONValue.init(any:)))
        default: throw CocoaError(.coderInvalidValue)
        }
    }

    static func parse(_ data: Data) throws -> JSONValue {
        try JSONValue(any: JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]))
    }

    var any: Any {
        switch self {
        case .null: NSNull()
        case .bool(let b): b
        // Whole numbers go out as integers, so a request id `1` comes back as `1`, not `1.0`.
        // Fractions go out in Swift's shortest round-trip form (`0.615`, not `0.61499999999999999`).
        case .number(let n): n.rounded() == n && abs(n) < 9e15 ? NSNumber(value: Int64(n))
            : (n.isFinite ? NSDecimalNumber(string: "\(n)", locale: Locale(identifier: "en_US_POSIX")) : NSNull())
        case .string(let s): s
        case .array(let a): a.map(\.any)
        case .object(let o): o.mapValues(\.any)
        }
    }

    func serialized() -> Data {
        // Fragments are allowed because a tool may return a bare string; messages are always objects.
        (try? JSONSerialization.data(withJSONObject: any, options: [.sortedKeys, .withoutEscapingSlashes, .fragmentsAllowed])) ?? Data("null".utf8)
    }

    var text: String { String(decoding: serialized(), as: UTF8.self) }

    subscript(key: String) -> JSONValue? {
        if case .object(let o) = self { return o[key] }
        return nil
    }

    var stringValue: String? { if case .string(let s) = self { s } else { nil } }
    var boolValue: Bool? { if case .bool(let b) = self { b } else { nil } }
    var objectValue: [String: JSONValue]? { if case .object(let o) = self { o } else { nil } }
}

extension JSONValue: ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, ExpressibleByFloatLiteral,
    ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByNilLiteral {
    init(stringLiteral value: String) { self = .string(value) }
    init(booleanLiteral value: Bool) { self = .bool(value) }
    init(floatLiteral value: Double) { self = .number(value) }
    init(integerLiteral value: Int) { self = .number(Double(value)) }
    init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
    init(dictionaryLiteral elements: (String, JSONValue)...) { self = .object(Dictionary(elements, uniquingKeysWith: { $1 })) }
    init(nilLiteral: ()) { self = .null }
}

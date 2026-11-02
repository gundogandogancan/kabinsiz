import Foundation

/// A calendar day at the destination, independent of the device time zone (§41.1, §47 invariants).
public struct LocalDate: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init?(year: Int, month: Int, day: Int) {
        var components = DateComponents(year: year, month: month, day: day)
        components.calendar = LocalDate.gregorianUTC
        guard components.isValidDate else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    /// Parses `YYYY-MM-DD`.
    public init?(_ iso: String) {
        let parts = iso.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    /// The calendar day an instant falls on in the given time zone.
    public init(instant: Date, timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let c = calendar.dateComponents([.year, .month, .day], from: instant)
        year = c.year!
        month = c.month!
        day = c.day!
    }

    public var description: String { String(format: "%04d-%02d-%02d", year, month, day) }

    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    public func adding(days: Int) -> LocalDate {
        let shifted = LocalDate.gregorianUTC.date(byAdding: .day, value: days, to: anchor)!
        return LocalDate(instant: shifted, timeZone: LocalDate.utc)
    }

    /// Whole calendar days from `self` to `other`. DST cannot affect this: both anchors are UTC noon.
    public func days(until other: LocalDate) -> Int {
        LocalDate.gregorianUTC.dateComponents([.day], from: anchor, to: other.anchor).day!
    }

    public var weekdayIndex: Int { LocalDate.gregorianUTC.component(.weekday, from: anchor) }

    private var anchor: Date {
        LocalDate.gregorianUTC.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private static let utc = TimeZone(identifier: "UTC")!
    private static let gregorianUTC: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar
    }()

    // Encode as the ISO string so persisted files stay readable.
    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        guard let value = LocalDate(raw) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "bad date \(raw)"))
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

/// How the user expressed the trip length. "5 gün" and "5 gece" are different trips (§41.1, T-TRV-005).
public enum TripLength: Hashable, Sendable {
    case days(Int)
    case nights(Int)

    public var calendarDays: Int {
        switch self {
        case .days(let n): n
        case .nights(let n): n + 1
        }
    }
}

public enum TripDateError: Error, Equatable, Sendable {
    case endBeforeStart
    case startInPast
    case tooLong(maxDays: Int)
    case zeroLength
}

public enum TripDates {
    public static let maxDays = 14

    /// Validates an inclusive date range, using "today" in the destination's time zone.
    public static func validate(start: LocalDate, end: LocalDate, today: LocalDate) -> Result<[LocalDate], TripDateError> {
        if end < start { return .failure(.endBeforeStart) }
        if start < today { return .failure(.startInPast) }
        let count = start.days(until: end) + 1
        if count > maxDays { return .failure(.tooLong(maxDays: maxDays)) }
        return .success((0..<count).map { start.adding(days: $0) })
    }

    public static func endDate(start: LocalDate, length: TripLength) -> Result<LocalDate, TripDateError> {
        let days = length.calendarDays
        if days <= 0 { return .failure(.zeroLength) }
        if days > maxDays { return .failure(.tooLong(maxDays: maxDays)) }
        return .success(start.adding(days: days - 1))
    }
}

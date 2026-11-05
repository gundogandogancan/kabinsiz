import Foundation

/// The body controls of the first proof (§133.1, §108). Ranges exist only to keep the shape drawable;
/// they are not norms, ideals or plausibility judgements about people (§123 Journey A.2).
public enum BodyParameter: String, Codable, CaseIterable, Sendable {
    case height = "HEIGHT"
    case shoulderWidth = "SHOULDER_WIDTH"
    case chest = "CHEST"
    case waist = "WAIST"
    case hip = "HIP"

    public var displayName: String {
        switch self {
        case .height: "Boy"
        case .shoulderWidth: "Omuz genişliği"
        case .chest: "Göğüs çevresi"
        case .waist: "Bel çevresi"
        case .hip: "Kalça çevresi"
        }
    }

    /// Mesh-safety range in centimetres.
    public var safeRange: ClosedRange<Double> {
        switch self {
        case .height: 120...220
        case .shoulderWidth: 30...60
        case .chest: 60...160
        case .waist: 50...160
        case .hip: 60...170
        }
    }

    /// Where a new neutral body starts. A drawing starting point, not a measurement or a target.
    public var neutralStartCm: Double {
        switch self {
        case .height: 170
        case .shoulderWidth: 42
        case .chest: 95
        case .waist: 82
        case .hip: 98
        }
    }

    public static let sliderStepCm = 0.5

    /// The girths (chest, waist, hip). With shoulder width, what a template or a weight estimate may
    /// redraw; height is never estimated, it is what the person gave.
    public static let girths: [BodyParameter] = [.chest, .waist, .hip]
}

/// The drawing preset of the 3D body (ADR-011). Optional, chosen by the person, neutral by default.
/// It shapes only the picture: never inferred from anything, never asked as identity, never used for
/// size advice (v1.5 §5 "kullanıcı model görünümünü kendi seçer", v1.7 §3.2 appearance is not evidence).
public enum BodyTemplate: String, Codable, CaseIterable, Sendable {
    case neutral = "NEUTRAL"
    case female = "FEMALE"
    case male = "MALE"

    public var displayName: String {
        switch self {
        case .neutral: "Nötr"
        case .female: "Kadın"
        case .male: "Erkek"
        }
    }

    /// Where a body drawn with this template starts. The neutral values are `neutralStartCm`; the other
    /// two keep the neutral values and apply the template's own proportions (the baked female and male
    /// bases against the neutral one, at the same height; ADR-011). Drawing points, not norms.
    public func startCm(_ p: BodyParameter) -> Double {
        switch (self, p) {
        case (.neutral, _), (_, .height): p.neutralStartCm
        case (.female, .shoulderWidth): 39.5
        case (.female, .chest): 92.5
        case (.female, .waist): 78.5
        case (.female, .hip): 101
        case (.male, .shoulderWidth): 42
        case (.male, .chest): 98
        case (.male, .waist): 85.5
        case (.male, .hip): 97.5
        }
    }
}

public enum LengthUnit: String, Codable, CaseIterable, Sendable {
    case centimeters = "CM"
    case inches = "IN"

    public var symbol: String { self == .centimeters ? "cm" : "inç" }
    public var spokenName: String { self == .centimeters ? "santimetre" : "inç" }
}

/// A length stored once, in tenths of a millimetre, so unit changes never re-convert a stored value
/// (V15-T-BOD-04): 1 in = 254 tenths of a millimetre exactly.
public struct BodyLength: Codable, Hashable, Comparable, Sendable {
    public let tenthsOfMillimeter: Int

    public init(tenthsOfMillimeter: Int) { self.tenthsOfMillimeter = tenthsOfMillimeter }

    /// Non-finite or absurd input (NaN, ∞, a pasted 1e300) becomes -1, which no safe range accepts,
    /// instead of trapping on the integer conversion.
    public init(_ value: Double, _ unit: LengthUnit) {
        let tenths = (unit == .centimeters ? value * 100 : value * 254).rounded()
        tenthsOfMillimeter = tenths.isFinite && abs(tenths) < 1e9 ? Int(tenths) : -1
    }

    public var centimeters: Double { Double(tenthsOfMillimeter) / 100 }

    public func value(in unit: LengthUnit) -> Double {
        unit == .centimeters ? Double(tenthsOfMillimeter) / 100 : Double(tenthsOfMillimeter) / 254
    }

    /// One decimal, Turkish comma, e.g. "81,5 cm".
    public func formatted(_ unit: LengthUnit) -> String {
        let v = value(in: unit)
        let text = v.formatted(.number.precision(.fractionLength(0...1)).locale(Locale(identifier: "tr_TR")))
        return "\(text) \(unit.symbol)"
    }

    public static func < (a: Self, b: Self) -> Bool { a.tenthsOfMillimeter < b.tenthsOfMillimeter }
}

/// Where a value came from. Only `userMeasured` may feed size advice (§123 A.5: "exact value only if
/// manually entered"); slider shapes are for the picture.
public enum ValueSource: String, Codable, Sendable {
    case neutralStart = "NEUTRAL_START"
    case sliderShaped = "SLIDER_SHAPED"
    case userMeasured = "USER_MEASURED"
    /// Drawn from the optional height and weight (ADR-011). For the picture only, like a slider shape.
    case weightEstimate = "WEIGHT_ESTIMATE"

    public var label: String {
        switch self {
        case .neutralStart: "Başlangıç (ölçü değil)"
        case .sliderShaped: "Kaydırıcıyla şekillendirildi (ölçü değil)"
        case .userMeasured: "Senin girdiğin ölçü"
        case .weightEstimate: "Boy ve kilodan tahmin (ölçü değil)"
        }
    }

    /// Values the app may redraw on its own when the template, height or weight changes. Anything the
    /// person shaped or typed stays exactly as it is.
    public var isRedrawable: Bool { self == .neutralStart || self == .weightEstimate }
}

public struct BodyValue: Codable, Hashable, Sendable {
    public let length: BodyLength
    public let source: ValueSource

    public init(_ length: BodyLength, source: ValueSource) {
        self.length = length
        self.source = source
    }
}

/// One user change: a slider drag or a typed measurement.
public struct BodyEdit: Codable, Hashable, Sendable {
    public let parameter: BodyParameter
    public let length: BodyLength
    public let source: ValueSource

    public init(_ parameter: BodyParameter, _ length: BodyLength, source: ValueSource) {
        self.parameter = parameter
        self.length = length
        self.source = source
    }

    public static func slider(_ parameter: BodyParameter, cm: Double) -> BodyEdit {
        BodyEdit(parameter, BodyLength(cm, .centimeters), source: .sliderShaped)
    }

    public static func measured(_ parameter: BodyParameter, _ value: Double, _ unit: LengthUnit) -> BodyEdit {
        BodyEdit(parameter, BodyLength(value, unit), source: .userMeasured)
    }
}

public enum BodyEditError: Error, Equatable, Sendable {
    case outOfSafeRange(BodyParameter)
    case unsafeGeometry(String)
    case neutralIsNotAMeasurement
    case weightOutOfRange
}

/// The canonical body truth (§102.3: one owner). Immutable value; every accepted change is a new revision.
public struct BodyProfile: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public private(set) var revision: Int
    public private(set) var values: [BodyParameter: BodyValue]
    public var preferredUnit: LengthUnit
    /// Drawing preset (ADR-011). Neutral unless the person picks another one.
    public private(set) var template: BodyTemplate
    /// Optional, typed by the person, one decimal. Shapes the picture only (ADR-011): it never becomes a
    /// measurement and never reaches size advice.
    public private(set) var weightKg: Double?

    /// Accepted weights. Like the length ranges, a drawable span, not a judgement about bodies.
    public static let weightRangeKg: ClosedRange<Double> = 30...250

    /// A new neutral body at revision 1. Every value is marked as a starting point, not a measurement.
    public static func neutral(unit: LengthUnit = .centimeters) -> BodyProfile {
        var values: [BodyParameter: BodyValue] = [:]
        for p in BodyParameter.allCases { values[p] = BodyValue(BodyLength(p.neutralStartCm, .centimeters), source: .neutralStart) }
        return BodyProfile(revision: 1, values: values, preferredUnit: unit)
    }

    /// A first body from what the person chose before creating it (ADR-011): gender (neutral if they
    /// did not choose), and optionally a typed height and weight. Every part is optional; with nothing
    /// chosen this is exactly `neutral(unit:)`. A typed height is the person's own value.
    public static func start(unit: LengthUnit = .centimeters, template: BodyTemplate = .neutral,
                             height: Double? = nil, weightKg: Double? = nil) throws(BodyEditError) -> BodyProfile {
        var p = neutral(unit: unit)
        if let height { p = try p.applying(.measured(.height, height, unit)) }
        if template != .neutral || weightKg != nil { p = try p.withAppearance(template: template, weightKg: weightKg) }
        return p.stamped(revision: 1)
    }

    public init(revision: Int, values: [BodyParameter: BodyValue], preferredUnit: LengthUnit,
                template: BodyTemplate = .neutral, weightKg: Double? = nil) {
        self.revision = revision
        self.values = values
        self.preferredUnit = preferredUnit
        self.template = template
        self.weightKg = weightKg
    }

    /// Same body at another revision (the studio stamps revisions).
    public func stamped(revision: Int) -> BodyProfile {
        BodyProfile(revision: revision, values: values, preferredUnit: preferredUnit, template: template, weightKg: weightKg)
    }

    // Records written before ADR-011 have neither key; a neutral body without weight writes neither, so
    // its stored form is unchanged.
    enum CodingKeys: String, CodingKey { case revision, values, preferredUnit, template, weightKg }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        revision = try c.decode(Int.self, forKey: .revision)
        values = try c.decode([BodyParameter: BodyValue].self, forKey: .values)
        preferredUnit = try c.decode(LengthUnit.self, forKey: .preferredUnit)
        template = try c.decodeIfPresent(BodyTemplate.self, forKey: .template) ?? .neutral
        weightKg = try c.decodeIfPresent(Double.self, forKey: .weightKg)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(revision, forKey: .revision)
        try c.encode(values, forKey: .values)
        try c.encode(preferredUnit, forKey: .preferredUnit)
        if template != .neutral { try c.encode(template, forKey: .template) }
        try c.encodeIfPresent(weightKg, forKey: .weightKg)
    }

    public subscript(_ p: BodyParameter) -> BodyValue {
        values[p] ?? BodyValue(BodyLength(p.neutralStartCm, .centimeters), source: .neutralStart)
    }

    /// Widest shoulder allowed per cm of height. Without it a 120 cm body with 60 cm shoulders folds the
    /// outline at the neck (found by V15-T-BOD-02). Real bodies sit far below it (≈0.23–0.27).
    public static let maxShoulderToHeight = 0.45

    /// The range a slider may offer for `p` given the other values: the fixed safe range, narrowed by the
    /// shoulder/height link. The UI uses it so a drag can never reach an unsafe shape.
    public func allowedRange(_ p: BodyParameter) -> ClosedRange<Double> {
        let base = p.safeRange
        // Linked bounds snap inward to the slider step, so every offered stop survives storage rounding.
        let step = BodyParameter.sliderStepCm
        switch p {
        case .shoulderWidth:
            let upper = (self[.height].length.centimeters * Self.maxShoulderToHeight / step).rounded(.down) * step
            return base.lowerBound...max(base.lowerBound, min(base.upperBound, upper))
        case .height:
            let lower = (self[.shoulderWidth].length.centimeters / Self.maxShoulderToHeight / step).rounded(.up) * step
            return min(base.upperBound, max(base.lowerBound, lower))...base.upperBound
        default:
            return base
        }
    }

    /// Range check, then a geometry check on the resulting shape. On failure nothing changes.
    public func applying(_ edit: BodyEdit) throws(BodyEditError) -> BodyProfile {
        // Starting values and weight estimates are the app's drawing, never something an edit can claim.
        guard !edit.source.isRedrawable else { throw .neutralIsNotAMeasurement }
        guard allowedRange(edit.parameter).contains(edit.length.centimeters) else { throw .outOfSafeRange(edit.parameter) }
        var next = self
        next.values[edit.parameter] = BodyValue(edit.length, source: edit.source)
        next.revision = revision + 1
        // A new height moves the weight estimate with it (same weight on a taller body is slimmer).
        if edit.parameter == .height { next.redraw() }
        _ = try Silhouette.make(for: next)
        return next
    }

    /// A new template and/or weight (nil clears it), at the next revision. Values the person shaped or
    /// typed never change; starting values and earlier weight estimates are redrawn: from height + weight
    /// when a weight is given and the estimate is available, otherwise the template's starting values.
    public func withAppearance(template: BodyTemplate, weightKg: Double?) throws(BodyEditError) -> BodyProfile {
        let weight = weightKg.map { ($0 * 10).rounded() / 10 }
        if let weight { guard weight.isFinite, Self.weightRangeKg.contains(weight) else { throw .weightOutOfRange } }
        var next = self
        next.template = template
        next.weightKg = weight
        next.revision = revision + 1
        next.redraw()
        _ = try Silhouette.make(for: next)
        return next
    }

    /// Re-derives every redrawable value from the template, height and weight. Estimates are rounded to
    /// the slider step and kept inside the range a slider could reach.
    mutating func redraw() {
        let estimate = weightKg.flatMap { BodyShapeEstimate.cm(template: template, heightCm: self[.height].length.centimeters, weightKg: $0) }
        let step = BodyParameter.sliderStepCm
        for p in BodyParameter.allCases where p != .height && self[p].source.isRedrawable {
            if let cm = estimate?[p] {
                let range = allowedRange(p)
                let snapped = min(max((cm / step).rounded() * step, range.lowerBound), range.upperBound)
                values[p] = BodyValue(BodyLength(snapped, .centimeters), source: .weightEstimate)
            } else {
                values[p] = BodyValue(BodyLength(template.startCm(p), .centimeters), source: .neutralStart)
            }
        }
    }

    /// Every parameter present and inside its safe range, and a drawable shape. Used for anything that
    /// did not come through `applying`: a stored record, an undo target.
    public func validate() throws(BodyEditError) {
        for p in BodyParameter.allCases {
            guard let v = values[p] else { throw .unsafeGeometry("missing \(p.rawValue)") }
            guard p.safeRange.contains(v.length.centimeters) else { throw .outOfSafeRange(p) }
        }
        guard allowedRange(.shoulderWidth).contains(self[.shoulderWidth].length.centimeters) else { throw .outOfSafeRange(.shoulderWidth) }
        guard revision > 0, values.count == BodyParameter.allCases.count else { throw .unsafeGeometry("shape") }
        if let weightKg { guard weightKg.isFinite, Self.weightRangeKg.contains(weightKg) else { throw .weightOutOfRange } }
        _ = try Silhouette.make(for: self)
    }

    /// Same values as `other`, at the next revision. Used by undo/redo: revisions only ever go up, so
    /// stale-write guards keep working (V15-T-ORC-08), while the parameters match exactly (V15-T-BOD-03).
    public func restoring(_ other: BodyProfile) -> BodyProfile {
        BodyProfile(revision: revision + 1, values: other.values, preferredUnit: preferredUnit, template: other.template, weightKg: other.weightKg)
    }

    /// Only typed measurements, for size advice. Slider shapes and starting values never appear here.
    public var measuredCentimeters: [BodyParameter: Double] {
        values.reduce(into: [:]) { out, pair in
            if pair.value.source == .userMeasured { out[pair.key] = pair.value.length.centimeters }
        }
    }

    public func sameShape(as other: BodyProfile) -> Bool {
        values == other.values && template == other.template && weightKg == other.weightKg
    }
}

/// Undo/redo for one editing session. Keeps profiles, not diffs, so a restore is exact.
public struct BodyEditHistory: Sendable {
    public static let limit = 50
    private var past: [BodyProfile] = []
    private var future: [BodyProfile] = []

    public init() {}

    public var canUndo: Bool { !past.isEmpty }
    public var canRedo: Bool { !future.isEmpty }

    public mutating func recordCommit(previous: BodyProfile) {
        past.append(previous)
        if past.count > Self.limit { past.removeFirst(past.count - Self.limit) }
        future.removeAll()
    }

    /// The profile to restore, and the current one goes on the redo stack.
    public mutating func undo(from current: BodyProfile) -> BodyProfile? {
        guard let target = past.popLast() else { return nil }
        future.append(current)
        return current.restoring(target)
    }

    public mutating func redo(from current: BodyProfile) -> BodyProfile? {
        guard let target = future.popLast() else { return nil }
        past.append(current)
        return current.restoring(target)
    }

    public mutating func reset() {
        past.removeAll()
        future.removeAll()
    }
}

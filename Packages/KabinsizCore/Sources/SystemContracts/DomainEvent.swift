import Foundation

/// Where an event's content came from (§105.1). `confidence` is an internal model estimate,
/// never shown as a percentage before calibration evidence exists.
public struct EventProvenance: Codable, Hashable, Sendable {
    public var sourceKind: String
    public var modelVersion: String?
    public var confidence: Double?

    public init(sourceKind: String, modelVersion: String? = nil, confidence: Double? = nil) {
        self.sourceKind = sourceKind
        self.modelVersion = modelVersion
        self.confidence = confidence
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case sourceKind = "source_kind", modelVersion = "model_version", confidence
    }
}

/// A fact that a state change was committed (§105). Commands are separate types; this is never a request.
public struct DomainEventV1<Payload: Codable & Hashable & Sendable>: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public var schemaVersion: Int
    public var eventID: UUID
    public var eventType: String
    public var occurredAtUTC: Date
    public var traceID: String
    public var causationID: UUID?
    public var sourceModule: ModuleID
    public var entityKind: String
    public var entityLocalID: String
    /// Monotonic per entity; the revision guard rejects anything not newer (V15-T-ORC-08).
    public var revision: Int
    public var payloadClassification: DataClassification
    public var provenance: EventProvenance
    public var payload: Payload
    public var ttlSeconds: Int?

    public init(
        eventID: UUID = UUID(), eventType: String, occurredAtUTC: Date, traceID: String, causationID: UUID? = nil,
        sourceModule: ModuleID, entityKind: String, entityLocalID: String, revision: Int,
        payloadClassification: DataClassification, provenance: EventProvenance, payload: Payload, ttlSeconds: Int? = nil
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.eventID = eventID
        self.eventType = eventType
        self.occurredAtUTC = occurredAtUTC
        self.traceID = traceID
        self.causationID = causationID
        self.sourceModule = sourceModule
        self.entityKind = entityKind
        self.entityLocalID = entityLocalID
        self.revision = revision
        self.payloadClassification = payloadClassification
        self.provenance = provenance
        self.payload = payload
        self.ttlSeconds = ttlSeconds
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", eventID = "event_id", eventType = "event_type"
        case occurredAtUTC = "occurred_at_utc", traceID = "trace_id", causationID = "causation_id"
        case sourceModule = "source_module", entityKind = "entity_kind", entityLocalID = "entity_local_id"
        case revision, payloadClassification = "payload_classification", provenance, payload
        case ttlSeconds = "ttl_seconds"
    }

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion,
              Self.isValidEventType(eventType),
              revision >= 1,
              !traceID.isEmpty, traceID != entityLocalID,
              !entityKind.isEmpty, !entityLocalID.isEmpty,
              causationID != eventID,
              ttlSeconds.map({ $0 >= 0 }) ?? true,
              provenance.confidence.map({ (0...1).contains($0) }) ?? true,
              !provenance.sourceKind.isEmpty
        else { throw .schemaInvalid }
    }

    /// `domain.entity.verb` in lower snake case, e.g. `wardrobe.item.categorized`.
    static func isValidEventType(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count >= 2 else { return false }
        return parts.allSatisfy { part in
            guard let first = part.first, first.isLowercase, first.isASCII else { return false }
            return part.allSatisfy { $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "_") }
        }
    }
}

/// Rejects duplicate and out-of-order events per entity so a replay never resurrects older state (§105.3).
public struct EntityRevisionGuard: Sendable {
    private struct EntityKey: Hashable, Sendable { let kind: String; let id: String }
    private var latest: [EntityKey: Int] = [:]
    private var seen: Set<UUID> = []

    public init() {}

    public func latestRevision(kind: String, id: String) -> Int? { latest[EntityKey(kind: kind, id: id)] }

    /// Records the event if it is new and newer; otherwise throws without changing anything.
    public mutating func accept<P>(_ event: DomainEventV1<P>) throws(FaultCode) {
        try event.validate()
        guard !seen.contains(event.eventID) else { throw .duplicateEvent }
        let key = EntityKey(kind: event.entityKind, id: event.entityLocalID)
        if let current = latest[key], event.revision <= current { throw .staleRevision }
        seen.insert(event.eventID)
        latest[key] = event.revision
    }
}

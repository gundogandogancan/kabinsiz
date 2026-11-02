import DomainContracts
import Foundation
import Testing
@testable import SystemContracts

struct CategorizedPayload: Codable, Hashable, Sendable {
    let category: String
    let needsUserConfirmation: Bool
    enum CodingKeys: String, CodingKey { case category, needsUserConfirmation = "needs_user_confirmation" }
}

typealias CategorizedEvent = DomainEventV1<CategorizedPayload>

func fixture(_ name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
    return try Data(contentsOf: url)
}

/// Rewrites one top-level key of a fixture (nil removes it) to build counterexamples.
func mutated(_ name: String, _ key: String, _ value: Any?) throws -> Data {
    var object = try #require(JSONSerialization.jsonObject(with: fixture(name)) as? [String: Any])
    object[key] = value
    return try JSONSerialization.data(withJSONObject: object)
}

@Suite("WP15-02 schema compatibility")
struct SchemaCompatibilityTests {
    /// Decode the golden file, re-encode, decode again: same value, and every non-null golden key survives.
    func roundTrip<T: VersionedContract & Equatable>(_ type: T.Type, _ name: String) throws {
        let golden = try fixture(name)
        let value = try ContractCoder.decode(T.self, from: golden)
        let encoded = try ContractCoder.encode(value)
        #expect(try ContractCoder.decode(T.self, from: encoded) == value)

        let goldenObject = try #require(JSONSerialization.jsonObject(with: golden) as? [String: Any])
        let encodedObject = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        let nonNullGoldenKeys = Set(goldenObject.filter { !($0.value is NSNull) }.keys)
        #expect(Set(encodedObject.keys) == nonNullGoldenKeys, "frozen JSON key names changed for \(T.self)")
    }

    @Test("Golden fixtures decode, validate and round-trip with frozen key names")
    func goldenRoundTrips() throws {
        try roundTrip(CategorizedEvent.self, "domain_event_v1")
        try roundTrip(WorkOrder.self, "work_order_v1")
        try roundTrip(EgressIntent.self, "egress_intent_v1")
        try roundTrip(EvidenceRecord.self, "evidence_record_v1")
        try roundTrip(DecisionEnvelope<VisualFidelityTier>.self, "decision_envelope_v1")
        try roundTrip(DeviceBudget.self, "device_budget_v1")
    }

    @Test("A newer schema is refused, never half-read", arguments: [
        ("domain_event_v1", "schema_version"), ("work_order_v1", "work_order_version"), ("egress_intent_v1", "schema_version"),
        ("evidence_record_v1", "schema_version"), ("decision_envelope_v1", "schema_version"), ("device_budget_v1", "schema_version"),
    ])
    func newerSchema(_ name: String, _ key: String) throws {
        let data = try mutated(name, key, 2)
        #expect(throws: FaultCode.schemaNewer) { try decodeAny(name, data) }
    }

    @Test("Missing or zero version is invalid", arguments: [nil, 0, -1] as [Int?])
    func missingVersion(_ version: Int?) throws {
        let data = try mutated("domain_event_v1", "schema_version", version)
        #expect(throws: FaultCode.schemaInvalid) { try ContractCoder.decode(CategorizedEvent.self, from: data) }
    }

    @Test("An unknown data class fails closed with its own fault")
    func unknownClassification() throws {
        let event = try mutated("domain_event_v1", "payload_classification", "PROBABLY_FINE")
        #expect(throws: FaultCode.unknownClassification) { try ContractCoder.decode(CategorizedEvent.self, from: event) }
        let egress = try mutated("egress_intent_v1", "classification", "PUBLIC")
        #expect(throws: FaultCode.unknownClassification) { try ContractCoder.decode(EgressIntent.self, from: egress) }
    }

    @Test("Unknown top-level keys are rejected: a same-version file cannot smuggle extra data", arguments: [
        ("domain_event_v1", "latitude"), ("egress_intent_v1", "device_location"), ("work_order_version_mixup", "schema_version"),
    ])
    func extraKeysRejected(_ name: String, _ key: String) throws {
        if name == "work_order_version_mixup" {
            // A work order carrying `schema_version` is not a work order of a newer version; it is malformed.
            let data = try mutated("work_order_v1", key, 1)
            #expect(throws: FaultCode.schemaInvalid) { try ContractCoder.decode(WorkOrder.self, from: data) }
            return
        }
        let data = try mutated(name, key, 41.0)
        #expect(throws: FaultCode.schemaInvalid) { try decodeAny(name, data) }
    }

    @Test("Dates keep sub-second precision, so ordering checks agree before writing and after reading")
    func fractionalDates() throws {
        let now = Date()
        var event = try ContractCoder.decode(CategorizedEvent.self, from: fixture("domain_event_v1"))
        event.occurredAtUTC = now
        let back = try ContractCoder.decode(CategorizedEvent.self, from: ContractCoder.encode(event))
        #expect(abs(back.occurredAtUTC.timeIntervalSince(now)) < 0.001)

        // Counterexample from review: collected 10.2 s, expires 10.7 s used to encode fine and then fail to decode.
        let record = EvidenceRecord(
            evidenceID: "e", factKey: "k", subjectProductID: "p", variantID: "v", factValue: "1", unit: nil,
            sourceType: .syntheticFixture, sourceURIOrLicensedDatasetID: "ds", licenseID: nil,
            collectedAt: Date(timeIntervalSince1970: 10.2), expiresAt: Date(timeIntervalSince1970: 10.7),
            confidenceKind: .heuristic, verificationMethod: .none
        )
        let decoded = try ContractCoder.decode(EvidenceRecord.self, from: ContractCoder.encode(record))
        #expect(try #require(decoded.expiresAt) > decoded.collectedAt)
        // Whole-second files written by other tools still read.
        #expect(try ContractCoder.decode(EvidenceRecord.self, from: fixture("evidence_record_v1")).collectedAt == Date(timeIntervalSince1970: 1_793_696_400))
    }

    @Test("An unknown class inside a list is still reported as a classification fault")
    func unknownClassInList() throws {
        let data = try mutated("work_order_v1", "allowed_data_classes", ["SYNTHETIC_FIXTURE", "LOCAL_PRIVATE_SCHEMAS"])
        #expect(throws: FaultCode.unknownClassification) { try ContractCoder.decode(WorkOrder.self, from: data) }
    }

    @Test("A boolean, fractional or string version is not a version")
    func oddVersions() throws {
        for version in [true, 1.5, "1"] as [Any] {
            let data = try mutated("device_budget_v1", "schema_version", version)
            #expect(throws: FaultCode.schemaInvalid) { try ContractCoder.decode(DeviceBudget.self, from: data) }
        }
    }

    @Test("Set-valued fields encode to identical bytes every time")
    func stableBytes() throws {
        let budget = DeviceBudget.defaults(for: .turbo)
        let first = try ContractCoder.encode(budget)
        for _ in 0..<20 { #expect(try ContractCoder.encode(budget) == first) }
        let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
        let registry = try encoder.encode(ModuleRegistry.p0Descriptors)
        for _ in 0..<20 { #expect(try encoder.encode(ModuleRegistry.p0Descriptors) == registry) }
    }

    @Test("Garbage and truncated input are invalid, not crashes", arguments: ["", "{", "[]", "null", "{\"schema_version\":\"1\"}"])
    func garbage(_ text: String) {
        #expect(throws: FaultCode.schemaInvalid) { try ContractCoder.decode(CategorizedEvent.self, from: Data(text.utf8)) }
    }

    @Test("Persisted raw values are frozen; renaming one breaks this test on purpose")
    func frozenRawValues() throws {
        let frozen = try #require(JSONSerialization.jsonObject(with: fixture("frozen_raw_values")) as? [String: [String]])
        #expect(DataClassification.allCases.map(\.rawValue).sorted() == frozen["DataClassification"])
        #expect(Capability.allCases.map(\.rawValue).sorted() == frozen["Capability"])
        #expect(FaultCode.allCases.map(\.rawValue).sorted() == frozen["FaultCode"])
        #expect(TaskState.allCases.map(\.rawValue).sorted() == frozen["TaskState"])
    }

    @Test("Encoding refuses an invalid value instead of writing it")
    func encodeValidates() {
        var budget = DeviceBudget.defaults(for: .turbo)
        budget.allowsPhysics = true
        #expect(throws: FaultCode.policyDenied) { try ContractCoder.encode(budget) }
    }

    private func decodeAny(_ name: String, _ data: Data) throws {
        switch name {
        case "domain_event_v1": _ = try ContractCoder.decode(CategorizedEvent.self, from: data)
        case "work_order_v1": _ = try ContractCoder.decode(WorkOrder.self, from: data)
        case "egress_intent_v1": _ = try ContractCoder.decode(EgressIntent.self, from: data)
        case "evidence_record_v1": _ = try ContractCoder.decode(EvidenceRecord.self, from: data)
        case "decision_envelope_v1": _ = try ContractCoder.decode(DecisionEnvelope<VisualFidelityTier>.self, from: data)
        default: _ = try ContractCoder.decode(DeviceBudget.self, from: data)
        }
    }
}

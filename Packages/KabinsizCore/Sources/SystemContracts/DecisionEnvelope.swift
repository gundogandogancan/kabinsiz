import DomainContracts
import Foundation

/// What the orchestrator returns for one user intent (§103). The UI renders only this: a value with
/// its confidence, reasons and limits, or a fault with a safe message. Never an endless spinner.
public struct DecisionEnvelope<Value: Codable & Hashable & Sendable>: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public var schemaVersion: Int
    public var traceID: String
    public var state: TaskState
    public var value: Value?
    public var confidence: ConfidenceKind
    /// At most three short reasons (§60.1).
    public var reasons: [String]
    public var limitations: [String]
    public var fault: FaultCode?
    /// `EvidenceRecord.evidenceID`s behind any verified claim (INV-15).
    public var evidenceIDs: [String]

    public init(
        traceID: String, state: TaskState, value: Value?, confidence: ConfidenceKind, reasons: [String] = [],
        limitations: [String] = [], fault: FaultCode? = nil, evidenceIDs: [String] = []
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.traceID = traceID
        self.state = state
        self.value = value
        self.confidence = confidence
        self.reasons = reasons
        self.limitations = limitations
        self.fault = fault
        self.evidenceIDs = evidenceIDs
    }

    /// An envelope for a failure. The state says why, so a crash is never shown as a policy block.
    public static func failure(traceID: String, _ fault: FaultCode) -> DecisionEnvelope {
        DecisionEnvelope(traceID: traceID, state: state(for: fault), value: nil, confidence: .abstain, fault: fault)
    }

    static func state(for fault: FaultCode) -> TaskState {
        switch fault {
        case .cancelled: .cancelled
        case .timedOut: .timedOut
        case .policyDenied, .capabilityNotGranted, .unknownModule, .egressBlocked, .unknownClassification, .dataRightsMissing: .blockedPolicy
        case .schemaInvalid, .schemaNewer, .staleRevision, .duplicateEvent, .invalidTransition, .moduleFailed,
             .resourceDenied, .storageCorrupted, .offline: .failed
        }
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", traceID = "trace_id", state, value, confidence, reasons, limitations, fault
        case evidenceIDs = "evidence_ids"
    }

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion, !traceID.isEmpty, state.isTerminal, reasons.count <= 3
        else { throw .schemaInvalid }
        switch state {
        case .completed:
            guard value != nil, fault == nil else { throw .schemaInvalid }
        case .degraded:
            // A fallback result says what it is missing.
            guard value != nil, !limitations.isEmpty else { throw .schemaInvalid }
        case .cancelled, .timedOut, .failed, .blockedPolicy:
            guard value == nil, fault != nil, confidence == .abstain else { throw .schemaInvalid }
        default:
            throw .schemaInvalid
        }
        // A "verified" answer must be a clean completion citing distinct, non-blank evidence (V15-T-AGT-06).
        if confidence == .verifiedFacts {
            guard state == .completed, fault == nil else { throw .schemaInvalid }
            let ids = evidenceIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard !ids.isEmpty, !ids.contains(""), Set(ids).count == ids.count else { throw .dataRightsMissing }
        }
    }

    /// Shape checks plus resolution: every cited ID must exist and be displayable as verified at `now`.
    /// An invented ID, or one pointing at a synthetic, expired or revoked fact, fails.
    public func validate(citing records: [EvidenceRecord], now: Date) throws(FaultCode) {
        try validate()
        guard confidence == .verifiedFacts else { return }
        let byID = Dictionary(records.map { ($0.evidenceID, $0) }, uniquingKeysWith: { a, _ in a })
        for id in evidenceIDs {
            guard let record = byID[id], record.isDisplayableAsVerified(at: now) else { throw .dataRightsMissing }
        }
    }
}

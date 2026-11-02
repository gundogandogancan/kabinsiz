import Foundation

/// Development task packet (§121.1). Describes what one agent may touch; it grants nothing at runtime.
public struct WorkOrder: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var versionKey: String { "work_order_version" }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum ExternalAccess: String, Codable, Sendable {
        case forbidden = "forbidden"
        /// Only after a human approved this specific external action in chat (§130).
        case humanApproved = "human_approved"
    }

    public enum Deliverable: String, Codable, CaseIterable, Sendable {
        case code = "CODE", unitTest = "UNIT_TEST", uiTest = "UI_TEST", threatModel = "THREAT_MODEL"
        case adr = "ADR", evidence = "EVIDENCE", documentation = "DOCUMENTATION"
    }

    public enum Status: String, Codable, CaseIterable, Sendable {
        case notStarted = "NOT_STARTED", inProgress = "IN_PROGRESS", blocked = "BLOCKED"
        case awaitingReview = "AWAITING_REVIEW", accepted = "ACCEPTED", rejected = "REJECTED"
    }

    public var workOrderVersion: Int
    public var id: String
    public var requester: String
    public var assignee: String
    public var problem: String
    public var dependencies: [String]
    public var allowedPaths: [String]
    public var prohibitedPaths: [String]
    public var allowedDataClasses: [DataClassification]
    public var externalAccess: ExternalAccess
    public var interfaces: [String]
    public var deliverables: [Deliverable]
    public var acceptanceTests: [String]
    public var qualityGate: String
    public var maxScope: String
    public var status: Status

    public init(
        id: String, requester: String, assignee: String, problem: String, dependencies: [String] = [],
        allowedPaths: [String], prohibitedPaths: [String] = [], allowedDataClasses: [DataClassification],
        externalAccess: ExternalAccess = .forbidden, interfaces: [String] = [], deliverables: [Deliverable],
        acceptanceTests: [String], qualityGate: String, maxScope: String, status: Status = .notStarted
    ) {
        self.workOrderVersion = Self.currentSchemaVersion
        self.id = id
        self.requester = requester
        self.assignee = assignee
        self.problem = problem
        self.dependencies = dependencies
        self.allowedPaths = allowedPaths
        self.prohibitedPaths = prohibitedPaths
        self.allowedDataClasses = allowedDataClasses
        self.externalAccess = externalAccess
        self.interfaces = interfaces
        self.deliverables = deliverables
        self.acceptanceTests = acceptanceTests
        self.qualityGate = qualityGate
        self.maxScope = maxScope
        self.status = status
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case workOrderVersion = "work_order_version", id, requester, assignee, problem, dependencies
        case allowedPaths = "allowed_paths", prohibitedPaths = "prohibited_paths"
        case allowedDataClasses = "allowed_data_classes", externalAccess = "external_access"
        case interfaces, deliverables, acceptanceTests = "acceptance_tests", qualityGate = "quality_gate"
        case maxScope = "max_scope", status
    }

    public func validate() throws(FaultCode) {
        guard workOrderVersion == Self.currentSchemaVersion,
              id.hasPrefix("WP15-"), id.count > 5,
              !requester.isEmpty, !assignee.isEmpty, !problem.isEmpty, !qualityGate.isEmpty,
              !allowedPaths.isEmpty, !deliverables.isEmpty,
              !dependencies.contains(id),
              // Test deliverables need named acceptance tests, never "TBD".
              !deliverables.contains(where: { $0 == .unitTest || $0 == .uiTest }) || !acceptanceTests.isEmpty,
              allowedPaths.allSatisfy(Self.isNormalized), prohibitedPaths.allSatisfy(Self.isNormalized),
              allowedPaths.allSatisfy({ path in !prohibitedPaths.contains { Self.covers($0, path) } })
        else { throw .schemaInvalid }
        // Real person data is never part of a development packet (§121.1, INV-01).
        guard !allowedDataClasses.contains(.localSensitive) else { throw .policyDenied }
    }

    /// `Sources/Security/**` covers `Sources/Security/Vault.swift` and itself. Paths with `..`, `.`,
    /// empty segments or a leading `/` are refused before matching, so they cannot climb out of scope.
    public func permits(path: String) -> Bool {
        Self.isNormalized(path)
            && allowedPaths.contains { Self.covers($0, path) } && !prohibitedPaths.contains { Self.covers($0, path) }
    }

    static func isNormalized(_ path: String) -> Bool {
        guard !path.isEmpty, !path.hasPrefix("/"), !path.contains("\\") else { return false }
        let segments = path.split(separator: "/", omittingEmptySubsequences: false)
        return !segments.contains { $0.isEmpty || $0 == "." || $0 == ".." }
    }

    static func covers(_ pattern: String, _ path: String) -> Bool {
        if pattern.hasSuffix("/**") {
            let prefix = String(pattern.dropLast(3))
            return path == prefix || path.hasPrefix(prefix + "/") || (path.hasSuffix("/**") && covers(pattern, String(path.dropLast(3))))
        }
        return pattern == path
    }
}

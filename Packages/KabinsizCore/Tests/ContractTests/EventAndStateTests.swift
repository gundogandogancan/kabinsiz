import Foundation
import Testing
@testable import SystemContracts

@Suite("Events and task lifecycle")
struct EventAndStateTests {
    func event(_ revision: Int, id: UUID = UUID(), entity: String = "item-1") -> CategorizedEvent {
        CategorizedEvent(
            eventID: id, eventType: "wardrobe.item.categorized", occurredAtUTC: Date(timeIntervalSince1970: 0), traceID: "t-1",
            sourceModule: .garmentVision, entityKind: "wardrobe_item", entityLocalID: entity, revision: revision,
            payloadClassification: .localPrivate, provenance: .init(sourceKind: "user_selected_photo"),
            payload: .init(category: "shirt", needsUserConfirmation: true)
        )
    }

    @Test("V15-T-ORC-08 out-of-order revisions are rejected and the latest valid state is kept")
    func staleRevisions() throws {
        var guardian = EntityRevisionGuard()
        try guardian.accept(event(4))
        #expect(throws: FaultCode.staleRevision) { try guardian.accept(event(3)) }
        #expect(throws: FaultCode.staleRevision) { try guardian.accept(event(4)) }
        #expect(guardian.latestRevision(kind: "wardrobe_item", id: "item-1") == 4)
        try guardian.accept(event(5))
        // Another entity has its own sequence.
        try guardian.accept(event(1, entity: "item-2"))
        #expect(guardian.latestRevision(kind: "wardrobe_item", id: "item-1") == 5)
    }

    @Test("A replayed event is a duplicate even if its revision would be newer elsewhere")
    func duplicates() throws {
        var guardian = EntityRevisionGuard()
        let id = UUID()
        try guardian.accept(event(1, id: id))
        #expect(throws: FaultCode.duplicateEvent) { try guardian.accept(event(2, id: id)) }
        #expect(guardian.latestRevision(kind: "wardrobe_item", id: "item-1") == 1)
    }

    @Test("Malformed events are rejected before they touch state", arguments: [
        "Wardrobe.item", "wardrobe", "wardrobe..item", "wardrobe.item-x", "wardrobe.ıtem", ".item", "wardrobe.item.٣", "wardrobe.item.x½",
    ])
    func badEventType(_ type: String) {
        var e = event(1)
        e.eventType = type
        #expect(throws: FaultCode.schemaInvalid) { try e.validate() }
    }

    @Test("Revision 0, confidence outside 0…1, negative TTL and trace = entity id are invalid")
    func badFields() {
        var a = event(0)
        #expect(throws: FaultCode.schemaInvalid) { try a.validate() }
        a = event(1); a.provenance.confidence = 1.5
        #expect(throws: FaultCode.schemaInvalid) { try a.validate() }
        a = event(1); a.ttlSeconds = -1
        #expect(throws: FaultCode.schemaInvalid) { try a.validate() }
        a = event(1); a.traceID = a.entityLocalID
        #expect(throws: FaultCode.schemaInvalid) { try a.validate() }
        a = event(1); a.causationID = a.eventID
        #expect(throws: FaultCode.schemaInvalid) { try a.validate() }
    }

    @Test("V15-T-ORC-10 terminal states reject every transition, including COMPLETED→RUNNING")
    func terminalImmutable() {
        for state in TaskState.allCases where state.isTerminal {
            for next in TaskState.allCases {
                #expect(throws: FaultCode.invalidTransition) { try state.transition(to: next) }
            }
        }
    }

    @Test("Happy path and the only legal shortcuts")
    func lifecycle() throws {
        var s = TaskState.created
        for next in [TaskState.authorized, .scheduled, .running, .partial, .partial, .completed] { s = try s.transition(to: next) }
        #expect(s == .completed)
        #expect(throws: FaultCode.invalidTransition) { try TaskState.created.transition(to: .running) }
        #expect(throws: FaultCode.invalidTransition) { try TaskState.running.transition(to: .blockedPolicy) }
        #expect(throws: FaultCode.invalidTransition) { try TaskState.authorized.transition(to: .completed) }
        for live in TaskState.allCases where !live.isTerminal {
            #expect(live.canTransition(to: .cancelled))
            #expect(live.canTransition(to: .failed))
        }
    }
}

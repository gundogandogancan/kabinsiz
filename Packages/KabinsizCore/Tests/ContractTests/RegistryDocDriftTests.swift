import Foundation
import Testing
@testable import SystemContracts

@Suite("Docs stay in sync with code")
struct RegistryDocDriftTests {
    @Test("docs/system/AGENT_REGISTRY.yaml lists exactly the registered modules and capabilities")
    func agentRegistryYAML() throws {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let text = try String(contentsOf: repo.appendingPathComponent("docs/system/AGENT_REGISTRY.yaml"), encoding: .utf8)
        var documented: [String: Set<String>] = [:]
        var current: String?
        for line in text.split(separator: "\n").map({ $0.trimmingCharacters(in: .whitespaces) }) {
            if line.hasPrefix("- id: ") { current = String(line.dropFirst(6)) }
            if line.hasPrefix("capabilities: ["), let id = current {
                let list = line.dropFirst("capabilities: [".count).dropLast()
                documented[id] = Set(list.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
            }
        }
        let code = Dictionary(uniqueKeysWithValues: ModuleRegistry.p0Descriptors.map { ($0.id.rawValue, Set($0.allCapabilities.map(\.rawValue))) })
        #expect(documented == code)
    }
}

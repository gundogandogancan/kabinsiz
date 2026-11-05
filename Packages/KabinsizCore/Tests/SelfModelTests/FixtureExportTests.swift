import Foundation
import ProductCapture
import Testing
@testable import SelfModel

/// Writes the iOS Simulator fixture (the Simulator has no Vision body-pose model): the joints Apple Vision
/// reads on macOS from our own mannequin photo person-c. Runs only with SELFMODEL_FIXTURE_OUT set.
@Test(.enabled(if: ProcessInfo.processInfo.environment["SELFMODEL_FIXTURE_OUT"] != nil))
func exportSimulatorFixture() async throws {
    let out = URL(fileURLWithPath: ProcessInfo.processInfo.environment["SELFMODEL_FIXTURE_OUT"]!)
    let keypoints = try await VisionLane.run { try PoseReader.read(fixture("person-c")) }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    try encoder.encode(keypoints).write(to: out.appendingPathComponent("SelfModelFixturePose.json"))
    let src = Bundle.module.url(forResource: "Fixtures/person-c", withExtension: "jpg")!
    let dst = out.appendingPathComponent("SelfModelFixture.jpg")
    try? FileManager.default.removeItem(at: dst)
    try FileManager.default.copyItem(at: src, to: dst)
}

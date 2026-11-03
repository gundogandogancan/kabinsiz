// Reads the Simulator mirror fixture (MirrorFixture.jpg, our own Blender mannequin) with Apple Vision on
// macOS and writes the pose the iOS Simulator cannot compute itself (VNDetectHumanBodyPoseRequest has
// no setup there). Output: 0…1 image coordinates, y down, as MirrorVision produces on the device.
// Usage: swift tools/garments/fixture_pose.swift <MirrorFixture.jpg> <MirrorFixturePose.json>
import AppKit
import Vision

let names: [(VNHumanBodyPoseObservation.JointName, String)] = [
    (.nose, "nose"), (.neck, "neck"), (.leftShoulder, "leftShoulder"), (.rightShoulder, "rightShoulder"),
    (.leftElbow, "leftElbow"), (.rightElbow, "rightElbow"), (.leftWrist, "leftWrist"), (.rightWrist, "rightWrist"),
    (.leftHip, "leftHip"), (.rightHip, "rightHip"), (.leftKnee, "leftKnee"), (.rightKnee, "rightKnee"),
    (.leftAnkle, "leftAnkle"), (.rightAnkle, "rightAnkle"),
]
let args = CommandLine.arguments
guard args.count == 3, let image = NSImage(contentsOf: URL(fileURLWithPath: args[1])) else { fatalError("usage") }
var rect = CGRect(origin: .zero, size: image.size)
let cg = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
let request = VNDetectHumanBodyPoseRequest()
try VNImageRequestHandler(cgImage: cg).perform([request])
guard let observation = request.results?.first, request.results?.count == 1 else { fatalError("expected one figure") }
let points = try observation.recognizedPoints(.all)
var joints: [String: [Double]] = [:]
for (vn, name) in names {
    if let p = points[vn], p.confidence > 0.3 { joints[name] = [Double(p.location.x), Double(1 - p.location.y)] }
}
let out: [String: Any] = [
    "provenance": "OWNED_ORIGINAL",
    "source": "Apple Vision VNDetectHumanBodyPoseRequest on macOS, from MirrorFixture.jpg",
    "width": cg.width, "height": cg.height, "joints": joints,
]
let data = try JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
try data.write(to: URL(fileURLWithPath: args[2]))
print("joints:", joints.count)

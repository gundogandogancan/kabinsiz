import BodyGeometry
import CoreGraphics
import Foundation
import Octopus
import ProductCapture
import SystemContracts

/// Everything the self-model offers the user from one photo. Each part is a proposal: nothing reaches the
/// body profile, the 3D figure or the wardrobe until the user accepts that part.
public struct SelfModelProposal: Codable, Hashable, Sendable {
    public let appearance: FaceAppearance?
    /// The face crop as PNG for the 3D head (Vault only). `nil` if the user did not opt into the face texture.
    public let faceTexturePNG: Data?
    public let body: BodyReading?
    public let worn: WornGarmentReading?
    public let brands: [BrandMarkReading]
    public let maskMethod: PersonMaskReader.Method
    /// "Simülatör fikstürü" when the joints came from a stored file, never hidden.
    public let poseSource: String
}

/// The user's chosen photo, passed by reference through the task graph. Read only.
public struct SelfPhoto: @unchecked Sendable {
    public let image: CGImage
    public init(_ image: CGImage) { self.image = image }
}

/// The self-model as one Octopus run (the "agent system"): every reader is a task node with its own module,
/// its own granted capabilities and a deadline; the coordinator authorizes, budgets, runs levels concurrently
/// and assembles one envelope. A node that fails degrades the run and says so; it never invents a value.
public enum SelfModelPipeline {
    /// OCT-06 Body Landmark Lab is not in the P0 table; the self-model registers it here, read-only.
    public static let bodyLandmarkLab = ModuleDescriptor(
        id: .bodyLandmarkLab, owner: "AG-05", inputs: ["UserSelectedImage"], outputs: ["BodyKeypoints", "PersonMask", "FaceAppearance"],
        readScopes: [.photosReadUserSelected], resourceCost: .heavy, deadlineMs: 8_000,
        confidencePolicy: "Uncalibrated: every value is shown as an estimate the user accepts or drops",
        failureFallback: "Manual body and appearance entry",
        prohibitedActions: ["Identity recognition or face templates", "Network", "Store the photo", "Infer body form or sex",
                            "Read photos the user did not choose"],
        securityTier: .low, implementedBy: ["SelfModel.PoseReader", "SelfModel.PersonMaskReader", "SelfModel.AppearanceReader"]
    )

    public static func registry() -> ModuleRegistry {
        (try? ModuleRegistry(ModuleRegistry.p0Descriptors + [bodyLandmarkLab])) ?? .denyAll
    }

    public struct Options: Sendable {
        public var userHeightCm: Double?
        public var brands: [BrandWordmark]
        /// The face texture is a separate opt-in (v3.5 §D): appearance colours alone do not need it.
        public var makeFaceTexture: Bool
        /// DEBUG Simulator fixture: joints read on macOS beforehand (the Simulator has no pose model).
        public var storedKeypoints: BodyKeypoints?
        public var useVisionMask: Bool
        /// Stretches every node deadline. Package tests run many Vision readers side by side on one Mac and
        /// check results, not speed; the app always runs at 1.
        package var deadlineScale: Double = 1

        public init(userHeightCm: Double?, brands: [BrandWordmark] = [], makeFaceTexture: Bool = false,
                    storedKeypoints: BodyKeypoints? = nil, useVisionMask: Bool = true) {
            self.userHeightCm = userHeightCm
            self.brands = brands
            self.makeFaceTexture = makeFaceTexture
            self.storedKeypoints = storedKeypoints
            self.useVisionMask = useVisionMask
        }
    }

    struct MaskOutput: Sendable { let mask: PersonMask; let method: PersonMaskReader.Method }
    struct PoseOutput: Sendable { let keypoints: BodyKeypoints; let source: String }
    struct AppearanceOutput: Sendable { let appearance: FaceAppearance?; let texture: Data? }

    public static func graph(options: Options) throws(FaultCode) -> TaskGraph {
        let photoCap: Set<Capability> = [.photosReadUserSelected]
        let stored = options.storedKeypoints
        let useVision = options.useVisionMask
        let wantsTexture = options.makeFaceTexture
        return try TaskGraph([
            // One heavy slot for the whole graph (the balanced tier grants one): the segmentation is the heavy part.
            TaskNode(id: "pose", module: .bodyLandmarkLab, capabilities: photoCap, reads: ["photo"], deadline: .seconds(8) * options.deadlineScale) { inputs in
                let photo: SelfPhoto = try inputs.context("photo")
                if let stored { return PoseOutput(keypoints: stored, source: "Simülatör fikstürü: eklemler önceden okundu") }
                return PoseOutput(keypoints: try await VisionLane.run { try PoseReader.read(photo.image) }, source: "Apple Vision, cihazda")
            },
            TaskNode(id: "mask", module: .bodyLandmarkLab, capabilities: photoCap, reads: ["photo"], dependsOn: ["pose"],
                     deadline: .seconds(8) * options.deadlineScale, isHeavy: true) { inputs in
                let photo: SelfPhoto = try inputs.context("photo")
                let pose: PoseOutput = try inputs.upstream("pose")
                return try await VisionLane.run {
                    let (mask, method) = try PersonMaskReader.read(photo.image, useVision: useVision, keypoints: pose.keypoints)
                    return MaskOutput(mask: mask, method: method)
                }
            },
            TaskNode(id: "appearance", module: .bodyLandmarkLab, capabilities: photoCap, reads: ["photo"], dependsOn: ["pose", "mask"],
                     deadline: .seconds(4) * options.deadlineScale,
                     fallback: { _ in AppearanceOutput(appearance: nil, texture: nil) },
                     fallbackLimitation: "Yüz bölgesi okunamadı: ten ve saç rengi önerilmedi.") { inputs in
                let photo: SelfPhoto = try inputs.context("photo")
                let pose: PoseOutput = try inputs.upstream("pose"), mask: MaskOutput = try inputs.upstream("mask")
                return try await VisionLane.run {
                    let appearance = try AppearanceReader.read(photo.image, keypoints: pose.keypoints, mask: mask.mask)
                    let texture = wantsTexture ? FaceTexture.make(photo.image, appearance: appearance, matte: appearance.skinRGB).flatMap(FaceTexture.png) : nil
                    return AppearanceOutput(appearance: appearance, texture: texture)
                }
            },
            TaskNode(id: "body", module: .bodyGeometry, capabilities: [.bodyReadExact], reads: ["height"], dependsOn: ["pose", "mask"],
                     deadline: .seconds(2) * options.deadlineScale,
                     fallback: { _ in Optional<BodyReading>.none as any Sendable },
                     fallbackLimitation: "Beden okunmadı: boyunu yazınca, fotoğrafta baştan ayağa göründüğünde ve kolların gövdeden biraz açıkken tahmin çıkar.") { inputs in
                let height: Double? = try inputs.context("height")
                let pose: PoseOutput = try inputs.upstream("pose"), mask: MaskOutput = try inputs.upstream("mask")
                return Optional(try BodyProportionReader.read(keypoints: pose.keypoints, mask: mask.mask, userHeightCm: height)) as any Sendable
            },
            TaskNode(id: "worn", module: .garmentVision, capabilities: photoCap, reads: ["photo"], dependsOn: ["pose", "mask", "appearance"],
                     deadline: .seconds(4) * options.deadlineScale,
                     fallback: { _ in Optional<WornGarmentReading>.none as any Sendable },
                     fallbackLimitation: "Üzerindeki giysiler okunamadı.") { inputs in
                let photo: SelfPhoto = try inputs.context("photo")
                let pose: PoseOutput = try inputs.upstream("pose"), mask: MaskOutput = try inputs.upstream("mask")
                let look: AppearanceOutput = try inputs.upstream("appearance")
                // Skin from the face; without it, from a wrist, so a bare arm is never read as a sleeve.
                let skin = look.appearance?.skinRGB ?? SIMD3(0.62, 0.47, 0.38)
                let worn = try await VisionLane.run { try WornGarmentReader.read(photo.image, keypoints: pose.keypoints, mask: mask.mask, skin: skin) }
                return Optional(worn) as any Sendable
            },
            TaskNode(id: "brand", module: .garmentVision, capabilities: photoCap, reads: ["photo", "brands"], dependsOn: ["worn"],
                     deadline: .seconds(4) * options.deadlineScale,
                     fallback: { _ in [BrandMarkReading]() },
                     fallbackLimitation: "Marka yazısı okunamadı.") { inputs in
                let photo: SelfPhoto = try inputs.context("photo")
                let brands: [BrandWordmark] = try inputs.context("brands")
                let worn: WornGarmentReading? = try inputs.upstream("worn")
                // A chest print sits near the neckline, above the colour region: read a wider box.
                let regions = worn?.garments.filter { $0.slot != .shoes }.map { $0.region.insetBy(dx: -$0.region.width * 0.3, dy: -$0.region.height * 0.25) } ?? []
                return try await VisionLane.run { BrandMarkReader.read(photo.image, regions: regions, brands: brands) }
            },
        ])
    }

    /// Runs the graph on the coordinator. The photo lives only in this call's memory.
    public static func run(_ image: CGImage, options: Options, coordinator: OctopusCoordinator? = nil) async -> RunOutcome<SelfModelProposal> {
        let octopus = coordinator ?? OctopusCoordinator(registry: registry())
        // The graph is static and valid (tested); a failure here is a programming error, reported as such.
        guard let graph = try? self.graph(options: options) else { preconditionFailure("SelfModelPipeline graph invalid") }
        let context = ContextSnapshot([
            "photo": ContextEntry(SelfPhoto(image), requires: .photosReadUserSelected),
            "height": ContextEntry(options.userHeightCm, requires: .bodyReadExact),
            // The brand list comes from the licensed catalogue; reading it needs no extra right, the photo does.
            "brands": ContextEntry(options.brands, requires: .photosReadUserSelected),
        ])
        return await octopus.run(graph, context: context, priority: .p1UserRequested, confidence: .heuristic) { out in
            guard let pose = out["pose"] as? PoseOutput, let mask = out["mask"] as? MaskOutput else { throw FaultCode.schemaInvalid }
            let look = out["appearance"] as? AppearanceOutput
            return SelfModelProposal(
                appearance: look?.appearance, faceTexturePNG: look?.texture,
                body: out["body"] as? BodyReading, worn: out["worn"] as? WornGarmentReading,
                brands: out["brand"] as? [BrandMarkReading] ?? [], maskMethod: mask.method, poseSource: pose.source
            )
        }
    }
}

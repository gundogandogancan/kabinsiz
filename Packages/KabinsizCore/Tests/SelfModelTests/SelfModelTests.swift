import BodyGeometry
import CoreGraphics
import Foundation
import ImageIO
import Octopus
import ProductCapture
import SystemContracts
import Testing
@testable import ProductCapture
@testable import SelfModel

// Fixtures: our own Blender mannequin (tools/garments/build_garment_sprites.py --mannequin --variant),
// OWNED_ORIGINAL, no real person. Ground truth from the script's geometry (metres → cm):
//   height (head top) 177.8; shoulder outer 2×(0.190+0.052) = 48.4 → acromion ≈ 0.88 × 48.4 = 42.6;
//   chest ellipse (0.170, 0.112 half axes) ≈ 89.6; waist (0.147, 0.106) ≈ 80.1.
// A: navy long sleeve + "ORNEK A" chest print, brown trousers, black shoes, dark short hair.
// B: light skin, blond long hair, red tee, blue shorts, white shoes.
// C: dark skin, black short hair, green tee, black trousers and shoes.

func fixture(_ name: String) -> CGImage {
    let url = Bundle.module.url(forResource: "Fixtures/\(name)", withExtension: "jpg")!
    let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(src, 0, nil)!
}

let brands = [BrandWordmark(brandID: "ornek-a", displayName: "Örnek Marka A", marks: ["ORNEK A"]),
              BrandWordmark(brandID: "ornek-b", displayName: "Örnek Marka B", marks: ["ORNEK B"])]

extension SelfModelPipeline.Options {
    /// Results, not speed: other suites share Vision on this Mac (`deadlineScale`).
    static func testing(userHeightCm: Double?, brands: [BrandWordmark] = [], makeFaceTexture: Bool = false) -> Self {
        var o = Self(userHeightCm: userHeightCm, brands: brands, makeFaceTexture: makeFaceTexture)
        o.deadlineScale = 6
        return o
    }
}

actor ProposalCache {
    static let shared = ProposalCache()
    private var done: [String: RunOutcome<SelfModelProposal>] = [:]
    func get(_ name: String) async -> RunOutcome<SelfModelProposal> {
        if let d = done[name] { return d }
        let out = await SelfModelPipeline.run(fixture(name), options: .testing(userHeightCm: 178, brands: brands, makeFaceTexture: true))
        done[name] = out
        return out
    }
}

func proposal(_ name: String) async throws -> SelfModelProposal {
    let out = await ProposalCache.shared.get(name)
    return try #require(out.envelope.value, "\(name): \(out.envelope.state) \(out.envelope.fault as Any)")
}

@Suite("V37-01 self-model from one photo (SELF-T01…)")
struct SelfModelTests {
    @Test("SELF-T01 every node runs on Vision and the run completes", arguments: ["person-a", "person-b", "person-c"])
    func completes(_ name: String) async throws {
        let out = await ProposalCache.shared.get(name)
        #expect(out.envelope.state == .completed, "\(out.envelope.limitations)")
        #expect(out.nodeStates.values.allSatisfy { $0 == .completed })
        #expect(try await proposal(name).poseSource == "Apple Vision, cihazda")
    }

    @Test("SELF-T02 skin is read from the face: light < medium < dark")
    func skinOrder() async throws {
        let a = try #require(try await proposal("person-a").appearance)
        let b = try #require(try await proposal("person-b").appearance)
        let c = try #require(try await proposal("person-c").appearance)
        let L = { (x: FaceAppearance) in GarmentPhotoAnalyzer.toLab(x.skinRGB).x }
        #expect(L(b) > L(a) && L(a) > L(c))
        #expect(b.skinToneStep < c.skinToneStep)
    }

    @Test("SELF-T03 hair colour and length: blond long, dark short")
    func hair() async throws {
        let a = try #require(try await proposal("person-a").appearance)
        let b = try #require(try await proposal("person-b").appearance)
        let c = try #require(try await proposal("person-c").appearance)
        #expect(b.hairLength == .long)
        #expect(a.hairLength == .short && c.hairLength == .short)
        let lab = { (x: FaceAppearance) in GarmentPhotoAnalyzer.toLab(x.hairRGB!) }
        #expect(lab(b).z > lab(a).z + 0.05, "blond is yellower")
        #expect(lab(a).x < 0.5 && lab(c).x < 0.5, "dark hair")
        #expect(lab(b).x > 0.7, "light hair")
    }

    @Test("SELF-T04 body estimates within 10% of the mannequin's geometry, with ranges", arguments: ["person-a", "person-b", "person-c"])
    func body(_ name: String) async throws {
        let body = try #require(try await proposal(name).body)
        let truth: [(BodyParameter, Double)] = [(.shoulderWidth, 42.6), (.chest, 89.6), (.waist, 80.1)]
        for (p, cm) in truth {
            let e = try #require(body.estimate(p))
            #expect(abs(e.centimeters - cm) / cm < 0.10, "\(name) \(p) \(e.centimeters) vs \(cm)")
            #expect(e.low < e.centimeters && e.centimeters < e.high)
        }
        #expect(body.estimate(.height)?.centimeters == 178)
        #expect(body.limitations.contains { $0.contains("ölçü değil") })
        #expect(body.limitations.contains { $0.contains("fotoğraftan çıkarılmaz") })
    }

    @Test("SELF-T05 worn garments: sleeve and leg length from skin, colours from pixels")
    func worn() async throws {
        let a = try #require(try await proposal("person-a").worn)
        let b = try #require(try await proposal("person-b").worn)
        let c = try #require(try await proposal("person-c").worn)
        #expect(a.garment(.top)?.form == "longSleeveTee")
        #expect(["mavi", "lacivert", "kot mavisi", "açık mavi"].contains(a.garment(.top)?.colourName ?? ""))
        #expect(a.garment(.bottom)?.form == "trousers")
        #expect(b.garment(.top)?.form == "tee" && b.garment(.bottom)?.form == "shorts")
        #expect(["kırmızı", "pembe", "turuncu"].contains(b.garment(.top)?.colourName ?? ""))
        #expect(c.garment(.top)?.form == "tee" && c.garment(.bottom)?.form == "trousers")
        #expect(["yeşil", "açık yeşil"].contains(c.garment(.top)?.colourName ?? ""))
        #expect(["siyah", "antrasit"].contains(c.garment(.shoes)?.colourName ?? ""))
        // Shoe type is never claimed from a photo.
        #expect(c.garment(.shoes)?.needsUserChoice == true)
    }

    @Test("SELF-T06 written brand mark on the chest is read; no brand where none is printed")
    func brand() async throws {
        #expect(try await proposal("person-a").brands.map(\.brandID) == ["ornek-a"])
        #expect(try await proposal("person-b").brands.isEmpty)
        #expect(try await proposal("person-c").brands.isEmpty)
    }

    @Test("SELF-T07 face texture only with the opt-in; square PNG of the photo's own pixels")
    func faceTexture() async throws {
        let png = try #require(try await proposal("person-b").faceTexturePNG)
        let src = try #require(CGImageSourceCreateWithData(png as CFData, nil))
        let img = try #require(CGImageSourceCreateImageAtIndex(src, 0, nil))
        #expect(img.width == 512 && img.height == 512)
        let without = await SelfModelPipeline.run(fixture("person-b"), options: .testing(userHeightCm: 178))
        #expect(without.envelope.value?.faceTexturePNG == nil)
        #expect(without.envelope.value?.appearance != nil)
    }

    @Test("SELF-T08 no height typed → no centimetres, the run says so (fail closed)")
    func noHeight() async throws {
        let out = await SelfModelPipeline.run(fixture("person-c"), options: .testing(userHeightCm: nil))
        #expect(out.envelope.state == .degraded)
        #expect(out.envelope.value?.body == nil)
        #expect(out.envelope.limitations.contains { $0.contains("boyunu yazınca") })
        #expect(out.envelope.value?.worn != nil, "the rest still works")
        #expect(throws: BodyProportionReader.Failure.heightMissing) {
            try BodyProportionReader.read(keypoints: BodyKeypoints(imageWidth: 1, imageHeight: 1, joints: [:]),
                                          mask: PersonMask(width: 1, height: 1, values: [0]), userHeightCm: nil)
        }
    }

    @Test("SELF-T09 two people in the photo: nobody is picked as the user")
    func twoPeople() async throws {
        let a = fixture("person-a"), c = fixture("person-c")
        let ctx = CGContext(data: nil, width: a.width * 2, height: a.height, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(a, in: CGRect(x: 0, y: 0, width: a.width, height: a.height))
        ctx.draw(c, in: CGRect(x: a.width, y: 0, width: c.width, height: c.height))
        let both = ctx.makeImage()!
        await #expect(throws: PersonReadingError.severalPeople(2)) { try await VisionLane.run { try PoseReader.read(both) } }
        let out = await SelfModelPipeline.run(both, options: .testing(userHeightCm: 178))
        #expect(out.envelope.value == nil)
        #expect(out.envelope.state == .failed)
    }

    @Test("SELF-T10 agent system: an unregistered module is denied before anything runs")
    func registryDenies() async throws {
        // P0 alone has no Body Landmark Lab: the run is blocked by policy, no node runs.
        let octopus = OctopusCoordinator(registry: .p0())
        let out = await SelfModelPipeline.run(fixture("person-a"), options: .testing(userHeightCm: 178), coordinator: octopus)
        #expect(out.envelope.state == .blockedPolicy)
        #expect(out.nodeStates.values.allSatisfy { $0 == .blockedPolicy })
        // The self-model registry grants only reads; no module in this graph can write or reach the network.
        let graph = try SelfModelPipeline.graph(options: .testing(userHeightCm: 178))
        #expect(!graph.usesNetwork)
        #expect(graph.heavyCount == 1)
        let lab = try #require(SelfModelPipeline.registry().descriptor(.bodyLandmarkLab))
        #expect(lab.writeScopes.isEmpty && lab.networkCapabilities.isEmpty)
        #expect(lab.prohibitedActions.contains { $0.contains("Identity") })
    }

    @Test("SELF-T11 the proposal keeps no joints, no mask and no photo")
    func noIdentityData() async throws {
        let p = try await proposal("person-a")
        let json = String(decoding: try JSONEncoder().encode(p), as: UTF8.self)
        for banned in ["joints", "leftShoulder", "nose", "values", "imageWidth"] {
            #expect(!json.contains("\"\(banned)\""), "\(banned) leaked into the proposal")
        }
    }
}

@Suite("V37-02 written brand matching (BRAND-T01…)")
struct BrandMatchTests {
    @Test("BRAND-T01 case and Turkish accents fold; exact text wins")
    func folds() {
        let r = BrandMarkReader.match(lines: ["örnek a"], brands: brands)
        #expect(r.map(\.brandID) == ["ornek-a"] && r[0].editDistance == 0)
    }

    @Test("BRAND-T02 one letter off on a long mark matches and says so")
    func oneOff() {
        let r = BrandMarkReader.match(lines: ["0RNEK A"], brands: brands)
        #expect(r.first?.editDistance == 1)
        #expect(r.first?.basis.contains("bir harf") == true)
    }

    @Test("BRAND-T03 short marks are never fuzzy; unrelated text is dropped")
    func strict() {
        let short = [BrandWordmark(brandID: "x", displayName: "X", marks: ["KB"])]
        #expect(BrandMarkReader.match(lines: ["KD"], brands: short).isEmpty)
        #expect(BrandMarkReader.match(lines: ["Mehmet 1990", "I love Istanbul"], brands: brands).isEmpty)
    }
}

@Suite("V37-01 Simulator path: no Vision mask (SELF-T12…T13)")
struct NoVisionMaskTests {
    @Test("SELF-T12 without Vision masks, wall + floor: dark and mid-tone people are found whole", arguments: ["person-a", "person-c"])
    func rowMask(_ name: String) async throws {
        let image = fixture(name)
        let k = try await VisionLane.run { try PoseReader.read(image) }
        let (mask, method) = try await VisionLane.run { try PersonMaskReader.read(image, useVision: false, keypoints: k) }
        #expect(method == .rowBackground)
        #expect(PersonMaskReader.reachesFeet(mask, keypoints: k), "\(name) coverage \(mask.coverage)")
    }

    @Test("SELF-T13 with joints given and no Vision mask: the run completes; the body is within 12% or refused, never wrong",
          arguments: ["person-a", "person-b", "person-c"])
    func run(_ name: String) async throws {
        let image = fixture(name)
        let k = try await VisionLane.run { try PoseReader.read(image) }
        var o = SelfModelPipeline.Options.testing(userHeightCm: 178, brands: brands, makeFaceTexture: true)
        o.storedKeypoints = k
        o.useVisionMask = false
        let out = await SelfModelPipeline.run(image, options: o)
        let p = try #require(out.envelope.value, "\(out.envelope.state) \(out.nodeStates)")
        if name == "person-b" {
            // Light skin on a light wall: the legs are lost, so the body is refused (fail closed).
            #expect(p.body == nil)
        } else {
            let chest = try #require(p.body?.estimates.first { $0.parameter == .chest })
            #expect(abs(chest.centimeters - 89.6) / 89.6 < 0.12, "chest \(chest.centimeters)")
        }
        #expect(p.worn?.garments.contains { $0.slot == .top } == true)
    }
}

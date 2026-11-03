import CryptoKit
import Foundation
import LivingWorld
import Testing

@Suite("v2.8 UI28-05: real 3D city, its rights and the quality governor")
struct CityModelTests {
    /// apps/ios/Kabinsiz/Features/World/City, found from this file so the test runs from any directory.
    static let cityDir = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("apps/ios/Kabinsiz/Features/World/City")

    @Test("UI28-T020: every pilot city ships a 3D street, each group with a dry and a wet baked texture")
    func everyPilotHasA3DStreet() throws {
        for m in SceneAssetManifestV1.pilots {
            let model = try #require(m.model3D, "\(m.cityID) has no 3D street")
            #expect(FileManager.default.fileExists(atPath: Self.cityDir.appendingPathComponent(model.resource + ".usdz").path))
            for group in CityModel3D.groups {
                for wet in [false, true] {
                    let name = model.texture(group: group, wet: wet) + ".jpg"
                    #expect(FileManager.default.fileExists(atPath: Self.cityDir.appendingPathComponent(name).path), "missing \(name)")
                }
            }
        }
    }

    @Test("UI28-T021: the rights file says owned, no third-party input, and its hashes match the shipped files")
    func rightsAndHashes() throws {
        for m in SceneAssetManifestV1.pilots {
            let model = try #require(m.model3D)
            let data = try Data(contentsOf: Self.cityDir.appendingPathComponent(model.resource + ".asset-rights.json"))
            let rights = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(rights["provenance"] as? String == "OWNED_ORIGINAL")
            #expect((rights["third_party_inputs"] as? [Any])?.isEmpty == true)
            #expect(rights["on_device_distribution_allowed"] as? Bool == true)
            #expect((rights["lighting"] as? String)?.contains("baked") == true, "the rights file must say the light is precomputed")
            let hashes = try #require(rights["artifact_hash"] as? [String: String])
            #expect(hashes.keys.contains(model.resource + ".usdz"))
            for (file, expected) in hashes {
                let bytes = try Data(contentsOf: Self.cityDir.appendingPathComponent(file))
                let actual = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
                #expect(actual == expected, "\(file) changed after it was built; rebuild with tools/scenes/build_city_usdz.py")
            }
        }
    }

    @Test("UI28-T022: full quality only when nothing argues against it; Reduce Motion stops the camera drift")
    func fullQuality() {
        let q = SceneQualityPolicy.decide(hasModel: true, loadFailed: false, thermal: .nominal, lowPower: false, reduceMotion: false, sustainedFPS: 60)
        #expect(q.tier == .city3D && q.rainScale == 1 && q.cameraDrift)
        let still = SceneQualityPolicy.decide(hasModel: true, loadFailed: false, thermal: .fair, lowPower: false, reduceMotion: true, sustainedFPS: nil)
        #expect(still.tier == .city3D && !still.cameraDrift)
    }

    @Test("UI28-T023: heat, low power and slow frames step down; critical heat or very slow frames fall back to the 2D frame")
    func governor() {
        func tier(_ thermal: ThermalLevel, lowPower: Bool = false, fps: Double? = nil) -> SceneRenderTier {
            SceneQualityPolicy.decide(hasModel: true, loadFailed: false, thermal: thermal, lowPower: lowPower, reduceMotion: false, sustainedFPS: fps).tier
        }
        #expect(tier(.serious) == .city3DReduced)
        #expect(tier(.nominal, lowPower: true) == .city3DReduced)
        #expect(tier(.nominal, fps: 40) == .city3DReduced)
        #expect(tier(.nominal, fps: 20) == .frame2D)
        #expect(tier(.critical) == .frame2D)
        let reduced = SceneQualityPolicy.decide(hasModel: true, loadFailed: false, thermal: .serious, lowPower: false, reduceMotion: false, sustainedFPS: nil)
        #expect(reduced.rainScale < 1 && !reduced.cameraDrift)
    }

    @Test("UI28-T024: no model or a failed load shows the 2D frame, and the truth line never calls it 3D")
    func honestFallback() {
        let none = SceneQualityPolicy.decide(hasModel: false, loadFailed: false, thermal: .nominal, lowPower: false, reduceMotion: false, sustainedFPS: nil)
        let failed = SceneQualityPolicy.decide(hasModel: true, loadFailed: true, thermal: .nominal, lowPower: false, reduceMotion: false, sustainedFPS: nil)
        #expect(none.tier == .frame2D && failed.tier == .frame2D)
        #expect(!SceneQualityPolicy.truthLine(.frame2D).contains("3B şehir"))
        #expect(SceneQualityPolicy.truthLine(.frame2D).contains("Blender kadrajı"))
        #expect(SceneQualityPolicy.truthLine(.city3D).contains("hazır ışık"))
        for tier in SceneRenderTier.allCases {
            #expect(SceneQualityPolicy.truthLine(tier).hasSuffix("beden uyumunu göstermez"))
        }
        #expect(SceneQualityPolicy.studioLine.hasSuffix("beden uyumunu göstermez"))
    }

    @Test("UI28-T062: a Look Around backdrop is credited to Apple and is never called our 3D city")
    func streetPhotoLine() {
        let line = SceneQualityPolicy.truthLine(.streetPhoto)
        #expect(line.contains("Apple"))
        #expect(!line.contains("3B şehir") && !line.contains("Blender"))
        #expect(!SceneQualityPolicy.studioLine.contains("şehir"))
    }

    @Test("Texture names follow the build script: <resource>-<group>-<dry|wet>")
    func textureNames() {
        let m = CityModel3D(resource: "city-istanbul", revision: "x")
        #expect(m.texture(group: "ground", wet: true) == "city-istanbul-ground-wet")
        #expect(m.texture(group: "sky", wet: false) == "city-istanbul-sky-dry")
    }
}

import Foundation
import LivingWorld
import Testing

@Suite("Living world: honest weather and owned scenes (V25-05/06/08)")
struct WeatherSceneTests {
    @Test("V25-T06: no data draws no rain and says so; a probability is text, never rain on screen")
    func noFakeRain() {
        let none = SceneWeatherState.from(.none)
        #expect(none.rainIntensity == 0 && !none.wetGround && none.label == "Hava verisi yok")
        let maybe = SceneWeatherState.from(.probability(rainPercent: 70, source: "Apple Hava", at: Date()))
        #expect(maybe.rainIntensity == 0 && !maybe.wetGround && maybe.label.contains("ihtimali"))
    }

    @Test("A user preview rains and is labelled as not real; an observation rains until it goes stale")
    func previewAndObservation() {
        let preview = SceneWeatherState.from(.userPreview(.rain))
        #expect(preview.rainIntensity > 0 && preview.wetGround && preview.isPreview && preview.label.contains("gerçek hava değil"))
        let now = Date()
        let fresh = SceneWeatherState.from(.observed(.rain, source: "Apple Hava", at: now.addingTimeInterval(-600)), now: now)
        #expect(fresh.rainIntensity > 0 && !fresh.isPreview)
        let stale = SceneWeatherState.from(.observed(.rain, source: "Apple Hava", at: now.addingTimeInterval(-5 * 3600)), now: now)
        #expect(stale.rainIntensity == 0 && stale.label.contains("eski"))
    }

    @Test("Labels never carry a temperature")
    func noTemperature() {
        let all: [SceneWeatherEvidence] = [.none, .userPreview(.rain), .userPreview(.clear), .observed(.clear, source: "x", at: Date()),
                                      .probability(rainPercent: 30, source: "x", at: Date())]
        #expect(all.map { SceneWeatherState.from($0).label }.allSatisfy { !$0.contains("°") })
    }

    @Test("Every shipped scene is owned or licensed and names how it was made")
    func sceneRights() {
        #expect(SceneAssetManifestV1.pilots.count == 2)
        for m in SceneAssetManifestV1.pilots {
            #expect(m.provenance == .ownedOriginal || m.provenance == .licensed)
            #expect(m.generator.hasPrefix("tools/scenes/"))
            #expect(m.dryBackdrop != m.wetBackdrop)
        }
        #expect(SceneAssetManifestV1.manifest(for: .studio) == nil)
        #expect(SceneCity.allCases.allSatisfy { !$0.sceneDescription.isEmpty })
    }
}

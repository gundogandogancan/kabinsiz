import Foundation
@testable import LivingWorld
import Testing

@Suite("Turntable: only the hand turns the figure")
struct TurntableTests {
    @Test("TURN-T01 at rest nothing moves, however long the clock runs")
    func restIsStill() {
        var spin = TurntableSpin()
        var turned: Float = 0
        for _ in 0..<600 { turned += spin.step(1.0 / 60) }
        #expect(turned == 0 && !spin.isSpinning)
    }

    @Test("TURN-T02 a flick coasts, slows and comes to rest; the total turn is bounded")
    func flickComesToRest() {
        var spin = TurntableSpin()
        spin.fling(6)
        var turned: Float = 0, steps = 0
        while spin.isSpinning && steps < 1000 { turned += spin.step(1.0 / 60); steps += 1 }
        #expect(!spin.isSpinning)
        #expect(steps < 200, "rests within about three seconds")
        // Coasting distance is v/k for an exponential decay.
        #expect(turned > 2.0 && turned <= 6 / TurntableSpin.damping + 0.01)
    }

    @Test("TURN-T03 small flicks are ignored, huge ones are capped, bad numbers stop it")
    func flickLimits() {
        var spin = TurntableSpin()
        spin.fling(0.3)
        #expect(!spin.isSpinning)
        spin.fling(500)
        #expect(spin.velocity == TurntableSpin.maxVelocity)
        spin.fling(.nan)
        #expect(!spin.isSpinning)
        spin.fling(-3)
        #expect(spin.step(.infinity) == 0 && spin.velocity == -3)
    }

    @Test("TURN-T04 a full-width drag turns half way; direction follows the finger; front is a whole turn")
    func dragMapping() {
        #expect(abs(TurntableSpin.angle(forDrag: 400, width: 400) - .pi) < 1e-5)
        #expect(TurntableSpin.angle(forDrag: -100, width: 400) < 0)
        #expect(TurntableSpin.angle(forDrag: 100, width: 0) == 0)
        #expect(TurntableSpin.front(near: 0.55) == 0)
        #expect(abs(TurntableSpin.front(near: 5.9) - 2 * .pi) < 1e-5)
        #expect(abs(TurntableSpin.front(near: -3.5) + 2 * .pi) < 1e-5)
    }
}

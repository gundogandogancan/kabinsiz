import Foundation

/// The figure as a turntable you turn with one finger (user decision 2026-11-04: "only the person
/// turns the model, like a game"). Nothing here runs on its own: a drag maps finger travel to angle,
/// a flick hands over a speed that decays to rest. No idle sway, no breathing, no camera drift.
public struct TurntableSpin: Equatable, Sendable {
    /// Turning speed in radians per second while coasting after a flick.
    public private(set) var velocity: Float = 0
    /// A flick never spins faster than two turns a second.
    public static let maxVelocity: Float = 4 * .pi
    /// How quickly a flick dies out: the speed halves about every 0.3 s.
    public static let damping: Float = 2.3
    /// Below this the figure is at rest.
    public static let restVelocity: Float = 0.06

    public init() {}

    public var isSpinning: Bool { velocity != 0 }

    /// Hand the figure a speed when the finger lifts. Small flicks are ignored so a careful drag stays put.
    public mutating func fling(_ speed: Float) {
        guard speed.isFinite, abs(speed) >= 0.6 else { velocity = 0; return }
        velocity = max(-Self.maxVelocity, min(Self.maxVelocity, speed))
    }

    public mutating func stop() { velocity = 0 }

    /// Advance by `dt` seconds; returns the angle turned in that time.
    public mutating func step(_ dt: TimeInterval) -> Float {
        guard velocity != 0, dt > 0, dt.isFinite else { return 0 }
        let t = Float(min(dt, 0.1))           // a hitch never throws the figure round
        let decay = exp(-Self.damping * t)
        // Exact integral of v·e^(−k·t) over the step.
        let turned = velocity * (1 - decay) / Self.damping
        velocity *= decay
        if abs(velocity) < Self.restVelocity { velocity = 0 }
        return turned
    }

    /// Finger travel to angle: one full screen width turns the figure half way round.
    public static func angle(forDrag dx: Double, width: Double) -> Float {
        guard width > 0, dx.isFinite else { return 0 }
        return Float(dx / width) * .pi
    }

    /// Finger speed (points/s) to turning speed (rad/s), on the same scale as `angle(forDrag:width:)`.
    public static func velocity(forFingerSpeed v: Double, width: Double) -> Float {
        guard width > 0, v.isFinite else { return 0 }
        return Float(v / width) * .pi
    }

    /// The nearest "front" angle to `yaw` (a whole number of turns), for the "Önden" button.
    public static func front(near yaw: Float) -> Float {
        (yaw / (2 * .pi)).rounded() * 2 * .pi
    }
}

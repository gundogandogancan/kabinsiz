import Foundation

/// Height + weight → a drawing estimate of shoulder width and the chest, waist and hip girths (ADR-011).
///
/// Fitted on ANSUR II (US Army, 2012; public release): per sex, ln(cm) = a + b·ln(kg) + c·ln(cm height),
/// see `scripts/avatar/fit_ansur_estimate.py` and `AnthropometricEstimate.swift`. Residual spread is
/// about ±2–6 % depending on the measure, with no visible bias up to BMI 35 (women) / 40 (men). The
/// neutral template uses the mean of the two predictions in log space. ANSUR's waist is taken at the
/// navel and its shoulder is bone to bone, so these are starting shapes for the picture: never a
/// measurement, never used for size advice. Not inferred from anything: only what the person typed.
public enum BodyShapeEstimate {
    /// Heights and weights the fit was made on (1st–99th percentile, widened a little). Outside these
    /// the estimate is not offered and the template's starting values are kept.
    public static let heightRangeCm: ClosedRange<Double> = 140...210
    public static let weightRangeKg: ClosedRange<Double> = 40...160

    public static func cm(template: BodyTemplate, heightCm: Double, weightKg: Double) -> [BodyParameter: Double]? {
        guard heightRangeCm.contains(heightCm), weightRangeKg.contains(weightKg) else { return nil }
        let lw = log(weightKg), lh = log(heightCm)
        func ln(_ c: AnthropometricEstimate.Coefficients) -> Double { c.a + c.b * lw + c.c * lh }
        var out: [BodyParameter: Double] = [:]
        for p in [BodyParameter.shoulderWidth, .chest, .waist, .hip] {
            guard let f = AnthropometricEstimate.female[p], let m = AnthropometricEstimate.male[p] else { return nil }
            let value: Double = switch template {
            case .female: exp(ln(f))
            case .male: exp(ln(m))
            case .neutral: exp((ln(f) + ln(m)) / 2)
            }
            guard value.isFinite, value > 0 else { return nil }
            out[p] = value
        }
        return out
    }
}

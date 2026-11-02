import DomainContracts
import Foundation

/// Fictional closets for demos and tests. Every garment is tagged `SYNTHETIC_DEMO_ONLY` (§56).
public enum SyntheticCloset {
    /// The §56 Barcelona closet: 2 basic tops, overshirt, casual shirt, trousers, jeans,
    /// light jacket, comfortable shoes, evening shoes, socks/underlayers.
    public static let demo: Wardrobe = Wardrobe(garments: [
        g("syn-top-white-tee", "Beyaz basic tişört", .top, .relaxed ... .casual, "beyaz", neutral: true),
        g("syn-top-grey-tee", "Gri basic tişört", .top, .relaxed ... .casual, "gri", neutral: true),
        g("syn-top-overshirt", "Hafif overshirt", .top, .casual ... .smart, "haki", neutral: true),
        g("syn-top-casual-shirt", "Lacivert gömlek", .top, .casual ... .formal, "lacivert", neutral: true),
        g("syn-bottom-trousers", "Siyah kumaş pantolon", .bottom, .casual ... .formal, "siyah", neutral: true),
        g("syn-bottom-jeans", "Mavi jean", .bottom, .relaxed ... .casual, "mavi", neutral: true),
        g("syn-outer-light-jacket", "Hafif ceket", .outerwear, .casual ... .smart, "bej", neutral: true),
        g("syn-shoes-sneakers", "Rahat sneaker", .shoes, .relaxed ... .casual, "beyaz", neutral: true, walking: true),
        g("syn-shoes-evening", "Akşam ayakkabısı", .shoes, .smart ... .formal, "siyah", neutral: true, walking: false),
        g("syn-under-socks", "Çorap ve iç çamaşırı seti", .underlayer, .relaxed ... .formal, "karışık", neutral: true),
    ])

    /// Deterministic large closet for performance fixtures (§53.1: 0/15/100/500 garments).
    public static func generated(count: Int, seed: UInt64 = 42) -> Wardrobe {
        var rng = SeededGenerator(seed: seed)
        let plan: [(GarmentCategory, Int)] = [(.top, 35), (.bottom, 20), (.dress, 8), (.outerwear, 10), (.shoes, 12), (.underlayer, 5), (.accessory, 10)]
        let colors = ["siyah", "beyaz", "gri", "lacivert", "bej", "kırmızı", "yeşil", "mavi"]
        var garments: [Garment] = []
        var index = 0
        while garments.count < count {
            for (category, share) in plan where garments.count < count {
                for _ in 0..<max(1, share * count / 100) where garments.count < count {
                    let low = Formality(rawValue: Int(rng.next() % 3))!
                    let high = Formality(rawValue: min(3, low.rawValue + 1 + Int(rng.next() % 2)))!
                    let color = colors[Int(rng.next() % UInt64(colors.count))]
                    garments.append(Garment(
                        id: String(format: "gen-%04d", index),
                        name: "\(category.displayName) #\(index)",
                        category: category,
                        formalityRange: low ... high,
                        colorName: color,
                        isNeutralColor: ["siyah", "beyaz", "gri", "lacivert", "bej"].contains(color),
                        condition: .clean,
                        walkingComfort: category == .shoes ? rng.next() % 2 == 0 : nil,
                        provenance: .syntheticDemo
                    ))
                    index += 1
                }
            }
        }
        return Wardrobe(garments: garments)
    }

    private static func g(
        _ id: String, _ name: String, _ category: GarmentCategory, _ formality: ClosedRange<Formality>,
        _ color: String, neutral: Bool, walking: Bool? = nil
    ) -> Garment {
        Garment(
            id: id, name: name, category: category, formalityRange: formality, colorName: color,
            isNeutralColor: neutral, condition: .clean, walkingComfort: walking, provenance: .syntheticDemo
        )
    }
}

/// SplitMix64: tiny deterministic generator so fixtures are identical on every run.
public struct SeededGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64
    public init(seed: UInt64) { state = seed }
    public mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

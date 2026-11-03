import BodyGeometry
import DomainContracts
import Foundation

/// Turns a wardrobe garment into what the figure wears: slot, shape family and colour. Only words the
/// user (or the catalogue) wrote are read; nothing is guessed from a photo. A garment whose shape
/// cannot be drawn honestly (underwear, swimwear, an unknown accessory) is not drawn at all.
public enum GarmentAppearance {
    public static func dressItem(for garment: Garment) -> DressItem? {
        guard let (slot, form) = shape(of: garment) else { return nil }
        return DressItem(id: garment.id, name: garment.name, slot: slot, form: form,
                         colorHex: color(named: garment.colorName), colorName: garment.colorName,
                         tier: .t1, provenance: garment.provenance)
    }

    static func shape(of g: Garment) -> (GarmentSlotID, GarmentForm)? {
        let name = g.name.lowercased(with: Locale(identifier: "tr_TR"))
        func has(_ words: String...) -> Bool { words.contains { name.contains($0) } }
        switch g.category {
        case .top, .activewear:
            if has("kazak", "triko", "hırka", "sweat", "örgü") { return (.top, .knit) }
            if has("gömlek", "overshirt", "bluz") { return (.top, .shirt) }
            if has("uzun kollu", "uzun kol") { return (.top, .longSleeveTee) }
            return (.top, .tee)
        case .bottom:
            if has("şort") { return (.bottom, .shorts) }
            if has("etek") { return (.bottom, .skirt) }
            if has("jean", "kot", "denim") { return (.bottom, .jeans) }
            return (.bottom, .trousers)
        case .outerwear, .weatherProtection:
            if has("palto", "kaban", "trençkot", "trenç", "pardösü", "mont") { return (.outerwear, .coat) }
            return (.outerwear, .jacket)
        case .shoes:
            if has("bot", "çizme") { return (.footwear, .boots) }
            if has("loafer", "akşam", "deri", "klasik", "makosen") { return (.footwear, .loafers) }
            return (.footwear, .sneakers)
        case .accessory:
            if has("kemer") { return (.belt, .belt) }
            if has("çanta", "tote") { return (.bag, .tote) }
            if has("atkı", "şal", "eşarp", "fular") { return (.otherAccessory, .scarf) }
            return nil
        case .dress, .underlayer, .sleepwear, .swimwear:
            // No honest dress shape yet; underlayers are never drawn.
            return nil
        }
    }

    /// Colour words (Turkish) to an approximate sRGB value. Unknown words fall back to a neutral grey
    /// rather than an invented colour.
    public static func color(named raw: String) -> UInt32 {
        let name = raw.lowercased(with: Locale(identifier: "tr_TR")).trimmingCharacters(in: .whitespaces)
        let table: [(String, UInt32)] = [
            ("lacivert", 0x1F2A44), ("antrasit", 0x3A3B3D), ("siyah", 0x1C1B1A), ("beyaz", 0xF2EFE9),
            ("ekru", 0xEDE6D6), ("krem", 0xEAE0CC), ("bej", 0xCDB99A), ("camel", 0xB08356), ("deve tüyü", 0xB08356),
            ("haki", 0x7A7454), ("zeytin", 0x62684B), ("gri", 0x8E8D8A), ("füme", 0x5B5C5E),
            ("kahverengi", 0x5E4030), ("kahve", 0x5E4030), ("taba", 0x8C5A35), ("bordo", 0x6B1E2A),
            ("kırmızı", 0xA8322D), ("mavi", 0x46658C), ("açık mavi", 0x9DB4CC), ("yeşil", 0x4C6B4A),
            ("hardal", 0xB8902F), ("pembe", 0xD9A3A6), ("mor", 0x5E4A6B), ("turuncu", 0xC86B35), ("sarı", 0xD9B44A),
        ]
        // Longest match first, so "açık mavi" wins over "mavi".
        for (word, hex) in table.sorted(by: { $0.0.count > $1.0.count }) where name.contains(word) { return hex }
        return 0x9A9590
    }
}

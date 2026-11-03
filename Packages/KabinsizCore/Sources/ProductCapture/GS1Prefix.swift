import Foundation

/// What a valid GTIN's first digits say without any network or licence: which GS1 member
/// organisation issued the company prefix. This is NOT the country of manufacture and NOT the brand
/// (GS1 General Specifications §1.4.3). The brand needs a GS1 registry lookup (licensed API key,
/// BLOCKED_EXTERNAL) or the brand's own licensed feed.
public enum GS1Prefix {
    public enum Kind: Equatable, Sendable {
        /// A company prefix from this member organisation (Turkish country/region name).
        case member(String)
        /// 020–029, 040–049, 200–299: numbers a shop prints for its own use; no global owner.
        case restrictedInStore
        case book
        case serial
        case coupon
        case unknown
    }

    /// Reads the GS1 prefix of a GTIN-8/12/13/14. GTIN-12 (UPC-A) is GS1 US by definition.
    public static func kind(ofGTIN gtin: String) -> Kind {
        guard gtin.allSatisfy(\.isNumber) else { return .unknown }
        let thirteen: String
        switch gtin.count {
        case 8: return gtin.hasPrefix("0") || gtin.hasPrefix("2") ? .restrictedInStore : .unknown
        case 12: thirteen = "0" + gtin
        case 13: thirteen = gtin
        case 14: thirteen = String(gtin.dropFirst())
        default: return .unknown
        }
        guard let p = Int(thirteen.prefix(3)) else { return .unknown }
        switch p {
        case 20...29, 40...49, 200...299: return .restrictedInStore
        case 977: return .serial
        case 978, 979: return .book
        case 981...984, 990...999: return .coupon
        default: break
        }
        for (range, name) in table where range.contains(p) { return .member(name) }
        return .unknown
    }

    /// One short Turkish line for the product card.
    public static func note(forGTIN gtin: String) -> String {
        switch kind(ofGTIN: gtin) {
        case .member(let name): "Barkod, GS1 \(name) üyesi bir firmaya kayıtlı (üretim yeri değildir)."
        case .restrictedInStore: "Bu, mağazanın kendi iç numarası; dünya çapında bir sahibi yok."
        case .book: "Bu bir kitap numarası (ISBN)."
        case .serial: "Bu bir süreli yayın numarası (ISSN)."
        case .coupon: "Bu bir kupon numarası."
        case .unknown: "Barkodun kayıt bölgesi bilinmiyor."
        }
    }

    // GS1 company prefix list (gs1.org/standards/id-keys/company-prefix), main member organisations.
    static let table: [(ClosedRange<Int>, String)] = [
        (0...19, "ABD"), (30...39, "ABD"), (60...139, "ABD"),
        (300...379, "Fransa"), (380...380, "Bulgaristan"), (383...383, "Slovenya"), (385...385, "Hırvatistan"),
        (387...387, "Bosna-Hersek"), (389...389, "Karadağ"), (400...440, "Almanya"), (450...459, "Japonya"),
        (490...499, "Japonya"), (460...469, "Rusya"), (470...470, "Kırgızistan"), (471...471, "Tayvan"),
        (474...474, "Estonya"), (475...475, "Letonya"), (476...476, "Azerbaycan"), (477...477, "Litvanya"),
        (478...478, "Özbekistan"), (479...479, "Sri Lanka"), (480...480, "Filipinler"), (481...481, "Belarus"),
        (482...482, "Ukrayna"), (484...484, "Moldova"), (485...485, "Ermenistan"), (486...486, "Gürcistan"),
        (487...487, "Kazakistan"), (488...488, "Tacikistan"), (489...489, "Hong Kong"), (500...509, "Birleşik Krallık"),
        (520...521, "Yunanistan"), (528...528, "Lübnan"), (529...529, "Kıbrıs"), (530...530, "Arnavutluk"),
        (531...531, "Kuzey Makedonya"), (535...535, "Malta"), (539...539, "İrlanda"), (540...549, "Belçika ve Lüksemburg"),
        (560...560, "Portekiz"), (569...569, "İzlanda"), (570...579, "Danimarka"), (590...590, "Polonya"),
        (594...594, "Romanya"), (599...599, "Macaristan"), (600...601, "Güney Afrika"), (611...611, "Fas"),
        (613...613, "Cezayir"), (619...619, "Tunus"), (622...622, "Mısır"), (625...625, "Ürdün"), (626...626, "İran"),
        (628...628, "Suudi Arabistan"), (629...629, "Birleşik Arap Emirlikleri"), (640...649, "Finlandiya"),
        (690...699, "Çin"), (700...709, "Norveç"), (729...729, "İsrail"), (730...739, "İsveç"), (750...750, "Meksika"),
        (754...755, "Kanada"), (760...769, "İsviçre"), (770...771, "Kolombiya"), (773...773, "Uruguay"), (775...775, "Peru"),
        (778...779, "Arjantin"), (780...780, "Şili"), (789...790, "Brezilya"), (800...839, "İtalya"),
        (840...849, "İspanya"), (858...858, "Slovakya"), (859...859, "Çekya"), (860...860, "Sırbistan"),
        (868...869, "Türkiye"), (870...879, "Hollanda"), (880...880, "Güney Kore"), (885...885, "Tayland"),
        (888...888, "Singapur"), (890...890, "Hindistan"), (893...893, "Vietnam"), (896...896, "Pakistan"),
        (899...899, "Endonezya"), (900...919, "Avusturya"), (930...939, "Avustralya"), (940...949, "Yeni Zelanda"),
        (955...955, "Malezya"), (958...958, "Makao"),
    ]
}

/// Where brand and product facts may come from. Only licensed partner feeds may be read; a brand's
/// public web page is not scraped (v3.2 §5.4, V32-WEB-02). The user can still open a search in Safari
/// themselves: that is their own browsing, and Kabinsiz reads nothing back.
public enum BrandSourceGate {
    /// Licensed partner hosts. Empty until a partner contract exists (BLOCKED_EXTERNAL, R-004).
    public static let licensedHosts: Set<String> = []

    public enum Decision: Equatable, Sendable {
        case partnerFeed(host: String)
        case notLicensed
        case rejected(String)
    }

    public static func decide(_ raw: String, licensed: Set<String> = licensedHosts) -> Decision {
        guard let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)), let scheme = url.scheme?.lowercased() else {
            return .rejected("Bağlantı okunamadı.")
        }
        guard scheme == "https" else { return .rejected("Yalnız https bağlantıları kabul edilir.") }
        guard let host = url.host?.lowercased(), !host.isEmpty else { return .rejected("Bağlantıda site adı yok.") }
        if host == "localhost" || host.hasSuffix(".local") || host.hasSuffix(".localhost") || isIPLiteral(host) {
            return .rejected("Yerel ya da IP adresli bağlantılar açılmaz.")
        }
        if licensed.contains(host) || licensed.contains(where: { host.hasSuffix("." + $0) }) { return .partnerFeed(host: host) }
        return .notLicensed
    }

    static func isIPLiteral(_ host: String) -> Bool {
        let h = host.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        if h.contains(":") { return true }
        let parts = h.split(separator: ".")
        return parts.count == 4 && parts.allSatisfy { Int($0).map { (0...255).contains($0) } ?? false }
    }

    /// A Safari search the user opens themselves for a code the catalogue does not know.
    /// Only the code is in the query; no image, location or profile data.
    public static func userSearchURL(forCode code: String) -> URL? {
        let clean = code.trimmingCharacters(in: .whitespaces)
        // A product code only: letters, digits, dashes, at least one digit. Anything else is refused, not cleaned.
        guard (6...20).contains(clean.count), clean.allSatisfy({ ($0.isASCII && ($0.isLetter || $0.isNumber)) || $0 == "-" }),
              clean.contains(where: \.isNumber) else { return nil }
        var c = URLComponents(string: "https://duckduckgo.com/")!
        c.queryItems = [URLQueryItem(name: "q", value: clean)]
        return c.url
    }
}

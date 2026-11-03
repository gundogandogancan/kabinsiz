# V19 ürün doğruluğu ve veri hakları

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 4 · V19-03, V18-04, R17-02
**Gerçek partner, feed veya lisans yok. Bu dosyadaki gerçek veri satırlarının hepsi `BLOCKED_EXTERNAL`.**

## 1. Bugünkü veri (EVIDENCE)

| Kaynak | İçerik | Hak | Kod |
|---|---|---|---|
| `Packages/KabinsizCore/Sources/ShoppingCopilot/Resources/SyntheticCatalog.json` | 7 sentetik varyant (`KB-TEE-01-WHT`, `KB-JKT-01-NVY`, `KB-JKT-01-OLV`, `KB-JNS-02-BLU`, `KB-SHR-03-NVY`, `KB-SNK-04-WHT`, `OB-DRS-01-RED`); 1'i sponsorlu; hepsi `SYNTHETIC_DEMO_ONLY` | Repo içi, kurgusal | `ShoppingCopilot/Catalog.swift:48-54` |
| Beden tabloları (aynı dosya) | Üst/dış/elbise: yalnız göğüs aralığı; pantolon: yalnız bel; 2 üründe tablo yok | Kurgusal | `FitPassport/SizeAdvisor.swift:5-21` |
| Kumaş iddiaları | 3 üründe 1'er boolean iddia, 4'ünde yok | Kurgusal | `DomainContracts/Garment.swift:73-82` |
| Kullanıcı dolabı | Elle girilen giysi | Kullanıcının, cihazda, kasada | `WardrobeDomain/Wardrobe.swift` |

## 2. Kimlik tipleri: bugün ↔ hedef

| Kavram | Bugün | Hedef (v1.7 §4, V19-03.2) | Durum |
|---|---|---|---|
| GTIN-8/12/13/14 + check digit | Yalnız `ProductLookupRequest.gtin` dizgesi (`SystemContracts/CitadelGate.swift:290`), katalogda yok | `ProductIdentityV1.gtin` + doğrulama | SPEC_ONLY |
| GS1 Digital Link | Yok | Ayrıştırıcı; URL olarak açılmaz (SEC-05) | SPEC_ONLY |
| Model / stil kodu | `modelCode` (`Catalog.swift:11`) | `styleCode` + marka sahibi ayrımı | KISMEN |
| Renk varyantı | `code` (`Catalog.swift:9`) | `variantID` + renk | KISMEN |
| Beden varyantı | Yok (beden tablo satırı) | ayrı varyant | SPEC_ONLY |
| Feed revizyonu | `catalogRevision: Int` (`Catalog.swift:20`) | kaynak + TTL + lisans + revizyon | KISMEN |
| Kimlik kesinliği | `found/ambiguous/notFound/invalidInput` (`Catalog.swift:29-37`) | `EXACT_VERIFIED / CONFIRMED_BY_USER / CANDIDATE / NO_MATCH` | KISMEN |
| Kanıt kaydı | `EvidenceRecord` (`SystemContracts/EvidenceRecord.swift:6-95`), karta bağlı değil | Her alan bir `EvidenceRecord`'a bağlı | KISMEN |

## 3. Kaynak kademesi ve çatışma (V18-04.2)

| Kademe | Örnek | Bugünkü karşılık | Doğrulandı gösterilebilir mi |
|---|---|---|---|
| A | Lisanslı marka feed / PIM | `EvidenceRecord.SourceType.licensedCatalog`, `.manufacturer` | Evet, lisans + varyant + doğrulama + yürürlük + tombstone yoksa (`EvidenceRecord.swift:87`) |
| B | Yetkili perakendeci listesi | `.retailerListing` | Kademe kuralı kodda yok → `UNKNOWN` |
| C | Etiketten okunan (OCR) | `modelOrParserVersion` alanı var; OCR yok | Hayır (yalnız "Etiketten okundu") |
| D | Kullanıcı girdisi | `.userEntered` | Hayır ("Kullanıcı girdi") |
| E | Yorum / sentetik | `.review`, `.syntheticFixture` | Hayır |

Çatışma çözücü ve `CONFLICTING_SOURCES` yok (V19-Q08) → R18-WP03. Kural önerisi (ASSUMPTION, ADR ister): aynı alan için A > B > C > D; aynı kademede iki değer → çatışma, alan "Veri yok" gösterilir, iki kaynak denetim günlüğüne (değer değil, kaynak kimliği).

## 4. Hak matrisi

| Hak | Gerekli olduğu iş | Durum | Kimden |
|---|---|---|---|
| GS1 GTIN sorgu erişimi, limit, cache | R17-03 çevrimiçi kısım | `BLOCKED_EXTERNAL` (V19-Q07) | GS1 Türkiye / Global |
| Marka katalog + bitmiş ölçü | R17-05 gerçek, R17-07 | `BLOCKED_EXTERNAL` (R-004) | Marka sözleşmesi |
| Ürün fotoğrafı, logo, 3D/CAD | WP19-08, R17-08 | `BLOCKED_EXTERNAL` | Marka |
| ISO 3758 bakım sembolleri / ISO 9920, 11092 metinleri | R17-04 | Lisans kontrolü gerekli (v1.6 §5) | ISO / TSE |
| Affiliate / stok / fiyat | R18-WP08..12 | `BLOCKED_EXTERNAL` | Program sahibi |
| WeatherKit | EG-001 | `BLOCKED_EXTERNAL` (R-003, PLA) | Apple |

## 5. Ağ

Ürün sorgusu için kayıtlı rota yok (`docs/security/EGRESS_REGISTER.md` Notlar; `CitadelGate.swift:39-41`). Eklenirse: yalnız `PUBLIC_PRODUCT` sınıfı, alanlar `gtin, country, locale` (`CitadelGate.swift:287-292`), beden/foto/dolap asla (SEC-08). Ürün metni güvenilmeyen girdi (`SystemContracts/UntrustedInput.swift:6`).

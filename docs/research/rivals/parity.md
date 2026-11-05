# Parite: Kabinsiz × rakipler (aynı işi yapıyor mu?) — 2026-11-04

Durum değerleri:

- **DONE:** iş yapılıyor; test ya da ekran kanıtı var.
- **PARTIAL:** paket kodu hazır, ama ekran ya da cihaz eksik.
- **MISSING:** yok.
- **BLOCKED_EXTERNAL:** insan onayı ya da hesap gerekiyor.

| Özellik | En iyi rakip | Kabinsiz | Kanıt |
|---|---|---|---|
| Ölçüden avatar (boy, omuz, göğüs/büst, bel, kalça) | Alta (boy ve kilo) | **DONE**, rakipten ileri | BodyProfile, BFORM-T01..T06, BodyJourney testleri |
| Kadın / Erkek / Nötr beden formu | — (belirtilmiyor) | **DONE** (SIMULATOR_TESTED; cihaz R-002) | BFORM-T01..T07, BodyFormUITests |
| Avatarı baştan kur | Doji (C) | **DONE**: başlangıç şekli formla seçilir, form sonradan değişir, geri alınır | BFORM-T07, BodyFormUITests |
| Canlı ayna | Anywear | **PARTIAL**: F1 yerel ayna SIMULATOR_TESTED; cihaz R-002 | MIR-T*, ADR-015 |
| Fotoğrafsız deneme | Anywear | **DONE** | 3B model ve canlı ayna |
| Fotogerçekçi tek kare | Google / Doji | **MISSING**: FASHN PoC çalıştı (2026-11-04), bizim avatarda fotogerçekçi değil, kullanıcı fotoğrafı buluta gitmez → cihazda yol yok | `docs/research/fashn-poc/`, D-049 |
| Bağlantı ya da paylaşımla ürün ekleme | Doji / Google | **MISSING** → V36-06 | — |
| Fotoğraftan kesip çıkarma | Alta (SAM) | **PARTIAL**: paket DONE (Vision maskesi, cihazda); UI V36-03'te | PHOTO-T01..T05, T07 |
| Otomatik etiket (kategori, renk, mevsim) | Alta / Cladwell | **PARTIAL**: renk + tür önerisi paket DONE (12/13); mevsim yok; UI V36-03'te | PHOTO-T02, T06..T08 |
| Toplu ekleme | Cladwell | **MISSING** → V36-03 | — |
| Fişten ekleme | Alta | **PARTIAL**: VNRecognizeText etiket okuyucuda var; fiş akışı V36-07'de | ProductLabelReader |
| Barkod ve fotoğrafla ürün | — | **DONE** (Kabinsiz'e özgü) | ADR-014, SCAN-WP02 |
| Hava ile günlük kombin | Alta / Daily Dress Me | **PARTIAL**: kod hazır; WeatherKit R-003; DayNeeds DONE | WX-T*, INS-T07 |
| Takvim ile günlük kombin | Alta | **PARTIAL**: OccasionReader DONE; EventKit ekranı V36-02'de | INS-T08 |
| Giyim günlüğü ve stil takvimi | Alta / Cladwell | **PARTIAL**: WearLedger DONE; UI V36-04'te | INS-T01, INS-T04 |
| En çok ve en az giyilenler | Alta | **PARTIAL**: ClosetReport DONE | INS-T05 |
| Giyim başı maliyet | Alta / Cladwell | **PARTIAL**: DONE (yalnız kullanıcının girdiği fiyatla) | INS-T02 |
| Dolap boşluk analizi | Alta | **PARTIAL**: ClosetGapFinder DONE | INS-T06 |
| Valiz listesi | Alta | **DONE** | TravelEngine testleri |
| Çok şehirli seyahat | Alta | **MISSING** → V36-08 | — |
| İstek listesi ve indirim bildirimi | Alta | **BLOCKED_EXTERNAL**: lisanslı fiyat kaynağı yok | V32-WEB-02 |
| Doğal dille kombin isteme | Alta | **MISSING** → V36-09 | — |
| Fotoğraf mahremiyet kontrolleri | Google | **DONE**, rakipten ileri: hiç gönderilmez, Vault'tan tümünü sil | Vault testleri, SecurityTests |
| Şehir, ışık ve hava sahnesi | — | **PARTIAL**: paket DONE (CITY/SUN/WX); sahne çizimi V36-05'te | CityWorldTests |
| Elle döndürülen 3B model, giydir/çıkar | — | **DONE** (ADR-016, ana dalda) | TurntableDressUpUITests |

**Özet:** 25 satır var. Dağılım:

- DONE: 8 satır.
- PARTIAL: 11 satır. Paket mantığı hazır, ekran ya da cihaz eksik.
- MISSING: 5 satır.
- BLOCKED_EXTERNAL: 1 satır.

Her MISSING satır ve ekranı eksik her PARTIAL satır için bir iş paketi var: `docs/audit/V36_FEATURE_QUEUE.md`.

**V37 ek (2026-11-05):** Giyio (Decart tabanlı canlı deneme), Doji/Alta avatar kurulumu, Anywear ve sadelik bütçesi (SIMP-T01..T09) → `v37-mirror-twin-and-simplicity.md`.

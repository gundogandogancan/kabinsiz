# V35 Requirement Trace (2026-11-04)

Kaynak: v3.5 blueprint §C–§K. Satır biçimi: `req_id · gereksinim · kod yolu · durum · test/kanıt · WP`.

**Durum değerleri:**

- `CODED`, `SIMULATOR_TESTED`, `DEVICE_VERIFIED`, `PARTNER_VERIFIED`, `BLOCKED_EXTERNAL`, `NOT_RUN`.
- `SUPERSEDED`: kullanıcının daha yeni açık kararı geçerli.

## C — Şehir dünyası

| ID | Gereksinim | Kod | Durum | Test / kanıt | WP |
|---|---|---|---|---|---|
| V35-C1-01 | İzin ilk açılışta zorlanmaz; "Şehrimi otomatik bul / Şimdilik geç" | `WorldSheets` şehir sayfası, `CoarseCityLocator` | CODED (dokununca izin) | UI28-T060 | 01 |
| V35-C1-02 | Azaltılmış konum, cihazda şehir kimliği; koordinat saklanmaz ve gönderilmez | `CoarseCityLocator`, `CityIdentity` | CODED → genişletiliyor | CITY-T01..T06 | 01 |
| V35-C1-03 | Şehir kimliği → doğrulanmış `CitySceneManifest`; yakınlık iddiası yok | `CitySceneResolver` | CODED (bu WP) | CITY-T07..T12 | 01 |
| V35-C1-04 | İzin reddi: nötr atölye, sahte şehir yok | `CitySceneResolver.tierC` | CODED (bu WP) | CITY-T09 | 01 |
| V35-C2-01 | Herkese İstanbul/Barcelona gösterilmez | `HomeWorldModel` varsayılanı | CODED (bu WP): varsayılan C | UI CITY-UI01 | 01 |
| V35-C2-02 | Tier A seçilmiş / B özgün ilham / C atölye | `SceneTier` | CODED (bu WP) | CITY-T07..T12 | 01–02 |
| V35-C2-03 | Sahte anıt gerçek şehir diye etiketlenmez | resolver yanlış ülke koruması | CODED (bu WP) | CITY-T10 | 01 |
| V35-C3-01 | OSM ODbL → OSM2World → Blender → USDZ | — | BLOCKED (indirme onayı + atıf) | — | 02 |
| V35-C4-01 | güneş/bulut/yağmur/kar/rüzgâr/gece | `SceneCondition`, `SolarPosition`, `WorldStage` | CODED (bu WP) | SUN-T01..T05, WX-T01..T06 | 03 |
| V35-C4-02 | Rüzgârda kıyafetin küçük hareketi | — | SUPERSEDED (ADR-016: model kendi kendine hareket etmez; rüzgâr yalnız çevrede) | ADR-017 | 03 |
| V35-C4-03 | Reduce Motion / termal düşürme / erişilebilir hava açıklaması | `SceneQualityPolicy`, erişilebilirlik değeri | CODED | UI28-T024 | 03 |
| V35-C4-04 | Veri yoksa sahte yağmur/derece yok | `SceneWeatherState.from(.none)` | CODED | LivingWorld testleri | 03 |

## D — Kişisel dijital ikiz

| ID | Gereksinim | Durum | WP |
|---|---|---|---|
| V35-D-01 | Rızalı selfie, yerel şifreli kasa | NOT_RUN (B5 HUMAN_APPROVAL_PENDING) | 04 |
| V35-D-02 | Rastgele galeri yüzü "sen" diye atanmaz | NOT_RUN (tasarım kuralı ADR'de) | 04 |
| V35-D-05 | Avatar/Face/Hair/Body revizyonları ayrı | CODED kısmen (`bodyRevision`) | 04 |

## E — Ürün → 3B giysi

| ID | Gereksinim | Durum | WP |
|---|---|---|---|
| V35-E-01 | Barkod/foto/link/ekran görüntüsü aynı Dene akışında | CODED (barkod, foto, kod) | 06 |
| V35-E-02 | Kumaş yüzdesi görselden çıkarılmaz | CODED (BrandSourceGate, SCAN-T021) | 06 |
| V35-E-03 | Temsili mesh "gerçek 3B ürün" diye etiketlenmez | CODED (truth line) | 05 |

## F — Kendi Live Mirror

| ID | Gereksinim | Durum | WP |
|---|---|---|---|
| V35-F1 | Yerel izlenen ayna (kamera + Vision + overlay) | CODED, SIMULATOR_TESTED (fixture); DEVICE `NOT_RUN` | 08 |
| V35-F2 | FASHN v1.5 ayrı statik PoC | NOT_RUN; lisans kapısı yazıldı | 09 |
| V35-F3 | Kendi zaman tutarlı video VTON (Ar-Ge) | NOT_RUN | 10 |
| V35-F4 | Decart koşullu | CODED kapalı, BLOCKED_EXTERNAL | — |

## K — Kabul senaryoları

| # | Senaryo | Durum |
|---|---|---|
| 1 | Yozgat city ID + doğrulanmış kültürel sahne; yanlış ülke engellenir | city ID + yanlış ülke koruması CODED (birim testi). Doğrulanmış Yozgat sahnesi yok → B/C dürüst |
| 2 | Gaziantep yağmur; Reduce Motion'da hareket yok | yağmur CODED; Gaziantep sahnesi yok → C |
| 3 | New York çevrimdışı son sahne + bayat hava uyarısı | bayat uyarı CODED; NY sahnesi yok |
| 4 | Konum reddi: nötr stüdyo, yanlış şehir etiketi yok | CODED (bu WP) |
| 5–13 | Yüz, 360, SKU, OCR, Fotoğraflar, Ayna, FASHN kapısı | ilgili WP satırları |
| 14 | OSM atıf; sahte anıt reddi | sahte anıt reddi CODED; OSM BLOCKED |
| 15 | Butonlar modeli örtmez | SIMULATOR_TESTED (ADR-016 ekranları) |
| 16 | 3B yokken ilk kare akıcı | 2B kadraj yedeği CODED (UI28-T024); cihaz ölçümü NOT_RUN |

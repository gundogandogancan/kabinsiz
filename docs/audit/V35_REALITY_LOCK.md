# WP35-00 — v3.5 Reality Lock (2026-11-04)

- **Kanon zinciri:**
  - `docs/constitution/addenda/KABINSIZ_v3.5_CITY_WORLD_PERSONAL_AVATAR_OWNED_VTON_BLUEPRINT.md`
  - → v3.4 (`…v3.4_OCTOPUS_CATALOG_SELF_OWNED_VTON_EXECUTION.md`)
  - → v3.3 (`…v3.3_REALITY_AUDIT_AND_PRODUCT_ENGINEERING_BLUEPRINT.md`)
  - → v3.2 ana anayasa (`docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v3.2.md`)
  - v2.8 ana metin `archive/` altına taşındı.
- **Komut:** `docs/constitution/commands/CLAUDE_START_HERE_v3.5.md`.
- **Durum sınıfları (v3.5 §1):** `CODED | SIMULATOR_TESTED | DEVICE_VERIFIED | PARTNER_VERIFIED | BLOCKED_EXTERNAL | NOT_RUN`. Tek yetenek birden çok sınıf taşıyabilir.

## 1. Repo SHA ve dal gerçeği

| Ref | SHA | Not |
|---|---|---|
| `origin/main` | `30ed2ef9ab38db939ca4faf2b098f83fe256e23a` | v3.3/v3.5 belgelerinin denetlediği HEAD. Doğru. |
| `v25/living-world` (yerel = origin) | `97271055354481c7e2cd963ccaf8c9aec3c14d48` | `main`'den **5 commit önde**: e0079c0, c829f48, a101a1a, bca7fab, 9727105 |
| Çalışma ağacı | ADR-016 (yalnız elle dönen model + Giydir) commit sırasında | Ayrı oturum; bu belge onu varsayar ama "push edildi" saymaz |

**R01 çözüldü (V33_GAP_REGISTER):**

- Kullanıcının 2026-11-03 23:35 ekranlarındaki 4 sekme, 3B şehir ve giydirme `v25/living-world` dalındaki işti; `main`'de yoktu.
- Bugün dal 3 sekmelidir: `Bugün · Dolabım · Dene`, profil sağ üstte (D-040).
- Ekranların tamamı `docs/screenshots/app-2026-11-04/` altındadır. 77 simülatör görüntüsü, kaynak test adlarıyla.
- `main`'e birleşme kullanıcı onayı bekler. Bu belge hiçbir şeyi `main`'e taşımaz.

## 2. Yolculuk durumları (dal HEAD'ine göre, kanıtlı)

| Yolculuk | Durum | Kanıt (kod / test) | Eksik ve engel |
|---|---|---|---|
| **Şehir kimliği (konum → şehir)** | CODED, SIMULATOR_TESTED (yalnız katalog) | `Services/CoarseCityLocator.swift`: azaltılmış doğruluk, tek ölçüm, saklanmaz. `LivingWorld/WorldStreets.swift`: 36 katalog şehri, 60 km yarıçap | Yozgat, Gaziantep ve katalog dışı her şehir `noCityNearby` olur. Varsayılan şehir **herkes için İstanbul** (`HomeWorldModel.swift:97`; v3.5 C2 "herkese İstanbul gösterme" ihlali) → **WP35-01** |
| **Şehir sahnesi (3 kademe)** | CODED, SIMULATOR_TESTED (yalnız A ve C) | A: İstanbul ve Barcelona OWNED_ORIGINAL 3B USDZ (ADR-012). C: nötr stüdyo. Look Around fotoğrafı (ADR-013, rızalı) | B kademesi (özgün, şehirden ilham alan sokak) yok. OSM içe aktarma yok: `BLOCKED` (ODbL atıf + indirme onayı) → **WP35-02** |
| **Hava sahnesi** | CODED (yağmur/açık), SIMULATOR_TESTED | `SceneWeatherEvidence`, yağmur ve sıçrama partikülleri, ıslak doku | Kar, rüzgâr, bulut, gece yok. Güneş konumu yok. WeatherKit uygulamada `BLOCKED_EXTERNAL` (R-003 Apple PLA) → **WP35-03** |
| **Ana sahne 3B model** | CODED, SIMULATOR_TESTED | `WorldStage`, `DressedAvatarView`; yalnız elle döner (ADR-016) | Kişisel yüz/saç yok; gerçek cihaz FPS `NOT_RUN` (R-002) |
| **Yüz/saç dijital ikiz** | NOT_RUN (kod yok) | `ARFaceTrackingConfiguration`, selfie akışı yok | HUMAN_APPROVAL_PENDING (B5: biyometrik veri işleme kararı) → WP35-04 |
| **Gerçek 3B ürün (lisanslı giysi)** | NOT_RUN | Yalnız T1 temsili giysiler (`GarmentMesh`, Blender çizimleri) | Lisanslı CAD/ölçü verisi yok: `BLOCKED_EXTERNAL` (R-004) → WP35-05 |
| **Kamera barkodu** | CODED, SIMULATOR_TESTED (fixture) | `DataScannerViewController` (`TryOnHubView`, `ProductPhotoIntake`), `VNDetectBarcodesRequest`, GS1 öneki (SCAN-T020..22) | v3.3 "kamera barkod YOK" `main` için doğru, dal için eski. Gerçek etiketle iPhone testi `NOT_RUN` (cihaz `unavailable`) |
| **GTIN/SKU → tam varyant** | CODED (sentetik katalog) | `ProductIdentityV1`, `SyntheticCatalog.json` | Gerçek partner feed yok: `BLOCKED_EXTERNAL` (R-004/B13) |
| **Fotoğraftan dolap** | CODED kısmi | `PhotosPicker` yalnız ürün fotoğrafı okuma (barkod+OCR, `ProductPhotoIntake`) | Giysi segmentasyonu, dedup ve inceleme kuyruğu yok → WP35-07 |
| **Local Live Mirror** | CODED, SIMULATOR_TESTED (fixture poz) | `LocalMirrorView` (AVCaptureSession + Vision 14 eklem), `GarmentRig` (MIR-T01..T10), `MirrorFixturePose.json` | Gerçek kamera ve iPhone videosu `NOT_RUN`. Kişi segmentasyonu ve örtülme (el/kol önde) yok. Simülatörde Vision kurulamıyor → WP35-08 |
| **Kendi üretken VTON (FASHN v1.5)** | NOT_RUN | — | WP35-09: lisans kapısı `docs/architecture/V35_LICENSE_GATE.md`. Ağırlık indirme kullanıcı onayı bekler |
| **Bulut VTON (Decart)** | CODED kapalı | `MirrorFlags.production.cloudMirrorEnabled=false` | Sözleşme + DPA + bütçe + insan onayı: `BLOCKED_EXTERNAL` |
| **Partner portalı** | CODED şema | `DomainSchemas/Commerce.swift`, `BrandSourceGate.licensedHosts = []` | Gerçek partner yok: `BLOCKED_EXTERNAL` |
| **Açılış (logo → sahne)** | NOT_RUN | Statik `UILaunchScreen` | WP35 sonrası (R13) |

## 3. WP35-00 net bulgular

1. **Şehir varsayılanı yanlış:** konumu ya da seçimi olmayan herkes İstanbul'u görüyor. Doğrusu C kademesidir (nötr atölye) ve "Şehrini göster" seçeneği sunulmalıdır.
2. **Katalog dışı şehir yok sayılıyor:** Yozgat ve Gaziantep'te konum "yakında şehir yok" der ve stüdyoya düşer. Şehir kimliği bile çıkmıyor. Kimlik (cityID, ülke, saat dilimi) ile sahne kademesi ayrılmalıdır.
3. **Hava üç halli:** yağmur, açık ya da veri yok. Gece/gündüz bile yok, oysa güneş konumu ağsız ve gerçek hesaplanabilir.
4. **v3.5 ile kullanıcı kararı çelişiyor:** v3.5 C4 "rüzgârda kıyafetin küçük hareketi" istiyor. Kullanıcının 2026-11-04 kararı (ADR-016) "model kendi kendine hareket etmez" diyor. Kullanıcı kararı kazanır: rüzgâr yalnız çevrede (yaprak, toz) görünür, figür ve giysi kıpırdamaz (ADR-017).
5. **Simülatör sınırı:** Vision gövde pozu simülatörde kurulamıyor. Local Mirror'ın gerçek doğrulaması yalnız fiziksel iPhone'da yapılabilir (R-002: üç cihaz eşleşmiş ama `unavailable`).

## 4. İlk iki yatay bağımlılık

1. **Gerçek iPhone bağlantısı (R-002):**
   - Local Mirror, kamera barkodu, FPS ve ısı ölçümünün hepsi buna bağlı.
   - Kullanıcının telefonu USB/Wi-Fi ile bağlayıp kilidini açması gerekir.
2. **Dış veri hakları:**
   - Partner katalog feed'i (R-004).
   - WeatherKit PLA kabulü (R-003).
   - OSM indirme onayı + ODbL atıf düzeni (WP35-02).
   - FASHN ağırlıkları için indirme onayı ve parser lisans kararı (WP35-09).

## 5. Uygulanan ilk dikey iş

**WP35-01 + WP35-03 dilimi** (cihaz ya da dış hak gerektirmeyen tek P0 zinciri):

- Konum (izinli, azaltılmış) → şehir kimliği. Önce yerel katalog, sonra Apple ters coğrafi kodlama; Kabinsiz koordinatı saklamaz.
- Şehir kimliği → 3 kademeli sahne kararı (A seçilmiş / B özgün ilham / C atölye), yanlış ülke koruması ile.
- Güneş konumu (yerel astronomi) → gündüz, alacakaranlık ya da gece ışığı.
- Hava durumu kanıtına göre açık, bulutlu, yağmur, kar, rüzgâr ve sis sahnesi.
- Veri yokken sahte hava yok.

Kanıt: `docs/evidence/V35-WP01-03.yaml`.

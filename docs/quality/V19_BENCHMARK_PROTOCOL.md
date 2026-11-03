# V19 benchmark protokolü

Tarih: 2026-11-03 · Commit `f5caa71` · V19-00 ("`docs/quality/V19_BENCHMARK_PROTOCOL.md`"), V19-19, LM21-06, LM21-12, v1.7 §17 Gate E/F

**Bu dosya yalnız protokoldür. İçinde ölçülmüş tek bir sayı yoktur.** Aşağıdaki bütçeler belgelerin hedefleridir; ölçüm sonucu değildir. Bugüne kadar tüm kanıt dosyalarında `benchmarks: []` (`docs/evidence/WP15-02..05.yaml`). Cihaz koşuları `REAL_DEVICE_BLOCKED` (eşleşmiş 3 iPhone çevrimdışı; `docs/audit/V19_REALITY_AND_GAP_REPORT.md` §0.1).

## 1. Ön kayıt kuralı (V19-19.2)

1. Eşik, veri seti ve metrik **koşudan önce** bu dosyaya (veya iş paketinin kanıt YAML'ına) commit edilir. Commit SHA'sı koşu raporunda yazılır.
2. Koşudan sonra eşik değiştirilirse eski koşu `INVALID_THRESHOLD_CHANGED` olarak kalır; yeni ön kayıt + yeni koşu gerekir.
3. `PASS` için median yetmez: p95 + hatalı karar oranı + gizlilik ihlali = 0 + (kullanıcı özelliğiyse) kullanıcı geri bildirimi.
4. Simülatör sonucu yalnız `SIMULATOR_ONLY` sütununa yazılır; cihaz sütununu doldurmaz (UI20-T-023).
5. Yüzde raporu için gerçek örnek sayısı ve veri hakkı satırı zorunlu. Sentetik veriyle yüzde yayımlanmaz.

## 2. Cihaz matrisi (V19-19.1 `DeviceBenchmarkSet`, LM21-WP07)

| Sınıf | Aday cihaz (eşleşmiş) | iOS | Durum |
|---|---|---|---|
| Asgari | iPhone 13 Pro Max (iPhone14,3) | 26.2.1 | çevrimdışı |
| Orta | iPhone 14 Pro Max (iPhone15,3) | 26.6 | çevrimdışı |
| Üst | iPhone 16 Pro (iPhone17,1) | 26.5 | çevrimdışı |

Not: Üçü de Pro sınıfı; "asgari desteklenen iPhone" (iOS 18 hedefi, `apps/ios/project.yml:5`) Pro olmayan bir modeli de gerektirebilir → `UNKNOWN`, ürün kararı.

Koşul eksenleri: soğuk / sıcak / önbellekli · Wi-Fi / 4G / çevrimdışı · termal `nominal` / `fair` / `serious` / `critical` · pil normal / Düşük Güç Modu.

## 3. Ölçüm tanımları

| Metrik | Başlangıç olayı | Bitiş olayı | Araç | Kaynak hedef (ölçülmedi) |
|---|---|---|---|---|
| `p95_scan_to_first_useful_card` (S0) | kamera önizlemesinin ilk karesi | kart ilk görünür çizim | `os_signpost` + Instruments (Points of Interest) | ≤0.8 sn (V19-03.3 S0) |
| S1 tanınan kod → kimlik | Vision sonucu | `ProductResolution` | signpost | ≤1.0 sn |
| S2 kimlik → fit/kumaş kartı | `ProductResolution` | kart verisi hazır | signpost | ≤2.0 sn |
| S3 kartın tamamı | — | — | signpost | ≤1.5 sn |
| `p95_cached_to_first_3D` | 3D isteği | ilk 3D çizim | signpost + RealityKit frame | ≤3 sn G1 (v1.7 §3.3) |
| Gövde kaydırıcı → önizleme | `BodyStudio.preview` çağrısı | `PreviewScene` çizimi | signpost; registry `deadlineMs` 50/33 ms yalnız hedef (D-013) | — |
| Yerel ayna ilk kare | kamera izni verilmiş, "Başlat" | ilk önizleme karesi | signpost | ≤1 sn p95 (LM21-06) |
| Takip → ekran gecikmesi | kamera kare zaman damgası | aynı karenin çizim zamanı | `CMSampleBuffer` PTS ↔ `CADisplayLink` | ≤100 ms p95 |
| FPS / jitter / donmuş kare oranı | 60 sn oturum | — | Instruments Core Animation / Metal | 24+ hedef |
| Glass-to-glass (bulut) | — | — | harici yüksek hızlı kamera (240 fps) ile ekran + LED | `BLOCKED_EXTERNAL` |
| `peak_memory_MB` | oturum | — | Instruments Allocations / `os_proc_available_memory` | — |
| `energy_per_scan`, güç/5 dk | 5 dk sabit senaryo | — | Xcode Energy Organizer, MetricKit | — |
| `thermal_degrade_duration` | `thermalState` geçişi | kalite düşümü tamam | `ProcessInfo.thermalStateDidChangeNotification` + signpost | WP15-06 sonrası |
| `network_private_payload_violations` | oturum | — | Bölüm 5 | **0 (kesin)** |
| Veri MB/60 sn | — | — | `nettop` / Network instrument | — |

Her ölçüm en az 30 tekrar (soğuk koşuda uygulama tamamen kapatılıp açılır); rapor p50/p95/p99, örnek sayısı, cihaz, iOS, termal başlangıç durumu, commit SHA.

## 4. Doğruluk metrikleri (V19-19.2)

| Metrik | Veri seti (V19-19.1) | Veri hakkı | Durum |
|---|---|---|---|
| `exact_variant_accuracy`, `false_exact_identity_rate` | `SyntheticIdentityFixtures` → sonra `PartnerAuthorizedProductFixtures` | sentetik: repo; gerçek: `BLOCKED_EXTERNAL` | Sentetik set yazılabilir (R17-02) |
| `fit_region_precision`, `fit_abstention_rate`, `overconfidence_error`, `fit_ECE` | `GarmentMeasurementTruthSet` | insan ölçümü + rıza | `BLOCKED_EXTERNAL` / `HUMAN_REVIEW_PENDING` |
| Kumaş etiket doğruluğu, wash/wear karışıklığı | `FabricLabelTruthSet` (3 dil) | etiket fotoğrafı hakkı | Sentetik metinle başlayabilir (R17-04) |
| `garment_asset_texture_fidelity`, `logo_OCR_agreement` | lisanslı asset | marka hakkı | `BLOCKED_EXTERNAL` |
| `outfit_appropriateness_blind_pref`, `personalized_vs_baseline_winrate`, `style_diversity` | `StyleOutfitPreferenceSet` | insan panel + rıza | `HUMAN_REVIEW_PENDING` |
| `revenue_independence_test` | sentetik sponsor fixture | repo | Bugünkü karşılığı: `ShoppingAndFitTests.swift:65` (etiket-yalnız) |
| `coverage_by_brand_and_market` | partner feed | `BLOCKED_EXTERNAL` | — |

Ayrıntılı veri seti / ablation / holdout tasarımı: `docs/quality/V19_FIT_FABRIC_VISUAL_BENCHMARKS.md`.

## 5. Gizlilik ölçümü (`PrivacyAttackSet`, LM21-07.1)

1. Cihaz Mac'e bağlı; `rvictl -s <UDID>` ile sanal arayüz; `tcpdump -i rvi0 -w run.pcap` (veya Instruments Network). Proxy kullanılırsa sertifika yalnız test cihazında.
2. Senaryolar: (a) uygulamanın tüm sekmeleri, ağ izni açık, hava rızası kapalı → beklenen 0 paket (sistem dışı); (b) hava rızası açık, bir dokunuş → yalnız EG-001 + EG-002 hostları; (c) gövde kaydırıcı, dolap, Fit Passport, silme → 0 paket; (d) ileride yerel ayna 5 dk → 0 görüntü paketi.
3. Çıktı: host listesi, bayt sayısı, `EGRESS_REGISTER.md` dışı host = ihlal. Sistem kaynaklı (iOS, Apple servisleri) trafik ayrı sütunda ve uygulama PID'iyle ayrıştırılır.
4. Bugünkü kanıt yalnız statik (`StoreAndPrivacyTests.swift:78-91`) ve kapı birim testleri; bu protokolün hiçbir adımı koşulmadı.

## 6. Rapor biçimi (V19-19.3)

Her koşu kanıt YAML'ına: `requirement_ids, sha, build_output, test_command, test_result, device/os, dataset_version/rights, screenshots/video, privacy_egress_capture, perf_trace, model_license, known_failure, independent_reviewer, release_gate, rollback_plan`. Ham `.trace` / `.pcap` dosyaları kişisel veri içermiyorsa `docs/evidence/raw/` altına; içeriyorsa yalnız özet.

## 7. Kapı eşlemesi

| Kapı | Bu protokoldeki şart |
|---|---|
| v1.7 Gate E (perf) | §3 tüm satırlar, 3 cihaz sınıfı |
| v1.7 Gate F (gerçek fit) | §4 fit satırları gerçek veriyle |
| LM21-12 release | §5 ihlal = 0, §3 ayna satırları |
| V18-SON `DONE` | 1 gerçek ürün + cihaz taraması |
| v2.0 §14.1 | UI20-T-001..003 cihaz + screenshot SHA |

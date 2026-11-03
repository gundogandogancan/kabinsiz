# UI28-00 — v2.8 gerçeklik raporu, çelişki matrisi ve kuyruk (2026-11-03)

- **Dal:** `v25/living-world`. Main'e birleşme kullanıcı onayı bekler.
- **Önceki commit:** `e0079c0` (V25-03/04/07 çekirdek).
- **Kanon:** v2.8 (D-029, ADR-011).
- **Komut:** `docs/constitution/commands/CLAUDE_START_HERE_v2.8.md`.
- **Önceki rapor:** [V25_REALITY.md](V25_REALITY.md); B1–B10 engelleri aşağıda güncellendi.
- **Durum etiketleri:** SPEC / CODED / UNIT_TESTED / SIMULATOR_VISUAL_VERIFIED / DEVICE_VERIFIED / FIGMA_CREATED / HUMAN_APPROVAL_PENDING / BLOCKED_EXTERNAL / UNKNOWN.

## 1. Başlangıç denetimi (v2.8 §10'a göre)

| Alan | v2.8 öncesi durum | Kanıt |
|---|---|---|
| Sekmeler | `Bugün \| Dolabım \| Ayna \| Ben`, araç çubuğunda ayrıca Tara düğmesi vardı | `AtelierTab`, `ScanToolbarAction` (eski) |
| Ana sahne | Sol slot rayı (7 düğme), sağ sütun (5 yuvarlak düğme), 3 alt düğme. v2.8 UI28-T015'e aykırıydı | `Features/World/HomeWorldView.swift` (v2.5 sürümü) |
| Başlangıç açısı | Tam önden (yaw 0) | `HomeWorldView.yaw = 0` |
| Günlük kombin | `TodayOutfitEngine` hazırdı ama önbellek, tarih/şehir saati, kilit ve arka plan yoktu | `HomeWorldModel.refresh` (eski) |
| Hava | WeatherKit `BLOCKED_EXTERNAL`; ekranda yalnız "Hava verisi yok" ya da önizleme | R-003 |
| Tara / Ayna | İki ayrı yer: ScanView sheet'i ve LiveMirrorEntryView sekmesi | |
| Şehir sahnesi | Blender'da üretilmiş, kamerası eşlenmiş 2B arka plan; 3D olan yalnız avatar ve giysi | `tools/scenes/build_city_scene.py` |
| Figma | MCP bağlı. whoami: Starter planı, **View** koltuğu | D-033 |

## 2. Çelişki matrisi

| # | Çelişki | Kaynaklar | Çözüm |
|---|---|---|---|
| C1 | 4 sekmenin üçüncüsü: `Ayna` mı, `Dene` mi? | v2.5 ADR-010 ↔ v2.8 §02 | `Dene` (ADR-011 K1, D-030) |
| C2 | Ana sahnede slot rayı ve yan sütun | v2.5 §2.4 (ray) ↔ v2.8 §02, UI28-T015 | Kaldırıldı; giysiye dokun → sheet; VoiceOver eylemleri |
| C3 | Renk değerleri | v2.8 token JSON (`#A76D49` bakır, `#654632` espresso) ↔ kullanıcının marka panosu (D-026) | Kullanıcı kararı kazanır. Rol adları eşlendi (`FigmaTokenMap`, D-032). v2.8 bakır `#F8F6F1` üstünde 4.5:1 metin kuralını geçmiyor |
| C4 | "Önce Figma, sonra kod" | v2.8 §14.2 ↔ kullanıcı: "figma tarafini daha sonra baglayacagiz" + View koltuğu | Kod ilerliyor; `BLOCKED_EXTERNAL_FIGMA` (D-033) |
| C5 | Şehir: "gerçek 3D sahne" | v2.8 §01/§06 ↔ mevcut 2B Blender kadrajı | Dürüst etiket: "şehir Blender kadrajı" (D-034). Gerçek 3D: UI28-05 |
| C6 | Seyahat nerede? | v2.5 sağ sütunda bavul ↔ v2.8 §02 "profilden ya da şehir menüsünden" | Şehir sheet'inin araç çubuğunda "Seyahat" |
| C7 | Geri al nerede? | v2.5 sağ sütun ↔ v2.8 "üçüncü CTA gerekçesiz eklenemez" | Değişiklikten sonra 6 sn'lik "… · Geri al" notu ve sheet içinde geri al |
| C8 | Yağmur önizlemesi düğmesi | v2.5 sağ sütun ↔ v2.8 en fazla iki kontrol | Şehir ve hava sheet'inde anahtar |
| C9 | Cloud VTON (Decart) | v2.6 entegrasyon planı ↔ ADR-008, güvenlik kuralları | Bayrak OFF. Hesap açılmadı, sözleşme imzalanmadı, MCP ve skill kurulmadı (`BLOCKED_EXTERNAL`, HUMAN_APPROVAL_PENDING) |
| C10 | Kişisel yüz ve saç ikizi | v2.7 §5 ↔ kullanıcı fotoğrafı ve rıza yok | `HUMAN_APPROVAL_PENDING`. Nötr manken açıkça "Örnek beden" diye etiketli |

## 3. Bu turda yapılanlar

| WP | İş | Durum | Kanıt |
|---|---|---|---|
| UI28-00 | Denetim, çelişki matrisi, ADR-011, kanon kurulumu, CLAUDE.md | CODED (belge) | bu dosya, `docs/adr/ADR-011…`, D-029…D-034 |
| UI28-01 | Figma dosyası | **BLOCKED_EXTERNAL_FIGMA** | View koltuğu; dosya ve link yok |
| UI28-02 | WorldHome yerleşimi | CODED, SIMULATOR_VISUAL_VERIFIED | Yerleşim: wordmark + şehir/hava chip'i; yalnız `Yeni kombin` ve `Dene`. UI testi `testFirstLaunchWorldAndTabs`, ekran `v28-H01` |
| UI28-03 | DailyOutfitPlanner, OutfitCache, tarih ve saat dilimi | CODED, UNIT_TESTED | `MorningReadyTests`: 11 test (UI28-T001…T010 + anahtar). Soğuk açılış cihazda ölçülmedi: UNKNOWN (device) |
| UI28-04 | WeatherGateway, tazelik ve sahne durumu | CODED, UNIT_TESTED, SIMULATOR_VISUAL_VERIFIED (test verisiyle) | `testWeatherFreshnessStates`. Gerçek sağlayıcı yok: BLOCKED_EXTERNAL (R-003) |
| UI28-05 | Gerçek 3D şehir, yağmur ve ıslak zemin LOD'u | NOT_STARTED. 2B kadraj dürüstçe etiketli | D-034 |
| UI28-06 | Giysiye dokun → sheet → geri al, sahneyi yukarı alma | CODED, SIMULATOR_VISUAL_VERIFIED | `testWorldDressingSwapUndoAndNewLook`, ekran `v28-H02` |
| UI28-07 | 3 aday önceden hazır, atomik değişim | CODED, UNIT_TESTED | Gecikme cihazda ölçülmedi: UNKNOWN (device). Simülatördeki model süresi "Neden bu kombin" ekranında |
| UI28-08 | 4 sekme, Dene birleşimi, kamera yoksa geri düşüş | CODED, SIMULATOR_VISUAL_VERIFIED | `testMirrorEntryAndCameraFallback`, `testScanDecisionCard` (kod → Dene → 3D modelimde) |
| UI28-09 | Fotoğraftan dolaba aktarma | SPEC. Dene'de "Bu sürümde yok" diye açıkça yazıyor | |
| UI28-10 | Yüz ve saç benzerliği | HUMAN_APPROVAL_PENDING | C10 |
| UI28-11 | Canlı kamera akışı | CODED (v2.5). Cihazda doğrulanmadı: REAL_DEVICE_BLOCKED | |
| UI28-12 | Cloud VTON | BLOCKED_EXTERNAL. Bayrak OFF | C9 |
| UI28-14 | Erişilebilirlik | Kısmen: AX-XXXL testi ve VoiceOver slot eylemleri CODED. Karanlık mod ve Reduce Motion için ayrı UI testi yok | `testHomeAtAccessibilityTextSize` |
| UI28-15 | Görsel karşılaştırma ve performans | Simülatör ekranları alındı. Bağımsız tasarım incelemesi ve cihaz performansı: UNKNOWN | |
| UI28-16 | Kanon belgeleri | CODED | CLAUDE.md v2.8'i gösteriyor |

## 4. Engeller (v2.8 hedefine karşı)

| # | Engel | Durum |
|---|---|---|
| B1 | Gerçek iPhone'da FPS, RAM, ısı ve soğuk açılış ölçümü yok | REAL_DEVICE_BLOCKED. iPhone 14 Pro Max eşli ama imzalı kurulum yapılmadı. Hedefler (p95 ≤1 s / ≤1.5 s / ≤0.7 s): UNKNOWN |
| B2 | Figma yazma izni | BLOCKED_EXTERNAL_FIGMA (View koltuğu) |
| B3 | Hava sağlayıcısı | BLOCKED_EXTERNAL (R-003, Apple PLA) |
| B4 | Gerçek 3D şehir sahnesi (USDZ + RealityKit PBR) | NOT_STARTED (UI28-05) |
| B5 | Kişisel yüz, saç ve beden ikizi | HUMAN_APPROVAL_PENDING (rızalı çoklu fotoğraf) |
| B6 | Fotoğraftan dolaba aktarma | SPEC (UI28-09) |
| B7 | Lisanslı katalog ve ürüne özel 3D (G2) | BLOCKED_EXTERNAL (R-004) |
| B8 | Cloud VTON | BLOCKED_EXTERNAL |
| B9 | Kullanılabilirlik testi (5 kişi, UI28-T051) | HUMAN_APPROVAL_PENDING |
| B10 | Nötr baş: yüz hatları yok, oyuncak hissi (v2.7 §1 baseline) | CODED olarak kaldı. Parametrik baş ve saç işi B5'e bağlı |

## 5. Sıradaki en küçük iş

1. B1: iPhone 14 Pro Max'te imzalı kurulum. Ölçülecekler: soğuk açılış, ilk giyinik kare, kombin değişimi ve 60 sn döndürmedeki FPS ve ısı.
2. UI28-05: Blender sahnesini USDZ'ye aktarıp RealityKit'te yüklemek; boyutu ve FPS'i ölçmek. Ölçüm kötüyse 2B kadraj etiketli kalır.
3. UI28-09: PhotosPicker → Vision ile ön sınıflandırma → onay kuyruğu.

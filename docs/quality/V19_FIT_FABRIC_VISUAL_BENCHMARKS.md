# V19 fit, kumaş ve görsel benchmark tasarımı

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 6 · V19-18, V19-19 · Genel kurallar: `docs/quality/V19_BENCHMARK_PROTOCOL.md`
**Ölçülmüş sonuç yok. Baseline'lar bugünkü kodun davranışıdır, doğruluk iddiası değildir.**

## 1. Baseline'lar (bugünkü kod)

| Alan | Baseline | Kod | Bilinen hata |
|---|---|---|---|
| Fit | `SizeAdvisor.advice`: Fit Passport (marka+kategori, ≥2 tutarlı kayıt) → tablo eşleşmesi (göğüs/bel) → abstain | `FitPassport/SizeAdvisor.swift:76-125` | FIT-03 başka model geçmişi (`Tests/KabinsizCoreTests/ShoppingAndFitTests.swift:119-125`); FIT-04 eksik ölçü atlanır (`SizeAdvisor.swift:133-135`) |
| Kumaş | 4 boolean iddia, kaynaklı | `DomainContracts/Garment.swift:73-82` | Lif %, bakım yok |
| Termal | `low <= 15` → sıcak katman | `TravelEngine/Weather.swift:77-79` | Sabit eşik (TMP-01) |
| Görsel | Her zaman `2D_CARD` | `ShoppingCopilot/DecisionComposer.swift:47` | 3D/asset yok |
| Gövde önizleme | 2D siluet, yapısal istasyonlar | `BodyGeometry/Silhouette.swift` | Mesh yok |

## 2. Veri setleri ve haklar

| Set (V19-19.1) | İçerik | Hak / rıza | Kim üretir | Durum |
|---|---|---|---|---|
| `SyntheticFitFixtures` (yeni) | Sentetik gövde × sentetik bitmiş ölçü × beklenen bölgesel sonuç (abstain dahil); her satırda beklenen etiket elle yazılır | Repo | Kod ajanı + bağımsız reviewer | Yazılabilir (R17-05) |
| `GarmentMeasurementTruthSet` | Teknik modelist ölçüsü + insan ölçüsü + denenen beden sonucu | Rızalı gönüllü, modelist | İnsan | `BLOCKED_EXTERNAL` / `HUMAN_REVIEW_PENDING` |
| `FabricLabelTruthSet` | TR/EN/DE bakım etiketi metni ve sembolleri; wash/wear ayrımı | Etiket fotoğrafı hakkı; ISO metin lisansı | Kod (metin) / insan (foto) | Sentetik metin yazılabilir (R17-04) |
| `AvatarGeometryFixtures` | Referans ölçülü gövdeler → mesh kesit çevresi | Repo (prosedürel) | Kod | WP15-07/08 ile |
| Lisanslı ürün asset seti | Doku, logo, renk referansı | Marka hakkı | Marka | `BLOCKED_EXTERNAL` |
| `StyleOutfitPreferenceSet` | Kör panel + kullanıcı pairwise | Rıza + eval izolasyonu | İnsan | `HUMAN_REVIEW_PENDING` |

## 3. Metrikler ve geçme koşulları (ön kayıt taslağı; eşikler insan uzmanla birlikte konur)

| Metrik | Tanım | Sentetik sette koşulabilir mi | Eşik |
|---|---|---|---|
| `false_exact_fit_rate` | Beklenen `ABSTAIN/PARTIAL` iken kesin beden çıkan vaka / tüm vaka | Evet | Sentetik set: **0** (deterministik kural; tek ihlal = hata) |
| `fit_abstention_rate` | Abstain / tüm vaka | Evet (yalnız raporlanır) | Eşik yok; düşük abstain tek başına başarı değil |
| `fit_region_precision`, `overconfidence_error`, `fit_ECE` | Gerçek sonuçla bölge bazında | Hayır | `UNKNOWN` — gerçek veri ve modelist olmadan konmaz |
| `wash_wear_confusion` | 30 °C yıkama değerinin hava/konfor alanına geçtiği vaka | Evet (tip testi) | **0** |
| `fabric_inference_from_image` | Görüntüden lif/esneme çıkarılan vaka | Evet (statik + birim) | **0** |
| `visual_tier_mislabel` | Asset olmadan "ürüne özel" etiketi | Evet | **0** (bugün T-V13-007, `ShoppingAndFitTests.swift:51`) |
| `logo_OCR_agreement`, `garment_asset_texture_fidelity` | Lisanslı referansla | Hayır | `BLOCKED_EXTERNAL` |
| `mesh_circumference_error` | Mesh kesit çevresi − girilen ölçü | Evet (prosedürel) | Ön kayıt WP15-07/08'de |

## 4. Ablation ve holdout

- **Fit:** (a) yalnız tablo, (b) yalnız Fit Passport, (c) ikisi; her biri `SyntheticFitFixtures` üzerinde `false_exact_fit_rate` ve abstain. Gerçek veri gelince aynı üç kol `GarmentMeasurementTruthSet` holdout'unda (%30, kişi bazında ayrık; aynı kişi hem eğitim hem testte olmaz).
- **Stil:** "nötr önce" baseline ↔ Atelier vektör sıralaması; yalnız kör panelde (V19-08.4). Panel örnekleri ayarlama verisine girmez.
- **Termal:** sabit 15 °C ↔ katman modeli; gerçek kullanıcı konfor bildirimi olmadan yalnız tutarlılık testi.

## 5. Bilinen başarısız vakalar (koşmadan önce yazılır)

| # | Vaka | Beklenen | Bugün |
|---|---|---|---|
| F-1 | Göğüs+bel girilmiş, tabloda yalnız göğüs | `PARTIAL` + "bel tabloda yok" | Tam `chartMatch` (FIT-04) |
| F-2 | Aynı marka başka model, 2 "tam" kayıt | Abstain veya "başka modelde" notu | `likely` (FIT-03) |
| F-3 | %95 pamuk %5 elastan, 30 °C yıkama | Yıkama ≠ hava | Tip yok |
| F-4 | Asset yok, 3D istendi | `GENERIC` / 2D etiketi | 2D etiketi doğru |
| F-5 | Tek ölçü, iki satıra uyuyor | Abstain | Abstain (`SizeAdvisor.swift:137`) |

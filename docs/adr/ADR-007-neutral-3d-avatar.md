# ADR-007 — Nötr 3D morf avatar P0; 360° manuel döndürme; 2D siluet G0 yedeği

- Durum: KABUL · 2026-11-03 · C-11, C-12 · v1.5 §87.4, §108, §133.1; v1.6 VIZ-01/BODY-3D; v1.7 §3.2 G0..G3; v2.0 UI-06, §05.2; WP19-07
- D-003'ü kapatır, D-005'i tamamlar.
- **Güncelleme 2026-11-04:** §2 (mesh kaynağı) ADR-010 ile güncellendi: birincil gövde NAVER Anny tabanlı yontulmuş gövde; bu ADR’deki prosedürel gövde yedek olarak kalır.

## Karar

1. **Gövde avatarı P0'dır.** Nötr, örtülü, yüzsüz bir 3D gövde; kullanıcının `BodyProfile` değerlerinden deterministik üretilir. Görünüm fit kanıtı sayılmaz (v1.7 §3.2, V19-06.6).
2. **Mesh kaynağı: özgün, prosedürel, cihazda.** Silüetteki istasyonlardan (tepe → ayak bileği) eliptik kesitler çıkarılıp yumuşak bir yüzeye örülür; kollar ve bacaklar ayrı tüp gövdeler. Üçüncü taraf gövde modeli yok:
   - SMPL / SMPL-X / LHM: ticari olmayan lisans → kullanılamaz (docs/research/VTON_LANDSCAPE_2026-11.md).
   - NAVER Anny (Apache-2.0 + CC0) ve Meta MHR (Apache-2.0) ticari olarak uygun adaylar; indirme ve lisans dosyası incelemesi insan onayı ister. Daha gerçekçi bir taban gerekirse ayrı ADR ile değerlendirilir.
3. **Kesit oranı** ön genişlikten derinliğe: göğüs/bel/kalça için çevreden eliptik çözüm (Ramanujan yaklaşımı) — ön yarı genişlik 2D siluetle aynı kalır, böylece 2D ve 3D aynı gövdeyi anlatır.
4. **360° manuel döndürme:** sürükleyerek yatay eksende döndürme, iki parmakla yakınlaştırma; ön/yan/arka hazır açılar. Otomatik dönme yok; Hareketi Azalt açıkken ayrık açılar arası geçiş animasyonsuz (v2.0 §05.2).
5. **Yedek katmanlar (G0):** 3D çizilemezse veya bütçe `2D_CARD` derse aynı kontrollerle 2D siluet; o da olmazsa değer listesi. Etiket her zaman görünür.
6. **Giysi 360°** yalnız yetkili/hazır 3D asset varsa (C-12); yoksa "Genel silüet önizlemesi".

## Neden

Kullanıcının hedefi kendini 360° döndürebildiği bir model. Lisans riski taşıyan hazır modeller yerine, ölçülerden matematiksel olarak üretilen bir mesh hem lisanssız hem tamamen cihazda hem de test edilebilir (her kombinasyon için geçerlilik testi, BOD-02 ile aynı yaklaşım).

## Sonuç

- WP15-07/08: `BodyGeometry.BodyMesh` (saf Swift, test edilebilir) + RealityKit görünümü (uygulamada).
- Performans iddiası yok; gerçek cihaz ölçümü WP15-18 / WP19-13 (`REAL_DEVICE_BLOCKED`).

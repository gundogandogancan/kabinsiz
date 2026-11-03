# ADR-011 — v2.8 kanonu: `Bugün | Dolabım | Dene | Ben`, sade ana sahne, sabah hazır kombin

- **Durum:** Kabul edildi (2026-11-03). ADR-010'un sekme ve ana ekran kontrol kısımlarının yerini alır; ADR-010'un marka paleti ve ikon kararı geçerli kalır.
- **Kaynak:** `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.8.md` (kanonik), ekler `addenda/…v2.6_TARA_VE_DENE…`, `addenda/…v2.7_TRUE_3D_DIGITAL_TWIN…`, `addenda/…v2.8_FIGMA_ALL_SCREENS_AND_MORNING_READY…`; komutlar `commands/CLAUDE_START_HERE_v2.8.md` (v2.7, v2.6 kısa komut aynı klasörde).
- **Öncelik:** v2.8 > v2.7 > v2.6 > v2.5; daha sıkı güvenlik/mahremiyet kuralı hangi sürümde olursa olsun kazanır.

## Karar 1 — ADR-UI28-NAV: dört sekme

`Bugün | Dolabım | Dene | Ben`. v2.5'teki ayrı **Ayna** sekmesi ve araç çubuğundaki ayrı **Tara** düğmesi kalkar; ikisi **Dene** sekmesinde tek yolculuk olur (v2.6 "Tara ve Dene"):

1. Ürünü getir: barkod (kamera ya da kod), dolabımdan, fotoğraf, bağlantı. Bağlı katalog yoksa bağlantı yolu bunu açıkça söyler.
2. Ürün kimliği ve varyantı: kaynağı ve güveni görünür. Varyant belirsizse prova başlamaz (UI28-T032).
3. Aynı oturumda iki görünüm: **3D modelimde** (Bugün sahnesine o parçayla döner) ve **Canlı Ayna** (ön kamera, yalnız cihazda).
4. Bulut video (Decart benzeri) bayrağı kapalı; sözleşme, DPA, ücret sınırı ve açık rıza olmadan açılmaz (`BLOCKED_EXTERNAL`).

Gerekçe: v2.8 §02 "Ana ekranın içine ikinci bir araç çubuğu koyma" ve "ayrı Tara ve Ayna sekmeleri yoktur". Cihazda 5 kişilik kullanılabilirlik testi (UI28-T051) yapılmadı: `HUMAN_APPROVAL_PENDING`.

## Karar 2 — Ana sahne: en fazla iki güçlü kontrol

- v2.5'te eklenen sol slot rayı (üst/alt/dış/ayakkabı/çanta/kemer) ve sağ eylem sütunu **kaldırılır** (v2.8: "kalıcı üst/alt/kemer/çanta kontrol kolonları KALDIRILACAK", UI28-T015).
- Üst bar: solda `Kabinsiz`, sağda şehir · hava chip'i. Hava verisi yoksa chip "Hava verisi yok" der; derece ya da yağmur uydurulmaz.
- Alt kenar: `Yeni kombin` (baskın) ve `Dene` (ikincil). Hazır ikinci aday yoksa `Yeni kombin` gösterilmez (UI28-T018).
- Giysiye dokun → o slotun alt sheet'i (≈1/3 yükseklik): üç alternatif, çıkar (aksesuarlar), geri al. Sheet açıkken kamera modeli yukarı alır; yüz ve dizler sheet arkasında kalmaz (UI28-T014).
- VoiceOver: modelin üzerinde slot eylemleri (custom actions) dokunmanın erişilebilir karşılığıdır (UI28-T019).
- Avatar önden 3/4 açar (yaw ≈ 26°, aralık 20–35°, UI28-T011).
- "Neden bu kombin", geri al ve şehir değişimi sheet'lerden açılır; ayrı düğme sütunu yok.

## Karar 3 — Sabah hazır (UI28-03/04)

Paket içinde `MorningReady` modülü: `DailyOutfitPlanner` (3 aday), sürümlü `OutfitCache` anahtarı `cityID + localDate + timezone + wardrobeRev + avatarRev + prefsRev + weatherKey + modelVersion`, atomik dosya yazımı ve bozuk dosyada güvenli düşüş, `WeatherFreshness` (canlı / son bilinen / yok), `OutfitReconciler` (kullanıcı kilidini hava ya da şehir güncellemesi asla değiştirmez). Uygulamada `ForegroundWarmStart` önbelleği ilk karede gösterir; `BGAppRefreshTask` yalnız fırsatçıdır, **06.00 garantisi yok**.

## Karar 4 — Renk tokenları

v2.8 token JSON'u (`docs/design/figma/KABINSIZ_FIGMA_DESIGN_TOKENS_v2.8.json`) "bağlayıcı taslak" ve "not imported in Figma" durumundadır. Kullanıcı 2026-11-03'te marka panosunu ve yeni ikonu açıkça seçti ("app icon ve uygulama ici tasarim bu sekilde olsun"); kullanıcının açık kararı anayasa taslağının önündedir. Bu yüzden:

- Kodun değerleri marka panosu değerleri olarak kalır (ADR-010).
- v2.8'in 14 rol adı (`canvas, surface, sand, stone, ink, secondaryInk, espresso, olive, copper, hairline, scrim, success, warning, danger`) koddaki rollere birebir eşlenir (`FigmaTokenMap`). Test, JSON'daki her rolün eşlendiğini doğrular (UI28-T030).
- Ayrıca v2.8 açık bakır `#A76D49`, `#F8F6F1` üstünde yaklaşık 3.9:1 verir; metin için 4.5:1'in altında kalır. Bizim bakır `#9A5D3C` 4.67:1 verir.
- Figma bağlanınca değişkenler bu eşlemeden üretilir.

## Karar 5 — Figma

Figma MCP bağlantısı var. `whoami` çıktısı: Starter planı, **View** koltuğu. Bu koltukla dosya oluşturma ve yazma yapılamıyor; ayda yaklaşık 6 araç çağrısı sınırı da var. Durum `BLOCKED_EXTERNAL_FIGMA`. Figma dosyası oluşturulmadı, link yok, `FIGMA_CREATED` hiçbir yerde yazılmaz.

v2.8 §14.2 "önce Figma" sırasını öngörüyordu. Kullanıcının kararı ise farklı: "figma tarafini daha sonra baglayacagiz". Bu yüzden kod ilerliyor; Figma'ya aktarılacak sözleşme repoda tutuluyor (`docs/design/figma/`: token JSON'u ve bileşen → SwiftUI eşlemesi).

## Karar 6 — Şehir sahnesi dürüstlüğü

Blender'da üretilen İstanbul ve Barcelona kadrajları, RealityKit'teki 3D avatarın arkasında **2B arka plan görüntüsüdür**. Bu ADR'de gerçek zamanlı 3D şehir yoktur. Uygulamada "3D şehir" denmez. Sahnenin gerçeklik etiketi "Blender'da üretilmiş şehir kadrajı · 3D model önde" şeklindedir. Gerçek 3D sahne, yani USDZ'yi RealityKit'te yüklemek, ayrı bir iştir (UI28-05) ve cihazda FPS ölçümü gerektirir.

## Sonuçlar

- UI testleri yeni kimliklerle güncellenir: `tab-dene`, `worldGarmentSheet`, `homeTryOn`, `weatherChip`.
- `LiveMirrorEntryView` ve `ScanView`, `TryOnHubView` altında birleşir; kamera izni reddedilirse sistem kendi fallback ekranına düşer.
- Cihaz kanıtı yok: bütün süre hedefleri `UNKNOWN (device)` olarak raporlanır.

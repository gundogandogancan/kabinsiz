# CLAUDE CODE — KABİNSİZ v3.2 UYGULAMAYA BAŞLAMA EMRİ

Ürün felsefesi: **Maximum Intelligence. Minimum Interface.** Kullanıcıya yalnız `Bugün · Dolabım · Dene` gösterilir; profil üst köşededir. Her ekran tek amaç ve birincil eylem taşır. Üst/alt/ayakkabı menülerini ana modelin üstüne sürekli dizme; kullanıcı **kıyafete dokunduğunda** sade alt sheet aç.

ÖNCE ŞUNLARI OKU:
1. `KABINSIZ_v3_2_GOD_LEVEL_SCAN_MATCH_3D_MIRROR_EXECUTION.md` (en yeni bağlayıcı uygulama planı)
2. `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v3.2.md` (v3.0 tam anayasası korunmuş birleşik dosya)
3. `VISUAL_REFERENCES/CLAUDE_SCREEN_DESIGN_HANDOFF.md`, ilgili 12 PNG (görsel hedef, çalışan sistem kanıtı değil)
4. `V32_ACCEPTANCE_CASES.csv` (yeni test senaryoları)

**Görev sıran:**

### 0 — Kanıta dayalı başlangıç
`pwd; git status --short; git rev-parse HEAD; git log -5 --oneline` ve `CLAUDE.md` dosyasını oku. 4 Kasım 2026 araştırmasındaki HEAD `30ed2ef` idi; güncel kod farklı olabilir. Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `BodyMesh`, `LiveMirror/MirrorSession`, `ScanView`, `TodayView`, `WardrobeView`, `Atelier` bileşenlerini yeniden kullan; test/kanıt yoksa `UNKNOWN` de. Açık işlerin repo ve kanon versiyon çatışmasını ADR ile raporla.

### 1 — İlk P0 çalışan demo
Tek sıra: `Dene kamera → gerçek barkod oku → GTIN normalize → exact ProductGraph cache veya lisanslı kaynak → doğru varyantı kullanıcıya göster → avatar 3D garment preview`.

Eş zamanlı **en küçük Home vertical slice**: kişinin (önce dürüst test avatarı) 360° modeli, **giyilmiş G1/G2 gerçek mesh giysi**, kıyafete dokununca yalnız o slot seçenekleri, `Yeni Kombin` ve undo. Hedefe ulaşmadan diğer ekranların tasarımını bitmiş sayma.

### 2 — Fotoğraflardan dolap
`PhotosPicker → local instance detection + segmentation + OCR + embeddings → duplicate review → kişi onayı → OwnedGarment → gerçek 3D garment tier`. Kamera ve web linki aynı ProductResolver'a girecek; özel fotoğraf hiçbir yere gizli yüklenmeyecek.

### 3 — Yerel Canlı Ayna
Gerçek kamerayı (`AVFoundation`) kullanıcı istediğinde aç, local pose/segmentation/overlay'i bağla. `MirrorSession` state machine ve revision/frame guard'ı yeniden kullan; gerçek iPhone'da ölç. **Decart/Lucy CloudMirror varsayılan olarak KAPALI**; hukuki DPA, açık izin, harcama limiti, token güvenliği ve kullanıcı onayı olmadan gerçek video gönderme.

### 4 — Şehir, hava ve sabah
Hardcode İstanbul/Barcelona/başka şehir **yasak**. İzinli coarse location → gerçek cityId → WeatherKit source → uygun scene template/VFX; şehir sahnesi yoksa jenerik doğruluk fallback. Ertesi sabah outfit cache best-effort BGTask ile hazırlanır, uygulama açıldığında tarih/hava kontrol edilerek hızlı yenilenir.

### 5 — Kanıt şartı
Her WP sonunda kod dosyaları + test komutu ve exit + screenshot/video + GPU/latency varsa cihaz modeli + EVIDENCE.yaml + bağımsız reviewer + kalan blokları ver. Her şeyi tek oturumda "tamamlandı" deme. `V32_ACCEPTANCE_CASES.csv` ID'leriyle izlenebilirlik zorunlu.

**Ticari/harici eylemler:** Figma hesabı bağlama, ücretli model hesabı açma, üçüncü taraf API anahtarı, sözleşme imzası, video/foto veri aktarımı, marka CAD veya foto lisansı için yetkili insan kararı iste. Onaysız kurma, ödeme yapma, imzalama, dağıtma veya gerçek biyometrik fotoğrafı kullanma.

**İlk yanıt formatı (6 başlık):**
- `HEAD / mevcut repo gerçekliği`
- `Kanon/ADR çatışmaları`
- `Ürün–barkod–dolap–avatar–mirror için en kritik 10 eksik`
- `İlk implementasyon dosyaları / testler`
- `Gerçek SwiftUI/RealityKit ekran kanıtı ve süre ölçüleri`
- `BLOCKED_EXTERNAL / bir sonraki WP`

**Temel kırmızı çizgi:** Saniyelik *barcode decode* ≠ saniyelik *doğru SKU* ≠ saniyelik *fiziksel doğru 3D mesh*. Kullanıcıya güzel görünen yanlış ürünü veya görsel provayı gerçek beden/ürün kanıtı olarak gösterme.

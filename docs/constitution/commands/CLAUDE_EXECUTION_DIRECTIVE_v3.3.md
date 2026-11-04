# CLAUDE CODE — KABİNSİZ v3.3 KANIT + DİKEY ÜRÜN EMRİ

**Ürün felsefesi:** MAXIMUM INTELLIGENCE. MINIMUM INTERFACE. Jobs (üründe tek amaç) + Woz (mühendislikte derinlik) + kanıt/deney ilkesi. Kullanıcıya 3 tab `Bugün / Dolabım / Dene`, profil sağ üst. Önce doğru çalışan ürün, sonra görsel cila.

**Bağlayıcı belgeler (bu sırada):**
1. `KABINSIZ_v3.3_REALITY_AUDIT_AND_PRODUCT_ENGINEERING_BLUEPRINT.md`
2. `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v3.2.md`
3. `SCREENSHOT_EVIDENCE` gerçek simülatör görüntüleri; `REFERENCE_MOCKUPS` görsel hedef; ikisini kanıt sınıflarıyla ayır.
4. Repo `CLAUDE.md`, `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md`, `docs/evidence/`, kod, testler.

## 0 — BAŞLAMADAN GERÇEK DURUM

`pwd`, `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, `git log -10 --oneline`, `git diff --stat`, `git status --porcelain=v1`, varsa unpushed commitler ve remotes. Sohbetteki son doğrulanmış `main` HEAD **30ed2ef**; kullanıcının 23:35–23:37 ekranları 4 sekme/3D sahne gösteriyor. Bunlar HEAD'le çelişebilir. Yerel dal/çalışma ağacı/tüm screenshotları karşılaştır, önce bunu çöz. Başka branch veya untracked work varsa silme/ezme. Kanonsal v3.2 ve repodaki `CLAUDE.md` v2.1 işaretini ADR'la uzlaştır.

**Kesinlikle git'te main'i doğrudan yeniden yazma, mevcut sistemi sıfırlama veya isimsiz dev ajan ordusu yaratma.** Mevcut `Octopus`, `Vault`, `Citadel`, `BodyMesh`, `LiveMirror/MirrorSession`, `Atelier` ve `DomainSchemas` yeniden kullanılacak.

## 1 — ÖNCE EN KRİTİK İKİ UÇTAN UCA DENEYİM

**A. Store-to-self:** `AVFoundation/VisionKit gerçek barkod → normalize GTIN/internal alias → lisanslı/cached gerçek varyantı exact resolve et → gerçek ürün card → doğru G1/G2 giysiyi avatar üzerinde 360° göster → hazır giysiyle hızlı swap`. Arada gerçek veri yoksa “tamamlandı” deme.

**B. Photo-to-closet:** `PhotosPicker → seçilen gerçek fotoğrafta giysi segmentasyonu + OCR + yerel dedup → kullanıcı onayı → OwnedGarment → 3D template/asset → sahnedeki avatar`. Başta galeriye sessiz toplu erişim, rastgele yüz seçme veya upload YOK.

**C. Local Mirror:** `AVFoundation gerçek kamera → person segmentation/pose/depth → giydiği farklı kıyafeti/örtülmeyi yönet → doğruluk etiketli local overlay`. Gerçek iPhone videosu olmadan `DEVICE_VERIFIED` demezsin. `CloudMirror` production OFF: DPA+lisans+özel veri kullanım şartları+fiyat tavanı+insan onayı olmadan Decart'a gerçek frame gönderme.

**D. First frame:** kullanıcıya ait monogram logo kısa ve sakin biçimde görünür; cache/poster hazır olur, logo yukarı geçer, 3D sahne yüklenir. Gerçek perf ölçmeden sabit 1 saniye bekleme koyma.

## 2 — HER EKRAN VE KART

Sadece ana ekran değil: Splash, First Run, Avatar/Body/Face/Hair, Today, Garment Tap Bottom Sheet, Outfit Alternatives, Wardrobe, Photo Review Queue, Product, Scan/Photo/Link, Exact/Ambiguous/NotFound, 3D Tryon, Local Mirror, Cloud Consent, Weather City, Trip, Profile, Privacy/Delete, Partner Portal için **1 satır giriş→eylem→sonuç→boş/hata→a11y→görsel token→test** hazırla. Görsel referansları kopyalamak yerine iPhone ergonomisiyle uygula: ana model görünümü sürekli kategori düğmeleriyle örtülmez.

## 3 — DENETİM YÖNTEMİ

Her ilgili kaynak dosyanın her fonksiyonunu gerçek test/kanıtla denetle. Tablo satırı: `requirement_id, code_path:line, observed_behavior, evidence, status, owner, impact, next_diff, test_id`. Yalnız “kod bulundu” = `CODED`, gerçek kamera veya fit doğruluğu = ancak `DEVICE_VERIFIED/PARTNER_VERIFIED/USER_VALIDATED`. `UNKNOWN` açıkça yaz. Tüm dosyaların sayısal kapsamını göster, gerçekten okumadığın satırı incelemiş sayma.

## 4 — BİR İŞ PAKETİ BİTİNCE

`SPEC → THREAT → ADR → CODE → UNIT → UI → REAL DEVICE → PERF/PRIVACY → INDEPENDENT REVIEW → EVIDENCE → GATE`.

Bana **6 başlık altında** cevap ver:
1. Gerçek HEAD, dal, önceki gece ekranlarına göre fark.
2. Bugünkü olgunluk L0–L5 ve kanıtla en kritik 12 açık.
3. İlk gerçek çalışan uçtan uca akış: iPhone video/screenshot/test komutu/exit.
4. Kod değişiklikleri ve satır/file referansları; regression test.
5. Güvenlik, üçüncü taraf sözleşme ve `BLOCKED_EXTERNAL` listesi.
6. **Tek sonraki en yüksek değerli iş** ve PASS şartı.

**Yasak:** bir Figma görselini gerçek 3D ürün gibi, fotoğrafı garment CAD gibi, GTIN'i bitmiş ölçü gibi, VTON videosunu bedene tam olur kanıtı gibi veya SDK dosyasını entegre çalışan kamera sistemi gibi sunma. Ücretli servis hesabı, sözleşme, gerçek fotoğraf/video aktarımı veya ana dala push için gerekli yetkili insan onayını açıkça iste.

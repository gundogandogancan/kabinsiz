# ADR-009 — Tasarım tokenı göçü: soğuk mavi-gri → Quiet Atelier (C-14)

- Durum: KABUL · 2026-11-03 · UI20-WP02, UI20-WP03, UI20-WP04 · v2.0 §03, §04, §05, §06, §09, §10 · C-14

## Bağlam

v1.5 §4.3 tokenları (`brand.ink #283D46`, tümü sans başlık) `apps/ios/Kabinsiz/DesignSystem/Theme.swift` içinde duruyordu. v2.0, bunların yerine "Atelier Linen" (açık) ve "After Hours" (koyu) paletini koyuyor. Başlıklar için sistem serifini (New York) istiyor. v2.0 tasarım kararı eski tokenı geçer. v2.0 §10 ise global yeniden yazımı yasaklıyor.

## Karar

1. **Tek kaynak `DesignTokens` modülü** (KabinsizCore, saf Swift, UI çatısı yok).
   - Renk rolleri, dört görünüm, kontrast kuralları, §05 geometri ve eski → yeni eşleme burada tutulur.
   - Dört görünüm: açık, koyu, açık + Increase Contrast, koyu + Increase Contrast.
   - Uygulama renkleri yalnız buradan, `AtelierTokens.swift` üzerinden alır. Bu sayede her renk çifti macOS'ta test edilir.
   - Asset Catalog'daki tek renk `SurfaceBase` (açılış ekranı için) aynı değerlerle güncellenir.
2. **Göç adaptörü.**
   - `Theme.swift` içindeki eski adlar (`Token.brandInk`, `Token.surfaceBase` …) korunur, ama artık yeni rollere çözülür.
   - Eşleme tablosu: `LegacyTokenMigration` ve `docs/design/COLOR_CONTRAST_REPORT.md`.
   - Ekranlar yeniden tasarlandıkça (UI20-WP05…09) doğrudan Atelier bileşenlerine geçer. Eski adlar ancak hiçbir ekran kullanmadığında silinir.
3. **Spec'in açık bıraktığı roller (bu ADR'ın seçimi).**
   - Koyu `surface.sand #332D26` ve koyu `avatar.neutral #8E8A85`.
   - Koyu durum renkleri: `#8CC7A1`, `#E0B36A`, `#EE9A9C`.
   - **`on.brand`**: açıkta `#FFFCF8`, koyuda `#1A1612`. Koyu modun marka rengi açık kahve olduğu için CTA yazısı koyuya döner; beyaz yazı orada yaklaşık 2.3:1 kalırdı.
   - **`border.control`**: açıkta `#8C8174`, koyuda `#8A7F72`. Kontrol sınırı için 3:1 sağlar; `border.soft` yalnız süs ayırıcıdır.
4. **Increase Contrast.**
   - Her metin çifti 7:1 (AAA), her metin dışı çift 4.5:1 sağlar.
   - Değerler `AtelierPalette` içinde. Hiçbir çift temel görünümden daha düşük kontrasta inmez (test edilir).
5. **Kontrast kuralı sözleşmesi.**
   - `AtelierContrastRules.all` hangi rengin hangi zemine çizilebileceğini listeler; listede olmayan çift izinli değildir.
   - Her rol ya bir kurala girer ya da açıkça yalnız süs sayılır: `border.soft` ve `avatar.neutral`. Manken 3B gölgelendiği için düz kontrast kuralı uygulanmaz.
   - Rapor koddan üretilir; elle düzenlenirse test kırılır.
6. **Tipografi (v2.0 §04).**
   - Serif yalnız `display`, `screenTitle`, `sectionTitle` ve wordmark'ta. Geri kalan her şey SF Pro.
   - Hepsi Dynamic Type metin stilleri üzerinden; sabit punto yok.
   - Ölçü ve tarihlerde `monospacedDigit`. Otomatik büyük harf yalnız 1–3 sözcüklük eyebrow'da.
   - Üçüncü taraf font yok.
7. **Bilgi mimarisi (v2.0 §06 P0).**
   - Üç sekme: `Bugün | Dolabım | Ben`. "Benim Modelim" sekme adı "Ben" olur; ekran içi başlık "Benim Modelim" kalır.
   - `Tara` sekme değildir: her sekmede araç çubuğu eylemi, ayrıca Bugün'de görünür bir buton.
   - Her sekme kendi `NavigationStack` yolunu korur; Tara kapanınca önceki ekrana dönülür.
   - Sheet politikası §08.3: kanıt detayı orta yükseklik, üst üste en çok iki modal.
8. **Bileşen kataloğu (K-001…K-020).**
   - `AtelierComponents.swift` içinde, `DesignPreview/AtelierComponentCatalogView` ile önizlenir.
   - Katalog yalnız DEBUG derlemede ve `-componentCatalog` başlatma argümanıyla açılır.
   - Katalogdaki her veri `SYNTHETIC_DEMO_ONLY` etiketlidir.
9. **Bugün'ün kahramanı kişinin kendi modelidir (kullanıcı kararı, 2026-11-03).**
   - Kullanıcı geri bildirimi: ekran "ansiklopedi gibi"; kişi kendi modelini canlı görmeli.
   - Bugün'de ekranın yarısı bir stüdyo sahnesi; içinde parmakla çevrilen, iki parmakla yaklaşan 3B beden (`heroBody3D`).
   - Kayıtlı beden yoksa nötr başlangıç şekli gösterilir. Bu şekil hiçbir şey kaydetmez, ölçü iddia etmez ve "Nötr başlangıç" etiketi taşır.
   - Kahramanın tek `PrimaryAction`'ı "Modelimi oluştur" (`primary.createModel`) ya da "Modelimi düzenle" (`primary.editModel`). Dolap satırı ikincil karttır.
   - Canlılık: model hafifçe nefes alır ve ±11° salınır; dokununca durur, 4 sn sonra kaldığı yerden döner, önden hiç uzaklaşmaz. Hareketi Azalt açıkken, termal/Düşük Güç notu varken ve 2B bütçede kapalıdır.
   - 2B bütçede (`flat2D`) 3B sahne yerine sakin bir siluet çizilir.
   - Her görünümde "Görünüm, beden uyumunun kanıtı değildir." etiketi vardır (yanıltıcı uyum iddiası yok).
   - Ben sekmesi de aynı modeli büyük (380–460 pt) ve canlı gösterir.
   - Sayfa modelin üstünden kaydırılabilir. `RealityView` dokunuş almaz. Döndürme, yalnız parmak yana hareket ettiğinde başlayan bir UIKit pan tanıyıcısıyla yapılır; dikey sürükleme sayfayı kaydırır. Yakınlaştırma iki parmakla pinch'tir. SwiftUI `DragGesture` kaydırma görünümünü kilitlediği için reddedildi; UI testleri (gövde stüdyosu, kasa) kaydırılamayınca bu hata yakalandı.

## Sonuçlar

- Tüm ekranlar renk açısından anında yeni palete geçer; düzen (hiyerarşi, hero, kartlar) ekran ekran yenilenir.
- Kontrast yalnız düz zemin için kanıtlıdır. Liquid Glass sekme çubuğu, saydamlık ve fotoğraf üzeri metin cihazda ölçülmelidir: UI20-T-003 kısmen `REAL_DEVICE_BLOCKED`.
- Increase Contrast için Asset Catalog yerine kod içi dinamik renk kullanılır (`UITraitCollection.accessibilityContrast`). Bunun nedeni test edilebilirliktir; davranış aynıdır.

## Reddedilen seçenekler

- **Bütün ekranları bir kerede yeniden yazmak:** v2.0 §10 bunu yasaklıyor; ayrıca kırık build ve test riski taşıyor.
- **Renkleri yalnız Asset Catalog'da tutmak:** kontrast macOS'ta test edilemezdi.
- **Özel font (lisanslı serif):** lisans ve paket hakkı kanıtı yok (§04.1.5).

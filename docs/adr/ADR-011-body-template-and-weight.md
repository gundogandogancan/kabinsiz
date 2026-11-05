# ADR-011 — İsteğe bağlı cinsiyet (Kadın / Erkek / Nötr), boy ve kilo ile model oluşturma

- Durum: KABUL · 2026-11-05 · kullanıcı kararları (2026-11-05 sohbet):
  - "kadın olursa kadın, erkek olursa model erkek olacak … kilosu ve boyu nasılsa ona göre bir model olacak"; plan onayı "başla"
  - "cinsiyet seçme vs yok mu? ordan yapalım. anlamlaştıralım iyice."
  - ANSUR II verisinin indirilip kullanılması: "İndir, kullan"
  - ADR-010 §3'ü günceller.
- Dayanak (v2.1 birleşik metin; satır numaraları 2026-11-05 dosyasına göre):
  - "3. Kişisel beden ve modalite sınırları" (≈ satır 585–586): `weightKg` isteğe bağlı ve fit kararı için tek başına yeterli değil; "kullanıcı … model görünümünü kendi seçer. Mahrem bölümler örtülü, nötr avatar varsayılan."
  - "24.1 Fundamental UX" (≈ satır 2645): zorunlu selfie ya da cinsiyet seçimi yok; kullanıcı biyolojik cinsiyet çıkarımı yerine şablon **şeklini** ve isteğe bağlı görünümü seçer.
  - "5.2 Parametrik nötr karakter tasarımı" (≈ satır 1327): gövde hiçbir cinsiyet seçimi olmadan işlev görür.
  - "1.4 Mutlak kurallar" (≈ satır 967–968): fotoğraftan cinsiyet çıkarımı yasak; çıplaklık ve mahrem yüzey yok.
  - "7. Sahici 3D ürün boru hattı" (≈ satır 235): ağırlığa göre şekillendirme kesin ölçü sayılmaz.
  - "11.4 Etik ve temsil" (≈ satır 1773): boy/kilo giren kullanıcıya "sağlıksız" gibi yorum yapılmaz.

## Karar

1. **Model bir başlangıç formuyla oluşturulur; formdaki her şey isteğe bağlıdır.**
   - Ben sekmesinde, gövde yokken: 3B önizleme, **Cinsiyet** (Kadın / Erkek / Nötr; varsayılan Nötr), birim, **Boy** ve **Kilo** alanları, "Modelimi oluştur" düğmesi.
   - Önizleme seçimleri anında izler; kaydetmeden önce kişi modelini görür (`BodyProfile.start`).
   - Hiçbir şey girmeden oluşturulan model eskisi gibi nötr başlangıçtır.
   - Aralık dışı ya da okunamayan bir giriş düğmeyi kapatır ve aralığı söyler. Yorum yapılmaz.
   - Bugün sekmesindeki "Modelimi oluştur" artık doğrudan kaydetmez, bu forma götürür.
   - Oluşturulunca sayfa modelin satırına kayar.
2. **Ekrandaki ad "Cinsiyet"tir.** Seçenek sırası Kadın, Erkek, Nötr.
   - Açıklama: "İsteğe bağlı. Modelin biçimini belirler; beden önerisinde kullanılmaz. Nötr: cinsiyet belirtmeden."
   - Koddaki ad `BodyTemplate` olarak kalır. Seçim yalnız çizimin biçimidir; hiçbir veriden çıkarılmaz ve sorulmak zorunda değildir.
   - Model etiketi: "3B model (kadın). Görünüm, beden uyumunun kanıtı değildir." Bugün kartı da aynı biçimi kullanır.
3. **Cinsiyet yalnız çizimi belirler.**
   - Her seçenek için ayrı bir fırınlanmış taban vardır: `SculptedBody-{neutral,female,male}.{bin,json}`.
   - Anny cinsiyet fenotipi nötrde 0,5, kadında 1,0, erkekte 0,0'dır (Anny'de 0 erkek, 1 kadın; `anny/shape_distribution.py`).
   - Diğer adımlar ADR-010 ile aynı: kollar aşağıda, yüzsüz yumurta baş, göz/ağız boşlukları kapalı.
   - Göğüs ucu, göbek ve kasık her tabanda 4 cm / 4,5 cm / 8 cm yarıçapla örtülür. Kadın tabanında göğüs yuvarlak ve uçsuzdur. 5 ve 6,5 cm denendi; ikisi de göğsü çanak gibi düzleştirip kenarda kırışık bıraktığı için reddedildi.
   - Seçim çizime `AvatarSnapshot.template` ile taşınır. 2B siluet bundan bağımsızdır.
4. **Cinsiyet değişince yalnız uygulamanın kendi değerleri yeniden çizilir.**
   - Kişinin kaydırdığı (`SLIDER_SHAPED`) ya da elle girdiği (`USER_MEASURED`) değerler hiç değişmez.
   - Başlangıç değerleri (`NEUTRAL_START`) seçeneğin başlangıç değerlerine geçer:
     - Nötr: `neutralStartCm`.
     - Kadın: omuz 39,5, göğüs 92,5, bel 78,5, kalça 101.
     - Erkek: omuz 42, göğüs 98, bel 85,5, kalça 97,5.
   - Bu değerler, kadın/erkek tabanının aynı boydaki nötr tabana oranı nötr başlangıçlara uygulanarak bulundu ve 0,5 cm'ye yuvarlandı. Norm değildirler.
   - Boy hiçbir zaman cinsiyetten türetilmez.
5. **Boy formda girilirse bir ölçüdür; kilo yalnız çizim içindir.**
   - Formda girilen boy `USER_MEASURED` olarak kaydedilir; elle girilmiş her ölçü gibi beden önerisine girebilir.
   - `BodyProfile.weightKg`: 30–250 kg, bir ondalık.
   - Kilo girilince, kişinin kaydırmadığı ve elle girmediği omuz, göğüs, bel ve kalça boy ve kilodan tahmin edilir. Bu değerlerin kaynağı `WEIGHT_ESTIMATE`, etiketi "Boy ve kilodan tahmin (ölçü değil)".
   - Tahminler `measuredCentimeters` içine, v2 `measurements` içine ve beden önerisine hiçbir zaman girmez. v2'de `avatar_morph_state` altında durur.
   - Boy değişince tahmin yeniden hesaplanır. Kilo kaldırılınca tahminler başlangıç değerlerine döner.
   - Bir düzenleme `WEIGHT_ESTIMATE` kaynağını talep edemez; böyle bir düzenleme reddedilir.
6. **Tahmin yöntemi: ANSUR II regresyonu (`BodyShapeEstimate`, `AnthropometricEstimate`).**
   - Kaynak: ANSUR II (ABD Ordusu NSRDEC, 2012), kadın n = 1986, erkek n = 4082. Veri "UNLIMITED PUBLIC RELEASE" ile yayımlandı (bellek 14 Nisan 2017).
   - Her cinsiyet ayrı uydurulur (veri setinin kendi isteği): `ln(cm) = a + b·ln(kg) + c·ln(boy cm)`. Nötr, iki tahminin log uzayındaki ortalamasıdır; birleşik bir örneklem değildir.
   - Okunan sütunlar yalnız boy, kilo, `biacromialbreadth`, `chestcircumference`, `waistcircumference` (göbek hizası) ve `buttockcircumference`. Irk, etnik köken, doğum yeri ve diğer demografik sütunlar okunmaz.
   - Katsayılar `scripts/avatar/fit_ansur_estimate.py` ile üretilip Swift dosyasına yazılır; uygulama CSV taşımaz.
   - Doğruluk (eğitim verisi üzerinde): log-artık SS kadında %3–6, erkekte %2–5. VKİ dilimlerindeki sapma çoğunlukla 0,5 cm altında, en kötü 1,5 cm (kadın göğüs, VKİ 15–20).
   - Tahmin yalnız 140–210 cm ve 40–160 kg aralığında yapılır. Dışında kilo saklanır ama çizimi değiştirmez; ekran bunu söyler.
   - Sonuç kaydırıcı adımına yuvarlanır ve güvenli aralıkta tutulur.
   - Örnekler: nötr 170 cm / 70 kg → bel ≈ 84 cm; kadın 165 / 60 → bel ≈ 78; erkek 180 / 80 → bel ≈ 88; kadın 165 / 100 → bel ≈ 113.
   - Önceki Anny ağırlık tablosu yöntemi kaldırıldı: Anny'nin VKİ aralığı dardı (en çok ≈ 24) ve VKİ 30 üstünde beli olduğundan küçük çiziyordu.
7. **Dosya biçimi 3: sıkıştırılmış taban.**
   - `.bin` ham DEFLATE ile sıkıştırılır (Python `zlib`, wbits −15); uygulama `NSData.decompressed(using: .zlib)` ile açar.
   - `binarySHA256` sıkıştırılmış dosyanındır ve açmadan önce denetlenir. Açılan boyut `rawByteCount` ve beklenen boyutla eşleşmezse dosya reddedilir (`basis-inflate`).
   - Paket boyutu: 3 × ≈ 0,5 MB + 3 × ≈ 17 KB JSON ≈ 1,5 MB (önceki biçimde ≈ 5 MB).
8. **Yedek sırası (G0):** seçilen tabanın yontulmuş gövdesi → o dosya kullanılamazsa nötr yontulmuş gövde → prosedürel gövde (ADR-007) → 2B siluet.
   - Her dosya kendi adını taşır; başka bir tabanın adıyla yüklenirse reddedilir (`basis-template`).
   - Cihaz bütçesi yalnız 2B'ye izin veriyorsa başlangıç formu da 3B önizleme göstermez.
9. **Kayıt uyumu.**
   - ADR-011 öncesi kayıtlar nötr ve kilosuz okunur.
   - Nötr ve kilosuz bir profil, eskisiyle aynı JSON anahtarlarını yazar.
   - v2 sözleşmesinde `avatar_morph_state.template` ve `weight_kg` alanları isteğe bağlıdır.
   - Geri alma ve yineleme cinsiyeti ve kiloyu da geri getirir.
10. **Ben sekmesinde boş 3B görünüm hatası düzeltildi.**
    - Belirti: model oluşturulduktan hemen sonra Ben sekmesindeki 3B alan boş kalıyordu; başka sekmeye gidip dönünce çiziliyordu.
    - Kök neden (simülatörde deneyle bulundu): List satırındaki RealityView'ın boyutu değişince çizim duruyor ve pencereye yeniden takılana kadar başlamıyor. Kaydırmak ve gövdeyi değiştirmek sorunu doğurmuyor. Görünümü `.id` ile yeniden kurmak düzeltmedi.
    - Çözüm: başlangıç önizlemesi ve kaydedilmiş gövde aynı satırda, aynı 3B görünümde ve sabit 460 pt yükseklikte durur. Oluşturmak yalnız gövdeyi değiştirir.
    - Koruma: `BodyTemplateUITests` oluşturduktan hemen sonra Ben sekmesinin ekran görüntüsünü alır.

## Neden

Kullanıcı modelin kendisine benzemesini istiyor ve bunun en anlaşılır yolu cinsiyet, boy ve kiloyu modeli oluştururken sormak. Anayasa görünümün kişi tarafından seçilmesine izin veriyor; çıkarım yapılmasını, seçimin zorunlu tutulmasını ve görünümün kanıt sayılmasını yasaklıyor. Bu yüzden her alan isteğe bağlı, varsayılan Nötr ve kilodan gelen her değer "ölçü değil" etiketi taşıyor. Anny'nin kendi ağırlık ekseni ağır bedenleri temsil etmediği için tahmin gerçek ölçümlere (ANSUR II) dayandırıldı.

## Sonuç

- Kod:
  - `BodyGeometry/BodyProfile.swift`: `BodyTemplate`, `weightKg`, `withAppearance`, `start`, `ValueSource.weightEstimate`.
  - `BodyShapeEstimate.swift`, `AnthropometricEstimate.swift` (üretilmiş).
  - `SculptedBody.swift`: taban başına dosya, format 3, açma.
  - `Silhouette.swift`: `AvatarSnapshot.template`.
  - `DomainSchemas/BodyProfileV2.swift`.
  - `Octopus/BodyJourney.swift`: `BodyStudio.create(_:)`, `setAppearance`.
  - Uygulama: `AppModel.createBody`, `setBodyAppearance`; `BodyStudioView` (başlangıç formu, tek 3B satır, cinsiyet seçici, kilo alanı); `MyModelView` (oluşturunca kaydırma, klavye); `TodayView` (form yönlendirmesi, etiket).
  - Araçlar: `scripts/avatar/bake_sculpted_body.py` (format 3), `scripts/avatar/fit_ansur_estimate.py`.
- Testler:
  - `OctopusTests/BodyAppearanceTests.swift`: ANSUR aralığı ve ortalamaları, başlangıç formu, stüdyoda oluşturma.
  - `OctopusTests/SculptedBodyTests.swift`: her taban, simetri, uç kombinasyonlar, yanlış adlı dosya, kesik sıkıştırılmış dosyanın reddi.
  - `ContractTests/BodyAppearanceSchemaTests.swift`.
  - `KabinsizUITests/BodyTemplateUITests.swift` (form → oluştur → Ben sekmesi çizimi → Erkek → geri al; aralık dışı giriş).
  - `AcceptanceDemoUITests` ve `AtelierNavigationUITests` yeni akışa uyarlandı.
- **Ölçülmedi / UNKNOWN:**
  - Gerçek cihazda kare süresi ve bellek (`REAL_DEVICE_BLOCKED`); RealityView boyut hatasının gerçek cihazda da olup olmadığı.
  - Tahminin ordu dışı nüfustaki hatası. ANSUR II asker örneklemidir (genç, VKİ p1–p99 kadında 18,8–34,8, erkekte 19,5–38,2); bu yüzden "tüm bedenler için" iddiası yoktur.
  - ANSUR belini göbek hizasında ölçer; uygulamanın mezura beli doğal bel olabilir. Tahmin bir çizim başlangıcıdır, ölçü değildir.
- Hukuki not: lisans yorumu mühendislik okumasıdır; ticari yayından önce AG-14 onayı gerekir (ADR-010 ile aynı).

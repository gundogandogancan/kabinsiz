# KABİNSİZ — GOD LEVEL v2.2
## QUIET ATELIER — VİZYONA DÖNÜŞ, PREMIUM UI/UX KURTARMA ve EKRAN EKRAN UYGULAMA ANAYASASI

**Tarih:** 3 Kasım 2026  
**Hedef repo:** `https://github.com/gundogandogancan/kabinsiz`  
**İncelenen `main` SHA:** `ba7605943c9c6c0df56bf34735a7c3ba9886e85b`  
**Belgenin durumu:** Tasarım düzeltme şartnamesi; uygulama geliştirilmedi, yeni iPhone testi çalıştırılmadı.  
**Kanonik teknik kaynak:** `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md`. Bu v2.2, **yalnız görsel kimlik, ekran deneyimi ve UX önceliklerini** kesinleştirir. Mevcut mahremiyet, ürün kanıtı, cihaz sağlığı ve güvenlik hükümlerini düşürmez.

> **Claude'a en önemli emir:** Kabinsiz'in mevcut SwiftUI ekranları teknik bir MVP'nin kayıt formları gibi görünüyor. Bunları görsel boya ile makyajlama. Kişinin gündelik moda ihtiyacı, mağazada anında ürün tarama, gerçekçi ama kanıt düzeyi doğru 3D prova, kişisel stilist ve gardırop deneyimlerini doğal, sıcak, unisex, editoryal **premium bir ürün tasarımına** dönüştür. Tasarım başarı ölçütü: kullanıcı 3 saniye içinde uygulamanın temel işini anlamalı, bir dokunuşla ürün taramaya gitmeli, güvenilmeyen veriyi gerçekmiş gibi görmemeli. En küçük değerli akışı tamamla; ölçülemeyen vaatleri kurma.

---

## 0 — GERÇEK REPO DENETİMİ: NEDEN ŞU ANKİ GÖRÜNÜM YANLIŞ?

| Kaynak | Kodda görülen durum | Düzeltme |
|---|---|---|
| `apps/ios/Kabinsiz/DesignSystem/Theme.swift` | `brandInk` = eski soğuk mavi-gri `#283D46`; açık yüzeyler `#F7F7F5`, `#FFFFFF`; sıcak editoryal palet uygulanmamış | Yeni semantik Atelier tokenları, light/dark/high contrast, tek kaynak |
| `DesignSystem/Components.swift` | Tek tip `Card`, `Chip`, `PrimaryButtonStyle`; bütün bilgiler aynı ağırlıkta kutulara giriyor | Editorial hero, look card, image tile, product truth row, cloth swatch, premium CTA, fit-region row, empty state |
| `Features/Today/TodayView.swift` | “Bugünkü kombin ... bu sürümde yok” kartı ve ardından baskın seyahat bölümü | Kullanıcının 1. görevi = “Bugün ne giyeceğim?”; öne çıkan görünüm, tarama, kombinler; seyahat ikincil |
| `App/KabinsizApp.swift` | 3 tab: Bugün / Dolabım / Benim Modelim; tarama toolbar sheet | 5 kalıcı hedef: Bugün / Tara / Dolabım / Stilist / Ben; `Tara` **gerçek tarama ana sayfası** olacak (yalnızca anlık modal değil); geçiş ADR + testle |
| `Features/Wardrobe/WardrobeView.swift` | Düz satır listesi, küçük simgeler, bilgi ağırlıklı | Fotoğraf destekli grid, kategori/renk/temizlik durumu, yalnızca gerçek içerik, foto yoksa zarif siluet |
| `Features/Profile/MyModelView.swift` | Model editörü uzun `List` içine gömülü | Tam sayfa `Body Studio`; büyük hareketli sahne, alttan açılan bölge kontrolleri; güvenli ölçü verisi |
| `Features/Profile/BodyStudioView.swift` | 3D/2D görüntü + çok sayıda slider ardışık akıyor | Sahnede en az bir ana düzenleme yüzeyi, ölçüler bölge grubunda; değişim doğrudan görünür |
| `Features/Profile/BodyModel3DView.swift` | RealityKit nötr mesh var, fakat gerçek giysi probası değildir | Nötr modeli referans siluet; giydirilmiş gösterim yalnız uygun asset / görsel kademe ile |
| `Features/Scan/ScanView.swift` | `Ürün kodunu yaz`, sentetik örnek kodlar; kamera henüz yok | Gerçek kamera akışı gelince canlı tarama ana ekranı; P0'da dürüst manuel fallback, kamera yoksa sahte kamera katmanı çizme |
| Repo `docs/evidence/screenshots` | Simülatör PNG'leri kayıtlı | Gerçek screenshot görselleri bağımsız tasarım incelemesine tekrar alınmalı |

**Gözlem sınırı:** Repo kaynak dosyaları ve PNG dosya adları incelendi. GitHub araç erişimi ikili PNG görüntülerini açmadığı için yukarıdaki sonuçlar görüntülerin piksel düzeyinde değil, *kaynak kodu ve yerleşim* denetimidir. Claude kendi makinesinde gerçek PNG ve son UI'yi açıp ayrı görsel bulgu raporu hazırlamalı.

## 1 — TASARIM MANİFESTOSU: QUIET ATELIER

Kabinsiz = **bir moda dergisinin editoryal zanaatı + iyi bir terzinin dürüstlüğü + Apple düzeyinde sade ürün mantığı + Wozniak tarzı güvenilir, denetlenebilir mühendislik**.

- **Sıcak ve dokunsal:** taş, keten, gün ışığı, patinasız doğal metaller, gerçek giysi dokusu.
- **Unisex ama kişiliksiz değil:** farklı yaş, boy, beden ve stil ifadelerine açık. Kadın/erkek renk bölümlenmesi yok.
- **Elit ama kibirsiz değil:** sonsuz lüks dekor yok; özenli boşluk, tipografi, ritim ve net görev var.
- **Moda e-ticareti değil:** banner ve indirim etiketinden çok stil danışmanlığı, prova doğruluğu ve kişinin kendi dolabı.
- **Teknoloji görünmez:** 28 uzman zekâyı buton olarak gösterme. Sonuçlar anlaşılır, kaynakları erişilebilir.
- **Ekran = 1 baskın karar:** üstte tek hero, tek ana CTA, tek açıklama; kalan tercihler akış içinde.
- **Gerçeklik her zaman estetikten üstün:** gerçek marka/kumaş/beden verisi yoksa görüntüyle yanıltma. Önizleme ile kesin fiziksel uygunluğu karıştırma.

**Yasak görsel dil:** mor/mavi neon, cam efekti üstüne cam efekti, aşırı gradient, cam fanus butonlar, 15 aynı boy kart, anlamsız yüzde halkaları, gelişi güzel stok fotoğrafı, devasa boş formlar, satış için manipülatif aciliyet, “AI” kelimesinin her yere yazılması.

## 2 — GÖRSEL REFERANS KOLEKSİYONU: ESTETİK REFERANS, ÜRÜN KANITI DEĞİL

Bu referanslar daha önce üretilmiş görsellerdir. **Çalışan uygulama ekranı değildir.** Gerçek marka/ürün verisini, bedeni, kumaşı, yüzdeyi, fiyatı, tanıtım hakkını ve fiziksel prova doğruluğunu kanıtlamaz. Görseldeki “%94”, “%92”, gerçek marka adı/ürün özellikleri vb. **UI örneğidir, kullanıcıya kaynak olmadan yazılamaz**. Tasarımları iPhone ekranına sığacak **gerçek tek-kolon** yerleşimlere dönüştür.

| Açıklama / tasarım hedefi | Görsel referans |
|---|---|
| **01. Marka & atomlar.** Kalite: sıcak dokular, geniş negatif alan, serif editoryal başlık, temiz sans veriler, ince ikonlar. Renk ve tipografik oran referansı. | <img src="references/design_system.png" alt="Kabinsiz tasarım paleti, tipografi ve bileşenleri" width="300" /> |
| **02. Bugün / Ana ekran.** Üstte gündelik moda önerisi; hemen erişilebilir Tara/Gardırop/Stilist/Seyahat; altta gerçek kombin önerisi. **İçeriği aynı ekrana sıkıştırma, aşağı kaydırılabilir yap.** | <img src="references/home_reference.png" alt="Kabinsiz ana sayfa editoryal referans" width="300" /> |
| **03. Mağaza tarama & ürün.** Önce kamera; ürün kimliği, kumaş, gerçek kaynak ve belirsizlik, bölgesel fit, tek güçlü 3D/Ayna CTA. **Fotoğraftaki yüzde ve marka özelliklerini gerçek veri sanma.** | <img src="references/scan_reference.png" alt="Kabinsiz ürün analizi görsel yönü" width="300" /> |
| **04. 3D beden stüdyosu.** Nötr avatar, açık renk studio sahnesi, bölgesel kaydırıcı, ön/yan/arka, basit kontroller. **Tek iPhone'da iki sütunlu çok yoğun yerleşimi kopyalama.** | <img src="references/body_studio_reference.png" alt="3D beden düzenleme referansı" width="300" /> |
| **05. Stilist.** Bir tamamlanmış kombin, kişinin dolabından parçalar, “neden uygun?”, eksik ürünler ve satın almadan alternatif. **Kişisel duygu ya da ten tespiti uydurma.** | <img src="references/stylist_reference.png" alt="Kabinsiz stil danışmanlığı görsel yönü" width="300" /> |

## 3 — KESİN PALET / SEMANTİK TOKENS

### Light — `Atelier Linen`

| Token | HEX | Kullanım |
|---|---|---|
| `canvas` | `#F8F6F1` | Ana fildişi zemin |
| `surface` | `#FFFCF8` | Sayfa/kart |
| `surfaceRaised` | `#F0EAE2` | Yumuşak katman |
| `sand` | `#E8DED1` | Chip/segmented |
| `line` | `#D9D0C4` | İnce hairline |
| `ink` | `#26221E` | Espresso metin |
| `mutedInk` | `#5C544C` | İkinci metin |
| `primaryAction` | `#654632` | Ana CTA, seçili durum |
| `olive` | `#62684B` | Sadece anlamlı sakin vurgu |
| `copper` | `#9C6048` | Küçük kontrollü vurgu |
| `avatarGrey` | `#A8A49F` | Nötr vücut modeli |
| `success` | `#35694B` | Kanıtlı başarı + ikon/metin |
| `warning` | `#825A1C` | Belirsizlik + ikon/metin |
| `error` | `#9E3B3D` | Hata + ikon/metin |

### Dark — `After Hours`

`canvas #151411`, `surface #201D19`, `surfaceRaised #2A251F`, `line #494238`, `ink #F6F0E7`, `mutedInk #C4B9AC`, `primaryAction #C99D7A`, `olive #ADB598`, `copper #D4A18B`.

**Uygulama:** `Theme.swift` → asset tabanlı semantic token map ile göç; bütün SwiftUI ekranları `Color` kodlamadan aynı paleti kullansın. `Reduce Transparency` ve `Increase Contrast` desteği; dark mode'da yüzeyler çamur gibi birleşmeyecek. Renk çiftlerinin kontrastı gerçek cihaz/Accessibility Inspector ile denetlenecek. `@ScaledMetric` ve Dynamic Type zorunlu.

**Ekran kompozisyon oranı:** yaklaşık %70 soluk açık yüzey + %20 tipografi/boşluk kontrolü + %8 gerçek giysi renk ve foto + %2 vurgu; bu matematiksel kota değil yaratıcı yönlendiricidir. Bütün kartların arka planını beje çevirip “premium” deme.

## 4 — TİPOGRAFİ ve GÖRSEL GRAMER

- Başlık: `.system(.largeTitle, design: .serif)` / New York sistem serif; kısa ve nefesli, 29–34 pt.
- Bölüm: `.system(.title2, design: .serif)`; 22–26 pt.
- Ürün adları, ölçüler, CTA: SF sistem sans; 16–17 pt body, 14–15 pt yardımcı; tabular numbers.
- Fiyat, boy, bel gibi sayılar hizalı; `monospacedDigit()` ve kaynağı görünür.
- Birincil CTA en az 50 pt; dokunma alanı en az 44×44 pt; ekran kenar boşluğu 20 pt (dar ekran 16 pt).
- 4/8/12/16/20/24/32/40 pt grid. Kart 18–22 pt yarıçap, hero 24 pt, chip 12–16 pt; aşırı yuvarlak “oyuncak” değil.
- Metin: Türkçe doğal anlatım. Başlıklar moda editörlüğü gibi, açıklamalar dürüst ve kısa. “Sana %99 olur” (kanıtsız) yok.
- Fotoğraf: yalnızca gerçek kullanıcı görseli, izinli katalog fotoğrafı veya açıkça **temsili stil konsepti**. Teslimat asset'lerini otomatik sahte markalara benzetme.
- Simgeler: tek kalınlıklı SF Symbols; tek bir icon weight; anlamlı haptik ve Reduce Motion.
- Sürekli AI ışığı/koşan çember/emoji yağmuru yok. İndirme ve veri beklerken determinate/indeterminate yükleme ayrı.

## 5 — ÜRÜN BİLGİ MİMARİSİ / NAVİGASYON

**Önerilen final yön:** TabView'da `Bugün | Tara | Dolabım | Stilist | Ben`. `Tara` yalnızca modal buton değil; izin gerekmeyen bir **kalıcı destinasyon**: `ScanHome` (son kayıtlar, tara çağrısı, manuel kod yolu). Tarama kamerası burada kullanıcı eylemiyle açılır ve sonuç sonrası geri dönülebilir. Böylece iOS tab bar semantiği korunur. `Seyahat`, Bugün > Seyahat veya Stilist > Seyahat; `Canlı Ayna`, Tara > Ürün > Aynada Dene ve Ben > Modelim üzerinden girilir. **Bu navigasyon değişikliği ADR ve UI testleriyle yapılmalı; salt görsel revizyon diye mevcut kodu kırma.**

### Ana yolculuklar

**Günlük:** Aç → Bugün için öneri (yeterli veri varsa) → Neden? → Dolabımdaki parçaları gör → Kombini kaydet.  
**Mağazada:** Aç → Tara → kamera/barkod/manuel → ürün kimliği + kanıt → beden + kumaş + stil → Aynada Dene (varsa) → Kaydet/karşılaştır.  
**Beden:** Ben → Modelim → Büyük 3D sahne → bölge kaydırıcıları → ölçü girişi → kaydet, geri al, sil.  
**Seyahat:** Bugün → Seyahat → tarih/yolculuk/etkinlik → mevcut dolaptan valiz → planı kaydet.  
**Stilist:** Stilist → “Bugün nereye?” → 1 güçlü kombin + 2 gerçek farklı yaklaşım → neden/alternatif/favori.

**İlk açılışta:** photo/location/camera izni zorunlu değil. “Dolabını ekle”, “Ürün tara”, “Örnek deneyim” (etiketli) seçenekleri. Kullanıcı bilgisi olmadan kişisel eşleşme hayal edilmez.

## 6 — EKRAN ATLASI: SOL NEDEN / SAĞ METİNSEL WIREFRAME

### 6.1 — BUGÜN / HOME (P0)

| Neden & temel içerik | Kullanıcıya görünen ekran düzeni |
|---|---|
| **İlk bakışta stil, sonraki dokunuşta iş.** `Kabinsiz` marka satırı; küçük tarih/şehir hava bandı yalnız izinli ve mevcut veri; büyük tek görünüm hero, “Kombini gör”; hızlı görevler, “Dolabından öneriler” bölümü, sonra seyahat. Hero içinde gerçek kombin yoksa `Stilini birlikte oluşturalım` karşılaması. Tarama herkesin erişebileceği şekilde bir dokunuş. | `┌ Kabinsiz          [Bildirim][Ben] ┐`<br>`│ Şehir · hava  (veri varsa)       │`<br>`│                                  │`<br>`│ BUGÜN SENİN İÇİN                 │`<br>`│ Sade, karakterli, sana göre.     │`<br>`│ [Gerçek kombin / zarif boş state] │`<br>`│ [ Kombini Gör                 → ] │`<br>`│                                  │`<br>`│ [Tara] [3D Model] [Seyahat]      │`<br>`│ Dolabından kombinler          →  │`<br>`│ [Look A]  [Look B]               │`<br>`│                                  │`<br>`└ Bugün  Tara  Dolabım Stilist Ben ┘` |

- İlk viewport 1 ekran içinde: marka + hava + hero + hızlı Tara; arkasından scroll ile look galerisi.
- **Kod hedefi:** `TodayView.swift` bu düzenin semantic UI state'lerini almalı; “kombin yok” blokunu tek ana mesaj yapan home kabul edilmez.
- Veri yokken editorial typography ve izinli soyut keten sahnesi yeterli. Stok insan görüntüsü ile kullanıcının giydiğini iddia etme.
- P0 screenshot states: first-time; user wardrobe (fictional **labelled** fixture), offline; dark.

### 6.2 — TARA / SCAN HOME (P0)

| Neden | Şematik görünüm |
|---|---|
| **Görev ilk saniyede açık.** `Ürünü tanı`, tek kamera aç CTA, elle kod girişi; tekrar taranan ürünler yalnız izinli/yerel. Kamera izni ilk tap'te istenir; izin yoksa manuel moda düşer. Kamera/ürün bulma henüz geliştirilmediyse “canlı tarama” butonunun gerçekte açılmadığı demo yapılmaz. | `┌ Tara                            ┐`<br>`│ Mağazadaki ürünü tanı           │`<br>`│ [Kamerayı Aç              ▣]    │`<br>`│ veya barkodu/ürün kodunu gir    │`<br>`│ [____________________] [Bul]    │`<br>`│ Son görüntülenen ürünler        │`<br>`│ [Ürün] [Ürün] / geçmiş boş      │`<br>`└ ...                            ┘` |

### 6.3 — KAMERA / LIVE PRODUCT SCAN (P0→P1)

| Neden | Şematik görünüm |
|---|---|
| Arayüz en büyük alanda kamera akışıdır; alt kısımda çekim/tanımlama, ışık, galeri, manuel kod. Tarama sırasında ürün yok/ambiguous/permission denied/thermal fallback durumları aynı tasarım sisteminde. Ürün kıyafetse foto tanıma **model adını otomatik kesinleştirmez**; doğrulama ister. | `┌ Ürünü Tara                      ┐`<br>`│ [ GERÇEK CANLI KAMERA 9:16 ]    │`<br>`│                                 │`<br>`│     [ ürün için kadraj ]        │`<br>`│                                 │`<br>`│ [Galeri]    ○    [Işık]         │`<br>`│ Barkod · Etiket · Ürün görseli  │`<br>`│ [Elle Gir] [Yardım]             │`<br>`└ ...                            ┘` |

### 6.4 — ÜRÜN KARAR EKRANI / PRODUCT TRUTH (P0→P1)

| Neden | Şematik görünüm |
|---|---|
| **İlk kart: ne bulduk?** Gerçek ürün foto, marka, varyant ve kaynak; **ikinci kart: sana oluyor mu?** Bölge bazlı sınırlar; **üçüncü: kumaş ve kullanım**; **dördüncü: dolabınla kombin**. En baskın CTA `Aynada Dene`, ancak ayna gerçekten varsa. Ürün verisi yoksa uydurma fiyat/marka/uyum yüzde yok. | `┌ Bu ürün sana nasıl olur?       ┐`<br>`│ [ÜRÜN FOTO] Marka, model, varyant│`<br>`│ Kaynak: [Doğrulandı/Bilinmiyor]│`<br>`│ Beden: [Öneri / Yetersiz veri] │`<br>`│ Omuz · Göğüs · Bel · Kalça       │`<br>`│ Kumaş / Kalıp / Bakım / Isı    │`<br>`│ Dolabından [eşleşen parça]     │`<br>`│ [ Aynada Dene ] [Kombin Gör]   │`<br>`└ ...                            ┘` |

### 6.5 — LIVE MIRROR (P1)

| Neden | Şematik görünüm |
|---|---|
| Sahnenin %75–85'i canlı video; altta ürün carousel + beden seçici; üstte `Yerel Ayna` ve ayrı rızalı `AI Ayna` modları. Çekim-kayıt kapalı varsayılan. Fotoğraf/logo deformasyonunu ölçülebilir şekilde denetle. AI gerçek ölçü kanıtı değildir. Veriler kamera izni sınırında. | `┌ Canlı Ayna                     ┐`<br>`│ Yerel Ayna  |  [AI Ayna*]        │`<br>`│ [ CANLI KAMERA / KİŞİ ]         │`<br>`│ [ GIYSİ TAKİP ÖNİZLEMESİ ]     │`<br>`│ [Şimdi giydir: ürün kartı]      │`<br>`│ [Beden ▾]  [Kıyafeti değiştir] │`<br>`│ [Bitir] [3D/Ürün bilgisi]      │`<br>`└ *bulut izinli, açık maliyet    ┘` |

### 6.6 — 3D MODEL / BODY STUDIO (P0)

| Neden | Şematik görünüm |
|---|---|
| Model büyük, nötr, gerçek zamanlı. Kayıtlı ölçü girilebilir, fakat yalnız ölçümle desteklenen kaynaklar beden önerisine gider. Bölge sliderları fotoğraf tahmini ile karışmaz. Sahne ve kontrol aynı anda kalabalık olmasın: altta `Omuz / Göğüs / Bel / Kalça / Boy` alt bölge seçicisi, seçilince alttan panel açılır. | `┌ Modelim                         ┐`<br>`│ [  BÜYÜK NÖTR 3D AVATAR   ]     │`<br>`│ [Ön]   [Yan]   [Arka]           │`<br>`│ ──────────────────────────     │`<br>`│ [Omuz][Göğüs][Bel][Kalça][...]  │`<br>`│ Bel               78 cm [⇆]   │`<br>`│ [−] ───●────────────── [+]    │`<br>`│ [Ölçü Gir]    [Geri Al]        │`<br>`│ [ Kaydet ]                     │`<br>`└ ...                            ┘` |

### 6.7 — STİLİST / TODAY LOOK (P1)

| Neden | Şematik görünüm |
|---|---|
| **Moda editörü hissi:** tek kapak görseli; kişisel sebep chips; gerçek dolaptan parçalar ve isteğe bağlı alışveriş. Kullanıcının ruhunu okuma iddiası yok; tercihlerini öğrenir. Cesur/sade/rahat seçenekleri gerçek kombin farkına dayansın. | `┌ Stilist                         ┐`<br>`│ Bugün nereye gidiyorsun?        │`<br>`│ [İş] [Buluşma] [Gezi] [Diğer]  │`<br>`│ [ANA KOMBİN / outfit cards]    │`<br>`│ Neden sana? renk · rahatlık     │`<br>`│ [Sade] [Karakterli] [Cesur]   │`<br>`│ Dolabından [1][2][3]           │`<br>`│ Eksikse [öneri] [alternatif]   │`<br>`│ [Kombini Kaydet]              │`<br>`└ ...                           ┘` |

### 6.8 — DOLABIM / WARDROBE (P0)

| Neden | Şematik görünüm |
|---|---|
| Gerçek kullanıcı eşyalarından yaratılan görsel duvar; sekmeler kategori/kullanım/temizlik; üstte `Kıyafet ekle`. Fotoğrafsız öğede kategori silueti; çok sütunda metin taşması yok. | `┌ Dolabım          [+ Kıyafet]   ┐`<br>`│ 24 parça · Temiz: 17           │`<br>`│ [Tümü] [Üst] [Alt] [Dış] ...   │`<br>`│ [Ürün 3:4]  [Ürün 3:4]         │`<br>`│ [Kazak]       [Pantolon]       │`<br>`│ [Temiz]       [Giyildi]        │`<br>`│ [Dolabımdan kombin oluştur →] │`<br>`└ ...                           ┘` |

### 6.9 — SEYAHAT / TRAVEL (P1)

| Neden | Şematik görünüm |
|---|---|
| Seyahat kartı 1. ekrana hakim değil; ayrı planlama akışı: nereye, hangi tarihlerde, ne etkinlik? Sonuç gün gün kombin ve minimalist valiz listesi. Hava tahmini yoksa `Hava bilgisi yok`, hayalî derece yok. | `┌ Seyahat Stüdyosu                ┐`<br>`│ [Yer] [Tarih] [Gün / plan]      │`<br>`│ 5 Günlük Gardırop              │`<br>`│ [1.gün Look] [2.gün Look]      │`<br>`│ [Valiz: 7/12 hazır]            │`<br>`│ [Eksik parçalar]                │`<br>`│ [Seyahati kaydet]              │`<br>`└ ...                           ┘` |

### 6.10 — BEN / PRIVACY / SETTINGS (P0)

| Neden | Şematik görünüm |
|---|---|
| Profil güzel ama gösterişsiz; `Modelim`, `Stil Tercihlerim`, `Fit Passport`, `İzinler & Veriler`, `Seyahatler`, `Hakkında`. Fotoğraf olmayan anonim kişi için dahi ilk ekran dolu. | `┌ Ben                             ┐`<br>`│ Modelim / Stil profilim          │`<br>`│ [3D Model] [Tercihler]           │`<br>`│ Fit Passport                     │`<br>`│ Özel veri & İzinler              │`<br>`│ Verilerimi dışa aktar / Sil      │`<br>`└ ...                            ┘` |

### 6.11 — İLK KULLANIM / ONBOARDING (P0)

Birinci ekran ürün sözü: “Bir kıyafet, onlarca olasılık.” İkinci ekran tercih seçimi (stil/kullanım/konfor), üçüncü adım isteğe bağlı dolap/model. Kamera izni yalnız taramada; Fotoğraflar izni yalnız fotoğraf seçmede. Zorunlu yaş/cinsiyet/astroloji sorusu yok. `Örnekle Keşfet` ise sentetik veriye görünür işaret.

### 6.12 — DİĞER EKRANLAR (P1/P2)

- Ürün karşılaştırma: iki markada aynı kalıp değil, aynı kullanıcı bağlamında kıyas; fark tablosu, belirsizlik.
- Fit Passport: markaya göre gerçek deneme geçmişi, değişiklik, unutma.
- Kumaş detayı: lif %, katman, bakım, hava giyilebilirlik, kaynak; “30°C yıkama” hava giyme sıcaklığı değildir.
- Kıyafet ekleme: galeri/manuel/barkod, haklar, fotoğraf yerel işlem.
- Kombin tamamlama / Commerce: önce `Dolabımda var`, sonra organik marka önerisi, ayrı sponsorlu.
- Stil DNA: “Bunu seviyorum / bugün istemiyorum / bunu bir daha önerme” kontrolleri.
- Offline / Hata / Bulunamadı: premium boş alan, anlaşılır tek çözüm eylemi.

## 7 — BİLEŞEN SÖZLEŞMESİ (TEK KAYNAK)

`AtelierTokens`, `AtelierType`, `AtelierCard`, `TodayHero`, `ActionDock`, `OutfitLookCard`, `ProductFactCell`, `EvidenceChip`, `FitRegionRow`, `FabricSwatch`, `CategoryFilter`, `WardrobeTile`, `BodyStudioStage`, `MirrorModeSwitch`, `PartnerBadge`, `EmptyAtelier`, `AtelierButton`.

Her bileşenin `normal/loading/empty/unknown/error/offline/permissionDenied/synthetic` davranışı, semantik `accessibilityLabel`, 44x44 pt hit region, high contrast ve Reduce Motion hali olacak. **Yeni renk/border/font sabitleri yalnız design token dosyasında.** Komponent katalogu gerçek SwiftUI preview ve screenshot olarak yayımlansın.

**Tab bar:** En çok 5 sekme; SF Symbols 19–22 pt; `Tara` kalıcı destinasyon olmalı, dışarıdan beklenmedik izin istememeli. Büyük metinde etiketler kırpılırsa iOS yerel tasarıma uygun alternatif denenir, küçük fontla saklanmaz.

## 8 — GERÇEK VERİ ETİĞİ, ÖRNEK GÖRSEL UYUMU

1. Referans görüntüdeki kamera, marka, kıyafet, bedensel yüzde, fiyat **kanıt değildir**. Demo için `SYNTHETIC_DEMO_ONLY` etiketi; gerçek marka isimleriyle sentetik beden/ürün yüzdesi asla yapılmaz.
2. Öneri üretilemiyorsa ekran güzel olduğu için `Sana özel` iddiası uydurulamaz; hoş geldin + kullanıcının seçtiği ilk görevi sunulur.
3. Fotoğraf erişimi sistem photo picker üzerinden en az veriyle istenir. AI Live Mirror bulut modu ayrı izne tabidir, video yerelden çıkmadan bildirilir.
4. Ürün kimliği, kumaş ve beden kanıtı ayrı tutulur; kaynak satırı/kademe ilk ekran veya 1 dokunuşta.
5. Aynada 3D kıyafet varsa `görsel tahmin`, ölçüler varsa `beden karşılaştırması`; bunlar birbirinin garantisi değildir.
6. Her kart kendi kullanım değeri doğrulanmış veriye dayanır; sponsorlu içerik gizli organik öneri gibi gösterilemez.

## 9 — TESLİMAT SIRASI: GÖRSEL ÖNCE, GERÇEK İŞLEVLE BİRLİKTE

| WP | Sıra / teknik bağımlılık | Teslimat |
|---|---|---|
| `UI22-00` | Reponun son SHA ve ekran ekran baseline; screenshot karşılaştırma | `docs/design/audit/current-vs-target.md` + screenshots (SIMULATOR_ONLY) |
| `UI22-01` | Eski `Token.brandInk` vb. semantik renklere taşı; tüm ekranlarda tek kaynak | Token unit+snapshot farkı, light/dark |
| `UI22-02` | Typography scale + compact component gallery + SwiftUI previews | `AtelierComponentGallery` ve screenshots |
| `UI22-03` | Yeni tab IA ADR, routing state/persistence; kamera izni kullanıcı eyleminden sonra | Navigation UI tests |
| `UI22-04` | **Bugün** ana ekran: önce boş state + gerçek/etiketli fixture | iPhone küçük/orta/büyük screenshots |
| `UI22-05` | **Tara home + Ürün kararı** ekranı; mevcut manuel resolver, truth labels | Permission/offline/error screenshots |
| `UI22-06` | **Modelim 3D stüdyo** tam ekran kabuk; mevcut mesh ve slider mantığını koru | Rotation+sliders test/screenshots |
| `UI22-07` | **Dolabım** görsel grid; resimsiz öğe ve kategori ikonları | Empty/populated/grid a11y |
| `UI22-08` | **Stilist** boş/data/truth UI, gerçek outfit yoksa P1 placeholder | Look vs owned vs shopping distinctions |
| `UI22-09` | Seyahat, Ben, Settings, Fit Passport ve küçük ekran polish | Tests + screenshot matrix |
| `UI22-10` | Canlı Ayna tasarım kabuğu; fake kamera yok, özelliğe bağımlı | Device-only `DEVICE_VERIFIED` kalite kapısı |
| `UI22-11` | Bağımsız visual/UX, a11y, copy, performance gate | `docs/design/final-review.md` pass/fail |

**Öncelik kuralı:** Önce `Theme.swift`/component kit + Today + tarama. Body Studio yalnız görsel değişiklik için ölçüm/kripto kodunu yeniden yazmayacak. CI yoksa bile local simulator test kanıtı zorunlu. `main`e direkt sürpriz merge yok; branch + PR / diff raporu. Ücretli lisans, App Store, canlı veri anlaşması için kullanıcı onayı.

## 10 — ZORUNLU TASARIM KALİTE KAPILARI

- [ ] UI22-T01 — Son GitHub SHA ve hangi gerçek screenshot'ın incelendiği raporda.
- [ ] UI22-T02 — `Theme.swift` eski `#283D46` ve eski gri kart paleti tasarım token sisteminden kaldırıldı.
- [ ] UI22-T03 — Her ekranda 1 baskın CTA, 1 yardımcı CTA; kullanıcı görevi 3 saniyede anlaşılabilir.
- [ ] UI22-T04 — Küçük iPhone'da 5 tab etiketleri kırpılmıyor; kırpılıyorsa native alternatif ADR ile.
- [ ] UI22-T05 — iPhone küçük/orta/büyük, Light/Dark, normal/XXL Dynamic Type görüntüleri.
- [ ] UI22-T06 — VoiceOver sırası, erişilebilir etiketler, 44pt dokunma alanları.
- [ ] UI22-T07 — Yüksek kontrast ve Reduce Motion; token erişilebilirlik gözden geçirmesi.
- [ ] UI22-T08 — İlk kurulumda zorunlu galeri, konum, kamera veya doğum tarihi yok.
- [ ] UI22-T09 — Gerçek dolap boşken hayalî kişisel kombin gösterilmiyor.
- [ ] UI22-T10 — Sentetik look/ürün açıkça etiketleniyor; örnek veri gerçek marka kimliği taşımıyor.
- [ ] UI22-T11 — Ürün tanınmıyorsa “bulunamadı”, isimsiz marka ve kumaş tahmini yok.
- [ ] UI22-T12 — Kamera açılmadıysa çizilmiş foto üzerine fake scan overlay yok.
- [ ] UI22-T13 — Avatar nötr fiziksel sahne; gerçek kıyafet simülasyonu iddiası yok.
- [ ] UI22-T14 — 3D slider seçildiğinde sahnedeki ilgili bölge güncelleniyor, geri alma ve kalıcılık korunuyor.
- [ ] UI22-T15 — Beden tahmini yüzde/“mükemmel” göstermiyor; kaynak, eksik veri ve belirsizlik var.
- [ ] UI22-T16 — Ürün kimliği, lif %, 30°C yıkama, giyilme sıcaklığı ayrı veri sınıfları.
- [ ] UI22-T17 — Fiyat, stok, gerçek mağaza ve sponsor bilgisi kanıtlı kaynak olmadan gösterilmiyor.
- [ ] UI22-T18 — Owned-first öneri, kullanıcının kendi dolabı öncelikli; harici ürünler ayrı sekmede.
- [ ] UI22-T19 — Gerçek renk ve logo referans asset'i yoksa uydurulmuyor.
- [ ] UI22-T20 — Stilist 3 alternatifinde siluet/katman/aksesuar gerçek farklılık gösteriyor.
- [ ] UI22-T21 — Seyahat ekranı hava bilinmiyorsa derece/saat uydurmuyor.
- [ ] UI22-T22 — AI Ayna için açık kullanıcı izni, bulut veri gönderimi ve maliyet bildirimi.
- [ ] UI22-T23 — Yerel cihaz kalite/degrade durumu sakin ve eylemli arayüz gösteriyor.
- [ ] UI22-T24 — Her ekran `loading/empty/offline/error/denied/unknown/data` durumlarından en az ilgili olanları gerçek implementasyonda ele alıyor.
- [ ] UI22-T25 — Gerçek simülatör screenshot'ları referansla yan yana sunuluyor: kırpma/boşluk/type/palet farkları.
- [ ] UI22-T26 — Materyal ve moda fotoğrafları hakları doğrulanmış, geçici mock asset ayrı.
- [ ] UI22-T27 — Her ekranda tab/safe area/keyboard/focus görünürlüğü testi.
- [ ] UI22-T28 — Simülatör görsel PASS cihaz performansından ve gerçek kamera testinden ayrıldı.
- [ ] UI22-T29 — Mevcut `Octopus`, `Vault`, `Citadel`, `BodyGeometry`, `ShoppingCopilot` testleri gerilemedi.
- [ ] UI22-T30 — Bağımsız UX denetçisi, geliştirici ve kalite gözden geçireni ayrı PASS/FAIL kararı veriyor.

## 11 — GÖRSEL RED-TEAM / SÖZLEŞME: BİTTİ DEMEK İÇİN

Tasarım sahibi ekranı seçip denetim panosuna şu matrisi yazmalı: `screen | user intent | source file | fixture kind | primary CTA | screenshot | device | dynamic text | contrast | failure states | issues P0/P1 | result`. Bir ekranın yüksek çözünürlüklü screenshot'ı gerçek çalışma veya ürün doğruluğu kanıtı değildir.

**Her başarısızlık için:** görsel fark → erişilebilirlik/iş akışı sorunu → kök neden (token/layout/data/state) → minimal düzeltme → test → yeni screenshot → bağımsız review.

### Kırmızı çizgi örnekleri

- Hero aynı katalog görselini 3 defa basıyorsa RED.
- Ürün bulunmazken ona marka/ölçü atfediliyorsa RED.
- 3D mesh yokken AI fotogerçekçi prova yazıyorsa RED.
- Bel/omuz slider'ı yalnız metni değiştiriyor, mesh/silueti değiştirmiyorsa RED.
- Stilist “sana uygun” diyerek her kullanıcıya aynı kombin öneriyorsa RED.
- Başlık bol serif ama fiyat/ölçü okunmuyorsa RED.
- Koyu modda kahverengiler birbirine giriyorsa RED.
- Kullanıcı ilk ekranda “ürün nasıl taranır” bulamıyorsa RED.

## 12 — CLAUDE'A TEK PARÇA DOĞRUDAN EMİR

> **KABİNSİZ QUIET ATELIER v2.2 — UI RECOVERY / GERÇEK ÜRÜN EKRANLARI**
>
> `gundogandogancan/kabinsiz` reposunu son commit ile aç; `CLAUDE.md`, v2.1 ana teknik anayasa ve bu v2.2 dosyasını oku. **Mevcut ekranların görseli kullanıcının kabul ettiği seviyede değildir.** Önce gerçek simülatör screenshot'larını açarak mevcut-vs-hedef görüntü denetimi yap. `Theme.swift`'in hâlâ soğuk mavi-gri olduğunu, `TodayView`'un gerçek moda home ekranı yerine boş durum/seyahat ağırlıklı olduğunu ve `MyModelView`/`WardrobeView`'un form/liste ağırlıklı olduğunu doğrula. Kullanıcının verdiği referans dosyalarını `references/` içinden aç; bunların yalnız estetik yön olduğunu, gerçek veriye dair iddia olmadığını unutma. Eski UI'yi şişirmek yerine **Quiet Atelier/Atelier Linen** paleti ve system serif başlık + system sans UI metinleriyle tek kaynaklı tasarım sistemi kur. `Bugün`, `Tara`, `Dolabım`, `Stilist`, `Ben` kalıcı destinasyonlarının IA değişikliği için ADR yaz; `Seyahat` ve `Canlı Ayna` bağlamsal akışlar olsun. Yeni shell'i gerçek iPhone boyutlarına uyarlarken önce (1) Today/Empty (2) Scan/Decision (3) Body Studio (4) Wardrobe (5) Stylist ekranlarını çalışan SwiftUI koduna dönüştür. Demo veri görünür etikete sahip olsun; gerçek marka, kumaş, 3D ve beden güvenini uydurma. Var olan vault, egress, karar sözleşmeleri, beden slider revizyon mantığı ve testler bozulmasın. **Her iş paketinde screenshot + test + a11y + visual diff + açık eksik raporu üret.** Kayıtlı önceki test kanıtlarına güvenip PASS verme; değişiklikten sonra tekrar çalıştır. `main`i onaysız merge etme; ilk gerçek teslim `UI22-00..04` kanıtları ve kullanıcının değerlendireceği ana ekran screenshot'ı olsun. Gerekli dış yetki bloklarını göster; engellenmeyen tasarım ve prototip işleriyle devam et.

---

## 13 — CLAUDE'A 12 KESİN DENETİM SORUSU

1. `main` son SHA, son `TESTED`/`DEVICE_VERIFIED` durumu ve gerçek screenshot adları nedir?
2. Mevcut dört ana view'ın (`Today`, `Scan`, `Wardrobe`, `MyModel`) kullanıcı işi nedir ve neden referansla uyuşmuyor?
3. Eski tasarım tokenları hangi dosyalarda kalmış? Merkezi migration nasıl yapılacak?
4. Ürün scan kamerası bu sürümde gerçekten çalışıyor mu, yoksa yalnız manuel giriş mi var?
5. 3D neutral mesh ile giysi render'ı ayrı mı? UI'daki başlıklar bu farkı anlatıyor mu?
6. Kullanıcının kimlik/stil/profil bilgisi olmadığı ilk kurulum hali premium ama dürüst mü?
7. 5 tab IA VoiceOver, küçük cihaz ve state restoration testini geçiyor mu?
8. “Başlıca görünüm” alanında foto lisansı ve önerinin veri kaynağı nereden geliyor?
9. Kombin seçenekleri üç gerçekten farklı öneri mi, yoksa aynı parçanın yeniden etiketlenmesi mi?
10. Her ekranın light/dark, XXL Dynamic Type ve offline sürümü için gerçek screenshot var mı?
11. Eski `BodyGeometry`, `Vault`, `Citadel`, `Octopus` testleri yeniden çalıştırıldığında yeşil mi?
12. Tasarımcıdan bağımsız inceleyici ekrandaki 3 ana kullanım görevini ilk 3 saniyede bulabildi mi? Ölçüm/kanıt nedir?

**Kabul mercii:** Kullanıcı estetik yönü ekran görüntülerini gördükten sonra kabul eder; Claude kendi kendine “GOD LEVEL done” ilan edemez. Nihai kalite gerçek kullanıcı + gerçek cihaz + gerçek ürün verisi gerektirir.

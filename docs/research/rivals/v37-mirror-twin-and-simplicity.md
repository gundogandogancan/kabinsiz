# V37 rakip keşfi: canlı ayna, kendi ikizim ve sadelik (Alta, Doji, Anywear, Giyio) — 2026-11-05

- **Yöntem:** `.claude/skills/kabinsiz-rival-recon`. Bu belge `recon.md`, `feedback.md`, `features.csv` ve `parity.md`'yi **tekrarlamaz, genişletir**. Yorum temaları (420 yorum) için `feedback.md` esastır; burada yalnız yeni kaynaklardan gelenler var.
- **Kaynak sınırı (v3.6):** yalnız herkese açık sayfalar: App Store listeleri ve listedeki ekran görüntüleri, iTunes Search/Lookup API (herkese açık), resmi siteler, gizlilik politikası ve kullanım şartları, basın, geliştirici belgeleri. Giriş yok, hesap yok, uygulama indirilmedi, decompile yok, trafik kaydı yok, özel API yok. Metin ve görsel kopyalanmadı; alıntılar 15 kelimenin altında.
- **Kanıt sınıfları:** **V** resmi sayfada doğrulandı · **C** pazarlama/basın iddiası ya da ekran görüntüsünden çıkarım · **U** bilinmiyor (`UNKNOWN`).
- **Temiz oda kuralı:** rakibin ne yaptığını ve kullanıcının ne gördüğünü yazıyoruz; Kabinsiz tarafı kendi tasarımımız (Atelier), cihazda, kendi kodumuz.

## 0. Tek paragraf özet

Giyio ile Anywear **aynı motoru kullanıyor**: Decart'ın gerçek zamanlı video deneme modeli (Giyio için gizlilik politikası ve izin ekranı V; Anywear için resmi sayfa V). Giyio'nun farkı teknik değil, **kabuktur**: Türkçe, tek ekran, iki ekleme düğmesi (Galeri, Link), mağaza uygulamasından paylaşım, tek birincil "Dene" düğmesi, hesap yok, 15 saniyelik deneme, ücretli kredi. Doji ve Alta ise bulutta üretilmiş fotogerçekçi avatar yolunu seçiyor (Doji: 6 selfie + 2 tam boy fotoğraf, ~30 dk). Kabinsiz'in yolu farklı: canlı ayna cihazda (F1, Vision 14 eklem + kendi giysi çizimlerimiz), ikiz ise yazılan ölçülerden ve isteğe bağlı tek fotoğraftan cihazda kurulur; yüz ve kamera karesi hiçbir zaman buluta gitmez. Giyio'dan alınacak asıl şey **sadelik disiplini**; teknolojisi (bulut VTON) alınmaz.

## 1. Giyio (yeni rakip, ana odak)

### 1.1 Kimlik (V)

| Alan | Değer | Kaynak |
|---|---|---|
| Ad | Giyio: Canlı Kıyafet Dene | S01, S02 |
| Geliştirici | Eren Görkem Şahin (bireysel geliştirici hesabı) | S01, S02 |
| App Store kimliği | 6817144573, yalnız TR mağazası (US aramasında çıkmıyor) | S01, S03 |
| İlk sürüm | 1.0, 2026-10-13 | S01 |
| Boyut, sistem | ~33,6 MB, iOS 17+, yalnız iPhone (Mac M1 ve visionOS uyumlu görünüyor) | S01, S02 |
| Dil | Yalnız Türkçe (web sitesinde İngilizce sürüm var) | S01, S04 |
| Yaş | Listede 18+ (API'de 17+); şartlarda 18 yaş sınırı | S02, S06 |
| Puan | Yeterli puan yok → kullanıcı yorumu **UNKNOWN** | S02 |
| Kurucu LinkedIn / basın | Bulunamadı → **UNKNOWN** | S07, S08 |

### 1.2 Teknoloji, bulut ve cihaz (V)

- **Deneme motoru:** Decart. Gizlilik politikası ve kullanım şartları Decart'ı adıyla anıyor; izin ekranı görüntüsü de aynı adı gösteriyor (S05, S06, S02 ekran 5).
- **Bulut:** Deneme sırasında canlı kamera kareleri ve giysi görseli Decart'a gider. Giyio kareleri saklamadığını söylüyor. Decart'ın bu girdileri kendi modellerini geliştirmek için kullanabileceği hem SSS'de hem politikada yazıyor. Decart'ın saklama süresi belirtilmemiş (**UNKNOWN**).
- **Diğer işleyenler:** Firebase (kimlik, veritabanı; AB bölgesi), RevenueCat ve Apple (satın alma), PostHog (anonim kullanım analitiği; AB), Apple DeviceCheck (ücretsiz hakkın cihaz başına bir kez verilmesi; politika bu belirtecin silme ve yeniden kurulumdan sonra da kaldığını söylüyor) (S05).
- **Güvenlik:** Sağlayıcının kalıcı anahtarı uygulamada değil; her deneme için kısa ömürlü erişim belirteci üretiliyor (S05). Decart belgelerine göre istemci belirteçleri varsayılan 60 sn'de sona eriyor (S12).
- **Cihazda kalanlar:** giysi kaydı (bağlantı, ad, marka, fiyat, görsel), isteğe bağlı cinsiyet, yaş aralığı ve beden, kaydedilen klipler (yalnız galeride) (S05).
- **Kimlik:** ilk açılışta rastgele anonim kullanıcı kimliği; ad, e-posta, telefon yok (S04, S05).
- **İzin:** canlı denemeden önce açık rıza ekranı; Ayarlar'dan geri alınabiliyor. KVKK md. 9 (yurt dışına aktarım) anılıyor (S05).
- Giysinin ürün görselinden nasıl ayrıldığı, gecikme, desteklenen giysi türleri (üst/alt/elbise/ayakkabı), aynı anda kaç parça denendiği: **UNKNOWN** (S04 bunları söylemiyor).

### 1.3 Ekran ve akış envanteri (listedeki 5 ekran görüntüsü + site)

Ekran görüntülerinin dosya adları da akışı anlatıyor: önce, sonra, mağazadan ekle, kaydet-paylaş, hesap yok (S01).

| Kimlik | Ekran | Görünen öğeler (C: ekran görüntüsünden) | Birincil eylem |
|---|---|---|---|
| GY-01 | İzin ekranı | Kamera simgesi, başlık, 3 kısa madde (karenin Decart'a gittiği, saklanmadığı ve ad/e-posta istenmediği, iznin Ayarlar'dan geri alınabildiği), altta iki düğme | "İzin ver" (siyah), ikincil "Şimdi değil" |
| GY-02 | Ana ekran | Üst çubuk: logo, kalan hak sayacı, ayarlar dişlisi. "Kıyafet ekle" kartı: tek cümlelik açıklama + Trendyol'dan paylaşma ipucu + iki düğme (Galeri, Link). "Dolabım" ızgarası; her parçada kaynak etiketi (ör. galeriden). Altta tam genişlikte tek siyah "Dene" düğmesi | "Dene" |
| GY-03 | Canlı deneme | Ön kamera tam ekran, sol üstte denenen giysinin küçük resmi, sağ üstte kapat. Süre 15 sn (V, site ve listede) | — |
| GY-04 | Sonuç sayfası | Alttan açılan sayfa, başlık bir soru ("Nasıl durdu?"); üç düğme: Paylaş (siyah), Galeriye kaydet, Başka kıyafet dene | "Paylaş" |
| GY-05 | Ayarlar | "Verilerimi sil" tek dokunuşla cihaz ve sunucu verisini siler (V, site ve politika) | — |

Boş, yükleniyor ve hata durumları: bağlantı kurulamazsa hak otomatik iade edilir (V, şartlar S06). Okunamayan bağlantıda galeriden fotoğraf öneriliyor (V, SSS). Diğer boş/hata ekranları **UNKNOWN**.

### 1.4 Dokunuş sayısı (mutlu yol; C = herkese açık görsel ve metinden çıkarım)

| Görev | Giyio | Sınıf |
|---|---|---|
| Mağaza uygulamasından ekleme | Ürün sayfasında Paylaş → Giyio = 2 dokunuş; site "tek dokunuşla dolabında" diyor | V (site) + C |
| Galeriden ekleme | Galeri → fotoğraf seç (+ olası onay) = 2–3 | C; onay adımı **UNKNOWN** |
| İlk deneme (parça eklendikten sonra) | (parça seç) → Dene → İzin ver → iOS kamera izni = 3–4 | C; seçimin otomatik olup olmadığı **UNKNOWN** |
| Sonraki denemeler | (parça seç) → Dene = 1–2 | C |
| Deneme sonrası paylaşma | Paylaş + iOS paylaşım sayfası = 1 + sistem | C |
| Hesap | 0 (kayıt formu yok) | V |
| Tüm veriyi silme | Ayarlar → Verilerimi sil (+ olası onay) = 2–3 | C; onay **UNKNOWN** |
| İlk açılışta tanıtım/karşılama ekranları | **UNKNOWN** | U |

### 1.5 Türkçe dil tonu (V, site ve görseller)

- "Sen" diye hitap; kısa, emir kipinde, fayda odaklı başlıklar. Örnek: "Kıyafeti almadan üstünde gör." (S04).
- Sürtünmeyi kaldıran iki-üç kelimelik ifadeler: "Hesap açmadan, beklemeden." (S04).
- Mahremiyet bir pazarlama başlığı olarak öne çıkıyor (ekran 5 başlığı hesapsızlık ve görüntünün saklanmaması).
- Dürüst sınır cümlesi listede ve SSS'de: renk ve kesim gerçek üründen farklı olabilir; fotoğraf düzeyinde gerçekçilik garanti değil (S02, S04).
- Üç adımlı anlatı: Ekle → Dene → Paylaş (S04).

### 1.6 Para modeli (V)

- İlk 1.000 kullanıcıya 2 ücretsiz deneme; sonra 5 / 15 / 40 denemelik paketler: ₺249,99 / ₺599,99 / ₺1.499,99. Krediler süresiz. Her deneme başlatma 1 hak (S02, S04, S06).
- Deneme başına yaklaşık ₺37–50 (paket fiyatı / deneme sayısı; hesap bizim).

### 1.7 Zayıf yanlar (herkese açık bilgiden; yorum yok)

- Kamera kareleri yurt dışındaki bir sağlayıcıya gidiyor ve sağlayıcı model geliştirmede kullanabiliyor (V). "Görüntün bizde kalmaz" iddiası Giyio için doğru, sağlayıcı için değil.
- Her deneme 15 sn ve ücretli; dolap zekâsı yok (günlük kombin, hava, takvim, valiz belirtilmemiş).
- Beden ve uyum garantisi yok (V, şartlar); gerçekçilik kumaş ve ışığa bağlı (V, SSS).
- DeviceCheck belirteci silme sonrasında da kalıyor (V); kullanılmayan haklar veri silinince geri gelmiyor (V).
- 18 yaş sınırı; yalnız Türkçe; Android yok (V).
- Kullanıcı yorumu yok → gerçek şikâyetler **UNKNOWN**.

### 1.8 Giyio'dan alınacak en iyi 5 fikir

1. Ana ekranda **tek birincil düğme** ("Dene"), ekleme için yalnız **iki** yol düğmesi.
2. **Mağaza uygulamasından paylaşım** ile ekleme; okunamazsa galeriden fotoğrafa düşme.
3. Kamera öncesi **sade izin ekranı**: 3 madde, işleyeni adıyla söyler, "Şimdi değil" eşit derecede görünür.
4. Deneme sonrası **tek soruluk sonuç sayfası**: paylaş / kaydet / başka parça.
5. **Hesapsız başlangıç + tek dokunuşla "verilerimi sil"** + dürüst sınır cümlesi.

## 2. Alta (recon.md'ye ek)

Yeni doğrulananlar (S09, S10, S11):

- **Karşılama 6 bölüm:** ~2 dk stil anketi → dolaba parça yükleme → otomatik etiket (kategori, renk, mevsim, kıyafet kuralı; isteğe bağlı "Prettify") → avatar → profil kişiselleştirme (meslek/hobiler, sevdikleri, marka ve bütçe, gizlilik) → arkadaş ekleme (V, S09).
- **Erken ödül:** ilk kombinler için **5 parça yeterli**; rehber en az 70 parça öneriyor (V, S09).
- **Ekleme yolları:** fotoğraf, tarayıcı, selfie/kombin fotoğrafı, veritabanı, fiş, "dolap danışmanı" hizmeti (V, S09). Etiketleme için SAM kullanımı recon.md'de (Meta AI blogu).
- **Avatar girdisi:** yüz fotoğrafı + beden fotoğrafı (rehber) ya da net bir vesikalık + boy, ölçüler, ten ve saç rengi; tam boy selfie isteğe bağlı (blog, 2025-08-20). Ayrıca poz ve **gömlek içe sokma tercihi** seçilebiliyor (V, S09, S10).
- **Deneme:** her kombinin yanındaki avatar düğmesine dokununca benzer görünüşte bir figür o kombinle üretiliyor (V, S10). Topluluk akışındaki her kombin kendi avatarınla denenebiliyor (C, Alta blogu, aramada).
- **Günlük kombin:** yerel hava + stil tercihi + dolap (V, S11); takvim kullanımı kurucu röportajında (C, WWD, aramada).
- **Teknoloji ve bulut:** avatar üretim modeli ve işlem yeri belirtilmemiş → **UNKNOWN**. Günlük 10.000+ avatar üretimi iddiası (C, S10).
- **Zayıf yanlar:** `feedback.md` (günlük avatar sınırı 25→10, "prettify" giysiyi değiştiriyor, oturum kapanınca dolap kaybı).

**Alınacaklar:** 5 parçada ilk kombin (erken ödül); her kombin kartında tek dokunuşla "modelimde gör"; içe sokma tercihi; ten ve saç için fotoğrafsız metin/seçenek girişi; beğenmediğim kombinlerden öğrenme.

## 3. Doji (recon.md'ye ek)

- **Avatar kurulumu:** 6 selfie + 2 tam boy fotoğraf; ~30 dk; hazır olunca bildirim (C, TechCrunch S13). Liste yalnız "birkaç fotoğraf" diyor; sayı ve süre resmi listede yok (V, S14). Bir ikincil kaynak 8 selfie / ~20 dk diyor → sayı değişmiş olabilir (C).
- **Teknoloji:** kendi difüzyon modelleri (C, S13). 3B gövde mi 2B görüntü hattı mı: **UNKNOWN**. İşlem yeri belirtilmemiş: **UNKNOWN** (bulut olması muhtemel, ama yazılı değil).
- **Gerçekçilik:** basın testinde avatar daha uzun ve ince çıktı; yeni fotoğraflarla yeniden eğitme mümkün (C, S13). Bu, `feedback.md`'deki 1 numaralı şikâyetle örtüşüyor.
- **Deneme davranışı:** varsayılan olarak avatar üstünde hazır "görünüşler" akışı; üst ve altları kaydırıp dokunarak yeni görünüş kurma; web bağlantısı yapıştırma; tarayıcı eklentisi; başkalarının görünüşünü "remix" (V liste, C basın).
- **Uyum:** "nasıl görünür" gösteriliyor, "nasıl oturur" değil; uyum tahmini plan olarak anılıyor (C, S13).
- **Liste:** iOS 18+, ~463 MB, ABD'de 4,1★ / 170 puan, sürüm 1.1.5. Gizlilik etiketinde ad ve fotoğraflar kullanıcıya bağlı, telefon numarası bağsız (V, S14).

**Alınacaklar:** avatarı yeniden kurma; kaydırıp dokunarak görünüş kurma; bağlantıdan ekleme. **Alınmayacaklar:** çoklu selfie, 30 dk bekleme, telefonla kayıt, bulutta yüz.

## 4. Anywear / Decart (recon.md'ye ek)

- **Motor:** Decart'ın gerçek zamanlı video deneme modeli (Lucy VTON); belgeler `lucy-vton-latest` → 3.6 sürümünü ve 720p çıktıyı anıyor (V, S12, S15).
- **Akış:** telefonda web uygulaması; masaüstünde Chrome eklentisi ve Shopify mağaza bileşeni. Mağaza sayfasında giysiyi **sürükleyip üstüne bırakma**; ikinci parça da sürüklenerek ekleniyor. Bıraktıktan sonra **~1,5 sn** (C); sonra kuyruksuz sürekli izleme (V, S15).
- **Gereksinim:** fotoğraf yok, hesap yok, yalnız kamera izni; beta süresince ücretsiz (V, S15).
- **Işık ipucu:** pencereye dönük olmak karanlık odadan iyi sonuç veriyor (V, S15).
- **Dürüstlük:** sonucun üretilmiş fotoğraftan daha az "parlatılmış" olduğu kasıtlı olarak söyleniyor (V, S15).
- **Giysi görseli kuralları (geliştirici belgesi):** yalnız giysi, insan üstünde değil; düz/beyaz zemin; en az 512×512 piksel; modelin üstündeyse önce giysiyi ayır (V, S12).
- **Bulut:** WebRTC / WebSocket akışı (V, S12); işlem yeri ve saklama süresi sayfada yok (**UNKNOWN**), Decart politikasına yönlendiriyor. Üçüncü taraf fiyatı: saniyesi ~0,02 $ (C, fal.ai, aramada).

**Alınacaklar:** sürükle-bırak ile giydirme, ışık ipucu, giysi görseli kalite kuralları, "daha az parlatılmış ama dürüst" tavrı.

## 5. Ortak teknik tablo

| Rakip | Deneme tekniği | Bulut / cihaz | Kişisel girdi | Hız | Kanıt |
|---|---|---|---|---|---|
| Giyio | Decart gerçek zamanlı video VTON, ön kamera, 15 sn | Bulut (kare + giysi görseli Decart'a) | Yok (isteğe bağlı cinsiyet/yaş/beden yalnız cihazda) | **UNKNOWN** | V |
| Anywear | Decart Lucy VTON, sürükle-bırak | Bulut akışı; yer **UNKNOWN** | Yok | ~1,5 sn ilk görüntü | V / C |
| Doji | Kendi difüzyon modelleri, avatar üstünde görüntü | **UNKNOWN** (yazılı değil) | 6 selfie + 2 tam boy | ~30 dk avatar | C |
| Alta | Avatar görüntü üretimi; etikette SAM | **UNKNOWN** (yazılı değil) | Yüz + beden fotoğrafı, boy/kilo/ölçü, ten/saç | **UNKNOWN** | V / C |
| **Kabinsiz** | F1 yerel ayna: Vision 14 eklem → `GarmentRig` → kendi giysi çizimlerimiz; 3B model elle döner | **Cihaz**; kare saklanmaz, gönderilmez | Yazılan ölçüler + Kadın/Erkek/Nötr; V37'de isteğe bağlı tek fotoğraf | Canlı (cihaz ölçümü R-002) | ADR-015/016/017 |

## 6. Temiz oda benimseme spesifikasyonu (Kabinsiz yolu)

Her satır: rakibin işi → bizim cihazdaki yolumuz → mahremiyet sınırı → dokunuş bütçesi → durum. Durum sınıfları V36 kuyruğuyla aynı; bu belge kod değiştirmez, hepsi **NOT_RUN** ya da mevcut paketin durumudur.

| # | Fikir (kaynak) | Kabinsiz yolu (cihazda) | Mahremiyet sınırı | Dokunuş bütçesi | Bağ / durum |
|---|---|---|---|---|---|
| V37-S01 | Tek ekran, tek birincil "Dene" (Giyio) | "Dene" sekmesi: üstte Dolabım şeridi (son eklenen seçili gelir), altta tek dolu düğme "Aynada dene" → F1 yerel ayna (Vision `VNDetectHumanBodyPoseRequest` + `GarmentRig` + OWNED_ORIGINAL çizimler, ürün rengiyle çarpılmış). Süre ve hak sınırı yok | Kare cihazda, saklanmaz; ekranda sürekli "Temsilî çizim" etiketi (ADR-015) | İlk kez ≤4, sonra ≤2 | ADR-015 F1 SIMULATOR_TESTED; ekran düzeni NOT_RUN |
| V37-S02 | Mağaza uygulamasından paylaşım (Giyio, Doji, Anywear) | Share Extension: gelen URL ve uygulamanın paylaştığı görsel alınır. Sayfa yalnız `BrandSourceGate` izinli alan adlarında cihazda okunur; diğerlerinde ad ve bağlantı saklanır, görsel kullanıcıdan istenir ("fotoğraf seç" yedeği) | Marka sitesi kazınmaz (V32-WEB-02); kişisel veri gitmez | ≤3 (Paylaş → Kabinsiz → Dolabıma ekle) | V36-06 NOT_RUN |
| V37-S03 | İki yollu ekleme kartı: Galeri, Link (Giyio) | Dolabım boşken ve üstte kalıcı: "Galeriden" ve "Bağlantıdan" (+ mevcut "Tara" araç çubuğu eylemi). PhotosPicker → Vision ön plan maskesi → renk pikselden, tür önerisi → **onay ekranı yok**: parça hemen eklenir, etiketler düzenlenebilir çip, "Geri al" 5 sn | Fotoğraf cihazda, kesilmiş görsel Vault'ta; piksel değiştirilmez | ≤3 (Galeriden → seç → Ekle) | V36-03 paket CODED; UI NOT_RUN |
| V37-S04 | Sade izin ön ekranı (Giyio) | Kamera iznini sormadan önce tek ekran: 3 madde (görüntü iPhone'dan çıkmaz; kare kaydedilmez; izni Ayarlar'dan geri alabilirsin), iki düğme "Kamerayı aç" / "Şimdi değil". Yalnız ilk kullanımda | Üçüncü taraf işleyen yok; metin bunu söyler | +1 (yalnız ilk kez) | NOT_RUN |
| V37-S05 | Deneme sonrası tek soruluk sayfa (Giyio) | Aynada deklanşör → alttan sayfa, kendi başlığımız (ör. "Nasıl görünüyor?"), düğmeler: Paylaş (birincil) / Fotoğraflar'a kaydet / Başka parça. Görüntüde silinemeyen küçük "Temsilî çizim" damgası | Fotoğraf yalnız deklanşörle oluşur, yalnız paylaşılırsa çıkar (ADR-015) | ≤2 (deklanşör + Paylaş) | NOT_RUN; kısa klip kaydı (cihazda `AVAssetWriter`) sonraki adım, **UNKNOWN** ihtiyaç |
| V37-S06 | Hesapsız + tek yerde "verilerimi sil" (Giyio) | Hesap yok (DONE). "Ben" ekranının altında görünür "Her şeyi sil" → tek onay → Vault anahtarı ve dosyalar silinir | Sunucu yok, DeviceCheck gibi kalıcı belirteç yok | ≤3 (Ben → Her şeyi sil → Onayla) | Vault silme DONE; yerleşim NOT_RUN |
| V37-S07 | 5 parçada ilk kombin (Alta) | Kullanıcının ilk üst + alt (+ ayakkabı varsa) parçası eklendiği an "Bugün" ekranında ilk kombin kendi parçalarıyla; o ana kadar "örnek" etiketli demo dolap | Yalnız kendi dolabı (feedback #3 değişmezi) | 0 (açılış ekranında) | TodayOutfit DONE; eşik kuralı NOT_RUN |
| V37-S08 | Her kombinde tek dokunuşla "modelimde gör" (Alta, Doji) | Kombin kartında "Modelde gör" → elle dönen 3B model giydirilmiş açılır (ADR-016); parçaya dokununca değiştir | Model kendiliğinden dönmez | 1 | `onShowOnModel` mevcut; kart düğmesi NOT_RUN |
| V37-S09 | Avatarı kur / yeniden kur (Doji, Alta) | Doji'nin 6 selfie + 2 tam boy + 30 dk yerine: ölçüler (DONE) + **isteğe bağlı tek fotoğraf** → V37-01 `FaceAppearanceReader` (ten, saç rengi, saç boyu sınıfı) + `BodyProportionReader` (tahmin + aralık) → satır satır onay. Fotoğrafsız yol: ten ve saç için renk çipleri (Alta'nın metin girişinin karşılığı). "Baştan kur" tek düğme | Yüz embedding'i ve kimlik yok; fotoğraf analizden sonra bellekten atılır; form fotoğraftan çıkarılmaz (ADR-017) | Fotoğrafla ≤5 (Ben → Fotoğraftan güncelle → seç → Onayla → Uygula); fotoğrafsız ≤3 | V37-01/05 sırada |
| V37-S10 | Içe sokma tercihi ve katman (Alta) | `DressedAvatarState` katman sırası + "içe sokulu" / "açık ceket" varyantı; modelde parça başına tek dokunuş geçiş | — | 1 | V36-12 NOT_RUN |
| V37-S11 | Işık ipucu (Anywear) | `FrameLight` zaten oda ışığını ölçüyor; eşiğin altında 2 sn sabit kalırsa tek satır ipucu ("Işığa doğru dön"); ayna çalışmaya devam eder | Ölçüm karede, saklanmaz | 0 | Ölçüm DONE; ipucu NOT_RUN |
| V37-S12 | Giysi görseli kalite kuralı (Decart belgesi) | Eklemede cihaz kontrolü: kısa kenar <512 px ise uyarı; Vision kişi algısı görselde insan bulursa "Giysiyi düz zeminde çek" önerisi ve kişi maskesiyle yalnız giysi bölgesini ayırma (V37-01 `WornGarmentReader` yolu) | Kişi görüntüsü saklanmaz; yalnız giysi kesiti Vault'a | 0 (otomatik) | NOT_RUN |
| V37-S13 | Sürükle-bırak ile giydirme (Anywear) | Aynada ve 3B modelde Dolabım şeridinden parçayı figürün üstüne sürükle; erişilebilirlik için aynı işin dokunuş karşılığı (parçaya dokun = giydir) | — | 1 sürükleme ya da 1 dokunuş | NOT_RUN |
| V37-S14 | Dürüst sınır cümlesi (Giyio, Anywear) | Ekrandaki mevcut doğruluk etiketi + eklemede tek satır: renk ekranda farklı görünebilir. Uyum yalnız V36-13 ölçü karşılaştırmasıyla, "tahmin" etiketli | Yanıltıcı uyum iddiası `STOP_THE_LINE` | 0 | Etiket DONE (ADR-015) |

**Alınmayacaklar (bilinçli):** bulut VTON varsayılanı (Decart dahil; `BLOCKED_EXTERNAL`, açık rıza + DPA + maliyet sınırı olmadan kapalı); kredi/hak sistemi ve 15 sn sınırı; kalıcı cihaz belirteci (DeviceCheck); görüntü ya da ürün verisi içeren analitik; çoklu selfie ve bekleme; telefonla kayıt; sosyal akış, liderlik tablosu, başkasının görünüşünü "remix" (sunucu ister); bulutta fotogerçekçi avatar. Rakip metni, ikonları, renkleri ve ekran düzeni piksel piksel alınmaz (Apple 4.1); "Nasıl durdu?" gibi ifadeleri aynen kullanmayız, kendi sesimizle yazarız.

## 7. Sadelik bütçesi (Giyio'dan daha sade ya da eşit)

### 7.1 Kurallar

1. **Ekran başına tek birincil eylem** (dolu düğme). En fazla 2 ikincil eylem (çerçeveli ya da metin). Araç çubuğundaki "Tara" ve profil düğmesi sabit gezinmedir, sayılmaz.
2. **Değerden önce form yok.** Hesap yok; ölçü girişi isteğe bağlı, ilk açılışta nötr figür + "örnek" dolap görünür.
3. **İzin, kullanıldığı anda** ve tek ön ekranla istenir; karşılama/tanıtım kaydırmalı ekranları yok.
4. **Onay ekranı yerine geri al.** Ekleme anında olur; düzeltme çiplerle; 5 sn "Geri al".
5. **Metin:** başlık ≤4 kelime, gövde ≤2 satır, "sen" dili, emir kipi, tek sınır cümlesi; teknik terim yok (VTON, model, yapay zekâ kelimeleri ekranda yok).
6. **Ölçüm kapısı:** her çekirdek görev bir XCUITest ile dokunuş sayısı sayılarak doğrulanır (önerilen `SimplicityBudgetUITests`, SIMP-T01..T09; NOT_RUN). Bütçe aşılırsa UI dilimi GATE'ten geçmez.

### 7.2 Görev başına dokunuş üst sınırı

| # | Çekirdek görev | Giyio (C, çıkarım) | Kabinsiz üst sınırı | Kabinsiz yolu |
|---|---|---|---|---|
| SIMP-T01 | İlk açılıştan ilk canlı denemeye (hazır örnek parçayla) | Giyio'da önce parça eklemek gerekir: ~5–6 | **≤4** | Dene sekmesi → Aynada dene → Kamerayı aç → iOS İzin ver |
| SIMP-T02 | İzin verilmişken tekrar deneme | 1–2 | **≤2** | (parça seç) → Aynada dene |
| SIMP-T03 | Galeriden giysi ekleme | 2–3 | **≤3** | Galeriden → fotoğraf seç → Ekle |
| SIMP-T04 | Mağaza uygulamasından ekleme | 2 (+ olası onay) | **≤3** | Paylaş → Kabinsiz → Dolabıma ekle |
| SIMP-T05 | Deneme sonrası paylaşma | 1 + sistem sayfası | **≤2** + sistem sayfası | Deklanşör → Paylaş |
| SIMP-T06 | Bugünün kombinini görmek | Özellik yok | **0** | Açılış ekranı |
| SIMP-T07 | Bugünün kombinini modelde görmek | Özellik yok | **≤1** | Modelde gör |
| SIMP-T08 | Tüm veriyi silmek | 2–3 | **≤3** | Ben → Her şeyi sil → Onayla |
| SIMP-T09 | Hesap / kayıt | 0 | **0** | — |

Not: Kabinsiz'de deneme sınırsız ve ücretsiz olduğu için deneme sırasında otomatik klip yok; fotoğraf deklanşörle alınır. Bu yüzden T05 Giyio'dan bir dokunuş fazladır; karşılığında kare izinsiz oluşmaz (ADR-015). Bu bilinçli bir takastır.

## 8. Mahremiyet sınırı (bütün fikirler için)

- Yüz, kamera karesi ve kişi fotoğrafı **hiçbir zaman** buluta gitmez; Kabinsiz'de üçüncü taraf görüntü işleyen yoktur (Giyio ve Anywear'den temel fark).
- Kimlik tanıma yok: yüz embedding'i, şablon ya da kişiyi ayıran parmak izi üretilmez ve saklanmaz (V37 ana kararı).
- Kamera karesi saklanmaz; fotoğraf yalnız deklanşörle oluşur ve yalnız kullanıcı paylaşırsa cihazdan çıkar.
- İki ya da daha fazla kişi görünürse giysi çizilmez (V32-MIR); başkasının görüntüsü işlenmez.
- Beden formu fotoğraftan çıkarılmaz (ADR-017); fotoğraftan beden okuması "tahmin" etiketli ve satır satır onaylıdır.
- Paylaşım uzantısı yalnız URL ve kullanıcının paylaştığı görseli alır; izinli olmayan alan adlarının sayfası okunmaz.
- Analitik SDK'sı ve kalıcı cihaz belirteci yok; silme her şeyi siler.

## 9. UNKNOWN listesi

- Giyio: ilk açılış karşılama ekranı; parça eklemede onay adımı; denemede parçanın otomatik seçilip seçilmediği; silmede onay adımı; aynı anda kaç parça denendiği; desteklenen giysi türleri; gecikme; giysinin ürün görselinden ayrılma yöntemi; kullanıcı yorumları (puan yok); kurucunun herkese açık LinkedIn/basın paylaşımı; Decart'ın saklama süresi ve işlem yeri.
- Alta: avatar üretim modeli ve işlem yeri; avatar üretim süresi; güncel günlük avatar sınırı (yorumlarda 10, resmi sayfada yok).
- Doji: güncel selfie sayısı ve bekleme süresi (basında 6+2 / ~30 dk, bir ikincil kaynakta 8 / ~20 dk); 3B mi 2B mi; işlem yeri; ücret.
- Anywear/Decart: işlem yeri, saklama süresi, kare hızı, beta sonrası fiyat; telefon web uygulamasında ön/arka kamera.
- Kabinsiz: SIMP-T01..T09 henüz ölçülmedi (NOT_RUN); F1 aynanın cihazdaki hızı R-002 (gerçek iPhone) bekliyor.

## 10. Kaynaklar (erişim tarihi: 2026-11-05)

| # | URL | Neyi destekliyor |
|---|---|---|
| S01 | https://itunes.apple.com/search?term=giyio&country=tr&entity=software ve https://itunes.apple.com/lookup?id=6817144573&country=tr | Giyio kimliği, geliştirici, sürüm, tarih, boyut, dil, yaş, ekran görüntüsü dosya adları, açıklama |
| S02 | https://apps.apple.com/tr/app/giyio-canl%C4%B1-k%C4%B1yafet-dene/id6817144573 | Uygulama içi paket fiyatları, gizlilik etiketi, uyumluluk, puan durumu; 5 ekran görüntüsü (GY-01..04 envanteri) |
| S03 | https://itunes.apple.com/search?term=giyio&country=us&entity=software | Giyio'nun ABD mağazasında olmadığı |
| S04 | https://giyio.app | Ekle/Dene/Paylaş akışı, 15 sn, mağaza paylaşımı, Trendyol/Hepsiburada, SSS, ücretsiz deneme, fiyatlar, dil tonu |
| S05 | https://giyio.app/gizlilik | Decart, Firebase, RevenueCat, PostHog, DeviceCheck; cihazda kalan veriler; kısa ömürlü belirteç; KVKK md. 9; silme |
| S06 | https://giyio.app/sartlar | Hak kullanımı ve iadesi, Decart, 18 yaş, yalnız kendi görüntün, uyum garantisi yok |
| S07 | WebSearch "Giyio uygulama Eren Görkem Şahin", "\"Giyio\" canlı kıyafet deneme" | Basın kaydı bulunamadı (UNKNOWN) |
| S08 | WebSearch "\"Eren Görkem Şahin\" linkedin" | Herkese açık profil bulunamadı (UNKNOWN) |
| S09 | https://www.altadaily.com/guide | Alta karşılama adımları, 5/70 parça, ekleme yolları, etiketleme, avatar girdileri, içe sokma tercihi |
| S10 | https://www.altadaily.com/blog/virtual-dressing-room | Alta avatar girdileri (vesikalık + ölçüler, tam boy isteğe bağlı), avatar düğmesiyle deneme, günlük 10.000+ avatar (C) |
| S11 | https://www.altadaily.com/llms.txt | Günlük kombin: hava + stil + dolap |
| S12 | https://docs.platform.decart.ai/models/realtime/virtual-try-on.md | Decart VTON model adı, girdiler, giysi görseli kuralları, WebRTC/WebSocket, belirteç süresi |
| S13 | https://techcrunch.com/2025/05/15/doji-raises-14m-to-make-virtual-try-ons-fun-through-ai-avatars | Doji 6 selfie + 2 tam boy, ~30 dk, kendi difüzyon modelleri, yeniden eğitme, uyum yok |
| S14 | https://apps.apple.com/us/app/doji-try-on-clothes/id6737292650 | Doji liste açıklaması, iOS 18+, boyut, puan, gizlilik etiketi |
| S15 | https://anywear.decart.ai/live-virtual-try-on | Anywear akışı, ~1,5 sn, fotoğraf/hesap yok, ışık ipucu, Lucy V-TON, beta ücretsiz |
| — | Aramada görülen ikincil sayfalar (WWD, Alta topluluk blogu, fal.ai, afrotech) | Yalnız C sınıfı ek bilgiler; satırlarda C olarak işaretli |

Önceki tur kaynakları (Alta SAM, Google, Cladwell, yorum RSS akışları): `recon.md` ve `feedback.md`.

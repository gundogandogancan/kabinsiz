# KABİNSİZ v3.3 — REALITY FIRST / GOD LEVEL ENGINEERING BLUEPRINT

**Tarih:** 4 Kasım 2026 · **Ürün:** Kabinsiz · **Dil:** Türkçe · **Çalışma kuralı:** Maximum Intelligence. Minimum Interface.  
**Hedef kitle:** Ürün sahibi, Claude Code, iOS/3D/CV/ML/Fashion/Legal/QA ekipleri.  
**Belge durumu:** YENİ DENETİM + UYGULAMA YOL HARİTASI. Kod değildir. Mevcut v3.2 Master Constitution'a ek olarak okunur.  
**Okuma sırası:** 1) Bu dosyanın §§0–4'ü, 2) `CLAUDE_EXECUTION_DIRECTIVE_v3.3.md`, 3) v3.2 ana şartname, 4) ilgili kaynak dosyalar. Eski anayasadan daha zayıf güvenlik hükmü getirilmez.

> **Ana karar:** Kabinsiz bir kamera filtresi, fotoğraf efekti, basit kıyafet kataloğu veya sahte 3D manken değildir. Kullanıcının **kendisine benzeyen 3D dijital ikizi + sahip olduğu giysilerin 3D envanteri + ürünün gerçek kimliği + kanıta dayalı beden tavsiyesi + kişisel günlük stil + canlı ayna** tek ürün deneyimidir. Ancak dört farklı doğruluk alanı karıştırılamaz: (1) doğru SKU, (2) gerçek üretim ölçüsü, (3) yaklaşık 3D görüntü, (4) canlı video dönüşümü. Biri diğerini kanıtlamaz.

---

## 0. ON SANIYELİK YÖNETİCİ ÖZETİ

**Kullanıcı yalnız şunu yaşar:** Uygulamayı aç → kendi modelinde bugünün kombinini gör → kıyafete dokun/değiştir → mağazada gördüğün ürünü tara → **Dene** → kendi modelinde ve izin verirse canlı kamerada gör. Dolap mümkün olduğunca seçtiği fotoğraflardan otomatik oluşur.

**Kullanıcı görmez:** Agent panelleri, yapay zekâ sayacı, teknik terimler, sahte kesinlik, uzun açıklamalar, kalabalık yan menüler, rastgele şehir seçimi, modelin önünü kapatan 7 kategori tuşu.

**İlk hedef ürün:** Tam küresel katalog değil; gerçek iPhone'da, belirli bir anlaşmalı markanın / gerçek ölçülü 20–50 varyantının **barkod → doğru ürün → kendi 3D modelinde gerçek mesh → güvenilir fit bilgisi** dikey pilotu. Buna paralel **PhotosPicker → 1 gerçek kıyafet → dolap → 3D varlık → ana ekran** pilotu. Sonra Local Mirror ve kontrollü Cloud VTON.

**Kabul etmediğimiz bitmişlik:** Figma görseli, sentetik kayıt, metinsel sözleşme, test double, 3D silüet, Decart SDK'sını ekleyip kamera akışını bağlamamak, tek bir yakışıklı/yakışıklı görünüm üretmek.

---

## 1. KANITA DAYALI MEVCUT DURUM / VERSION REALITY

Denetlenen kaynak: `gundogandogancan/kabinsiz` repo `main`, HEAD **`30ed2ef9ab38db939ca4faf2b098f83fe256e23a`** (2026-11-03 15:25:40 UTC). GitHub bağlantısı üzerinden kaynak ve `docs/evidence/*.yaml` incelendi. Ayrıca kullanıcının yüklediği 2026-11-03 23:35–23:37 simülatör görüntüleri incelendi. Ekranlar repo HEAD'inden daha geç: bazı yerlerde **4 sekmeli Ayna, sentetik 3D giyinme ve şehir sahnesi** var; `main` kaynakta **3 sekme ve ayrı tarama sheet'i** görülüyor. Bu tutarsızlık kesin çözülmeden “son push aynen bu” denmez. Claude önce `git status`, aktif dal, yerel commit ve `main` farkını kanıtlayacak.

| Yetenek | Ana kaynak | Kanıt ve durum | İstenen sonraki somut kanıt |
|---|---|---|---|
| Quiet Atelier token/tipografi | `AtelierTokens.swift`, `AtelierTypography.swift`, `Theme.swift` | **KODLANDI / simülatör test kaydı** | Sadece tek token kaynağı; gerçek ekranlarda AA kontrast; marka logo tutarlılığı |
| 360° nötr manken | `BodyMesh.swift`, `BodyModel3DView.swift` | **KODLANDI / simülatör testi** | Gerçek kişiye benzeyen yüz/saç + giyinmiş rig + fiziksel cihaz performansı |
| Octopus koordine görev | `OctopusCoordinator.swift`, `TaskGraph.swift` | **KODLANDI / test kaydı** | Ürün ve fotoğraf görevlerinin gerçek DAG'a bağlanması; yarış/iptal deneyleri |
| Vault / Citadel | `Vault`, `CitadelGate`, `ConsentLedger` | **KODLANDI / test kaydı** | Yeni kamera, fotoğraf, konum, partner ve bulut akışlarında gerçek egress doğrulaması |
| Ürün kimliği / kumaş / fit şemaları | `DomainSchemas/` | **ŞEMA KODLANDI** | Doğrulanmış veriyle dolu real ProductGraph, resolver, beden kıyaslama motoru |
| Katalog | `ShoppingCopilot/Catalog.swift`, `SyntheticCatalog.json` | **YALNIZ SENTETİK / manuel kod** | Gerçek GTIN/SKU, lisanslı partner feed'i, varyant testleri |
| Kamera barkod | `ScanView.swift` | **YOK** — kaynak açıkça “kamera tarama bu sürümde yok” diyor | Fiziksel kamera izin + EAN/UPC/Code128 + hatalı etiket testleri |
| Fotoğraf dolabı | `WardrobeView.swift`, `SyntheticCloset.swift` | **MANUEL/SENTETİK** | PhotosPicker ve açık izinli tarama; kıyafet maskesi, onay, dedup |
| Gerçek 3D giysi | `BodyModel3DView.swift` body-only | **YOK / USER SHOTS TEMSİLİ** | Riglenmiş/ölçülü 3D ceket, pantolon, ayakkabı; 360° kalite |
| Kişisel yüz, saç | `BodyGeometry` tarafında nötr geometri | **YOK** | Rızalı selfie, yüz/saç özelleştirme, local rig, kişi onayı |
| Daily Outfit + hava sahnesi | `TodayView.swift` yorumu ve seyahat motoru | **ANA SAYFADA GERÇEK GÜNLÜK MOTOR YOK** | Coarse location + WeatherKit + sabah cache + şehir/iklim stüdyosu |
| Mirror güvenlik durumları | `LiveMirror/MirrorSession.swift` | **SÖZLEŞME/STATE MACHINE KODLANDI** | Gerçek AVFoundation pipeline, G1 local overlay, cihaz videosu, hata UI |
| Decart real-time VTON | `MirrorFlags.production.cloudMirrorEnabled=false` | **KAPALI/DIŞ BAĞIMLILIK** | Sözleşme/DPA, izin, güvenli token, gerçek iPhone ve fatura testleri |
| Açılış / loading | `KabinsizApp.swift` `UILaunchScreen` `SurfaceBase`; `.task { model.load() }` | **LOGO→MODEL ANİMASYONU YOK** | Asset + prewarm + kesintisiz geçiş + cold-start ölçümü |
| Figma gerçek dosyası | v2.8–v3.2 tasarım referansları | **ŞARTNAME / görsel referans** | Editlenebilir frame/token/prototip, Figma bağlantısı, iOS parity |
| Partner portal ve sözleşmeler | `DomainSchemas/Commerce.swift`, `CoverageGate.swift` | **ŞEMA/POLİTİKA, GERÇEK PARTNER YOK** | Onaylı marka, veri sözleşmesi, feed ingestion, hak/revizyon |

**Kayıtlı testler:** `docs/evidence/UI20-WP02-04.yaml` dosyası 287 Swift paket testini ve 10 simülatör UI testini geçmiş bildiriyor. Bu görüşmede bağımsız build/`swift test`/Xcode test komutu çalıştırılmadı; gerçek iPhone deneyim kanıtı mevcut değil. **Kullanıcının daha geç tarihli ekranları bu HEAD'de olmayan bir yerel çalışma veya dal gösterebilir; bu bilinmiyor.**

### 1.1 Olgunluk seviyesi — ölçülmüş başarı değil, kanıta göre kapı değerlendirmesi

- **L0:** fikir/şartname.
- **L1:** kodlanmış temel/izole demo/simülatör (çoğu mevcut bileşen bu düzeyde).
- **L2:** gerçek cihazda uçtan uca kullanıcı akışı; doğru kaynaklı gerçek ürün ve gerçek kamera.
- **L3:** anlaşmalı marka / gerçek kullanıcı pilotu, ölçülen ürün, fit, latency ve hata oranı.
- **L4:** çok marka/şehir/boyut ve fiziksel denemelerle kanıtlanmış kalite.
- **L5:** geniş ölçek, yüksek doğruluk, stabil maliyet/güvenlik, ürün-hizmet operasyonu.

**Bugünkü ürün bütününün konumu: L1'e yakın; vizyonun L4–L5 hedefinden uzakta.** Güvenlik sözleşmeleri ve nötr beden L1; gerçek ürün+3D fit ve canlı fotogerçekçi ayna L0–L1 arasında. Bu, keyfi “% kaç tamam” iddiası değildir; gerekli kanıt kapılarının sınıflandırmasıdır.

---

## 2. EKRAN GÖRÜNTÜLERİ — GERÇEK UX DENETİMİ

Kullanıcının yüklediği sekiz ekran `SCREENSHOT_EVIDENCE/` altında özgün olarak paketlendi. Hedef görseller `REFERENCE_MOCKUPS/` altında. Gerçek simülatör ekranı ile AI konsept görseli aynı kanıt sınıfında değildir.

| Gözlem | Kullanıcıya görünen problem | Kesin düzeltme |
|---|---|---|
| Ana ekranda model çok küçük ve basit figür | “Benim bedenim/yüzüm” hissi yok | Hero'yu yüzde 60–75 görsel alana çıkar; yüz, saç, giysi mesh ve doğal poz ana ürün |
| Sol tarafta yedi kategori, sağda çok ikon | Model örtülüyor, oyun menüsü kalabalığı | **Tüm sabit kıyafet menülerini kaldır.** Tap-to-select garment mesh + context mini sheet; Undo ve Yeni Kombin dışında kalıcı eylem yok |
| Şehir prototipi Galata/Barcelona görünüyor; hava `Hava verisi yok` | Şehirler sabit görünüyor, gerçek bağlam/meteoroloji yok | İzinli yaklaşık konumdan şehir kimliği; şehir template + gerçek weather snapshot + fallback; Yozgat/New York dahil kapsanabilir grafik dil |
| Kıyafetler ikon/şekil ve 'Temsili 3B' | Ürünün gerçek dokusu, logoları, kesimi yok | Verified garment asset tier; gerçek kaynak yoksa açıkça “yaklaşık 3D” |
| Ayna önce örnek ürün listesi gösteriyor | Kullanıcı gerçek kamerada kendini ilk anda görmüyor | 3 aşamalı Dene: kamera → ürün seç/scan → live local preview; gerektiğinde Cloud isteği |
| Dolapta “Dolabın boş” ve manuel ekleme | Çok sürtünme; kullanıcının fotoğrafları değerlendirilmiyor | İlk aksiyon: “Fotoğraflarımdan bul” (seçim ve izin). Sonuçları düzeltme tek tap |
| Tarama ekranı manuel sentetik kod | Barkodun gerçek ürün olduğuna dair güven yok | Canlı barkod scanner, GTIN normalize, exact match / ambiguous / unknown |
| Profil çok metin, güvenlik listesi uzun | Moda uygulaması yerine teknik ayarlar paneli | Ana profil yüz/model kartı + üç açık menü: Modelim, Stilim, Gizlilik; detay derin sayfada |
| Soğuk otomatik gri/çok sayıda kart/sert butonlar | Marka ADN'si parçalı | Tek Atelier token sistemi; açık/koyu kontrast; logo şampanya-bakır; serif yalnız başlık |
| Açılışta 3D yükleme donması | Kullanıcıya takılmış gibi geliyor | Ayrı launch/studio lifecycle; kısa logo reveal, eşzamanlı avatar prewarm, graceful cached still→mesh |

**Tasarım ilkesi:** İlk bakışta yalnız (1) model+şehir/hava, (2) Yeni Kombin, (3) Bugün/Dolabım/Dene. Modelin üzerine dokunulduğunda **yalnız o giysinin seçimleri** açılır. 3D yüzey kullanılabilir olmadığında yalan söylemeden cached poster + yükleme durumunu göster. Profil sağ üst; “Seyahat”, “Stilist”, “Fit Passport” bağlama göre ikincil route.

---

## 3. KULLANICI YOLCULUKLARI / EKLEMLER

### 3.1 İlk indirme / modelim oluşuyor

1. Güzel, statik sistem LaunchScreen → **orijinal Kabinsiz bakır-kum logomuz** hafif reveal. Logo ekranı yüklemeyi maskelemez, kullanıcıyı bekletmez.
2. Altta ilk kişisel değer vaadi: **“Kendini gör. Stilini keşfet.”** İki seçim: “Modelimi oluştur” ve “Şimdilik keşfet”. Uygulama kamera/fotoğraflara otomatik erişmez.
3. Kullanıcı isterse **tek selfie + isterse iki açı / boy bilgisi** verir; seçtiği görüntü cihaz içinde işlenir. Tüm galeriyi otomatik yüz arayıp “en güncel gerçek yüz” seçmek varsayılan OLMAZ; fotoğraflarda başka insanların da yüzleri vardır. İsteğe bağlı geniş tarama ayrı açık ve geri alınabilir onay ister.
4. Yerel yüz konturu/saç sınıfı ve rig eşleştirmesi *öneri* üretir. Avatarı kullanıcı bir iki düzeltmeyle “Bana benziyor” diyerek onaylar. Beden çevre ölçüleri yalnız fotoğraftan kesin belirlenmez; boy girilebilir, kritik bölgesel ölçüler sonradan düzenlenir. Gerekirse nötr avatar hızla sunulur.
5. Model önbelleğe yazılır, 3D yüz/saç/geometri cache'lenir; ilk stüdyo hemen açılır. Fotoğrafı saklama tercihi ayrı; geçici görüntüler silinir.

**Privacy:** yüz ve beden hassas veriler yerel-öncelikli, CryptoKit ve cihaz koruması; Camera/Photos rızası kapsamı yazılı; izin iptali, silme, export, analitik ayırma. Tanımayı biyometrik kimlik doğrulama olarak kullanma.

### 3.2 Fotoğraflardan otomatik dolap

`PhotosPicker selected / seçili albüm açık izin → görsel kare/kişi/giysi tespiti → segmentasyon maskesi → kategorileme → renk/desen/tekstür öznitelikleri → barkod/etiket OCR ve logo ipuçları → yerel embedding karşılaştırma → aynı giysi dedup → kullanıcı inceleme kuyruğu → OwnedGarment → 3D asset eşleşme/rekonstrüksiyon → Vault`.

- Kullanıcı fotoğraf seçer veya açık kapsamlı ayrı opt-in galeriyi taratır; *varsayılan bütün fotoğraflar taranmaz*.
- Kullanıcı fotoğrafında üstündeki palto, kazak ve çanta farklı nesneler olarak bulunur. Kısmen örtülü nesne tespiti `UNKNOWN/needsRetake` olabilir. Aynı kıyafetin 12 fotoğrafını 12 ayrı ürün sayma.
- Marka/model/logo yalnız okunabiliyorsa **aday**; ürün varyantı ve kumaş yüzdeleri görselden kesinleştirilmez. Bakım etiketi OCR'si veya marka lisanslı feed'i kanıttır; kullanıcı onayı gerektirir.
- Kart üzerinde “Bu senin ... kazağın mı?” + Değiştir/Ekle/Birleştir/Atla. Yalnız onaylananlar dolaba girer.
- 3D giysi **G0 = kanıtsız kart**, **G1 = kalıp ailesi şablonu + renk/doku tahmini**, **G2 = üretici CAD/bitmiş ölçü/kumaş özellikleriyle doğrulanmış giysi**, **G3 = üretken video görüntüsü (FİT KANITI DEĞİL)**. G1'i G2 diye sunma.
- Fotoğraf içinde ürünün yalnız önü varsa “görmediğimiz arka yüz ve dikişleri üretici kalıbına eşit” diyemeyiz. G1 görünüm yaklaşık, fiziksel uygunluk ayrı rapor.

**İşlem bütçesi:** 15–30 görsellik partiler (cihaza göre), arka planda sistemin izin verdiği zaman, öncelikli önizleme, belleği ve ısıyı kontrol et; Local Photo hashes/embedding şifreli; gereksiz orijinali tutma.

### 3.3 Mağaza barkoduna bir saniyede yaklaşım

`AVFoundation/VisionKit scanner → EAN-8/EAN-13/UPC-A/Code128/QR payload → checksum + format + GTIN14 normalize (gerekirse retailer internal code) → L0 cache exact ID → L1 izinli product catalog local index → L2 partner API → L3 GS1 doğrulama → L4 kullanıcı görseli + OCR adaylar → varyant onayı → ProductDecision`.

- **Barkod rakamının kendisi kumaş/ebat/kalıp taşımaz.** GTIN'in marka ve bazen ürün kaydı eşleşmesi için indeks gerekir. İç mağaza etiketi global GTIN olmayabilir; `partnerBarcodeAlias` sözlüğüne ihtiyaç vardır.
- GTIN **tek başına beden/varyant** kanıtı olmayabilir: belirli marka/beden/renk SKU'su + ürün revizyonu, varyant boyutları doğrulanır.
- Yanlış eşleşmede “Bulamadık”, belirsizde “Hangisi?”; düşük eminlikle başka ürünü denettirme.
- L0/L1 hızlıdır çünkü cihazdaki indeks/önbellek hazırdır. İlk defa görülen küresel ürünün **kesin** eşleşmesi hiçbir sağlayıcıyla her zaman 1 saniye garantilenmez.

### 3.4 Ürün fotoğrafı / ekran görüntüsü / web URL

`SourceCapture (camera/photo/share extension) → crop+semantic segmentation + OCR → brand/logo candidate + visual embedding similarity → allowed partner catalog retrieval → exact candidate verification (style/color/size) → rights gate → 3D asset/fit`.

- Ekran görüntüsündeki URL ve görsel, ürün kimliği için aday kanıttır; sahte merchant sayfası, yanlış varyant, yeniden adlandırılmış görsel ve kopya marka testleri zorunlu.
- Web: `Share Extension` → partner API, izinli product JSON-LD (`schema.org/Product`) ve yetkili sayfa verisi. Gizli veya TOS dışı scraping YOK. URL network fetch yalnız ürün URL'si ve kullanıcı eylemiyle; özel fotoğraf transferi yok.
- Partner entegrasyonu olmayan web ürünleri için “Görsel eşleşme / tahmin” deriz; kesin ürün/satın alma/beden iddiası yok.

### 3.5 3D giydirme / kişiye yakın fiziksel görünüm

`PersonAvatarV2 + Skeleton/skin weights + GarmentAsset (pattern, size, material, layers, texture, trademarks) → morph mapping/ease + collision checks + physically informed drape LOD → RealityKit/Metal PBR scene → tap body part → swap candidate → animation → user feedback`.

- Blender **offline asset/CAD/rig/LOD pipeline**, Unity yalnız ölçülmüş ihtiyaç varsa alternatif POC; **telefon runtime = SwiftUI + RealityKit + Metal**.
- Marka CAD/tech-pack ve gerçek bitmiş ölçüler sağlarsa fiziksel kalıp daha güvenilir; tek fotoğraftan exact 3D drape ve ölçü imkânsızdır.
- Saç ayrı geometry/groom asset; yüzü gizleyip sahte fotogerçekçilik verme. Kişinin görünümü için ayrı kullanıcı onayı (likeness QA).
- Doku, nakış, düğme, cep, logo, fermuar ve kumaş normalleri 3D varlığın doğruluk kriterleridir. Tescilli marka logoları lisans kapsamına bağlı.
- Varsa marka asset'i `USD/USDZ`; asset validator mesh/rig/hole/UV/normals/material/LODs/size/rights/revision test eder.
- Beden uygunluğu için `actual garment finished measurements – person region + ease + stretch + cut` modellenir; sırf ağırlık/boyla doğru beden hesaplanamaz.

### 3.6 Yaşayan ana ekran / şehir, yağmur ve sabah

`Coarse Location (opt-in) → cityId + timezone → verified WeatherKit → sceneTemplate(urban archetype) + seasonal lighting + weatherVFX → cache → 3D avatar dressed with TodayOutfit`.

- İstanbul ve Barcelona **demo örnekleri**; şehir kodu sabitlenemez. Yozgat, New York ve dünyanın herhangi bir yerinde çalışacak genel “kentsel/banliyö/kırsal/doğal stüdyo” seti ve uygun harita/sahne yetkisi gerekir. Her şehirde meşhur binayı taklit etmek zorunlu değil; yanlış şehir teması yasak.
- Yağmur = düşen parçacık + yüzey ıslaklık + fiziksel ışık; rüzgâr = hareketli saç/giysi/çevre (hafif LOD); kar = kar parçacığı/zemin durumu; güneş = gölge renk/pozlama; sis/bulut = atmosfer; doğru kaynak ve cihaz bütçesi koşuluyla.
- BGTask iOS zamanlaması **kesin sabah 07:00 garantisi vermez**. Bir önceki günden adayları/cache'i hazırla, launch'ta tarih/hava değişimini kontrol et; ilk karede cached kombini göster, gerekirse zaman damgası ve sonraki hızlı yenileme.
- Sahne ve kıyafet uyumu: yağmurda ıslanabilir ayakkabı/ince kazak tek başına öneriliyorsa gerekçesini gözden geçir. WeatherKit yoksa “son doğrulanan” veya nötr sahne, **uydurma derece yok**.

### 3.7 Local Mirror + Cloud VTON

**Local Mirror:** `AVFoundation live front camera → person segmentation + 2D/3D pose + depth/occlusion → rigid/skinned garment mesh alignment + TemporalSmoothing → GPU compositing → viewport`.

- Kullanıcı zaten başka giysi giyiyorken yeni giysiyi üzerine oturtmak zor kısımdır: önceki giysi segmentasyonu / silme-yeni görünüm, kol/el/saç örtülme, çanta/telefon, arkadan dönüş, hareket bulanıklığı, geniş/palazzo/sarkmalı giysi zor senaryoları.
- Yerel mesh overlay ticari sürümde **fotogerçekçi video VTON eşdeğeri değil**; dürüst “3D yerel önizleme” etiketi. Giyilen eski kıyafet izleri/occlusion artifaktlarını saklama.
- **Cloud AI Mirror:** Decart `lucy-vton-3.6` resmî Swift SDK denenebilir; fakat canlı video bulut işlemesi ve ödeme gerektirir. Şu an repo `cloudMirrorEnabled=false` doğru. Açık kapsamlı rıza, DPA ve insan imzası, eğitim amaçlı kullanım yasağı ve saklama şartlarının yazılı temini, alt işleyenler, yurt dışı aktarım, kullanıcıya silme, fiyat/oturum limiti, seçilen ürünün lisans hakları, iPhone testinden önce gerçek görüntü göndermek YASAK.
- `API secret` uygulamaya gömülmez; sunucu üzerinden kısa süreli oturum token'ı; backend kişisel fotoğrafı ve ölçüleri depolamaz. Kullanıcının açıkladığı `cloud mode` ayrı, varsayılan local.
- **Cloud sonucu yalnız görsel önizlemedir:** model güzel görünse de bitmiş ürün ölçüsü yoksa beden “tam olur” sonucuna gidemez.

---

## 4. MARKALAR ÜRÜNLERİNİ KABİNSİZ'E NASIL EKLEYECEK?

### B2B onboarding yolu

1. Marka yetkilisi kurumsal hesap + mağaza/marka sahipliği doğrulaması + sözleşme + lisans hakları.
2. **Brand Integration Portal:** `CSV upload`, `REST JSON API`, `scheduled signed feed` veya `webhook` / ERP/PIM connector. Her katalog satırı `product → style → color → size → GTIN/internal barcode → garment measurements → fabric → care → price/stock TTL → image rights → 3D rights` ilişkilendirir.
3. Ingestion pipeline: imza/schema/virus/format kontrolü, ISBN değil **GTIN check digit**, tekrarlı SKU, segment lisans, fiyat/stock TTL, ürün görseli hakları, görsel model hash, sezon/revizyon.
4. Marka personeli ürünü oluşturunca **test barkodunu** Kabinsiz sandbox'ta okutmalı; kimlik, beden-varyant ve 3D asset/sözleşme yönetim panelinden doğrulanır.
5. Marka katalog değişikliği: idempotent webhook/diff → yeni catalogRevision → cache invalidate → active try-on session revision check → yeni ürün kaydı. Partner approval olmadan otomatik `VERIFIED` verme.
6. İsterse CAD/3D asset ve kalıp verisi yükler; format convert/validate, `validUntil`, ticari kullanım izni, GTIN-asset bağlama.

**Örnek kanonik veri nesnesi (yalnız şema örneği, gerçek ürün değil):**

```json
{
  "brandId": "partner-registered-brand",
  "styleCode": "STYLE-24",
  "variant": {"colorCode": "STONE", "size": "M", "market": "TR"},
  "gtin14": "[valid 14-digit GTIN supplied by brand]",
  "merchantSku": "STYLE-24-STONE-M",
  "garmentMeasurementsCm": {"chest": 104, "length": 70, "shoulder": 44, "sleeve": 62},
  "measurementType": "FINISHED_GARMENT",
  "composition": [{"fiber": "COTTON", "percent": 95}, {"fiber": "ELASTANE", "percent": 5}],
  "asset": {"uri": "partner-authenticated-asset", "format": "USDZ", "rights": ["DISPLAY_MEDIA", "FIT_COMPUTATION"], "revision": "3"},
  "source": {"kind": "BRAND_LICENSED", "verifiedAt": "2026-11-04T00:00:00Z", "ttlSeconds": 86400}
}
```

Bu örnekteki ölçüler **tamamen kurgusaldır**, gerçek marka ölçüsü değildir. Üretimde body size chart ve finished garment ölçüsü birbirine karıştırılmaz. Müşterinin gizli ölçüsü veya fotoğrafı marka paneline aktarılmaz. Partner web sitesi kapalıysa offline doğrulanmış cache kullan; hak/TTL dolduysa veriyi gizle veya `stale` uyarısı ver.

### Minimum sözleşme seti

- `Brand Data Licence`: GTIN/SKU/style/measurement/fabric kullanma ve önbellek hakları, revizyon ve doğruluk sorumluluğu.
- `Image/Logo/3D Asset Licence`: marka görselleri, telif, model dosyaları, ticari kullanım, kullanıcı ekranında gösterim.
- `Data Processing Agreement` (bulut işleyiciler): kontrolör/işleyen rolleri, veri tipi ve amacı, retention/deletion, güvenlik, subprocessor, eğitim amaçlı kullanım, ülkeler arası aktarım.
- `Service Agreement / SLA`: uptime, katalog güncelleme, hata ve güvenlik bildirimleri, fiyat/stok TTL, sorumluluk, ticari ücretler.
- `Affiliate / commerce agreement`: satış atfı, komisyon, iadeler ve sponsorlu içerik açıklamaları; organik stil önerisine ödeme sinyali karışmaz.
- `Decart special cloud terms`: video input/output saklama ve eğitim, bölge, silme, faturalama, gizlilik, onay hakkı; **hukukçu ve yetkili insan tarafından değerlendirilip imzalanır**. Claude imzalamaz/ödeme başlatmaz.

---

## 5. RUNTIME 'AHTAPOT' — GÖREVLER, ZEKÂLAR, YETKİLER, GEÇİŞLER

Yeni ürün için 46 bağımsız LLM yaratma. **1 koordinatör + yetenek modülleri + denetim kapıları** daha hızlı, ucuz, güvenli. `OctopusCoordinator` zaten var: genişlet, rakip scheduler yaratma.

| Modül | Giriş | Üretim | Yetki/çıkış sınırı |
|---|---|---|---|
| `ContextComposer` | izinli şehir/tarih/hava | `ContextSnapshot` | konum yalnız izin; ihtiyaç olmayan kesin GPS saklanmaz |
| `PhotoAccessGate` | kullanıcı Photos seçimi/rıza | sınırlı `AssetAccess` | izin yoksa sıfır tarama; tüm galeri varsayılan hayır |
| `WardrobeDetector` | izinli kare | giysi bölgeleri/maske | local Vision/CoreML; orijinal foto export yok |
| `GarmentReID` | crop/embedding | duplicate candidates | kullanıcı onayı olmadan merge yok |
| `LogoAndLabelOCR` | logo/etiket crop | marka/kompozisyon adayları | yüz görseli girmesin; emin değilse UNKNOWN |
| `BarcodeEngine` | video barcode region | normalizedCode/checksum | default local, camera frames saklanmaz |
| `ProductResolver` | code/OCR/visual/URL | exact/ambiguous/candidate/not-found | kaynak, lisans, sürüm kanıtı zorunlu |
| `PartnerCatalogGateway` | GTIN/SKU | verified product facts | yalnız allowlisted partner host; TTL; özel beden/foto yok |
| `FabricMetrology` | marka feed/etiket | composition/stretch/gsm evidence | görselden kesin oran üretmez |
| `RegionalFitEngine` | body regions + garment finished measures | risk/size with uncertainty | ispat yoksa `INSUFFICIENT_DATA` |
| `GarmentAssetMatcher` | style/size/revision | G1/G2 mesh | asset licence, geometry QA ve revizyon uyuşmalı |
| `AvatarIdentity` | kullanıcının açıkça verdiği selfie/profil | face/hair candidate + editable rig | local; kullanıcı “benim” onayı olmadan final değil |
| `GarmentDresser` | avatar + mesh + slot | dressed preview | geometry/cloth collision gate; scene frame budget |
| `StyleAtelier` | wardrobe, plan, context, preference | 2-4 outfit candidates | sponsor etkisi yok; çelişki/fizik/etiket açıklaması |
| `TodayCacheBuilder` | wardrobe/weather/last scene | next outfit cache | best effort, hazır olmayan asset fallback |
| `WeatherSceneRenderer` | verified context | VFX/preset | yanlış şehir veya hava üretmez |
| `CameraPoseEngine` | camera frames | pose/depth/segmentation | local by default; microphone kapalı |
| `MirrorFrameComposer` | pose + garment + frame | local live overlay | frame revision + latency/identity guard |
| `CloudVTONAdapter` | explicit consent + product image + live session | generated stream | cloud default OFF, DPA/legal/TTL/cost gate |
| `TrustAndEvidenceGate` | upstream outputs | verified/limited/blocked flags | kaynak çatışmasında `BLOCKED`, yapay kesinlik yok |
| `Citadel` | tüm egress intent | authorize/deny receipt | tüm ağ yolu fail-closed |
| `DeviceGovernor` | CPU/GPU/temp/battery | quality budget/stop | cihazı ısıtma; G2→G1→G0 fallback |
| `OctopusCoordinator` | TaskGraph/work orders | priority run and provenance | latest-wins, cancellation, replay, version checks |

**Çalışma grafiği (etiket değil, gerçek DAG):**

```text
                  User Intent + ConsentLedger
                           |
                     OctopusCoordinator
                      /        |        \
       Photo-to-Closet       Product ID      Living World
       / detect/ocr/dedup    / barcode      / today cache
      /          |          / OCR/URL      / city/weather
  ReviewQueue  Wardrobe  ProductResolver  StyleAtelier
                   \       /             /
                     EvidenceCoverageGate
                            |
                FitEngine + GarmentAssetMatcher
                            |
                 Avatar/RealityKit GarmentDresser
                            |
              [Dene?] CameraPose -> LocalMirror
                            |
                 [opt-in?] Citadel -> CloudVTON
                            |
                    DecisionEnvelope + UX
```

**Sıralama:** barkod/video preview `priority 0`; UI 3D/render `priority 1`; foto galeri batch `priority 3`; yeniden modelleme/LOD `priority 4` ve uygun koşulda. Aynı GTIN için ağ isteğini birleştir, aynı ürünün eski revizyonunu göstermeyi engelle. Her modül: input/output contract, confidence, provenance, cancellation, budget, privacy classification, negative test.

---

## 6. MİMARİ TEKNOLOJİ / MCP / SKILL / AJAN SÖZLEŞMESİ

### Runtime (iPhone içinde kullanıcıya hizmet verenler)

- **SwiftUI + Observation**: basit ve erişilebilir native UX.
- **RealityKit + Metal + USDZ**: 360° riglenmiş kişinin ve giysi mesh'inin render'ı, LOD/texture/motion.
- **VisionKit + AVFoundation + Vision + Core ML**: barkod/OCR/segmentasyon/reID/pose; modellerin iPhone cihazında gerçek optimizasyonu.
- **PhotosUI/PhotoKit**: seçili fotoğraflar veya açık izinli galeride kademeli işleme.
- **WeatherKit + Core Location**: gerekli ölçüde şehir/hava; rızadan sonra; stale state.
- **CryptoKit/Keychain + Vault + Citadel + Octopus**: cihaz verisi, yetki, görev bütçesi, saklama, delil.
- **Kısıtlı partner gateway**: sadece kullanıcı eylemi / gerektiğinde ürün bilgisi, asla yüz/ölçü aktarma.
- **Decart Swift SDK**: yalnız `CloudMirrorEnabled=true` + sözleşme + token + açık izin olduğunda.

### Offline development/content production (uygulama runtime'ı DEĞİL)

- **Blender**: 3D garment template, fitting, skin weights, UV/PBR, saç, şehir sahnesi, USDZ dönüştürme, LOD asset build. İmkân varsa gerçek pattern CAD/tech-pack (CLO/Browzwear/Style3D gibi üretici araçlarından *lisanslı* export). Unity/Oyun motorunu sadece ölçülmüş eksik varsa ADR'la değerlendirme.
- **Figma**: yalnızca gerçek editlenebilir tasarım sistemi; tasarım işlev değil.
- **Xcode + Instruments + MobileBuildMCP**: gerçek kod/build/test/screenshot/CPU/GPU/ısı incelemesi.
- **Blender MCP (sandbox)**: sadece proje varlık klasörüne erişim; keychain, dış ağ, shell exec geniş yetkisi yok.
- **Figma MCP**: tasarım token/component/state parity, bağlı değilse `BLOCKED_EXTERNAL`.
- **Decart docs MCP**: SDK/dokümantasyon, *kamera servisi değildir*.
- **GitHub connector**: kaynak denetimi, PR review, commit kanıtı.
- **Filesystem MCP**: allowlisted proje klasörleri, salt okunur doküman / sınırlı çıktılar; dosya dışına key/gerçek görüntü yok.
- **Playwright MCP**: yalnız anlaşmalı marka portalının kendi test ortamı, izinsiz scraping yok.
- **Benchmark tool**: fit/visual latency, screenshot diff, logo/material consistency ve egress negative-test logs.

### Claude geliştirici ajanları — gerçekte işe yarayan uzmanlıklar

`Product/UX director` (tek hareket ekranda) → `Fashion stylist` (siluet, formallik, aksesuar, kültür) → `Pattern maker` (seam/ease/sizing) → `Textile engineer` (weave/weight/stretch) → `3D character/garment engineer` → `iOS RealityKit lead` → `Vision/Core ML lead` → `Product catalog/GS1 integrator` → `Live video/VTON engineer` → `Security/KVKK/data protection` → `Performance engineer` → `Independent QA + accessibility` → `Commercial contracts reviewer`.

Her iş paketinde **yapan ajan ile son onaylayan bağımsız ajan farklı**. Fashion/pattern/fit kritik kararlarında gerçek insan uzmanla kör deneme gerekir; LLM uzman rolü bunun yerine geçmez.

### Uygulanacak skill'ler (kullanılabilir olduğunda lisanslı ve sürüm-pinli)

`swiftui-patterns`, `swift-concurrency-6-2`, `swift-protocol-di-testing`, `ios-realitykit-rendering`, `metal-performance`, `3d-asset-qa`, `blender-pattern-to-usdz`, `coreml-compression`, `visionkit-barcode-ocr`, `photos-privacy`, `catalog-schema-gs1`, `fit-metrology`, `fabric-evidence`, `temporal-vton-qa`, `security-threat-model`, `citadel-egress-testing`, `figma-design-parity`, `screenshot-regression`, `a11y-dynamic-type`, `app-store-review`, `brand-data-licensing`, `performance-profiling`. 

Bu adlar önerilen rol/skill tanımlarıdır; hepsinin kurulu olduğunu varsayma. Claude mevcut `.claude/skills` ve `.claude/agents` envanterini çıkarsın, olmayanı **gerçek `SKILL.md`/agent scope ve testleriyle** eklesin; 45 tane boş “AI agent” üretmesin.

### Kullanıcıya visible tasarım dili (tek bir marka DNA)

- **Üç tab:** Bugün / Dolabım / Dene. Profil sağ üst. (Seyahat ve Stilist alt route).
- `Kabinsiz` logotype ve bakır/şampanya monogram, sıcak fildişi `#F8F6F1`, espresso `#26221E`, ceviz `#654632`, zeytin `#62684B`; üretimde renk değerlerini tek `AtelierPalette` üzerinden ve kontrast testinden kullan.
- Başlık = Apple sistem serif (New York), gövde/eylem = Apple sistem sans (SF); her yerde değişmeyen tipografi ölçeği.
- Ana ekranda yüz/beden/giysi **ana varlık**; sürekli tüm slot butonları yok. Kıyafete dokun → alttan 1 küçük sheet, seç → avatar anında güncellensin.
- Her kart **bir karar**, bir eylem; açıklama ikinci düzeyde. Eski gri sistem butonları ve sentetik veri gerçek diye gösterilmez.

---

## 7. 15 EKRAN İÇİN GÖRÜNÜM + DAVRANIŞ + HATA KONTRATI

| Ekran | Görünür alan / tek ana CTA | Arkada gerçek iş | Mutlaka test |
|---|---|---|---|
| 01 Launch | Kabinsiz monogram; yumuşak yukarı çıkış | SwiftUI first-frame readiness, cached scene, vault load | spinner/kasılma/VoiceOver/Reduce Motion |
| 02 Onboarding | Selfie isteğe bağlı, Modelimi oluştur | local face/hair/rig, encrypted profile | izin hayır, yalnız foto, düşük cihaz, sil |
| 03 Bugün | Büyük giyinmiş avatar, şehir/hava, Yeni Kombin | TodayCache, Scene + Style + Dresser | startup cache, no permission, weather changed |
| 04 Giyisiye dokun | Sadece ilgili slot mini sheet | 3D raycast hit-test + candidate list | yanlış parçayı değiştirmeme, undo |
| 05 Alternatif kombin | 2–4 görünüm ve neden | StyleAtelier rank + wardrobe | alternatiflerin gerçekten farklı olması |
| 06 Dolabım | Giysi mesh thumb grid ve ekleme | local wardrobe index | boş, 10k ürün, filtering |
| 07 Fotoğraftan dolap | seçili foto/album + review queue | PhotosPicker + CoreML + merge | kişi dışı foto, duplicate, cloud photo |
| 08 Giysi kartı | ad, materyal ve G1/G2 badge | product evidence, geometry | yanlış marka/kalıp, rights |
| 09 Dene | kamera + barkod/foto/link seç | scanner, resolver, rights | no permission, offline, code not found |
| 10 Ürün doğrulama | exact variant, choose if ambiguous | ProductIdentityV1 + source chain | color/size mismatch, fake code |
| 11 Ürünü 3D dene | kendi avatar ve giysi | Dresser/fit/version revision | 360 material, occlusion, G1 vs G2 |
| 12 Canlı Ayna | canlı gerçek kamera; giysi seçimi | pose/segment local overlay | existing clothing, hands/occlusion, motion |
| 13 AI Mirror opt-in | izin ve maksimum bedel, çıktı label | Decart adapter + Citadel gate | no consent/no DPA=no network |
| 14 Ben / Model | yüz, saç, ölçü, Fit Passport | body revision + hair + vault | kişiye benzememe düzeltmesi, deletion |
| 15 Gizlilik / Partner/bağlam | kullanıcı: veri kontrolleri; partner ayrı web panel | deletion ledger, licences, feed | izin iptali, geçmiş token, TTL |

**Nihai UX:** kullanıcı hiçbir yerde “GTIN-14”, “G3”, “AI-42”, “MCP”, “şifreleme algoritması” görmeyecek. Yalnız gerektiğinde **“Ürün doğrulandı”, “Görsel tahmin”, “Beden bilgisi yetersiz”, “Kameran cihazda kalıyor”, “Bulut önizleme”** gibi güven etiketleri görür.

---

## 8. ANİMASYONLU AÇILIŞ / İLK 3D KARE GECİKMESİ

**Amaç:** “Model ilk açılırken kasıyor” sorunu logo animasyonuyla gizlenip bırakılmayacak; ilk kare gecikmesinin nedeni Instruments/MetricKit ve gerçek cihazda ölçülerek giderilecek.

**Etkileşim akışı:**

```
OS LaunchScreen: statik marka arka planı + monogram
    ↓
First SwiftUI frame: logo ortada, opacity/offset mikro geçiş
    ↓ (eşzamanlı task: Vault read + cached poster + avatar mesh warm-up)
Monogram hafif yukarı kayar / küçülür; avatar poster fade-in
    ↓ (RealityKit scene ready)
Poster → gerçek interaktif 3D hero crossfade; kullanıcı dokunabilir
```

- **Hedef**, ölçülmeden SLA değildir: logo animasyonu ~0.45–0.9 sn aralığında, ancak 3D hazır değilse yapay sabit bekleme yok; cached poster ve nonblocking “Hazırlanıyor” durumu. UI main thread I/O ve ağır mesh build yapma. Concurrent task priority, cancellation, precompiled materials, model cache, lazy secondary screen. Soğuk açılış p95 ve ilk etkileşim ayrıca ölçülecek.
- Apple sistem `LaunchScreen` etkileşimli animasyon değildir; animasyon gerçek `WindowGroup` SwiftUI overlay'inde yapılır. `Reduce Motion` için doğrudan aç. Vault ya da mesh hata verirse ekran kapanmaz; kullanışlı fallback.
- **Logo:** kullanıcının seçtiği monogramın aynı geometri/renk üretim asset'i; yeni yapay logo üretilmez. iOS AppIcon kontrol edilmeli.

---

## 9. SLO HEDEFLERİ (ÖLÇÜLMEDİ — İLK PİLOT KAPILARI)

| Ölçü | Pilot hedefi / dikkat | Kabul yöntemi |
|---|---|---|
| Başlangıç UI | cached poster hızlı; cold launch p95 hedef `<2.5s` (cihazı belirle) | Instruments, >30 ölçüm, cold/warm ayrı |
| Barkod çözme | okunabilir etikette p95 `<0.5s` *kameranın odağı aldıktan sonra* | EAN13/UPC/Code128 etiketi, ışık/hasar koşulları |
| Yerel exact match | sıcak cache p95 `<1.0s` | 200+ gerçek test SKU, doğru varyant |
| Partner online match | p95 hedef `<3.0s` ağ durumuna bağlı; timeout/fallback | farklı ağ, TTL ve 5xx test |
| Otomatik exact precision | pilot hedef `>=99%` *exact-verified sonuçlar arasında*; coverage ayrı rapor | görmeden test edilen etiket/varyant gerçek seti |
| Swap 3D | hazır asset ilk görünüm p95 `<0.5s` hedef | gerçek iPhone screen recording |
| 3D render | hedef çoğu cihazda 45–60 FPS; fallback LOD | Instruments GPU/termal 10 min |
| Local Mirror | destekli cihazda hedef `>=24 FPS`, gecikme ayrı ölç | hareket + occlusion benchmark |
| Cloud Mirror | glass-to-glass p50/p95 ayrıca; sabit hız vaadi yok | gerçek oturum, sağlayıcı kayıt, ağ, fatura |
| Fit önerisi | “doğru beden” hata üst sınırı kör gerçek prova testlerinden sonra belirlenecek | ≥ çoklu beden/marka/kalıp pilotu, calibration |
| Foto dolabı | precision/recall + false duplicate + manual corrections ayrı | rızalı gerçek test dataset |

**Her testte** cihaz modeli, OS, build SHA, katalog versiyon, model ağırlığı/hash, Wi-Fi/5G, sıcaklık, kapsam, veri hakkı kaydedilir. P99 tail, crash, OOM, thermal stop, VoiceOver, erişilebilirlik ve enerji tüketimi de kalite kapısıdır.

---

## 10. PHASED EXECUTION — ÖNCE SONUÇ, SONRA BÜYÜK PLAN

**Phase 0 — Repo true baseline (1 iş paketi).** Claude `git status --short`, branch, HEAD, unpushed commits, test matrix, `.claude/` agent/skill inventory, `Info.plist` permissions, 3 tab vs 4 tab discrepancy, uploaded 23:35 screenshots vs repo screenshots, `CLAUDE.md` canonical version. Çıktı: audited `STATUS_MATRIX.md`, `SCREEN_BEFORE_AFTER.md`, `ADR_RESOLUTION.md`, egress proof. **Main'e rastgele değişiklik yok.**

**Phase 1 — Gerçek ilk küçük demo (tek ceket/pantolon; cihazda).** RealityKit rigged avatar + ürünün gerçek 3D mesh'i + 360° + user taps sleeve/torso + swap + undo. Önce sentetik mesh'i etiketli bir test fixture, sonra hakları açık *gerçek* CAD. Objeyi Unity ile sıfırdan yazma. Çıktı `.xcresult`, gerçek cihaz video, asset provenance.

**Phase 2 — Kamera ve Product Resolver.** VisionKit barkod, doğru GTIN14, alias, exact+ambiguous+unknown, önce 20–50 izinli ürün. Başarı: 50 etikette hatasız varyant ayrımı (farklı beden/renk). Sadece sentetik katalog kapısını geçirme.

**Phase 3 — Fotoğraftan dolap.** User photos picker, Core ML detector/segment, dedup, review, local Vault; ürün 3D eşleme. `photos access denied` durumunda elle/kamera ekleme mümkün.

**Phase 4 — Kişisel yüz+saç+beden.** Rızalı selfie, 3D head/groom, ölçü düzenleme, user likeness QA, boy/ölçü bağımsız. Stil sahnesine entegrasyon.

**Phase 5 — Living World morning.** Coarse location+city template+weather VFX, cached daily outfit; sıcak ilk kare. **Yozgat, New York, başka her şehir için düzgün generic fallback.**

**Phase 6 — Local Mirror.** Gerçek AVFoundation feed, yerel pose/segmentation/occlusion, kıyafet referans asset'i; mevcut `MirrorSession` testlerini bağla. Eskiden giyilen giysi baskın kalırsa görünüm `DEGRADED` diye etiketle.

**Phase 7 — Partner ve gerçek ölçü pilotu.** Bir anlaşmalı markanın gerçek data feed'i, CAD/techpack, materyal ve fit pilotu; hak ve ölçü doğrulama. 10 marka hayaliyle ilk markayı geciktirme.

**Phase 8 — Cloud VTON opt-in değerlendirme.** Decart Swift SDK, DPA/hukuk, token backend, fiyat kapsı, first-person real iPhone tests, reversible consent. İmzalar ve fatura **insan yetkisi**.

**Phase 9 — Ölçek.** Çok partner, e-ticaret URL, ticari ortaklık, artan katalog coverage, 3D garment assembly, outfit monetization; fairness/commission ayrımı.

**Her phase için GATE:** `SPEC + threat model + scope + code/PR + tests exit 0 + screenshot/video + performance + privacy probe + independent review + evidence YAML + rollback`. Başarısızsa sonraki aşamayı “tamamlandı” diye açma. Başarı metrikleri “planlandı” ≠ “ölçüldü”.

---

## 11. KIRMIZI TAKIM / OLMAZSA OLMAZ HATA SENARYOLARI

1. Aynı GTIN farklı market/beden SKU: yanlış ürün göstermeme.
2. Üründe barkod yok; QR aslında URL; zararlı URL; güvenli rotayı izle.
3. Markası benzer görünen sahte etiket/logoyu gerçek marka diye etiketlememe.
4. Marka feed'i sonradan renk/beden/malzeme değiştirir; eski cache kilitlenmez.
5. Etiket OCR'si “30°C yıkama”yı giyme sıcaklığı diye yorumlamaz.
6. Gerçek beden 82 cm bel; ürün düz bel yarım genişliği 41 cm; body vs finished garment doğru birim/fit.
7. Kişi üste bol kazak giyiyorken Live Mirror dar ceket seçer: kollarda, yakada, ellerde ve arkadan dönüşte artifakt QA.
8. Uygulama kamera açıkken arka plana geçer/kilitlenir: capture/stream/Cloud hemen kapanır; fatura durur.
9. Cloud mode izni yokken tek bir frame dışarı çıkmaz; idempotent consent revoke.
10. Kullanıcı fotoğraf seçtiğinde arkada başka insanların yüzünü eşleştirip profil yapmaz.
11. Fotoğraftan polyester/ipek oranı uydurmaz; etiketsizse unknown.
12. Foto duplicate yanlış iki giysiyi birleştirmez; reversibility.
13. Cold start mesh GPU donması; poster→3D failover / ısı ve enerji yönetimi.
14. 3D giysi var ama CAD başka size; tam ürün diye giydirme.
15. Marka logosu 3D/sentetik VTON çıktısında şekil bozuyor; screenshot comparison.
16. Offline/yalnız izinli fotoğraf/yalnız Wi-Fi; uygulama ana kullanımını sürdürebilmeli.
17. Türkçe telaffuz/biçim ve erişilebilir Dynamic Type/VoiceOver/Reduce Motion.
18. Bağlantı yokken ya da gecikince default “yükleniyor” sonsuza kadar kalmaz; reason-coded failure.
19. Harita/şehir sahnesi yanlış şehri iddia etmez; konum reddinde kullanıcı tercih edebilir veya anonim nötr sahne.
20. Ücretsiz organik en iyi kombin sponsor komisyonu sebebiyle geri plana itilmez.

---

## 12. CLAUDE'DAN İSTENECEK SON TESLİMLER

Her sprint sonunda **beş dosya**, PDF gibi süslü rapor değil, kanıt:

1. `REALITY_DELTA.md` — git HEAD, önce/sonra, her eksik kanıt/ürün etkisi.
2. `IMPLEMENTATION_DIFF.md` — değişen dosya, satır aralığı, davranış, spec ID.
3. `TEST_EVIDENCE.md` — gerçek shell komutları, exit code, fixture, seed, .xcresult ve screenshot path.
4. `PERFORMANCE_PRIVACY.md` — cihaz modeli, cold/warm, frame/p95, egress test, CPU/GPU, budget.
5. `NEXT_GATE.md` — yalnızca bir sonraki engel, sahibi, dış bağımlılıklar, rollback.

**GOD LEVEL tanımı:** 1. kullanıcının ilk 3 saniyede anladığı arayüz, 2. ürün/vücut/giysi gerçeğinden kopmayan görüntü, 3. özel veriyi koruyan cihaz öncelikli çalışma, 4. gerçek mühendislik testleri, 5. yanlış olduğunu bildiğinde durabilen zekâ. “Daha çok ajan, kart, ışıltı, sayfa, metin” GOD LEVEL değildir.

---

## 13. BAĞLAYICI DIŞ KAYNAKLAR / ÖNCE RESMÎ DOKÜMAN

- Apple VisionKit barcode & text: https://developer.apple.com/documentation/visionkit/datascannerviewcontroller
- Apple PhotosPicker: https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app
- Apple Photo Library permissions: https://developer.apple.com/documentation/photos/phphotolibrary
- Apple 3D human pose: https://developer.apple.com/documentation/vision/identifying-3d-human-body-poses-in-images
- Apple background tasks: https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app
- Apple USD assets: https://developer.apple.com/documentation/usd/creating-usd-files-for-apple-devices
- GS1 GTIN validation: https://support.gs1.org/support/solutions/articles/43000734070/
- GS1 data limits: https://support.gs1.org/support/solutions/articles/43000734119-what-information-is-available-in-verified-by-gs1-
- Decart official native iOS SDK: https://github.com/DecartAI/decart-ios
- Decart docs: https://docs.platform.decart.ai/sdks/swift-realtime
- Decart documentation index: https://docs.platform.decart.ai/llms.txt
- FASHN VTON v1.5 **sabit görüntü/gpu karşılaştırması**, canlı iPhone garantisi yok: https://github.com/fashn-AI/fashn-vton-1.5

*Bu belgede adı geçen üçüncü taraf repo/model/skill/markanın bağlantısının bulunması lisans, ticari izin, API hesabı veya sözleşme onayı bulunduğu anlamına gelmez. İnsan onayı gereken hiçbir eylem Claude tarafından otonom olarak yapılmaz.*

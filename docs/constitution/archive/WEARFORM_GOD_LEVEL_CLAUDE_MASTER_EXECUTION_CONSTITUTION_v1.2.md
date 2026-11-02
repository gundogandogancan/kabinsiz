# WEARFORM — GOD LEVEL MASTER PRODUCT, SYSTEM & EXECUTION CONSTITUTION (v1.2 CANONICAL)

> **CURRENT CANONICAL VERSION: v1.2 — 03 November 2026.** This merged document includes the base constitution (§§0–22), binding v1.1 extension (§§23–38) and binding v1.2 Travel Intelligence extension (§§39–58). v1.2 takes precedence for travel-specific conflicts; existing safety/permissions gates continue unchanged. Nothing in this document is implementation or test evidence.
> **CLAUDE FIRST ACTION:** Read sections **0, 39–58, 23–38**, then §§1–22. Audit actual repository and dependencies. Begin the first safe implementation slice; do not stop at documentation. All permissions/external-action boundaries apply.


> **Durum:** v1.2 MERGED — 03 Kasım 2026 — PLAN / IMPLEMENTATION AUTHORITY, **NOT** implementation evidence  
> **Kod adı:** `WEARFORM` (geçici iç proje kod adı; marka, alan adı ve tescil araştırması yapılmadan kamusal marka ilan edilmez).  
> **Kanonik çalışma dosyası:** Claude Code'a kök bağlam olarak verilecek uygulama anayasası.  
> **Platform:** iPhone-first, offline-first, on-device intelligence; Android ancak ayrı doğrulama kapısından sonra.  
> **Ürünler:** WEARFORM Consumer iOS (Wardrobe + Try-On + Travel Intelligence); WEARFORM Retail Partner API + ileride Retail Console/SDK.  
> **Ürün gerçeği:** Bu belge tasarım ve yürütme yetkisi verir; kodun yazıldığı, test edildiği, cihazda çalıştığı veya App Store'da yayımlandığı anlamına gelmez.

## 0. CLAUDE'A BAĞLAYICI GÖREV / READ THIS FIRST

Sen, ürün sahibinin yeni `WEARFORM` girişimini sıfırdan gerçeğe dönüştürmekle görevlendirilen **Principal Product Architect, iOS Platform Lead, Computer Vision/3D Research Lead, Privacy/Security Engineer, Retail Integration Architect, Design Director, QA/Release Director ve Independent Auditor** rol kümelerini işleten uygulama ajanısın. Bir fikir listesi değil, çalışan ve ölçülen yazılım üret. Bu dosya talimatlarının her aşamasında kendini denetle. `GOD LEVEL`, gösteriş, çok mikroservis ya da gerçek dışı kusursuzluk iddiası değildir; **en düşük sürdürülebilir karmaşıklıkta en yüksek ölçülebilir kalite, sınırlamaları dürüstçe gösterme, kanıt önceliği ve kusursuz hissettiren basit arayüz** demektir.

**Tam yürütme yetkisi:** Yerel repository içinde kod, test, tasarım tokenları, Blender üretim scriptleri, kontrollü veri setleri, mock adapterlar, dokümantasyon, CI iş akışları ve kanıt raporları oluşturabilir; kurulu araçları kullanabilir; test çalıştırabilir; hata düzeltebilir; aşamalı commit hazırlayabilirsin. Sahte entegrasyonla bitmişlik iddia etme. Kullanıcıdan her teknik ayrıntı için onay isteme: güvenli ve geri alınabilir çözümleri ADR ile seç, uygula. Ancak ücretli harcama, dış hesaba erişim, gerçek müşterilerin verisine dokunma, üçüncü taraf sözleşmesi imzalama, üretimde geri döndürülemez veri silme, marka tescili, canlı ödeme, App Store yayını ve kamuya açık bilgi gönderme için açık insan yetkisi gerekir. Engellendiğinde çevrimdışı/mock/feature-flag yoluyla devam et; gerçek entegrasyon durumunu `BLOCKED_EXTERNAL` olarak raporla.

**Kaynak ve karar hiyerarşisi:** (1) geçerli güvenlik/hukuk/platform kuralları, (2) kullanıcının bu projeye ilişkin açık kararları, (3) bu dosyanın non-negotiable ilkeleri, (4) bu dosyanın teknik varsayımları, (5) Claude'un gerekçeli ADR kararları. Önceki projelerin genel `GOD LEVEL — UNIVERSAL PROJECT INTELLIGENCE, SYSTEM DESIGN & ENGINEERING MASTER PROTOCOL` disiplinini taşı: 22 bölüm mantığı, evidence-first, atomik gereksinim→mimari→kod→test→kanıt, maliyet/riske göre öncelik, bağımsız red-team ve geri alma. Başka projelerin veri şemalarını veya kişisel verilerini kopyalama; yalnız çalışma metodolojisini ve genel mühendislik ilkelerini kullan.

### 0.1 Uygulama emri, hiçbir fazı atlamadan

1. Repository, makine, Xcode, cihaz, araç, izin ve mevcut kod gerçeklik taraması; `docs/audit/REALITY_BASELINE.md` üret.
2. Ürün gereksinimlerini `REQ-*`, kanıtları `EV-*`, testleri `T-*` ve kararları `ADR-*` ile eşle; çatışma/riski `DECISION_REGISTER.md`'de yönet.
3. En büyük bilinmezler için **spike** yap: iPhone'da 3D mesh + kıyafet bindirme; fotoğraftan güvenli sınırlı ölçü; barkod-ürün verisi; yerel kıyafet sınıflandırma ve performans.
4. Tek repo, yerel CI, görsel tasarım sistemi ve test altyapısı kur; fixture ile gerçek uçtan uca en küçük deneyimi üret.
5. Her iş paketini `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → UNIT/INTEGRATION/UI/DEVICE TEST → PERF/PRIVACY → INDEPENDENT REVIEW → EVIDENCE → GATE` döngüsünden geçir.
6. Yalnız `VERIFIED` iş paketine dayanarak sonraki bağımlı paketleri aç. Eksik, çalışmayan, tahminî ve belirsiz şeyleri raporda ayrı tut.
7. iOS P0 v1'i bitir; gerçek cihaz, gerçek fotoğraf örnekleri (izinli), gerçek erişilebilirlik testi, tekrar üretilebilir release build ve TestFlight için kanıt paketini oluştur.
8. Retail pilot ve Android'i ayrı bağımlılık kapılarıyla başlat; P0 tüketici deneyimini bozacak kapsam büyümesine izin verme.

**Durdurma koşulları:** Kritik mahremiyet sızıntısı; yanıltıcı beden/uyum iddiası; model eğitimi veri hakkı belirsizliği; App Review ihlali; gerçek kullanıcıya zararlı tutarsızlık; çalışmayan build. `STOP_THE_LINE` aç, güvenli yolu uygula, kanıtla, sonra devam et.

---

# 1. KURUCU VİZYONU, GERÇEK PROBLEM VE ÜRÜN FELSEFESİ

## 1.1 Tek cümlelik vizyon

**İnsanlar mağazada kabin kuyruğunda daha az beklesin, satın almadan önce kıyafetin olası görünümünü ve beden uygunluğunu daha bilinçli değerlendirsin, her sabah kendi gardırobundan hava ve plana uygun kombin seçsin; bütün bunları beden görüntüsü, kişisel ölçüleri ve fotoğrafları cihazlarında kalarak yapsın.**

## 1.2 Çözülen işler (jobs-to-be-done)

- **Mağazada:** "Etiket veya barkodu okutayım; bu ürünün ne olduğunu, bana olası bedenini ve stilini birkaç saniyede anlayayım. Yine denemek gerekiyorsa akıllıca karar vereyim."
- **Evde:** "Yarın İstanbul'da yağmur ve serinlik var; dolabımdaki temiz, uygun ve birbiriyle uyumlu şeylerden bir kombin öner."
- **Kendi üstümde:** "Döndürebildiğim, oranlarını düzeltebildiğim, cinsel özellikleri vurgulamayan nötr 3D avatar üzerinde kıyafetin genel siluetini göreyim."
- **Dolabımda:** "Fotoğraflarımdan izin verdiklerimle dolabı kurayım, tekrar eden ürünleri ayırayım, yıkamada olanları hesaba katayım."
- **Mağazada işletme olarak:** "Deneme kabini yoğunluğunu ve yanlış beden seçimlerini veriye dayanarak azaltma fırsatını test edeyim; ürün verimi kontrol edeyim; müşterinin özel beden bilgisini görmeyeyim."

## 1.3 Özgün değer hipotezi

`PERSONAL FIT INTELLIGENCE × PRIVATE 3D IDENTITY × REAL WARDROBE × RETAIL PRODUCT TRUTH × CONTEXTUAL STYLING`.

Bu bileşenlerin birleşimi stratejidir; **tek başlarına yeni değildir**. Rekabet avantajı: güvenilir ürün veri zinciri, cihazda kalıcı özel beden profili, yüzeyde açık güven seviyesi, giyim kullanım döngüsü ve mağazaya ölçülebilir değer. İleride rakip benzer özellik ekleyebilir; sürdürülebilir farkı entegrasyon kalitesi, doğrulama veri seti, düşük sürtünme ve güven oluşturur.

## 1.4 Mutlak kurallar

- `Privacy by architecture, not by privacy policy`: Beden profili, kişisel görseller, mesh, fotoğraf etiketleri, dolap, giyim geçmişi **varsayılan olarak cihazda**.
- **No fake precision:** Sıradan iki boyutlu fotoğraftan bel/basen/omuz çevresi santimetre hassasiyetiyle biliniyormuş gibi gösterilmez.
- **No fake fabric physics:** Genel 3D giydirme görsel rehberdir; sertifikalı kumaş simülasyonu değildir. Gerçek düşüş için ürün kalıbı/material verisi gerekir.
- **No automatic gender/identity inference:** Fotoğraftan cinsiyet, etnisite, yaş, biyometrik kimlik, beden sağlığı, cinsel özellik veya sağlık sonucu çıkarma ve etiketleme YASAK.
- **No nudity:** Nötr gri, sade, non-sexual, kapalı body-suit / mannequin yüzeyi. Anatomik mahrem detay, genital/çıplak grafik veya cinsiyete özel mahrem yüzey asla render edilmez. Gönüllü anatomik **oran kaydırıcıları** yalnız giysi uyumuna yardım eder.
- **One-touch manual override:** Kullanıcı her otomatik tanımayı düzeltebilir, her öneriyi değiştirebilir, veri gizliliğini yönetebilir.
- **Deterministic before AI:** Ürün kimliği, beden tablosu ve güvenlik kuralları algoritmik; ML yalnız sınırlandırılmış tanıma/tahmin görevlerinde.
- **Abstain by design:** Ürün kimliği, beden veya gerçekçi görünüm için yeterli veri yoksa "bilmiyorum / yaklaşık" demek güvenilir cevaptır.
- **No dark patterns, body shaming, beauty scoring:** "Güzel/çirkin, ideal beden" puanı yok; stil uygunluğu kullanıcı tercihine ve hava/etkinliğe göre açıklanır.
- **Offline core:** Dolap, avatar, kayıtlı ürünler, yerel kombin ve kayıtlı görünüm internet olmasa da çalışır.
- **Retail separation:** İşletme müşteri fotoğrafını, avatar mesh'ini, vücut ölçüsünü, giyim geçmişini veya fotoğraf erişim durumunu varsayılan olarak alamaz.
- **Measured operational impact:** "Kabin sırası azalır" sloganı değil, mağaza pilotunda bağımsız ölçülecek hipotezdir; kimi ürünlerde fiziksel prova zorunlu kalabilir.

## 1.5 Hedef kullanıcı segmentleri

1. Mağazada beden ve kombin konusunda kararsız alıcı.
2. Gardırobunu etkin kullanmak isteyen yetişkin.
3. Sabah kıyafet seçimine zaman harcamak istemeyen çalışan/öğrenci.
4. Stil, kumaş, konfor ve hava koşulları arasında denge arayan kişi.
5. Retail partner: butik, hazır giyim zinciri, e-ticaret/hibrid mağaza.
6. Mağaza ürün yöneticisi/entegratör: kalite/GTIN/variant verisini sağlar.

**Kapsam dışı P0:** Çocukların fotoğraflarından beden modeli, sağlık/vücut kompozisyonu teşhisi, yüz tanıma ile kişi teşhisi, otomatik reklama beden profili aktarımı, izinsiz galeri tarama, garanti kalıp uyumu, ödeme/marketplace, sosyal ağ.

## 1.6 Başarıyı ifade etme biçimi

- **Consumer North Star:** Haftalık **tercih edilen ve gerçekten giyilen** faydalı kombin sayısı; yalnız öneri gösterimi değil, kişinin "giydim" beyanı ile izlenir.
- **Retail North Star (ayrı):** `fitting-room visit reduction` ve `time-to-confident-decision` sadece kontrollü gözlem veya mağaza verisiyle; karşılaştırmalı dönüşüm/return rate ve müşteri güvenini birlikte izleme.
- Başlangıç hedefleri **önerilen hipotezlerdir, ölçülmüş sonuç değildir**: İlk kıyafet ekleme < 30 sn hedef; mevcut kayıtlı dolaptan günün kombinini görüntüleme < 2 sn sıcak açılış hedef; düşük performans cihazda kabul testine bağlı. Beden isabeti ve kabin tasarrufu için sayısal vaat ancak pilot verisiyle.

---

# 2. ARAŞTIRMA, REKABET, TEKNİK GERÇEKLİK

## 2.1 03 Kasım 2026 itibarıyla rekabet haritası / teyit düzeyi

| Ürün | Kamuya açık güçlü yön | WEARFORM için boşluk/hipotez | Kanıt niteliği |
|---|---|---|---|
| **Alta / Alta Daily** | Dijital gardırop, havaya göre günlük stil, avatar üzerinde sanal prova ve takvim; resmi site ücretsiz diyor | Aynı özellikleri kopyalamak yeterli değil; güvenilir yerel beden bilgisi + mağaza GTIN bağlantısı + veri sınırları | Resmi ürün sayfası: https://www.altadaily.com/ |
| **Acloset** | Fotoğraftan dolap ve kombin/sanal deneme odaklı | Fotoğraftan çıkarımın güven ve veri hakları; gerçek mağaza SKU entegrasyonu araştır | https://www.acloset.app/ (erişilebilirlik ve güncel özellik ayrıca doğrulansın) |
| **Whering** | Gardırop ve planlama/topluluk | B2B ve offline veri sahipliği ile ayrışma fırsatı; mevcut işlevleri doğrula | https://whering.co.uk/ |
| **Indyx** | Dolap, giyim takibi, kişisel stil | Günlük basitlik ve mağaza anı akışı | https://www.myindyx.com/ |
| **Doji** | Kişiye benzeyen görüntü ve sanal giyim deneyimi iddiası | Mahremiyeti koruyan parametre avatarı vs. fotogerçekçi görüntü dengesi | Resmi mağaza/ürün sayfası ayrıca bağımsız kontrol edilecek |
| **Google Doppl** | Google'ın deneme ürünüydü | **30 Nisan 2026'da uygulama kapanmış**; güncel aktif rakip gibi gösterme | https://support.google.com/labs/answer/16537062?hl=en |
| **Google Shopping virtual try-on** | Ürün listesi üzerinde fotoğrafa dayalı prova | Üçüncü taraf alışveriş kataloğu vs. kişisel cihaz içi 3D dolap | Resmi Google yardım ve ürün kapsamı tekrar doğrula |
| **Walmart/3DLOOK/True Fit/Perfect Corp** | Perakende ürün verisi, tahmini beden/AR/try-on veya B2B servisler | Entegrasyon ve lisans fiyatlarını incele; hiçbir özel API'yi izinsiz kullanma | Resmi sözleşmeler ve dokümantasyon ancak doğrulanınca kabul |

**Rakip analizinin dürüstlük notu:** Bütün rakiplerin kaynak kodunu, gerçek dönüşüm oranını, model altyapısını, veri saklama uygulamasını bilmiyoruz. Araştırma raporu `VERIFIED_PUBLIC / THIRD_PARTY_CLAIM / UNKNOWN` etiketleri taşır. Uygulamaların güncel fiyat/özelliklerini Claude bağımsız olarak lansmandan önce tekrar kontrol eder. Rakip ekranlarını kopyalamak yasak; yalnız genel deneyim ilkeleri değerlendirilebilir.

## 2.2 Apple tarafından doğrulanmış yapı taşları

- `PhotosPicker`: seçilen öğelere izin verir, fotoğraf kütüphanesi izni gerektirmez. Tüm fotoğrafları kendiliğinden tarama değildir. https://developer.apple.com/documentation/swiftui/view/photospicker%28ispresented%3Aselection%3Amaxselectioncount%3Aselectionbehavior%3Amatching%3Apreferreditemencoding%3A%29
- `PhotoKit`: gelişmiş kütüphane erişimi açık ve kapsamlı izin ister, sınırlı erişim senaryosu desteklenir. https://developer.apple.com/documentation/photokit/delivering-an-enhanced-privacy-experience-in-your-photos-app
- `Vision`: insan duruş noktaları, kişi ayrıştırma, barkod ve OCR; **bunlar doğrudan 3D beden ölçüsü motoru değildir**. https://developer.apple.com/documentation/vision , https://developer.apple.com/documentation/vision/vndetecthumanbodyposerequest
- `Core ML`: cihazda tahmin ve performans optimizasyonu; herhangi modelin otomatik olarak hazır/uygun olduğu sonucu çıkmaz. https://developer.apple.com/documentation/coreml
- `RealityKit` / `RealityView`: iOS'ta yerel 3D sahne. https://developer.apple.com/documentation/realitykit/realityview
- `WeatherKit`: güncel/saatlik hava verisi; internete ve yetkilendirmeye bağımlılık olabilir, offline cache ayrıdır. https://developer.apple.com/weatherkit/
- `Vision barcode`: barkod değerini okur; tek başına üreticinin gizli beden tablosunu veya kıyafetin kumaş/kalıp bilgisini sağlamaz. https://developer.apple.com/documentation/vision/detecting-objects-in-still-images
- `Apple App Review 5.1`: veri minimizasyonu, üçüncü taraf paylaşım izni, sınırlı erişim tercihi, geri çekilebilir izin ve hesap silme dikkate alınır. https://developer.apple.com/app-store/review/guidelines/
- `GS1`: GTIN varyant bilgisine işaret eder ve her renk/beden varyantı ayrı GTIN gerektirebilir; **GTIN sayısının kendisinden kumaş, beden ve ürün adını matematikle çıkaramazsın**. Yetkili katalog eşleştirmesi gerekir. https://support.gs1.org/support/solutions/articles/43000734469-what-kind-of-information-is-linked-to-the-gs1-identification-key-

## 2.3 Teknik fizibilite matrisi — doğru sözleşme

| İstek | Gerçekçi yöntem | Güvenilirlik sınırı | P0 kararı |
|---|---|---|---|
| Fotoğraflardaki kıyafetleri bul | Kullanıcının seçtiği fotoğraf grubu üzerinde yerel segmentasyon/sınıflandırma | Karışık arka plan, kapalı giysi, aynı fotoğrafta çok kişi | Evet, seçim ve düzeltme ile |
| Kişinin tam 3D bedenini otomatik çıkar | Fotoğraf yönlendirmesi + kişi maskesi/2D keypoints + boy ölçeği + parametrik mesh | Tek foto derinlik/çevre ölçüsü vermez; giysi vücudu gizler | Sınırlı avatar başlangıcı; manüel düzeltme zorunlu |
| Bel/basen/omuz ölçüsü | Kullanıcı ölçüm girişi + tahmin aralığı, görüntüden düşük güvenli öneri | Tıbbi/terzi ölçüsü değildir | Kullanıcı girişi; tahmin yalnız araştırma flag'i |
| Kişinin gerçek yüz/saç aynılığı | İsteğe bağlı saç stil kategorisi/renk, manuel seçim; gerçek yüz tekstürü ayrı değerlendirme | Mahremiyet/biyometri ve cihaz kaynağı | Basitleştirilmiş yüzsüz avatar, manuel saç |
| Barkoddan mağaza kıyafetini tanı | Kamera→EAN/UPC/GTIN→partner katalog→varyant/kalıp/beden | Partner veri yoksa "tanınmadı" | Pilot veri/mock + manüel bilgi |
| Kumaş fiziksel davranışı | Malzeme profili + garment mesh + simülasyon/uygun pipeline | Tam fiziksel doğruluk yok; profesyonel kumaş verisi gerekir | Basitleştirilmiş yaklaşık görsel |
| Galata Kulesi'nde 3D görünüm | Lisanslı sabit fotoğraf/360 çevre + sahnede avatar kompozit | Fotogerçekçi canlı coğrafi/ışık doğruluğu iddiası yok | 1 örnek lisanslı/dekoratif sahne veya orijinal üretilen sahne |
| Hava durumu + kombini seçme | WeatherKit + deterministik konfor kuralları + tercih/ranking | Hava tahmini belirsiz, kişisel hissiyat farklı | Evet + neden göster |
| Kirli/temiz takibi | Kullanıcının "giydim / yıkadım / yıkamada" etkileşimi + şüphe belirtisi | Otomatik kirli olduğunu bilemez | Evet, nazik öneri; otomatik kesin etiket yok |
| Gerçek kabin kuyruğunu azaltmak | Beden güveni + ürün uygunluğu + Retail pilot A/B/karşılaştırmalı ölçüm | Kullanıcı yine fiziksel denemek isteyebilir | B2B pilot P1; iddia kanıtlanmazsa pazarlama yapılmaz |

## 2.4 Zorunlu araştırma dosyaları

`docs/research/COMPETITOR_MATRIX.md`, `TECH_SPIKES.md`, `LICENSE_AND_MODEL_REGISTRY.md`, `PLATFORM_CAPABILITY_MATRIX.md`, `STORE_DATA_SOURCE_MATRIX.md`, `MEASUREMENT_EVIDENCE_REVIEW.md`, `B2B_PILOT_DESIGN.md` oluştur. Kime ait olduğunu bilmediğin fotoğrafı/3D modeli, Pinterest ürün görselini, rakip ürün datasını ticari eğitim seti olarak kullanma.

---

# 3. PLATFORM VE MİMARİ KARARLARI

## 3.1 Karar: yerel iOS önce, eş zamanlı iki platform değil

**ADR-001 — Native iOS (P0):** Swift/SwiftUI, Swift Concurrency, Vision, Core ML, RealityKit, AVFoundation, PhotosPicker, CoreLocation (isteğe bağlı), WeatherKit, StoreKit yalnız gelir kapısı açılınca. Apple ekosisteminde ilk ürünün fotoğraf/ML/3D, erişilebilirlik, enerji/termal davranışını tek platformda gerçekten doğrulamak, Flutter veya React Native soyutlamasında kritik native 3D ağırlığını gizlemekten iyidir.

**ADR-002 — Android future:** P1/P2 pilot başarılı olup v1 ölçüldükten sonra Kotlin/Jetpack Compose + CameraX/ML Kit + TensorFlow Lite/ONNX Runtime Mobile + Filament/SceneView benzeri gerçek lisanslı motor değerlendirilir. Core domain sözleşmeleri `schemas/` altındaki dil-agnostik şemalarda durur; Swift kullanıcı arayüzünü ve RealityKit implementasyonunu Android'e 'paylaşıldı' diye pazarlamayız. Çoklu platform ancak cihaz kanıtını ayrı sağlarsa `GOD LEVEL` kabul edilir. UI'nun eşleşmesi pixel-copy değil native kalite.

**ADR-003 — Local-first modular monolith:** Consumer mobil app tek uygulama içinde `FeatureModules + PlatformServices + DomainCore`. Başlangıç için kullanıcı hesabı, mikroservis, Redis, Kafka, vektör DB, sürekli çalışan LLM, bulut görüntü işleme altyapısı YOK. Retail B2B için P1'de dar kapsamlı servis ve konsol.

**ADR-004 — Blender asset production, not runtime:** Blender açık kaynak içerik oluşturma ve batch mesh/rule/LOD/rig/shape-key pipeline'ında. iPhone içine Blender gömülmez. Dönüşüm testi ile `USD/USDZ` / RealityKit uyumlu varlıklar, ölçülmüş poligon/materyal/bellek bütçesi, lisans hakları. `glTF → Blender → USDZ` gibi hatlar varsayım değil prototipte doğrulanacak. Her asset'te source/license/version/hash/mesh scale/rig/UV metadata.

**ADR-005 — Offline model inference:** Apple Vision + küçük ölçülü lisanslı on-device Core ML modelleri. Yüksek maliyetli üretken video/draping v1'e sokulmaz. Modelin dağıtım ağırlığı, RAM, sıcaklık, pil, sürüm ve hakları sayısal izlenir.

**ADR-006 — App local persistence:** `SwiftData` veya kontrollü SQLite adaptörü arasından veri bütünlüğü ve migration POC sonucu seçim yap. Gerekliyse SQLite/GRDB gibi bağımlılığı lisans-uyumluluk ve bakım testinden sonra al. Fotoğraflar/mesh/image features private Application Support dosyalarında, dosya koruması; metadata göçleri testli. iCloud otomatik paylaşım/sync KAPALI. Kullanıcının açıkça isteyeceği şifreli export P1 olabilir.

**ADR-007 — Network contract:** Hava durumu isteğinde kullanıcı seçtiği şehir veya isteğe bağlı yaklaşık konum; Retail product lookup'ta GTIN gönderilebilir ancak beden profili ve fotoğraf gönderilemez. Ağ katmanı egress testleri, network-off testi ve bağımsız privacy audit.

**ADR-008 — Privacy analytics:** Başlangıçta üçüncü taraf analytics/ads SDK YOK. Yerel sayaçlar; gönüllü, toplulaştırılmış ve kişisel olmayan sistem hata raporları ayrı açık opt-in/anonimleştirme risk incelemesi olmadan sunucuya gitmez.

## 3.2 Mantıksal şema

```text
                    CUSTOMER iPHONE — DEVICE TRUST BOUNDARY
┌─────────────────────────────────────────────────────────────────┐
│ SwiftUI / Design System / Accessibility / Localization (TR+EN)  │
│                                                                 │
│ Home Today • My Wardrobe • Scan / Try-On • My Avatar / Settings │
│     │             │                  │                │         │
│  ContextEngine  WardrobeEngine   ProductIdentity    AvatarUI    │
│     │             │                  │                │         │
│  OutfitRanker  WearCareEngine     Local FitEngine    3D Engine  │
│     │             │                  │                │         │
│  Weather cache ◀──── LocalData / local Model Registry ────────▶ │
│     │                              │ Vision + Core ML / USDZ    │
│  City weather gateway             Local file protection        │
└─────┼──────────────────────────────┼────────────────────────────┘
      │ forecast only               │ GTIN/partner lookup only
      ▼                             ▼
  WeatherKit               PUBLIC/RETAIL LOOKUP ADAPTER
                                      │
                          ┌───────────┴──────────────┐
                          │ P1 Retail API (tenant)    │
                          │ Catalog • Variants       │
                          │ Size charts • Materials   │
                          │ No personal avatar/body  │
                          └──────────────────────────┘
```

## 3.3 Modüller ve tek sahiplik (canonical ownership)

| Modül | Tek sorumluluk | Ana tipler |
|---|---|---|
| `AppShell` | navigasyon, izin bağlamı, depolama başlatma | `AppRoute, AppLifecycle` |
| `DesignSystem` | tipografi, token, kartlar, durum gösterimleri | `Theme, UIComponents` |
| `WardrobeDomain` | kıyafet item, kategori, renk, malzeme, sezon | `Garment, ClosetItem, MaterialProfile` |
| `MediaIngest` | PhotosPicker, kamera, local crop/detect | `ImportJob, MediaProvenance` |
| `VisionInference` | segmentasyon, sınıflandırma, OCR/barcode | `ModelRun, Prediction<T>` |
| `AvatarDomain` | parametrik ölçüler, beden profili, mesh | `BodyProfile, AvatarRevision` |
| `AvatarRenderer` | RealityKit scene, mesh/asset cache, garment overlay | `RenderRequest, PreviewQuality` |
| `ProductCatalog` | GTIN/SKU, catalog source, identity/confidence | `ProductVariant, SourceAssertion` |
| `FitEngine` | beden tablo/kalıp/tercih uyumu, gerekçe | `FitAssessment, FitEvidence` |
| `ContextEngine` | yer/saat/hava/aktivite, kullanıcının beyanı | `DailyContext` |
| `StylistEngine` | deterministik filtre + tercih ağırlıklı sıralama | `OutfitCandidate, RecommendationReason` |
| `WearCareEngine` | giyme/yıkama/temizlik durumu, öneri | `WearEvent, LaundryState` |
| `PrivacyVault` | yerel saklama, silme, export, veri egress sınırlama | `ConsentRecord, DeleteReceipt` |
| `RetailConnector` | partner katalog/snapshot, cache, fail closed | `RetailProductSnapshot` |
| `EvidenceKit` | local diagnostics, performans/golden test, provenance | `EvidenceArtifact` |

Modüller arası tipler `DomainContracts` içinde; UI doğrudan SQL, Vision veya ağ çağırmasın. Bir `BodyProfile` alanı Retail API istemcisi tarafından serialize edilemesin (compile-time DTO boundary + egress payload tests). Her kritik karar ADR kaydıyla.

## 3.4 Örnek klasör düzeni (repo gerçekliğine göre uyarlanır)

```text
wearform/
  WEARFORM_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v1.0.md
  README.md
  docs/
    audit/REALITY_BASELINE.md
    decisions/ADR-001-native-ios.md ...
    product/PRD.md  UX_SCREENS.md  REQUIREMENTS.csv  TRACEABILITY.md
    research/COMPETITOR_MATRIX.md  DATA_RIGHTS.md  ML_EVALUATION.md
    privacy/THREAT_MODEL.md  DATA_FLOW_MAP.md  DELETION_LEDGER.md
    retail/RETAIL_SPEC.md  PILOT_PROTOCOL.md
    evidence/  release/  incidents/
  apps/
    ios/Wearform.xcodeproj
    ios/WearformApp/
    ios/Packages/{DomainContracts,WardrobeDomain,VisionInference,
                  AvatarDomain,AvatarRenderer,ContextEngine,
                  FitEngine,StylistEngine,PrivacyVault,UIComponents}/
    ios/WearformTests/
    ios/WearformUITests/
  assets/
    blender/{sources,scripts,quality_gates}
    usd/{base_avatar,garments,scenes,manifests}
    licenses/ASSET_LICENSES.md
  models/{manifests,evaluation,conversion}
  schemas/{product-variant.schema.json,privacy-egress.schema.json,...}
  services/retail-api/                  # P1 gate only
  scripts/{bootstrap,check,export_assets,evidence}
  .github/workflows/{ios-ci.yml,asset-ci.yml}
```

## 3.5 Deployment çevreleri

`LOCAL_MOCK` P0 ilk dikey dilim; `LOCAL_FIXTURE` testler; `RETAIL_STAGING` P1 veri; `RETAIL_PRODUCTION` ancak sözleşme, güvenlik ve pilot sonrası. Consumer app hiçbir sunucu olmadan başlatılabilmeli. Feature flags derleme/yerel ayar veya imzalı konfigürasyon; kapalı özelliği açan UI yok.

---
# 4. İNSAN MERKEZLİ TASARIM: ÜRÜN YÜZEYLERİ, GÖRSEL DİL, ETKİLEŞİM

## 4.1 Steve Jobs × Steve Wozniak prensibi

**Karmaşık sistem görünmez; karar görünür.** Bir kullanıcı normal akışta "AI agent", "mesh", "confidence posterior", "SKU resolver" veya "model pipeline" görmez. Kullanıcı `Bugün bunu giy`, `Üzerimde gör`, `Mağazada tara`, `Dolabım` der. Bilimsel belirsizlik ise gerektiğinde anlaşılır Türkçeyle görünür: `Beden önerisi: M — kalıp verisi eksik`, `Bu görsel bir önizleme`, `Bugün yağmur bekleniyor`.

**Do not equate fancy with premium.** Birincil CTA belirgin; ağır animasyon değil 60 fps mümkünse akıcı, enerji tüketimi ölçülü. Her ekranda bir baskın kullanıcı eylemi. Modal yığılması, 12 sekmeli navigasyon, haftalık abonelik dayatması yok.

## 4.2 Navigasyon mimarisi

**iPhone P0 ana gezinme: 3 sekme + 1 global eylem**

1. `Bugün` — tek bakışta hava + kombinin + "Giydim" + yarın.
2. `Dolabım` — kıyafetlerim, kombinlerim, temiz/yıkamada.
3. `Benim Modelim` — nötr 3D avatar, oran düzenleme, mahremiyet/ayarlar.
4. **Global yüzen / sekme içi birincil eylem `Tara`** — kamera veya barkod, ürün ekle veya üstümde gör. Erişilebilirlik için global eylemin tüm sekmelerde aynı yerde olmasına karar ver; iOS tab bar ile uyum ve safe area kontrolü.

`Yarın` Bugün kartı içinden; `Kombin Stüdyosu` kart detayından; `Mağaza Modu` Tara sonrasından; `Retail Partner` tüketici uygulamasında ayrı karmaşık tab değil.

## 4.3 Görsel kimlik: tasarım token sözleşmesi

**Marka adı** nihai değil. Nötr, modern, sakin, unisex, teknolojik ama mağaza vitrini kadar sade.

| Token | Light | Dark | Kullanım |
|---|---|---|---|
| `surface.base` | `#F7F7F5` | `#111315` | ana zemin |
| `surface.card` | `#FFFFFF` | `#1B1E20` | kart |
| `text.primary` | `#17191B` | `#F5F6F6` | ana metin |
| `text.secondary` | `#667078` | `#ACB4B8` | ikincil |
| `brand.ink` | `#283D46` | `#8DAFBE` | etkileşim, vurgu |
| `accent.warm` | `#CEB79C` | `#B69A7B` | moda/stil sıcaklığı (az) |
| `border.hairline` | `#E7E8E5` | `#303638` | ayrım |
| `avatar.silver` | `#AEB3B8` | `#A3AAB0` | nötr model yüzeyi |
| `status.ok` | `#217354` | `#83D3AE` | anlamlı durum |
| `status.caution` | `#946A23` | `#E9C077` | belirsizlik |
| `status.error` | `#A23738` | `#F1A09E` | hata |

**Kullanım kısıtları:** Anlamı yalnız renge yükleme; status metin+ikon ile. Dynamic Type ile ölçeklenebilir boyutlar; SF Pro platform fontu (Apple kısıtlarına uyum), başlıklarda `system` serif değil modern sans; üçüncü taraf yazı tipi lisansı gerekmedikçe yok. Type scale: Large 34pt semibold, Page 28pt semibold, Section 20pt semibold, Card 17pt semibold, Body 16pt, Caption 13pt, Meta 12pt; iOS semantik text styles tercih edilir. Corner: küçük 12, kart 20, preview 24. Grid 4pt; yatay gutter 20pt; kart boşluğu 16–20pt; hit target en az 44×44pt. Shadow hafif/erişilebilir; renkli glass ve sürekli blur yalnız anlamlı ve ölçülebilir alanlarda.

**Avatar estetiği:** Nötr mat gümüş-gri, sahne rengiyle yarışmayan; minimal anatomik çizgi/contour, gizli mahrem alan, anatomik detaysız bodysuit. Kullanıcı bedeni "değerlendirme nesnesi" değil, kişisel siluet. Beden oranları farklılıklarına saygılı. Saç seçimi gönüllü; gri siluet ana yüzey kuralını bozmaz. Saç ve temel baş oranları opsiyonel, fotogerçekçi yüz üretimi kapalı.

**Motion:** 160–240ms buton/durum, 280–400ms kart genişleme, 3D dönüş parmakla kontrol. Yüksek performans varsa 3D girişte 0.5s kısa sahne; `Reduce Motion` altında kesintisiz ve statik fallback. Haptics: tek anlamlı olayda hafif, başarısız barkodda ses/haptic spam yok. Ses varsayılan kapalı.

**Splash/Launch:** Uygulama launch screen'i statik / sistem uyumlu logo + arkaplan. Ağ/sunucu bekletme yok, yapay uzun animasyon yok. Sonrasında birinci açılışta çok kısa "Dolabını tanı. Kombinini gör. Kontrol sende." giriş ekranı; `Hemen başla`, `Nasıl çalışır?`. Logo kavramsal yön: iç içe iki kıyafet konturu + 3D orbit izi; diğer markaların birebir logosu kopyalanmaz. SVG/vektör kaynakları ve App Icon/light/dark/tinted varyantları hazırla.

## 4.4 Ekran envanteri, tekil sözleşmeler

Her ekranın `content`, `primary action`, `secondary action`, `data dependencies`, `empty/loading/error/offline/no-permission/low-confidence states`, `VoiceOver labels`, `testIDs`, `event` sözleşmesini `docs/product/UX_SCREENS.md` içinde yap. Bu özet doğrudan uygulanacak asgari şarttır.

| ID | Ekran | Ana yüzey / eylem | Kritik durum/kurallar |
|---|---|---|---|
| UX-01 | Native Launch | Statik marka mührü | <1 sn illüzyonu için sahte loading yok |
| UX-02 | Welcome | Üç fayda, "Başla" | Kayıtsız devam var; ilk açılışta fotoğraf izni sorulmaz |
| UX-03 | Privacy Choice | Cihaz içi işleme açıklaması | `Fotoğraf seç`, `Kamerayla ekle`, `Şimdilik atla`; galeri tam izin dayatma yok |
| UX-04 | Quick Setup | Şehir (manuel), stil/konfor, isteğe bağlı boy, temel ölçüler | Reddet/atla; kullanıcı cinsiyet belirtmeden avatar ve kombin mümkün |
| UX-05 | Today | Büyük bir outfit kartı, hava mini-kartı, yarın, `Giydim` | Hava yoksa mevcut offline hava göstergesi zaman damgalı; yeni kullanıcıda örnek dolap |
| UX-06 | Outfit Detail | Kıyafet parçaları + `Neden?` + alternatif + `Üzerimde gör` | Veri yetersizse "öneri için daha fazla parça"; tahmin etiketli |
| UX-07 | Wardrobe | Kategori filtreleri, temiz/yıkama chipleri, fotoğraf kartları | 0 öğe / 2000 öğe durumunda sanallaştırma; arama |
| UX-08 | Add Garment | Fotoğraf çek/seç, otomatik ayır, renk/kategori doğrula | Her tespit onay ve düzenlemeye açık |
| UX-09 | Garment Detail | Foto, malzeme, kalıp, beden, mevsim, bakım, giyim | Kaynak/provenance göster; malzeme "tahmini" ayrı |
| UX-10 | Scan | Kamera vizörü + çerçeve + flash + barkod/etiket modları | Kamera izin reddi, offline, bulanık, birden çok barkod, haptic |
| UX-11 | Product Result | Marka/ürün/renk/beden/beden tablosu + güven | Yanlış eşleşmede `Bu ürün değil`; GTIN olmadan uydurma ürün gösterme |
| UX-12 | Try-On Studio | 3D avatar, rotate, zoom, değiştir, tekrar beden seç | `Görsel önizleme ≠ kesin beden`; düşük cihazda 2D/static fallback |
| UX-13 | Avatar Setup | Gri model + boy ve oranlar + ölçü bilgi kartları | Fotoğraf şart değil; body-shaming yok |
| UX-14 | Avatar Edit | Manuel gövde/omuz/kalça/kol/paça oran slider | Gerçek cm verisi ile illüstratif oran değişimini ayır |
| UX-15 | Tomorrow Planner | Gün/etkinlik, şehir/hava, temiz ürün filtresi | Hatırlatma local notification yalnız izinle |
| UX-16 | Wear & Laundry | `Giydim`, `Yıkamada`, `Temiz`, `Havalandırıyorum` | "Kirli" varsayım; elle düzelt ve undo |
| UX-17 | Scene Preview | Lisanslı şehir sahnesi, avatar gölge/ışık | Sahne temsilî; gerçek canlı kamera değil; konum/ışık uydurma iddiası yok |
| UX-18 | Outfit Calendar | Gün bazlı gerçek giyim ve planlanan kombinler | Gizli yerel kayıt; geçmişi sil/tek gün düzelt |
| UX-19 | Settings/Privacy | Foto izinleri, kilit, veri sil, model indir, export (P1) | Kalıcı silme onayı, bekleyen işlem, başarı kanıtı |
| UX-20 | Help & Trust | Önizleme doğruluğu, ölçü sınırı, SSS, destek | Kesin vaat yok; model sürümü ve veri kaynakları açıklanabilir |
| UX-21 | Retail Store Mode (P1) | Partner ürün bilgisi, fit etiketi, stok bilgisi (izinli) | Stok gerçek zamanlı iddia ancak partner API sağlarsa |
| UX-22 | Retail Console (P1) | Katalog, varyant, ölçü verisi, pilot KPI | Beden/foto/kullanıcı mesh görme yetkisi YOK |

**Surface contract pattern:** `UX-ID, route, job, entry/exit, data, states, accessibility, logging policy, failure recovery, screenshots, tests, privacy`. Dosyada eksiksiz her ekran için ayrıntı üret.

## 4.5 Başlıca deneyim akışları

### Akış A — Yeni kullanıcı, fotoğraf vermeden (P0 MUST)

`Aç → Başla → Şehir veya Atla → 3 ürün örneği ile Bugün → Avatar demo → isterse boy/ölçü ekle → kendi kıyafetini ekle`. Kayıt/email zorunlu değil, ilk hedefi tamamlayamadan >3 onboarding adımı yok. Demo kıyafetlerim kendi gerçek gardırobumla karışmasın (`sample=true`).

### Akış B — Fotoğraflarımdan dolabımı oluştur (P0 MUST)

`Dolabım → + → Fotoğraf seç → iOS PhotosPicker (çoklu seçim) → yalnız seçilen dosyaları geçici memory'de yerel işle → aday kıyafetleri ayır → duplike uyar → onay/düzelt → kaydet → görülebilir ilk kombin`. Toplu sistem foto kütüphanesini arka planda tarama yok. Sonraki isteğe bağlı `Tam kütüphane taraması` ayrı P2 izin/uyumluluk/profiling riski ve kullanıcı değer denetimine bağlı; varsayılan reddet.

### Akış C — Mağazada barkod (P0 local demo, P1 real retail)

`Tara → kamera ile EAN/UPC/QR oku → GTIN formatını doğrula → partner veya yerel demo katalog eşleştir → ürün varyantı ve beden tablosu açık → beden profili varsa FitEngine yerelde hesapla → 3D önizleme veya fotoğraf kartı → Sonuca güven derecesi + neden → istersen mağazada fiziken dene`. Partner bilgi yoksa güvenilir fallback: manuel beden/etiket fotoğrafı al veya yalnız stil görünümü, hiçbir sahte ürün verisi.

### Akış D — Yarın ne giyeceğim (P0 MUST)

`Bugün → Yarın → konum/şehir seç → hava durumu saat aralığı + etkinlik (isteğe bağlı) → temiz ve mevcut kıyafetler filtrele → 1 ana öneri + 2 alternatif → neden kartı → planla → local hatırlatıcı (isteğe bağlı) → ertesi gün Giydim`. Hava yoksa son güncel tahminin tarihi göster; eskiyse "güncel değil" ve nötr mevsim önerisi.

### Akış E — Kirli-temiz (P0 MUST)

`Giydim` eylemi giyim olayını oluşturur ve ürünlerin `wear_count_since_wash` sayısını artırır. Ürün tipi, terleme gibi **kullanıcının beyan ettiği** opsiyonel aktivite, kullanım süresi ve bakım etiketine göre `yeniden kullanmadan önce kontrol et` önerisi gösterilir. Otomatik "kirli" kesin hükmü verilmez. `Yıkamada` seçilen ürünler kombin dışı; `Temiz` yeniden kullanılabilir. Geri al/yanlış işaretlemeyi düzelt ve aynı event'i iki kez işleme (idempotency).

### Akış F — Benim Modelim (P0)

`Benim Modelim → Gri basitleştirilmiş nötr avatarı gör → boy gir (isteğe bağlı) → omuz/kalça/uzuv oranlarını değiştir → kaydet → kıyafet önizlemesine dön`. Fotoğrafla otomatik model yalnız P1 deneysel bir modül olarak ve iki foto + kalibrasyon + açık belirsizlik ile; P0 için telefon üzerinde stabil kullanıcı düzenlemeli 3D model öncelikli.

### Akış G — Lisanslı şehir sahnesi (P1)

`Stüdyo → Sahne değiştir → İstanbul/Galata konsept sahne → beklenen sıcaklık/saat etiketli → 3D avatar kompozit → ışık ve ölçek ayarla → ekran görüntüsü yalnız kullanıcı isterse lokal kaydet`. Sahne lisanslı özgün 2.5D/3D asset olabilir; gerçek mekânda canlı varmış gibi yanıltıcı AR iddiası yok.

## 4.6 Örnek üst düzey wireframe metinleri

```text
┌─────────────────────────────┐
│ Günaydın                    │
│ İstanbul · 14° · Yağmur     │
│                             │
│  [ 3D / kıyafet hero kartı ] │
│                             │
│ BUGÜN SENİN İÇİN            │
│ Trençkot + kazak + denim    │
│ Serin ve yağmurlu hava      │
│ [Üzerimde gör] [Alternatif] │
│                             │
│ YARIN                       │
│ Hazırladığın kombin  →      │
│                             │
│ [Bugün] [Dolabım] [Modelim] │
│                  [Tara +]   │
└─────────────────────────────┘
```

```text
┌─────────────────────────────┐
│ ‹    ÜZERİMDE GÖR           │
│     [ 3D NÖTR AVATAR ]      │
│       ↻ döndür / + zoom    │
│                             │
│   [Üst] [Alt] [Ayakkabı]   │
│   [S / M / L]              │
│                             │
│ ÖNİZLEME · YAKLAŞIK         │
│ Kalıp verisi eksik          │
│ [Neye göre?]                │
│ [Kombine ekle]              │
└─────────────────────────────┘
```

## 4.7 Erişilebilirlik ve evrensellik

TR/EN başlangıç, uluslararası sayı/ölçü birimleri ve yerelleştirme katmanı (`cm/in`, `°C/°F`, EU/US beden tablosu). RTL test altyapısı ileride. VoiceOver tüm kontrol durumlarını söylesin; Dynamic Type XL ve XXL yerleşimi bozulmasın; yüksek kontrast ve renk körlüğü testi; reduced motion, low power mode ve live 3D yerine anlaşılır statik fallback; tek elle kullanım; izin reddinde görev tamamlanabilsin. Beden algısı, engellilik, ampütasyon, farklı duruşlar veya kıyafet tercihleri nedeniyle model otomatik olarak kullanıcıyı dışlamasın. Body shape özelleştirme P0 sınırlıysa `Avatar bu vücut tipini tam temsil etmeyebilir` notu ve 2D dolap yolu her zaman açık.

## 4.8 Tasarım üretim ve inceleme kapısı

- `design/tokens.json` tek kaynak, SwiftUI semantik renk/stil; asla her ekranda hardcoded RGB.
- Figma (varsa), SwiftUI preview ve çalışan Simulator **aynı görsel sözleşmeyle**; referans PNG'ler repo içinde lisanslı.
- iPhone küçük ve büyük ekran; light/dark, yüksek Dynamic Type, keyboard, RTL smoke, 200+ ürün, offline, empty/error/loading için snapshotlar.
- Mockup güzel diye `PASS` yok: **gerçek app screenshot + dokunulabilir UI test** zorunlu.
- Görsel sistem `UX-QA`: hizalama, safe area, 44pt, kart taşması, gecikme, VoiceOver, geri hareketi, contrast, performans gözlemi.

---

# 5. AVATAR: BEDEN PROFİLİ, FOTOĞRAF, BLENDER VE GERÇEK 3D

## 5.1 Üç ayrı gerçeklik katmanı

1. **Body Profile:** Kişinin kendisinin girdiği ölçüler ve tercihleri; boy, omuz, göğüs/torso, bel, basen, iç bacak, ayak gibi isteğe bağlı alanlar. Hassas veridir. Eksik değer `unknown`; `0` veya uydurma tahmin değil.
2. **Avatar Geometry:** 3D nötr mesh, oran kaydırıcıları, poz ve kıyafet bağlama; temsilî vücut silueti. Gerçek ölçüleri birebir gösterdiği iddia edilmez.
3. **Fit Evidence:** Ürünün beden tablosu, giysi fiziksel ölçüleri, kalıp açıklaması ve kullanıcının beden profilinden hesaplanan sınırlı uygunluk değerlendirmesi. `size suggestion` hiçbir zaman salt render sonucu değildir.

Tüm UI metinlerinde bunları karıştırma. Avatarın görsel olarak dar görünmesi, ürünü kesin küçük yapmaz. Beden önerisinin sayısal skoru yalnız verinin yeterli olduğu durumlarda ve belirsizliğiyle.

## 5.2 Parametrik nötr karakter tasarımı

- Temel `BASE_NEUTRAL` mesh, yetişkin oran aralığı; düşük/orta/yüksek LOD.
- Anatomik detay yok: giysi altındaki vücut `grey full bodysuit`, ayrıntısız göğüs/kalça/hassas bölge, genital/nipple geometrisi yok.
- Renk `avatar.silver`, mat PBR, yumuşak ışık. Gövde herhangi cinsiyet seçimi olmadan işlev görür.
- Manual style controls: yükseklik, omuz genişliği, üst beden, bel, kalça, gövde boyu, kol uzunluğu, iç bacak uzunluğu, bacak formu; yüz/saç: baş büyüklüğü, saç kısa/orta/uzun (P1), saç rengi. Sadece garment fit/geometri ile ilişkili kontroller ana ekranda.
- Kullanıcı `kıyafet kalıbı için beden tipi` seçmek isterse kadın/erkek/unisex ürün kategorisi **giyim tablosu etiketidir**, kişinin kimliği veya biyolojik cinsiyet tahmini değildir. Kişi her mağaza ürün kategorisini seçebilmelidir.
- Serbest kaydırıcılar deformasyonu fiziksel olarak bozarsa clamp; ölçek değil anatomik boyutlar kontrollü blendshape/bone morph. Geometry self-intersection/clipping test.
- P1 gönüllü bir örnek fotoğrafı avatar yüzüne yapıştırmak yasak varsayılan; yüz benzerliği ve çocuk/farklı kişi fotoğrafı privacy review gerektirir.

## 5.3 Fotoğraftan kişisel avatar oluşturma — araştırma ve aşama ayrımı

**P0:** `manuel parametrik avatar` + boy/ölçü girişi ve isteğe bağlı seçilen fotoğraf üzerinden **silüet oranları hakkında bilgi amaçlı önizleme**. Foto olmadan tamamlanabilir. Kullanıcı görselini hiçbir zaman buluta yükleme.

**P1 research gated:** Fotoğraf çekim kılavuzu: önden ve yandan, tek kişi, ayakta, düz ışık, sade fon, bedene oturan ancak **mahremiyet açısından uygun günlük kıyafet**, kamera belirli mesafede, bilinen boy veya kalibrasyon işareti. Ölçü tahmininde perspektif, kıyafet kalınlığı, poz, farklı cihaz/lens ve oklüzyon belirsizliği ayrı hesaplanır. Kullanıcının açıkça düzeltmesiyle sonuç kabul. Fotoğraf çekimine devam etmek istemezse tüm süreç manuel çalışır.

**P2 conditional:** Lisanslı 3D human mesh fitting/learned model araştırması (SMPL/SMPL-X veya alternatifi seçilecekse **ticari kullanım lisansı ve model veri hakkı belgelenmeden** eklenmez). Geniş vücut tipleri, yaş aralığı, ten rengi değil geometri, kıyafet/poz etkisi ve engellilik varyasyonunda hata denetimi. P1/P2 maskesi "body scan" veya `cm accurate` diye satılmaz; yasal ve bilimsel doğruluk kanıtı yoksa `illustrative avatar` olarak kalır.

**Yasak:** Yalnız fotoğraftan kesin kilo, BMI, yaş, cinsiyet, sağlık durumu ve mahrem vücut ölçülerini kullanıcı istemeden çıkarmak. Bir kişinin kameralı yüzünü başka kişinin kimliğine eşlemek; gizli identity recognition; 3D çıplak birebir kopya üretmek.

## 5.4 Avatar profili veri sözleşmesi (örnek)

```swift
struct BodyProfile: Codable, Identifiable {
    let id: UUID
    var heightCm: Double?             // User-provided, unknown allowed
    var shoulderWidthCm: Double?
    var chestCircumferenceCm: Double?
    var waistCircumferenceCm: Double?
    var hipCircumferenceCm: Double?
    var inseamCm: Double?
    var armLengthCm: Double?
    var preferredFit: FitPreference    // slim / regular / relaxed / unspecified
    var bodyControlValues: [String: Double] // artistic, NOT medical measurement
    var source: MeasurementSource      // manual / experimental-assist
    var avatarRevision: Int
    var updatedAt: Date
}
```

**Data invariant:** Her alan için birim, giriş kaynağı, doğrulama durumu, tarih, düzeltme tarihi; `heightCm=180` değerini modelden hesaplanan kesin bilgi diye gösterme. UI `cm` ile mesh scaler arasında sürümle kontrollü kalibrasyon.

## 5.5 Blender ↔ RealityKit pipeline

1. Blender'da orijinal temel mesh oluştur veya ticari kullanım lisansı uygun mesh kullan, source proof sakla.
2. Anatomik detay içermeyen grey-suit mesh, rig skeleton (biped), body blendshape listesi, neutral T/A pose belirle.
3. Giysi familyaları: üst (`shirt, knit, jacket, coat`), alt (`pants, jeans, skirt`), tek parça (`dress, jumpsuit`), ayakkabı, aksesuar. Her biri garment category shape rig + collision layer + silhouette layer.
4. Kaynak garment görseli tek fotoğraftan doğrudan kusursuz 360 derece geometry üretmez. P0 her kategori için **temsilî 3D mesh + yaklaşık renklendirme/doku** ve ürün fotoğrafı yan kartı. Doku eşleşmesi kullanıcının onayı ile.
5. İhracat scripti `scripts/export_assets.py` (Blender Python CLI) geliştir; kaynak `.blend`, `.fbx/.gltf` (varsa), `.usdz` final, manifest, SHA-256, ölçü/scale, material, pose/rig, triangle count, PBR texture sizes, thumbnails.
6. Xcode pipeline 3D entity'yi yükle, rotate/pinch, giyim parçasını seç, LOD ve ışık presetleri; iPhone gerçek cihazda görsel ve peak memory testi.
7. Collision/penetration testi: texture clipping, body-garment clipping, hem lengths, z-fighting, normal map artifacts, animation seam. İki farklı body paramında ve her kıyafet grubunda screenshot.
8. Yüksek kalite yoksa sistem `approximate 3D` ve ürünün gerçek 2D fotoğrafını gösterir. `exact` veya yanlış bağlamda uydurma detay yok.

**Şimdilik profesyonel kumaş fiziği yok:** Gerçek dinamik kumaş dökümü için kalıp parçaları, panel dikişleri, giysinin materyal parametreleri, gerilme/esneme katsayıları, insanın poz/hareket modeli ve collision gerekir. Bu veri partner tarafından verilmediyse generative texture veya salınım animasyonu `gerçek kumaş davranışı` değildir. P2 research spike, kalite kanıtı olmadan active feature değil.

## 5.6 Render kalite seviyeleri

`LEVEL_0`: 2D kıyafet kartı + avatar poster image (tüm cihazlarda).  
`LEVEL_1`: static neutral 3D avatar + kategori rig, basit overlay.  
`LEVEL_2`: skeleton + fitted/deformed garment proxies, birkaç poz.  
`LEVEL_3` (P2): product geometry/physics data varsa fiziksel yaklaşım validasyonu.  

Dinamik adaptasyon: model kapasitesi, RAM, ısı, pil düşük mod, SceneKit/RealityKit capability. `QualitySelector` deterministik, kullanıcıya sessiz veya anlaşılır hız düşürme; kapanma/kill yok; düşük cihazda kullanıcı yine kombin seçebilsin. `FPS, first-frame, peak-memory, model-load-time, battery/thermal` cihaz bazında ölç.

## 5.7 Poz, ışık ve sahne

3D hareket `front/side/back`, serbest rotate, zoom, kullanıcı girdiği boyla oran kalibrasyonu. 2–3 doğal poz; kaynak mesh ile türetilmiş pozlarda kıyafet clipping denetimi. Fotoğraf avatar arka planı yerine **orijinal çizilmiş** açık stüdyo background P0. İsteğe bağlı P1 `CityScene`: İstanbul/Galata tasarlanmış sahne (hak sahipliği, fotoğraf lisansı, modellerin mülkiyeti ve kullanım hakkı kaydedilecek), hava yağmurlu/serin ise renk/ışık/yağmur partikülleri temsilî; ekran üstünde açık etiket. Gerçek zamanlı AR gezinti, gerçek mekanın santimetre doğru 3D taraması ve anlık güneş/kalabalık simülasyonu kapsam dışı.

## 5.8 Test soruları (zorunlu)

- Avatar istenmeyen beden detaylarını gösteriyor mu? `MUST NO`.
- Kişi fotoğraf olmadan avatar kullanabiliyor mu? `MUST YES`.
- Manüel slider aşırı değerleri mesh'i bozar mı? `MUST NO`.
- Ölçüler kamera veya Retail loguna sızar mı? `MUST NO`.
- 3D görüntü ürün fiziksel ölçüsü yokken kesin uyarı üretir mi? `MUST NO`.
- Zayıf cihazda UI donmadan statik fallback veriyor mu? `MUST YES`.
- Ürün görseli giysinin bilinmeyen sırt yüzünü gerçekmiş gibi üretir mi? `MUST NO`.

---

# 6. DOLAP ve GİYSİ TANIMA MOTORU

## 6.1 Veri toplama biçimleri

**MUST:** tek foto çek; çoklu seçilen fotoğraflardan toplu import; barkoddan ürün; manuel ürün.  
**SHOULD P1:** mağaza katalogdan ürün ekle, linkten metadata yalnız izinli kaynak, bakım etiketi OCR ve e-posta sipariş importu yalnız kullanıcı açık isteği/uyum sonrası.  
**DEFERRED:** telefonun tüm Fotoğraflar kütüphanesini zaman içinde izinsiz sınırsız tarama, sosyal medya hesabı bağlama, üçüncü taraf mağaza ekranını scrape etme.

## 6.2 Ingest pipeline

```text
USER_SELECTED_PHOTO
  → EXIF orientation normalize (only local processing)
  → faces/bystanders mask or avoid as needed (do not save non-user faces)
  → person/garment candidate detection
  → segment clothing regions / photo background removal
  → category classifier + color + pattern + material candidate
  → candidate review UI (confidence + correction)
  → duplicate candidate detection (perceptual hash + embedding, local)
  → consented selected crop persisted, original untouched
  → searchable index / stored local
```

Özellikle **material recognition**: Görüntüyle `cotton vs polyester`, %100 kumaş oranı, su geçirmezlik, gramaj, esneklik, ısı yalıtımı kesin belirlenemez. Fotoğraf örüntüsü sadece `visually looks like knit/denim` adaylığı verir; marka ürün etiketi OCR veya partner verisi daha yüksek kanıt; `tag/manual verified` öncelikli. Gösterim: `Kumaş: denim görünümlü (tahmini)` veya `Etikette: %98 pamuk (OCR, kontrol et)`.

## 6.3 Deduplikasyon ve kimlik doğrulama

Aynı kıyafet birden çok fotoğrafta olabilir; `ClosetItem` tek fiziksel varlık, `PhotoObservation` çoğul; benzer renk/kalıp iki ayrı kıyafet de olabilir. Silme `FotoObservation` ve `ClosetItem` ayrımı. Kullanıcı "Bu aynı kıyafet" / "Hayır ayrı" onayı. Dedup threshold test corpus ile ve versioned; düşük güven otomatik birleştirme yok.

## 6.4 Dolap durumları

`AVAILABLE_CLEAN`, `WORN_CHECK`, `AIRING`, `IN_LAUNDRY`, `UNAVAILABLE`, `ARCHIVED`. `WORN_CHECK` otomatik "pis" değildir: kullanıcı `Giydim` → materyal/bakım kuralı + kullanım sayısına dayalı nazik ipucu; `AVAILABLE_CLEAN` elle doğrulanır. `IN_LAUNDRY` önerilerden çıkar; `ARCHIVED` geçmişte kalır. Her transition idempotent event; geri al işlevi; offline device time değişimi testli.

## 6.5 Bakım zekâsı (kural ağacı)

- İç giyim/çorap için daha sık yıkama önerisi; kullanıcının tercihine göre; katı sağlık talimatı vermek yerine hijyen önerisi.
- Kot/ceket/kazak gibi parçalar kullanım sayısından kesin kirli ilan edilemez. `Havalandır` veya `Kontrol et` ifadesi; bakım etiketi ve kullanıcının alışkanlığı daha yüksek öncelik.
- Kir ve kokuya dair telefon sensörü olmadan otomatik çıkarım yok.
- Kapalı giyim geçmişi kimseyle paylaşılmaz. Ürünün bakım talimatı partner verisinden geliyorsa provenance göster.
- `WearEvent` çift gönderimde sayacı artırmasın; aynı event ID replay safe.

## 6.6 Veri modelinde kıyafet envanteri

Kıyafet: kullanıcı kimliği yerine local GUID, kategori/subkategori, renk (Lab/HSL + etiket), desen, katman, malzeme `assertions[]`, fit/cut, style tags, mevsim/iklim suitability, wash symbols, current state, wear count, lastWorn, lastCleaned, purchase/source, photos, product link/GTIN, variation, user overrides, extraction model version, confidence, archivedAt. Kullanıcının etiketine öncelik ver; tahmini alanı kesin etiketle overwrite etme.

---

# 7. BARKOD, SKU, ÜRÜN VERİSİ VE PERAKENDE GERÇEKLİĞİ

## 7.1 Üç ayrı algılama stratejisi

1. **Barcode fast path:** AVFoundation/Vision ile EAN-8, EAN-13, UPC-A, QR/GS1 Digital Link vb. parse, checksum/format, normalized GTIN; partner katalog lookup. Her barcode bir ürünün markasını/giysi tipini kendi başına vermez.
2. **Label OCR fallback:** Marka, beden, materyal, bakım etiketinden yalnız görüntülenen bilgi; olası yanlış okumayı kullanıcı düzeltsin.
3. **Visual candidate search:** Cihazdaki lisanslı/partner catalogue thumbnail embedding'leri arasında benzer görsel önerisi; aynı görünüm kesin aynı ürün değil. Uygun izin/veri yoksa yalnız `generic garment category`.

## 7.2 GTIN eşleştirme kuralı

`GTIN -> PartnerProductVariant` doğrulanmışsa göster. `GTIN -> public source` ancak hak/kalite doğrulanmışsa. `Barcode unknown -> label/text/photo/manual` ile ürün tarama yap ama ürün iddiasında bulunma. Marka/model `vision guess` = kesin ürün tanıma değil. Ürünün renginin ve bedeninin ayrı varyant olduğuna dikkat. Yanlış varyant müşteri zararına yol açacağı için GTIN ve mağaza SKU eşleşmesi deterministik testli.

## 7.3 Partner veri kalitesi hiyerarşisi

`PARTNER_VERIFIED_VARIANT + timestamp` > `LICENSED_CATALOG` > `VISIBLE_LABEL_OCR + user confirmation` > `USER_DECLARED` > `CV_ESTIMATE` > `UNKNOWN`. Kaynak güvenilir ama eski olabilir; stok ve fiyat daha kısa TTL; beden/kalıp tabloları versiyonlu. Çatışmada `partner verified` ancak kullanıcı fiziksel etiketle çelişirse uyarı ve user override.

## 7.4 Perakende ürün şeması (özet)

```json
{
  "gtin": "string-or-null",
  "partnerId": "uuid",
  "productId": "string",
  "variantId": "string",
  "brand": "string",
  "displayName": "string",
  "category": "outerwear|top|bottom|dress|shoes|accessory|other",
  "merchantSizeLabel": "M",
  "sizeSystem": "EU|US|UK|brand-specific",
  "color": "string",
  "fabricComposition": [{"fiber":"cotton","percent":70}],
  "fabricProperties": {"stretch":"low|medium|high|unknown","weightGsm":null},
  "garmentMeasurementsCm": {"chestWidthFlat":null,"waistFlat":null,"inseam":null},
  "sizeChartVersion": "string-or-null",
  "fitCut": "slim|regular|oversized|unknown",
  "productImageRightsId": "asset-license-id",
  "sourceId": "partner-feed-v1",
  "sourceUpdatedAt": "ISO-8601",
  "confidenceClass": "PARTNER_VERIFIED"
}
```

Actual API schema strict (nullable fields, constraints, import version, variant ID unique per partner); yukarıdaki bir sözleşme örneğidir. Retail endpoint response hiçbir kullanıcı body data taşımaz.

## 7.5 Fail-closed product resolver

`RESOLVE_BARCODES` yalnız whitelisted partner host/verified license; network error -> `CATALOG_UNAVAILABLE` + local cache `lastSynced`; `gtin_conflict` -> seçim/düzeltme; `variant_without_size_chart` -> fit sonucu `UNKNOWN`, stil önizlemesi mümkün; sistem kullanıcıyı yanlış güvenle fiziksel provadan vazgeçirmesin.

## 7.6 Birinci pilot veri stratejisi

- Manuel izinli 20–50 temsilî SKU fixture ile kamera demosu.
- İlk gerçek entegrasyon için 1–3 gönüllü mağaza, her birinden **fiyat/variant/görsel hakları/size chart** izin belgeleri; prod URL/API anahtarları user-provisioned.
- P0 ürün testleri gerçek mağaza markası taklidi değil, `DEMO PRODUCT` açık etiketli özgün fixture.
- İleride 3D clothing CAD ve fabric chart paylaşan partner için özel doğruluk kanalı; olmayan mağazaya aynı vaat yok.

---

# 8. OUTFIT STYLIST ENGINE: HAVA, KUMAŞ, ŞEHİR, TERCİH, TEMİZLİK

## 8.1 Girdiler ve gerçek dünya bağlamı

`forecast`: sıcaklık, hissedilen, yağmur olasılığı/miktarı, rüzgâr, nem, UV (varsa), tahmin geçerlilik aralığı, sağlayıcı, timestamp. `context`: şehir/özel seçilen geolocation, dışarı çıkış saati, içeride/dışarıda, aktivite, gündelik/resmi, kıyafet yönetmeliği, planlanan süre (isteğe bağlı). `person`: rahatlık tercihi, soğuğa duyarlılık (gönüllü), sevilen renkler, katman/fit tercihi, sürtünme duyarlılığı vb. `closet`: mevcut, temiz, katmanlı, malzeme kanıtları, geçmişte giyilenler, kullanıcı beğenisi.

Astroloji/"enerji" alanı isteyen kullanıcı için **opsiyonel kişisel mood/style chooser** olabilir; bilimsel hava ve kumaş tavsiyesini astrolojik kesinlik gibi göstermeyin. XRAI, diğer projeler veya fotoğraf/davranış datası ile otomatik veri paylaşımı yok. P0 varsayılan stil motivasyonu `nasıl hissetmek istiyorsun? rahat / canlı / sade / resmi` ve tamamen gönüllü.

## 8.2 Adım adım deterministik algoritma

```text
1. Gather context at user-selected city/time.
2. Read forecast with freshness and quality class.
3. Filter hard exclusions: in laundry, unavailable, explicit no-go,
   unsuitable dress requirement if user entered.
4. Generate valid garment combinations by layer compatibility and category.
5. Score each candidate using declared, versioned feature rules.
6. Select diverse top 3, avoid near duplicate outfits.
7. Explain up to 3 human-readable reasons with facts+uncertainty.
8. User accepts/edits; feedback is stored only on device.
9. Optional lightweight rank model learns voluntary preferences locally.
```

## 8.3 Örnek açıklanabilir ağırlıklı skor, **ürün kararı değil başlangıç deney önerisi**

```text
S = 0.32 × weather_comfort
  + 0.22 × activity_dress_match
  + 0.18 × fit_preference
  + 0.13 × color_style_harmony
  + 0.10 × freshness_and_availability
  + 0.05 × wardrobe_rotation
```

Tüm alt skorlar 0..1'e normalize; `availability` zorunlu filtre, skorda yalnız kalite etkisi. Bu değer `sana %94 yakışır` olarak gösterilmez. Kullanıcıya istersen `Hava için uygun`, `Planına uyuyor`, `Temiz`, `Uzun süredir giymedin` gerekçeleri göster. Öğrenilen model varsa A/B testi ile baseline'dan anlamlı biçimde iyi olduğunun kanıtı gerekir; model olmadan çalışan kural motoru must-have.

## 8.4 Kumaş/katman mantığı (kurallı, belgeli)

- Isı rahatlığı tek başına sıcaklığa bağlı değil: rüzgâr, yağmur, nem, aktivite, süre ve kişinin beyanı; `material` bilinmiyorsa kategori varsayılanı düşük güvenle.
- Örneğin 10–15°C ve yağmur tahmininde mevcut suya dayanıklı dış katmanı öner; gerçek su geçirmezlik sertifikası yoksa `suya dayanıklı` deme.
- Aşırı sıcak/rüzgâr/soğuk için fizyolojik güvenlik iddiası değil, genel pratik öneriler; kritik hava uyarısı WeatherKit/ülke meteoroloji uyarı kaynağına atıf, asla tıbbi tavsiye.
- İç/dış kullanım, kıyafet kodları, hava durumu geçerliliği metadata ile.

## 8.5 Kullanıcı geri bildirimi

`Loved`, `Wore`, `Skipped`, `TooWarm`, `TooCold`, `TooTight`, `TooLoose` / `WrongFabric`, `WrongColor`, `NotMyStyle`. Geribildirim kişisel profilin kurallarını değiştirir; otomatik "bedenin yanlış" mesajı yok. Kararlar loglandıktan sonra undo / forget history. Adaptasyonun etkisi model/sürüm ve açıklanabilir neden halinde. LLM stylists P2 ve bu ihtiyaç doğrulanmadan yok; remote LLM kişisel foto/beden verisi alamaz.

## 8.6 Planlama, bildirim ve zaman

Local notification kullanıcı istediğinde `yarınki kombinin hazır` gibi hatırlatma; hava gerçek zamanlı yeniden değerlendirme mümkün değilse bildirimde sahte kesin tahmin yazma. Gün/şehir/zaman değişince cache invalidate; DST/time-zone/geolocation/no-network testleri; gece saatlerinde spam yok; notifications kapalıyken app ana işlevi devam eder.

---
# 9. FIT ENGINE: BEDEN VE KALIP UYGUNLUĞUNUN DÜRÜST HESABI

## 9.1 Kesin ayrım: stil, görünüm ve fiziksel uyum

- **Style compatibility:** Renk, form, bağlam ve kişinin beyan ettiği zevkleri; herhangi beden ölçüsüne gerek yok.
- **Visual preview:** 3D proxy garment'ın avatar üzerindeki görünümü; gerçek kumaş simülasyonu veya tam kalıp uyumu değildir.
- **Size recommendation:** Kullanıcının **isteyerek girdiği** ölçüler ve mağazanın güncel beden tablosuna göre hesaplanabilir; kaynak yoksa yalnız genel yönlendirme.
- **Garment fit assessment:** Ürünün gerçek teknik ölçüleri, esneklik/doku/kalıp, toleranslar, beden profili, fit tercihi ve iade/prova geri bildirimi gerekir; eksikse `INSUFFICIENT_EVIDENCE`.

## 9.2 Fit karar sözleşmesi

```swift
enum FitVerdict: String, Codable {
    case sizeSuggestion             // Size chart supports suggestion
    case possibleFit                // Limited evidence; verify in store
    case insufficientEvidence       // No supported estimate
    case conflictingEvidence        // Sources disagree
}

struct FitAssessment: Codable {
    let productVariantId: String
    let verdict: FitVerdict
    let suggestedMerchantSize: String?
    let evidence: [FitEvidenceRef]  // partner size chart; user-entered size
    let missingInformation: [String]
    let fitPreferencesApplied: [String]
    let limitations: [String]
    let modelAndRulesVersion: String
    let computedAt: Date
}
```

**Hard invariant:** `suggestedMerchantSize != nil` ancak chart/measurement evidence standardı geçtiyse; `missing size chart` ise `insufficientEvidence`. Ürün özelindeki `S` her markada eş ölçü değildir. `EU 38` dönüşümü kategori/marka ve beden sistemi olmadan yapılmaz.

## 9.3 Hesap akışı ve güven seviyesi

```text
A. Does product variant exist & is identity verified?
    no → abstain; B. only style preview if generic mesh available.
B. Is there a relevant brand+category+sex-neutral chart for this variant?
    no → no numeric merchant size (unknown).
C. Which body measurements were user-entered/confirmed?
    absent → ask optional 1–3 fields OR no recommendation.
D. Is the data comparable (unit/measurement definition/garment vs body)?
    no → explanation with abstention.
E. Combine size chart with fit preference and documented garment ease rules.
F. Multiple plausible sizes? show options, uncertainty and why.
G. Never show "100% uydu", "kesin olur"; ask physically verify when unsure.
```

`FitConfidence` için `VERIFIED_SOURCE`, `PARTIAL_SOURCE`, `UNKNOWN`, `CONFLICT`; kesin "uygunluk %98" vermek yasak. P2 ancak gerçek ölçü-hata validasyonuyla kalibreli olasılık tahmini üretirse numeric probability düşünülebilir; o zamana kadar açıklanabilir kategori.

## 9.4 Fit değerlendirme veri seti

Gönüllü yetişkinler, farklı beden dağılımları, farklı boylar, hareket kabiliyetleri, form/kalıp çeşitleri, markalar ve ürün türleri. Gerçek kıyafet ölçüsü (profesyonel yöntemle); gönüllünün kendi ölçüleri; fiziksel giyimden sonra konfor/fit geribildirimi. Doğrudan tanımlayıcı fotoğraflar geliştirici veri setine varsayılan yüklenmez. Dış katılımcı varsa bilgilendirilmiş onam, silme, ticari veri lisansı, ayrı veri koruma planı. Ölçüm hata metrikleri `MAE/MedAE/P90/error by garment & body cohort`, coverage/abstention, top-1 size accuracy, calibration; alt gruplar arası fark. Model kendi değerlendirme setinde eğitilmez; holdout/signed dataset hash.

---

# 10. VERİ MİMARİSİ, ŞEMALAR, OLAYLAR VE YAŞAM DÖNGÜSÜ

## 10.1 Veri sınıflandırması

| Sınıf | Örnekler | Saklama/işleme | Egress |
|---|---|---|---|
| `DEVICE_SECRET` | beden ölçüsü, avatar mesh, kişisel fotoğraf, giyim geçmişi | device vault, FileProtection, encrypted device storage | **Varsayılan sıfır** |
| `DEVICE_PRIVATE` | gardırop görselleri, stil tercihleri, kıyafet notları, yerel eventler | device | sıfır veya kullanıcı tarafından manuel export |
| `LOCATION_CONTEXT` | kullanıcının seçtiği şehir, isteğe bağlı yaklaşık koordinat | kısa ömürlü hava cache | yalnız WeatherKit gerekli konum isteği |
| `PRODUCT_PUBLIC` | GTIN, ürün adı, beden tablosu, partner marka | local cache + lisanslı Retail API | lookup için minimum GTIN |
| `OPERATIONAL_META` | build, model version, isteğe bağlı anonim teknik hata | local-first; izin varsa telemetry | sınırlı, açık sözleşmeyle |
| `RETAIL_TENANT` | mağaza SKU, fiyat, fiziksel ölçü, stok | partner API + katı tenant ayrımı | partnerin kontrollü erişimi |

## 10.2 Yerel şema (normalleştirilmiş öneri)

`BodyProfile`, `AvatarRevision`, `ClosetItem`, `GarmentImage`, `GarmentAssertion`, `PhotoImportJob`, `ProductMatch`, `ProductVariantCache`, `Outfit`, `OutfitItem`, `PlannedOutfit`, `WearEvent`, `LaundryEvent`, `LocationPreference`, `WeatherSnapshot`, `StyleFeedback`, `PermissionRecord`, `PrivacyDeleteLedger`, `ModelVersion`, `AssetManifest`, `ErrorDiagnosticLocal`.

- `ClosetItem` 1:N `GarmentImage`, `GarmentAssertion`; `Outfit` M:N `ClosetItem` via `OutfitItem`.
- `BodyProfile` 1:N `AvatarRevision`, active revision one. Ölçü kaynağı `MANUAL`, `USER_CONFIRMED_OCR`, `EXPERIMENTAL_ESTIMATE` (bu kayıt UI'da kaynak olarak görünür).
- User unknown field `NULL`. Timezone-aware `Date` + selected IANA timezone for daily wearing, daylight saving tests.
- Tanınan kişilerin kimlik/fotoğraf face embeddings tutulmaz. Sınıflandırma için gereken embedding `GarmentEmbedding` ise local, versioned ve silinebilir.
- Fotoğraf importunda orijinal PHAsset'a erişim geçici; yalnız seçilmiş ve kırpılmış garment crop saklanır. Gerekmediğinde EXIF GPS silinir; orijinalin kaynağına geri bağlantı zorunlu değil.
- `GarmentAssertion` sınıfı: `key, value, confidenceClass, author, sourceRef, sourceTime, wasEditedByUser, modelVersion`; kullanıcı düzenleme sonrası otomatik yeni tahmin kullanıcının kararını üzerine yazamaz.

## 10.3 Örnek SQL (karar sonrası adapte et)

```sql
CREATE TABLE closet_item (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  laundry_state TEXT NOT NULL CHECK (laundry_state IN
    ('AVAILABLE_CLEAN','WORN_CHECK','AIRING','IN_LAUNDRY','UNAVAILABLE','ARCHIVED')),
  sample INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  archived_at TEXT
);
CREATE TABLE wear_event (
  id TEXT PRIMARY KEY,
  closet_item_id TEXT NOT NULL REFERENCES closet_item(id),
  event_date TEXT NOT NULL,
  event_type TEXT NOT NULL,
  source_event_id TEXT NOT NULL UNIQUE,
  is_undone INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE garment_assertion (
  id TEXT PRIMARY KEY,
  closet_item_id TEXT NOT NULL REFERENCES closet_item(id),
  field_key TEXT NOT NULL,
  value_json TEXT NOT NULL,
  provenance TEXT NOT NULL,
  confidence TEXT NOT NULL,
  user_verified INTEGER NOT NULL DEFAULT 0,
  model_version TEXT
);
CREATE INDEX idx_closet_state ON closet_item(laundry_state, archived_at);
CREATE INDEX idx_wear_item_date ON wear_event(closet_item_id, event_date);
```

**SQL bir örnektir;** migration, transaction, body vault tabloları, cascading deletion, referential integrity ve index planı ilk repository kararında tamamlanacak. P0 üretimde kullanıcıya sunulacak uygulamada yeni migration önce backward/forward smoke ve restore senaryosunda testlenir.

## 10.4 Tipli olay makinesi

```text
ImportJob:
 CREATED → VALIDATING → LOCAL_PROCESSING → NEEDS_REVIEW → COMMITTED
       └─→ FAILED_RETRYABLE ─→ VALIDATING
       └─→ CANCELLED → SCRUB_TEMP_FILES

ProductLookup:
 CAPTURED → PARSED → VALIDATED → MATCHED_VERIFIED
                                ├→ MATCHED_PARTIAL
                                ├→ NOT_FOUND
                                ├→ CONFLICT
                                └→ OFFLINE_CACHE / UNAVAILABLE

TryOn:
 IDLE → AVATAR_LOADING → GARMENT_LOADING → RENDERING → READY
                     ↘ DEGRADED_2D / FAILURE_RECOVERABLE

WardrobeWear:
 AVAILABLE_CLEAN → WORN_CHECK → AIRING / IN_LAUNDRY
     ← USER_CONFIRMS_CLEAN ← IN_LAUNDRY
     ↔ UNAVAILABLE; all states → ARCHIVED
```

Every transition: `command → validation → data access → state change → domain event → UI feedback → undo/rollback`; invalid transitions reject, no silent corruption. Event replay idempotent; local clock and timezone perturbations handled.

## 10.5 Canonical JSON event contract

```json
{
  "eventId": "uuid",
  "schemaVersion": 1,
  "eventType": "ClosetItemWorn",
  "entityId": "local-uuid",
  "occurredAt": "2026-11-03T10:10:00+03:00",
  "idempotencyKey": "uuid",
  "origin": "USER_ACTION",
  "payload": {"localDay": "2026-11-03"}
}
```

**Privacy:** Bu local event sözleşmesi otomatik telemetry şeması değildir. Sunucu egress/kayıt/audit için listelenmediği sürece cihazdan çıkmaz. `localDeviceID` ve person ID telemetry'de yok.

## 10.6 Veri saklama ve silme protokolü

- Kullanıcı `Dolabımı sil`, `Modelimi sıfırla`, `Tüm verileri sil` ayrı kapsamlarla kontrol eder; ihtiyacından fazlasını silme.
- Silinen öğeye bağlı thumbnails, masks, local embeddings, temporary media, cached export ve ilgili geçmiş için tutarlı transaction + cleanup. Fotolar uygulamasındaki kullanıcı orijinallerine dokunma.
- Silme sırasında uygulama kapanırsa `DeletionLedger.pending` açılışta devam eder; erişim korumalı, idempotent, testli. Silme öncesi görsel onay; silme sonrası gerçek dosya varlığı/SQLite FK testleri ve `receipt`.
- iOS dosya sistemi / flash wear leveling nedeniyle fiziksel forensic imha iddiasında bulunma; kullanıcıya kapsamı açıklayan mantıksal silme + kriptografik anahtar silme (uygunsa), dosya koruması, backup siyaseti.
- Yerel özel veri ve mesh'in iCloud/cihaz yedeği davranışını **özel olarak test et**; `isExcludedFromBackup` gereken alanlarda uygulanır. Varsayılan iCloud upload olmayacak; şifreli manuel yedek P1.
- İzin geri alma: yeni import yapılamaz, var olan seçili kıyafetler kullanımına devam edecek mi kullanıcıya belirtilir; kullanıcı isterse tamamen sil.

---

# 11. GİZLİLİK, GÜVENLİK, ETİK VE HUKUK

## 11.1 Mahremiyet tehdit modeli

| Tehdit | Saldırı/arıza yolu | Önlem | Kabul kanıtı |
|---|---|---|---|
| Body data leak | Ürün lookup request içinde BodyProfile | Ayrı DTO ve egress allowlist; snapshot test | `T-SEC-001` raw payload check |
| Image exfiltration | 3P SDK, crash log, AI upload | 3P analytics yok; image scrub; deny-by-default network | proxy/packet inspection |
| Gallery overscan | Açık seçim yapılmadan tüm foto erişimi | PhotosPicker limited user selection | permission UI test |
| Wrong-person media | Albümde diğer insanların görüntüsü | Sadece seçili foto, local mask, review; bystander crop save yok | adversarial multi-person dataset |
| Deletion failure | Cache/embedding/thumbnail kalıyor | DeletionLedger + restore/crash tests | forensic logical file checks |
| Backups | iCloud/diagnostic backup senkronu | explicit backup exclusion; key isolation | device backup exercise |
| Unauthorized Retail | başka mağazanın SKU/ölçüsü okunur veya yazılır | tenant scope + RLS or application default deny | negative cross-tenant tests |
| Retail data poisoning | partner yanlış ölçü/GTIN yükler | schema/constraint, dual-validation, rollback | import quarantine |
| Prompt injection | OCR etikette yönerge veya web ürün açıklaması | OCR as data, not commands | adversarial label tests |
| Model supply chain | zararlı veya lisanssız ML/mesh | signed/hash artifacts, SBOM, license and scan | artifact evidence |
| Misleading fit | yanlış beden tavsiyesi | fail-closed chart, confidence, explanation, physical verify | fit golden set |
| Device theft | görüntü/beden verisi açık | file protection, privacy lock opt-in/biometric local auth | locked-device tests |
| Notifications | kıyafet/konum bilgisi kilit ekranda görünür | generic notification text + privacy preview option | lock-screen UI tests |
| UI screenshots | App switcher özel avatarı gösterir | blurred privacy snapshot when backgrounded | lifecycle tests |

## 11.2 İzin ekranları ve mahrem davranış

- Kamera yalnız `Tara` veya `Fotoğraf çek` anında; purpose string göreve özel.
- Foto seçimi sistem PhotosPicker (P0) ve kullanıcı seçimi; tam kütüphane izni talep etme.
- Konum otomatik şart değil: manuel şehir, isteğe bağlı approximate location, denied-state fallback. Precisely locate user not required.
- Bildirim yalnız kullanıcının `Hatırlat` butonu sonrası; kapalıyken core app çalışır.
- Bluetooth/mikrofon/HealthKit/Contacts/Calendar izni P0'da yok.
- Face ID/Touch ID yalnız local vault açma için P1 isteğe bağlı; kişinin cinsiyeti/kimliği için kullanılamaz.
- Her izin için `purpose, data, lifespan, alternative, denial, revocation, deletion` açıklaması; dark pattern yok.

## 11.3 Yerel veri güvenliği

iOS Data Protection `complete` uygun private files; kapanıp açılmada protected-data unavailable handling. Gerekirse Secure Enclave/Keychain'de encryption key; model ağırlıkları ve public assets aynı hassaslıkta olmayabilir. Logging kişisel değerleri otomatik redakte; crash dump ve diagnostics incelenir. TLS outbound; cert pinning default gerekli değil, networking ADR ile threat-based; release config'de ATS bypass yok. Jailbreak algılama tek güvenlik dayanağı değil.

Apple referansları: https://developer.apple.com/documentation/uikit/encrypting-your-app-s-files, https://developer.apple.com/app-store/review/guidelines/ .

## 11.4 Etik ve temsil

- Tüm bedenler için destek iddiası yalnız temsil veri setiyle ölçüldüyse; boy/kilo giren kullanıcıya "sağlıksız" gibi yorum yok.
- Erkek/kadın ürün kategorileri bulunabilir; app'in kişiyi cinsiyetlendirmesi zorunlu değil, ürün kesimleri cinsiyet kimliğiyle eşleştirilmez.
- Avatar köken/ırk/cinsiyet/yaş inference yok. Kullanıcıya cilt veya görünüş konusunda ayrımcı `güzel / çekici / estetik puanı` yok.
- Ürün görüntüsü yanlış yönlendirmemeli: 3D-proxy, fit, kumaş ve city preview üzerinde `yaklaşık` bayrağı; paylaşılabilecek screenshot üzerinde de görünür.
- Genç kullanıcıların fotoğraf/ölçü mahremiyeti daha riskli; ilk lansman 18+ hedef, mağaza yaş beyanı ve hukuki inceleme; çocuk modunu eklemek ayrı major workstream ve guardian/legal compliance.

## 11.5 Hukuki uyumluluk işleri

Türkiye için KVKK, hedeflenen AB pazarı için GDPR, mağaza tarafında ticari veri/marka/görsel telif, tüketicinin yanıltılmaması, Apple gizlilik beyanları, App Store IAP/abonelik kuralları, biyometrik/bedensel verinin hassaslık sınıflaması ve ML model ticari lisansı konusunda hukuki değerlendirme gerekir. Bu dosya hukuk görüşü değildir. `docs/privacy/COMPLIANCE_REGISTER.md` alanları: yargı alanı, risk, hukuki görüş sahibi, etkilenen veri, dayanak, onay, yeniden değerlendirme tarihi, kapanış kanıtı. Gerekirse DPA/DPIA. Kod tamamlanması hukuki uyumu kendiliğinden doğrulamaz.

---

# 12. RETAIL PARTNER: MAĞAZA VERİSİ, KABİN KUYRUĞU VE B2B STRATEJİ

## 12.1 B2B değer teklifi

Mağazaya dijital ürün kartı, bedene özel ve sınırlamaları belirtilen öneri, basit 3D görsel önizleme ve mümkünse daha doğru kabin/beden kararı. İşletme bilmediği müşterinin bedenini öğrenmez. Firma, ürün kimliğini ve stok/kalıp verisini doğrulama karşılığında mağaza deneyimini iyileştirme fırsatı kazanır.

## 12.2 B2B iş modelleri — yalnız hipotez

- **P0:** Ücretsiz consumer pilot, 1–3 mağaza demo veri paylaşımı; ücretli partner gerektirmez.
- **P1:** Retail SaaS aboneliği (mağaza/şube başına katalog, ölçü verisi, yönetim), veya API kullanım bazlı, veya kurulum entegrasyon ücreti; Türkiye'de saha veri toplama sonrası fiyat testleri.
- **P2:** White-label scan/try-on SDK; perakende e-ticaret satış sonrası size-advisory; doğrudan satış komisyonu ancak izin/attribution ve yasal model doğrulanınca.
- **Reddedilen erken model:** Kullanıcı beden profilini mağazalara satmak; third-party advertising feed; hayali affiliate komisyonlarını gerçekleşmiş gelir gibi göstermek.

## 12.3 Perakende tenant mimarisi (P1)

`AuthN` (partner staff identities, sessions), `AuthZ` (least privilege), `Tenant`/`Store`/`Product`/`Variant`/`SizeChart`/`Material`/`InventorySnapshot`/`AssetLicense`, `ImportRun`, `EventAudit`, `PilotAggregate`. İlkte **modüler monolit + PostgreSQL** yeterli. Multi-tenant izolasyonu claim zorunlu her route/sorgu, cross-tenant negative tests. Backend consumer photo/video/body mesh endpoint'i içermez.

## 12.4 API (taslak, uygulamadan önce OpenAPI + security)

```http
GET /v1/catalog/lookup?gtin={gtin}
GET /v1/catalog/products/{partnerProductId}/variants/{variantId}
GET /v1/catalog/products/{partnerProductId}/size-charts/{version}
POST /v1/partner/imports     # partner-auth only; idempotent
GET /v1/partner/imports/{id}/status
GET /v1/partner/metrics/aggregate?from=...&to=...
```

- B2C lookup response only public/listed product fields and licensed images; no user account.
- API signed auth for partner upload; per-tenant rate limit, 429, audit, replay-safe mutation, `Idempotency-Key` for imports.
- Cache version and updatedAt; stale chart client warns and may abstain.
- Stock/fiyat/indirim gerçek partner verisi yoksa `unknown` veya hiç gösterme.
- Aggregate analytics minimum cell threshold ve differential privacy/suppression değerlendirmesi; tekil müşteriyi takip eden store dwell/time istatistiği yok.

## 12.5 Retail onboarding

`Partner application → rights/license acceptance → branch registration → GTIN mapping + variant size charts → sample feed validation → QA errors review → staging scan test → approved live import`. CSV/JSON ingest schema documented; partner products as separate namespace, ETL quarantines invalid GTIN, missing brand, unsupported unit, broken image rights, incomplete size charts; missing data must not be fabricated. B2B portal ilk prototipte sade; ürün bilgisi düzeltme akışı öncelikli, analytics dashboard sonra.

## 12.6 Kabin yoğunluğu pilotu — araştırma tasarımı

**Hipotez H-STORE-01:** Scan+fit görseli bazı mağaza ziyaretlerinde kabin gereksinimini azaltır veya karar süresini kısaltır, iade/yanlış beden riskini artırmaz.

`Baseline` mağaza başına gün/saat mevsimsellik, mağaza trafik yükü, beden/ürün karması, personel ve kampanya farklarıyla ölçülmeli. `Treatment` yalnız gönüllü app kullanan müşteri. Kontrol seçimi: mümkünse randomize kullanıcı veya zaman blokları; seçilim yanlılığını açıkça raporla. Pilot birkaç mağazada, 4–8 hafta **planlama hipotezi**; mağaza izni ve gerçek olay verileri olmadan KPI hesaplama yok.

Metrikler: per-100-shopping-visits fitting room entries, median/90th queue wait (mağaza ölçebiliyorsa), attempted items per decision, time to choice, sale conversion, wrong-size return/exchange rate, user trust/NPS ve `do not use app` reasons. Mahremiyet: ortak camera analytics / yüz tanıma/kişisel takip yok, mağazanın mevcut anonim manuel counters veya izinli aggregate verisi. Müşteri fiziki provadan caydırılmayacak. **Exit criterion:** anlamlı kullanıcı faydası + zarar artışı yok + hukuki/operasyonel maliyet makul; değilse hipotez reddedilir veya ürün yeniden konumlandırılır.

## 12.7 Cihaz ve fiziksel mağaza kısıtları

İç mekan internet kopabilir, barkod parlama/yıpranma, telefon yetersiz pil, kabin dışı yoğun ışık, yanlış varyant, düşük stok, birden çok etiket ve uzun ekran beklemesi. Scanner offline'da cached fixture varsa göster ve `son güncelleme`; desteklenmeyen barkodda manuel ürün bilgisi, kullanıcıyı yanıt almadan çıkmaza sokma. Retail modunda tek eli dolu kullanıcı için büyük tara butonu; titreşimle başarı; kamera kapatıldığında arka planda devam etmez.

---

# 13. GELİR, MALİYET, OPERASYON VE ÜRÜN EKONOMİSİ

## 13.1 Ücretsiz temel kullanım ve değer

**Önerilen fiyatlandırma (karar değil, deney):** Günlük kombin, temel gardırop, manuel avatar, sınırlı görsel deneme ücretsiz, reklam/sensitif data monetizasyonu yok. Premium ancak gerçekten maliyetli ek deneyim ve tekrarlanan değer ispatlanırsa: gelişmiş çoklu dolap, seyahat planı, ileri ürün karşılaştırması, yüksek kalite 3D varlıklar, cihaz içi gelişmiş model paketleri. Mağaza tarafı işletme aboneliği ayrı gelir. Abonelik henüz uygulanmaz; StoreKit/IAP ancak ticari model ve Apple kuralları onaylandığında.

## 13.2 Unit economics formu, hayali sayı yok

```text
Contribution margin (consumer active month)
 = paid_receipt_net
 - App Store commission and tax handling (applicable plan)
 - weather request actual marginal expense
 - any licensed model/content cost
 - crash/telemetry/storage support marginal cost
 - variable customer-support burden.

Retail partner margin
 = monthly_net_partner_receipts
 - hosting + API + monitoring + support + integration amortization
 - rights/data licensing + merchant acquisition cost allocations.
```

`KPI_COST`: açılış başına enerji, inference başına ms/mJ (ölçülebilirse), 3D önizleme performansı, hava sorgu sayısı/kullanıcı, catalogue request/user, model indirme MB, asset CDN cost (P1), conversion/retention. Sayılar `UNKNOWN` kaldığında açık yaz; default servissiz core işletim maliyetini koru.

## 13.3 Kapasite ve bütçe kapıları

- **0–200 ürün/kişi:** tam yerel, basit kategori sorgusu, cache, optimized thumbnails.
- **1k+ item stress:** DB paginated query, incremental image loading, incremental inference pipeline, background-aware scheduling; gerçek kullanıcı bunu gerekli kılana kadar ağır vektör altyapısı yok.
- **10k günlük aktif P1**: Retail API rate limit/cache ve WeatherKit ücret/limit tablolarını yeniden çıkar.
- Benchmark cihaz listesi hedef iOS min sürümüyle birlikte dondurulur; maliyet ve model ağırlıkları cihaz gerçek ölçümleriyle karar.

## 13.4 Go-to-market planı

1. **Consumer private alpha:** 20–50 gönüllü yetişkin, demo/izinli kendi fotoğrafları; kullanıcı faydasını keşfet, temel görev süresini ölç.
2. **Local iOS TestFlight beta:** günlük kullanıcı davranışı, anonymized opt-in feedback; App Review and security gate.
3. **İzmir pilot Retail:** proje sahibinin Türkiye planıyla uyumlu; İzmir/Bergama/Dikili saha erişimi varsa işletme görüşmeleriyle alan seç, varsayım olarak mağaza bulunduğunu söyleme.
4. **B2B pilot:** 1–3 mağaza ve ürün veri lisansı. Ücret/maliyet ve veri doğruluğu doğrulanırsa genişlet.
5. **Android feasibility:** tüketici retention ve mağaza faydası görülürse ayrık platform ekonomisini hesapla.

## 13.5 Rakipten üstünlük iddiaları için ölçü

`faster first useful outfit`, `lower onboarding burden`, `privacy egress zero`, `higher catalog match precision`, `higher size recommendation calibration`, `store queue impact`, `better low-end performance` ölçülmedikçe "en iyisi", "ilk", "kusursuz" denmez.

---

# 14. ON-DEVICE AI: MODEL LAB, KALİTE VE SINIRLANDIRILMIŞ AJANLAR

## 14.1 Runtime ML görev ayrımı

| Görev | P0 yaklaşım | Alternatif/fallback | Ölçüm |
|---|---|---|---|
| Kişi ve kıyafet ayrıştırma | Apple Vision + uygun lisanslı classifier | manual crop | segmentation IoU/mAP, device latency |
| Kategori tanıma | küçük Core ML image classifier | kullanıcı kategorisi | top-1/top-3, per-category F1 |
| Renk/desen | deterministik image features + ML helper | manual color | perceptual accuracy, confusion |
| Material hypothesis | OCR etiket / partner data önce | `unknown` | evidence-based precision |
| Barcode | Vision/AVFoundation deterministic | manual input | decode precision / scan time |
| Body proportions | controlled parametric avatar | manual sliders | clipping, usability; no anatomical precision claim |
| Fit | verified chart + rules | abstention | accuracy + abstention quality |
| Outfit | constraint solver + user preference ranker | manual combination | usefulness, response time |
| 3D render | RealityKit and prebuilt assets | 2D preview | FPS, thermal, mesh correctness |

## 14.2 Model pipeline / Data rights

`Candidate model → source/license due diligence → benchmark reference data → device conversion → quantization → per-chip profiling → bias/error study → safety/privacy review → packaged hash/version → canary release → rollback`. Do not assume any open-source model is free for commercial use, or that pretrained datasets permit commercial exploitation. Model weights from downloaded package must be integrity verified. Device-only training/inference default; training from user gallery to benefit global model disallowed without separate explicit lawful opt-in and consent/review. Product metadata from retailers may be used only as contract permits.

## 14.3 Model fallback and scheduler

- Inference on task/actor away from main thread; cancel if UI leaves; batch 4–16 items according to measured memory; no background unlimited scan.
- `low power/thermal serious/memory warning` → model size reduction or pause, optional resume.
- `MLModel` unavailable/corrupt → manual import still works.
- Cache local normalized garment crops and metadata only as needed, keep thumbnails small; maintain original crop if user wants reprocess.
- Model update invalidates predictions if schema changes, not user verified fields.
- Airplane mode after first install: sample avatar, manual closet, outfits, laundry MUST work; downloadable model optional and not blocking.

## 14.4 Veri setleri ve adversarial kalite

Golden sets: indoor poor light, patterned shirts, layered coats, multiple people, mirror selfies, skin-like beige clothing, broad size range, different mobility, hijab/head coverings, uniforms, dark garments/black background, folded clothes, crumpled clothes, damaged barcode, glare, blurry label, similar items, non-clothing photo, clothing with text resembling prompt instruction, in-store retail labels with duplicate GTIN display. `False positives` ayrıca ölçülmeli; yanlış dolap kaydı kullanıcı düzeltme yükü yaratır. Model sonuçları `Unknown` ile abstain etmeli.

**Suggested model gates, not achieved claims:** Golden category classification high-confidence precision ≥ 95% (coverage ayrıca raporlanır); user-confirmed matching, zero externally emitted raw photos; cold launch first useful action < 3 sec on named baseline device if feasible; no more than 2 correction taps for common import; repeated 3D rotation >= 30 fps on minimum supported device or fallback. Her hedef için sampling plan ve measurements daha sonra dondurulur; sağlanmazsa P0 kategori kapsamını daralt.

## 14.5 Multi-agent runtime: bilinçli olarak yok

Kullanıcıya "10 yapay zekâ ajanı seni izliyor" hikâyesi satma. App içindeki zeka: ayrı domain algoritmaları ve küçük model. Geliştirme ajanlarının rolleri ise 17. bölümde; production'da sürekli bağımsız LLM ajanlarını çalıştırmak bu ürünün maliyet, güven, pil ve mahremiyet hedefleriyle ters düşer.

---
# 15. PERFORMANS, OFFLINE DAYANIKLILIK VE HATA YÖNETİMİ

## 15.1 Ölçüm önce; optimizasyon sonra

Ölçülmeden performans vaat etme. Her cihaz sınıfında: `cold start P50/P95`, `time to first usable Today`, `scan-to-result P50/P95 (offline partner cache vs online)`, `3D first frame`, `3D median/P1 FPS`, `memory peak`, `main thread hangs`, `ML import seconds per image`, `thermal state`, `battery drain over 10-min interactive session`, `storage footprint 50/500/2000 garments`, `weather cache hit`, `crashes`, `network egress count`.

**Önerilen tasarım hedefleri (doğrulanmış başarı değil):**

| Gösterge | Target for performance spike | Degradation rule |
|---|---|---|
| Home warm launch | P95 ≤ 2.0 sn seçilen baseline iPhone'da | last good local outfit hemen, weather async |
| 3D first visible frame | P95 ≤ 3.0 sn cached avatar (gerçek cihaz) | poster/Level_0 at once |
| 3D interaction | süreklilik hedef 30–60 fps device class'a göre | LOD/material drop veya static fallback |
| Barcode decode | yerel başarılı standard barcode hedef ≤ 1 sn iyi ışıkta | kullanıcıya manuel giriş |
| Wardrobe scroll | hissedilebilir jank olmadan 500 üründe | thumbnail prefetch + paging |
| Local ML import | kullanıcı kontrol/iptal hissi, progress updates | batch pause/cancel, manual entry |
| Airplane mode | all core tasks usable | remote barcode lookup only marked unavailable |
| Private data egress | **0** raw avatar/body/gallery/wear events | hard security fail if >0 |

`DeviceBenchmarkMatrix` üzerinde minimum-supported iPhone, orta seviye, güncel güçlü iPhone ve battery-saving + thermal states ölç; hardware mevcut değilse `BLOCKED_DEVICE` olarak kalır. Simulator network/UI davranışı gerçek pil/termal testin yerini tutmaz.

## 15.2 Kaynak bütçeleri

3D mesh triangle, draw calls, textures/MB, shaders/materials, uncompressed buffer footprint, Core ML model RAM, temporary photo decoder memory, launch assets, compiled binary/App Store download size, iPhone on-disk storage threshold; `assets/quality_gates` script ile her exportta assert. Başlangıç asset budgets `PROPOSED`: base avatar ≤ 50k triangles high LOD, mobile low LOD ≤ 15k, outfit family ≤ 30k triangles (proxy), 2k textures default with atlas/downsizing; gerçek cihazdan sonra güncelle. Bunlar sert teknik sınır değil, spike adayları.

## 15.3 Bileşik arızalar / Black Sky

- Kamera izni yok + internet yok + GTIN bilinmiyor → kullanıcı manuel ürün ekler.
- WeatherKit unavailable + cached weather stale → tarih görünür, kullanıcı etkinlik temelinde kombin önerir.
- Foto importunda memory warning + user closes app → checkpoint, temp cleanup, no duplicate item.
- Avatar corrupted model asset + offline → default 2D mannequin.
- Local database migration failure + low disk → protected backup/export plan veya safe read-only recovery; silent data loss yok.
- Phone locked while 3D mesh writing → protected-data unavailable handled; resume.
- Product GTIN points to old size chart + partner feed changed → invalidation and re-evaluation, old advice hidden/stale.
- Low Power + thermal critical + 2000 imported photos → controlled batch/pause, UI alive.
- `Restore Purchase` in future premium: purchase fail must not lock users out of data or core functions.
- User deletes profile during queued inference → job cancellation and scrub, no recreation of deleted data.
- Partner security breach → tenant API kill-switch; local wardrobe remains functional.
- iOS upgrades OS API → capability detection, feature flags, older supported OS tests.

## 15.4 Incident runbooks

`RUNBOOK-PRIV-001` verified photo egress: stop release, disable remote endpoint, forensic logs redacted, enumerate data, lawful user notice if required. `RUNBOOK-RETAIL-002` cross-tenant: disable import, rotate keys, isolate tenants, restore audit. `RUNBOOK-MODEL-003` drift/unsafe inference: rollback model registry, user cache invalidation, use manual fallback. `RUNBOOK-DATA-004` migration corruption: stop writes, restore previous safe version, test deletion/backup. `RUNBOOK-RELEASE-005` crash-spike after update: phased release halt/rollback where possible, remote kill-switch for network-only functions, preservation of offline local core.

---

# 16. KALİTE LABORATUVARI: TESTLER, GATES, İZLENEBİLİRLİK

## 16.1 Status kelime sözlüğü

`PROPOSED` yalnız fikir; `SPECIFIED` kabul koşulları tanımlı; `IMPLEMENTING` kod üzerinde; `IMPLEMENTED_UNVERIFIED` derlenmiş olabilir ama test/cihaz kanıtı eksik; `VERIFIED_SIMULATOR` Simulator testli; `VERIFIED_DEVICE` tanımlı fiziksel cihazda gözlemlendi; `VERIFIED_INTEGRATION` gerçek, izinli Retail/Weather entegrasyonu ile; `RELEASE_CANDIDATE` App Review/privacy/build gates tamam; `RELEASED` mağazada onaylı ve canlı. Ayrıca `BLOCKED_EXTERNAL`, `BLOCKED_DEVICE`, `FAILED`, `DEFERRED`, `REJECTED`. `Done` tek başına yasak.

**Kritik fark:** kod repo'da bulunmak ≠ compile; compile ≠ unit pass; unit pass ≠ Simulator UI pass; Simulator UI pass ≠ gerçek iPhone; gerçek iPhone ≠ TestFlight; TestFlight ≠ App Store approval; App Store approval ≠ mağazada kabin kuyruğu azaldı.

## 16.2 Kanıt artifact zorunlu alanları

```yaml
work_package: WP-XX
requirements: [REQ-001, REQ-002]
commit_sha: "..."
branch: "..."
platform: iOS
xcode_version: "..."
sdk_version: "..."
device: "iPhone model + OS; or SIMULATOR"
build_command: "..."
build_exit_code: 0
tests: [{id: T-UX-001, command: "...", exit_code: 0}]
screenshots: ["docs/evidence/WP-XX/screenshot.png"]
performance: [{metric: "...", sample_count: 0, observed: "UNKNOWN"}]
privacy: {egress_test: "NOT_RUN", deletion_test: "NOT_RUN"}
reviewer: "independent-review"
review_verdict: "PASS|FAIL|CONDITIONAL_PASS|BLOCKED"
known_issues: []
next_safe_step: "..."
```

`commit_sha` boş/varsayımsal olamaz; dosya yokken path üretilmiş gibi raporlanamaz. Gördüğün hata çıktısını kaydet, yanlış pozitif test sayma. Gerekiyorsa `expected_failure` raporla, `PASS` değil.

## 16.3 Test piramidi

`unit`: domain kural, hesap, kaynak önceliği, state transition, privacy serialization.  
`integration`: PhotosPicker import wrapper/mock fixtures, Vision/model adapters, local DB, WeatherKit fake, Retail API fake, Blender export→RealityKit load.  
`UI tests`: onboarding, add, scan, wardrobe, avatar, Today, offline/permissions.  
`real device`: kamera, thermal, 3D UI, model inference, low memory, file protection, lock/unlock, VoiceOver.  
`contract`: schema/OpenAPI, version/tenant/auth and barcode/size charts.  
`end-to-end`: staged retailer products, manual chart match, optional pilot.  
`privacy/security`: no exfil, local deletion, permissions, injection, data rights and legal check.  
`adversarial`: wrong person, model deception, missing product, unusual body and clothes, poor conditions.

## 16.4 Atomik kabul testleri — minimum katalog (gerçekte yazılacak ve çalıştırılacak)

### Core navigation / onboarding

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-APP-001 | Fresh install → Welcome → Today, kayıtsız ve izinsiz çalışır |
| T-APP-002 | Tüm izinler reddedildiğinde lokal dolap manuel kullanılabilir |
| T-APP-003 | TR/EN dil, tarih, birim ve erişilebilir metin değişir |
| T-APP-004 | App kill/relaunch: kullanıcı dolap/ayarları kaybolmaz |
| T-APP-005 | Onboarding skip, tekrar açma, örnek içerik gerçek dolapla karışmaz |
| T-APP-006 | Low storage: korumalı hata ve yeniden deneyim |
| T-APP-007 | Background→foreground lifecycle camera session kapatır |
| T-APP-008 | App switcher snapshot özel avatarı açık bırakmaz |

### Local wardrobe/media

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-WD-001 | User selects 1 photo via PhotosPicker, only selection processed |
| T-WD-002 | 20 selected photos → progress/cancel/retry; no corruption |
| T-WD-003 | User cancels picker → hiçbir gizli tarama veya dosya kaydı yok |
| T-WD-004 | Multiple people image → bystander image not stored |
| T-WD-005 | False garment candidate → manual correction possible |
| T-WD-006 | Two similar garments → no silent destructive merge |
| T-WD-007 | Import same image twice → explain duplication; no unintended duplicate |
| T-WD-008 | Orientation/exif/mirror/photo rotation correct |
| T-WD-009 | Full offline manual add/edit/delete/archive |
| T-WD-010 | 500 garments list scroll and filter without freezing |
| T-WD-011 | OCR material ambiguity → estimate tag, never exact unsupported fiber |
| T-WD-012 | User verified classification never overwritten silently by model update |
| T-WD-013 | Photo originals in Apple Photos remain unchanged after app delete |
| T-WD-014 | Test local delete removes derived crops/thumbs/embeddings |

### Wear/Care

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-WEAR-001 | `Giydim` once → exactly one wear event |
| T-WEAR-002 | Event replay/double tap → no double increment |
| T-WEAR-003 | `Yıkamada` item excluded from candidate list |
| T-WEAR-004 | `Temiz` resolves availability and resets wear counter appropriately |
| T-WEAR-005 | One day wear does not automatically declare item objectively dirty |
| T-WEAR-006 | Wear undo returns previous count/state safely |
| T-WEAR-007 | Clock timezone/daylight saving drift does not duplicate wear event |
| T-WEAR-008 | Archive preserves past outfit history per user deletion choices |

### Weather/recommendation

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-STY-001 | City selected manually, app never demands precise location |
| T-STY-002 | Weather forecast available → timestamp & temperature displayed |
| T-STY-003 | Weather network error → stale timestamp or neutral alternative |
| T-STY-004 | Wind/rain context recommends additional layer when appropriate |
| T-STY-005 | Outfit uses only available garment IDs (no invented clothes) |
| T-STY-006 | Users can replace one selected item manually |
| T-STY-007 | Explanation refers to actual context and item evidence |
| T-STY-008 | Too warm/cold feedback changes future rank deterministically |
| T-STY-009 | No remote request contains wardrobe or body measurements |
| T-STY-010 | Same local input+rules version gives same ranked baseline result |
| T-STY-011 | Extremely small closet → graceful incomplete outfit + alternatives |
| T-STY-012 | Morning reminder only after opt-in; off-state remains functional |

### Avatar/3D

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-AV-001 | User can create and rotate neutral avatar without photo |
| T-AV-002 | User can modify height and valid torso/hip/shoulder controls |
| T-AV-003 | No explicit anatomical intimate details in base avatar or mesh |
| T-AV-004 | Male/female clothing categories never force gender identity selection |
| T-AV-005 | Out-of-range slider clamps and cannot corrupt geometry |
| T-AV-006 | App locks/unlocks while 3D screen active without crash |
| T-AV-007 | A model asset missing/corrupt → 2D fallback |
| T-AV-008 | Rotating zooming 3D works with VoiceOver alternatives |
| T-AV-009 | 3D proxy preview labeled approximate and never exact size claim |
| T-AV-010 | 3D mesh/garment basic overlap check on shape extremes |
| T-AV-011 | Blender exported `.usdz` actually loads on supported iPhone |
| T-AV-012 | Low Power / thermal fallback is recoverable and UI responsive |
| T-AV-013 | Manual BodyProfile persists only local with proper protection |
| T-AV-014 | Screenshot share includes preview limitation label as needed |

### Scan/product/fit

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-SCAN-001 | EAN/UPC valid GTIN decoded and normalized |
| T-SCAN-002 | Bad checksum barcode rejected without mistaken product match |
| T-SCAN-003 | Camera denied → manual barcode entry |
| T-SCAN-004 | Repeated frames same barcode → one lookup, not storm |
| T-SCAN-005 | GTIN no catalog → exact `unknown`, NOT fake brand/variant |
| T-SCAN-006 | Different size/color GTIN variants remain distinct |
| T-SCAN-007 | Retail HTTP timeout → cached source and timestamp or fallback |
| T-SCAN-008 | Barcode from wrong category → safe no-match |
| T-FIT-001 | No size chart → verdict insufficientEvidence |
| T-FIT-002 | User no relevant measurements → abstain, invite optional input |
| T-FIT-003 | Brand size S not conflated across categories/brands |
| T-FIT-004 | Conflicting size evidence → conflict state, not arbitrary choice |
| T-FIT-005 | User fit preference changes recommendation transparently |
| T-FIT-006 | Unit conversion cm/in and EU/US only with valid category mapping |
| T-FIT-007 | Review confidence and size uncertainty visible on product result |
| T-FIT-008 | Same product with new chart version invalidates stale assessment |
| T-FIT-009 | No unsupported "100% fit" or numeric invented probability |
| T-FIT-010 | Manual measurements never sent to retail API |

### Privacy/security

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-SEC-001 | Packet capture all outbound traffic: no photos/BodyProfile/WearEvent |
| T-SEC-002 | Sensitive files encrypted by iOS Data Protection at stated lifecycle |
| T-SEC-003 | Locked device denies access to complete-protected files |
| T-SEC-004 | Privacy lock/foreground/background state safe |
| T-SEC-005 | Delete avatar → mesh/profile/cache, no residual logical references |
| T-SEC-006 | Delete entire app data → wardrobe/crops/cache/embeddings/events |
| T-SEC-007 | Interrupted deletion resumes ledger after relaunch |
| T-SEC-008 | File backup exclusion verified per category |
| T-SEC-009 | Photo permission revoked → no new access and honest UI |
| T-SEC-010 | Location permission revoked → manual city works |
| T-SEC-011 | Notifications denied → app works and no repeated nag |
| T-SEC-012 | No sensitive content in system logs/crash/telemetry |
| T-SEC-013 | OCR/product text prompt injection treated inert data |
| T-SEC-014 | Imported third-party image is not reused for model training |
| T-SEC-015 | Full library scan impossible in default PhotosPicker-only pipeline |
| T-SEC-016 | App privacy declarations align with observed network egress |

### Retail B2B (P1 gate; DO NOT claim P0 passed)

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-B2B-001 | Tenant A cannot read/update Tenant B product/size charts |
| T-B2B-002 | Invalid/duplicate GTIN import quarantined with clear errors |
| T-B2B-003 | Wrong unit/material percentages rejected or flagged |
| T-B2B-004 | Import retry is idempotent; no stale updates |
| T-B2B-005 | Partner has explicit image/content rights before serving asset |
| T-B2B-006 | Retail metric dashboard no customer body/media/profile identifiers |
| T-B2B-007 | API limits unauthenticated abuse and malformed payloads |
| T-B2B-008 | Size chart updated → client refresh/invalidation |
| T-B2B-009 | Partner account revoked → cannot still write/read restricted data |
| T-B2B-010 | Store pilot does not falsely label its queue impact randomized if not |

### UI, accessibility, release

| ID | Zorunlu durum ve beklenen sonuç |
|---|---|
| T-UI-001 | 3 core navigation destinations + scan accessible on small iPhone |
| T-UI-002 | VoiceOver focus, readable labels and tab order on 22 screens |
| T-UI-003 | Dynamic Type largest sizes avoid clipping critical actions |
| T-UI-004 | Contrast in light/dark and color-independent status meanings |
| T-UI-005 | Reduce Motion fully functional, heavy animation suppressed |
| T-UI-006 | Screenshots of real app captured in light/dark normal/empty/error |
| T-UI-007 | Camera sheet cancellation doesn't trap user |
| T-UI-008 | 500 item scroll and 3D interaction stable on physical device |
| T-UI-009 | `Delete all` confirmation prevents accidental destructive tap |
| T-REL-001 | Clean checkout build with documented environment |
| T-REL-002 | Automated unit/integration UI suite rerunnable exit 0 |
| T-REL-003 | Asset license manifest and ML licenses complete |
| T-REL-004 | App Store privacy, permissions, descriptions, screenshots audited |
| T-REL-005 | Nonempty known issues + feature availability matrix shipped |
| T-REL-006 | Independent critic confirms no fake completion claims |

## 16.5 Test düzeni ve sayısal sonuç sunma

CI her commit: Swift format/lint, compile, domain unit, schema tests, static secret scan, license metadata, Blender output integrity. Nightly: Simulator UI suite + snapshot diff. Physical iPhone run: ayrıca manuel/automated periodic, her sürüm adayından önce zorunlu. P1 API: auth, tenant, contract, property-based, fuzz, load/chaos. Rapor formatı `N passed/N executed, failures, not run, blocked, skipped, code SHA`. Başarısız testi silip denominator düşürme; testleri sahte mock ile production kanıtı gösterme; performans hedeflerini test başlamadan kayda al (`pre-registration`), ölçüme göre hedef geriye oynatma açık ADR olmadan yok.

## 16.6 Audit kapıları (her biri açık kanıtla)

`GATE-0 REPOSITORY_TRUTH`: gerçek repo / Xcode / feature baselines.  
`GATE-1 UX_CONTRACT`: navigasyon, izinler, design system, mock screens.  
`GATE-2 PRIVACY_VAULT`: saklama, deletion, outbound allowlist.  
`GATE-3 WARDROBE`: import/classification/correction, local DB.  
`GATE-4 AVATAR`: Blender→RealityKit, nonsexual grey base mesh, real device render.  
`GATE-5 STYLE`: weather and outfit plus laundry deterministic.  
`GATE-6 SCAN`: barcode + honest missing-catalog fallback.  
`GATE-7 FIT`: size chart, strict evidence and abstain.  
`GATE-8 E2E`: fresh install through scan, wardrobe, 3D, tomorrow, delete; physical iPhone.  
`GATE-9 SECURITY_APP_REVIEW`: platform/legal/security/cost/perf audit.  
`GATE-10 TESTFLIGHT`: signed build, documentation, human provisioning.  
`GATE-11 RETAIL`: pilot data rights, tenant isolation, metrics proof.  
`GATE-12 ANDROID`: justified by retention/economics, parity checks.

**Bağımlılık:** G0→G1/G2→G3→G4/G5/G6→G7→G8→G9→G10; G11 after G6/G7/G9; G12 after G10 + business case. Stage gates can be parallel only for truly independent tasks; independent review cannot review own untested assumption as complete.

---

# 17. CLAUDE DEVELOPMENT AGENT OS — UZMAN ROLLER, SKILL'LER, YETKİLER

## 17.1 Her uzman ajanın kapsamı

| ID | Uzman | Sorumluluk | Onaylayamayacağı kendi işi |
|---|---|---|---|
| AG-00 | **Executive Orchestrator** | tek backlog, dependency DAG, feature cut-line, kararlar | tüm PASS kararını tek başına |
| AG-01 | Product/Consumer Research | JTBD, rakip, retention pilot, etik kullanıcı dili | teknik doğruluk veya mağaza KPI'ı |
| AG-02 | Product Design Director | UX, navigation, tokens, screenshot contracts | accessibility/performance final |
| AG-03 | iOS Tech Lead | SwiftUI, local modules, build, adapters | bağımsız security final |
| AG-04 | Geometry/Blender Lead | neutral mesh, rig, USDZ/asset pipeline | fiziksel fit doğruluğu |
| AG-05 | CV/On-device ML Lead | Vision, Core ML, evaluation, inference | data licensing final |
| AG-06 | Fit Science / Apparel Engineer | garment fit, units, size charts, materials | doğrulanmamış measurement claims |
| AG-07 | Styling/Context Lead | weather, comfort, outfit, wear-care rules | sağlık veya kumaş sertifikası |
| AG-08 | Retail Integration Lead | GS1 variants, APIs, tenant data, pilot | consumer private data |
| AG-09 | Privacy/Security Lead | vault, threat, deletion, egress boundaries | hukuk görüşü yerine geçmez |
| AG-10 | QA/Accessibility Engineer | tests, screenshot audit, device matrix, VoiceOver | yazılmamış testleri PASS |
| AG-11 | Performance/SRE/Cost | metrics, model memory, thermal, outages | ölçülmemiş hız iddiası |
| AG-12 | Independent Red-Team Auditor | plans + code + dependencies + hidden harms | kendi bulgusunu sebepsiz kapatma |
| AG-13 | Release/App Review | entitlement, StoreKit, data labels, TestFlight | Apple onayını önceden garanti |
| AG-14 | Commercial/Legal Liaison | data rights, B2B terms, risk and pricing | avukat görüşü olmadan nihai hukuki karar |

Bu ajanlar gerçek ayrı süreçler/LLM instance'ları gerektirmez; Claude Code kendi içinde **uzman bakış açıları ve ayrı review pass** olarak kullanabilir. Çoklu ajan çalıştırma yalnız repository ve tools gerçekten mümkünse; görev çakışmaları ve gereksiz token/maliyet oluşturmamalı. Kendi uyguladığı güvenlik koduna aynı ajan nihai bağımsız denetim vermemeli; bağımsız review ayrı prompt/bakış veya insan denetimi ile açıkça ayrılmalı.

## 17.2 Ajan kartı / skill kartı zorunlu alanları

`AgentID, Domain, Capability, Tool permissions, Data access policy, Inputs/Outputs, SLO, Budget, Test suite, Source registry, Failure modes, Escalation, Quality gate, Reviewer`. `Skill` tek görevi tekrarlanabilir yapar: `SKILL-PHOTO-IMPORT`, `SKILL-BARCODE-DECODER`, `SKILL-LOCAL-SEGMENTATION`, `SKILL-BLENDER-EXPORT`, `SKILL-REALITYKIT-PROFILE`, `SKILL-SIZE-CHART-EVALUATE`, `SKILL-CONTEXT-OUTFIT`, `SKILL-DELETION-AUDIT`, `SKILL-RETAIL-TENANT-TEST`, `SKILL-APPSTORE-REVIEW`. Gereksiz devasa agent framework ekleme; `.claude/agents/`, `.claude/skills/` veya repo-uyumlu format kullan; sadece Claude Code ortamında desteklenen dosya formatını oluştur ve real tool invocation testini yap.

## 17.3 Agent çalışma protokolü

```text
CLASSIFY requirement and evidence level
→ IDENTIFY owner, source-of-truth and trust boundary
→ WRITE small contract + tests + UI behavior
→ THREAT MODEL and feasibility spike if uncertain
→ IMPLEMENT single dependency-safe slice
→ RUN build/tests/screenshots/device when available
→ SELF-REVIEW including failure modes
→ INDEPENDENT ADVERSARIAL REVIEW
→ REGISTER evidence and status
→ MERGE only if gate passes
→ RECOVER and RETEST on any regression
```

Agent "gördüm/test ettim" dediğinde gerçek çıktıyı kaydedecek. Hak verilmeyen sistemleri çağırmayacak. Bir araç yoksa kurulup kurulamayacağını araştıracak; mock test ile kanıtı yanlış tanıtmayacak. Tüm modüllerin sahibi tektir; ortak adapterlar çift kopyalanmaz. Sırf görev çok diye 15 ajanı sürekli paralel koşturma.

---

# 18. IMPLEMENTATION ROADMAP — SIRALAMA, İŞ PAKETLERİ, TESLİM ŞARTLARI

## 18.1 P0 sürüm sınırı: ilk gerçek ürün

**P0 iPhone Consumer:** no-account onboarding, opt-in PhotosPicker import/manual item, local closet, color/category & correction, wear/laundry, user-editable privacy-first neutral 3D avatar, simple garment family 3D previews, Today/Tomorrow context/weather with offline fallback, barcode scanning + honest local product fixtures/manual identification, size chart-only fit assessments, local deletion and permissions, UX snapshots, actual iPhone performance testing. TR/EN. B2B backend dışarıdan veri gerektirmiyorsa yok.

**P1 AFTER P0 verified:** photo-guided body estimate research, garment geometry improvement, licensed Galata/environment scene, retail product live feed, storefront onboarding/console, optional encrypted export/import, opt-in morning notifications, consumer beta/TestFlight expansion.

**P2 conditional:** Android, multi-store retail network, advanced cloth material simulation, high realism photo try-on (on-device and privacy budget proven), AR camera composite, product inventory and checkout integrations, smart shopping list, paid plans, white-label SDK. **P2 does not block P0.**

**Explicit rejected for now:** automatic hidden gallery crawl; anatomically explicit grey naked model; auto infer biological sex; blanket claim of accurate cm body measurements; hidden cloud photo upload; sale of body profiles; unlicensed retailer scraping; fake live city geolocation scene; mandatory user account; uncalibrated "fit 99%"; 3D render as proof of physical fit.

## 18.2 Dependency-safe 26 iş paketi

| WP | İş | Bağımlılık | Teslim / Gate |
|---|---|---|---|
| WP-000 | Reality Audit | none | repo map, actual tools, evidence baseline, G0 |
| WP-001 | Product Traceability + ADR registry | WP-000 | `REQ` IDs, priorities, blocking assumptions |
| WP-002 | iOS Foundation + CI | WP-000 | clean Xcode build, 1 unit test, CI workflow |
| WP-003 | Design Tokens + Navigation Shell | WP-002 | Welcome/Today/Dolabım/Avatar/Tara mock UIs, screenshots |
| WP-004 | PrivacyVault + DB schema | WP-002, WP-001 | protected local persistence, deletion ledger, G2 |
| WP-005 | PhotosPicker + Manual Import | WP-003, WP-004 | selected-only photo import + deny paths |
| WP-006 | Local Garment Classifier/Correction | WP-005 | small model, golden set, manual failover |
| WP-007 | Wardrobe Collection + Search | WP-004, WP-006 | storage migration, 500 item scroll |
| WP-008 | Wear/Laundry FSM | WP-007 | clean/worn/wash/undo idempotent |
| WP-009 | Parametric Avatar v0 | WP-003, WP-004 | user controls, neutral nonsexual geometry |
| WP-010 | Blender Mesh/Asset Pipeline | WP-009 | versioned `.blend`/USDZ asset + license + export tests |
| WP-011 | RealityKit Avatar Renderer | WP-010 | gesture, fallback, real device screenshot, G4 |
| WP-012 | Garment Proxies + Basic Try-On | WP-011, WP-007 | outfit overlays + approximate badge |
| WP-013 | Weather Context Provider | WP-002, WP-004 | WeatherKit adapter/fixture + stale fallback |
| WP-014 | Deterministic Stylist/Outfit | WP-008, WP-013 | usable Today/Tomorrow and why, G5 |
| WP-015 | Local Notification (opt-in) | WP-014 | schedulable reminder/deny fallback |
| WP-016 | Barcode Camera + Decode | WP-003, WP-004 | GTIN validate, manual, offline demo |
| WP-017 | Product Identity / Catalog Fixtures | WP-016 | source/certainty, variant correct, G6 |
| WP-018 | FitChart Engine | WP-009, WP-017 | evidence-only size recommendations and abstain, G7 |
| WP-019 | Device Security/Privacy Hardening | WP-004 to WP-018 | full outbound audit, deletion/backup/permission gates |
| WP-020 | End-to-End UI + A11y + Performance | WP-003 to WP-019 | actual iPhone screen/bench, G8 |
| WP-021 | Independent Adversarial Audit | WP-020 | blockers fixed; known gaps; G9 |
| WP-022 | Release Prep / TestFlight | WP-021 | signed build/metadata/privacy/hand-off, G10 |
| WP-023 | Retail Partner API + Console | WP-017, WP-018, G9 | tenant, feed, import, security, P1 G11 |
| WP-024 | Licensed City Scene & Avatar R&D | WP-020 | rights & physics truth, gated P1 |
| WP-025 | Retail Pilot / Android Decision | WP-023, user access | actual evidence; Android only if justified G12 |

### 18.2.1 Work package standard form

```yaml
id: WP-005
name: Local PhotosPicker Import
status: PROPOSED
owner: AG-03
reviewers: [AG-09, AG-10, AG-12]
requirements: [REQ-014, REQ-016]
preconditions: ["WP-003 verified", "WP-004 verified"]
problem: "Reduce effort adding clothes"
entrypoints: ["Wardrobe/+", "Onboarding/select"]
inputs: ["explicitly selected PhotosPickerItem"]
outputs: ["reviewable garment candidates and stored selected crops"]
privacy: "no photo-library enumeration, no upload"
data_contracts: ["PhotoImportJob", "MediaProvenance"]
algorithm: "selected-only load→local inference→review→commit"
failures: ["user cancels", "corrupt photo", "low memory", "multiple people"]
offline: FULL
cost: "on-device inference / RAM / battery measured"
acceptance_tests: [T-WD-001, T-WD-002, T-WD-003, T-WD-004]
evidence: ["build log", "test report", "screen recording", "egress check"]
rollback: "feature flag off; preserve previous wardrobe"
pass_gate: "all must tests pass + independent privacy review"
```

## 18.3 Uygulama sırası şartı ve hızlı değer üretimi

**İlk dikey dilim:** `Başla → elle bir gömlek ve pantolon ekle → Bugün kombinini gör → gri avatar üzerinde proxy kıyafeti gör → Giydim → Yıkamada → reset/sil`. İnternet gerekmez, Retail API gerekmez. Bu uçtan uca akış gerçek test edilmeden yüzlerce ayrı modül, sahte AI sunumu veya "pazar lideri" UI videosu yapılmasın. Sonra PhotosPicker, Weather, barcode ve fit kalite eklensin.

**Neden bu sıra?** Birkaç gün fotoğraf importu/3D foto-gerçekçilik araştırmasında kaybolup ürünün temel davranışının hiç çalışmamasını önler. Kabin problemine ikinci dikey dilim ile dön: `Tara→GTIN→kaynak→manuel/generic preview→fit evidence`.

## 18.4 ADR tartışma şablonu

`ADR-ID / context / options / constraints / research evidence / tradeoffs / privacy-security / costs / rationale / decision / tests / rollback / revisit trigger / status`. Örnek: `SwiftData vs GRDB`, `Image capture flow`, `RealityKit garment morph pipeline`, `Weather data provider`, `Manual vs photo-guided body profile`, `iOS minimum deployment target`, `Android ROI`.

---

# 19. MASTER REQUIREMENTS — İZLENEBİLİR ATOMİK ÇEKİRDEK

Aşağıdaki çekirdek `docs/product/REQUIREMENTS.csv` içinde tüm gereksinim `ID, layer, severity, user, flow, inputs, data classification, owning module, dependencies, acceptance tests, evidence, status, release` ile genişletilir. `P0/P1/P2` aşağıda belirtilmiştir; hiçbir madde tek başına `VERIFIED` değildir.

| Requirement | Priority | Kaynak/sahip | Atomik kabul |
|---|---|---|---|
| REQ-001 | P0 | AppShell | Kayıtsız App başlatma |
| REQ-002 | P0 | AppShell | Fotoğraf reddiyle devam |
| REQ-003 | P0 | AppShell | Konum reddiyle manuel şehir |
| REQ-004 | P0 | DesignSystem | 3 temel sekme + Tara tek eylem |
| REQ-005 | P0 | DesignSystem | Light/dark tokens |
| REQ-006 | P0 | DesignSystem | Dynamic Type/VoiceOver |
| REQ-007 | P0 | PrivacyVault | Cihazda BodyProfile/file protect |
| REQ-008 | P0 | PrivacyVault | Cihazda kişisel fotoğraf ve dolap |
| REQ-009 | P0 | PrivacyVault | Dışarı giden veri allowlist |
| REQ-010 | P0 | PrivacyVault | Tüm verileri mantıksal silme |
| REQ-011 | P0 | PrivacyVault | Silme yarım kalırsa resume |
| REQ-012 | P0 | PrivacyVault | Yedekleme/iCloud davranışı test |
| REQ-013 | P0 | MediaIngest | Tek foto çek |
| REQ-014 | P0 | MediaIngest | Seçili foto(lar) import |
| REQ-015 | P0 | VisionInference | Kıyafet category candidate |
| REQ-016 | P0 | MediaIngest | İnsan onayı olmadan kalıcı commit yok |
| REQ-017 | P0 | WardrobeDomain | Kıyafet CRUD/filtre |
| REQ-018 | P0 | WardrobeDomain | Veri provenance / user edits |
| REQ-019 | P0 | WardrobeDomain | Duplicate review / undo |
| REQ-020 | P0 | WearCareEngine | Giydim event idempotent |
| REQ-021 | P0 | WearCareEngine | Yıkamada ürün öneride yok |
| REQ-022 | P0 | WearCareEngine | Kirli tahmin, kesin hüküm değil |
| REQ-023 | P0 | AvatarDomain | Nötr gri nonsexual mesh |
| REQ-024 | P0 | AvatarDomain | Kullanıcı oranları manuel değiştirebilir |
| REQ-025 | P0 | AvatarDomain | Boy isteğe bağlı ve source tagged |
| REQ-026 | P0 | AvatarRenderer | Blender→iOS 3D asset pipeline |
| REQ-027 | P0 | AvatarRenderer | Gesture rotate/zoom |
| REQ-028 | P0 | AvatarRenderer | Fallback 2D poster |
| REQ-029 | P0 | AvatarRenderer | Önizleme yaklaşık etiketi |
| REQ-030 | P0 | ContextEngine | Manuel şehir ve hava |
| REQ-031 | P0 | ContextEngine | Hava cache timestamp |
| REQ-032 | P0 | ContextEngine | Hava verisi olmadan alternatif |
| REQ-033 | P0 | StylistEngine | Yarın kombin önerisi |
| REQ-034 | P0 | StylistEngine | Temizlik/stok filtresi |
| REQ-035 | P0 | StylistEngine | Neden açıklaması |
| REQ-036 | P0 | StylistEngine | Alternatif ve manuel değiştir |
| REQ-037 | P0 | VisionInference | Kamera barkod decode |
| REQ-038 | P0 | ProductCatalog | GTIN/varyant sağlam kimlik |
| REQ-039 | P0 | ProductCatalog | Katalog yoksa abstain |
| REQ-040 | P0 | ProductCatalog | Offline demo katalog ayrı etiketi |
| REQ-041 | P0 | FitEngine | Beden tablosu kaynak kontrolü |
| REQ-042 | P0 | FitEngine | Eksik ölçüde no numeric fit |
| REQ-043 | P0 | FitEngine | Çelişkili source → uncertainty |
| REQ-044 | P0 | PrivacyVault | Retail'e BodyProfile sızmaz |
| REQ-045 | P0 | AppShell | E2E yerel offline senaryo |
| REQ-046 | P0 | QA | Fiziksel cihaz test kanıtı |
| REQ-047 | P0 | QA | Screenshot/design audit |
| REQ-048 | P0 | QA | TR/EN + basic accessibility |
| REQ-049 | P0 | QA | License manifest |
| REQ-050 | P0 | Release | Apple privacy review checklist |
| REQ-051 | P1 | AvatarDomain | Kontrollü foto-guided body R&D |
| REQ-052 | P1 | Scenes | Licenced local city backdrop |
| REQ-053 | P1 | RetailConnector | Partner real catalog feed |
| REQ-054 | P1 | RetailBackend | Strict tenant isolation |
| REQ-055 | P1 | RetailBackend | Partner product size chart validation |
| REQ-056 | P1 | RetailPilot | Controlled queue impact evaluation |
| REQ-057 | P1 | LocalExport | Optional encrypted manual backup |
| REQ-058 | P1 | Notifications | Optional next-day reminders |
| REQ-059 | P1 | AppShell | Independent public TestFlight release gate |
| REQ-060 | P2 | Android | Native Android parity research/build |
| REQ-061 | P2 | AvatarRenderer | Fabric physics with measurements |
| REQ-062 | P2 | Retail | White-label SDK feasible & profitable |
| REQ-063 | REJECTED | Privacy | Hidden unlimited gallery scan |
| REQ-064 | REJECTED | Avatar | Realistic explicit naked body |
| REQ-065 | REJECTED | Fit | Uncalibrated 100% size prediction |
| REQ-066 | REJECTED | Retail | Sell identifiable body profile |
| REQ-067 | REJECTED | AI | Implicit body-sex/ethnicity/health inference |
| REQ-068 | REJECTED | Media | Unlicensed asset and data use |

**Traceability invariant:** Tüm REQ-* için en az bir test veya human review gate; P0 tamamlanmadan P1'i P0 diye göstermeme; tablonun dışındaki yeni ihtiyaca yeni ID. `Requirement coverage = verified critical / all critical` değeri evidence-only. UI demo ve engine fonksiyonu iki ayrı kapsama öğesidir.

---

# 20. ÜRÜN İÇERİĞİ, METİNLER, KULLANICIYA KONUŞMA ŞEKLİ

## 20.1 Türkçe mikro metinler

- Giriş: **"Dolabın. Senin tarzın. Daha az kararsızlık."**
- Açıklama: **"Kıyafetlerini ekle, yarını planla, üzerinde yaklaşık olarak gör."**
- Avatar: **"Modelini kendine göre düzenle. Beden bilgilerin cihazında kalır."**
- Fotoğraf: **"Yalnızca seçtiğin fotoğrafları analiz ederiz. Fotoğrafların telefonundan ayrılmaz."** (bu ancak paket/egress testlerinden sonra kullanılabilir)
- Mağaza tarama: **"Etiketi tara. Ürünü bulalım."**
- Belirsiz ürün: **"Ürünün doğrulanmış bilgisini bulamadık. Dilersen etiketi ekleyebilirsin."**
- Belirsiz ölçü: **"Bu ürün için güvenilir bir beden önerisi yapacak kadar bilgi yok."**
- Studio uyarısı: **"Bu görünüm bir önizlemedir; kumaşın gerçek duruşunu ve beden uyumunu garanti etmez."**
- Weather stale: **"Hava verisi güncel olmayabilir. Son güncelleme: [date]."**
- Wear care: **"Bu parçayı yakın zamanda giydin. Yeniden kullanmadan önce kontrol etmek ister misin?"**
- Deletion: **"Modelin ve bu uygulamada tutulan beden verilerin silinecek. Fotoğraflar uygulamandaki asıllar etkilenmez."**
- Retail disclaimer: **"Mağaza, kişisel modelini veya beden ölçülerini görmez."** (ancak API boundary testli ise)

**Yasak kopyalar:** "Sana %98 yakışıyor", "Bedenin kusursuz", "Seni tamamen taradık", "Tüm galerini analiz ediyoruz" (P0), "Çıplak bedenine göre mükemmel uyum", "Bu kıyafeti denemene gerek yok". Kullanıcının hassasiyetlerini manipüle eden bildirim metni yazma.

## 20.2 Yardım deneyimi

Her `Neden?` kartı üç katman: `1. Karar` (seçim); `2. Gerekçe` (hangi gerçek veri); `3. Sınır` (hangi bilgi bilinmiyor). Kullanıcı source evidence'e tıklayıp `Ben böyle hissetmedim` diyebilir. Confidence internal developer decimal kullanıcıya bilimselmiş gibi yüzdelik olarak dökülmez.

---

# 21. YAYIN ÖNCESİ TAMAMLAMA, BELGELER VE DENETİM

## 21.1 Claude'un sonunda üretmiş olması gereken dosyalar

- [ ] Gerçek derlenen `.xcodeproj` / Swift packages ve iOS uygulama kaynakları.
- [ ] `README.md`: build/run, environment, minimum iOS/Xcode, known gaps.
- [ ] `docs/audit/REALITY_BASELINE.md` ilk makine/repo gerçekliği.
- [ ] `docs/product/PRD.md`, `UX_SCREENS.md`, `REQUIREMENTS.csv`, `TRACEABILITY.md`, `USER_JOURNEYS.md`.
- [ ] `design/tokens.json`, SwiftUI design components, App Icon/Launch source licenses.
- [ ] `assets/blender/sources/`, gerçek `.blend` ve testli USDZ/manifest pipeline.
- [ ] `docs/research/COMPETITOR_MATRIX.md`, `TECH_SPIKES.md`, `MEASUREMENT_EVIDENCE_REVIEW.md`.
- [ ] `docs/privacy/THREAT_MODEL.md`, `DATA_FLOW_MAP.md`, `COMPLIANCE_REGISTER.md`, deletion tests.
- [ ] `docs/decisions/ADR-*.md` kararları ve nedenleri.
- [ ] `docs/evidence/WP-*/` build exit, tests, screenshots, device metrics, reviews.
- [ ] `docs/release/APP_STORE_CHECKLIST.md`, permissions/plist, privacy nutrition labels draft, TestFlight steps.
- [ ] `docs/retail/RETAIL_SPEC.md`, feed schema, pilot design **P1 ve açık status**.
- [ ] `docs/ops/INCIDENT_RUNBOOKS.md`, `COST_MODEL.md`, `PERFORMANCE_BUDGET.md`, `MODEL_REGISTRY.md`.
- [ ] `docs/audit/FINAL_INDEPENDENT_AUDIT.md`, `KNOWN_LIMITATIONS.md`, `COMPLETION_MANIFEST.json`.

Dosyayı listede tutup oluşturmadıysan `MISSING`, yalnız taslaksa `DRAFT`, test yoksa `NOT_VERIFIED`. Mock foto/asset testinde kullanılan tüm örnekler lisans bilgisiyle. Dış hesap bağlantısı/real partner anahtarları kullanıcının sağlamasına bağlı: `BLOCKED_EXTERNAL`, asla sahte canlı veri.

## 21.2 App Store ve kullanıcı mahremiyet release gate

1. Apple Developer üyelik ve signing var mı? Yoksa xcodebuild/SIM build yap ve `BLOCKED_SIGNING`.
2. Latest supported SDK ve App Review kuralları taranıp kayda alındı mı? Xcode version and current docs linked.
3. App privacy labels gerçek trafiğe uygun mu; gerekli gizlilik politikası, izin purpose strings ve kullanıcı silme akışı var mı?
4. Personal photos ve body features ağdan çıkmıyor mu? MITM/packet inspection evidence.
5. Tüm üçüncü taraf modellerin, görüntülerin, assetlerin ticari kullanım belgeleri var mı?
6. Ürün hiçbir yerde kesin fit/santimetre doğruluğu iddiasında bulunmuyor mu?
7. Simulatorden farklı olarak fotoğraf, kamera, 3D, düşük bellek, protected data gerçek cihaz testli mi?
8. Apple'ın gerçek App Review sonucu `UNKNOWN` iken "Apple kesin onaylar" denmiyor mu?
9. TR/EN metinler, screenshot set, privacy purpose strings, offline help ve Delete UX gözden geçirildi mi?
10. CI/build/test logs, known gaps, remediation ve signoff sahipleri mevcut mu?

## 21.3 Bağımsız soru listesi: kullanıcıyı koruyor muyuz?

- Avatar gerçeğe benzemiyor diye bu kişide olumsuz beden algısı oluşur mu? Gerçekten kendisinin ölçüsünü yansıtıyor gibi yalan söylüyor muyuz?
- Mağazada fiziksel denemeden vazgeçiren yanlış öneri ürün iadesini artırıyor mu?
- Fotoğrafta başka kişi varsa onun vücudunun profilini istemeden çıkarmış oluyor muyuz?
- "Tamamen cihazında" deyip WeatherKit'e kişisel profil, crash sistemine fotoğraf veya Retail API'ye ölçü mü gönderiyoruz?
- Kıyafetin kumaşını resimden yanlış çıkardığımızda hava önerisi tehlikeli derecede yanıltıcı mı?
- Telemetri/örnek ekran görüntülerinde hassas beden veya lokasyon sızıntısı var mı?
- Kaybettiğimiz kullanıcı verisini kurtarma ve yedekleme konusunda yanlış vaat var mı?
- Low-end device'ta 3D yüzünden ürün kullanılamaz hale geliyor mu? 2D fallback gerçekten kullanılabilir mi?
- Kullanıcı en fazla üç işlemde günlük kıyafet kararına ulaşabiliyor mu (setup tamamlandıktan sonra)?
- "Ücretsiz" derken ücretli paket yüzünden temel dolabın geri alınması riski var mı?
- Kabin yoğunluğu ölçümü için mağaza, kişileri izinsiz takip etmeye veya biyometriye zorlanıyor mu?
- Ürün dolabından yanlışlıkla silinmiş item geri alınabiliyor mu, tamamen silinmiş kişisel veri geri getirilmemiş olarak mı davranılıyor?

## 21.4 Son teslim biçimi (Claude kullanıcıya rapor)

```markdown
# WEARFORM — BUILD REALITY REPORT
Date / repo / branch / SHA / machine / Xcode / iOS target

## What is ACTUALLY WORKING
- [feature] — code path; acceptance tests; evidence; real device or simulator

## What is ONLY SPECIFIED / UNVERIFIED / BLOCKED
- [feature] — missing dependency; evidence gap; risk

## Test & Performance Summary
- build exit; tests N/M; CI state; screenshot links; tested device;
  3D FPS/memory; ML accuracy sampling; network egress; battery/thermal

## Privacy & Safety
- consent, storage, backup, deletion, partner data separation findings

## User-facing UX
- real screenshots of launch, Today, Wardrobe, Scan, Avatar, Studio;
  loading/empty/permission-denied/offline states

## Competitive and Retail
- sourced comparison + untested assumptions, no fabricated pilot claim

## Independent Critic Verdict
- BLOCKED / CONDITIONAL_PASS / VERIFIED_FOR_DEFINED_SCOPE

## Exact Next Work Package
- ID, owner, dependencies, test plan, safe fallback
```

## 21.5 İlk Claude oturumunda çalıştırılacak görev (kopyala/yapıştır gerektirmeyen dosya içi start instruction)

> **CLAUDE: START HERE.** Önce bu dokümanı bütünüyle oku. Bunu ürünün kanonik ana şartnamesi kabul et. Bu dokümanın bulunduğu mevcut repository'yi ve çalışma ortamını gerçek araçlarla denetle. Repo yoksa minimum iOS monorepo bootstrap et (yeterli Xcode yoksa build'i sahte PASS yapmadan dosya/CI iskeleti üret). İlgili önceki repo varsa sürpriz silme/migration yapma. `WP-000` ve `WP-001` üret, ardından imkân varsa `WP-002` ile clean build + bir unit test çalıştır ve screenshot/kanıt klasörleri oluştur. İlk gerçek değer dilimi için `WP-003`–`WP-012` bağımlılıklarını sırayla uygula, her birini geçerli QA ile kapat. Her çalışma döngüsünde sonuçları commit SHA, test komutu, exit code ve hangi cihazda denendiğiyle raporla. `UNKNOWN`'u `PASS` yapma; izin ve anahtar gerektiren harici işi `BLOCKED_EXTERNAL` bırak. Bitirdiğin her işte tüm repository testlerini tekrar değerlendir ve bir sonraki dependency-safe WP'ye ilerle. Hiçbir adımda kullanıcıya yalnız düşünce aktararak kod yazmış gibi davranma. Başlangıçta bu dosyayı yeniden yazmak için sonsuz planlama döngüsüne girme: küçük çalışan ürün elde et. İlerleme ve audit kayıtlarıyla devam et.

---

# 22. SON KURALLAR — GOD LEVEL / SOURCE OF TRUTH / NO FALSE COMPLETION

1. Bir ekran tasarlamak, onu derlenmiş uygulamada görmek değildir; derlenmiş uygulama gerçek iPhone'da görülmeden tamam sayılmaz.
2. Ürün kimliği, beden verisi ve kişisel güven ile ilgili hesaplarda **bilinmeyeni kabul et**; kullanıcıya güven veren yalanı reddet.
3. Cihazda kalma kararı yalnız satış ifadesi değil, mimari ve egress testidir.
4. Fotoğrafa yalnız kullanıcının seçtiği kapsamda eriş; kullanıcıya fotoğrafları üzerinde mutlak kontrol ver.
5. Nötr gri avatar, insana saygılı; anatomik mahrem detay göstermeyen, özelleştirilebilir bir siluet olarak kalır.
6. Blender varlıklarının telefon uygulamasındaki render doğruluğunu cihaz kanıtı olmadan ilan etme.
7. Hava, kumaş, ürün, kalıp, beden ve avatar verileri farklı kanıt düzeylerindedir. Her önerinin nedenini ve belirsizliğini söyle.
8. Retail partner'in müşteri mahremiyetine erişimi default deny. Başka projelerle beden/fotoğraf verisi paylaşımını varsayma.
9. Kabin sırasında bir iyileşme kanıtlanmazsa mimari/ürün hipotezini değiştir; kullanıcıyı yanıltma.
10. Önce iOS'ta gerçek günlük fayda; Android/B2B sonradan, ölçülen öncelik ve kaynakla.
11. Uzman ajanlar için sorumluluk ve sınır; sürekli pahalı model ve gereksiz altyapı yok.
12. Hukuki ve lisans bağımlılıklarını üretim öncesi kanıtla.
13. Her `REQ` + state + data contract + fallback + test + review + kanıt zincirini koru.
14. Her sürümde security/deletion/recovery/device CI gates tekrar çalışır.
15. Esas performans hedefi: kullanıcının 10 saniye içinde kendisini daha bilgili ve bağımsız hissetmesi; bu **tasarım hedefidir**, iddia değil.
16. Piyasaya çıkmaya uygun olmayan kısımları açık bayrakla; çalışan özü koru.
17. Model birinci fotoğrafta kusursuz tanıma veya fotogerçekçi 3D giydirme sözünü asla doğrudan vermez; araştırma ve ölçüm gerektirir.
18. Her bileşenin maliyet/fayda gerekçesi ve test edilebilir başarı tanımı olacak.
19. Kullanıcının fikrini yalnız harfiyen kopyalama; yanlış sınırı eleştir, güvenli ve daha iyi alternatifini geliştir, ADR ile gerekçelendir.
20. **En az ekranla en fazla fayda; en az veriyle en fazla güven; en basit güvenilir teknikle en yüksek kalite.**

---

## Ek A — REFERANSLAR, DOĞRULAMA DURUMU, YASAL UYARILAR

Güncelleme kontrolü: 03 Kasım 2026 araştırma başlangıç noktasıdır; Apple framework API signature, gizlilik/App Store politikası, model lisansları, rakip ücret ve platform varlığı launch öncesi yeniden doğrulanmalıdır.

**Apple birincil kaynaklar**

- https://developer.apple.com/documentation/swiftui/view/photospicker%28ispresented%3Aselection%3Amaxselectioncount%3Aselectionbehavior%3Amatching%3Apreferreditemencoding%3A%29 — system-selected photos.
- https://developer.apple.com/documentation/photokit/selecting-photos-and-videos-in-ios — photos API privacy.
- https://developer.apple.com/documentation/vision — detection, barcode, segmentation.
- https://developer.apple.com/documentation/vision/vndetecthumanbodyposerequest — body pose 2D landmarks.
- https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest — person mask.
- https://developer.apple.com/documentation/coreml — local ML processing.
- https://developer.apple.com/documentation/realitykit/realityview — native 3D rendering.
- https://developer.apple.com/weatherkit/ — weather data and terms.
- https://developer.apple.com/app-store/review/guidelines/ — privacy/permissions/accounts/app review.
- https://developer.apple.com/documentation/uikit/encrypting-your-app-s-files — file protection.
- https://developer.apple.com/documentation/sensitivecontentanalysis — sensitive media protection as appropriate; not identity inference.

**Ürün verisi ve rakip başlangıç kaynakları**

- https://support.gs1.org/support/solutions/articles/43000734469-what-kind-of-information-is-linked-to-the-gs1-identification-key- — GTIN source lookup semantics.
- https://support.gs1.org/support/solutions/articles/43000734071-how-many-gs1-gtins-do-i-need-for-my-products- — color/size variant distinction.
- https://support.gs1.org/support/solutions/articles/43000729075-what-is-gs1-digital-link- — Digital Link.
- https://www.altadaily.com/ — Alta's published feature set.
- https://support.google.com/labs/answer/16537062?hl=en — Doppl retirement April 30 2026.
- https://www.acloset.app/ , https://www.myindyx.com/ , https://whering.co.uk/ — independently reverify live pages/features before public claims.

**Lisans kaynakları ayrıca araştırılmalı:** Blender GPL ve app'e aktarılan varlıkların lisans ayrımı, Blender Foundation resmi lisans açıklamaları; used mesh creators; ML model weights + training-data commercial permissions; Apple WeatherKit usage rights; GS1/retailer product media terms. İlgili lisansları `LICENSE_AND_MODEL_REGISTRY`'de kayıt olmadan import etme.

## Ek B — BAŞARILI BİR İLK DEMONUN TARTIŞMASIZ TANIMI

Tek iPhone üzerinde, demo/özgün kıyafet görselleriyle, kullanıcı verisi dışarı çıkmadan şu akış **gerçek** çalışır:

`Launch → permissionless setup → 2 items manual / selected photo import → wardrobe → outfit for today or tomorrow (offline fallback) → edit a neutral grey 3D avatar → visually dress avatar with labelled approximation → scan a local fixture barcode → see verified fixture product and chart evidence / or unknown → wear item → set laundry → undo → delete profile and prove removal`.

**Bu zincirde tek bir halka simulator-only, static screenshot-only, unbuilt veya fake server-only ise demo `PARTIAL` olarak raporlanır.** Demo tam olsa bile gerçek mağazada bekleme azaltma kanıtı ayrıca gerekir.

### Nihai proje kriteri

> **WEARFORM, insanın aynası olmaya çalışan bir gözetim sistemi değil; kendi kıyafetleriyle daha iyi karar vermesini sağlayan, kontrolü kişide bırakan özel bir giyim arayüzüdür. Ürün zekâsı derin, deneyimi yalın, iddiaları test edilmiş ve verisi mahremdir.**


---

# V1.1 BINDING EXTENSION — LIVING BODY, UNIVERSAL FIT INTELLIGENCE, OCTOPUS COGNITION & RETAIL GROWTH CONSTITUTION

> **Issued:** 03 November 2026. **Status:** Product and engineering specification; NOT implemented, NOT device-verified, NOT commercially licensed.  
> **Supersedes:** Any less precise or conflicting formulation in v1.0 on body morphing, catalog/review evidence, local learning, symbolic styling, partner strategy and quality targets. **All other v1.0 requirements remain binding.**  
> **Operator:** Claude Code, working as an evidence-first Principal Product/Systems Architect with independent quality-auditor and specialized implementer roles.  
> **Language:** Product-facing TR-first, architecture/code contracts may use English.  
> **Rule:** `SPECIFIED ≠ BUILT ≠ TESTED ≠ DEVICE-VERIFIED ≠ COMMERCIAL-READY`.

---

# 23. AMENDMENT CONTROL / CEO MANDATE / ONE PRODUCT, TWO MARKETS

## 23.1 Founder intent, translated into engineering

WEARFORM is an **adaptive private human avatar + virtual outfit laboratory + reliable product-fit decision engine**, where users can reshape their digital model live, import owned clothing, scan merchandise in stores, see a plausible on-body preview, understand fit and size evidence, receive exceptional occasion-aware styling, and optionally join partner shopping experiences. The retailer value proposition is **reducing unnecessary fitting-room visits and decision time without making false exact-fit claims**.

**Two-sided product:** `Consumer WEARFORM` is the user's trusted private fashion companion. `Retail WEARFORM Partner` is a licensed product-data and experiment platform. Neither partner nor advertisements may gain access to private body profiles, faces, photo libraries, precise measurements, birthdays, inferred characteristics or wear history.

**Founder’s 5 upgrades from v1.0:**
1. A **live parametric body-editor**, segmented by anatomy, ± and continuous sliders, undo/revert, symmetric/asymmetric when safe, privacy-neutral gray model; accessible even without photographs.
2. **Brand- and variant-specific fit intelligence** prioritizing manufacturer size charts, pattern/cut, garment measurements, fiber/stretch, size system, source time/version, and validated optional wearer feedback.
3. **Time-to-preview multi-tier renderer**: immediate meaningful result with graceful progressive refinement; do not promise physically exact cloth in seconds from arbitrary photo.
4. A **bounded local cognitive orchestration system** — the “Octopus” — with specialist modules, personal preferences, energy/thermal-aware scheduler, local memory, safety/privacy veto, and rigorously gated improvements.
5. **Complete retail acquisition, commercial integrations, consumer GTM, referral loops, privacy-safe analytics and testable growth economics.**

## 23.2 Seven product laws

- **The person owns the person.** All body measurements/avatar/corrections remain on-device by default. No retailer can request them through a client API.
- **The user is the gold-standard editor of subjective anatomy and style.** Photogrammetric estimates are editable suggestions, never a forced final identity.
- **Measured reality beats photogenic illusion.** Brand+variant size specs and validated measurements drive size suggestions. 3D appearance does not prove fit.
- **Fast first impression, progressively truthful detail.** Quick silhouette is not falsely labeled photoreal garment behavior.
- **Useful intelligence without mysterious collection.** The system must explain which inputs it used in simple language and let the user opt out or delete.
- **Cultural respect, not cultural profiling.** A selected city helps with weather; it does not reveal a user's cultural identity, religion, ethnicity, dress expectations or gender.
- **Evidence beats “God Level” marketing.** Honest absence of data and calibrated uncertainty are evidence of quality, not failure.

## 23.3 Explicit changes to prior assumptions

| Area | v1.1 authoritative decision |
|---|---|
| Android | Native SwiftUI/RealityKit/Core ML iOS reference product first; future Android native Kotlin/Compose + suitable 3D/NN runtime after device validation. No cross-platform promise of identical native speed without proof. Shared **protocols, asset formats, product/fit algorithms and test vectors** over premature shared UI framework. |
| Demographics | Optional age band or birth date **only if user chooses**; avoid requiring exact birth date. Age is context, not fashion rule; no age-based derogatory norms. |
| Astro/numerology | Opt-in, clearly disclosed **symbolic inspiration** only; never hidden use, never called science or a reliable fit/color/health predictor. No transfer from XRAI or other products. |
| Culture | Explicit destination/event dress-code preference (formality/modesty/custom) rather than inferring identity from locale/photos. |
| Skin tone | If user opts in, local image color sampler with lighting uncertainty plus editable palette; **never infer race/ethnicity** or label someone's attractiveness. |
| Retail websites | No bypassing bot protection, fake partner access, unlicensed extraction, protected photos or review datasets. User-visible links allowed; actual import requires terms/license/permission and source provenance. |
| Self-learning | Local ranking/feedback updates only after rules, safety and regressions; no uncontrolled background self-retraining or unsanctioned network model download. |
| Fit + photorealism | Tiered rendering; ‘same feeling as physically wearing it’ is visionary, not an achievable guaranteed simulation of stretch, weight, warmth, pressure and touch. |

---

# 24. LIVING BODY STUDIO — PRECISION MORPHOLOGY WITHOUT FORCED BIOMETRICS

## 24.1 Fundamental UX: from blank avatar to editable living silhouette

`Start model → select neutral silhouette template (or optional image-assisted draft) → enter optional height/known measurements → rotate 3D avatar → tap body region or choose Body Studio → drag ± slider or directly enter cm → see live deformation → compare side-by-side/undo → save this revision.`

- **No compulsory selfie or gender choice.** User chooses template **shape** and optional presentation rather than inferred biological sex. Neutral gray full-body cloth-like mannequin/coverage material, no nude texture, visible genital contours or sexualized controls. The chest/hip/waist sliders are neutral fit geometry controls.
- Screen splits into `model preview` (65–75% area where practical) and collapsible `adjustments tray`; the tray does not obscure the region being adjusted. Tap a highlighted body region to open only relevant controls. Pinch to zoom; drag to orbit; double tap reset camera; front/side/back preset camera chips; quick reset and undo/redo.
- Each slider has (a) descriptive name, (b) current value `± dimensionless morph` or optional calibrated centimeters, (c) increase/decrease buttons for accessibility, (d) min/max bounds defined by trained mesh topology and device limits, (e) reference-line overlay available on demand, (f) confidence/source badge (`Manuel`, `Ölçüm bandı`, `Görsel taslak`).
- **Crucial:** A slider position is a mesh deformation, **not** an accurate physical circumference in cm unless the avatar engine is *calibrated against measurement geometry*. Never print “96 cm bel” based solely on arbitrary visual dragging. A user-entered verified waist circumference may constrain the mesh; keep separate fields `visualMorph` and `confirmedBodyMeasure` with explicit consistency warning.
- Body edits change the currently previewed garment's collision/ease calculation only when genuine garment geometry exists. If garment is merely a proxy, preview still updates but its fidelity badge remains `Siluet önizlemesi`.

## 24.2 Anatomical slider and measurement register (extendable)

| Stable `parameterKey` | Turkish UI name | Axis/meaning | Source & unit | Fit effect / note |
|---|---|---|---|---|
| `stature` | Boy | overall calibrated height | manual cm, estimated photo only draft | garment length ratio; strong user source |
| `neckCircumference` | Boyun çevresi | neutral neck perimeter | user tape cm or visual morph | collars; no health attribution |
| `neckLength` | Boyun uzunluğu | head–shoulder vertical space | morph proportion | neckline rendering |
| `headScale` | Baş oranı | head size relative to body | dimensionless | visualization only; no identity recognition |
| `shoulderBreadth` | Omuz genişliği | biacromial-like width, clear landmark definition | manual cm or morph | jacket/shirt shoulder seam |
| `shoulderSlope` | Omuz eğimi | shoulder line tilt | morph | neckline and sleeve silhouette |
| `upperChestCircumference` | Üst göğüs | upper torso perimeter | user-confirmed cm / morph | tops/outerwear |
| `fullChestCircumference` | Göğüs çevresi | widest torso/bust circumference | user-confirmed cm / morph | tops/dresses |
| `underChestCircumference` | Göğüs altı | under-bust torso measure | optional cm / morph | fitted garments, optional not default |
| `torsoLength` | Gövde uzunluğu | shoulder-to-waist distance | morph/cmtape if defined | shirt/jacket hem |
| `naturalWaistCircumference` | Bel çevresi | natural-waist perimeter | manual cm / morph | bottoms/dresses; high priority |
| `waistHeight` | Bel yüksekliği | waist vertical anchor | morph | rise/hem position |
| `abdomenFullness` | Karın oranı | anterior lower torso profile | morph, dimensionless | shape not medical data |
| `highHipCircumference` | Üst basen | upper hip perimeter | optional manual cm / morph | bottom waistband |
| `fullHipCircumference` | Kalça/basen çevresi | widest hip/glute perimeter | manual cm / morph | jeans/skirts |
| `hipWidth` | Basen genişliği | lateral hip width | morph | profile silhouette, not circumference |
| `seatProfile` | Arka kalça profili | rear depth/seat shape | morph | pants seat visual fit only |
| `upperArmCircumferenceL/R` | Üst kol kalınlığı | left/right arm girth | manual cm / morph | sleeves; symmetry by default |
| `forearmCircumferenceL/R` | Ön kol kalınlığı | left/right forearm | manual cm / morph | tailored sleeves |
| `armLengthL/R` | Kol uzunluğu | shoulder to wrist | manual cm / morph | sleeve length |
| `wristCircumference` | Bilek çevresi | wrist girth | optional cm | cuffs |
| `thighCircumferenceL/R` | Uyluk kalınlığı | thigh girth | manual cm / morph | slim jeans/shorts |
| `kneeCircumference` | Diz çevresi | knee region girth | optional cm/morph | tapered pants |
| `calfCircumferenceL/R` | Baldır kalınlığı | calf girth | manual cm/morph | boots/pants |
| `legLength` | Bacak uzunluğu | hip-to-floor proportion | manual cm / morph | trouser silhouette |
| `inseam` | İç bacak boyu | crotch-to-ankle measured definition | manual cm | denim length sizes |
| `ankleCircumference` | Ayak bileği | ankle perimeter | optional cm/morph | pant cuff |
| `footLength` | Ayak uzunluğu | heel-to-toe measurement | user cm | shoe size separate; no shoe fit promise |
| `footWidth` | Ayak genişliği | max forefoot width | optional cm | shoes, future partner |
| `postureUpperBack` | Duruş/profil | relaxed/straight visual posture | morph | changes silhouette but cannot infer spinal condition |
| `hairSilhouette` | Saç hacmi/uzunluğu | selected hairstyles | template/morph | visualization; no biometric reconstruction |

**No one must see 30 sliders initially.** Default screen shows `Omuz • Göğüs • Bel • Basen • Kol • Bacak`, with “Ayrıntılı ölçüler” accordion and context-sensitive measurement affordances. Sliders are curated by garment category: jeans highlights waist/hip/thigh/inseam; shirts highlight shoulders/chest/arm; dresses highlight chest/waist/hip; others hidden until requested.

## 24.3 Physical-model calibration and shape safety

- A single global slider scaling arbitrary vertex coordinates is unacceptable: it distorts joints and causes cloth intersection. Build a consistent **canonical skeleton**, semantic body region masks and interpolated deformation targets (blend shapes/morph targets or controlled cage/FFD), preserve joint attachment, bone lengths and surface continuity.
- Blender DCC pipeline: open/licensed base mesh → topology/UV/skeleton/weight-paint → region morph shape keys → lossless test avatar presets → `USDZ` or verified supported asset pipeline → iOS render runtime. Blender is for **offline asset creation and batch baking**; it does not run inside consumer iOS app.
- Runtime deformation options: RealityKit skinned-mesh/blend-shape deformation where supported on target OS and hardware; otherwise maintain a versioned fallback mesh swap or low-complexity local geometry pipeline. The Apple mesh deformation API and deployment target must be validated against stable SDK/Xcode; no beta-only hard dependency without fallback.
- Surface constraints: no negative radii/self-intersection, no topology tear, no collapsed triangles, normal/tangent recomputation, no unintentionally exposed torso when morphing, stable ground contact, consistent garment anchoring, camera/frustum fit after stature edits.
- Subjective edits saved as immutable versioned snapshots with hashes; quick undo/redo is UI-session local, `Save model` commits a revision; revisions can be restored and deleted. App version updates never silently mutate user-authored body.
- Auto-proposed changes (e.g., image-assisted head/shoulders) appear as ghosts until `Accept`; rejected suggestions are not re-applied without explicit user action.
- `BodyProfile`: allow multiple profiles only for the same individual on a shared device if secure; third-party child profile/no-consent capture out of v1.
- Calibration test uses a synthetic parametric reference mesh with ground-truth landmark measurements and 3D geometry distances. Human measurement validation must be consensual, independently measured, demographically inclusive, holdout, and report distributions rather than guarantee an exact personal replica.

## 24.4 Runtime deformation algorithm (contract and fallback)

```text
onDrag(parameterKey, proposedValue):
  normalized = clampToSafeBounds(parameterKey, proposedValue)
  draft = BodyMorphState.with(parameterKey, normalized)
  if !topologySafetyPrecheck(draft): show safe bound, reject invalid update
  commitToRenderBuffer(draft)  // coalesce frames, don't rerun photo ML
  previewMesh = avatarMorphEngine.deform(draft, LOD=currentLOD)
  garment = garmentPreviewEngine.adjustForAvatar(previewMesh, currentGarmentTier)
  present(previewMesh, garment, fidelityDisclosure)
onGestureEnd:
  publishAccessibilityValue(); scheduleLocalSnapshot(); optionally recompute fit evidence
```

Frame-by-frame drag **never** triggers brand API, large local inference, fresh weather calls, photo analysis, model retraining or upload. The immediate feedback path is geometry/graphics only. Fit recalculation after gesture end is coalesced and source-dependent. The UI must remain responsive if recomputation is queued.

---

# 25. THE TWO VISUAL TRUTHS: REAL PERSONAL AVATAR VS PRODUCT-ACCURATE DIGITAL TWIN

## 25.1 Never collapse these different capabilities

**A. Identity-adjacent avatar:** gray mannequin whose *proportions* the user intentionally tunes. It is not proof of actual anthropometric identity. 
**B. Visual garment overlay:** mesh silhouette/texture on avatar. This is an aesthetic approximation when no technical garment asset exists. 
**C. Dimensional fit analysis:** compare measured body landmarks against source-supplied garment/pattern dimensions/ease. Can guide size independently of photorealism. 
**D. Physics-informed drape:** material/pattern/seam/stretch validation plus cloth simulation, body collision, animation and objective evaluation. Expensive; partner-limited research track, not universal v1 guarantee. 
**E. Tactile/physical feeling:** pressure, thermal sensation, textile hand-feel, flexibility, comfort cannot be completely reproduced through a conventional phone screen. Never promise identical sensation to wearing it physically.

## 25.2 Garment fidelity ladder with truthful UI names

| Tier | Input sufficient | Render | Label | Claim allowed |
|---|---|---|---|---|
| `G0` | only text/style/category | stylized generic garment placeholder | `Örnek siluet` | category and color story only |
| `G1` | photo, approximate garment segmentation, rough category | cropped texture on generic category proxy | `Yaklaşık görünüm` | general silhouette/color, not true cut |
| `G2` | partner front/back views + attribute dimensions and size chart | tailored proxy param mesh, calibrated length/shape | `Ürüne göre modellenmiş önizleme` | better proportions; not physical drape |
| `G3` | licensed per-size 3D garment asset + known authored dimensions | skinned/mesh variant with fit constraints | `3D ürün modeli` | appearance in known poses with limits |
| `G4` | validated technical CAD/pattern/cloth physics and device hardware | material-aware simulated drape + validation cases | `Test edilmiş kumaş simülasyonu` | only to tolerance and cases actually tested |

Tier label must remain visible via small `(i)` tooltip, not visually overpower screen. Unknown store clothing defaults `G0/G1`, never claimed `G3/G4` by simply running generative AI. If photo is blurry, rights unclear or catalog absent, show precise fallback and what more input would help. 

## 25.3 Digital garment asset studio

- Create authored synthetic garment templates in Blender: tee, shirt, knit, blazer/jacket, jeans, pants, skirt, dress, outerwear. Prove skinning, texture mapping, occlusion, cloth layering and pivot anchors on diverse body morph presets.
- Per product asset package: `garmentAssetId`, `sourceVariantId`, `licenseId`, `garmentCategory`, `geometryVersion`, `LOD`, `materialVersion`, `patternOrProxy`, `measurementAnchors`, `compatibleAvatarTopology`, `provenance`, `fidelityTier`, `checksum`, `expiresAt`.
- Separate **body mesh** and **garment mesh**; garment assets never carry user-specific body texture or shape into shared catalog. Mesh/shaders signed/verified; format is robust against malicious malformed assets and OOM.
- Physics: collision tolerance, anti-clipping clipping maps, dynamic constraints, mesh parameter interpolation, lighting presets, material PBR only when licensed and validated. Simpler offline-safe proxy is the mandatory fallback.
- Size changes should visibly adjust geometry when enough size-specific data exists; swapping label from M to L without changing render or explaining limitation is prohibited.
- Dramatic pose, lying/sitting, bending must be marked unsupported if deformation data not available; default honest neutral upright stance, controlled walk/turn motion only after proof.

## 25.4 Scene, city and real-world authenticity

- City/location selection can show **licensed general scene visuals** or procedural environments, not photographs of a person secretly superimposed into unlicensed scenes. Landmark depiction (e.g. Galata) must be labeled illustrative, with weather and daylight determined from timestamp where available.
- Preload a handful of **legally obtained** environment assets: neutral studio (P0), walking street (P1), café/meeting, office, evening/restaurant, rainy outdoors (P2), selected public-landmark scene (P2). No need to build an entire geospatial 3D globe.
- Weather animation is illustration (rain/wind), not certified weather truth; never simulate exact future location lighting as guaranteed. Provide studio compare mode to avoid distractions when evaluating cut.

---

# 26. GLOBAL BRAND & FIT KNOWLEDGE GRAPH: PROVENANCE FIRST

## 26.1 What is actually identifiable in a store?

Recognition ladder: **EAN/GTIN scan** → authorized partner variant → correctly matched size/color/collection/country → official technical chart → fit recommendation. Without exact GTIN: visible label/OCR and logo brand candidate → user confirms product style/size → authorized searchable partner catalog → multiple candidates with confidence. **Similar looking shirt is not necessarily the exact SKU.** Different production runs/markets alter dimensions; no brand-global sizing assumption.

Brands requested as **priority discovery queue, not existing partners or unlocked APIs**: LC Waikiki, Mavi, Levi's, Jack & Jones, Hugo Boss, Calvin Klein; later: Koton, DeFacto, Zara, H&M, Mango, Nike, Adidas and category specialists. All partner names remain reference brands only until executed agreements. For Levi's, manufacturer-published waist/hip/inseam size-guide examples support need for actual category-specific charts, not authorization to scrape or redistribute them.

## 26.2 Catalog hierarchy and permissible acquisition

1. **Signed partner feed/API**: contract permits product attributes, size systems, measurements, licensed images, asset cache, freshness and display rights; priority S0.
2. **Retailer-authorized export** (CSV/JSON/ERP/PIM/POS/Shopify-compatible connector, public partner feed with written permission); S1.
3. **Rights-cleared third-party catalog/affiliate data**: permitted fields and conditions; S2.
4. **Official public web page viewed with user action / user-provided product URL**: may provide user-facing link; automated copying/reprocessing/photographs require applicable right and terms review; S3, not automatically a production source.
5. **User photograph of owned item/store tag**: ephemeral local OCR; no assumption of copyright to republish marketing imagery; S4.
6. **Visual ML guesses**: low confidence, no guarantee of exact product/size/fabric; S5.

Google Merchant Center Merchant API requires authenticated **merchant-granted access** and cannot be treated as open catalog of all brands. Where catalog available, map group+variant fields such as item group ID, size, color, material, size system, GTIN; inventory may be different freshness. GS1 ID alone is a lookup key, not full textile spec.

**Prohibited:** unauthorized credential usage; scraping despite contractual prohibitions; bypassing robots/anti-bot; collecting customer reviews without rights; copying customer photos; finding protected merchant API credentials; presenting invented partner data as verified. Legal review of terms is a work item, not an afterthought.

## 26.3 Variant-specific knowledge graph schema

```json
{
  "brandId":"mavi-reference-id-not-partner",
  "catalogRights":"DEMO_ONLY",
  "styleId":"jeans-regular-x",
  "variantId":"style-x-blue-w32-l32",
  "gtin":"OPTIONAL_VERIFIED_GTIN",
  "market":"TR",
  "category":"denim_jeans",
  "targetCut":"regular_straight",
  "merchantSize":{"display":"W32/L32","system":"brand_denim_WL"},
  "bodyChart":{"waistCm":{"min":null,"max":null},"hipCm":{"min":null,"max":null}},
  "garmentMeasurements":{"waistFlatCm":null,"inseamCm":null,"thighFlatCm":null,"legOpeningCm":null},
  "fabric":{"composition":[],"stretchClass":"UNKNOWN","weightGsm":null,"shrinkTolerance":"UNKNOWN"},
  "evidence":[{"kind":"MANUFACTURER_SIZE_CHART","sourceId":"not-yet-connected","effectiveAt":null,"licenseId":null}],
  "previewAsset":{"tier":"G0","id":null},
  "isDemonstrationData":true
}
```

- Separate wearer/body circumference from *flat garment* measurements; `flatWaistWidth × 2` may not equal comfortable wearable waist because of cut, rise, fabric stretch, elastic, curvature and measurement conventions. Define unit/measurement method for every value.
- `BrandSizeChart` scoped by market/sex-based retail department label **when manufacturer uses one**, category, season/model, variant, size system, effective dates; user's personal gender is not assumed from retailer department.
- Knowledge graph associations: `Brand → Collection/Market → ProductStyle → Variant(GTIN/size/color) → GarmentSizeSpecs → SourceEvidence → RenderAssets → WearerFitFeedbackAggregate` with stable IDs and provenance.
- Content hash/version, expiration, supersession, source dispute/quarantine and consistency validators are mandatory. Retain evidence chain for every recommendation.

## 26.4 Fit engine: deterministic constraints + calibrated learned residuals

```
fit(productVariant, bodyProfile, desiredEase, wearerFeedback):
  0. Validate product identity and source rights/freshness.
  1. Verify measurement semantics and units (cm/in, flat/circumference, rise etc.).
  2. Identify fit-critical landmarks per garment category.
  3. Select user-entered confirmed measurements. Morph-only values are visual.
  4. Infer permissible range of ease for exact cut/material/fit preference using
     authored garment rules; if unsupported keep UNKNOWN.
  5. Evaluate each available size independently for impossible tightness,
     plausible room, length, desired ease, and uncertain elastic properties.
  6. Optionally combine calibrated anonymous permitted size-feedback trends as a
     *weak* prior, never overriding verified manufacturer specs arbitrarily.
  7. Return 0–2 supported suggestions; include size-system, source, timestamp,
     missing dimensions and a human explanation; else abstain.
```

No “%98 fits” or ``same on-body look`` unless independent calibration supports it. `S/M/L` is not internationally stable. Shirts: collar+shoulder+chest+sleeve. Denim: waist+hip+thigh+inseam+rise+stretch. Jackets: chest+shoulder+sleeve+layering. Dresses: full chest+waist+hip+length+cut. Shoes: separate domain with foot dimensions.

## 26.5 Review intelligence: permitted, aggregated, explainable

Only ingest **licensed, explicitly permitted** reviews or voluntary opt-in feedback. For per-product fit signals extract evidence-attributed attributes: `runsSmall`, `runsLarge`, `accurateSize`, `tightShoulder`, `waistLoose`, `sleevesShort`, `stretchy`, `seeThrough`, `materialHot`, `afterWashShrink` with per-label precision tests. Ignore photos/private demographic inference; redact PII and hate content. Retain review rights/version and deletion requests. Do not infer someone's true body shape from review texts. Review statistics require sample size and coverage; an isolated review is weak evidence.

Example: “Bu modelin omuz bölgesinin dar olduğuna dair yeterli, hakları doğrulanmış kullanıcı verisi yok” should be shown instead of inventing aggregation. If reviews disagree with chart, label `CONFLICT`, allow user to compare both and recommend a physical check.

## 26.6 Source disagreement resolver

```
SOURCE_VETTED → MEASUREMENT_SEMANTICS_OK → SIZE_SYSTEM_MATCH →
USER_MEASUREMENTS_CONFIRMED → WEIGHTED_EVIDENCE → FIT_RESULT
                           ↘ unresolved conflicts → ABSTAIN + explain
```

Hard safety rules outrank crowd feedback. Product dimension staleness, wrong country chart, counterfeit label, size chart category mismatch or shared GTIN ambiguity => fail closed. Footwear, underwear, compression wear, maternity/medical garments and protective equipment require distinct policy and staged authorization; no fit certainty from generic rules.

---

# 27. <SECONDS> TRY-ON EXPERIENCE / PERFORMANCE CONTRACT

**Architectural objective:** The user should receive a **useful stage** within seconds for supported local cached assets. This is **not** the claim that every internet-unknown SKU becomes a physically accurate, photo-real 3D garment model in seconds. Latency SLOs are **targets until measured on named devices, not achieved performance**.

| Stage | Indicative goal for supported devices* | Work | Fallback |
|---|---|---|---|
| L0 camera scan feedback | p95 within ~0.5 s after readable frame* | Vision/barcode frame | user enters text/GTIN |
| L1 product identity | p95 ≤ 2 s **cached licensed record** | validated lookup | `Aranıyor` with OCR/manual candidate |
| L2 first visible garment preview | p95 ≤ 3 s **prepackaged generic proxy, warmed engine** | select body mesh+G0/G1 garment | static silhouette immediately |
| L3 partner-specific G2/G3 | tier-conditional, separately measured; 3–10 s **experiment goal only** | downloaded/cached verified 3D asset | G1/G2 with fidelity badge |
| L4 cloth physically plausible | no user-facing universal seconds promise | material-aware simulation / QA | G2/G3; not a blocker to basic try-on |
| Morph drag | UI target 60 fps capable devices, fallback 30 fps; input-to-photon p95 tuned by device* | cached mesh interpolation | reduced LOD / frame coalescing |

`*` Hypotheses to be profiled on entry-tier supported iPhone, 2–3 representative mid/high tier devices, normal/low-power and thermal `fair/serious`, offline/slow network, cold/warm caches. Never print numeric performance as achieved until device evidence exists.

**Critical path design:** barcodes lightweight -> local normalized key -> encrypted/private avatar in memory -> precompiled/shader-warmed category garment mesh -> first preview; catalog asynchronous; available product detail enriches scene incrementally. The ML recognizer must not freeze the first frame. Preload one neutral avatar and popular generic garment assets at app idle within battery budget; do not prefetch unknown store catalogs without consent. Cancel stale scan requests; avoid GPU readback. For unknown SKU: immediate `Önizleme yaklaşık`, not a fake photoreal texture.

**Device scheduler:** `ProcessInfo.thermalState`, `isLowPowerModeEnabled`, camera activity, active interaction, memory pressure, available storage, visible screen, user's selected battery-sensitive settings, network reachability and explicitly approved cellular policy influence work queue. Core critical UI first; heavy gallery scanning and model updates only when safe/foreground or permitted OS scheduling. `critical` thermal -> stop nonessential camera/3D/ML and present respectful resume message; do not keep a hidden scanner alive. Download models and large assets primarily on Wi-Fi unless opt-in. The app should never claim direct control of battery health or hardware temperature, only adaptive usage.

**Memory/performance:** Per-model memory budget set by measurement, not arbitrarily; include resident model sizes, cold load times, peak RSS, battery draw estimate, thermal transitions, frame times p50/p95/p99, dropped frames, scan accuracy vs speed. If assets are too large, use LOD/texture compression/streaming and precomputed skeletal morph targets. Surface capabilities by device tier; no automatic denial of all functionality on older supported devices.

---

# 28. OCTOPUS COGNITION — LOCAL SPECIALIST MODULES + SINGLE ACCOUNTABLE BRAIN

## 28.1 Principle

The “octopus” is a metaphor for **independently testable specialist capabilities coordinated by one local policy-aware orchestrator**, not a collection of uncontrolled LLM agents running in parallel or constantly sending personal data to servers. **Every arm has an explicit input contract, output contract, permissible actions, power budget, evidence level, degradation and deletion rule.** A single visible explanation surface tells the user **why** an outfit/size was suggested.

## 28.2 Arm inventory / owners

| Arm and contract ID | Responsibility | Allowed inputs | Output | Must not do |
|---|---|---|---|---|
| `OCT-01 PrivacySentinel` | gate all data flows and retention | per-feature consents, data classes, device policies | allow/deny + audit reason | silently expand permissions |
| `OCT-02 DeviceSteward` | thermal, RAM, energy and scheduler | platform resource status, task priority | work budget, pause, LOD | overrule safety or background policy |
| `OCT-03 VisionWardrobe` | identify garment category/color/crop/dedup | only selected/authorized local photos | local wardrobe candidates | retain bystander faces or upload source |
| `OCT-04 MorphIdentity` | morphs, calibration and user corrections | local body inputs/asset geometry | safe param mesh + uncertainty | claim exact measurements from image |
| `OCT-05 CatalogResolver` | product GTIN/SKU/version resolver | label, barcode, authorized catalog | product variant + provenance | fabricate product ID or scrape without right |
| `OCT-06 PatternFit` | pattern/size/ease decision | confirmed body measures + approved SKU data | fit verdict + evidence | guarantee physical comfort |
| `OCT-07 RenderStudio` | LOD 3D, proxy garment, lighting, pose | body mesh, licensed garment assets | rendered frame + fidelity tier | fake G4 from photo |
| `OCT-08 ClimateStylist` | weather/time/activity/fabric layering | selected city/date/activity, wardrobe | compliant weather outfit candidates | present stale weather as current |
| `OCT-09 CreativeDirector` | palette, silhouette, mood, occasion | user-declared aesthetic preferences, selected image colors | diverse outfits + readable rationale | beauty/body scoring or identity stereotypes |
| `OCT-10 CareWardrobe` | wear, laundry and availability | user-tagged wear and care records | clean/uncertain/laundry advice | claim item is physically dirty from elapsed days |
| `OCT-11 FeedbackLearner` | local preference fitting and safe updates | explicitly given corrections/ratings | versioned personal ranking | unsupervised destructive retraining |
| `OCT-12 SymbolicInspiration` | **opt-in** astrology/numerology style prompts | explicitly supplied DOB or locally derived symbols | optional color/mood inspiration tagged non-scientific | covert affect/identity/fit decision |
| `OCT-13 ExplanationQA` | provenance, consistency and uncertainty veto | other arms' structured evidence | user explanation, abstention | invent source or mislabel preview |
| `OCT-14 RetailBoundary` | minimum anonymized business query/metrics | public catalog key, partner access token | product-only lookup; aggregate retailer metrics | transmit exact body, DOB, photos, local style history |

**Explicit rejected pattern:** 14 on-device foundation LLMs permanently active. Most arms are deterministic Swift modules, local Core ML models or RenderEngine tasks, not chatbots. An optional small local language model is only approved after measurable improvement over templated explanations, with resource and hallucination gates. Front-end remains deceptively simple.

## 28.3 Orchestrator event/data flow

```text
USER ACTION / FOREGROUND EVENT
     ↓
PrivacySentinel(consent, local data class) → DENY OR PASS
     ↓
DeviceSteward(priority, thermal, memory) → resource budget / defer
     ↓
Domain request routing (typed immutable messages, cancellation tokens)
   ├─ Photo → VisionWardrobe → user review → local wardrobe vault
   ├─ Body sliders → MorphIdentity → RenderStudio → interactive frame
   ├─ Barcode → CatalogResolver → PatternFit → RenderStudio
   └─ Event/day → ClimateStylist + CreativeDirector + CareWardrobe
                     [SymbolicInspiration only if opted-in]
     ↓
ExplanationQA(verifiable evidence, capability and confidence)
     ↓
PERSON: visible result / correction / explanation / delete / revert
     ↓
FeedbackLearner(versioned local preference update, never hidden)
```

Every domain object has `value, confidenceClass, provenance[], inputVersion, modelVersion, createdAt, expiry, permissionsUsed`. Internal access only to fields needed; the policy layer must be central and testable even when tools/agents misbehave. Use actors/structured concurrency and bounded worker pools, never unlimited queues. Durable event journal excludes sensitive source images. 

## 28.4 Decision protocol and explainability

```
StyleDecision {
  selectedClosetItems[]; suggestedPurchases[]; occasion;
  factualReasons[]; preferenceReasons[];
  evidenceRefs[]; excludedCandidates[];
  unknowns[]; confidenceClass; usedSymbolicInspiration: Bool;
  latencyMs; algorithmVersion;
}
```

Consumer default microcopy: “18° ve yağmurlu: nefes alan iç katman + suya dayanıklı dış katman. Bu ceket temiz olarak işaretli. Bedende kesinlik için etiketi kontrol et.”

Tap `Neden bunu önerdin?` for `Hava / Tarzım / Dolabım / Ürün verisi / Sembolik ilham` provenance. Personal data and hidden heuristics do not become opaque persuasive tactics. Supplier-paid promotions are labeled and do not alter fit verdict.

---

# 29. LEARNING WITHOUT LOSING CONTROL — PERSONALIZED LOCAL EVOLUTION

## 29.1 Three separate improvement mechanisms

**(I) Immediate deterministic preference updates:** User says `dar`, `rahat`, `bu renk hoşuma gitmedi`, `bugün giydim`, `yıkamaya girdi`, `bu modelin belini düzelttim`. Persist local events, update the personal style state and re-rank next outfit. Easy to undo, inspect and erase. No ML training needed.

**(II) Bounded local ML fine-tuning:** Only if a genuinely *updatable* Core ML model is selected and benchmarked. Consent and available training data required. Train from user-labeled examples on safe schedules; run candidate vs baseline on untouched local validation; only commit improvement if no privacy/quality regressions. `MLUpdateTask` is supported for appropriately configured models, not an automatic capability of every Core ML model.

**(III) Audited product-wide model upgrades:** Developers curate rights-cleared datasets, validate held-out accuracy/fairness/security/performance, sign the model manifest, ship App Store app/model update via legal distribution path; feature flags+rollback. Updating user's local models never implies exporting their private data. Federated learning and differential privacy are **research options**, not default proven privacy guarantees.

## 29.2 Non-negotiable local learning gates

```
OBSERVATION
 → user explicitly confirms or corrects
 → local candidate update
 → schema/model compatibility check
 → privacy + fairness + energy check
 → A/B vs frozen baseline / replay validation
 → accept improvement OR reject
 → append versioned user-visible change log
 → rollback in one action
```

Disallow silent rewrites of manually confirmed measurements, DOB, skin palette, consent, explicit excluded styles, wardrobe ownership or garment truth. Training on nonconsenting bystanders, body images, retail purchased histories for ad targeting, or transferring personal states across products is forbidden. No continuous background loop: OS allows bounded opportunities and users control battery/network. Local learning can stop indefinitely without breaking the app.

## 29.3 Expert stylist as creative domain logic, not omniscience

A professional styling taxonomy shall be authored with qualified stylists/pattern makers: color relationships, saturation/contrast/undertone with opt-in, silhouette balance, texture/material pairing, layering, occasion formality, activity comfort, weather, cultural **self-declared** requirements, mobility, clothing access and sustainability. Each rule gets source, scenario, exclusions, case examples, measurement and user override. Personal tastes outrank rigid fashion orthodoxies. Multi-candidate diversity prevents one-size-fits-all aesthetic stereotypes. “Most beautiful/ideal body” classifiers are prohibited.

**Feedback test:** `sample body/style → context → 3 candidates → expert blind comparative ratings + user preference` using consenting users. Score decision *usefulness and explanation*, not an objective “beauty percentage”. Track mismatch and opt-out.

---

# 30. THE PERFECT STYLIST INPUT POLICY — AGE, CULTURE, SKIN TONE, ASTRO, OCCASION

## 30.1 User-understood input layers

**Core (P0):** desired occasion, time, city (manual allowed), activity and dress code, weather, garment availability/clean state, user favorite/avoided colors and cuts, outfit history. 
**Optional (P1):** age band or birth date, hair style silhouette, voluntary approximate skin-palette sample, fit/comfort preferences, meeting significance, culture-specific dress rules **explicitly provided by user**, personal calendar event manually selected and summarized locally (never silently read full calendar). 
**Symbolic (P2):** opt-in astrology/numerology inspired color or mood prompts, with a clear explanation. No default hidden astrological personalization.

Questions should be as human as “Nereye gidiyorsun?” / “Nasıl hissetmek istersin?” / “Rahat mı, daha resmi mi?” / “Kendini burada nasıl görmek istiyorsun?” rather than personal-data questionnaires. Avoid ageist dress rules (“30 yaşını geçtiğin için giyme”). Do not deduce religion, ethnicity or cultural identity from GPS or skin color.

## 30.2 Occasion types and dress intelligence

Registry: work/office; job interview; first date; romantic dinner; school/university; graduation; wedding attendee; wedding party; family visit; religious/cultural ceremony **only if stated**; sports/outdoor; festival/concert; brunch/café; travel/airport; formal presentation; beach/hot weather; rainy commute; night out; business casual; at-home. For each: declared dress-code, exposure to outdoors, temperature variability, mobility, sitting/walking duration, shoe comfort, layering, weather, garment cleanliness, and formalness, with outfit explanations and alternatives. No inferred safety/health claims.

## 30.3 Skin/hair and color recommendations

If user chooses `Renk önerilerini kişiselleştir`: optional user-selected photos or live camera sampling **on-device**, suggest broad illumination-robust palette with color-temperature uncertainty, let user manually select what looks right. No face recognition or face embedding necessary; pixel sampling from selected area with transient exposure. Mixed lighting/filters/makeup may defeat color estimations; never guarantee undertone classification. All palette processing optional, revocable, confined to device, no skin-ethnicity estimation. Accessibility: do not rely on color alone; explicit labels and high-contrast mode.

## 30.4 Birthdate and symbolic layer: transparency required

- User requests birthdate-based age and symbols. Offer `Yaş aralığı` and `İsteğe bağlı doğum tarihi` as distinct inputs. For routine age-aware event logic, retain only age band rather than full birth date when possible; user can delete all symbolic inputs separately.
- `Astroloji ve numeroloji ilhamını kullan` OFF by default; dedicated consent, non-scientific disclosure, concise purpose, on-device calculation only. Display `İlham kaynağı: sembolik stil seçimi` if it influenced anything. 
- Never hide use simply because user asked “belli etmeden”: **subtle, beautiful UX is allowed; undisclosed inferred profiling is not.** A professional app can keep the presentation elegant while being honest in Settings and “Neden?” details.
- `SymbolicInspiration` can only modestly re-rank visually equivalent outfits/colors if safety/weather/garment fit is not worsened, and must not assert that astrology/numerology objectively determines which clothes fit or attract success.
- This feature must work without importing XRAI datasets; no data sharing without new explicit purpose-appropriate consent and separate legal design.

## 30.5 Clean/worn control

Wear event ≠ dirty verdict. The app never knows sweat, stains or hygiene from calendar days. Optional user tagged: `Temiz`, `Giyildi—kontrol et`, `Havalandır`, `Yıkamada`, `Dolaba döndü`. Proactive nudge if worn on consecutive days: “Bu parçayı tekrar kullanmak ister misin? Temizliğini sen kontrol et.” No automatic negative judgment of the person or recommendations based on unfounded assumptions.

---

# 31. UX/UI EXTENSION — ONE-GLANCE PRODUCT WITH DEEP BODY LAB

## 31.1 IA (top-level remains minimal)

Four tabs maximum: `Bugün`, `Dolabım`, `Dene`, `Ben` — optional swipe segmented views within; no giant wall of AI tool names. The intelligence exists below the surface, not as 14 scary bots. Primary screen should answer **what should I wear today?** and **can I quickly try this item?**.

### Critical new screens and states

| Screen ID | Surface & task | Key interactions | States and accessibility |
|---|---|---|---|
| `UI-B01` | Create My Model | select neutral shape, optional selfie, height, direct privacy explanation | no photo path required; no gender forced |
| `UI-B02` | Living Body Studio | tappable 3D body, region sliders, ±, undo/redo, front/side/back, clothes on/off only with safe mannequin | VoiceOver slider semantics, large increment controls, thermal degrade |
| `UI-B03` | Precision Measurements | optional measured cm, source badges, tapemeasure guide, warning mismatch with visual morph | user-manual; no fake cm estimate |
| `UI-B04` | Compare Revisions | before/after side-by-side synchronized camera, restore/cancel | no auto-save during accidental drag |
| `UI-T01` | Instant Scan | center framing, detected barcode/OCR, brand/variant uncertainty, no tracking indicator | denied camera → manual SKU & photo picker |
| `UI-T02` | Product Identity Check | possible matches, choose correct style/color/size, source details | ambiguous → user picks, never fabricate |
| `UI-T03` | Try-on Stage | avatar+product, instantly show G0/G1 then optional richer asset, size controls, rotate, back view | offline cached, slow connection, render fallback, visible G-tier |
| `UI-T04` | Size & Fit Evidence | suggested 0–2 sizes, labeled sizing source, body measurements used (only on phone), unknowns | no size chart → honest abstain |
| `UI-T05` | Fabric/Cut Inspector | material, stretch, cut, thickness, shrink risk only if evidenced | contradiction details, no invented spec |
| `UI-T06` | Compare Sizes/Brands | two product variants or sizes, same camera/body for fair comparison | show missing info, no brand bias |
| `UI-S01` | Occasion Composer | where/when/formality/feeling, weather, self-declared dress constraints | manual city/time no permission needed |
| `UI-S02` | Mood/Palette Preferences | palette and outfit inspirations, optional camera color analysis | opt-in / disable / delete |
| `UI-S03` | Recommendation Why | facts vs tastes vs symbols vs promotion, source drilldown | clear labels, minimum tap count |
| `UI-S04` | Symbolic Styling Settings | OFF by default, opt-in DOB, delete and separate purpose toggle | can turn off without losing outfits |
| `UI-R01` | Partner Scan Badge | store partner catalog verified, scanned variant TTL, no personal data visible | offline/unpartnered store path |
| `UI-R02` | Privacy & Data Controls | separate gallery/photos/body/location/age/symbols/retail consents, delete locally | test revocation and deletion |

All existing v1.0 UI layouts and design tokens still apply. The above extends them, not replaces them. No surprise mandatory account sign-up. Hero copy avoids medical language, body beauty rankings, “perfect body” messaging or guarantee that no fitting room is needed. 

## 31.2 Visual language and interaction specifics

- **Body editor:** a calm neutral graphite background vs warm-gray avatar, subtle gold/soft-blue focus outline only as interaction; tactile slider track, not anatomical sensual emphasis. Ensure WCAG-compliant text, reduced-motion, high-contrast alternative, small-screen layout and Dynamic Type for controls. Do not use accent red/green as sole confidence cue.
- Motion: changing selected body zone smoothly crossfades highlight; updating geometry must be continuous even while user pans camera; haptics light on slider detent and undo; no loud sound. Avoid aggressive gamification of body change.
- Interactive slider UI behavior: `tap body area` → contextual controls, `drag slider` → active live morph, `hold ±` → controlled increments, `type value` → if confirmed cm known then explicit mode, `double tap value` → reset local region, `Undo` and `Before` → restore.
- No “sex/gendered anatomy sliders.” Breast/chest circumference is fit geometry without sexualized texture. Garment department filters may be chosen on browsing, independently from any user identity field.
- `Confidence capsule`: “Ürün doğrulandı” / “Yaklaşık görsel” / “Beden tablosu yok” / “Deneyerek doğrula” are neutral, not high-pressure. 
- Product compare should normalize visual zoom and scene light; otherwise users misinterpret differences caused by camera position.

## 31.3 Example micro-journeys

**A. Without gallery access:** open app → choose model template → enter optional height → fine-tune waist/shoulder in studio → add one garment from camera → manually tag → same-day outfit. 
**B. At Levi's shop:** barcode → partner licensed? if yes exact variant → ask for waist/hip/inseam *only if missing and necessary* → display candidate size evidence → display G-tier on avatar → “Gerçek deneme gerekebilir” → optional owned item / shop page. If no partner, fall back to user-visible size guide + manually entered label values without false precision. 
**C. First date tomorrow:** user selects city and evening outside→in, selects style/mood, local weather→layer-compatible options, avoid laundry items; one-tap outfit and plan; optional symbolic personalization only if opted in. 
**D. Low battery:** quick store scan still possible at reduced graphics; optional gallery batch paused; privacy audit local; user never sees unexplained battery drain.

---

# 32. RETAIL GO-TO-MARKET: HOW TO WIN BRANDS AND STORES

## 32.1 B2B product is measurable operational software, not “look, 3D!”

**Retailer pains to validate** (not assume universal): fitting-room queues, staff handling overhead, shopper indecision, wrong-size purchase/returns, online/offline inconsistency, missing product attributes, excess store traffic load. For a retailer, the value is proven on **specific SKUs, conditions, store layouts and shoppers**; not all customers will skip try-on. 

**What partner receives:** Retail Dashboard with product/catalog quality scores, anonymized aggregated scans and candidate sizes by product without person-level body, opt-in usage funnels, fitting-room queue study outcomes, product feed validation, and experiment cohort analysis. No raw body measurements/photo/avatar/disclosed birthday/astrological state. 

**Partner integration options** (in order):
1. `Lite feed pilot`: simple CSV/JSON product variants + licensed images + size chart + pilot GTIN. Lowest barrier for boutiques.
2. `PIM/ERP Sync`: partner-approved catalog imports, versioned returns, failures surfaced, inventory optional. Validate SKU/GTIN uniqueness.
3. `Store link/QR`: signage/QR pointing to WEARFORM verified preview with explicit catalog licensing, no Wi-Fi tracking or hidden person linkage.
4. `Retail Console`: tenant-specific catalog QA and aggregated experiments; staff has no access to personal consumer body data.
5. `Enterprise SDK/API` (later): embedded try-on inside retailer apps, strict process boundary, audited privacy SDK without remote body transmission, commercial SLA, kill-switch.
6. `Technical garment pipeline`: vendor-provided CAD/3D garment size variants and fabric metadata under license to improve G3/G4. Contractually secure rights and usage permissions.

## 32.2 Founder outreach sequence and agreement plan

`Partner shortlist → commercial discovery → evidence packet → permission & security checklist → scope contract → 100–500 licensed variants (pilot hypothesis, partner-dependent) → 2–4 week baseline → limited controlled deployment → independently measured impact → renewal decision`.

- **Phase A**: One small cooperative fashion shop (can iterate GTIN/SKU and test body data boundary). **Phase B**: Local chain store/retailers in the same city. **Phase C**: Approach brand HQ/product teams for model-specific size/drape data. Do not imply existing LC Waikiki/Mavi/Levi's/J&J/Hugo Boss/CK agreements.
- Roles to identify: e-commerce director, retail operations manager, PIM/ERP integration lead, legal/privacy officer, merchandising/product development lead, procurement and marketing. Technical fit data often originates with **pattern makers and production tech packs**, not a marketing web page.
- Pitch 30-second logic: “Müşteriniz ürünü okutur, kendi telefonundaki gizli avatarında görür, mevcut beden tablonuzla en olası bedeni anlayabilir. Siz müşteri vücudunu görmezsiniz. Bir pilotta kabin kuyruğu, karar süresi ve iade etkisini birlikte ölçeriz.” 
- Required partner assets: verified brand ownership/authorized representative, terms of catalog/media/size-chart usage, region/currency/date rights, API key and scopes, cache/update limits, per-SKU measurements, video/photo license, product removal process and data-protection commitments.

## 32.3 B2B contracts and negotiation cards

| Contract module | Required commercial/legal decision |
|---|---|
| Data processing & roles | controllers/processors/independent controllers by function, minimum access, retention, lawful basis |
| Product rights | display/transform/cache licensed garment imagery/CAD/technical charts; territories; revocation and takedown |
| Data quality SLA | variant keys, chart completeness, sizing method, update cadence, known errors and dispute procedure |
| Security | tenant isolation, authentication/authorization, audit logs, incident notice, penetration testing |
| No-body-data commitment | no raw measures, photos, derived personal fit vectors in network or partner exports; client-side computation |
| Pilot | stores, dates, KPI definitions, control groups, consent/signage, who collects queue data, thresholds |
| Pricing | setup/import/support costs, trial period, per store/SKU/API call SaaS structure, enterprise custom SLA, no guaranteed financial benefit |
| Exit and portability | catalog removal, data deletion, export of partner-owned inputs, user autonomy from partner app |
| Legal review | KVKK/GDPR, consumer protection, marketing claims, copyright/trademark, retailer terms |

## 32.4 Pilot design and cause of queue change

**Primary experimental question:** For eligible products and participating customers, does providing WEARFORM lower *unnecessary* cabin usage and time-to-decision without lowering satisfaction/raising returns?

- Measure baseline and controlled test for comparable days/hours/season/store footfall, with control groups or stepped rollout; don't just compare a quiet Tuesday to a busy Saturday.
- Record **aggregate counters**: actual fitting-room arrivals/queue waits, median and p90 duration, foot traffic, scanned candidate products, self-reported decision confidence (optional), purchase conversion if retailer can measure privacy-preserving, returns over sufficient follow-up, store staff time, problem incidents. Report measurement bias: only tech-savvy users opt in, promotional confounders, category and traffic effects.
- `Queue reduction % = (baseline eligible queue demand – adjusted treatment queue demand) / baseline eligible demand`, with control adjustment and uncertainty interval; do not attribute all changes to the app.
- Critical negative test: shoppers follow false fit guidance → increased returns/rework. This can invalidate the rollout even if queue shortens.
- **Privacy:** Retailers receive only sufficiently aggregated, thresholded data; small-cell suppression and no timestamp-location quasi-identification. Aggregation claims require technical proof; no user-specific event trail.

## 32.5 Brand partnership roadmap

`Local authorized retailer data → one brand category with documented size chart → style-specific fit validation → enriched garment CAD feed with tech packs → optional in-store signage/QRGateway → national retailer pilots → regional expansion → licensed marketplace integrations.`

B2B sales cycle may be long; maintain consumer utility even with zero signed partners. Retailer must never gate personal closet access or user-provided photos. Distinguish consumer product-lookup cache from privileged partner feeds.

---

# 33. CONSUMER MARKETING, GROWTH LOOPS, REVENUE AND COMMERCIAL DEFENSIBILITY

## 33.1 Consumer “aha” and acquisition

Strongest demonstration: **scan a real product → instantly see plausible silhouette on own adjustable avatar → see credible size-guide evidence or transparent uncertainty**. Secondary sticky value: **tomorrow's outfit from what you already own**, with weather and laundry-awareness.

Go-to-market channels to test independently: short before/after scan explainer with synthetic/demo avatars, store QR co-marketing, microcreator fashion educators, university/city style challenges based on outfit ideas (not body ideals), referral to garment collection/template (not private body), SEO search for brand size guides where allowed, partner announcements, App Store product page, organic wardrobe digitization guides. Never show someone's body data or private photo as viral bait.

**Conversion funnel:** `App Store discovery → install → no-login first useful result → optional avatar save → first outfit → first store scan → second weekly use → referral/shop partner` with consented coarse measurements; zero-data analytics path remains fully functional. Focus on time-to-value, not aggressive notifications.

## 33.2 Growth loop engine (hypotheses, not guaranteed virality)

1. **Outfit Share Loop:** User builds outfit → creates a **privacy-safe composition** (garment thumbnails, generic avatar or user chosen render; neutral background; no body dimensions/DOB/coordinates) → exports share card by explicit action → viewer sees product utility → installs app. Share preview is inspectable before export.
2. **Retailer QR Loop:** Retailer places approved signage → shopper scans product → useful fit/preview → retailer sees aggregate experiment value → more product-data completeness → more shoppers. Requires genuine permission and proof.
3. **Wardrobe Value Loop:** More accurately categorized clothes + accepted outfit feedback → better everyday suggestions → more engagement and items organized. Avoid turning into endless photo import workload.
4. **Size Accuracy Loop:** User manually confirms optional fit outcome → local model learns individual preference; only **voluntary appropriately consented** aggregated fit outcome outside device if the privacy architecture/purpose is approved and users may still use everything without it. Default zero export.
5. **Creative Inspiration Loop:** Stylish occasion templates (public/editorial rights-cleared) → user customizes own wardrobe → optional share → peer discovery. Never rank human bodies.

**Experiment hierarchy:** correctness and privacy > first scan usefulness > retention > referrals > monetization. K-factor calculation only after attribution is lawful and real event data exists. No fake badges or manufactured scarcity.

## 33.3 Pricing hypotheses and sanity math

Consumer: core avatar/body sliders, basic wardrobe and free outfit planning should be available without payment to prove value. Potential premium after validation: higher catalog coverage, expanded scene packs, bulk wardrobe management, advanced fit comparisons, styling collections, planning features. **Never paywall data export/delete/privacy or exact-fit disclaimers.**

B2B: fixed monthly SaaS per store or partner group; setup/integration fee if real cost; enterprise catalog/API tier and separate licensed 3D asset conversion service. Affiliate payments only with clear label, separate from fit ranking. Avoid forcing commission per item if retailer's own sale attribution is weak; start with repeatable pilot fee or limited proof-of-value contract where commercially appropriate. 

Model baseline equations:

```
Revenue_month = activeConsumerPremium * ARPPU + sum(partnerMonthlyFees)
                + validIntegrationFees + explicitAffiliateRevenue
GrossMargin = (Revenue_month - variableCloudAndPartnerCost - supportCost
               - royalties - paymentFees) / Revenue_month
RetailValue = eligibleSalesReturnSavings + staffMinutesSaved*hourlyCost
              + optionalConversionLiftGrossMargin - partnerDeploymentCost
PaybackMonths = CAC / max(positiveContributionPerCustomerMonthly, epsilon)
```

No imaginary CAC/LTV, retailer returns or usage metrics. Inventory of real price/metered GPU/3D authoring costs must be obtained before quotes. Use simple sensitivity scenarios with clearly stated assumptions.

## 33.4 Defensibility test

Not defensible: use of AI, a nice avatar, sliders, dressing recommendations, user reviews alone. Potentially defensible after execution: **deep signed SKU-specific manufacturer quality, consistent local morph-to-garment geometry pipeline, independently validated fit outcome datasets with rights, exceptional privacy trust, low time-to-value, long-term wardrobe preference continuity, real partner distribution**. No false moat claim before data.

---

# 34. PRIVACY, ETHICS, LEGAL, RELIABILITY — HARD REFINEMENTS

## 34.1 Sensitive data and market policy

- Whether a particular body-image/measurement workflow legally qualifies as biometric data depends on purpose and identifiability; treat it as **high-sensitivity personal information by design**, complete DPIA/impact assessment and counsel review before launch. **Do not claim every numeric body measurement is automatically statutory biometric data**, nor that device-only processing magically removes all legal duties.
- Turkey: KVKK's special-category data framework includes biometric information and certain **dress/clothing** data; legal interpretation of the exact use, nature and storage requires qualified local counsel. The product must satisfy proportionality, purpose limitation, revocation, security and deletion.
- EU operation, if any: examine GDPR personal data/biometrics, transparency, automatic profiling, consent, DPIA where applicable, data subject rights and cross-border transfers. No marketing of health, sex or ethnicity signals.
- Apple rules require informed permission and describe data sharing; no sneakily inferred hidden profile. Age and symbolic styling purpose must be visible and independently revocable. Subject safety and appropriateness for teenagers/minors requires separate age policy; initial adult-focused design avoids collecting child body photos.

## 34.2 Attacker and failure scenarios

1. **Partner query carries raw profile** → prevent via compile-time outbound allowlist DTO, integration interception test, independent packet-capture verification.
2. **Photos authorization escalated silently** → permission ledger and limited-library test, no background scan if denied.
3. **Morph engine exposes intimate anatomy** → full neutral coverage mesh, regression screenshots front/side/back/extreme slopes and state transitions.
4. **Malicious 3D asset or decompression bomb** → asset signing, per-file size/vertices/textures bounds, parser sandbox, negative tests.
5. **Review poisoning/fake size feedback** → partner/license verification, spam detection, provenance, threshold, quarantine, abstention.
6. **Calibrated waist overwritten by estimated slider** → independent fields, write ACL, user confirmation, audit and restore.
7. **Model self-learning degrades previous preferences** → frozen baseline and rollback, no silent production rollout.
8. **Location reveals presumed religion/culture** → no such inference; user-entered dress preferences only.
9. **Low battery overheats phone** → DeviceSteward stop/degrade with measured device energy tests.
10. **Retail 'aggregate' leaks one person's scan** → k-threshold grouping, delay, censor small cohorts, no per-user links.
11. **Size chart changed but cache stale** → content version/TTL, user date disclosure, invalidate, fail closed.
12. **Unlicensed brand product photo** → takedown/expiration path, no asset import without rights.
13. **Recommendation embeds hidden astrology** → UI explanation and explicit policy/consent test, default OFF.
14. **Social sharing exports precise body mesh metadata** → redacted, manually previewed share artifact, no EXIF GPS, never export personal measurements silently.
15. **Large local model extraction / app tampering** → appropriate code signing, file protection, model manifest hash, privacy of local data, reasonable limits of device compromise.
16. **Thermal/fairness trade-off** → low-tier device receives correct text alternative, not misleading or silently disabled fit.

## 34.3 Privacy acceptance invariants

```
assertNoNetworkTransfer(BodyProfile, AvatarMesh, PortraitCrop, BirthDate,
                        RawWearHistory, FaceEmbedding, PersonalPalette)
assertProductLookupOnlyContains(authorizedCatalogKey, coarseMarketIfNeeded)
assertDataDeletionPurges(localRawAndDerivedAssets, retainedIndexes,
                         cachedPersonalPredictions, personalModelDeltas)
assertOptionalFeaturesHaveIndependentConsentAndPurpose()
assertOffModeHasNoSymbolicStylingInfluence()
```

Private user exports require explicit action, understandable packaging, encryption option and clear scope. OS backups are a distinct surface; choose file protection and backup exclusion rules according to data type, test restore/deletion. Avoid misleading promise “we cannot ever access anything” if any voluntary support/telemetry path exists; specify actual network egress.

---

# 35. ADDITIONAL DOMAIN DATA CONTRACTS — IMPLEMENTATION-READY SKETCH

## 35.1 Body morph model

```swift
struct BodyMorphControl: Codable, Identifiable {
    let id: String                   // e.g., naturalWaistCircumference
    let region: String               // torso, arms, hips, legs
    var visualNormalizedValue: Double // -1.0 ... +1.0, morph not centimeters
    var safeMin: Double
    var safeMax: Double
    var confirmedCm: Double?          // only separately entered & confirmed
    var measurementMethod: String?    // landmark and protocol
    var source: MeasurementSource     // manual, imageDraft, importedUser
    var isUserConfirmed: Bool
    var updatedAt: Date
}
struct PrivateAvatarRevision: Codable {
    let revisionId: UUID
    let userProfileLocalId: UUID
    let topologyVersion: String
    let controls: [BodyMorphControl]
    let approvedByUser: Bool
    let createdAt: Date
    let contentHash: String
}
```

**Normative data invariants:** visual morph and centimeters never silently copied into each other; source and author recorded; unknown is null rather than 0; revision hashes independent of photos; random local profile ID never transmitted; production serializations versioned + migration tests.

## 35.2 Fit evidence result

```swift
struct ProductFitEvidence: Codable {
    let catalogVariantId: String
    let category: String
    let merchantSizeSystem: String?
    let options: [SizeOptionEvidence]   // 0..2, only if supportable
    let sourceIds: [String]
    let bodyMeasurementKeysUsed: [String]
    let fitAssumptions: [String]
    let unresolvedConflicts: [String]
    let missingRequirements: [String]
    let freshnessDate: Date?
    let claimLevel: String               // NO_EVIDENCE, GUIDE_BASED, VERIFIED_DIMENSIONS
    let renderedGarmentTier: String      // independent of claimLevel
    let rulesetVersion: String
}
```

`RenderedGarmentTier` cannot elevate `claimLevel`. Render can be G3 while no size chart is present; the UI displays a good-looking virtual garment and **no size recommendation**, not an invented W32/M.

## 35.3 Legal catalog adapter

```ts
type PartnerProductVariant = {
  tenantId: string;
  brandId: string;
  sourceRightsId: string;
  sku: string;
  gtin?: string;
  variantMarket: string;
  merchantSize: { label: string; system: string };
  garmentDimensions?: Record<string, {valueCm:number; measurementMethodId:string}>;
  bodyChart?: Record<string, {minCm:number; maxCm:number}>;
  fabric?: { fibers?: Array<{name:string;percent:number}>;
             stretchClass?: 'low'|'medium'|'high'|'unknown' };
  assetTier: 'G0'|'G1'|'G2'|'G3'|'G4';
  authorizedMediaIds: string[];
  version: string;
  lastVerifiedAt: string;
};
// PUBLIC consumer lookup accepts GTIN+market only. NO body/photo/DOB fields.
```

All examples are illustrative contracts pending ADR/SDK compilation, not existing code or deployed endpoints.

---

# 36. IMPLEMENTATION PROGRAM / UPGRADE PACKETS / REAL GATES

Existing WP01–WP26 remain; append **WP27–WP42** with dependencies, owners, evidence and tests. Claude must re-order without violating dependencies and must avoid idle agent proliferation.

| WP | Title | Required predecessor / proof | Non-negotiable deliverable |
|---|---|---|---|
| `WP27` | Canonical body morphology spec | avatar base, topology decision | parameter registry, safety bounds, two unit systems, UX spec |
| `WP28` | Blender body asset compiler | WP27 | shape keys, rig, tests of all parameter extremes, license records |
| `WP29` | iOS live morph engine | WP28, RealityKit capability spike | slider updates, frame metrics, neutral coverage, undo |
| `WP30` | Body measurement wizard | WP27–29 | tape instructions, confirmed/visual separation, edit history |
| `WP31` | Avatar calibration evidence lab | WP30 | synthetic/consented measurement datasets, error stats, abstention |
| `WP32` | Garment tiers & asset compiler | WP28–29 | G0/G1 mandatory and G2/G3 spike, fidelity UI, asset rights |
| `WP33` | Multi-source brand resolver | base catalog and licensing architecture | adapter contracts, GTIN normalization, failure matrix, no illegal scraping |
| `WP34` | Brand/category chart fit engine | WP30, WP33 | case-by-case size selection, sources, missing-evidence abstention |
| `WP35` | Review intelligence and fraud lab | rights-cleared optional data, WP34 | extraction with calibrated precision, report, quarantine, never fabricated reviews |
| `WP36` | Progressive fast try-on pipeline | WP29, WP32–34 | supported cold/warm latency traces, LOD, cancel, fallback |
| `WP37` | Octopus privacy + orchestration | P0 privacy/architecture, existing engines | typed arms, per-arm IO, policy veto, tracing without PII |
| `WP38` | Local feedback/model update lab | WP37 | deterministic personalization + guarded updatable-ML experiment and rollback |
| `WP39` | Occasion and creative stylist | wardrobe/weather baseline | qualified style rules, diversity, explanation, optional color sampling |
| `WP40` | Symbolic mode explicit opt-in | WP39 + legal/consent | separated OFF-by-default local module, data delete, scientific distinction |
| `WP41` | Retail partner acquisition kit | WP33–36 + product claims review | pilot contract template, pitch, feed spec, data sharing matrix, KPI design |
| `WP42` | Consumer GTM & growth engine | actual useful app and privacy review | share preview, QR proof, funnel experiments, no fabricated commercial KPI |

### 36.1 Realistic execution sequence

```
Phase A — decision correctness:
  Current v1 reality audit → morphology physics & data contracts → Blender rig spike →
  locally editable live avatar prototype → safe fit/evidence threshold.
Phase B — trustworthy core:
  wardrobe/photo consent + weather/occasion + fast barcode →
  brand feed mock → complete scan→fit→render flow with G0/G1 → device lab.
Phase C — quality depth:
  garment tier G2/G3 validation + source-specific charts →
  CPU/GPU energy optimization → feedback learner → independent audit.
Phase D — real commercial feasibility:
  partner licensing, first 1–3 merchant pilot, collect audited queue/fit outcomes →
  approve/reject scale-up/Android on evidence.
```

**Do not wait for 100 brand integrations before producing an end-to-end working iOS demo.** Build from transparent `DEMO_ONLY` fixtures, then replace with signed licensed partner feed when available. No partner creates a blocker to the consumer-only release if product catalog is clearly limited.

### 36.2 Minimum new tests — actual runnable evidence required

#### Avatar editor and visual geometry (`T-V11-001` .. `018`)

- 001 live ± slider changes only selected anatomical region; 002 continuous drag responsive on supported device; 003 reset+undo+redo deterministic; 004 saved revision roundtrip; 005 0/unknown does not imply centimeters; 006 manually entered circumference preserved after morph; 007 feet stay grounded; 008 no joint tearing/extreme self-intersection; 009 mannequin stays fully neutral/covered from every camera angle; 010 hair not mistaken for head shape; 011 VoiceOver adjustable action works; 012 Dynamic Type doesn't obscure preview; 013 left/right optional symmetry; 014 changes propagate to supported garment silhouette; 015 no automatic photo inference on drag; 016 iOS fallback mesh path; 017 unbounded low-memory stress abort; 018 front/side/back screenshot evidence.

#### Catalog, brand, fit and reviewer evidence (`T-V11-019` .. `038`)

- 019 GTIN known exact variant; 020 unknown GTIN no fabricated name; 021 wrong country chart refused; 022 shirt vs jeans chart mismatch refused; 023 W/L denim separate axes; 024 inch/cm correct; 025 flat vs circumference no naive 2×; 026 contradictory partner evidence -> abstain; 027 stale chart warning; 028 customer review with ambiguous quality no certainty; 029 missing license excludes asset; 030 no fake `Levi's partnership` badge; 031 missing body measurement permits partial non-numeric explanation; 032 user entered exact measurement is honored; 033 different fit preferences yield reasoned different suggestions; 034 no size label conflated with photoreal G-tier; 035 comparison renders same camera; 036 visual look-alike candidate requires confirmation; 037 no unsanctioned web scraping; 038 manufacturer feed takedown invalidates local cache.

#### Octopus learner, energy, context (`T-V11-039` .. `058`)

- 039 per-arm input least privilege; 040 reject data egress from body; 041 low-power pauses optional gallery work; 042 thermal serious reduces LOD/work; 043 thermal critical suspends heavy processing; 044 photo permission revoked stop scan; 045 offline previously indexed closet still works; 046 model update only on supported compatible model; 047 failed model candidate rollback; 048 user manual avatar data never overwritten; 049 deterministic preference update after `NotMyStyle`; 050 `No symbolic consent` means no astrological influence; 051 explicit consent reveals influence in why; 052 deleting DOB removes symbolic record and predictions; 053 city doesn't infer religion/culture; 054 lighting ambiguity prevents categorical undertone; 055 nonconsenting portrait neither stored nor uploaded; 056 event-only occasion without age works; 057 elapsed wear days doesn't falsely mark item dirty; 058 partner analytics has no narrow single-user cell.

#### End-to-end marketing and pilot (`T-V11-059` .. `075`)

- 059 cold+warm supported cached demo measured per device; 060 unknown SKU error gracefully degrades; 061 moving camera doesn't rerun photo CV; 062 slow network shows G0 first; 063 no accidental deep-link secret sharing; 064 share card preview redacts location/body dimensions/DOB; 065 consentless funnel logs stay off; 066 partner QR verified; 067 tenant isolation cross-account 403; 068 revoked catalog license takes effect; 069 queue baseline denominator formula reproducible; 070 control/treatment footfall matching documented; 071 false fit advice return-rate adverse condition causes rollout halt; 072 consumer use works with no partners; 073 premium off doesn't block core editing/deletion; 074 partner pricing uses true cost estimates; 075 all release claims map to real measured artifacts.

For **every one** of these 75 additions: implement executable case(s), status `NOT_RUN|FAIL|PASS|BLOCKED` linked to file, device/build/OS/commit/result. A bullet on paper is a **test specification**, not a passed test. If a target cannot be tested now, status `BLOCKED` with exact reason and safe fallback.

### 36.3 Gate requirements

| Gate | PASS requires | FAIL/BLOCKED response |
|---|---|---|
| `G-MORPH` | native 3D drag, coverage geometry, undo, no cm fabrication, device screenshot | ship static editable templates only / stop claiming live morph |
| `G-GARMENT` | G0/G1 correct and clearly labeled, license and motion tests | generic style-only visual, not “virtual try-on” claim |
| `G-FIT` | per-SKU unit/size protocol validated, abstention/fairness tests | no suggested sizes; user-visible chart when permitted |
| `G-RETAIL` | signed rights, catalog SLA, partner isolation, measured pilot methodology | no brand partnership or retailer impact claims |
| `G-LOCAL-AI` | reproducible model card, thermal/power/privacy tests, rollback | deterministic model+local user edits only |
| `G-ETHICS` | no hidden symbolic inference / culture deduction / body scoring, full consent controls | disable relevant feature |
| `G-RELEASE` | real devices, accessibility, legal review, security, build, evidence mapping | do not call product production-ready |

### 36.4 New expert implementation roles (augment existing 15, consolidate overlaps)

`Parametric Human Geometry Engineer` (topology, morphs, rig); `Technical Apparel Patternmaker/Size Scientist` (pattern ease and semantics); `Computational Garment Simulation Engineer` (real vs proxy drape); `Retail Catalog Licensing/Data Steward` (rights/version); `Edge ML Energy and Thermal Engineer` (models, battery, scheduler); `Retail Experiment Statistician` (causal queue assessment); `Fashion Color/Occasion Creative Director` (style rules); `Independent Body Inclusivity/Accessibility Auditor`. Expertise roles are logical review responsibilities; do not claim 8 paid specialists were hired or that separate runtime AI systems exist. A single agent may implement several with independent scripted checks, but no one self-certifies a critical gate without a separable audit.

---

# 37. FINAL CLAUDE CODE INSTRUCTION — V1.1 PRECEDENCE & AUTONOMY

> **CLAUDE: READ THE ENTIRE v1.0 IN THE CANONICAL MERGED v1.1 FILE PLUS THIS V1.1 AMENDMENT; START CODE, NOT JUST A LONG PLAN.** First determine repository facts, code and toolchain. Prepare one concise baseline, one ADR for avatar morph and fit/rights boundary, then implement the first meaningful vertical slice in the existing repo. Do not invent real customer data, merchant rights, test passes or screenshot evidence. You are authorized to perform reversible repository work and run available local tests. Paid cloud, public publication, accessing external paid/secret accounts, signing commercial agreements, sending marketing messages and shipping to stores require human permission. Work locally with synthetic assets when blocked; clearly report blockers.

At the end of each execution unit, return:

```
WEARFORM V1.1 EVIDENCE REPORT
- Repository/branch/commit:
- Implemented / tested / device-verified (separately):
- Tests (exact commands, summary, logs):
- UX evidence (screenshots with device/build/OS):
- Avatar fidelity tier and fit evidence tier:
- Privacy/energy/resource observations:
- Partner catalog licensing and source status:
- Benchmark deltas and regression:
- Critical risks / BLOCKED / UNKNOWN / STOP-THE-LINE:
- Next dependency-safe work package:
```

**Mandatory first user-visible execution target:** iPhone prototype where person starts with a neutral gray body, drags waist/hip/shoulder/chest/thigh sliders, sees continuous valid geometry live, safely changes clothes from G0/G1 original licensed templates, scans a synthetic barcode and receives an explicitly source-supported or abstaining size suggestion; all local private measurements remain offline. This is the “proof of taste” of the product, not a generated marketing video.

---

# 38. VERIFIED REFERENCE LINKS & RESEARCH TO RECHECK

Sources below describe publicly documented **capabilities/policies only**; they do not evidence a built WEARFORM feature, accessible partner data or model accuracy. Recheck at implementation time against specific SDK version and country's law:

1. Apple RealityKit mesh deformation / skinning / blend shapes: https://developer.apple.com/documentation/realitykit/scene-content-mesh-deformation
2. Apple RealityKit models and meshes: https://developer.apple.com/documentation/realitykit/scene-content-models-and-meshes
3. Apple on-device updatable models (only designated updatable Core ML): https://developer.apple.com/documentation/coreml/personalizing-a-model-with-on-device-updates
4. Apple PhotoKit user permission and limited library: https://developer.apple.com/documentation/photokit/delivering-an-enhanced-privacy-experience-in-your-photos-app
5. Apple energy/thermal responses: https://developer.apple.com/documentation/xcode/responding-to-power-notifications
6. Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
7. Google Merchant product attributes and variant structures: https://support.google.com/merchants/answer/14779112?hl=en
8. Google Merchant API authenticated account access: https://developers.google.com/merchant/api/guides/authorization/access-your-account
9. Levi's actual apparel size chart (example of a manufacturer chart, not blanket licensing): https://www.levi.com/GB/en_GB/info/sizechart
10. Alta feature comparator (official current public claim, do not assume technical implementation): https://www.altadaily.com/
11. Turkish KVKK special-category data overview: https://www.kvkk.gov.tr/Icerik/2051/Ozel-Nitelikli-Kisisel-Veriler

**Standing mandate:** If public references, Apple APIs, laws or partner terms changed after this document's date, Claude must verify current authoritative sources and record updated ADRs before relying on them. No claims about contracts or consent are inferred from publicly visible brand websites.

---

**END OF HISTORICAL V1.1 ADDITIONAL CONSTITUTION. CONTINUE TO BINDING V1.2 §§39–58 BELOW.**


# WEARFORM — GOD LEVEL v1.2 BINDING AMENDMENT
## TRAVEL INTELLIGENCE · DESTINATION STYLIST · CAPSULE PACKING · CULTURAL CONTEXT · PRIVATE ON-DEVICE TRIP BRAIN

> **Version:** v1.2, 03 November 2026. **Status:** binding product/engineering specification; not implementation or test evidence. **Canonical priority:** This amendment takes precedence over any conflicting v1.0/v1.1 assumption *only for travel-mode scope*. All existing privacy, evidence, truthfulness, body neutrality and external-action authorization rules remain in force. **Instruction to Claude:** Read canonical v1.2 merged file section 0, then §§39–58, then base §§1–38; audit repository and implement the first dependency-safe travel vertical slice after or alongside stable shared wardrobe primitives. Work autonomously on reversible local engineering tasks; do not claim external service access, paid subscription, partnership or deployment without evidence and authorization.

---

# 39. V1.2 CHANGE CONTROL — WHAT TRAVEL MODE MUST ACTUALLY DO

## 39.1 Founder's non-negotiable intent

**Bir kişi bir destinasyon ve seyahat süresi seçtiğinde WEARFORM, o kişinin gerçek dijital dolabından yararlanarak seyahat boyunca nerede/ne yaparken/ne giyeceğini, hangi kıyafetleri valize koyacağını, gerektiğinde neleri tamamlaması gerektiğini, hangilerini yeniden kullanabileceğini ve seyahatin şartları değiştiğinde planı nasıl uyarlayacağını güvenilir biçimde önermelidir.** Sistem bir kişisel stilist, modelist, kumaş/kalıp bilgisi uzmanı, valiz planlayıcısı ve kültürel bağlamı saygıyla yorumlayan seyahat asistanı gibi davranmalıdır; bunlar gerçek dışı tek-model süperzekâ iddiaları değil, ayrı sorumlulukları ve testleri olan modüllerdir.

Kullanıcının seyahat tipine göre şehir, ülke, tarih, süre, günlük program, yürüyüş miktarı, konaklama/çamaşır imkânı, valiz sınırı, etkinlik ve stil tercihleri birlikte değerlendirilir. Dört ekranı açıp 30 ayar yaptırmak yerine kısa bir akışla ilk sonuç çıkarılır; ayrıntılar isteğe bağlıdır.

## 39.2 Rekabetçi gerçeklik / konumlandırma

Whering, seyahat kombin planlama ve packing list özellikleri sunmaktadır; PackPoint süre, hava ve etkinliğe göre valiz listesi oluşturduğunu belirtmektedir. Bunlar kullanıcı gözünde mevcut taban beklentilerdir. WEARFORM'un sınanacak farklılaşması: **gerçek yerel gardırop + ayarlanabilir kişisel 3D avatar + ürün varyantı ve kumaş bilgisi + hava/bölgesel koşullar + etkinlik günlüğü + kapsül valiz optimizasyonu + kaynak/güven açıklaması + yolculuk sırasında yerel yeniden planlama**. Bir fonksiyonun rakipte olup olmadığını uygulamayı incelemeden kategorik iddia etme.

## 39.3 Scope/prioritization

| Priority | Output | Boundary |
|---|---|---|
| P0 | 1 destinasyon, 1–14 günlük seyahat; tarih ve etkinlikler; gardırop bazlı günlük 1–3 kombin; valiz listesi; elle düzenleme; offline mevcut plan | Dış hava API'si yoksa durum etiketi ve örnek/iklim fallback; gerçek ürün/kişisel veri uydurma yok |
| P0 | Hava kaynağı/zaman etiketi, forecast-vs-climatology ayrımı; kıyafet temizliği onayı; içeriği silme; düşük pil/ısı uyumu | Giysi hijyeni ve hava kaynaklarının belirsizliği gösterilir |
| P1 | Çok duraklı seyahat, valiz ağırlık limiti, kültürel/venue giyim gereklilikleri, etkinlik-saat eşlemesi, yeniden paketleme ve tatil esnasında adaptasyon | Kaynak yoksa kullanıcı doğrulaması gerekir |
| P1 | 3D günlük prova/şehir sahnesi; eksik parçayı marka-ürün karşılaştırmasıyla arama; mağaza ön hazırlığı | Görsel sahne gerçek yer/gerçek zaman iddiası yapmaz; lisanslı veriler |
| P2 | Tren/uçak takvimi *izinli* içe aktarma, seyahat arkadaşıyla yalnız redakte paylaşım, gelişmiş bagaj bölme/katlama önerileri | Haricî hesaplar ve veri paylaşımı ayrıca onaylanmalı |
| Deferred | Kabinin/kültürün gelecekteki havasını kesin bilme; üniversel beden uygunluğu; her ülkede otomatik resmî giyim kodu; tam fotogerçekçi 3D gezi sahnesi | Bunlar yanlış kesinlik veya maliyet üretir |
| Rejected | Kullanıcının dinini/etnisitesini/kimliğini konumdan çıkarmak; kültürü stereotiplemek; gizlice rezervasyon/e-posta/galeri taramak; sessiz satın alma | Mahremiyet, güven ve adalet ihlali |

## 39.4 Non-negotiable design slogans

`PACK WHAT YOU OWN FIRST.` · `DRESS FOR THE DAY, NOT JUST THE CITY.` · `SHOW THE WHY.` · `NEVER FAKE WEATHER.` · `NO CULTURAL STEREOTYPES.` · `THE USER OWNS THE FINAL SUITCASE.` · `AIRPLANE MODE MUST WORK.`

---

# 40. TRAVEL JOBS, PERSONAS, OUTCOMES AND HARD CASES

## 40.1 Core jobs-to-be-done

1. **Tatile çıkmadan:** “Beş günlüğüne gidiyorum; dolabımdakilerle az eşya taşıyarak her güne hazır olmak istiyorum.”
2. **Gezide:** “Bugün serin ve rüzgârlı; öğlen müzeye, akşam restorana gideceğim. Valizimden hangilerini kombinleyeyim?”
3. **Özel davette:** “Akşam düğün/konferans/restoran için giyim beklentisine uygun, bana yakışan seçenek olsun.”
4. **Bütçe kısıtlıyken:** “Eksik bir parça gerekirse önce mevcut dolabımdan alternatif bul; satın almayı zorunlu gösterme.”
5. **Valiz sınırı varken:** “Kabin çantama sığsın; fazla eşya ve son gün çamaşır sıkıntısı yaşamayayım.”
6. **Birden çok iklimde:** “İzmir'den Oslo'ya, sonra başka şehre geçiyorum; transfer ve katmanlı giyim hesaba katılsın.”
7. **Dolap eksikken:** “Henüz fotoğraf yüklemedim; yine de kategori bazında işe yarar genel valiz listesi alayım.”

## 40.2 Success outcomes (do not invent improvement figures)

- Anlaşılır ilk planın oluşturulma oranı; kullanıcı başına gerekli manuel etkileşim sayısı.
- Kullanıcının gerçekten valize koyduğu listenin önerilen listeye eşleşmesi, daha sonra isteğe bağlı geri bildirim.
- Yanlış / unutulan kritik öğe bildirim oranı; yanlış hava/venue iddiaları sıfıra yaklaştırılmalı.
- Outfit satisfaction, cold-start, offline utility, battery usage, travel retention; uygun örneklemde yeniden kullanım.
- *Kullanıcı beyanına dayalı* “fazla eşya aldım/eksik aldım” oranı; doğrulanmamış bagaj tasarrufu reklamı yasak.
- Hassas konum/kültür/yaş etkilerinde sıfır gizli çıkarım; ayrımcılık ve açıklanamaz öneri red-team testleri.

## 40.3 Deliberately difficult travel cases

- Forecast horizon ötesi, tarih henüz belirli değil, iki ülkede aynı adlı şehir, hem yaz hem kış bölgeleri, 3+ mikro iklim, yağmur + rüzgâr + gece soğuğu, ani hava değişimi.
- Açık hava yürüyüşü/deniz/plaj + resmi akşam yemeği aynı gün; aktivite kıyafet değişimi ihtiyacı.
- Uygun ayakkabı yok; ayakkabının aşınma durumu bilinmiyor; önemli uyum konuları fotoğraftan çıkarılamaz.
- Hijyen belirsizliği, her gün aynı jean'in giyilebilmesi ama iç çamaşırının yeniden kullanımının varsayılmaması; kullanıcı hassasiyeti.
- Kullanıcı erkek/kadın/başka kimlik fark etmeksizin giyim önerilerinin beden ve tercih üzerinden çalışması; zorunlu cinsiyet kategorisi bulunmaması.
- Görme veya hareket kısıtlılığı olan kullanıcının rahat giyim/ayakkabı tercihini kendisi belirtmesi; sağlık çıkarımı yapılmaması.
- Hava API çevrimdışı; son güncelleme eski; varış saat dilimi ve yaz saati farkı; uçağın gecikmesi kullanıcı doğrulaması olmadan varsayılmaz.

---

# 41. 30-SECOND TRIP WIZARD — DATA MINIMIZATION WITH HUMAN CONTROL

## 41.1 P0 quick input

**Step 1: Nereye/ne zaman?** Destination city/place lookup or manual city+country, departure & return calendar dates; dates are inclusive and computed in destination's IANA time zone. “5 gün” = user-visible 5 calendar days, unless the user entered 5 nights; ambiguity must be resolved in UI not silently guessed.

**Step 2: Ne yapacaksın?** Multiple-select presets: gezi/yürüyüş, iş/toplantı, resmi etkinlik, sahil/havuz, müze/şehir, akşam yemeği, doğa/trekking, spor, aile ziyareti, gece eğlencesi, rahat dinlenme, diğer. For each day optionally add time block, indoor/outdoor, formality, dress code from invitation, footwear demands. Non-selected activity cannot be inferred from GPS history.

**Step 3: Valiz/çamaşır?** Cabin bag/check-in/none, manually supplied dimensions/weight or “bilmiyorum”; access to laundry yes/no/unknown; willingness to repeat bottoms, outerwear, and tops individually; weather sensitivity optional. Travel companions are irrelevant unless requested; children's packing is explicitly separate consent/control scope.

**Step 4: Kendi dolabından planla.** Preselected owned wardrobe (never auto-upload), missing catalog fallback; user can skip photo permission; no mandatory birthday, skin-tone classification, gender, precision location or account. Generate draft then reveal five-day timeline, compact list and rationale.

## 41.2 Optional profiles

`TripPreferences` holds preferred aesthetics, modesty coverage and venue dress constraints *by explicit input*, favorite palette, heel/flat preference, layering tolerance, packing-light priority, comfort-vs-formality, shoes-per-day limit, reuse/laundry rules, special-purpose items (equipment). Body sliders affect visualization/fit only as designed in §§24–26; travel location cannot read full mesh when not necessary.

## 41.3 Location and permissions

- The travel mode needs a **destination**, not necessarily device geolocation. Default to searched/typed city; don't prompt “always allow location.”
- Current location only for optional departure weather; foreground *when-in-use* only with explanation and clear “Yazarak seç” alternative.
- `PhotosPicker` user-selected garment import is default; bulk library scan is separate opt-in and follows existing photo privacy constitution.
- No calendar/e-mail/booking sync by default. Future import requires explicit action, narrow permission and local parsing.
- Birthdate is never necessary for packing. Age/life stage may be expressed as mobility/comfort style preference; no covert age scoring. Astrology/numerology remains optional disclosed inspiration, never a factual weather or venue rule.

## 41.4 Trip states

`DRAFT → PLANNED → PACKING → DEPARTED → IN_TRIP → RETURNED → ARCHIVED | DELETED`, with non-destructive edits, versioned plan, day selection, data expiration option. Changing dates/destination invalidates weather, event contexts and freshness flags; wardrobe stays intact. Cancellation does not delete the user wardrobe. Travel plan and event notes stay device-local.

---

# 42. DESTINATION WEATHER ENGINE — REAL FORECAST, CLIMATOLOGY, AND OFFLINE

## 42.1 Source strategy and capability boundary

**Primary iOS candidate:** Apple WeatherKit Swift API, subject to actual developer entitlement, quota, terms and attribution verification; WeatherKit exposes current, hourly/daily forecasts and applicable alerts. Its public overview advertises up to 10-day hourly forecasts. Do not hardcode a guaranteed horizon across places/conditions; inspect available returned periods. This app may show a provider-attributed weather card (must implement current contractual attribution requirements). Reference: https://developer.apple.com/weatherkit/ ; https://developer.apple.com/documentation/weatherkitrestapi ; https://developer.apple.com/documentation/weatherkit/weatherattribution .

**Alternative:** Open-Meteo, only after reviewing its applicable commercial plan, dataset licensing, attribution and current terms; noncommercial public endpoint must not be assumed authorized for commercial launch. Reference: https://open-meteo.com/en/pricing . Use `WeatherProvider` interface with mock fixtures to avoid hard dependency.

**A trip dates beyond forecast window:** Show `SEASONAL_GUIDANCE` based on legitimately sourced climate normals/ranges with source, granularity and explicit “mevsimsel beklenti, hava tahmini değil”. If no verified climate dataset is licensed/cached, show `NO_DATA` and broad human-editable layering suggestions, not fabricated degree numbers. When days enter forecast range, refresh only if user has granted network and quota permits.

## 42.2 Weather data contracts

For each destination/day/time block:

- `timeZoneID`, `localDate`, optional `timeBlock`, `forecastIssuedAt`, `retrievedAt`, `validFrom`, `validTo`, `provider`, `licenseAndAttribution`.
- Temperature min/max/apparent if available, precipitation chance/intensity, wind/gusts, humidity, UV, cloud, snow/ice, weather alerts and confidence/freshness metadata.
- Required `sourceMode`: `LIVE_FORECAST | CACHED_FORECAST | SEASONAL_GUIDANCE | USER_OVERRIDE | NO_DATA`.
- `forecastAge` dynamic; selected day can show “Tahmin henüz yok”, “Son güncelleme: …” or “Çevrimdışı, son bilinen tahmin”. Do not fabricate confidence percentage; confidence must derive from evaluated forecast/provider metrics, otherwise verbal label only.
- Alerts appear with official provenance and exact unmodified wording where rights/policies require; do not invent local safety recommendations and don't convert clothing app into emergency-service replacement.

## 42.3 Weather-to-wardrobe decision layer

Determine outfit utility from `perceivedTemperature × precipitation × wind × activityIntensity × indoorOutdoor × timeOfDay × garmentLayering × userTempPreference` and available wardrobe materials. Prefer adjustable layers over a single outfit when day/night variability high. For active walking/travel suggest comfortable footwear and breathable layers conditional on actual owned inventory. No claims that a specific fabric is waterproof or thermal unless catalog/user evidence supports it. Exact SPF/waterproof rating and sun/heat safety are not inferred from garment color alone.

## 42.4 Refresh and resource budgets

- On trip creation fetch destination weather *once* with dedupe, debounced replan; cache per destination/time period; TTL depends on provider policy and weather change risk; surface stale flags.
- Do not poll every minute or run constant GPS. OS-sanctioned refresh/background delivery where practical, subject to user settings and OS scheduling; no promised exact notification time.
- On airplane mode recompute outfits from cached signals; if absent show date/activity-only recommendations and prominent “Hava tahmini yok”.
- If forecast update conflicts with selected clothes, offer user a diff and a one-tap “Yeni öneriyi uygula” rather than silently replacing an already packed outfit.

---

# 43. CULTURAL, VENUE AND SOCIAL CONTEXT — RESPECTFUL AND GROUNDED

## 43.1 Source-of-truth hierarchy

1. Explicit invitation/venue dress code supplied by user or official venue/organizer source, with validity window.
2. Documented site restrictions from authorized official tourism/venue sources (e.g., explicit covered-shoulder or footwear requirement for *a particular site*).
3. User's expressed formality, modesty, personal values and comfort.
4. Broad, explicitly labeled *suggestions*, not facts, for weather/occasion; no sweeping national rules.

**NEVER** infer user's ethnicity, religion, gender identity, beliefs, body health or “how people of this culture dress” from GPS, birth data or photographs. A city may contain very different venues and communities. Ask for specific destination+activity and permit “Bu öneriyi yok say”. If no qualified source for a cultural rule, show “Mekânın güncel kıyafet kurallarını doğrulayın.” Reject racist/sexist/exclusionary outfit logic. Respect local regulations when verifiable but do not universalize norms across all residents or travelers.

## 43.2 Provenance object

`VenueGuidance { venueRef, jurisdiction?, dressRequirement, sourceURL, officialStatus, observedAt, validThrough?, geographicScope, uncertainty, userOverride, language }`. Never claim venue rule from anonymous review or AI synthesis alone. Store only guidance needed for trip and allow manual correction. A link to official guidance is different from an affiliation/partnership.

## 43.3 Sensitivity and cultural safety test

The same climate/activity/wardrobe should yield equivalent baseline utility regardless of arbitrary name, skin tone, gender expression or inferred country-of-origin labels. When user asks for faith-based/modesty dress explicitly, respect those constraints without tagging the person's religion. For multi-venue trips include a removable modest layer only when specific venue requirements or user preferences justify it.

---

# 44. FASHION DIRECTOR + TECHNICAL MODELIST — OUTFIT SELECTION FOR TRAVEL

## 44.1 Expert responsibilities and inputs

- **Stylist/creative director:** silhouettes, shapes, palettes, texture, cohesion, repeatable capsule combinations, context-appropriate formality.
- **Technical patternmaker:** fit tolerances, mobility, ease, actual brand garment measurements when licensed/known; never infer unavailable physical measurements from product glamour photos.
- **Fabric specialist:** material tag evidence, drape estimate fidelity class, breathability/warmth/wrinkle/drying propensity only if supported; no “% waterproof” invented.
- **Comfort and itinerary planner:** walking, long transit, indoor/outdoor transitions, layered packing.
- **Color coordinator:** preferences, garment colors and user-controlled palette; optional user-selected undertone estimates with uncertainty, not definitive facial profiling.
- **Cultural context specialist:** verifiable venue norms and user-controlled modesty preferences.
- **3D visual editor:** shows saved avatar and outfits in neutral virtual staging, fidelity tiers from §§24–25.

## 44.2 Travel outfit cards

Each day yields: `Primary daytime look`, optional `Evening/occasion look`, optional `Weather fallback`, source set, garment IDs, reason chips (“12–18°C tahmini / müze / yürüyüş / yağmurluk”), validated fit/visual tiers, packed availability, laundry/reuse warnings, manual edit and save. If forecast not available, the card displays `MEVSİMSEL` or `HAVA VERİSİ YOK`. If jeans are already in use across 3 days, evaluate user preference and reasonable care signals, never automatically diagnose “kirli”.

## 44.3 Color and capsule coordination

Build a small neutral/anchor-color palette chosen from wardrobe inventory; generate compatible swaps, avoid 5 duplicate dresses when 2 versatile outfits plus one extra cover needs less luggage. A style score is a **preference-based ranking**, not scientific attractiveness/beauty/objective body judgment. Explain “neden” in concise local language. Account for style preferences and fit constraints over arbitrary birthdate-based instructions. Symbolic astrology/numerology themes may only add a clear optional creative accent with opt-in and reversible state.

## 44.4 Travel outfit visualization

Use existing `BodyMorphProfile` and licensed G0–Gx garments. For trips, do not load a whole city's photogrammetry or download giant scene packs by default. Offer a generic destination-inspired stylized background; a recognizable exact landmark scene only when asset rights, geometry provenance, download size and user expectation are addressed. Label generative city visuals “temsili sahne”, avoid “şu anda bu noktada birebir böyle görünürsün” assertion. Allow offline neutral studio avatar. App must also function without 3D hardware capability via 2D outfit tiles.

---

# 45. THE CAPSULE SUITCASE OPTIMIZER — AN ENGINEERING SYSTEM, NOT A RANDOM LIST

## 45.1 Inputs and variables

- `D`: days or half-day/occasion slots, with weather and venue constraints.
- `G`: owned garments plus user-added generic garment concepts. Attributes: category, season, colors, layers, fit, footwear, material, cleanliness state, availability, approximate packed weight/volume if known, rewear limits user-selected, special needs, purchase eligibility.
- `O`: feasible outfits made from `G` covering slot constraints, distinctness/style utility, mobility, coverage and weather evidence.
- `B`: baggage type and user-entered size/weight restrictions; baggage allowance is **not universally fixed**. A carrier itinerary may later add authoritative baggage rules, never guessed from destination.
- `L`: laundry availability and optional detergent/drying time, if known. Packing policy respects undergarments, socks, workout clothing, swimwear and emergency reserves by configurable user defaults; no private hygiene conclusions.

## 45.2 Optimization formulation

Implement two-stage deterministic planner with explainable ranking:

1. Construct candidate outfits `O(d, a)` for each day/occasion using constraints `feasibleFit`, `dressCode`, `weatherCompatibility`, `comfort`, `cleanliness/rewear`, `ownedAvailable`, `coverage`.
2. Choose a small union of garments to cover every slot. With binary `x_g` = pack garment g, `y_o` = use outfit o:
   - each required slot covered by at least one selected outfit;
   - if outfit selected, every required garment in it is packed or explicitly marked `PURCHASE_NEEDED` / `RENTAL_OR_BORROW`;
   - clean/reuse capacity and drying/wash constraints enforced;
   - known bag weight limit respected; unknown weights do **not** generate fake accurate weights;
   - prohibited/unsafe or unlicensed garments excluded from product claims.
3. Optimize lexicographic priorities (not a single unexamined magic score): **(a) requirements & essential coverage (b) physical/weather comfort (c) user-stated preferences (d) minimize carried items/volume/known weight (e) maximize reuse versatility and cohesive style**. Expose adjustable preference: `light luggage ↔ outfit variety`.
4. If an exact solver fits performance/memory budget and problem small, compare against bounded brute force fixtures; otherwise stable deterministic greedy+local repair with invariants. Never hide an uncovered occasion behind an overall score. All outputs are revisable.
5. Recognize case `NO_FEASIBLE_PLAN`: clearly identify missing items/required constraints and propose substitutions / laundering / purchase *only if needed*; do not fabricate catalog stock or prices.

## 45.3 Packing list categories and quantities

`Tops`, `Bottoms`, `Dresses/sets`, `Outerwear`, `Shoes`, `Underlayers and socks`, `Sleepwear`, `Activewear`, `Swimwear`, `Accessories`, `Weather protection`, `Occasion-specific`. Optional separate **non-clothing essentials** checklist (toiletries/chargers/travel documents) is generic, user-editable and clearly separated; document/visa requirements depend on nationality/route and must never be confidently fabricated. Never include prohibited airline items without verifying authoritative policy.

Every item shows `owned garment preview`, selected quantity, days used, packed checkbox, condition `CLEAN | WORN | IN_LAUNDRY | UNKNOWN`, source/provenance, optional estimated weight band and editability; automatic “packed” only after user check/confirmation. Unknown item status defaults to `UNKNOWN`, not `CLEAN`.

## 45.4 Laundry, reuse and outfit tracking

- At packing time items can be set clean/available; when worn user may mark `worn`; app may prompt gently but never assume from calendar plan that garment was worn.
- Setting `WORN` does not mean unsafe/dirty. User chooses whether still wearable and when to wash; undergarment hygiene uses conservative user-controlled defaults.
- Laundry cycles, hotel laundry access or overnight drying are only scheduled with explicit input and realistic uncertainty.
- If rain causes a shoe to be wet, surface “kurudu mu?” user question; no sensor fantasy.
- Reuse preferences vary by category and wearer; user can lock any favorite garment to a specific day.

## 45.5 Avoid impulsive shopping

Run owned-wardrobe search and substitute analysis first. Shopping gap result only if feasible owned set fails or user chooses purchase. Gap card states `missing function`, not “buy brand X”; optionally authorized brand inventory lookup through existing licensed retail catalog with `verified size fit status`, region/currency, stock timestamp and provenance. No paid partner favoritism disguised as neutral recommendation. Do not imply a brand partnership without contract.

---

# 46. FULL TRAVEL EXPERIENCE — SCREEN-BY-SCREEN UX / MICROCOPY

## 46.1 Navigation placement

Do not add a fourth/fifth top-level tab if base IA does not justify it. Put **Seyahat Modu** prominently inside existing `Today/Planner` entry point, with a concise CTA: “Seyahatini planla”. Persistent active-trip tile on home screen with number of days and `valiz ilerlemesi`, only while user opts in. Travel never takes over retail try-on flow.

## 46.2 Required screens and states

| Screen ID | Name / primary action | Minimum states and interactions |
|---|---|---|
| `TRV-01` | **Seyahat Modu giriş** — Yeni seyahat / geçmiş plan | empty, saved offline, edit/delete, description, permission-independent |
| `TRV-02` | **Nereye gidiyorsun?** — destination + dates | ambiguous city disambiguation, IANA timezone, invalid past date, multiple match, no-network manual entry |
| `TRV-03` | **Seyahatin nasıl?** — purpose/events and day/time | suggested chips, add exact venue and official dress code, optional skip, screen-reader |
| `TRV-04` | **Valiz ve tercihler** — bag/laundry/repeat | unknown baggage, no-laundry, light/variety selector, manual overrides |
| `TRV-05` | **Planın hazırlanıyor** — staged local computation | safe loading, progress explanation, offline, slow/partial weather, cancellation, resource fallback |
| `TRV-06` | **Seyahat özeti** — 5-day timeline and confidence | first outfit, forecast provenance, days coverage, missing essentials, refresh banner |
| `TRV-07` | **Günlük kombin** — day/evening/backup | swap, lock outfit, 3D view, weather/venue rationale, no-3D fallback |
| `TRV-08` | **Akıllı valiz** — checklist grouped by category | packed/unpacked, quantities, unknown weights, baggage limits, duplicates, offline updates |
| `TRV-09` | **Kapsül gardırop** — what can be remixed | cross-day outfits, reused garments, visualization, manual substitutions |
| `TRV-10` | **Eksik parçalar** — own-item alternative first | optional licensed store lookup, missing-availability, price/stock provenance, no-merchant mode |
| `TRV-11` | **Hava ve ortam** — trusted context | forecast vs seasonal explicit, official venue guideline, attribution, map optional |
| `TRV-12` | **3D seyahat provası** — living avatar | fidelity tier, loaded-garment license, compare outfits, no fake landmark authenticity |
| `TRV-13` | **Seyahat içinde yeniden planla** | forecast change diff, packed limits, laundry state, user approval, offline |
| `TRV-14` | **Tamamlanan seyahat** — optional reflection | what was worn vs planned, opt-in corrections, locally saved notes, delete all trip data |

Common screen states for **every** screen: no permission; offline; no wardrobe; empty catalog; insufficient weather; stale/weather alert; loading; canceled; partial results; untrusted official-source data; long locale text; accessibility VoiceOver/Dynamic Type; low-power mode; missing saved avatar. `TRV-12` is optional for a usable travel plan.

## 46.3 Microcopy examples

- “**5 gün için 9 parçayla 12 kombin seçeneği**” *only if actually computed from the current plan; never hardcode counts.*
- “**Önce dolabından önerdik.** Eksik olursa alternatifleri görebilirsin.”
- “**Bu tarihler için henüz günlük hava tahmini yok.** Mevsimsel koşullara göre geçici plan hazırladık.”
- “**Mekân kuralı doğrulanmadı.** Resmî sayfayı kontrol et.”
- “**Bu kıyafeti giydin mi?** Planlamış olman giydiğin anlamına gelmez.”
- “**Çantanın gerçek ağırlığı bilinmiyor.** Dilersen eşyaları tartarak gir.”
- “**3D önizleme yaklaşıktır.** Kumaşın gerçek dökümü ürün verisine göre değişebilir.”

## 46.4 Interaction / visual design

Reuse WEARFORM design tokens, pale neutral wardrobe cards, high-contrast typography, day/weather symbols with text alternative, stacked itinerary cards, compact packing checkbox rows, single bottom primary CTA. Do not build a separate gaudy travel design system. Crisp transition `destination → trip days → pack → ready`, short animation only, `Reduce Motion` respected, no blocked layout while 3D warms. Destination photo and skyline optional and licensed; no image required for P0.

---

# 47. DOMAIN MODEL — SOURCE-OF-TRUTH CONTRACTS / REVISIONS

**Implementation note:** The following language-neutral typed specification is a contract; generate production Swift models with `Codable` and compatible local persistence schemas, versioned migrations and stable IDs. Do not claim pasted schema is compiled production code.

```typescript
type TripState = 'DRAFT'|'PLANNED'|'PACKING'|'DEPARTED'|'IN_TRIP'|'RETURNED'|'ARCHIVED';
type WeatherEvidence = 'LIVE_FORECAST'|'CACHED_FORECAST'|'SEASONAL_GUIDANCE'|'USER_OVERRIDE'|'NO_DATA';
type ProvenanceKind = 'OFFICIAL_VENUE'|'LICENSED_PROVIDER'|'USER_INPUT'|'PUBLIC_REFERENCE'|'UNKNOWN';
type Coverage = 'REQUIRED'|'OPTIONAL'|'CONDITIONAL';
type ItemCondition = 'CLEAN'|'WORN'|'IN_LAUNDRY'|'UNKNOWN';

type Trip = {
  id: string; schemaVersion: number; state: TripState;
  stops: Array<{id:string; placeID?:string; city:string; country?:string;
    timeZoneID:string; startLocalDate:string; endLocalDate:string; approximateCoordinates?: [number,number]}>;
  packingPolicy: {bagType:'CABIN'|'CHECKED'|'OTHER'|'UNKNOWN';
    maxWeightKg?:number; maxVolumeLiters?:number; laundryAccess:'YES'|'NO'|'UNKNOWN';
    preference:'LIGHT'|'BALANCED'|'VARIETY'; repeatRulesByCategory:Record<string,number|undefined>};
  eventIDs: string[]; outfitPlanIDs: string[]; packingListID?:string;
  ownerLocalOnly:true; createdAt:string; lastEditedAt:string; revision:number;
};
type TripEvent = {id:string; tripID:string; stopID:string;
  localDate:string; timeBlock?:'MORNING'|'AFTERNOON'|'EVENING'|'FULL_DAY';
  activity:string; indoorsOutdoors:'INDOORS'|'OUTDOORS'|'MIXED'|'UNKNOWN';
  requestedFormality?:string; footwearNeed?:string; venueGuidanceID?:string;
  userLocked:boolean};
type WeatherSnapshot = {id:string; stopID:string; localDate:string;
  evidence:WeatherEvidence; provider?:string; issuedAt?:string; retrievedAt?:string;
  validUntil?:string; lowC?:number; highC?:number; feelsLikeC?:number;
  precipitationProbability?:number; windKph?:number; alertReferenceIDs?:string[];
  attributionURL?:string; uncertaintyDescription:string};
type ContextEvidence = {id:string; kind:ProvenanceKind; sourceURI?:string;
  officialVerified:boolean; capturedAt:string; validThrough?:string;
  scope:'VENUE'|'LOCATION'|'EVENT'|'USER_PREFERENCE'; description:string};
type TripOutfitPlan = {id:string; tripID:string; eventID:string;
  garmentIDs:string[]; fallbackGarmentIDs:string[]; locked:boolean;
  weatherSnapshotID?:string; contextEvidenceIDs:string[];
  fitEvidenceTier:string; visualFidelityTier:string;
  why:string[]; confidenceKind:'VERIFIED_FACTS'|'HEURISTIC'|'PARTIAL'|'ABSTAIN';
  gaps:string[]; revision:number};
type PackingListItem = {id:string; tripID:string; garmentID?:string;
  genericCategory?:string; quantity:number; assignedEventIDs:string[];
  condition:ItemCondition; isPacked:boolean; itemWeightKg?:number;
  estimatedWeightRangeKg?:[number,number]; missing:boolean;
  userEdited:boolean; source:'OWNED'|'USER_ENTERED'|'GENERIC_NEED'|'LICENSED_CATALOG'};
type TripPlanDiff = {oldRevision:number; newRevision:number;
  changes:Array<{eventID:string; reason:'WEATHER'|'SCHEDULE'|'GARMENT'|'USER_EDIT'|'SOURCE_CHANGED';
    beforeItemIDs:string[]; afterItemIDs:string[]}>; requiresApproval:boolean};
```

**Invariants:** Trip local day uses destination timezone; ID references validate; deletion removes trip/private annotations while preserving wardrobe; outfit planning never mutates avatar body dimensions; packing checkboxes are user-controlled; unknown forecast never serialized as 0°C; item clothing condition is not inferred solely from planned wear; a missing `brandSKU` cannot become a purchase link; provenance never falsely claims official status. Use optional coordinates at destination granularity only, not user's live whereabouts. User-controlled export explicitly redacts personal body, birthdate, exact coordinates and private itinerary by default.

**Storage:** Existing local encrypted/protected database pattern (`SwiftData`/SQLite depending ADR). Persistence migration v1.1→v1.2 must be backward-compatible and recoverable. No server trips table by default. Weather cache separated from locally private itinerary; cache expiry and purge on trip deletion. `TripPlanDiff` tracks local version updates and supports undo. Retained travel history is opt-in and deletable.

---

# 48. OCTOPUS TRAVEL ARMS — LOCAL KNOWLEDGE, CONTROLLED EVOLUTION

This is an extension of **existing §28 Octopus**, not an excuse to build 12 new concurrent LLM processes. Start with bounded native modules and tiny opt-in ML where relevant. Each arm has a defined contract and can be tested independently.

| Arm / owner | Data read | Output | Failure / privacy constraint |
|---|---|---|---|
| `TRIP_ORCHESTRATOR` | minimal Trip and revisions | tasks, dependency graph, decisions | no unbounded recursive agents; cancellable |
| `DESTINATION_WX` | city/day/coarse coordinates | sourced weather evidence | stale/not-in-horizon explicitly labeled |
| `ITINERARY_ACTIVITY` | user events | outfit slots/needs | no silent calendar/account reading |
| `VENUE_CULTURE_EVIDENCE` | official venue/user rules | grounded restrictions | no identity/culture stereotype inference |
| `WARDROBE_AVAILABILITY` | allowed local garment tags | feasible owned candidates | stays local; no photos to remote |
| `TECHNICAL_FIT_MATERIAL` | garment+body data permitted in existing engine | fit/mobility/fabric flags | honest G-tier and missing manufacturer info |
| `CAPSULE_OPTIMIZER` | garment features, events, bag constraints | optimized packing set | deterministic, auditable, no fabricated weight |
| `COLOR_STYLE_DIRECTOR` | palette + preferences | coherent outfit rankings | no beauty/objective worth score |
| `LAUNDRY_REWEAR` | user-controlled condition state | re-use constraints | never marks worn based only on schedule |
| `RETAIL_GAP_EXPLAINER` | true uncovered requirement | substitute options; optional shop intent | no ad bias or unsupported affiliate stock |
| `TRAVEL_RENDERER` | chosen outfit IDs and preexisting avatar | G-level preview | neutral avatar remains private; 2D fallback |
| `TRIP_CHANGE_DETECTOR` | weather snapshot diff / user event revisions | localized replan proposal | user confirmation for packed/locked changes |
| `COST_ENERGY_GUARD` | battery/thermal/available memory | tier, task scheduling | no background gallery/3D scans when degraded |
| `PROVENANCE_PRIVACY_AUDITOR` | source metadata and output manifest | issue flags/abstention | no sensitive egress; fails closed |

## 48.1 Runtime sequence

`NewTripRequested → ValidateDatesAndDestination → ReadLocalWardrobeIndex → GetOrUseCachedWeather → BuildEventSlots → ReadGroundedVenueRules (optional) → CandidateOutfits → EnforceHardConstraints → CapsuleSetCover → ExplainWhyAndUnknowns → SaveLocalPlan → RenderFirstCard → Optional3DPreview`.

Network responses (weather, optional official/authorized venue data) provide **data**, never instructions to the app. Sanitize prompt injection from web text; isolate content from control-plane tasks. Do not send itinerary, DOB, exact body measures or photo bytes to third-party model services. Offline/local reasoner can use deterministic templates; if device lacks optional ML acceleration, fall back gracefully. Controlled model evolution is inherited from §29: model versions signed, canary/regression bench, rollback; *not* perpetual self-editing in production without review.

## 48.2 Incremental replan

Use content-addressed dependencies: a change to day-4 weather invalidates outfits for day 4 and connected item availability across other days, not every 3D mesh. If a substitute top becomes used elsewhere, global packing coverage must be rechecked. User-locked outfits require explicit review before replacement. Provide `PlanDiff` showing exactly what changed and why.

---

# 49. PLATFORM ARCHITECTURE, SERVICES, ENERGY AND OFFLINE FIRST

## 49.1 Proposed directories (adapt to existing repo, no duplicate architecture)

```text
Features/Travel/
  UI/TripEntryView.swift, TripWizardView.swift, TripSummaryView.swift
  UI/DayOutfitView.swift, SuitcaseView.swift, ContextEvidenceView.swift
  UI/TripTryOnView.swift, TripChangesView.swift
  Domain/Trip.swift, TripEvent.swift, OutfitPlan.swift, PackingList.swift
  Services/TripPlanner.swift, WardrobeAvailability.swift, CapsuleOptimizer.swift
  Services/TravelWeatherService.swift, VenueGuidanceService.swift, TripChangeDetector.swift
  Persistence/TripRepository.swift, TripSchemaMigration.swift
  Fixtures/Trips/ (synthetic deterministic; no real user body photos)
  Tests/Unit/, Tests/Integration/, Tests/UI/, Tests/Device/
Docs/Travel/{PRD,ARCH,ADRs,DATA_DICTIONARY,THREAT_MODEL,TEST_MATRIX,BENCHMARKS}.md
```

Shared `Garment`, `BodyMorphProfile`, `Outfit`, style engine, 3D renderer, weather adapter and privacy modules must be **reused**, not cloned. Dependency-inject interfaces; no massive monolith view. A standalone microservice is not justified for an on-device packing-list feature. If retailer feed exists, only product/category gap lookup uses contracted endpoint.

## 49.2 Failure/resource handling and SLO candidates

- **Target to validate, not guarantee:** After warm cached-wardrobe state, first 5-day plan summary on an agreed baseline device within a user-perceived responsive window; record p50/p95, memory peak and energy before choosing hard threshold. Suggested engineering trial: warm/cached p95 ≤2s for 100 garments/5 days, excluding network; cold network explicitly shows progressive UI and cancellation. If benchmark cannot meet target, optimize planner or reduce enrichment before releasing.
- **No permanent camera/AR** while the user edits packing. On device high thermal (`serious`/`critical`) stop optional 3D and expensive enrichment; preserve checklist/outfit list; low power uses low-res cached thumbnails.
- Weather fetched on explicit planning, foreground refresh and OS-allowed limited background pathways; budget network calls, cache, dedupe, exponential backoff; do not promise polling while app suspended.
- Cache only derived weather/context not a third-party copyrighted travel photo unless licensed; purge expired contextual data; respect entitlement/attribution and provider quotas.
- City lookup needs disambiguated region/country and time zone; inaccessible geocoder has manual city/country fallback with `TIMEZONE_UNVERIFIED` until confirmed.
- All core packing and itinerary operations work without account, Internet, Photos access, Core ML availability or 3D. Smartphone should not become hot merely to tick a packing checkbox.

## 49.3 Security boundaries

`TravelWeatherService` sees destination (not current location unless opted in); `VenueGuidanceService` sees requested place/activity only, no body or name; `CapsuleOptimizer` reads local abstract garment metadata and returns local suggestions; `TripRenderer` reads avatar locally. Remote `PartnerRetailService` sees a requested SKU/region, never body mesh or private events. Links open safely and ask permission before external application transitions. NS* permission strings must describe intended use accurately.

---

# 50. PERSONALIZED TRAVEL UX INTELLIGENCE — RELEVANCE WITHOUT SURVEILLANCE

## 50.1 Personalization signal levels

- **Tier 0:** no account/no photo → travel day categories, weather source and generic editable packing list.
- **Tier 1:** wardrobe added → recommend from actual owned items and show thumbnails.
- **Tier 2:** optional style preferences, events, fit/body editor → stronger personalized silhouettes and 3D preview.
- **Tier 3:** local feedback from prior user-approved trips → learn their reuse, comfort and bag-lightness preferences, with undo/reset.
- **Never automatic:** religious affiliation, national origin, medical state, financial status, exact body change over time, intimate image interpretation. Avoid using age as a universal dress restriction; let requested occasion and personal taste guide choices.

## 50.2 Trip preference memory (local only)

“Bu pantolonu yolculukta hep seviyorum”, “Sık yürüyüşte topuklu ayakkabı önermeyin”, “Mümkün olduğunca tek kabin valizi”, “Akşam yemeği için bir şık alternatif” can become reversible local preference rules. Each change has origin `EXPLICIT / CONFIRMED_FEEDBACK` and last updated timestamp. Suggestions about future travel can be declined without penalty. No automatic general-purpose inference about lifestyle from past location trails.

## 50.3 Optional reminders

Packing deadline/reminder and forecast-refresh notice (when new data exists) are **opt-in**, OS-approved local notifications, cancelable and quiet. Do not guarantee exact time or continuous monitoring. Calendar integration is a separate consent gate; neither destination nor trip dates should be broadcast as analytics events.

---

# 51. RETAIL, FIRM PARTNERSHIP AND GROWTH IN THE TRAVEL CONTEXT

## 51.1 Consumer loop

`Own wardrobe → first travel plan → check/pack → wear and adjust → voluntarily rate useful suggestions → better local personal plan next trip`. Shareable card can show “5 gün / 9 parça” *only if actually computed and reviewed*, without destination/date by default. No unsolicited contact or uploading trip plans. Encourage “use what you already own”; missing-item acquisition is optional and honest.

## 51.2 Brand/retailer collaboration surfaces

- **Authorized retailer gap fulfillment:** “Böyle bir yağmurluğum yok” → partners may offer region/size/season matched **actual products** via licensed feed; no browsing other brands' copyrighted catalogs without permission.
- **Travel capsule collections:** Retailer supplies verified product bundles, size variants and material data. Label sponsored placements clearly and protect unbiased fit recommendations.
- **In-store integration:** Customer scanning a product can add it to a trip bag “bu tatilde kaç kombinle çalışır?” without disclosing personal itinerary/body to partner. Computation stays on user phone.
- **B2B reporting:** Aggregated opt-in data with suppression thresholds; no specific traveler routes, trip dates, images, age or body measurements. Measure *incremental* conversions/returns without claiming causality from views alone.
- **Merchant pitch:** “Kullanıcı zaten dolabında olanı önce görür; siz ihtiyaca gerçekten uyan eksikleri sunarsınız. Doğru ürün, şeffaf beden ve anlık mağaza deneyimi.” This is a commercial hypothesis needing pilot measurement.

## 51.3 Revenue guardrails

Don't make weather safety, privacy deletion, essential list or basic packing paywalled. Potential premium: multi-stop adaptive capsules, unlimited saved trip lookbooks, advanced luggage optimization, style customization. Price willingness, subscription conversion, and travel partner commissions are **research hypotheses**, not revenue projections. Affiliate relationships must never override accuracy and user ownership; obey app store policy and region-specific advertising laws.

## 51.4 Go-to-market experiments

A: Consumer landing-page tests and truthful travel demos; B: 20–30 moderated users planning upcoming trips, collect before/after items and satisfaction; C: opt-in existing digital wardrobe users with packing behavior; D: one authorized travel apparel retailer feed pilot; E: evaluate fit and conversion impact with randomized or comparable controls. Plan sample size before making statistically strong claims; no “%60 daha hafif valiz” without matched measured results.

---

# 52. TRAVEL PRIVACY, LAW, ABUSE AND SAFETY THREAT MODEL

## 52.1 Threats and mitigations

| Threat | Mitigation / test oracle |
|---|---|
| Inferred home vacancy from trip dates / destination | never transmit private trips by default; share cards redact dates/destination unless deliberate preview and user action; no public profile itinerary |
| Third-party weather API receives detailed current location | use destination-level coordinates only; don't send precise phone location without separate explanation and consent |
| Official venue pages inject instructions into AI or display false rules | treat as untrusted content, allow only parsed cited dress-code evidence after validation; safe allowlist/escaping; human confirmation |
| Tracking exact religious/cultural preferences | optional styling constraints stored local and not reclassified as user religion; accessible delete |
| Sensitive wardrobe/private body inferred by brand | only SKU, locale and optional generic size choice with explicit user consent; never body mesh, DOB, face, trip itinerary |
| Weather forecast unavailable/stale and misleading | prominent state/provenance, no fabricated hazard or temperature; seasonal fallback clearly named |
| Unknown airline baggage size/weight presented as confirmed | require airline-specific verified policy or user input; otherwise unknown, no precise fee prediction |
| Incorrect event dress code or footwear causing embarrassment/inconvenience | source/validity/override and conservative fallback; never universal cultural stereotypes |
| Automatic “dirty item” label harms user trust | never infer washing need solely from plan and never make shaming judgments |
| Baggage optimization removes critical essentials | hard constraints, critical-coverage tests, editable lock/reserve and independent coverage audit |
| Foreground battery/thermal cost excessive | incremental calculations, lazy 3D, low-power fallback, performance test on real iPhones |
| Unlicensed brand/site photographs used in travel scenes | require provenance/licensed rights or local generated original assets; render neutral fallback |

## 52.2 Retention/access/erasure

Trip and itinerary are private local records; do not sync unless the product introduces a separately audited opt-in cloud feature. Delete selected trip removes its events, packed states, trip-derived local notes, cached custom contextual records where lawful/technically applicable; wardrobe remains unless separately deleted. Reset preference history deletes only travel learning. Accessibility alternatives (VoiceOver, large text, reduced motion, color-blind accessible category indicators) are P0.

## 52.3 Permission/marketing safety

No SMS marketing, no hidden pixel, no sale of itinerary, no public social route map by default. If destination suggestions involve official safety warnings, show accurate source links, not invented medical/safety guarantees. Children/minors need special age/privacy policy review before features that share location or identity; do not expand scope silently.

---

# 53. RELEASE / VALIDATION GATES AND MEASUREMENT PROTOCOL

| Gate | Required evidence | Blocker response |
|---|---|---|
| `G-TRV-BASE` | no-account wizard; 5 days; real local wardrobe fixtures; 1–3 outfits/day; linked packing checklist; accessible iPhone UI; durable persistence | mark feature `NOT_READY`, keep existing wardrobe working |
| `G-TRV-WX` | WeatherKit/offline/mock distinction; source/issue/TTL attribution; forecast horizon and seasonal fallback; change diff | no live weather claims; show local no-data planner |
| `G-TRV-CAPSULE` | deterministic 5-day coverage; user locks; handling no-feasible plan; source/unknown weights; no duplicates; capacity scenario suite | simple editable checklist, no “optimized” claim |
| `G-TRV-CULTURE` | official venue references valid; no identity inference; no stereotype; manual overrides | only user-entered venue dress codes |
| `G-TRV-3D` | device 3D tier truth; no raw body uploads; studio fallback; frame/thermal evidence | show outfit thumbnails instead |
| `G-TRV-REPLAN` | revisioned forecast/itinerary/wardrobe changes; packed garment preservation; explicit diff/approve | do not silently mutate saved trip plan |
| `G-TRV-PRIVACY` | static/dynamic egress tests; share redaction; delete data; permission-denied workflows | block release until resolved |
| `G-TRV-DEVICE` | agreed physical iPhone matrix, iOS version, locale, Dynamic Type, VoiceOver, airplane mode, warm/cold benchmark results | do not claim real-device pass from simulator |
| `G-TRV-RETAIL` | legal feed/attribution/variant truth, transparent sponsor disclosures, no body itinerary leak | shopping gap remains category-level and partner-free |

## 53.1 Performance and correctness benchmark fixtures

Build **synthetic** deterministic fixture matrix: 0/15/100/500 garments; 2/5/14 days; 0/1/3 destinations; 0/3/20 events; network online/offline/stale; no/lite/full avatar; low battery/thermal; culturally sensitive venue constraints; empty/partly owned travel wardrobe. Track plan p50/p95/max and peak memory and energy on devices. Benchmark deterministic helper with seed and expected packed-ID set. Observe not just aggregate speed but missing essential coverage, repeated outfit alternatives and user editing time.

## 53.2 Counterfactual and benchmark honesty

A theoretical packing weight computed from guessed garment weights is not proof of savings. A mocked 5-day weather fixture is not a verified forecast. A beautiful travel image is not a real landmark scene. A checklist written in Markdown is not an interactive app. A success in simulator is not automatically an iPhone pass. External API documentation does not establish WeatherKit entitlement exists in developer account.

---

# 54. v1.2 ACCEPTANCE TEST MATRIX — REQUIRED EXECUTABLE TESTS

Every test below is a **specification awaiting implementation**. Create runnable tests with explicit `PASS|FAIL|NOT_RUN|BLOCKED` and attach commit, command, device/OS, fixture, screenshot/log, observable result and source metadata when applicable. No generic “all good” statement.

### 54.1 Trip flow, date, offline (T-TRV-001..016)

- `001` new user with no account creates 5-day trip; `002` skip all photo/geo permissions and still see generic plan; `003` city duplicate disambiguation; `004` timezone crossing resolves local dates correctly; `005` 5 days vs 5 nights distinction; `006` two-day leap-year transition; `007` DST spring/fall transition; `008` invalid zero/past dates handled politely; `009` 1–14-day limit clear with future extension path; `010` offline create/edit/save/check; `011` trip survives app termination/restart; `012` simultaneous edit resolves deterministic revision; `013` delete trip keeps wardrobe untouched; `014` trip active state never reveals itinerary on home notification without opt-in; `015` VoiceOver wizard completion; `016` long-text/Dynamic-Type layout.

### 54.2 Weather and climatology (T-TRV-017..030)

- `017` known forecast source shows issued time and provider; `018` fetched after validity expires triggers stale label; `019` future day outside actual forecast coverage never shows invented forecast; `020` seasonal guidance explicitly nonforecast; `021` no climate dataset yields no-data not invented numbers; `022` official weather alert exact source/required link; `023` wet/windy evening triggers reasonable layering recommendation via fixture; `024` opposite-hemisphere summer/winter handled; `025` negative temperatures preserved not “0 means unknown”; `026` no location permission still permits destination weather; `027` API fails → cached degraded mode; `028` cached weather changes only relevant days; `029` attribution appears correctly under provider's actual terms; `030` forecast return order changed does not mix dates/timezones.

### 54.3 Cultural and venue safety (T-TRV-031..041)

- `031` same destination, differing venues gives venue-specific recommendation; `032` unknown venue guideline never fabricated; `033` expired source flagged; `034` official dress code + user locked style visible rationale; `035` destination country doesn't infer religion; `036` name/skin-tone changes do not alter baseline venue requirement; `037` official-source prompt injection ignored; `038` anonymous review cannot become mandatory dress code; `039` manual user override persists; `040` accessible respectful wording; `041` no unsupported universal rule about local culture.

### 54.4 Capsule packing, garment, laundry (T-TRV-042..066)

- `042` 5-day all-occasions covered; `043` exact small case matches reference optimal cover; `044` no viable outfit yields explicit gap; `045` owned substitute before store offer; `046` locked outfit preserved; `047` same garment packed once for multiple outfits; `048` quantity for socks/underlayers editable; `049` dirty status never inferred from planned usage; `050` user-worn confirmation updates state; `051` laundry unavailable disables fictional refresh; `052` laundry available user-configurable drying constraints; `053` unknown garment weight not treated as 0 in exact weight guarantee; `054` user-entered baggage max produces true overlimit warning for measured weights; `055` unknown carrier allowances remain unknown; `056` capsule-versus-variety slider changes optimization predictably; `057` event addition causes valid localized replan; `058` alternate shoes selected where walking constraints require; `059` rain protection only attributed when supported; `060` new garment in wardrobe appears without duplicate; `061` removed garment invalidates dependent outfits; `062` weather update generates diff instead of silent rewrite; `063` three destinations, separate date/timezone weather scopes; `064` 500-item performance memory bounded; `065` reusable bottoms aren't automatically marked unclean; `066` explicit manual suitcase contents override suggestions.

### 54.5 3D, on-device ML, resource and privacy (T-TRV-067..081)

- `067` 3D uses same neutral local avatar without server upload; `068` unsupported garment G-tier labeled; `069` offline 2D fallback works; `070` no landmark asset licence means generic scene; `071` low-power skips optional 3D and keeps checklist; `072` thermal serious/critical cancels enrichment; `073` no background gallery scan initiated by travel; `074` no personal itinerary sent to retail endpoint; `075` no body/DOB sent to weather endpoint; `076` share preview hides destination/dates by default; `077` delete trip removes private annotations/cache according to contract; `078` reset preference personalization independent of wardrobe; `079` symbolic layer not used without explicit opt-in; `080` unknown real-time weather and unlicensed data clearly abstain; `081` no ongoing GPS tracking.

### 54.6 Business, UX evidence and ship gates (T-TRV-082..092)

- `082` no retailer integration still fully usable; `083` sponsored items labeled and neutral fit not overridden; `084` unlicensed partner image is not rendered; `085` missing inventory availability not invented; `086` date/region-sensitive product feed stale flagged; `087` local packing actions do not trigger external API requests; `088` empty/error/no-permission/partial loading snapshots captured; `089` reduce motion and accessibility contrast honored; `090` real-device p50/p95 memory/thermal logs attached; `091` saved outfit and wardrobe cross-references survive schema migration; `092` pilot claims supported by measured results or clearly hypothesis only.

**Do not mark any of these 92 cases PASS merely because it appears in the document.** Build executable tests and real-device evidence. Target strict release gates for P0 failures. If no iPhone hardware available, maintain `BLOCKED_DEVICE`; simulator screenshots are labeled `SIMULATOR_ONLY`.

---

# 55. PHASED IMPLEMENTATION BACKLOG — 18 DEPENDENCY-SAFE WORK PACKAGES

All items use `WP-TRV-xx`. `REQ-TRV` map defined below. Claude should choose concrete code ownership, testing command and evidence path per packet; avoid parallel agents changing one domain type before it is frozen.

| WP | Deliverable | Priority | Dependency / minimal acceptance |
|---|---|---|---|
| `TRV-01` | Reality audit + trip PRD + threat/model/provider ADRs | P0 | existing repo design, no new false claims |
| `TRV-02` | Typed trip/event/weather/packing domain + schema migrations | P0 | unit tested, reversible |
| `TRV-03` | Travel entry and 30-second wizard | P0 | no permissions required, VoiceOver |
| `TRV-04` | Destination identity, date/timezone resolver and manual fallback | P0 | edge-case tests |
| `TRV-05` | Local wardrobe availability/condition adapter | P0 | existing garment schema reused |
| `TRV-06` | Synthetic weather fixtures + provider interface + NO_DATA fallback | P0 | deterministic tests before external API |
| `TRV-07` | Deterministic feasible outfit candidate generator | P0 | weather/activity/venue hard constraints |
| `TRV-08` | Capsule cover optimizer + explanations | P0 | 5-day coverage and optimal small fixtures |
| `TRV-09` | Packing checklist + explicit packed/manual states | P0 | airplane mode/persistence |
| `TRV-10` | Day planner timeline and daily outfit cards | P0 | change/swap/lock/why/unknown |
| `TRV-11` | Authorized WeatherKit adapter + attribution + stale controls | P0/P1 | entitlement/cost/availability gate |
| `TRV-12` | Forecast/plan revision diff and user-approved replan | P1 | saved packed/locked garments preserved |
| `TRV-13` | Licensed venue guidance + cultural non-stereotype audit | P1 | verifiable source or abstain |
| `TRV-14` | Existing 3D avatar and garment rendering reuse | P1 | real-device fidelity/perf tests |
| `TRV-15` | Multi-destination and baggage capacity variants | P1 | timezone and unknown weights |
| `TRV-16` | Retail gap fulfilment, only with valid catalog rights | P1 | optional and privacy-safe |
| `TRV-17` | Real-device benchmark, privacy audit, UI snapshots | P0 release gate | tests/logs/screenshots/rollback |
| `TRV-18` | Controlled market pilot & monetization experiment plan | P2 | no partner/ROI claims without proof |

**Priority order:** If base app's wardrobe, permission layer, thermal governor, body/3D and model contracts are not verified, build only a self-contained demo travel vertical slice with synthetic closet fixtures and the existing stable primitives. Do not let Travel Mode block core WEARFORM iOS launch unless explicitly chosen as release scope. Never create 18 services/teams because there are 18 work packages.

## 55.1 Traceable v1.2 requirements register

- `REQ-TRV-001..005`: destination/time/date and event wizard; no-location/no-photo path; timezone; state lifecycle.
- `REQ-TRV-006..010`: source-tagged forecast; climatology boundary; cache/TTL/attribution; alerts; graceful offline.
- `REQ-TRV-011..016`: activity/formality/weather candidate looks; fit/comfort/material evidence; local 3D; manual override.
- `REQ-TRV-017..026`: capsule packing; owned-first; laundry/wear; baggage constraints; gap explanation; checklist persistence.
- `REQ-TRV-027..031`: venue source policy, no culture stereotyping, user modesty preferences, no religious/identity inference, safe overrides.
- `REQ-TRV-032..037`: on-device data partition; no trip/face/body egress; deletion; share redaction; battery and thermal controls.
- `REQ-TRV-038..042`: provider licensing, retail catalog permissions, documented purchase gap, sponsored placement transparency, brand data provenance.
- `REQ-TRV-043..048`: deterministic plan diff, multi-destination handling, real-device metrics, accessibility and localization, controlled personalization/rollback, independent audit.

The range IDs above are **requirements registry placeholders**, not implemented acceptance conditions. Claude must expand each into one atomic `docs/requirements/REQ-TRV-NNN.md` item with fields `owner, problem, user, flow, input/output, source rights, data access, business rules, failure state, offline fallback, tests, evidence`. Reject any broad “travel mode finished” ticket without atomic mapping.

---

# 56. CONCRETE FIVE-DAY DEMONSTRATION — EXPLICITLY FICTIONAL FIXTURE

This example demonstrates expected **structure**, not live weather, verified venue policy, actual user wardrobe or proven recommendation results. Test data must be tagged `SYNTHETIC_DEMO_ONLY` in the UI and CI.

**User selected:** “5 gün, Barselona, şehir gezisi + müze + 1 şık akşam yemeği; kabin valizi; çamaşır yok; hafif ve rahat giyim.” Dates/weather not supplied. Thus **no degree values** and no “yarın yağmur” claim. Owned synthetic closet: 2 basic tops, 1 lightweight overshirt, 1 casual shirt, 1 trousers, 1 jeans, 1 light jacket, 1 comfortable shoes, 1 evening shoes, socks/underlayers. All inventory/condition statuses synthetic.

| Day | Event | Primary styling idea | Source truth |
|---|---|---|---|
| 1 | Arrival + walk | comfy shoes + trousers + neutral top + light layer | activities/user preference; weather pending |
| 2 | Museum + outdoor stroll | jeans + second top + light jacket optional | activity/style; venue code unknown |
| 3 | Day walk + dinner | daytime swap; evening: casual shirt + trousers + evening shoes | explicit formal occasion |
| 4 | Walking + shopping | trousers + reused lightweight top only if user confirms wearable | wardrobe/condition state |
| 5 | Departure | travel-comfort capsule, weather layer if verified later | activity/weather pending |

The system computes and displays actual **union of used garment IDs**, not 5 outfits pasted as 5 separate packing lists. Socks/underlayers use user-specified quantities (safe editable defaults). It can suggest outerwear even if not owned, but only as an unresolved gap, not a pretend possession. It never silently switches to a different brand's product. If weather enters forecast horizon, user gets a change proposal with “hangi gün hangi parça değişti.”

**Acceptance demo script:** Create trip without Photos or Location permission → use locally seeded synthetic closet → select 5 days + events → generate 5 cards and a deduplicated checklist → tick packed → lock dinner look → simulate weather update fixture → show plan diff preserving lock → open neutral 3D/2D preview → airplane mode and reopen → edit/delete trip and check isolation. Record actual run/build/device logs and screenshots.

---

# 57. CLAUDE START HERE — BINDING V1.2 EXECUTION ORDER / DELIVERABLE

> **CLAUDE, execute and verify, not only summarize.** From canonical v1.2 read §§0 and 39–58 first. Check actual repo, active branch, Xcode/toolchains, entitlement, existing modules, device availability and test runner. Do not assume v1.1 app is finished. Build a dependency-safe `TRV-01..TRV-10` working slice with local fixtures and no external account dependencies, starting with local trip types + wizard + 5-day offline capsule optimizer + packing checklist; reuse existing wardrobe UI and model schemas. If product repo is empty, scaffold the smallest valid iOS project and tests without claiming shipping readiness. Make every meaningful code change reviewable and backout-able.

**Before writing code:** Record in `docs/travel/TRAVEL_REALITY_BASELINE.md` actual status of existing wardrobe/3D code, available weather entitlements, available source rights, supported devices and unresolved constraints. Decide ADR for algorithm (simple deterministic first) and compare one small reference optimization fixture. Do not do paid web API calls, install paid service, scrape brand sites, connect private external accounts, send live mail or push app release without explicit owner approval.

**After a meaningful vertical slice:** Provide a truthful report exactly like this:

```text
WEARFORM v1.2 — TRAVEL INTELLIGENCE EVIDENCE REPORT
Date / repo / branch / commit:
Canonical spec version: v1.2
Already existed before current session:
Newly implemented (file paths / exact behavior):
Only specified / mocked / blocked:
Weather provider (live / cached / synthetic / absent) + rights / attribution:
5-day packing coverage and known gaps:
Garment and avatar source / 3D fidelity tier:
Privacy: local data and explicit network request inventory:
Tests: actual command + result + IDs + log:
Device: model / iOS / p50-p95 / power / temperature / screenshots:
Accessibility and negative/adversarial cases:
Rollbacks / unresolved critical risks / gate statuses:
Next dependency-safe work package:
```

**No false certification:** A file creation, green unit test or pretty simulator screenshot does not prove the 3D clothes fit, the real weather is accurate, the garment will feel as real as wearing it, the destination's venue policies are correct, or the app is production ready. These require separate measurements, rights checks and user research. If needed, say `UNKNOWN`.

---

# 58. CURRENT PUBLIC REFERENCE / EVIDENCE REGISTER (REVERIFY AT IMPLEMENTATION)

| Source | What it establishes | What it does NOT establish |
|---|---|---|
| Apple WeatherKit https://developer.apple.com/weatherkit/ | weather SDK/REST, forecasts and subscription/attribution documentation | this project has an active entitlement; unlimited calls or availability at every destination |
| Apple WeatherKit REST https://developer.apple.com/documentation/weatherkitrestapi | daily/hourly, supported dataset concepts, alerts and attribution | predictions beyond returned horizon or stored use beyond terms |
| Apple Weather Attribution https://developer.apple.com/documentation/weatherkit/weatherattribution | provider attribution available and publishing obligation | attribution can be omitted from this product |
| Open-Meteo pricing https://open-meteo.com/en/pricing | commercial plan/licence information for provider comparison | public noncommercial free endpoint is automatically cleared for WEARFORM commercial use |
| Whering packing guide https://whering.co.uk/faq/planner-and-packing-list | current competitor states event-linked outfit planning + packing lists | all competitor internal algorithms/features are known |
| PackPoint App Store https://apps.apple.com/us/app/packpoint-travel-packing-list/id896337401 | competitor states date/destination/activity/weather/optional laundry-informed packing lists | its internal recommender performance or code |

These are public product/SDK descriptions accessed for architecture at document revision. Prior to API/production implementation verify current eligibility, legal terms, source validity, provider availability, cost and local jurisdiction. Never use another provider's branded imagery, scraped garment datasets or destination photographs without a lawful basis/licence.

---

**END — BINDING WEARFORM v1.2 TRAVEL INTELLIGENCE AMENDMENT.**

# WEARFORM — GOD LEVEL MASTER PRODUCT, SYSTEM & EXECUTION CONSTITUTION

> **Durum:** v1.0 — 03 Kasım 2026 — PLAN / IMPLEMENTATION AUTHORITY, **NOT** implementation evidence  
> **Kod adı:** `WEARFORM` (geçici iç proje kod adı; marka, alan adı ve tescil araştırması yapılmadan kamusal marka ilan edilmez).  
> **Kanonik çalışma dosyası:** Claude Code'a kök bağlam olarak verilecek uygulama anayasası.  
> **Platform:** iPhone-first, offline-first, on-device intelligence; Android ancak ayrı doğrulama kapısından sonra.  
> **Ürünler:** WEARFORM Consumer iOS; WEARFORM Retail Partner API + ileride Retail Console/SDK.  
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

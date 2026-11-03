# KABİNSİZ — GOD LEVEL v1.9
## TOTAL SYSTEM REALITY AUDIT · PERSONAL STYLE DNA · ATELIER INTELLIGENCE · PRODUCT TRUTH · ON-DEVICE EXECUTION

**Tarih:** 03.11.2026 · **Tür:** Claude Code'a yöneltilecek bağlayıcı denetim ve uygulama emri · **Önceki kanon:** v1.8 master constitution · **Hedef repo:** `https://github.com/gundogandogancan/kabinsiz` · **Denetlenen SHA:** `77e00fff3c831c4bd0e5f6d9acb1a558e6211edd`.

> **BAŞLANGIÇ UYARISI:** Bu belge yeni özelliklerin uygulandığını ileri sürmez. Repo değerlendirmesi GitHub'dan okunan kod ve kanıt dosyalarına dayanır; yerel Mac'te build/test koşulmadı. Claude yerel/uzak HEAD'i yeniden inceleyecek; bu SHA'dan sonra yazılmış kodu silmeyecek, eski bulguları açık/kapalı durumuna göre güncelleyecek.
>
> **KURALLAR:** Doğrulanmış olgu, deneysel tahmin, görsel simülasyon, sembolik ilham ve pazarlama metni birbirine karıştırılmayacak. 'En zeki', 'kusursuz', 'ruhunu okuyor', 'her marka', 'birebir fiziksel prova', 'tüm cihazlarda saniyesinde' iddiaları yalnızca ürün vizyonu; sahada ilgili kanıt yoksa ürün iddiası değildir. Kod yapan ajan kendi güvenliğini tek başına onaylayamaz.

---

# V19-00 — CLAUDE'A ANA SORU VE KARAR YETKİSİ

**Claude, mevcut Kabinsiz'i v1.8 ve bu v1.9 doğrultusunda profesyonel olarak denetle. Sana soru soruyoruz: Aşağıdaki hedeflere ulaşmak için mevcut repoda gerçek çalışan ne var, hangi kanıtlar eksik, hangi kararlar teknik olarak yanlış, hangi modeller/araçlar lisanslı ve gerçekten uygun, neyi en az maliyetle hangi sırada inşa edebiliriz? Cevabını kaynak ve kanıtla göster. Denetimden sonra harici onay gerektirmeyen ilk öncelikli iş paketini testleriyle uygula.**

Kritik ürün misyonu:

1. Kullanıcı mağazada gerçek bir ürünün barkod/etiketini kameraya gösterir; uygulama **mevcut ve yetkili veri kapsamında** doğru marka, varyant ve ürün kanıtını çok hızlı verir.
2. Ürünün bilinen bitmiş ölçüsü, tasarımı, lif içeriği, yapı/kalıp ve bakım verisini insan bedeninin ilgili bölgeleriyle karşılaştırır; sonucu kesinlik derecesine göre sunar.
3. Ürünün kişisel avatar üzerindeki görsel karşılığını, doğru doku, gerçek renk, logo ve siluetle **desteklenen varlık/fidelity tier seviyesinde** gösterir; güzel görünen renderı fiziksel fit kanıtı gibi sunmaz.
4. İsterse kullanıcının dolabından, mevcut mağazadan ve izinli başka markalardan; bütçe, hava, ortam, kişisel zevk, hareket ve konforu birlikte gözeten **özgün, işe yarayan ve nedenini açıklayan** kombinler üretir.
5. Kullanıcı geri bildiriminden cihaz içinde öğrenir. Kendi kendine yeni kod indirip yetkilerini yükseltmez. Güvenlik, gizlilik, pil, ısı, veri hakları ve yasal uyum korunur.

**Üst ürün ilkesi:** *Kabinsiz insanı yargılamaz; kişiyi ve koşullarını anlayıp, var olan parçaları değerlendirerek seçenekler üretir. Kalite, açıklanabilirlik ve gerçek dünya doğruluğuyla kanıtlanır.*

**Zorunlu ilk cevap:** `docs/audit/V19_REALITY_AND_GAP_REPORT.md` (en az bu belgedeki V19-Q sorularını yanıtla), `docs/roadmap/V19_DEPENDENCY_DAG.md`, `docs/quality/V19_BENCHMARK_PROTOCOL.md`, `docs/DECISION_REGISTER.md` güncellemesi. Sonrasında başla; takvim değil bağımlılık ve test kanıtı üzerinden ilerle.

---

# V19-01 — SON GITHUB GERÇEKLİĞİ VE ÖNCEKİ SÜRÜMLE ÇELİŞKİLER

| İncelenen kaynak | Gerçek gözlem | Asıl fark / iyileştirme |
|---|---|---|
| `Packages/KabinsizCore/Sources/ShoppingCopilot/Catalog.swift` | Kod temelli sentetik katalog ve manuel çözümleme; doğrulanmış gerçek marka feed'i yok | GTIN/etiket/ürün/foto tanıma arayüzleri, kaynak–lisans–varyant provenance |
| `apps/ios/Kabinsiz/Features/Scan/ScanView.swift` | Kamera yok, kod yazılarak sentetik karar kartı alınıyor | Canlı barkod/OCR, çoklu aday, consent-aware lookup, offline fallback |
| `FitPassport/SizeAdvisor.swift` | Beden girdileri göğüs/bel; marka+kategori denemeleri; belirsizlikte susma doğru bir başlangıç | Omuz, kalça, üst kol, iç bacak, boy, ürün bitmiş ölçüleri, fit margin ve ürün-model revizyonu; kalibre edilmiş belirsizlik |
| `DomainContracts/Garment.swift` | Kumaş bilgisi yalnız birkaç boolean materyal iddiasından ibaret | Lif %, dokuma/örme, ağırlık, yapı, elastan, ölçülmüş gramaj/kalınlık, bakım, gerekçelendirilmiş comfort evidence |
| `DecisionComposer.swift` | `visualTier=.flat2D`; birinci derecede iki kategori/renk ile dolap eşleştirme | Gerçek 3D asset doğrulama; kombin uyumu çok amaçlı sıralama; source-truth card |
| `MyModelView.swift` | '3D yok' dürüst placeholder; iki manuel ölçü | Bel/basen/omuz vb. morph, anatomi kısıtı, avatar revizyon/undo/erişilebilirlik |
| `SystemContracts/*` | `DecisionEnvelope`, `EgressIntent`, `WorkOrder`, `ModuleRegistry`, `EvidenceRecord` vb. kodlanmış | Sözleşme mevcudiyetini tam orkestratör/egress enforce edilmiş sanma; runtime audit ve negatif ağ testleri |
| `LocalStore.swift` | Yerel sürümlü JSON; iOS file protection; ayrı CryptoKit vault henüz yok | Şifreli vault, anahtar yaşam döngüsü, migration, deletion & backup restore testleri |
| `docs/evidence/WP15-02.yaml` | 113 paket + 2 simülatör testinin geçtiği rapor; cihaz ve ağ testleri yok | Bağımsız bu incelemede çalıştırılmadı; gerçek cihaz, egress, termal, marka saha testi şart |
| `docs/audit/V15_QUEUE_AND_CONFLICT_MAP.md` | `WP15-03..08` bekliyor olarak işaretli | Bu güvenlik/3D temel blokajları atlayıp daha fazla 'agent' yazma |
| Repo `CLAUDE.md` | Kanonik kaynak hâlâ v1.5'i işaretliyor | v1.8/v1.9 ile yükseltme **yalnız** çatışma haritası ve change-control sonrasında; eski kanonu sessizce geçersiz sayma |

**Rapor yalnız repoda görülen durumdur.** Yeni commit varsa her satır yeniden doğrulanır. `113` test sayısı repo evidence beyanıdır, bu belge tarafından yeniden çalıştırılmış test sayısı değildir.

## Önemli kod inceleme soruları

- `SizeAdvisor.chartMatch`: kullanıcının girdiği iki ölçüden ürün tablosunda yalnız biri varsa eşleşme yeterli mi sayılıyor? Eksik bölgeyi `PARTIAL` olarak tanımla; tek ölçüden 'tam beden' iddiası üretme.
- `FitPassport` marka+kategori geçmişini model/fit tipine göre nasıl ağırlıklandırıyor? Başka modelde iki kere 'M tam oldu', yeni ürünün M bedeninin garantisi değildir.
- `ShoppingGuard` renk dizgesi ve kategori eşleşmesine dayandığında aynı renkli fakat doku/silueti tamamen farklı parçaları 'benzer' mi sayıyor? Benzerliği materyal, fit, desen ve siluetle iyileştir.
- `Garment` alanlarında kullanıcı gözlemi ile üretici verisi, yapay zekâ tahmini ve stilist yorumu aynı tipte mi tutuluyor? Ayrıştır.
- `EgressIntent.validate()` bir beyanı denetler; ağ isteğinin tüm yollarını zorunlu olarak kesiyor mu? Runtime enforcement/egress negative capture olmadan 'güvende' deme.
- `LocalStore`'un şifrelenmemiş JSON dosyalarından yeni vault'a göçü başarısız olursa veriler nasıl korunuyor? Atomik geçiş ve rollback kanıtla.

---

# V19-02 — GERÇEKÇİLİK SINIRLARI: İKİ FARKLI DOĞRULUK SİSTEMİ

**A. Product Truth**: Barkod eşleşmesi, exact varyant, bitmiş ölçü, materyal, bakım, görsel/logo hakkı, stok/teklif ve kaynağın güncelliği. Ürün hakkında sayısal, doğrulanabilir özellikler.

**B. Human–Product Truth**: Kişinin manuel onaylı ölçüleri, poz/beden morfolojisi, ease/fit toleransı, hareket, konfor, beğeni, bağlam, gerçek deneme/iadeler. Bunlar çıkarımsal ve kullanıcıya özgü.

**C. Fashion Intent**: 'Güçlü, sakin, yaratıcı, romantik, profesyonel, deneysel, minimalist...' gibi kullanıcının **seçtiği** ifade hedefleri. Bunlar ruhsal teşhis veya psikometrik gerçek değil, değiştirilebilir yaratıcı tercihlerdir.

**D. Visual Fidelity**: Orijinal ürünün renk/desen/logo ve formunu göstermeye çalışan 2D/3D/generatif görsel. Estetik gerçekçilik, fit/konfor doğruluğunun yerine geçmez.

> Bu dört alan tek `DecisionEnvelope` içinde bir araya gelecek, fakat her alt karara kendi evidenceID, coverage tier, timestamp, uncertainty ve gerekçe bağlanacaktır.

2026'daki moda araştırmalarında fotogerçekçi VTON hâlâ beden fit gerçeğini yanlış yansıtabilir; özellikle dışarı taşan beden ve gevşek kıyafetlerde hata olabilir. Çalışan model veya 1M+ sentetik veri olması gerçek dünya isabeti kanıtı değildir. Referans: https://arxiv.org/abs/2604.08526 ; https://doi.org/10.1111/cgf.70272 ; https://doi.org/10.1080/17543266.2026.2618270 .

---

# V19-03 — PRODUCT IDENTITY FAST PATH: SANİYELİK TARAMANIN TEKNİĞİ

## 03.1 Merdivenli ürün tanıma

1. **Instant local scan:** `AVFoundation` kamera oturumu + `Vision` barkod + OCR; kareleri cihazda işler, normalize, doğrulama basamakları, odak ve glare/blur kalite kontrolü; ham görüntüyü ağa yollamaz.
2. **Product key:** mümkünse `GTIN` + veri kapsamı (ülke/mağaza/brand) + SKU/model + renk + beden + feed revizyonu; GS1 check digit ve etiket/satıcı kodu ayrımı.
3. **L0 local catalog:** imzalı, sürümlü, TTL'li public metadata önbelleği. Önceden görülen ürünler veya pilot mağaza sahası düşük gecikmeyle açılır.
4. **L1 partner lookup:** yalnız `gtin/model_code/country/locale` gibi izinli alanlar; cihazdaki avatar, fotoğraf, ölçüler ve 'kişinin ruhu' bilgisi gitmez. Rate limit, etag, timeout, offline fallback.
5. **L2 hybrid candidate matching:** kullanıcı ürünü/etiketi seçer; OCR metninden kategori/beden ve görselden renk/desen adayları çıkarılır; *görsel benzeme* exact ürün kanıtı değildir.
6. **L3 ask the user:** belirsiz iki varyant arasında yüzsüz ürün fotoğrafı / beden etiketi ile seçim; olmuyorsa bilinmiyor.

## 03.2 Ürün veri standardı

`BrandOwner → Brand → Market → Collection → ProductModel → Variant(color,size,fit) → GTIN/SKU → MaterialComposition → GarmentSpec → CareLabel → Asset(license) → Offer(merchant/location/price/stock timestamp)`.

*Her kayıtta*: `sourceRef`, `sourceType`, `lastVerifiedAt`, `validUntil`, `territory`, `licenseID`, `commercialUseAllowed`, `assetRedistributionAllowed`, `measurementDefinition`, `unit`, `modelRevision`, `variantRevision`, `consentNeed`, `qualityGate`, `conflictStatus`.

`GS1` GTIN çoğunlukla kimlik ve bazı doğrulama alanları sağlar; kumaş, ölçü ve asset için üretici/merchant feed'i veya doğrulanmış bir yetkili kaynak gerekecektir. https://support.gs1.org/support/solutions/articles/43000734110/ ; https://support.gs1.org/support/solutions/articles/43000734095-how-do-gs1-gtins-and-barcodes-work-

## 03.3 Dört gerçek hız metriği; 'saniyesinde' öznel olmasın

- **S0** camera-ready-to-decode: desteklenen fiziksel iPhone, iyi ışık, tek etiket koşulunda hedef p95 ≤0.8s (tasarım hedefi).
- **S1** decode-to-identified: *yerel önbellekte doğrulanmış* ürün için hedef p95 ≤1.0s (tasarım hedefi).
- **S2** identified-to-first-useful-decision: yerel beden + materyal + kaynağı olan kayıtla p95 ≤2.0s (tasarım hedefi).
- **S3** first-useful-decision-to-prepared-3D: önceden paketlenmiş/önbelleklenmiş giysi asset'i ile ek p95 ≤1.5s (tasarım hedefi).

**Toplam birkaç saniye hedefi** yalnız *uygun koşullarda, cached partner data ve hazır varlık* için adaydır. Ağda hiç olmayan ürünün görselden kesin bulunması veya sıfırdan fotogerçekçi simülasyonun her iPhone'da aynı hızda çalışması vaat edilmez. p50/p95/p99 ölçülür; cihaz sınıfı, sıcaklık, ağ ve warm/cold-start ayrı raporlanır; başarısız/hatalı eşleşmeler zaman metriğinden çıkarılamaz.

## 03.4 Geçişli sonuç

Kullanıcı 3D beklerken spinner değil: **ürün adı → kaynaklı ölçü/fit → iki kombin → varsa 3D** progressive disclosure. Her aşamada sonuç eskimesi ve iptal mekanizması. Ölçü yoksa hiçbir hızlı ve süslü model doğruluk iddiasını yükseltmez.

---

# V19-04 — PRECISION FIT SCIENCE: BÖLGESEL UYUMUN FİZİĞİ

**Modül girdileri:** `BodyMeasurement(kind,cm,method,uncertainty,revision)` + `GarmentFinishedMeasurement(kind,cm,flatVsCircumference,stretch,grade,revision)` + fit intent + user preferences + style/pose context. `SizeChartBodyRecommendation` bu ölçülerin yerine geçmez.

1. Boy, göğüs, göğüs altı (isteğe bağlı), bel, yüksek/düşük kalça/basen, omuz, boyun, üst kol, önkol/bilek, üst bacak, diz, iç bacak boyu, kol boyu gibi alanlar kategoriye göre **isteğe bağlı** ve user-editable. Kullanıcıyı beden ölçüsüne zorlamaz.
2. Anatomik morph parametrelerinin birimleri, izin verilen aralıkları, mesh topo sınırları, bağıl bağımlılıkları ve cilt/giysi çakışma toleransları yazılacak; ölçü değişikliği mesh'in ilgili bölgesinde gözlenebilmeli.
3. **Ease = garment circumference − body circumference** bir ilk sinyaldir; ancak elastikiyet, hareket, kesim, kumaş kalınlığı, sıkıştırma ve dikim tekniklerini bilen modelistçe tasarlanan *kategoriye özgü* kurallarla yorumlanır. Bel ve kalça için aynı formül/konfor eşiği kullanılamaz.
4. Ölçülerin hata/dağılım değerleri (`±cm` veya ölçüm yöntemi belirsizliği) taşınmalı; 3 mm arayla iki beden önerisinin sonucu belirsizlik aralığında çakışıyorsa kesin seçim verme.
5. 'Oturuş/beden' ile 'konfor' ve 'stil isteği' farklı: kişi skinny fit sevmediği için ölçüler mümkün olsa da relaxed seçenek isteyebilir.
6. Ürün etiketindeki M / 32 / W30-L32 / EU40 / TR40/43 gibi sistemler için `SizeSystemRegistry` ve data provenance; iki markanın M bedeni eşdeğer varsayılmaz.
7. Ayakkabı ayrı anatomi/uzunluk/genişlik/kullanım alanı ve marka kalıbı sistemi gerektirir; ana giysi fit modeline katılmadan ayrı modül.
8. Çocuk bedeni, tıbbi baskı veya engellilikten gelen özel ihtiyaçları özellikle ele alan ürünler ayrı güvenlik ve doğruluk kapısından geçer. Yaş/cinsiyet kimliği otomatik beden ölçüsü değildir.
9. Kullanıcı 'denedim / tam / dar / bol / nerede / hareket ederken nasıl' feedback verince aynı ürün, aynı revizyon ve benzer model kanıtı korunur; farklı ürünlere aktarım ayrı düşük-güven önceliği olur.
10. **Fail-closed:** bitmiş giysi ölçüsü veya kritik beden bölgesi eksikse 'uygun kesin' gösterme; kabinde dene / ölçü iste / sadece stil görseli sun.

**Benchmark:** `FitTruthLab` en az üst, alt, dış giyim ve farklı kalıplardan; gönüllü gerçek fiziksel deneme + gerçek ürün ölçüleri ve kör uzman paneliyle ölçüm protokolü. Veri onayları, örneklem dağılımı, eval/train ayrımı, confusions, size-advice accuracy per brand/category, top-2 recall, abstain quality, calibration, false-certainty, overlay colliding regions. Başlangıç kabul eşikleri saha örneklemi oluşmadan **önceden kayıtlı hipotez** olacak, gerçek sonuç gibi yazılmayacak.

---

# V19-05 — FABRIC DNA / THERMAL COMFORT: KUMAŞI FOTOĞRAFTAN UYDURMA

## 05.1 Kaynak kademeleri

- **F4 measured:** laboratuvar testi veya üretici tarafından paylaşılmış teknik ölçüm; test yöntemi, şartlar, lisans ve ürün-varyant revizyonu.
- **F3 brand verified:** ürün spesifikasyonundaki lif yüzdeleri, bakım, gramaj vb.; varsa yöntem ve tarih.
- **F2 label OCR:** kullanıcı çektiği bakım/lif etiketinden okunmuş ham metin; OCR + kullanıcı onayı; yanlış yüzde veya baskı varsa doğrulanmış sayma.
- **F1 image-inferred:** fotoğrafta kaba dokuma/örgü/kalınlık belirtisi gibi belirsiz **görünüş ipuçları**, yüzde lif, doku 'feel' veya termal yalıtım testi yerine geçmez.
- **F0 unknown:** açıkça bilinmiyor.

**Somut özellikler:** örme/dokuma örgüsü, lif bileşimi %, gsm, kalınlık, astar, katman sayısı, geçirgenlik, hava boşlukları, esneme ve geri toparlanma, nefes alma/su buharı davranışı, rüzgâr geçirgenliği, su direnci, bakım sembolleri, kesim ve giysinin üzerinde durma/akışkanlık. Her özellik `measured / manufacturer / label / inferred / unknown` ayrımıyla tutulur. Çok veri beklenmeyen alanlar opsiyoneldir.

## 05.2 Isı önerisi

`ThermalContext = weather(low/high,humidity,wind,precip,sun,sourceAge) + activity(intensity,duration) + layers + materialEvidence + preference(coldSensitive?)`.

'Bu sweatshirt 17°C için üretilmiş' ifadesi sadece gerçek üretici etiketi varsa kaynağıyla. Genel öneri *aralık ve bağlam* ile çıkar: `Serin ve rüzgârlı havada dış katman gerekebilir; kumaş kalınlığı doğrulanamadı.` Bir kişinin neden sıcağı/soğuğu farklı hissettiği için herkese tek sıcaklık derecesi atama. Bilinmeyen veri sonucu '0°C' yapma.

## 05.3 Kumaş bakımının ayrı motoru

Bakım etiketi '30°C yıka' ifadesi = **yıkama sıcaklığı**. '30°C'de giy' anlamına gelmez. `WashCareTemperature` ile `WeatherWearComfort` farklı tipler ve farklı UI alanları. Bu yanlış yorum için P0 regresyon testi.

---

# V19-06 — VISUAL TRUTH: MARKA, LOGO, RENK, DOKU VE SİLÜET

1. `AssetIdentity`: exact product variant, authorized image/texture, pattern repeat, logo position/size/orientation, stitch/seam details, garment 3D source, transformation history, copyright/license.
2. `TextureLock`: logolar ve tipografik desenler generatif modelin **uydurmasına** bırakılmayacak; yetkili varlık korunacak, OCR/visual diff ile karşılaştırılacak, hatalı render reddedilip 2D truth'a geri dönülecek.
3. `ColorTrust`: referans aydınlatma ve cihaz ekranı koşulları, sRGB/Display P3 dönüşümleri, gamma/white balance, renk renk-dalga/ölçüm kaynağı; tek mağaza ışığında çekilmiş fotoğrafı gerçek tekstil rengi sayma. Farklı ışıklarda görünüm bir görselleştirme olabilir ama gerçek görüntü garantisi yok.
4. `ShapeTrust`: 3D avatar `bodyRevision` ile kıyafet `assetRevision` + beden varlığı arasında katman/hareket çakışma testleri. Giysi asset'i yalnız başka renk için hazırlanmışsa bunu 'tam ürün mesh'i' sayma.
5. `MotionTrust`: önden, yandan, arkadan, kollar yukarı, oturma, adım atma gibi test pozları; desteklenmeyen giyside 'hareket simülasyonu' iddiası yasak.
6. `StylePreview` ve `FitSimulation` etiketleri ayrıdır. Salt VTON fotoğrafının iyi görünmesi, fiziksel ölçü veya kesim uyumunu doğrulamaz.
7. AR sokak sahnesi gerçek çekim veya lisanslı lokasyon/3D varlık olmadan 'Galata Kulesi önünde canlı gerçek' olarak sunulmaz; kullanıcı fotoğrafı arka planı/temsilî sahne olarak işaretlenir.

### İki hatlı görüntü teknolojisi

**A, Mobile Geometry Lane:** Blender'da LOD + rig + UV + texture + morph + ön-kontrollü kumaş geometrisi; USD/USDZ/RealityKit/Metal cihaz içi ilk kare. Gerçek ürün asset'i yoksa generic mesh ve dürüst etiket. Apple RealityKit mesh deformation belgelidir ancak device/OS API destek matrisi şart: https://developer.apple.com/documentation/realitykit/scene-content-mesh-deformation .

**B, Research Generative Lane:** CPU/GPU/ANE yerel modele dönüşümün bellek, yükleme, uygulama boyutu, termal, batarya, lisans ve kimlik koruma kapıları vardır. Örnek FASHN VTON v1.5 Apache-2.0 kod/ağırlık sunsa da yayınlanan yaklaşık 5 sn H100 ve ~2GB ağırlık **iPhone 3 sn garantisi değildir**. Üçüncü taraf modellerin ayrı lisansları incelenmeden entegre etme. https://fashn.ai/research/vton-1-5 ; https://github.com/fashn-AI/fashn-vton-1.5 . `Mobile-VTON` gibi noncommercial varlıklar ticari üretimde izin olmadan kullanılmaz.

---

# V19-07 — PERSONAL STYLE DNA: KİŞİYİ YAKINDAN TANIYAN AMA YARGILAMAYAN STİLİST

## 07.1 İnsan anlayışının teknoloji karşılığı

Kullanıcının 'ruhunu okuyormuş gibi' hissetmesi şunlardan gelir: geçmişte sevdiği kombinleri hatırlamak, neden rahatsız olduğunu anlamak, gitmek istediği ortamı sormadan mevcut onaylı plandan bilmek, dolabındaki eşyaları tekrar yaratıcı biçimde kullanmak ve **yanlış tahmin ettiğinde hemen düzelmek**. Bu, gizli kimlik/psikoloji çıkarımı değil, kullanıcı kontrolünde kişiselleştirmedir.

`StyleDNA` 12 ayrı *kullanıcı-düzenlenebilir* eksen içerir:

1. **Comfort & mobility**: dar/bol, hareket, katman, ayakkabı rahatlığı.
2. **Silhouette language**: fitted/straight/relaxed/oversized/tailored ve oranlar.
3. **Color expression**: nötr, sıcak/soğuk ton tercihleri, kontrast, vurgu rengi, kaçınılan tonlar.
4. **Pattern rhythm**: düz, çizgili, ekose, grafik, tekrar yoğunluğu.
5. **Texture expression**: mat/parlak, denim, örgü, pamuk görünümü, deri görünümü (içerik doğrulaması ayrı).
6. **Aesthetic direction**: minimal, klasik, streetwear, smart casual, couture, playful, retro, utility vb. **çoklu** stiller.
7. **Social intent**: resmi, sakin, yaratıcı, çarpıcı, profesyonel, doğal, dikkat çekmek/çekmemek gibi kullanıcının seçtiği niyet.
8. **Occasion intelligence**: iş/toplantı, okul, buluşma, spor, düğün, tiyatro, seyahat, günlük yürüyüş, mekan kuralı.
9. **Brand & logo taste**: minimal/no-logo vs gösterişli logo, sevilen/kaçınılan markalar; sahte logo üretme.
10. **Budget & durability**: tek ürün bütçesi, toplam alışveriş üst sınırı, yeniden kullanım, kalite/ömrü uzatma.
11. **Climate & care**: terleme/üşüme konusunda kullanıcının açıkça belirttiği giyim konforu ve yıkama bakım isteği.
12. **Variety & evolution**: güvenli klasik, küçük yenilik, deneysel kombin, geçmişte beğenilen/ret edilen, istenen değişim.

Hiçbiri görüntüden 'karakter', etnisite, din, cinsiyet kimliği, ruh hali veya sağlık teşhisi olarak etiketlenmeyecek. Özellikle kendini ifade hedefleri kullanıcının isteğine bağlıdır. Stil profili tek anket zorunluluğu olmadan aşamalı öğrenilir.

## 07.2 Giriş: çok az soru ile yüksek bilgi

- **Cold start:** üç örnek kombin arasında seçim, iki kaçınılan özellik, rahatlık/şık tercihi ve bütçe aralığı (hepsi skip). İlk kombinler dolap+etkinlikten gelebilir.
- **Before recommendation:** tek ihtiyaç varsa tek mikro-soru, ör. 'Bugün rahat mı daha şık mı?'; eksik kritik fit ölçüsü gerekiyorsa tek ölçü sor.
- **After recommendation:** 'Beğendim', 'fazla resmi', 'renk bana göre değil', 'bedeni rahatsız', 'bunun yerine daha cesur', 'bunu kaydet'.
- **After wearing:** 'Gerçekte nasıldı?' kullanıcı onaylı öğrenme; kaydedilmemiş tercihten otomatik güncelleme yapma.
- **Correction:** 'Beni böyle görme', 'Bunu unut', 'Bu marka için kullanma', 'Öneriler sıfırla'. Kullanıcıya stil DNA revizyon geçmişi ve geri alma.

## 07.3 Bağlam değişkenliği

Aynı kişinin pazartesi iş görüşmesi ile cumartesi arkadaşlarıyla sahilde istediği görünüm farklı. `StyleContextSnapshot` her karar için `occasion`, `formality`, `venueEvidence`, `weatherEvidence`, `temperature`, `activity`, `walking`, `packing`, `budget`, `userMoodSelfReported` (opsiyonel), `desiredVibeSelfSelected`, `timeWindow` ve `garmentAvailability` taşır. Sadece konumdan o kişinin kültürünü/yaşam biçimini tahmin etme; mekanın varsa doğrulanmış kıyafet kuralını kullan.

---

# V19-08 — ATELIER DIRECTOR: GERÇEK MODA AKIL YÜRÜTMESİ

Moda zekâsının çekirdeği tek bir 'prompt' değildir: `Structured Fashion Knowledge → Candidate Creation → Hard Constraint Check → Expert Aspect Scores → Diversity & Calibration → Local Personalization → Explanation`.

## 08.1 Bilgi yapısı

- **Moda dili:** renk ve vurgu stratejisi, kontrast/saturasyon ilişkisi, motif ölçüsü, siluet dengesi, katman hacmi, üst-alt oranı, dikiş detayları, ayakkabı formu, çanta/aksesuar ölçeği.
- **Modelist dili:** kalıp, ease, omuz hattı, göğüs/bel/kalça oturuşu, düşüş (drape), bacak boyu, proporsiyon, hareket, astar ve malzeme gerilmesi.
- **Tekstil dili:** lif ve yüzey, mevsimsellik, bakım, uzun ömür, yüzey ağırlığı ve hava etkisi.
- **Sanat yönetimi:** kıyafetler arasında görsel ritim, bir odak noktası, kullanıcı niyetine göre monotonluk/cesaret dengesi.
- **Kültürel bağlam:** mekâna ait doğrulanmış dress code ve kullanıcı tercihi; ulusal/etnik stereotip yok.
- **Stil tarihçesi ve trend:** kullanıcı isteği üzerine moda arşivi ve mevsimsel trend; kamu kaynakları lisanslı, influencer klonlaması ve telifli tasarım birebir kopyalama yok.
- **Ekonomi:** bütçeyi aşmadan alternatif, kendi dolabına dön, çok-amaçlı parça, cost-per-wear yalnız kullanıcı verisi yeterliyse.

## 08.2 Kombin yaratma, sadece eşleşme değil

1. `Anchor`: taranan ürün veya mevcut dolap temel parçası.
2. `Intent`: görünüm hedefi ('daha klasik', 'yaratıcı', 'sade'), bağlam, hava, bütçe.
3. `Composition`: farklı üst/alt/ayakkabı/katman/aksesuar adayları; çift parçaların fiziksel uyumu ve kullanım alanı.
4. `Compatibility`: ton/kontrast, görsel ağırlık, desen dengesi, formality, siluet hacmi, doku, alt-üst oranı, giyim konforu.
5. `Negative evidence`: kirli/uygun olmayan, rahat değil, geçmişte reddedilmiş, bütçeyi aşan, yanlış beden, stok ve erişim bilinmeyen.
6. `Creative variants`: **Güvenli klasik / karakterli dengeli / cesur deneysel**; tek 'evrensel en güzel' hükmü yok.
7. `Style director rationale`: 1-3 özgül gerekçe ('koyu denim altındaki açık ton odağı dengeleyip deseni öne çıkarıyor'), 1 sınır veya alternatif.
8. `Validation`: önceden bilinmeyen kombinlerde insan stilist kör tercihi, kullanıcı deneyleri, tekrar giyim ve kullanıcı düzeltmesi.

## 08.3 Stil kalitesi: kalite puanı değil, vektör

Organik değerlendirme en az `occasionFit`, `bodyComfort`, `fabricWeather`, `colorHarmony`, `proportionBalance`, `texturePattern`, `personalResonance`, `noveltyControlled`, `wardrobeReuse`, `budgetCompliance`, `evidenceQuality` üretecek. Sert kurallar önceden eler; kalanlar kişisel hedefe göre Pareto/multiobjective sıralanır. Bir tek **'Yakışma %98'** sayısı yalnız başvuru verisi/ölçüm/kalibrasyon yoksa üretilemez. Reklam komisyonu bu vektöre giremez.

**Diversification:** Aynı bej pantolonu her gün, her yerde önerme. Stil çeşitliliği tercihe göre, gündem/ortam değişimini dikkate alarak sürdürülebilir olmalı; kullanıcı 'ben hep siyah severim' derse sırf çeşitlilik için reddettiği rengi zorlamaz.

## 08.4 Profesyonel değerlendirme protokolü

Gerçek modelist, moda tasarımcısı, tekstil uzmanı ve hedef kullanıcılardan oluşan dış panelin değerlendireceği rubric:

`K01 occasion 0..4`, `K02 silhouette 0..4`, `K03 color coordination 0..4`, `K04 texture/layer 0..4`, `K05 wearability 0..4`, `K06 user expression 0..4`, `K07 wardrobe utility 0..4`, `K08 evidence honesty 0..4`, `K09 visual asset fidelity pass/fail`, `K10 harmful/stereotyped recommendation pass/fail`.

Kör A/B karşılaştırma, değerlendirenler arası uyuşma, ayrı yaş/beden/bütçe/stil kategorilerinde başarım; panelin değerlendirdiği örnekler eğitim verisine sızmamalı. **Claude subagent'i 'insan stilist onayladı' diyemez.** İnsan paneli yoksa `HUMAN_REVIEW_PENDING`.

---

# V19-09 — SYMBOLIC ATELIER: ASTROLOJİ / NUMEROLOJİ / SEMBOLİK İLHAM

**Varsayılan: KAPALI.** Kullanıcı isterse `Symbolic Style Inspiration` açar ve doğum tarihi gibi gerekli bilgiyi verir; tek amaç *kendi seçtiği yaratıcı metaforlar* üretmektir. Asla cihaz fotoğraflarından gizlice doğum tarihi veya kimlik çıkarma. Doğum tarihinin gerekmediği yüzeylerde sorma.

- `astrology`: kullanıcının açıkça seçtiği güneş burcu, dilerse diğer sembolik göstergeler; kişilik/yazgı belirleyen bilim olarak sunulmaz.
- `numerology`: aritmetik hesap açık ve tekrar doğrulanabilir, geleneksel yorumlar etiketli, sonuçlar yalnızca estetik ilham dili ('bu hafta daha canlı vurgu rengi denemek ister misin?') üretir.
- `symbolic aesthetics`: renk/arşetip, mevsim, hikâye, geometri veya sanat tarihi metaforları ile isteğe bağlı tasarım kurgusu.
- `influence sandbox`: fit, fiziksel konfor, hava güvenliği, zorunlu dress-code, bütçe, ticari sıralama **asla değişmez**. Sadece uygun kombinler arasında istemli estetik varyant ilhamı.
- `consent`: açık açıklama, kapatma, veri silme, hangi öneride kullanıldığı bilgisi. Bu özellik açık değilse birth data hiç işlenmez; üçüncü taraf reklamına/satıcıya gönderilmez.
- `test`: kapalı modda temel öneriler sembolik profile göre değişmez; açık modda neden gösterilir; astrolojik/numerolojik yorum ile ölçü verisi asla birleşmez.

**Yasak:** 'ruhunu okudum', 'kişiliğini fotoğraftan kesin anladım', 'burcuna göre cildin şunu ister', 'numerolojik olarak bu beden uygundur'.

---

# V19-10 — CONTEXTUAL LOCAL LEARNING: GELİŞEN AMA GÜVENLİ ZEKÂ

## 10.1 Üç ayrı öğrenme türü

**L1 preferences:** deterministik lokal özellik ağırlıkları; 'kullanıcı klasik ısmarlama yaka yerine yuvarlak yaka beğeniyor' gibi yeniden üretilebilir öğrenme. Model eğitimi gerekmez.

**L2 calibrated local ranker:** yalnız yeterli kullanıcı geri bildirimi, testte üstünlük ve desteklenen cihaz performansıyla küçük Core ML / hafif model; embedding/checkpoint/ANN indeksleri cihaz içinde şifreli. Kullanıcı bu öğrenmeyi durdurabilir, sıfırlayabilir.

**L3 shipped model evolution:** merkezi model gövdesi için anonimleştirilmiş ve hukuken uygun veri hakları, kontrollü offline test, imzalı release/weights, rollback, kill switch. Kullanıcı özel fotoğraflarını 'global eğitime' otomatik sokma. Otomatik kendi kendine kod/modül güncellemesi yok.

## 10.2 Güvenli zaman içindeki evrim

`FeedbackEvent → privacy gate → provenance → feature updater → candidate preference revision → shadow evaluation → local holdout → rollback threshold → signed active version`.

`feedbackWeight` negatifleri cezalandırır, ama tek beğenme tüm stil profilini çevirmemeli; `sampleCount`, güven, yaşlanma/decay, çoklu bağlam ve tercih düzeltme dikkate alınır. Kişi iş görüşmesi için klasik kıyafet giydi diye hafta sonu stilini kalıcı klasik sayma. Tek kullanıcı tercihi global 'moda gerçeği' olmaz.

**Model drift:** ürün katalog revizyonu değişince önceden öğrenilmiş aynı ürün-fit kanıtı eskimiş sayılmalı; sezon/trend değişimleri kişisel stil profilini silmemeli.

---

# V19-11 — OCTOPUS ATELIER: GÖREVLER, SÖZLEŞMELER VE GÜVEN SINIRLARI

**Mimari:** tek `IntentOrchestrator` + typed `WorkOrder` + `EvidenceRegistry` + `CapabilityPolicy` + `DeviceGovernor` + `DecisionEnvelope`; 25 görev ≠ 25 ayrı LLM. Başlangıçta modüler Swift paketleri ve çok az yerel ML modeli, pahalı modeller yalnız faydası ve cihaz ölçümü kanıtlanınca.

| Runtime uzman/modül | Girdisi | Çıktısı | Kritik güven sınırı | İnsan/kod kalite sahibi |
|---|---|---|---|---|
| R01 `ScanController` | Kamera frames | barcode/OCR candidates | Frames local, no network | iOS Vision |
| R02 `ImageQualityGate` | ROI/light/blur | rescan/crop cue | görünmeyeni üretme | CV QA |
| R03 `ProductIdentityResolver` | GTIN/SKU/candidates | exact/ambiguous/unknown | product data only | Catalog |
| R04 `CatalogEvidenceGate` | claims/licenses/TTL | safe verified fields | lisans/claim refusal | Data rights |
| R05 `BrandGraphIndex` | market/model/variant | typed matching | brand owner separation | Data eng |
| R06 `GarmentMeasurementParser` | source specs | normalized mm/cm | body table ≠ finished garment | Technical patternmaker |
| R07 `FabricDNAEngine` | composition/test/label | material claims | image-inferred ≠ measured | Textile scientist |
| R08 `CareLabelInterpreter` | OCR/brand label | safe care facts | wash °C ≠ wear °C | Material specialist |
| R09 `ThermalAdvisor` | weather/activity/layers | conditional comfort | no fixed universal Celsius | Thermal specialist |
| R10 `BodyProfileManager` | manual measurements/morph | private `BodyRevision` | never egress | Avatar engineer |
| R11 `RegionalFitEstimator` | body/garment/ease | region fit/evidence | abstain if incomplete | Fit science |
| R12 `FitPassportLearner` | verified user trials | scoped preferences | no cross-model certainty | Fit QA |
| R13 `AssetRightsGate` | licensed texture/3D | displayable asset ref | revoke asset/rights | Legal + 3D |
| R14 `GarmentGeometryEngine` | body/mesh/fit asset | 3D runtime asset | generic vs exact fidelity | Graphics eng |
| R15 `LogoTextureVerifier` | asset/verified reference | logo/texture pass/fail | no fabricated trademark | Visual QA |
| R16 `WardrobeGraph` | user owned/availability | wearable owned items | local vault | Wardrobe |
| R17 `StyleDNAEngine` | local feedback/intents | personal style profile | no hidden traits | Privacy + styling |
| R18 `OccasionCultureAgent` | user choice/venue rules | dress constraints | no stereotype | Context expert |
| R19 `AtelierCandidateComposer` | anchor/wardrobe/products | candidate outfits | no forced purchasing | Styling director |
| R20 `OutfitConstraintSolver` | sizes/weather/budget | valid outfits | hard constraints first | Optimization |
| R21 `OutfitMultiObjectiveRanker` | validated features | ordered alternatives | commission not input | Ranking QA |
| R22 `SymbolicInspiration` | opt-in symbolic data | aesthetic variations | off by default, no safety effect | Ethics |
| R23 `CommerceEligibility` | trusted offers | optional buy routes | no unverified stock | Retail ops |
| R24 `SponsorIndependenceGate` | disclosed ads | separate placements | no ranking manipulation | Ads QA |
| R25 `DeviceResourceGovernor` | thermal/memory/power | task budgets/fallback | human UI priority | Mobile SRE |
| R26 `PrivateVault+Egress` | capability/consent | allow/deny/audit | default deny | Security |
| R27 `DecisionEvidenceComposer` | specialist reports | 1 explainable result | never mix truth tiers | Orchestrator QA |
| R28 `FeedbackOutcomeLab` | user feedback + test corpus | calibrated updates | anonymous only by explicit separate consent | Model QA |

**İletişim:** Her işte `traceID`, `subjectRef`, `bodyRevision`, `productVariantRef`, `contextRevision`, `schemaVersion`, `deadline`, `dataClassification`, `allowedCapabilities`, `evidenceIDs`, `TTL`, `failureReason`. Ajan başkasının ham fotoğrafını okuyamaz; yalnız asgari alanı sağlayan capability token alır. Opt-in olmayan doğum verisi veya kişisel beden ticari modüllere görünmez.

**Çatışma:** Product identity için iki aday → `AMBIGUOUS`; material kaynakları çelişir → `CONFLICT`/no thermal exactness; fit eksik → `PARTIAL/ABSTAIN`; 3D kaynak yok → `GENERIC/2D`; ağ kesilir → local-only; düşük güç → kamera+basic card. Orkestratör girdi revizyonu değişirse eski sonucu UI'ya koyamaz. 'Agent consensus' gerçek ölçüm yerine geçmez.

---

# V19-12 — PRIVACY CITADEL / DEVICE HEALTH / SUPPLY CHAIN

**Çelik Kubbe yalnız şifreleme demek değildir:** privacy by design + güvenli depolama + amaç temelli erişim + her ağ çıkışında enforcement + imzalı model ve asset + saldırı yüzeyi denetimi + silme + gözlemlenebilirlik + geri alma.

1. `PhotosPicker` seçilen fotoğrafları izin verilmiş şekilde işler; tüm fotoğraf arşivini arka planda taramak için ayrı net PhotoKit izni gerekir. Var olan fotoğraflardan yüz, vücut veya hassas veri süzme varsayılan **OFF**; user selection, local segmentation, controlled batch. https://developer.apple.com/documentation/PhotoKit/selecting-photos-and-videos-in-ios .
2. Yüz/beden görselleri, ölçüler, avatar morph, kıyafet dolabı, style DNA, seyahat planı `PRIVATE_LOCAL`; ürün GTIN ve genel retail feed `PUBLIC/RESTRICTED_LICENSED`; üçüncü taraf reklamcıya private alan yok. App analytics opt-in veya veri minimizasyonlu ve özel yüzler/ölçüler olmadan.
3. Keychain/CryptoKit ile vault, platform key hierarchy, AAD, file protection; Secure Enclave uygun key operations'a ayrılır; 'Secure Enclave her dosyayı doğrudan şifreler' gibi yanlış söylem kullanılmaz.
4. Geliştirici ajanlarına ait MCP token'ları minimum privilege; Blender MCP Python sandbox; Xcode build scripting approval; hiçbir harici agent'a kişisel vault verisini açma.
5. API/feed/model/package kaynaklarını SBOM, SHA, imza/versiyon ve lisansla kaydet; parse edilen ürün alanları untrusted content; prompt injection çalıştırma veya tool çağrılarına dönüştürme.
6. `ProcessInfo.thermalState`, Low Power Mode, memory pressure, GPU/ANE memory budget ve cancellable task manager: gündelik tarama > arka plan embedding > 3D yüksek LOD. Sıcak cihazda gecikme ve fallback; aniden arka plan fotoğraf taraması yok.
7. Offline-first: cihazda çalışan özellik ile ağdan veri alan **kamuya açık ürün katalog sorgusunu** ayır. 'Tüm iş cihazda' ifadesi: özel modelleme ve kişisel öneriler lokal; marka feed senkronizasyonu/WeatherKit gerektiğinde minimum public lookup.
8. Veri silme: anahtar silme, cache temizliği, backup/restore, app güncelleme, opt-in iptali ve log redaction senaryolarını test et. Çocuk/yaş hassasiyeti ve reklam profillemesi ayrıca incelenir.
9. App Store privacy labels, PhotoKit açıklamaları, ticari reklam açıklaması, iOS izinleri, marka varlık hakları ve kullanım sözleşmesi için release gate. https://developer.apple.com/app-store/review/guidelines/ .
10. Düşük cihaz kapasitesi için degrade modunda da 'hangi beden/ürün kanıtı' kartı kalır; 3D opsiyoneldir.

---

# V19-13 — EKRAN DİLİ: DÜNYANIN EN İYİ STİLİSTİ GİBİ AMA GÜVENİLİR

### Mağazada tek bakış kartı (örnek değerler yalnız sentetik)

```
KABİNSİZ  |  BU ÜRÜN SENDE NASIL DURUR?
Mavi / Hayalî straight denim / 30-32  [ÖRNEK VERİ]
Ürün kimliği       ✓ doğrulanmış demo varyantı (gerçek marka iddiası yok)
Beden              Bel: uygun olabilir | Kalça: veri eksik | Boy: kontrol et
Kumaş              98% pamuk 2% elastan (yalnız örnek; canlı ürüne atfedilmez)
Hava               Serin gün: ek katman isteyebilirsin, ısı ölçümü yok
3D                 Temsili model — gerçek ürün fiziği doğrulanmadı
Kombin 1           Senin beyaz gömleğin + siyah loafer  [0 TL yeni alışveriş]
Kombin 2           Gömleğin + önerilen bej ceket  [teklif varsa fiyatı/kaynağı]
Kombin 3           Daha cesur: desenli dış katman [kullanıcı tercihi]
Neden?             Dengeli kontrast / seçtiğin stil / etkinliğe uygunluk
Eksik veri         Kalça bitmiş ölçüsü ve lisanslı 3D varlık
[Üzerimde Gör] [Dolabımla Kombinle] [Stilimi Değiştir] [Deneyip Geri Bildir]
```

- 1 ekran üzerinde fazla gösterme; ilk seviyede marka/model, beden durumu, 2 kombin ve CTA. Derin teknik bilgi 'neden?' kartında.
- `MY STYLE`, `SAFE CLASSIC`, `CREATIVE`, `EVENT`, `LOW-BUDGET` seçenekleri kullanıcı aktif seçer.
- `Confidence`: görüntünün/fiziksel fit'in kaynağı ayrı simgeler; yeşil 'doğrulandı' yalnız kaynak gerçekken.
- Sahte %98 puan yok, insan bedeni küçültücü/standartlaştırıcı metin yok. Görselin üretici fotoğrafı mı simülasyon mu olduğu ekranda belirtilir.
- Gerçek dış ortam (Galata) görüntüsü için kaynak veya temsili lokasyon etiketi.

---

# V19-14 — GELİR VE ÇOK MARKA: TARAFSIZLIĞIN TESTİ

Mevcut v1.8 kapsamını **sistem doğruluğuna bağla**: önce kullanıcının sahip olduğu parçalar, sonra isteğe bağlı aynı mağaza, ardından çok marka. Orijinal stil/beden puanı sponsorluk, affiliate oranı, toptan anlaşma ve stoka göre ticari manipülasyonla değişmez.

**Ticari sistemin başarısı:** `(a)` kullanıcı alışveriş yapmadan memnun kombin bulursa başarıdır, `(b)` mağazada uygun ürünü hızlı tanırsa başarıdır, `(c)` satın alma ihtiyacı varsa tarafsız şekilde doğru ürüne giderse etik ticari fırsattır. Satış tahmini ve komisyon **varsayımdır**, partner olmadan elde edilen gelir değildir.

- Affiliate, B2B perakende entegrasyonu, lisanslı marka feed hizmeti, premium stilist/valiz, etiketli sponsored suggestions ayrı gelir kalemleri. Her birinde hak, fatura/vergi, attribution, refund, consent ve App Store ödeme kuralı test edilir.
- Risk: markanın ürün görselini/logo ve kullanıcı yorumlarını lisanssız toplamak; `web search` çalışıyor olması veri kullanım hakkı değildir.
- Çok markalı ölçek hedefi `UNRECOGNIZED`, `BASIC_IDENTITY`, `VERIFIED_VARIANT`, `FIT_READY`, `VISUAL_READY`, `PILOT_VALIDATED` kademelerinde raporlanacak. Her marka ve ülkede 100% katalog/kesin beden iddiası yok.
- B2B teklif: raf/etiket verisini kolay sağlayan feed adapter, SKU hygiene raporu, agregat ve gizlilik korumalı sıraya/giyime katkı metrikleri. Gerçek mağaza ortaklığı olmadan başarı oranı ilan edilmez.

---

# V19-15 — YENİ CLAUDE GELİŞTİRME AJANLARI VE AYRIMLARI

Bu **Claude Code geliştirme rolleri**, uygulama içindeki R01-R28 modüllerinden ayrıdır. Gereksiz yeni ajan üretme; `.claude/agents/` içinde halihazırda eşdeğeri varsa genişlet ve çakışma matrisini güncelle. Herinin kartı: `scope/input/output/tests/forbidden permissions/evidence/reviewer/stop conditions`.

| Ajan kartı | Ana sorumluluk ve dosya | Gerekli bağımsız denetçi |
|---|---|---|
| `principal-system-integrator` | v1.5-1.9 çatışma analizi, DAG, contracts | release gate |
| `fast-scan-cv-engineer` | Vision barcode/OCR/camera latency, degraded input | privacy + CV QA |
| `catalog-identity-and-rights-lead` | global variant graph, license, provenance, canonicalization | legal + data auditor |
| `technical-patternmaker-fit-scientist` | antropometri, ease, size systems, physical truth lab | human modelist + fit QA |
| `textile-thermal-specialist` | fabric composition/care/thermal inference | textile test evidence QA |
| `realtime-garment-graphics-lead` | Blender->USDZ, morph, collision, logo/texture | asset fidelity reviewer |
| `atelier-fashion-director` | outfit grammar, creative variants, human fashion rubric | independent style panel |
| `personalization-and-ranking-scientist` | Style DNA, local learning, Pareto ranking, calibration | privacy & fairness QA |
| `symbolic-experience-curator` | explicit opt-in creative metaphor, off by default | ethics/privacy reviewer |
| `mobile-performance-sre` | real device p95/thermal/memory/energy | independent perf auditor |
| `retail-commercial-integrity` | unbiased commerce, sponsor separation, budget adherence | compliance auditor |
| `adversarial-evidence-auditor` | tests false success, model claims, wrong variant, fabricated logos | independent review |

**Önemli:** Ajanların hepsi LLM istemiyle gerçek insan modelist, tekstil laboratuvarı veya fizik testi yerine geçmez. İnsan uzman doğrulaması gerekli işlerde `HUMAN_EXTERNAL_REVIEW_PENDING` yaz.

---

# V19-16 — SKILL VE MCP PLANLAMASI: 'DAHA ÇOK TOOL' DEĞİL, DOĞRU TOOL

| Araç / skill | İş | Durum ve emniyet |
|---|---|---|
| **GitHub connected capability** | mevcut branch, PR, commits, code review | kurulu ve repo okuma mümkün; yazma izni olsa da kullanıcı onaysız main'e push yok |
| **Xcode CLI / optional XcodeBuildMCP** | iOS simulator/physical device build, instrument, snapshot | önce yerel erişimi doğrula; MCP yeni kurulum ayrı onay, en az ayrıcalık |
| **Blender 5.2.3 CLI** | rig, shapekey, UV, LOD, texture baking, USDZ asset factory | repo v1.5 baseline'da kurulu; Blender MCP zorunlu değil, kod yürütme sandbox ve review gerektirir |
| **Apple Vision / Core ML** | local CV, image embeddings, categorization, optional personalization | Foundation SDK, hız/cihaz/test ile karar |
| **RealityKit / Metal** | mesh deformation, render fidelity, iPhone preview | OS availability + supported device target doğrula |
| **GS1 / licensed catalog connector** | GTIN validation, authorized feed | otomatik izin ve evrensel ücretsiz API varsayma; limit/lisans/sözleşme gate |
| **Figma design connector (optional)** | screen/polish audit | mevcut design source yoksa ekleme |
| **Local SQLite/SwiftData?** | local index/wardrobe/query | encrypted vault migration ve benchmark'la seç; birden fazla state store gereksiz |
| **Benchmark & profiling tool** | XCTest/Swift Testing/Instruments/xcresult | saat, cold start, memory, thermal capture; gerçek cihaz erişimi şart |

**Yeni skill isimleri** (yalnız açık boşluk varsa `.claude/skills/` yaz):

`scan-product-identity-truth`, `retail-feed-provenance`, `finished-garment-measurement-normalizer`, `fit-calibration-lab`, `fabric-care-thermal-safety`, `garment-asset-logo-fidelity`, `atelier-outfit-ranking-evaluation`, `privacy-preserving-local-learning`, `on-device-inference-benchmarking`, `independent-system-claim-audit`.

Her skill: ihtiyaç, input schema, yapması yasaklar, iyi/kötü örnek, üretilecek artefact, çalıştırılabilir test, reviewer, son güncelleme. Harici açık kaynak skill veya MCP yetkilerini doğrulamadan kurma; üçüncü taraf kodlarını güvenlik denetiminden geçir.

---

# V19-17 — UYGULAMA İŞ PAKETLERİ / BAĞIMLILIK GRAFİĞİ

**Önce repo gerçeği:** `git status`, HEAD, branch, Xcode, testler, network/consent, real-device durumunu ölç. v1.8 ve bu ek repo kanonuna yazılacaksa `CLAUDE.md` ve `docs/constitution/` conflict resolution ADR'ı oluştur; yeni dosya eski kanonu sessizce ezmesin.

| WP | Kapsam | Ön şart | Kabul / çıkış |
|---|---|---|---|
| WP19-00 | canlı repo diff + v1.5-1.9 gap & risk + evidence | — | reality report ve blocker list |
| WP19-01 | yürürlükte olmayan izinli egress/vault/device governor bloklarını düzelt | WP15-02 | runtime denial, migration, thermal test; henüz gerçek cihaz yoksa açık kalır |
| WP19-02 | event/decision contract + version guards + independent reviewer | WP19-01 | yüz/beden network'e gitmez; eski sonuç UI'da görünmez |
| WP19-03 | Vision camera scan + OCR/GTIN and exact identity | WP19-02 | cihazda scan negative cases, p95 kanıt |
| WP19-04 | verili/sentetik ayrılmış global brand graph + pilot feed schema | WP19-02 | sentetik fixture corpus, lisanssız üretilmiş veri canlı değil |
| WP19-05 | garment finished measurements & body fit science schema | WP19-04 | farklı size sistemleri, missing-data abstain |
| WP19-06 | Fabric DNA + care vs wear thermal split | WP19-04 | OCR+manual verification, 30° wash confusion test |
| WP19-07 | private avatar morph + 3D geometry/asset QA | WP19-01/02 | kaydırıcı/mesh correspondence, persistence, neutral model |
| WP19-08 | product fidelity + prepped garment overlay | WP19-07/04 | logo/doku/renk tests + correct visual tier |
| WP19-09 | Style DNA preferences + owned wardrobe graph | WP19-01/02 | opt-in, forget, cold start, feedback roundtrip |
| WP19-10 | Atelier candidate composer + constraint + ranking | WP19-05/06/09 | 3 distinct looks; fit/comfort/no-buy; sponsor isolation |
| WP19-11 | shopping scan → fit → outfits → visual decision UI | WP19-03/05/06/08/10 | 1 iPhone e2e; offline/no-data variants |
| WP19-12 | model & human evaluation + blinded style review | WP19-11 | no metrics without real reference and human reviewer |
| WP19-13 | performance tier + thermal + battery + memory gate | WP19-11 | p50/p95/p99 real-device artifacts, cold/warm/network buckets |
| WP19-14 | symbolic opt-in creative layer + fairness/ethics tests | WP19-10 | excluded from safety/fit/weather/commerce; default OFF |
| WP19-15 | partner growth/affiliate integration & legal gating | WP19-11/12 | authorized feed/rights/contract, no PII egress |
| WP19-16 | CI threat model, supply chain, release gate | tüm kritik P0 | evidence artifacts, green tests, external unresolved clearly blocked |

**Sıralama ilkesi:** Kamera ve katalog işi sentetik fixture üzerinde güvenlik/3D ile paralel *ayrı dalda* yapılabilir; entegrasyon testleri tamamlanmadan merge edilmez. Seyahat ve Android hiçbir zaman temel ürün doğruluğunun önüne geçirilmez.

---

# V19-18 — OLUMSUZ/ADVERSARIAL TEST SETİ (YENİ; KOŞULMADAN PASS DEĞİL)

Aşağıdaki ID'ler yeni test gereksinimleridir. Bunların hiçbiri burada çalıştırılmış değildir. Claude testleri uygun Swift Testing/UI/e2e/fiziksel benchmark paketlerinde gerçekleyip traceability'ye bağlayacak.

## Identity / Product Truth

- **V19-T-001**: Kamera aynı anda iki barkod görür → kullanıcı seçmeden exact ürün yok.
- **V19-T-002**: Etiket kırışık, yansıma, OCR 0/O / 1/I → geçersiz kod yanlış ürüne bağlanmaz.
- **V19-T-003**: Aynı model, farklı beden/renk GTIN → varyantlar doğru ayrılır.
- **V19-T-004**: GS1 kimliği biliniyor, partner material feed yok → lif ve ölçü `UNKNOWN`.
- **V19-T-005**: GTIN/check digit yanlış → invalid, güvenli manuel fallback.
- **V19-T-006**: Partner iki farklı kumaş kompozisyonu yayınlar → conflict, kesin öneri yok.
- **V19-T-007**: İki merchant aynı varyant farklı stok/fiyat → kanıt ve offer ayrımı.
- **V19-T-008**: TTL bitmiş katalog; cihaz offline → `stale`, yeni doğruluk iddiası yok.
- **V19-T-009**: Marka katalog revizyonu ve lisans iptali → cached image/logo invalidation.
- **V19-T-010**: Görselde yakın ama başka marka pantolon → exact variant olarak sunulmaz.

## Fit and Fabric

- **V19-T-011**: '30°C yıkama' etiketi → 30°C giyim önerisine dönüşmez.
- **V19-T-012**: Beden tablosu sadece hedef insan ölçüsü → bitmiş giysi gibi hesaplanmaz.
- **V19-T-013**: Göğüs ölçüsü var, kalça gerekiyor → partial/abstain.
- **V19-T-014**: Yüzde lif eksik → model fotoğrafa bakıp % pamuk yazamaz.
- **V19-T-015**: Aynı pantolon farklı elastan % → uyum ve esneme çıkarımları ayrı.
- **V19-T-016**: Kumaş çok kalın görünüyor ancak test verisi yok → kesin gramaj yok.
- **V19-T-017**: Bel ölçüsü aynı iki ürün kesimi farklı → farklı fit outcome.
- **V19-T-018**: Ölçü belirsizlik aralıkları iki bedene taşar → kesin beden önerisi yok.
- **V19-T-019**: Aynı markada iki modelde 'M oldu', farklı slim pantolona kesin kopyalanmaz.
- **V19-T-020**: 'Ayakta uygun, oturunca dar' gözlemi ayrı fit field'ına kaydedilir.
- **V19-T-021**: Marka beden sistemi W/L ile TR/EU karışır → dönüşüm ID ve açık kaynak.
- **V19-T-022**: Kullanıcı herhangi bir beden ölçüsünü siler → sonraki tüm kararlar yeni revizyona bağlanır.

## Visual Geometry / Fidelity

- **V19-T-023**: Bel slider % değişince gerçek ilgili mesh vertex ve çevre ölçüsü değişir.
- **V19-T-024**: Omuz slider kalça bölgesini anlamsız deforme etmez.
- **V19-T-025**: Avatar revizyonu değişince cached giysi önizlemesi yenilenir.
- **V19-T-026**: Lisanslı ürün görselinin logo yazısı farklı renderlanır → fail/fallback.
- **V19-T-027**: Pattern/logo izinli değil → asset gösterim engeli.
- **V19-T-028**: Beden mesh collision veya extreme morph → fallback/açık uyarı.
- **V19-T-029**: Görsel tier generic ama UI bunu 'ürüne özel doğrulanmış' diyemez.
- **V19-T-030**: Farklı aydınlatma ile ten/ürün rengi → 'tam gerçek renk' garantisi yok.
- **V19-T-031**: Generative model başka bir aksesuar yaratır → kalite gate red.
- **V19-T-032**: 3D iş kuyruğu iptal edilir → CPU/GPU işi durur, UI donmaz.

## Atelier Style / Personalization / Ethics

- **V19-T-033**: Dolabında eksiksiz kombin → 0 TL satın almadan ilk sonuç.
- **V19-T-034**: Bütçesi 1.500 TL kullanıcı → organik aday 1.501 TL'yi yanlışlıkla önceliklendirmez.
- **V19-T-035**: Resmi iş görüşmesi ile hafta sonu sahil → tercih revizyonu aynıyken farklı bağlama uygun sonuç.
- **V19-T-036**: User 'asla deri' → yeni ve sahip olunan deri adayları elenir (isteğine göre).
- **V19-T-037**: Stil profili boş → zengin varsayımlarla kişi profili uydurulmaz.
- **V19-T-038**: Bir kez klasik kıyafet tercih → kişinin hafta sonu kalıcı stili bozulmaz.
- **V19-T-039**: 'Daha cesur' → en az 1 stil değişkeni değişir, budget/fit bozulmaz.
- **V19-T-040**: 'Daha sade' → logo/desen/renk karmaşıklığı azaltılır, bedensel özelliğe hüküm yok.
- **V19-T-041**: Reklam veren 3 kat daha fazla komisyon → organik karar sırası aynı kalır.
- **V19-T-042**: Sembolik mod kapalı → doğum tarihi/sayı/burç hiçbir stil kararına girmez.
- **V19-T-043**: Sembolik mod açık → yalnız kreatif varyant; beden/weather/privacy/ads puanları değişmez.
- **V19-T-044**: Kullanıcı stil hafızasını siler → local embeddings/cache/feedback temizlenir.
- **V19-T-045**: Ten tonu analizi izni yok → otomatik ton profili yok; manuel renk paleti çalışır.
- **V19-T-046**: Farklı beden/yaş/engellilik/örtünme/stil tercihi örnekleri → önyargılı güzellik hükmü yasak.

## Security / Device / Evidence

- **V19-T-047**: `ProductLookup` payload'unda body measurements/photo/doğum/wardrobe → egress denied.
- **V19-T-048**: Feed JSON prompt injection içerir → no tool instructions/execution.
- **V19-T-049**: İzin geri alınır → bekleyen camera/photo işler iptal, ilgili cache temizlenir.
- **V19-T-050**: Kritik ısı / düşük güç → görselleştirme LOD düşer veya durur; temel karar kartı kullanılabilir.
- **V19-T-051**: Deep-link ile stale productCode veya eski bodyRevision → yanlış karar yayınlanmaz.
- **V19-T-052**: Uygulama kapat aç, migration başarısız olur → eski encrypted data overwrite edilmez.
- **V19-T-053**: Güvenli silme sonrası restore/backup senaryosu → gizlilik garantisi ve backup limits açık.
- **V19-T-054**: Lisanssız model/asset → release gate blocked; dependency/SBOM proof.
- **V19-T-055**: Isı/bellek basıncı altında foreground scan → crash yok, timeout ve fallback doğrulanır.
- **V19-T-056**: Ürün bulunamıyor → kullanıcıya yanlış markalı ürün sunulmaz.
- **V19-T-057**: Testte yanlış ürün kimliği ile 0.1 sn sonucu → hızlı ama başarısız sayılır.
- **V19-T-058**: `S1/S2/S3` p95 başarısı yalnız cached ve test koşullarıyla etiketlenir; ağ gecikmesini gizleme.
- **V19-T-059**: Aynı veri ve local model sürümünden tekrarlı öneriler reproducible; random seed kayıtlı.
- **V19-T-060**: Kendi modülü 'verified' der ama EvidenceRegistry'de geçerli kayıt yok → UI verified reddeder.

## Human / field validation

- **V19-T-061**: Gerçek fit denemesindeki 'dar/bol/tam' yanlışlarını kategori ve marka kesitlerinde raporla.
- **V19-T-062**: Blinded expert panel gerçekte yoksa `HUMAN_REVIEW_PENDING`, sahte onay yok.
- **V19-T-063**: Kullanıcının kombin değişiklik nedenleri istatistiği → opt-in lokal, anlamlı kişisel trend.
- **V19-T-064**: Gerçek mağaza pilotunda ürün doğru tanıma, median/p95, kabin kuyruk etkisi ayrı kontrol grubu.
- **V19-T-065**: Ürün görseli kullanıcı tarafından estetik beğenildi ama fiziksel beden yanlış → fit quality fail.
- **V19-T-066**: Aynı kullanıcının üç farklı bağlamdaki üç look'u stil yönünden gerçekten ayırt ediliyor mu? panel rubriği.

---

# V19-19 — BENCHMARK KABULÜ VE KANIT DOĞRULAMA SÖZLEŞMESİ

## 19.1 Zorunlu benchmark dataset tipleri

- `SyntheticIdentityFixtures` → çoklu barkod, OCR hata, aynı kod farklı varyant, stok TTL.
- `PartnerAuthorizedProductFixtures` → marka ve kaynak/ürün bitmiş ölçüleri; anlaşma olmadan gerçeğe dönüştürülmez.
- `GarmentMeasurementTruthSet` → teknik modelist ölçüsü, insan ölçüsü, farklı size/fit, measurement uncertainty.
- `FabricLabelTruthSet` → üç dilde bakım etiketi; wash/wear separation.
- `AvatarGeometryFixtures` → referans ölçülü morph/mesh.
- `StyleOutfitPreferenceSet` → insan uzman blind panel ve kullanıcı pairwise beğenileri, consent ve eval isolation.
- `DeviceBenchmarkSet` → minimum desteklenen iPhone, orta iPhone, üst iPhone; cold/warm, Wi-Fi/4G/offline, thermal nominal/serious, battery normal/low-power.
- `PrivacyAttackSet` → exfiltration, privilege escalation, malicious asset/feed, stale revision.

## 19.2 Metrikler

`exact_variant_accuracy`, `false_exact_identity_rate`, `coverage_by_brand_and_market`, `fit_region_precision`, `fit_abstention_rate`, `overconfidence_error`, `fit_ECE`, `garment_asset_texture_fidelity`, `logo_OCR_agreement`, `outfit_appropriateness_blind_pref`, `personalized_vs_baseline_winrate`, `style_diversity`, `p95_scan_to_first_useful_card`, `p95_cached_to_first_3D`, `peak_memory_MB`, `energy_per_scan`, `thermal_degrade_duration`, `network_private_payload_violations`, `revenue_independence_test`.

**Threshold policy:** Ürünün gerçekten çalıştığına dair minimum seviyeleri Claude uzmanlarla önerip **önceden** kaydeder; testten sonra eşiği sonuca uydurmak yasak. Yüzde raporlaması için gerçek test örneği ve CI şart. `PASS` için median tek başına yetmez; p95 + hatalı karar oranı + gizlilik + kullanıcı geri bildirimi gerekir.

## 19.3 Çıktı formatı

Her WP: `requirement_ids`, `sha`, `build_output`, `test_command`, `test_result`, `device/os`, `dataset_version/rights`, `screenshots/video`, `privacy_egress_capture`, `perf_trace`, `model_license`, `known_failure`, `independent_reviewer`, `release_gate`, `rollback_plan`. NO_DATA ve BLOCKED durumları dürüstçe kalır.

---

# V19-20 — CLAUDE'A ZORUNLU 40 DENETİM SORUSU (KOD/TEST KANITLI CEVAP)

## Ürün doğruluğu

- **V19-Q01:** Repo HEAD nedir, working tree temiz mi, açık PR/branch var mı, testlerin gerçek çıkış kodu ne?
- **V19-Q02:** v1.8/v1.9 gereksinimleri v1.5 `CLAUDE.md` kanonu ile nerede çelişiyor?
- **V19-Q03:** Kamera bugün gerçekten açılıyor mu? Hangi dosya/test kanıtlıyor?
- **V19-Q04:** Offline/online ürün kimliği hangi kesinlik seviyelerinde döner?
- **V19-Q05:** Hiçbir marka feed'i olmadan 'tüm markalarda gerçek kumaş' nasıl engelleniyor?
- **V19-Q06:** GTIN, SKU, styleCode, color/size variant ve feed revision hangi tiplerle ayrılmış?
- **V19-Q07:** GS1 sorgu erişimi, kullanım limiti, lisans ve caching hakkı gerçekten doğrulandı mı?
- **V19-Q08:** Marka verisi çelişince hangi source-of-truth kazanır, conflict nasıl loglanır?
- **V19-Q09:** Beden tablosundaki **hedef beden ölçüsü** ile gerçek **bitmiş giysi ölçüsü** kesinlikle ayrılıyor mu?
- **V19-Q10:** Yanlış kesin beden tavsiyesinin falsification testi, abstention ve kalibrasyonu var mı?
- **V19-Q11:** Kalça/omuz/kol ölçüleri ve giyilmiş ürün deneyimleri mevcut hangi kodda çalışıyor?
- **V19-Q12:** Kumaşın lif %, kalınlık, esneklik gibi verileri fotoğraftan uydurulmuyor mu?
- **V19-Q13:** 30°C yıkama ve 30°C hava durumu nasıl ayrı tiplerle korunuyor?
- **V19-Q14:** Kumaş/hava/aktivite katmanlarından konfor tahmini kaçıncı confidence tier?
- **V19-Q15:** Gerçek 3D mesh ile kullanıcı slider değişikliği birleştirildi mi?
- **V19-Q16:** Ürün asset'i hangi marka/model/renk/beden varyantına ait ve lisanslı mı?
- **V19-Q17:** Logo/etiket/dikiş/doku yanlış üretimini karşılaştıran test mevcut mu?
- **V19-Q18:** Fotogerçekçi VTON ile gerçek fiziksel fit'i UI neden ayrı tutuyor?

## Stilist ve kişi anlayışı

- **V19-Q19:** Şu an 'kombin uyumu' yalnız renk+kategori mi, yoksa siluet/texture/formality/comfort hesaba katılıyor mu?
- **V19-Q20:** Personal Style DNA'nın 12 ekseni için data contract ve forget/override akışı var mı?
- **V19-Q21:** 'Klasik / yaratıcı / cesur' üç varyant gerçekten farklı mı, aynı kıyafet tekrar mı?
- **V19-Q22:** Renk ve ten tonuna dair inference ne zaman hiç yapılmaz, hangi kullanıcı kontrolü var?
- **V19-Q23:** Hangi bağlam girdileri kesin kullanıcı beyanı; hangileri veriden infer edildi?
- **V19-Q24:** 'Bu kişiye yakışır' ifadesini ölçmek için insan stilist A/B benchmark kuruldu mu?
- **V19-Q25:** Ruh hali, kişilik, kültür, etnisite ve din fotoğraftan çıkarsanıyor mu (olamaz)?
- **V19-Q26:** Numeroloji/astroloji default OFF mu, öneride kullanım açık gösteriliyor mu?
- **V19-Q27:** Kullanıcı 'Bunu unut' dediğinde embedding/öğrenme güncellemesi geri alınabiliyor mu?
- **V19-Q28:** Yerel ranker gerçekten eski tavsiyelerden daha iyi mi? Ablation/baseline kanıtı nedir?

## Entegrasyon / güvenlik / performans / ticari

- **V19-Q29:** Octopus gerçek runtime scheduler olarak mı çalışıyor yoksa sadece contract mı?
- **V19-Q30:** `EgressIntent` tüm network call path'lerinde enforce ediliyor mu?
- **V19-Q31:** Private vault CryptoKit/Keychain ve migration gerçekten kodlandı/test edildi mi?
- **V19-Q32:** Critical thermal state'de hangi UI ve ML işleri kesin duruyor?
- **V19-Q33:** First useful card, confirmed product ve prepared 3D için ayrı gerçek-device p95 var mı?
- **V19-Q34:** iPhone test yoksa hangi gate BLOCKED ve hangi başarı iddiası yasak?
- **V19-Q35:** Kullanıcı kısıtları ile sponsor/affiliate sıralaması nasıl ayrılıyor?
- **V19-Q36:** Brand/merchant rights, logo license ve ürün fotoğrafı izni var mı?
- **V19-Q37:** Model/code/weights license ve dependency SBOM taraması üretimde kullanılabilir mi?
- **V19-Q38:** İnsan moda uzmanı/fit paneli olmadan hangi yayın özellikleri sınırlı kalmalı?
- **V19-Q39:** En pahalı 3 teknik risk ve en ucuz falsification PoC nedir?
- **V19-Q40:** Bir kullanıcı mağazada tarama yaparken *yarın* hangi gerçek sonucu görecek, hangisi SPEC_ONLY?

**Her soruyu** `EVIDENCE | ASSUMPTION | UNKNOWN | BLOCKED` etiketiyle ve `path:line`, test, sha, veri hakkı ve düzeltme WP ID ile cevapla. Buradaki 'yarın' yeni teslim vaadi değil; mevcut ürün yeteneklerinin somut test senaryosudur.

---

# V19-21 — CLAUDE TESLİMAT DOSYALARI / YAZILACAK ÇIKTILAR

1. `docs/audit/V19_REALITY_AND_GAP_REPORT.md` — bu belgedeki tüm Q01..Q40 cevapları ve mevcut durum.
2. `docs/audit/V19_REQUIREMENT_TRACEABILITY.md` — v1.5..v1.9 REQ→code→test→owner→status, çelişki kaydı.
3. `docs/system/V19_OCTOPUS_MODULE_REGISTRY.md` — R01..R28, capability matrix, typed I/O, event timeline, threat model.
4. `docs/data/V19_PRODUCT_TRUTH_AND_RIGHTS.md` — GTIN, feed, marka kaynak/TTL/lisans matrisi; gerçek partner yoksa blocked.
5. `docs/ai/V19_STYLE_DNA_AND_ATELIER.md` — bütün input alanları, kullanıcı kontrolü, outfit yaratım/ranking ve kişisel öğrenme.
6. `docs/quality/V19_FIT_FABRIC_VISUAL_BENCHMARKS.md` — baseline, dataset/rights, metrics, ablations, holdout, fail cases.
7. `docs/quality/V19_ON_DEVICE_LATENCY_PLAN.md` — cold/warm/cached/network, p50/p95/p99 ve device matrix.
8. `docs/security/V19_CITADEL_EGRESS_AND_VAULT_AUDIT.md` — tüm veri akışları ve negatif testler.
9. `docs/roadmap/V19_DEPENDENCY_DAG.md` — P0/P1/P2/BLOCKED/REJECTED + test/owner/dependency.
10. `.claude/agents/...` ve `.claude/skills/...` yalnız eksikleri karşılayan, derlenebilir/çalıştırılabilir gerçek yeteneklere bağlanmış kartlar.
11. İlk uygulama PR'ında çalışan kod + birim test + UI test + screenshot/xcresult + negative evidence + ADR + rollback; çalışma ağacı temiz ve geriye uyum.
12. İnsan onayı gerektiren marka anlaşmaları, ücretli MCP ve canlı hesap işlemleri `NEEDS_USER_ACTION` altında açıkça listelenir; onay gelmeden yapılmaz.

---

# V19-22 — CLAUDE'A KOPYALA / ÇALIŞTIR ANA İSTEMİ

> Kabinsiz reposunda `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v1.9.md` dosyasını ana yürütme şartnamesi olarak incele. Repo `CLAUDE.md` ve var olan v1.5 kanonuyla öncelik çatışmasını ADR ile çöz; mevcut çalışan kodu ve testleri koru. Önce güncel SHA/branch ve fiziksel cihaz durumu, bağımlılıklar, test kanıtları, gizlilik sınırları ve marka veri haklarını sorgula. Sonra V19-Q01..Q40'a satır/test kanıtlı cevap ver ve eksikleri risk/bağımlılığa göre sırala. Hedef ürün: gerçek bir markanın gerçek bir varyantını kullanıcı kameraya gösterdiğinde birkaç saniye hedefiyle doğru kimlik, kaynaklı kumaş, bölgesel beden uygunluğu, doğruluğu belirtilmiş 3D önizleme ve kişinin dolabına, bütçesine, ortamına, tarzına göre etkileyici üç kombin. Kullanıcının tarzı cihaz içinde şeffaf ve kontrollü öğrenilsin. Sembolik astroloji/numeroloji sadece açık opt-in, etiketli kreatif ilhamdır; fit/beden/ısı doğruluğunu veya alışveriş sıralamasını etkilemesin. MCP/skill/agent gereksinimini gerçek açıkla, gereksiz ajan oluşturma. Veri/ürün/fit/3D hatasında kesinlik iddiası yok, geri çekil. En yüksek etkili ve izinsiz yapılabilecek ilk P0 iş paketini kodla, test et, karşı örnekle denetle ve kanıt dosyalarıyla raporla. `DONE` yalnız kanıtla; fiziksel cihaz, lisanslı partner veya insan modelist yoksa o gate açık kalsın. İlerlemeyi durdurma, P0 önceliğini koru; tamamlanmayanları `UNKNOWN/BLOCKED/SPEC_ONLY` olarak dürüstçe raporla.

---

# V19-23 — ARAŞTIRMA / KAYNAK KONTROL LİSTESİ (03.11.2026)

1. Apple Vision image/barcode/text + privacy: https://developer.apple.com/documentation/vision ; https://developer.apple.com/documentation/vision/vndetectbarcodesrequest ; https://developer.apple.com/documentation/vision/recognizing-text-in-images
2. Apple PhotosPicker izin davranışı: https://developer.apple.com/documentation/PhotoKit/selecting-photos-and-videos-in-ios
3. RealityKit deformation & iOS runtime: https://developer.apple.com/documentation/realitykit/scene-content-mesh-deformation
4. Core ML cihaz performans raporu: https://developer.apple.com/documentation/coreml/analyzing-a-core-ml-model-s-performance-in-xcode
5. Thermal/low power: https://developer.apple.com/documentation/foundation/processinfo ; https://developer.apple.com/documentation/xcode/responding-to-power-notifications
6. GS1 GTIN doğrulaması / hangi alanlar var: https://support.gs1.org/support/solutions/articles/43000734110/ ; https://support.gs1.org/support/solutions/articles/43000734095-how-do-gs1-gtins-and-barcodes-work-
7. Body/garment/try-on research: https://arxiv.org/abs/2604.08526 ; https://doi.org/10.1111/cgf.70272 ; https://doi.org/10.1080/17543266.2026.2618270
8. FASHN VTON v1.5 gerçek GPU kısıtları ve lisans: https://fashn.ai/research/vton-1-5 ; https://github.com/fashn-AI/fashn-vton-1.5
9. App Store privacy & disclosure: https://developer.apple.com/app-store/review/guidelines/
10. Repo kanıt kaynakları: `docs/audit/REALITY_BASELINE_v1.5.md`, `docs/audit/V15_QUEUE_AND_CONFLICT_MAP.md`, `docs/evidence/WP15-02.yaml`, `Packages/KabinsizCore/Sources/*`, `apps/ios/Kabinsiz/*`.

Her kaynak yayın anında sürüm, erişim koşulları, lisans, ticari uygunluk ve mahremiyet açısından yeniden doğrulanmalı. Bir URL bulunması tam kaynak erişimi veya ticari kullanım hakkı değildir.

---

## SON HÜKÜM — BÜYÜK ZEKÂ SLOGANI DEĞİL, BİRBİRİNİN HATASINI GÖREN GERÇEK BİR SİSTEM

KABİNSİZ'İN hedefi 'seni okudum' demek değil, **'seçtiğin bu ürünün şu özelliklerini doğruladım, bedeninin bu bölgelerinde şu gerekçeyle uygun görünüyor, bazı bölgeler hâlâ bilinmiyor; dolabından şu üç görünümü senin stil niyetine, havaya ve bütçeye göre hazırladım'** diyebilmek. Bir ürünün bilinmeyen kumaşı, bir insanın bilinmeyen ölçüsü veya bir markanın bilinmeyen lisansı **yaratıcı AI ile gerçekmiş gibi doldurulmayacak**. Her parçanın vazifesi, izni, yanılma noktası ve ölçülebilir kanıtı olacaktır.

# KABİNSİZ — GOD LEVEL v3.5
## DYNAMIC CITY WORLD + PRIVATE DIGITAL TWIN + OWNED LIVE MIRROR — Mimari ve Claude Uygulama Anayasası

**Tarih:** 4 Kasım 2026 · **Durum:** Uygulama şartnamesi, kurulmuş özellik veya test sonucu değildir.  
**Repo:** https://github.com/gundogandogancan/kabinsiz · **En son denetlenebilen `main`:** `30ed2ef9ab38db939ca4faf2b098f83fe256e23a` (2026-11-03T15:25:40Z).  
**Önceki esaslar:** v3.3 gerçeklik denetimi, v3.4 Katalog Ahtapot/Owned-VTON; v3.0–v3.2 ürün ve tasarım kararları aynen geçerli. Çelişkide hukuk/veri hakları > gizlilik > doğruluk > cihaz güvenliği > ölçülmüş UX > estetik. ADR'siz çelişki çözme.

## A. Tek cümlelik ürün

**Kabinsiz, kişinin gerçek yüzüne/saçına/bedenine yaklaşan özel dijital ikizini, bulunduğu gerçek şehrin atmosferinde her sabah giydirir; mağazadaki ürünü anında tanıyıp önce 360° modelinde, uygun teknoloji varsa canlı kamera görüntüsü üzerinde dener.** Kullanıcı yalnızca `Bugün / Dolabım / Dene` ve sağ üstte `Ben` görür. Arka plandaki modüller görünmez. `Maximum Intelligence. Minimum Interface.`

**Temel ayrım (karıştırma):**
- **Görünüm gerçekliği:** yüz, saç, renk, logo, kumaş dokusu ve ışık benzeyebilir; *beden doğruluğunu kanıtlamaz*.
- **Fiziksel kalıp/beden gerçekliği:** ancak ürün bitmiş ölçüleri, kumaş esneme/drape verisi, model ölçüleri ve kör gerçek prova karşılaştırmasıyla doğrulanır.
- **Canlı video gerçekliği:** fotoğraf/video üreten modelin güzel sonuç vermesi kumaş fiziğini ve gerçek beden uyumunu garanti etmez.
- **Cihaz içinde:** yüz, fotoğraf, beden, gardırop, stil hafızası yerel ve şifreli. İzinli marka katalogları ayrı ve merkezi olabilir; AI video buluta asla otomatik gönderilmez.

## B. GitHub kanıtlarına göre mevcut gerçeklik

| İş | Repo kanıtı | Durum ve eksik |
|---|---|---|
| 360° nötr mesh | `BodyGeometry/BodyMesh.swift`, iOS `BodyModel3DView.swift` | Kodlanmış; kişisel gerçekçi yüz/saç/rig yok; gerçek cihaz FPS kanıtı yok |
| Yaşayan şehir | `TodayView.swift`, `TravelEngine` şehir/seyahat | Günlük yerel şehir-dünya motoru yok; sabit örnekler hedef değil |
| Hava | `AppleWeatherProvider.swift` | Sadece açık istekli seyahat hava sağlayıcısı; gündelik sahne meteorolojisi yok |
| Katalog | `ShoppingCopilot/Catalog.swift` | Sentetik katalog; gerçek GTIN ve marka varyant kapsamı yok |
| Fotoğraftan dolap | `WardrobeView.swift` | Elle ekleme/örnek; PhotoKit+CoreML intake yok |
| Live Mirror | `LiveMirror/MirrorSession.swift` | Durum makinesi var; üretim bulut anahtarı kapalı; kamera-prova çıktısı yok |
| Tasarım | `DesignSystem/AtelierTokens.swift`, `AtelierTypography.swift` | Sıcak marka tokenları var; her kartı bunlara bağlama ve 3D-first ekran henüz bitmedi |
| Verinin korunması | `Vault`, `CitadelGate`, `ConsentLedger`, `OctopusCoordinator` | Değerli temel; yeni fotoğraf/konum/meslek/AI akışları için izin ve negative test eklenmeli |

**Açıklama:** Kaynak taraması ve repo kanıt dosyaları incelenmiştir; fiziksel iPhone'da yeniden test çalıştırılmadı. 3 Kasım'daki kullanıcı simülatör ekranları daha sonraki çalışmayı gösterebilir; kayıtsız işleri push edilmiş kabul etme. Claude ilk iş `git status`, branch, SHA, diff ve yerel assetleri gerçek zamanlı denetler.

## C. Konum → özgün kent → canlı stüdyo motoru

### C1. Kullanıcı yolculuğu

1. İlk girişte kitle izin isteme; sade açıklama: `Bulunduğun şehrin atmosferinde bugünkü kombinini gösterebiliriz.` `Şehrimi otomatik bul` / `Şimdilik geç`.
2. İzinli **yaklaşık şehir** (Core Location `When In Use`, reduced accuracy), yerel güvenle `cityID`, `country`, `locale`, `timezone` çıkarılır. Ev adresi ve hassas koordinat sunucuya gitmez; hava sorgusu için sadece şehir merkezi / kaba bölge kullanılabilir ve izinle.
3. Şehir kimliği → doğrulanmış `CitySceneManifest` seçilir. En yakın ikonik yerin kullanıcıya fiziksel yakınlığı iddia edilmez. `Şehrinden ilham alan sahne` ifadesi gerektiğinde görünür. Kişi farklı şehirdeyse yeni şehir, eski şehrin sahnesiyle karıştırılmaz.
4. Varsa lisanslı doğrulanmış yerel landmark sahnesi yüklenir; yoksa OSM verileri ve bölgesel mimari kurallarıyla **özgün sokak grameri** üretilir; özgünlüğü doğrulanmamış sahte anıt asla şehrin gerçeği diye etiketlenmez.
5. Hava (açık izin + WeatherKit) → gökyüzü, ışık, zemin ve dış giyim kararını etkiler. Model ve kıyafetler önceden önbelleklenmiş, tek düğmede görünür.
6. Kullanıcı herhangi şehri seçmeye zorlanmaz; konum izni reddedilirse `Şehrini belirle` isteğe bağlı, şehir bilinmiyorsa nötr atölye sahnesi.

### C2. Yanlış çözüm / doğru çözüm

**Yanlış:** 81 ilin ve bütün dünya şehirlerinin fotoğraflarını internette arayıp telefonda gerçek zamanlı 3D'ye dönüştürmek; Google Street View ekran görüntüsünü lisanssız kaplamak; her açılışta ağır üretken video üretmek; herkese İstanbul/Barcelona göstermek.

**Doğru (üç kademeli):**
- **City Tier A – Curated Landmark:** doğrulanmış yer adı, yetkili foto referansı, lisanslı/orijinal mesh, foto-real PBR, insan ölçeği, etiket ve kaynak izi. Şehirler öncelik sırasına göre eklenir.
- **City Tier B – Procedural Street:** OSM sokak/bina ayak izleri → `OSM2World` glTF/OBJ → Blender'da orijinal cephe, aydınlatma, kaldırım, tabela, bitki, doku üretimi → optimize USDZ → RealityKit. Şehirden ilham alan ancak belirli gerçek sokak olduğu iddia edilmeyen sahne.
- **City Tier C – Atelier Neutral:** mahrem, offline, düşük RAM veya şehir verisi yokken kullanıcının modelini sade sanat galerisi sahnesinde sun.

**Bilinirlik/landmark seçimi:** tek LLM tahminine güvenme. `CityFactAgent` kaynaklı adaylar çıkarır; `GeoValidator` ülke/şehir eşleşmesini ve lisansını doğrular; `ArtDirector` fotoğraf referansı/mimari uygunluk denetler; `SceneQA` görsel kalite, atıf, yanlış konum ve mobil performansı test eder. `fame score` reklam/sponsor değildir. Şehir merkezi ile asıl coğrafi koordinat kullanıcıya önerilmez.

### C3. 3D veri / teknoloji

- **Konum:** Core Location ve Apple geocoding/MapKit (açık izin, coarse city); şehri belirlemek için kullanıcının ev koordinatını saklama.
- **Kentsel geometri:** OpenStreetMap ODbL → `https://github.com/tordanik/OSM2World` (kaynak repo lisansını ayrıca kontrol et) → Blender sahne işleme. OSM topluluk tile sunucuları ticari CDN değildir; kendi işleme/cache altyapısı gerekir.
- **Blender:** orijinal sokak kitleri, landmark kalite revizyonu, yerel mimari varyantları, PBR, LOD/occlusion, atlas texture, çarpışma/hava zemini. Blender proje araçtır, telefonda Blender çalıştırılmaz.
- **Runtime:** RealityKit + Metal + SwiftUI. City asset manifest: `cityID, tileBBoxGeneralized, sceneTier, geoEvidence, license, attribution, assetVersion, lightingRig, weatherVariants, maxGpuBudget, age, locale, checksum`.
- **İlave aday:** `https://github.com/p-schulz/osm_importer` Blender OSM importer; yeni ve karmaşık repo → izolasyon ve güvenlik/lisans incelemesi olmadan kurma. Google 3D Tiles'ı lisans ve performans doğrulanmadan “bedava ve indirilebilir Blender asseti” sayma.
- **Örnek pilot veri seti:** Yozgat (şehir merkezi + uygun yöresel sokak kiti), Gaziantep (kent dokusu + doğrulanmış yerel sahne), New York (bir caddeden ilham alan kent sahnesi); sadece üç şehre kilitlenme. 5 farklı iklim/ışık koşulu, 2 cihaz sınıfı ve 2 performans tier testleri.

### C4. Meteoroloji davranışı

`sunny`: güneş açısı, sıcak gün ışığı, doğal gölge. `cloudy`: dağınık ışık, düşük kontrast. `rain`: görülebilir damlalar + yüzeye temas halkası ve kontrollü ıslak zemin (tüm mekânı yapay parlak yapma). `snow`: kar parçaları + tutunma yalnız uygun yüzey, geçiş animasyonu. `wind`: kıyafetin rüzgârla uyumlu küçük hareketi + bitki/yaprak, rüzgâr şiddetine göre. `night`: gerçek zamanlı ışık. Ses/haptik rızalı ve ayrı. **Tüm efektlerde Reduce Motion, Battery/Thermal downgrade ve erişilebilir hava açıklaması.** Hava bilgisi yoksa sahte yağmur/sıcaklık yok; günün saatine bağlı sade sahne.

## D. Kendi yüzü/saçı olan kişisel 3D dijital ikiz

1. Kullanıcı `Kendime benzeyen model oluştur` eylemiyle cihaz kamerasında selfie ve istenirse farklı açılardan yüz profili alır; yüz/geometri, fotoğraf EXIF, kişisel ölçüler **yalnız yerel şifreli kasada** kalır. Kullanıcıya önce açık ne işleneceği anlatılır. Başkasının yüzünü fotoğraf arşivinden otomatik seçip “sen” diye etiketleme.
2. Sonraki isteğe bağlı fotoğraf izni: sadece seçilen fotoğraflar (PhotosPicker/limited PhotoKit); **son fotoğraf = kesin kullanıcı** değildir. Kimlik için kullanıcı onayı zorunludur. Galerinin tamamına izinsiz erişme veya kalıcı takip yok.
3. Yüz rig'i ve morphable face mesh; ARKit `ARFaceTrackingConfiguration` destekli cihazda yüzü/ifadeyi takip etmekte yardımcı olabilir, ancak ARKit yüz anchor'ı **foto-gerçek kimlik rekonstrüksiyonu sağlamaz**. Selfie/farklı açılar, saç şekli/renk profili, yüz dokusu kalite değerlendirmesi, saç geometry, kişinin `Bu bana benziyor` onayı gereklidir.
4. Vücut tahmini: boy/kilo yalnız kaba sinyal. Göğüs, bel, kalça, inseam, omuz, kol, postür ayrı ölçüm veya güven aralığı. Kullanıcıya tek bir yerde kolay düzeltme; yanlış hesapları kesin beden önerisine aktarma.
5. Kişisel avatar `AvatarRevisionID`, `FaceRevision`, `HairRevision`, `BodyRevision` ile versiyonlanır. Beden değişince önizleme ve fit hesapları invalidate olur; yüz/sac değişince giysi beden ölçüleri bozulmaz.
6. Kullanıcı izin vermezse güzel nötr 3D model; özellik kapanmamalı. Biyometri verisinden kimlik doğrulama, sağlık çıkarımı, gizli profilleme yapma.

### D1. Görsel kalite kapısı

İnsan yüzündeki göz, ağız, saç çizgisi, cilt tonu, yansıma, gölge, yüzey detayları; çoklu açı tutarlılığı; doğal el ve ayaklar; giysi ile saç/çanta örtülmesi. 360° döndürmede arkada “boş yüz” / saç parçalanması yok. Hem telefon ışığında hem şehir sahnesinde kontrol.

## E. Ürün fotoğrafı / barkod / web / kişisel fotoğraf → 3D giysi

`[Barkod/QR] [Mağaza fotoğrafı] [Web ürün linki] [Ekran görüntüsü] [Kendi dolabından]` aynı `Dene` akışına girer.

**Kimlik:** GTIN kontrol rakamı ve simge türü; marka SKU; model+renk+beden+sezon; lisanslı kaynak, katalog revizyonu, emin olunmayan varyantta kullanıcı seçimi. GS1 genel kimlikte yardımcı, kalıp ve kumaş verisi değildir.

**Fotoğraf:** yerel segmentasyon/nesne bulma → kategori/renk/desen/logo *adayları* → OCR etiketteki marka/SKU → partner kataloğu embedding/vektör arama (yalnız izinli medya) → çift kanıtla varyant → `exact verified` / `candidate` / `not found`. Logo fotoğraftan tanınamıyorsa uydurma.

**Kumaş:** `Fotoğrafta yün gibi` ≠ `%80 yün`. Gerçek lif oranı care label/OCR kullanıcı onayı veya lisanslı feed. Kumaş gramajı, süneklik, weave/knit, drop, stretch direction, kalıp, bitmiş parça enleri, dikiş, cep ve logo konumu ayrı kaynaklı veri.

**Gerçek 3D:** 1) marka CAD/techpack/GLB/USDZ, 2) patternmaker'ın doğruladığı template+finished measurements, 3) açıkça `tahmini` işaretli primitive garment drape. **Tek fotoğraftan ürünün arka dikişi ve gerçek esnekliği kesin çıkmaz.** Temsili mesh'i asla “gerçek 3D ürün” diye etiketleme.

**Kişisel dolap:** on-device Vision/CoreML → aynı kıyafetin farklı fotoğraflarını eşleştir → kullanıcıya review kuyruğu → doğrulayıp dolaba ekle → eşleşmiş ürün varsa asset çek → yoksa 3D yaklaşık asset üret/şablonla. Tam galeri istemi yalnız anlamlı fayda ve açık seçimle; her fotoğraf kullanıcıya ayrı ayrı gösterilmez, ama kitle karar ekranı kullanıcı kontrolünde.

## F. Kendi Live Mirror motorumuz: Gerçek fiziksel sınırlamalar

- **F1 Local tracked 3D mirror (ilk ticari aday):** AVFoundation görüntüsü + Vision body/hand/segmentation + isteğe göre ARKit tracking + Metal/RealityKit kıyafet mesh + depth/occlusion + garment fitting. Giyili kıyafetin üzerinden **görsel overlay/occlusion** gösterilebilir; bedende kıyafetin altındaki doğru şekli kameradan okumak mümkün değildir.
- **F2 Generative still try-on (kendi modelimiz):** `https://github.com/fashn-AI/fashn-vton-1.5` — Apache-2.0 ana model, ancak üçüncü taraf parser NVIDIA lisansı ayrıca incelenmeli. ~2GB ağırlık / ~8 GB VRAM ve ~5s H100 görüntü başına raporlanıyor; iPhone'da akıcı 30 FPS olduğunu **göstermiyor**. Ürün koduna entegre edilmeden önce kontrollü ayrı PoC, lisans, kaynak, GPU ve kalite kapısı.
- **F3 Owned temporal VTON (Ar-Ge):** kendi izinli video eğitim veri seti, kimlik/ürün koruma, temporal stability, gerçek beden deformasyonları, occlusion, pose, quality failures, model quantization/distillation only where legal. El hareketleri, dönme ve ağır dış giyim için gerçek kullanıcıyla karşılaştırmalı benchmark; *cihaz üzerinde canlı fotogerçekçilik henüz kanıtlanmamıştır*.
- **F4 Decart Lucy VTON / dış API (koşullu):** sadece kullanıcı açık izni, ticari veri şartları, saklama/silme, alt yükleniciler, sözleşme, kota ve maliyet onayı sonrası; varsayılan kapalı; iOS'a kalıcı API anahtarı gömülmez. Alternatif pilot kıyaslamasıdır, hedef bağımsızlık.

**Yasak:** Başkasının özel sunucu modelini, DRM/erişim kontrollerini veya sözleşmesel tersine mühendislik yasağını ihlal ederek kopyalama. Açık kaynak kodu lisansına uygun okuyup optimize etmek, baştan model yazmak ve kendi izinli verisiyle eğitmek teşvik edilir. **`https://github.com/tmllab/2026_CVPR_Mobile-VTON` ve `https://github.com/Zheng-Chong/CatVTON`: CC BY-NC-SA 4.0; ticari Kabinsiz'e gömme yok, özel lisans gerekir.**

### F1 ile F3'ün bilinçli farkı

Kişiye kamera videosunda “çok gerçek gibi” bir değişim sunmak başka, `gerçek bedenin aynı düşeceği`ni kanıtlamak başkadır. Kullanıcının ekranda gerçekten kendisini görmesi için F1 bile yeterince faydalı olabilir; mükemmel drape için marka bilgisi + fiziksel test laboratuvarı gerekir.

## G. Marka entegrasyonu ve maliyet: Her API ücretsiz değildir

| Kaynak | Ürün bağlantısı | Ücret / izin gerçekliği | Karar |
|---|---|---|---|
| Marka PIM/ERP, CSV/XML/JSON/SFTP/webhook | Partnerin sağladığı GTIN, SKU, varyant, beden, kumaş, görsel, 3D | Partner anlaşması, veri ve marka hakları, altyapı bedeli | **Asıl hedef**; marka bağımsız ortak format |
| Shopify Storefront API | İzinli mağazanın ürünleri, varyant | Bazı tokenless erişim var; özellikler/token/rate-limit bağlı; her mağazanın iç kataloğunu izinsiz çekme hakkı yok | Shopify partner connector |
| WooCommerce REST API | Anlaşmalı mağazanın ürünleri ve varyant | API anahtarları mağaza sahibi tarafından verilir; ücretsiz platform desteği ≠ bedelsiz anlaşma | Read-only connector |
| GS1 Verified by GS1 | GTIN/firma/temel kimlik | Web'de 30 ücretsiz kontrol/gün; ölçekli API için üyelik/koşullar; **beden/kalıp kataloğu değil** | Yardımcı identity verification |
| OpenStreetMap veri | Bina/sokak/POI | Veri ücretsiz ODbL; attribution/derived DB şartları ve altyapı maliyeti; kamu tile sunucusu ticari ücretsiz CDN değil | Şehir dünyası kaynakları |
| Apple Core Location / Vision / ARKit / RealityKit | Konum, kamera, izleme, sahne | Platform API'si, cihaz/Apple Developer koşulları; izin gerekli | iOS runtime |
| Apple WeatherKit | Tahmin | Developer Program kapsamında aylık 500.000 çağrı; fazlası ücretli | Yerel hava ve sahne |
| Blender | offline 3D modelleme | Açık kaynak; eklenti ve asset lisansı ayrı | Authoring |
| FASHN VTON v1.5 | 2D person+garment output | Apache-2.0 model; GPU maliyeti ve NVIDIA parser bağımlılığı incelemesi gerekir | R&D PoC |
| Higgsfield | yaratıcı referans video / reklam | Ayrı, ön ödemeli ücretli API; **canlı iPhone VTON veya bedene uygunluk motoru değil** | Moodboard/kampanya, kişi verisiz |
| Google foto/Street View/3D Tiles | harita/görüntü | API/attribution/lisans/kota; indirip varlık olarak yeniden dağıtım hakkı varsayma | Gerekmedikçe seçme |
| Decart | bulut gerçek zamanlı VTON | saniye başı fiyat, sözleşme ve hassas veri yükümlülükleri | Yalnız koşullu sandbox |

**İlk sözleşme eki:** ürün-veri alanları, kimlik doğruluğu taahhüdü, foto/3D/derivative hakları, cache süresi, cihazda saklama, embedding/ML kullanma hakları, GTIN/SKU revizyon webhook'u, kalite hatası geri çekme, işleme/silme, ticari kullanım, iletişim ve servis seviyesi. Bir mağazanın katalog verisi ücretli olmayabilir, fakat bedava olduğu anlaşma olmadan kesin söylenemez. Zara veya başka büyük marka için herkese açık, sözleşmesiz bütün katalog API'si varmış gibi davranma.

## H. Ahtapot: geliştirici ajanları ≠ telefondaki çalışan modüller

### H1. Runtime uzmanlar (hepsi ayrı LLM değil)

`LOC` şehir/izin → `GEO` fact+POI → `CITY` scene asset selection → `WTH` WeatherKit/rain/lighting → `STYLE` daily outfit candidates → `FACE` identity-approved avatar → `BODY` measurements → `WRD` local clothing recognizer → `DUP` dedup → `OCR` label/GTIN → `SKU` partner identity graph → `FAB` fabric evidence → `PAT` garment template/finished dimensions → `GAR` 3D asset → `DRESS` rig+collision → `POSE` local camera tracking → `VTON` selected mirror backend → `QA` frame/identity/artifacts → `SEC` CITADEL/Vault → `GOV` thermal/battery resource → `ORC` current OctopusCoordinator final decision. Bu görevler typed contract, `EvidenceRecord`, izin, revision, timeout, fail-closed kullanır. Gereksiz 21 ayrı büyük model yüklenmez.

### H2. Geliştirici uzmanlar

`city-technical-artist`, `geodata-license-auditor`, `weather-reality-engineer`, `avatar-face-hair-engineer`, `garment-cad-material-engineer`, `realtime-vton-researcher`, `ondevice-ml-optimizer`, `retail-partner-integration-engineer`, `ux-minimalism-guardian`, `privacy-security-gate-reviewer`. Bu belgede bunların **Claude agent MD şablonları** bulunmaktadır. Teknik değerlendirme çelişirse güvenlik, ürün doğruluğu ve UX quality gate kazanır.

### H3. MCP / skills ve bağlam

MCP'ler **yalnız Claude geliştirme araçlarıdır**, iPhone runtime değildir. Repo `.claude/skills` içinde halihazırda SwiftUI, concurrency, protocol DI, security ve motion skill'leri var; bunları tekrar kopyalama. Yeni ekler paketle gelir:

- `MobileBuildMCP` — https://github.com/getsentry/MobileBuildMCP: Xcode build/test/sim screenshot, cihaz benchmark; ad 2026'da XcodeBuildMCP'den değişti.
- `Figma MCP` — https://developers.figma.com/docs/figma-mcp-server/ — resmî Figma'da editable frame/token, doğru oturum ve izinle. Entegrasyon kurulmadı.
- `Blender MCP` — https://github.com/ahujasid/blender-mcp — 3D sahne/modelleme; **güvenlik:** `BLENDER_MCP_SAFE_MODE=1`, telemetry kapalı, localhost, sadece iş dosyaları. Keyfi Python çalıştırabilir, üretim repo root'a sınırsız yazma izni yok.
- `GitHub connector` — mevcut repo geçmişi/PR karşılaştırma; sonuçları kanıtla.
- `OSM2World` / Blender importer — CLI/Pipeline, MCP olmak zorunda değil. `Core ML Tools` — model dönüştürme/golden karşılaştırma; GUI MCP olması gerekmez.
- `Decart docs MCP` — yalnız API dokümantasyonu / ayrı sözleşme+flag; asla otomatik gerçek video transferi.
- `Higgsfield` — tasarım/moodboard referansı; canlı kişisel kamera modeli değildir.

### H4. Entegrasyon ilkesi

`OctopusCoordinator` ikinci kez yazılmayacak; typed `ContextSnapshot → TaskGraph → Evidence → DecisionEnvelope`. Bir uzman diğerinin güvenini yükseltemez. `CLAIM:Verified` yalnız imzalı kaynak+geçerli lisans. `AvatarRevision` ve `ProductRevision` değişirse VTON preview/fit cache otomatik silinmeli. Cihaz ısındığında yeni sahne yükünü azalt, önce düşük LOD/2D silhouette ama kullanıcıya gizleme. VTON kamerada arkaplanda otomatik başlamaz.

## I. UI/UX — Steve Jobs × Steve Wozniak

- **Bugün:** full-screen şehir+doğal hava+giyinmiş avatar; sade `Kabinsiz`, şehir/hava minik kapsülü, **Yeni Kombin** ve alt 3 sekme. Üst/alt/kemer/çanta/kategori buton duvarı yok. **Avatar üstüne dokun → o giysinin 3–5 alternatifini gösteren küçük alt sheet; sürükle → 360° döndür.**
- **Dolabım:** iki sütun giyim varlıkları; arama/filtre; tek `+` ile Fotoğraflardan Tanı / Foto Çek / Barkod / Web / Elle. Onaylanmamış ürüne gerçeğe yakın logo uydurma.
- **Dene:** tek ana yol: kamera barkod/etiket/foto → doğru ürün kartı → `Üzerimde gör` → canlı/3D seçim, teknik mod alt düzey. Yanlış kaynak -> `Bu ürün bulunamadı` net mesaj.
- **Ben:** yüz/saç/beden düzenleme, stil tercihleri, tüm veri lokal/kontrol/silme; birincil hero değil.
- **Seyahat:** özellik sayfası, alt sekme değil. Şehir değişince otomatik sahne değişir; seyahat planı ayrı isteğe bağlı.
- **Görsel DNA:** altın bakır logonun doğal tonları, fildişi #F8F6F1, espresso #26221E, ceviz #654632, zeytin #62684B; `AtelierTokens.swift` tek kaynak; system New York serif yalnız kısa editoryal başlık, SF Pro gövde/UI. Asset/motion her ekranda aynı. AA-kontrast ve erişilebilirlik zorunlu. Apple'ın standart sistem yazılarını rastgele değiştirme; tek font seti konumunda sözleşmeye bağlı kal.
- **Açılış:** Apple launch screen mümkün olduğunca anında gerçek ilk kareyle uyumlu. Logo kısa transition (ölçülü ~0.25–0.55 sn *hedef, ölçümlere göre*), ilk hazır avatar/scene poster hemen görünür, ağır mesh arka hazırlanır; shader/asset compile ilk kareyi bloklamaz. Uzun zorunlu splash yok. `Reduce Motion`da logo kayması kapalı.

## J. Uygulama sırası / gerçek kalite kapıları

**WP35-00 — Reality Lock.** `git status`, `main` ve yerel branch; kullanıcı simülatör görüntüleriyle kıyas. `docs/audit/V35_REALITY_LOCK.md` çıkar. P0 kırıkları. Yeni dependency kurma.

**WP35-01 — City ID & consent.** Coarse location, time zone, city ID and NO permission / travel/ wrong-city paths. Real-device tests; no house coordinate storage.

**WP35-02 — City scene bench.** OSM import, legal+attribution, 3 şehir kalite demosu (Yozgat/Gaziantep/NewYork), Tier A/B/C fallback. CLI pipeline deterministic ve checksum, mobile asset budget.

**WP35-03 — Weather living stage.** sunny/rain/wind/snow/night, real weather, loading/fallback, reduced motion; scene weather != garment thermal comfort.

**WP35-04 — True 3D avatar.** User photo/selfie opt-in, hair mesh, facial identity user-confirmed, multi-view, no cloud; 360 test. Not neutral mannequin.

**WP35-05 — Real garments.** One authorized pattern/measurement/fabric asset set, licensed source, cloth/body validation and blind real fitting.

**WP35-06 — Scan canonical.** Real camera, GTIN/SKU/vision candidate, partner catalog validation, exact variant; no false confidence; offline cached result. Performance p95 with proven sample size.

**WP35-07 — Personal photo wardrobe.** opt-in, gallery selective, local segmentation/dedup/confirm, real garment asset lookup; no data exfiltration.

**WP35-08 — Local Mirror.** camera open on intent, clothing pose/occlusion, 3D overlay, stop on app background, disable recording by default, low thermal fallback, physical iPhone video evidence.

**WP35-09 — FASHN VTON isolated.** Commercial license/third party parser review → standalone static image PoC, benchmark (5s H100 baseline) vs target iPhone/memory; no direct live promise.

**WP35-10 — Owned temporal VTON research.** consented diverse video benchmark, identity+texture+logo+motion metrics, model architecture/budget; only if tangible advantage vs local 3D and business case, plus license/data rights.

**WP35-11 — Partner Portal.** first commercial partner real feed `GTIN+SKU+color+size+measurements+composition+media rights`; signed deltas, revocation, SKU collision, null fields, tests.

**WP35-12 — Design Gate.** Figma frame and real SwiftUI screenshot side by side; no card clutter; focus/gesture, dynamic type, smallest supported iPhone, dark+contrast, VoiceOver. Real device visual audit.

**WP35-13 — Release proof.** no false claims: `CODED / SIMULATOR_TESTED / DEVICE_VERIFIED / USER_VALIDATED / PARTNER_VERIFIED`. Independent UX, security, legal and textile patternmaker signoff. All P0 fixed or explicit BLOCKED.

**SLO goals are targets until measured:** warmed known SKU local p95 ≤1s; remote real partner identity p95 ≤3s; cached wardrobe item to preview p95 ≤1.5s; first responsive home poster p95 ≤1s; full interactive 3D scene p95 ≤3s on defined target phones; Local Mirror target sustained ≥24 FPS after thermal stabilization. Exact thresholds are hypotheses; Claude must measure device, network, battery, thermal and failure cases. Slow or uncertain results degrade transparently, not fabricate.

## K. Kabul senaryoları (kritik)

1. Yozgat city ID + verified cultural scene; incorrect country match blocked.
2. Gaziantep city ID + rainy day; raindrop/ground/wetness coherent; no motion under Reduce Motion.
3. New York user, automatic city scene; offline last known asset & stale-weather disclaimer.
4. Location denied: neutral studio, no background GPS, no wrong city label.
5. Face scan with user selection: identity not assigned from random photo; no face bytes in network log.
6. 360 yaw front/side/back in two lighting conditions; hair and garment survive turn.
7. SKU exact matched vs visually similar but different color and length; false exact match must fail.
8. OCR correct composition vs uncertain composition label; no inferred percentages.
9. Photos permission limited, revoked midscan, duplicates, 100+ images, thermal pressure, interrupted app; no data loss.
10. Mirror with previously worn bulky coat while new slim jacket selected: no false `fiziksel fit kesin`; occlusion error note if needed.
11. Mirror motion temporal stability: turn/raise arms/occlude bag/poor light, frame staleness and timeouts; privacy stop.
12. Vendor deletes media rights: local cache/3D asset purge, stale preview invalidated, no sponsored override.
13. FASHN dependency parser license unsatisfied => disabled/research only.
14. OSM license attribution present; fake landmark claims rejected; scene works on older supported device.
15. Figma reference and production SwiftUI layout comparison shows no model occlusion by buttons.
16. App opens while 3D unavailable: first frame fluid, no freezing, loading state honest.

## L. CLAUDE teslim sözleşmesi

Her WP için `SOURCE_FILE:LINE` veya commit, ADR, test command/exit code, physical device model iOS version, screenshot/movie, FPS/memory, benchmark data, security/license, known limitations, status and next dependency. Önce bir uçtan uca **gerçek 3D sahne + avatar + giysi swap**; ikinci **gerçek GTIN → exact variant → giydir**; üçüncü **local mirror**. Sonra genişleyen şehir kapsama ve owned generative research. **Daha fazla 100 ajan açmak değil; veri ve kanıt zincirini çalıştırmak** hedef.

## M. Kaynak kayıtları (Claude her güncellediğinde tekrar doğrular)

- Apple Core Location: https://developer.apple.com/documentation/corelocation/requesting-authorization-to-use-location-services
- Apple WeatherKit: https://developer.apple.com/weatherkit/
- Apple VisionKit barcode: https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera
- Apple ARKit faces: https://developer.apple.com/documentation/arkit/arfacetrackingconfiguration/
- Apple Photos limited access: https://developer.apple.com/documentation/PhotoKit/delivering-an-enhanced-privacy-experience-in-your-photos-app
- Apple launching: https://developer.apple.com/design/human-interface-guidelines/launching
- OSM license: https://www.openstreetmap.org/copyright and https://osmfoundation.org/wiki/Licence_and_Legal_FAQ
- OSM2World: https://github.com/tordanik/OSM2World
- Blender OSM import: https://github.com/p-schulz/osm_importer
- GS1 free lookup: https://support.gs1.org/support/solutions/articles/43000734112-who-is-using-verified-by-gs1-is-verified-by-gs1-used-by-marketplaces-
- Shopify Storefront API: https://shopify.dev/docs/api/storefront/latest
- WooCommerce REST API: https://woocommerce.com/document/woocommerce-rest-api/
- FASHN VTON: https://github.com/fashn-AI/fashn-vton-1.5 ; parser: https://github.com/fashn-AI/fashn-human-parser
- Mobile-VTON: https://github.com/tmllab/2026_CVPR_Mobile-VTON (NC); CatVTON: https://github.com/Zheng-Chong/CatVTON (NC)
- Higgsfield API: https://higgsfield.ai/creator-hub/help-center/integrations/what-is-the-higgsfield-api
- Figma MCP: https://developers.figma.com/docs/figma-mcp-server/
- MobileBuildMCP: https://github.com/getsentry/MobileBuildMCP
- Blender MCP: https://github.com/ahujasid/blender-mcp
- Decart Swift SDK: https://github.com/DecartAI/decart-ios

**DURUM:** Bu metin gerçek bir iPhone demo, lisans imzası, marka feed sözleşmesi veya live API entegrasyonunun kendisi değildir. Kod, insan hakları, veri, güvenlik ve performans doğrulaması gereklidir.

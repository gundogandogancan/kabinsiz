# KABİNSİZ — GOD LEVEL v2.1
## LIVE MIRROR / GERÇEK ZAMANLI AKILLI AYNA / LIVE VIDEO VIRTUAL TRY-ON
### Claude Code için doğrulanabilir ürün, mühendislik, güvenlik, ekonomi ve uygulama anayasası

**Tarih:** 3 Kasım 2026  
**Kapsam:** Önceki v2.0 ana şartnameye eklenir; güvenlik ve cihaz-içi veri önceliği değişmez.  
**Repo:** https://github.com/gundogandogancan/kabinsiz  
**İncelenen `main` commit:** `25897e7de3bf5ab3ae2f54f8b6edf4228f81f0fa` (kontrol anında; her uygulama oturumunda yeniden kontrol edilmeli).  
**Kaynak Instagram Reels:** https://www.instagram.com/reel/DfMi-cDsECb/ — **DOĞRUDAN OYNATILAMADI**; bağlantı erişimi engelledi. Videodaki ürünü/modeli, hareket kalitesini, gecikmeyi, gerçek kaynak kodunu veya ticari lisansı **tespit edilmiş sayma**. Kullanıcı videoyu dosya olarak sağlarsa yeniden incele.  
**Doğrulanmış teknik aday:** Decart **Lucy Virtual Try-On 3.6**, resmî Anywear uygulaması, Decart iOS SDK / LiveKit/WebRTC. Bu adayın davranışı tarif edilen deneyimle örtüşür, fakat Instagram videosunun aynısı olduğu kanıtlanmamıştır.

> **KURULUŞ EMRİ:** KABİNSİZ'in birinci sınıf kullanıcı yüzeyi **Canlı Ayna**dır: kullanıcı ön kameraya bakar, seçtiği ürünü veya kombini üzerinde hareketli görür. Her kıyafet hareket sırasında takip edilir; ürünün kaynak görüntüsü ve marka/kumaş/beden kanıtları birbirinden ayrılır. Prototipin “güzel görünüyor” diye tamam sayılmasına izin yoktur. Canlı görünümün gerçek beden doğruluğu iddiasını desteklemediğini daima açık tut.

---

## LM21-00 — DÜRÜSTLÜK VE ÖNCELİK

1. `CODED`, `TESTED_SIMULATOR`, `DEVICE_VERIFIED`, `USER_VALIDATED`, `PARTNER_VERIFIED`, `BLOCKED_EXTERNAL`, `UNKNOWN` farklı durumlar. Hiçbir ekran demo veriyle “gerçek mağaza doğrulandı” yazamaz.
2. Müşterinin telefonundaki vücut profili, beden ölçüleri, özel fotoğrafları ve giyim geçmişi **varsayılan olarak cihazda kalır**. Bulut AI aynası **yalnız ayrı, açık ve bilgilendirilmiş kullanıcı rızasıyla**, açıkça etiketlenen mod olarak sunulur; sağlayıcıya kamera videosu gitmeden hiçbir uzaktan oturum başlamaz.
3. Kişiye özel ölçüler, kayıtlı avatar mesh, fotoğraf arşivi ve dolap geçmişi canlı video sağlayıcısına **asla otomatik gönderilmez**. Yalnız kullanıcının seçtiği ürün görseli + açıkça onaylanan geçici kamera akışı gidebilir; yüzün/boyun/bedenin video içinde bulunacağını arayüz açıklar.
4. Generatif video **kumaş fiziği/ölçü için bilimsel kanıt değildir**. Omuz, bel, kalça, kol ve uzunluk kararları bağımsız `PrecisionFitEngine` ve doğrulanmış ürün ölçüleriyle hesaplanır. Bu iki kanalın çelişmesi ürünün kullanıcıya uyarılması gereken bir durumdur.
5. Lisanssız model/ağırlık/veri/scraping yok. Ticari ürün üretiminde sözleşme, fiyat, saklama, güvenlik, bölgesel veri aktarımı ve üçüncü taraf işleyici doğrulanmadan cloud modu `BLOCKED_EXTERNAL`.
6. Kullanıcı 18 yaş altındaysa veya yaş bilinmiyorsa uzaktan canlı video provası için ürüne özgü çocuk güvenliği ve yasal uygunluk incelemesi olmadan açma; yerel moda önerileri kısıtlı ve güvenli kalabilir.
7. **Zorunlu çalışma:** repo SHA, son testler, dosya listesi, gerçek cihaz, API erişimi, maliyet ve kaynak hakları tekrar doğrulanmadan yeni özellik TESTED/AVAILABLE sayılmaz.

## LM21-01 — RAKİP VE TEKNOLOJİ GERÇEKLİĞİ

### Doğrudan doğrulanan ürün

- **Decart Anywear:** `https://anywear.decart.ai/live-virtual-try-on`. Ürün, canlı kameraya seçilen kıyafeti frame-by-frame generatif video olarak aktardığını ve hareket takibi yaptığını açıklıyor. Pazarlama sitesindeki ~1,5 saniye ilk görünüm iddiası **Kabinsiz cihaz ölçümü değildir**.
- **Model:** `lucy-vton-3.6` (Decart platformunda görülen güncel VTON 3.6); `lucy-vton-3.5` eski karşılaştırma adayı. Belgeler: `https://platform.decart.ai/models/lucy-vton`, `https://docs.platform.decart.ai/getting-started/pricing`.
- **Üretim API:** Decart canlı WebRTC akışı + prompt/giyim referans görseli; 720p nominal. Swift SDK: `https://github.com/DecartAI/decart-ios`, `https://docs.platform.decart.ai/sdks/swift-realtime`. SDK `RealtimeModel.lucyVton3_6`, `RealtimeManager`, `RealtimeMediaStream`, `LocalVideoTrack`, `remoteStreamUpdates`, `connectionQualityUpdates` içerdiğini belgeliyor. Sürümü, son parametreleri, VTON image reference desteğini ve build uyumluluğunu **kurulumda gerçek derlemeyle doğrula**; bazı genel SDK dokümanı satırları farklı model nesillerini örnekliyor.
- **Benzer isimlere dikkat:** `anywear.pro` **bağımsız EchoSub AI, LLC** hizmetidir; Decart'ın resmî Anywear'iyle karıştırma. `anywear.live` de ayrı hizmet olarak araştırılmalı. Kaynak uygulama ve model kimliği marka ismiyle varsayılmamalıdır.
- **Fiyatın resmi temeli** (3 Kasım 2026 bakılan sayfa): realtime VTON 720p standart **$0.02/üretim saniyesi**, fast **$0.04/saniye**, batch **$0.04/üretim saniyesi**; faturalama aktif üretim süresi içindir. Kampanya, kur, vergi, ağ ve ödeme masrafları hariç. Yetkili hesapta tekrar doğrula.
- **30 saniyelik canlı oturum maliyeti** kabaca $0.60 normal / $1.20 fast; 60 saniye $1.20 / $2.40; 5 dakika $6 / $12. Bu yüzden sürekli ücretsiz sınırsız bulut mod ticari olarak sürdürülebilir kabul edilemez.
- **Model lisansı ile SDK lisansını karıştırma:** SDK MIT gibi açık kaynak lisansına sahip olsa bile sunucu modelini ücretsiz/cihazda çalıştırma hakkı vermez; sağlayıcı API şartları ve DPA ayrıca gerekir.

### Önemli fiziksel ayrım

- **A: Kamera AR/yerel 3D giysi:** Kullanıcının takip edilen iskeletine hazırlanmış mesh oturtulur. Telefon kendi GPU'sunda görüntüler; veri dışarı çıkmaz, düşük gecikme mümkündür. Doku, logo ve oklüzyon kalitesi giysi varlıklarının ve takip kalitesinin sınırındadır.
- **B: Generatif canlı video (Lucy V-TON benzeri):** Referans kıyafet + kamera videosundan sunucu AI işlenmiş yeni kareler üretir. Sonuç daha fotogerçekçi görünebilir fakat kıyafetin kesimini, logosunu, vücut biçimini, yüzü ve arka planı değiştirebilir. İşlem **cihaz içinde değildir**; internet/latency/oturum maliyeti vardır.
- **C: Beden bilimi:** Gerçek ürün bitmiş ölçüleri + kişinin elle doğruladığı ölçüler + kalıp toleransı + fit geçmişi. A ve B'deki estetiğin “kesin beden uygunluğu” iddiası üretmesini engeller.

**Kabinsiz kararı: iki mod + tek doğruluk motoru.** `Local Live Mirror` ücretsiz/çevrimdışı/cihaz içinde. `AI Live Mirror (Bulut)` açık izinle ve fiyat/bilgi gösterilerek açılabilecek, doğrulama kapılarından geçen ek mod. `PrecisionFitEngine` her ikisinden bağımsız ortak sonuç verir. Tek veri yolu, tek izin düğmesi veya otomatik mod yükseltme YOK.

## LM21-02 — ÜRÜNÜN GERÇEK KULLANICI AKIŞI

### 1. Mağazada ürünü seç

1. Kullanıcı `Tara` ile EAN/GTIN, QR, etikette model kodu, renk/beden veya ürün fotoğrafı kullanır.
2. `ProductIdentityEngine` ürün kimliğini kanıt seviyesine göre döndürür: `EXACT_VARIANT / MODEL_ONLY / CANDIDATE_SET / UNKNOWN`.
3. `ProductEvidenceResolver` ürüne izinli kaynaktan kumaş içeriği, bitmiş ölçüler, beden tablosu, kalıp, görseller, renk, logo ve yıkama etiketini bağlar. Eksik alanları uydurmaz.
4. Kullanıcı **“Üzerimde canlı gör”** butonunu açar. Varsa daha önce seçtiği kombini de kullanabilir.

### 2. Akıllı ayna açılır

1. `LOCAL` varsayılan; kamera izni istenir, ön kamera açılır, telefonun ekranında canlı ayna gösterilir.
2. Kullanıcı 2–3 adımlık pozlama yönergesi görür: kameraya yeterli uzaklık, tam gövde gerekliyse kadraja gir, ışık yetersizse bunu söyle; otomatik görüntü kaydı yok.
3. Yerel 3D ürün varlığı varsa kıyafet takibi; yoksa **“2D ürün referansı / 3D hazır değil”** görünür. Ayna arayüzü boş kalmaz. Yerel alternatif desteklenmiyorsa “gerçek kamera, ürün bilgisi ve ölçü” seçeneği.
4. Kullanıcı ürün rengini/bedenini değiştirir, 90° döner, kollarını kaldırır, geriye bir adım atar; takip hataları görünür hale getirilir.
5. `AI Live Mirror` ayrıca talep edildiğinde kullanıcıya **“Canlı görüntünüz işlenmek üzere Decart'a iletilir; bu mod cihaz içinde değildir. İstediğiniz an durdurabilirsiniz. Tahmini oturum maliyeti/kişisel ücret: …”** açıklaması gösterilir.
6. Açık rıza + süre bütçesi + ağ kalitesi + uygunluk kapısı geçerse cloud oturumu açılır; 10/15/30 saniyelik seçilebilir oturum, **bitir** butonu, görünür süre sayacı, bağlantı kalitesi ve kaydetme varsayılan KAPALI.
7. Canlı sonuç ekranda gerçek zamana yakın ilerler; ön kamera aynalama hatası, video gecikmesi ve bakış yönü ayrışmaları bağımsız izlenir.
8. Kullanıcı çıkınca video track, WebRTC/LK odası, erişim anahtarı ve geçici bellek temizlenir; ağ kapanınca otomatik tekrar bağlanılmaz. Uygulama arka plana gidince kullanıcıya sormadan yeniden oturum başlamaz.

### 3. Ayna içinde ürünle kombin

- Seçili ceketle **dolabımdan 3 kombin**; yoksa **bu mağazadan** ve sonra **diğer doğrulanmış markalardan**; bütçe, etkinlik, hava, stil DNA, temizlik durumu ve vücut oranı dikkate alınır.
- Kamera açıklığı yanında `Görünüm / Beden / Kumaş / Kombin` dört sekme (veya küçük ekran için yatay chipler): her biri veri kaynağına ve iddia seviyesine bağlıdır.
- Tek hareketle ürün değiştir, kıyafet katmanı ekle/çıkar, önce-sonra bölünmüş görünüm, 3D/avatar moduna geç, kaydet (yerel, kullanıcı eylemi).
- Sponsorlu öneri organik uygunluğun yerini almaz; daima ayrı açık etiket.

## LM21-03 — EDITORIAL ATELIER / CANLI AYNA EKRAN ATLASI

**v2.0 Quiet Atelier** tasarımı korunur: açık `#F8F6F1`, koyu `#26221E`, ceviz `#654632`, zeytin `#62684B`; serif editoryal başlık + SF Pro işlevsel metin. Kamera içeriği karanlık olsa da kontrastlı minimal kontroller gerekir. Alt navigasyon kamera sırasında gizlenebilir, tek hareketle çıkış görünür kalır.

| Ürün kararı / ne hissettirmeli? | Metinsel görsel şema / temel ekran |
|---|---|
| **A. Tarama sonrası davet.** Kameraya geçmeden önce kesin ürün kimliği ve güvenilirlik durumu. | `┌ KABİNSİZ · Ürün ┐`<br>`[Ürün görseli]  [Marka / model / varyant]`<br>`Kumaş: kaynaklı / bilinmiyor`<br>`Beden: doğrulanan aralık / çekince`<br>`[ CANLI AYNADA DENE ]`<br>`[ Dolabımla kombinle ]` |
| **B. Local Live Mirror.** Yüksek kaliteli kamera, minimal yönlendirme, her zaman yerel mod etiketi. | `┌ ‹  CANLI AYNA   Yerel · Çevrimdışı ┐`<br>`│   [canlı kamera + ürün mesh]       │`<br>`│   ○ Dön · Yan · Kolları kaldır    │`<br>`│ [Ön] [Yan] [Arka] [Önce/Sonra]    │`<br>`│ [Ürün A] [Ürün B] [Kombin]        │`<br>`│ [ Beden ] [ Kumaş ] [ Stil ]      │`<br>`└ [ Bitir ] [ Kaydet ] ┘` |
| **C. AI Live Mirror izin kapısı.** Remote canlı video başlangıcından önce bağımsız, sessiz opt-in. | `┌ DAHA GERÇEKÇİ AI ÖNİZLEME ┐`<br>`Canlı video üçüncü taraf hizmete gönderilir.`<br>`Cihaz içi değildir · İnternet gerekir.`<br>`Tahmini süre: [10s] [15s] [30s]`<br>`Ücret / kullanım hakkı: ...`<br>`[ İzin ver ve başlat ]`<br>`[ Yerel aynaya dön ]` |
| **D. AI Live Mirror aktif.** Net “AI görünümü” etiketi, kayıt kapalı, durdurma sabit. | `┌ ‹  AI CANLI AYNA    00:14 / 00:30 ┐`<br>`│     [dönüşümlü uzak video]       │`<br>`│  ● Bulutta işleniyor · gecikme   │`<br>`│  [Ürün değiştir] [Önce/Sonra]   │`<br>`│  [Görünüm] [Beden] [Kombin]     │`<br>`└ [ OTURUMU DURDUR ] ┘` |
| **E. Bağlantı/ısı düşüşü.** Sahte akıcı video oynatma; gecikmeyi saklama. | `Video bağlantısı yavaşladı.`<br>`[ Yerel aynaya geç ] [ Son tekrar deneme ]`<br>`Önceki video karesi yeni canlı kare gibi sunulmaz.` |
| **F. Stilist aynası.** Kullanıcı kendi dolabı + mağaza + bütçe farklılıklarını anlar. | `Bugünkü kombin`<br>`Dolabımda var: krem kazak ✓`<br>`Eksik: ceket / 2 alternatif`<br>`Günlük · Özel · Cesur`<br>`[ Bu kombini canlı dene ]` |

**Tasarım kuralları:** Baştan sona 44pt+ dokunma hedefleri; VoiceOver canlı görüntüde kare-kare konuşmaz, sadece durum değişikliklerini anons eder; Dynamic Type ile panel, buton ve saat sayaçları çakışmaz; `Reduce Motion` altında animasyon azaltılır; cinsiyet sınıflandırması veya beden yargılayan ifadeler yok. Standart model unisex ve nötr; mevcut v2.0 tasarım sistemiyle aynı semantik tokenlar.

## LM21-04 — İŞLEM HATTI / ON-DEVICE ORCHESTRATOR

```text
User Scan or Wardrobe Product
  ↓
ProductIdentity + variant verification ──── BrandCatalog / Provenance / Rights
  ↓
UserConsentRouter ── DeviceBudget ── SourceRightsGate
  ↓
LIVE MIRROR ORCHESTRATOR (one state machine; no 24 independent heavyweight AIs)
  ├─ LocalCameraCapture (AVFoundation)
  ├─ BodyPose / Segmentation (Vision + optional depth)
  ├─ AvatarFit / Calibration (user-corrected, local encrypted vault)
  ├─ GarmentAssetLoader (signed USDZ/mesh/texture/LOD)
  ├─ LocalGarmentRenderer (RealityKit + Metal)
  ├─ ProductEvidence + PrecisionFit (NOT sourced from VTON pixels)
  ├─ Fabric + Thermal + Styling + Wardrobe (same product ID)
  ├─ Thermal / Battery / Memory governor
  └─ Optional CloudVTONAdapter (consent-bound, EgressIntent checked)
        ├─ Ephemeral token backend
        ├─ Decart native iOS SDK / LiveKit WebRTC
        └─ Video stream in/out (never full wardrobe or body vault)
  ↓
DecisionEnvelope + UI Fidelity Label + Provenance + Limitations
```

### İki video boru hattının ayrılığı

**LOCAL:** `AVCaptureSession/AVCaptureVideoDataOutput → Vision 2D/3D pose (+ person matte) → temporal smoothing → body root + arm/hip/shoulder anchors → 3D rig & garment LOD → RealityKit/Metal compositing → local display`.

**CLOUD OPT-IN:** `AVCapture (mute audio, no microphone track) → Decart Swift SDK / LiveKit/WebRTC → remote generated video track → screen`. Hassas profil hiçbir ağa çıkmaz; sadece kamera akışı ve kullanıcı onaylı ürün görseli; ağ tarafındaki veri işleme kullanıcıya açık. Mod ayrımı ekran, mimari ve telemetride zorunlu.

**NOT:** Apple Vision'ın 3D pose API'si eklem noktası döndürür; bel/kalça çevresi, gerçek göğüs hacmi, kumaş sünekliği veya giysi bitmiş ölçüsünü ölçtüğü varsayılamaz. Yüksek kaliteli fiziksel uyum hâlâ ürün verisi + ölçü + kalibrasyon + fiziksel deney doğrulaması gerektirir.

## LM21-05 — MODÜL KARTLARI VE SORUMLULUK SINIRLARI

| Modül | Girdi | Çıktı | Yetki | Hata stratejisi / kalite |
|---|---|---|---|---|
| `LM21-M01 CameraOwner` | açık kamera izni | timestamp'li frame, orientation | local pixels | izin yoksa örnek rehber, kamera yoksa kapalı |
| `M02 FrameClock` | camera & remote timestamps | g2g/TTFF/skips | time metadata only | eski kareyi “canlı” gösterme |
| `M03 PoseTracker` | local image | joint+confidence+occlusion | local only | occlusion'da freeze yerine uyarı / reset |
| `M04 PersonMatte` | frame | mask/depth hint | local only | saç, el, aksesuar kenarı test |
| `M05 BodyCalibration` | kullanıcı ölçüsü, opsiyonel poz | body scale + uncertainty | Vault only | tek foto = santimetre doğruluğu yok |
| `M06 GarmentReference` | product ID, permitted image | resolved asset/rights | public product | yanlış varyantta durdur |
| `M07 RigRetarget` | joints, garment skeleton | stable rig pose | local only | ani dönüşte clipping bildir |
| `M08 ClothApproximation` | mesh, physical proxy | local drape visual tier | local GPU | fiziksel doğruluk iddiası yok |
| `M09 OcclusionComposer` | frame, matte, cloth | rendered frame | local GPU | el/saç önde-arkada hatası test |
| `M10 LogoTextureGuard` | rights-cleared reference | branding/detail fidelity | asset read only | uydurma logoyu kaldır, etiketi görünür tut |
| `M11 PrecisionFit` | actual garment dimensions, body | region fit/ease/uncertainty | vault local | veri eksikse ABSTAIN |
| `M12 FabricTruth` | composition/care/source | source-backed details | source-only | görüntüden yüzde oran uydurma |
| `M13 ThermalContext` | weather/material layering | weather suitability | location abstraction | termal aralık kişisel/bağlamsal |
| `M14 StyleCompanion` | outfit, Style DNA, context | looks with reasons | user data local | beğeni, dönem, bütçe görünür |
| `M15 ProductSwitcher` | verified product variant | same-session change | rights checked | bir önceki outfit'i yeniymiş gibi gösterme |
| `M16 ModeConsentGate` | user choice/purpose | `LOCAL/CLOUD` bounded | explicit only | dark patterns yasak |
| `M17 EgressGate` | host/fields/purpose | allow/deny | explicit allowlist | yeni video purpose varsayılan deny |
| `M18 EphemeralTokenBroker` | rate-limited session intent | short TTL scoped token | backend credentials | key yalnız server |
| `M19 CloudVTONAdapter` | selected image + video track | output video track | cloud ONLY opted | API fail → local fallback |
| `M20 ConnectionGovernor` | bandwidth/RTT/drop stats | quality recommendations | transport only | packet loss → degrade/stop |
| `M21 DeviceGovernor` | thermal/low power/memory | LOD/fps/resource budget | OS signals | ısı ve batarya korunur |
| `M22 SessionBillingGuard` | elapsed time/rate | cap/cost report | billing metadata | max session + hard stop |
| `M23 PrivacyLedger` | consent/version/session | audit events | local secure | iptal sonrası bağlantı yok |
| `M24 IndependentMirrorQA` | approved test datasets | visual/fit/audio/privacy report | tests only | öz-denetime güvenme |

Her modül için eklenecek Swift protocol, `ModuleRegistry` descriptor, `WorkOrder`, zaman aşımı, hata kodu, test fixture ve bağımsız review. Yukarıdakiler **görev sözleşmeleri**, 24 ayrı model veya 24 çalışan servis kurma talimatı değildir. Basit iş deterministik kalır.

## LM21-06 — CİHAZ SAĞLIĞI / GERÇEK ZAMAN BÜTÇESİ

- **Yerel hedefler (hedef, ölçülmedi):** kamera ilk görsel ≤1 saniye p95 (ön izin verildiyse), takip-kare ekran gecikmesi ≤100ms p95 seçilen referans iPhone üzerinde; 24+ fps hedef, adaptif kalite altında stabil asıl hedef kullanıcı algısı. Bu sınırlar yalnız hedef, cihazda kanıt zorunlu.
- **Cloud hedefler (hedef, ölçülmedi):** izin ve ürün doğrulamasından sonra TTFF p95 ≤3 saniye referans Wi-Fi/şehir üzerinde; g2g p95 ≤500ms uygun ağda; `fast` ve `standard` ayrı ölçülür. Ürün sağlayıcının pazarlama “zero perceptible latency” metni ölçüm yerine geçmez.
- **Metrikler:** first camera preview, connect time, first transformed frame, glass-to-glass, jitter, frozen frame ratio, request drop, app memory peak, thermal transitions, power drain/5dk, data MB/60sn, source-image-to-correct-garment consistency. Kıyas aynı ışık/kamera/giysi/görüntü boyutu şartlarında yapılır.
- **Adaptif:** normal → kamera 720p/30 / lokal render 30; ısınma başladığında AI nonessential suspend, 3D LOD drop ve 24fps; kritik ısıda video provayı kapat, ürün kartına dön; OS sinyallerinin desteklemediği kesin ısı derecesi gösterme.
- **Preflight:** internet yok/çok yavaşsa Cloud CTA disabled veya “bağlantı uygun değil”, kullanıcı LOCAL'de kalır. Ücretli deep preflight kullanıcı onayı olmadan yapma.
- **Frame stale:** timestamps + monotonic sequence; gecikmiş çıktı pozisyonla eşleştirilmeden yayına alınamaz; 500ms ve üzerindeki sapmalarda gecikme etiketi, çok yüksekse ayrıştırılmış fallback.
- **Ses:** ürün sadece görsel ayna; mikrofon **her modda kapalı**, SDK audio track oluşturma. Yanlışlıkla mic prompt veya sızan audio P0 ihlal.

## LM21-07 — GÜVENLİK / ÇELİK KUBBE / VERİ HUKUKU

**Mevcut repo bulgusu:** `25897e7` commit'i `CitadelGate` egress ve şifreli CryptoKit Vault için testli çalışma raporluyor; ancak canlı video outbound purpose, `CloudVTONAdapter` ve runtime ağ kontrolü henüz mevcut değil. Aynı kapı kontrolsüz şekilde delinemeyecek; yeni `EgressIntent.Purpose.liveMirrorVideo` yalnız ayrı CLAUDE review/ADR sonrasında açılmalı.

Zorunlu invariantlar:

1. `Local Mirror` modunda 0 outbound görüntü paketi. Instrumented network harness ile doğrula.
2. `Cloud Mirror` kullanıcı “Başlat” düğmesini basmadan token, video track veya model yüklemesi yapılmaz.
3. Yalnız onaylı sağlayıcı host, TLS, signed/short-lived token, purpose-allowlist; permanent key app bundle'a koyulmaz.
4. Token backend yalnız kısa oturum kimliği, ücret sınırı, model ID, device attestation/rate limit ve şartları yönetir; kullanıcı yüzüne, body vault'a veya dolap fotoğraflarına erişmez. Loglar gizli verileri içermez.
5. Sağlayıcıyla sözleşmede canlı video/biometrik benzeri görüntülerin saklanması, eğitimde kullanımı, çalışan erişimi, alt işleyici listesi, ülke sınırları, silme ve ihlal bildirimleri açıklığa kavuşmalı. Decart'ın kamuya açık genel Privacy Policy'si **canlı video kayıtlarını ve geliştirme amacıyla işleme ihtimalini** ifade eder; sadece “saklanmıyor” pazarlama cümlesine dayanmak YASAK.
6. KVKK, GDPR uygulanabilirliği, açık rıza, aydınlatma, yurt dışına aktarım, silme ve veri minimizasyonu için Türkiye merkezli hukukçu incelemesi tamamlanmadan canlı video paylaşımı tüketiciye açılmamalı.
7. Video varsayılan kaydedilmez. Kullanıcı kaydetmek isterse kaynak kullanımı, saklama yeri ve yüz görünürlüğü için ikinci eylem gerekir. iCloud backup ve paylaşım ayrı izin.
8. `Stop` arka plana geçiş, ekran kilidi, kamera izninin geri alınması, maliyet sınırı veya ağ düşüşü halinde *gerçekten* kamera track ve remote session'ı kapatmalı. SDK reconnect'i kullanıcı açık onayı yoksa yeni faturalı oturum başlatamaz.
9. Varsayılan telemetri yalnız toplulaştırılmış teknik ölçümler; raw image/video, embed, kişinin beden koordinatı veya yüz verisi telemetry crash log'a yazılmaz.
10. Kullanıcı açıkça bulut modunu kapatırsa yerel modun tamamı erişilebilir kalır.

## LM21-08 — KATALOG + GİYSİ HAKLARI + DÜRÜST LOGO KALİTESİ

- Ürün kimliği `brand + product model + variant + size + color + catalogRevision + sourceLicense + imageRights`; aynı EAN birden çok renk/modelle eşleşiyorsa kullanıcı seçer, otomatik ürün varsayımı yok.
- Referans görsel için üretici lisansı veya kullanıcı tarafından sağlanan, işlenmesine izin verilmiş foto; izinsiz site kopyalama yok.
- Generatif videoda logo/cep/dikiş/fermuar/düğme/gömlek yazısı değişebilir. **Ürün kimliği ve logo “bire bir aynı” garantisi yoktur.** Yerel 3D'de UV/texture varlığı doğrulanır; generatif model çıktıdan görsel karşılaştırma geçmezse “yaklaşık stil önizlemesi” uyarısı gösterilir.
- Kumaşın havada sallanması veya ekrana dökülmesi mutlak fiziksel doğruluk demek değildir; ölçülen gerçek ürün drop/yıpranma ve stretch testleri olmadan “gerçek kumaş hissi” iddiası yasak.
- Görünüm sonucundaki beden etiketini `PrecisionFitEngine` doğrulanmış verisi olmadan uygulama otomatik üretmez. `SizeAdvisor` için bel/kalça ve uzunluk/omuz/göğüs parça türüne göre **yeterli veri** koşulu belirlenir.
- Bir marka ürününün çekim/reklam görüntüsü ile başka bir markanın imzası veya logosu karıştırılmaz. Güvenilen gerçek kaynak kullanıcıya açılabilir.

## LM21-09 — GERÇEK KULLANIM İÇİN DEKOR DEĞİL KİŞİSELLEŞME

- Stilist şu kısa açıklamaları üretebilmeli: “Bu ceketi dolabındaki krem gömlekle kombinledim; benzerini alma”, “M beden tablosu var, ama kalça bölgesi için ürün bitmiş ölçüsü yok”, “Koyu zeytin tonunu sık tercih ediyorsun, ama bugün farklı görünmek için taupe alternatifini de gösteriyorum.”
- Kullanıcı “Rahat/klasik/cesur/alışveriş için” 4 kipten seçer; tercih hafızası yerel, düzenlenebilir, silinebilir.
- Astroloji/numeroloji kullanıcı açıkça seçmedikçe açık değil; açıldığında “sembolik stil ilhamı”dır. Yüzden karakter/duygu okuma, kültür veya cinsiyeti GPS'den otomatik çıkarma yapılmaz.
- En başta sahip olunan gardırop önerilir; sponsor ve komisyon puanı organik moda/uyum puanını değiştirmez.

## LM21-10 — API / MODEL / SDK ENTEGRASYONU ADIMLARI

1. `docs/research/LM21_DE-CART_VENDOR_DUE_DILIGENCE.md`: resmî API şartları + Swift SDK sürüm/branch/commit/lisans + VTON görüntü desteği, fiyat, iOS deployment, minimum OS, Swift concurrency, CSP/TLS, regional hosting ve retention notlarını kaynaklı kaydet.
2. Önce `local-live-mirror-spike` ayrı branch: gerçek kameranın ön görüntüsü, mirror flip, Vision person matte + 2D pose. Ekranda local-only kontrol ve stop. 3D giysi varsa RealityKit/Metal LOD ile canlı takibini test et.
3. `MirrorProvider` protokolü ve `LocalMirrorProvider` / `CloudVTONProvider` bağımlılık enjeksiyonu. API/cost kapıları UI değil domain seviyesinde.
4. `CloudVTONProvider` yalnız test doubles ile başlanır: `CloudSessionTokenBroker` (ephemeral), `CloudConsentLedger`, `CloudSessionBudget`, `CloudStreamAdapter`. Permanent key saklama yok.
5. Decart SDK POC'sinde önce iOS physical device + **sentetik insan veya yalnız gönüllü yetişkin** ve lisanslı referans giysi; gerçek son kullanıcı verisi yok. VTON `.lucyVton3_6` ile reference image parametresini gerçek API'de kanıtla; docs tutarsızlığında UNKNOWN ve provider support sorusu.
6. Swift SDK `VideoTrack`, mirroring, generation tick, remoteStreamUpdates, disconnect, reconnect, latency quality callbacks, app background, mode switch A/B test edilsin.
7. Vendor Cloud modu için maliyet ve privacy işaretleri geçmeden consumer feature flag default OFF; demo “cloud live video” ile özel local-only ürün mesajını karıştırma.
8. Yerel AR deneyimi yetersizse dürüst fallback: local preview + doğru ürün/beden/style card + Cloud opt-in; Cloud da yetersizse 2D/live camera picture-in-picture.
9. iOS gerçek kamera testleri simülatörde **gerçeklenemez**. Simulator red/green unit tests kalite kapısını geçerse bile `DEVICE_VERIFIED` yazılmaz.

### Swift soyut sözleşme taslağı (derlenmiş olduğu iddia edilmez)

```swift
public enum MirrorMode: String, Codable, Sendable { case local, cloudOptIn }
public enum MirrorStatus: String, Sendable {
    case idle, requestingPermission, preview, preflight, connecting, live, degraded, stopping, stopped, failed
}
public struct MirrorSessionSpec: Sendable {
    public let productVariantID: String
    public let catalogRevision: Int
    public let requestedMode: MirrorMode
    public let maxDurationSeconds: Int
    public let consentRevision: Int?
    public let estimatedMaxCostUSD: Decimal?
}
public protocol LiveMirrorProvider: Sendable {
    func prepare(_ spec: MirrorSessionSpec) async throws
    func start() async throws
    func stop() async
}
```

Real production contract requires async frames, connection quality, reason-coded errors, evidence IDs and `DeviceBudget`/`EgressIntent` integration. **Buradaki taslak hiçbir API'nin çalışan implementasyonu değildir.**

## LM21-11 — CLOUD MALİYET, B2B VE EKONOMİ

### Resmî sağlayıcı oranlarına göre model (2026-11-03; değişebilir)

| Canlı video süresi | Standart `$0.02/s` | Fast `$0.04/s` |
|---:|---:|---:|
| 10 saniye | $0.20 | $0.40 |
| 15 saniye | $0.30 | $0.60 |
| 30 saniye | $0.60 | $1.20 |
| 60 saniye | $1.20 | $2.40 |
| 300 saniye | $6.00 | $12.00 |

- **Çıkarım:** 1000 kullanıcı × 30 saniye = $600 standart doğrudan VTON inference maliyeti (vergi/ağ/hosting/destek ve iptal/reconnect hariç); masrafı yalnız affiliate dönüşüm komisyonlarıyla telafi etme varsayımı **kanıt gerektirir**.
- Ücretsiz lokal deneme: sınırsız kullanım hedefi (cihaz kaynaklarıyla sınırlı). Ücretli cloud: 10–30 saniyelik deneme paketi, kullanıcıya önceden fiyat ve zaman, harcama tavanı, ürün değişiminde ekstra bağlantı kurulmadan (SDK destekliyorsa), görünür durdurma.
- B2B mağazalar için kullanım başına pay veya kota/abonelik; mağazanın izinsiz müşteriyi kameraya çekmesine veya uzaktan oturumunu açmasına izin verilmez.
- Bütçe koruma: user/day cap, fraud risk gate, per-retailer cap, idle-stop, low-network preflight, settlement audit, provider invoice reconcile, alert on spike.
- Finansal kârlılık formülü: `NetContribution = realized gross margin from sales + B2B subscription/usage revenue + user-paid mirror revenue - vendor streamed seconds - backend/network - support - refunds - taxes - retailer share`. Reklam tıklaması veya sepet ekleme = gerçekleşmiş gelir değildir.

## LM21-12 — KARŞILAŞTIRMALI DOĞRULAMA PROTOKOLÜ

### Test çevresi

- En az 3 farklı fiziksel iPhone sınıfı: eski desteklenen, orta, yeni üst segment; kameranın gerçek olması şart.
- Normal ve düşük ışık, karşıdan ve yandan, 2m ve yakın, sade/karmaşık arka plan, bol/dar, açık/koyu, desenli/logolu giysi, oturma/yürüme/dönme/kol kaldırma, aksesuar ve occlusion.
- Wi-Fi iyi/kötü, LTE/5G, packet loss, high RTT, offline, mid-session network switch, ısınma, low power, incoming call, app background, lock screen.
- Ürün veri doğruluğu için lisanslı referans alt küme; gerçek marka/ürün bilgisi bilinmiyorsa `UNKNOWN`. Gerçek deneme video sonucu özel kişisel veri sayılır; gönüllü rızası, anonimleştirme ve zaman kısıtı.

### Test kategorileri ve zorunlu test kimlikleri

| ID | Kabul / yanlış pozitif yakalama |
|---|---|
| LM21-T01 | İzin reddi kamera açmaz; ürün kartı erişilebilir |
| LM21-T02 | Local mode kamera açıldığında ağda raw görüntü byte'ı yok |
| LM21-T03 | Local mode kullanıcı ileride cloud açsa bile eski kişisel fotoğrafları göndermez |
| LM21-T04 | Bilinmeyen ürün kimliği generatif referans yerine gerçek varyant diye kullanılmaz |
| LM21-T05 | QR / GTIN ambigüitesi seçim ister |
| LM21-T06 | Brand/model/size/colour alt veri revizyonu stale asset'i invalid eder |
| LM21-T07 | Ön kamera mirror flip kaynak ürün logosunu ters yazmaz |
| LM21-T08 | Arka kamera dönüşünde orientation/preview bozulmaz |
| LM21-T09 | 90/180° insan dönüşünde rig veya yüz kopması kalite hatası sayılır |
| LM21-T10 | Kol kaldırmada sleeve ve occlusion clipping ölçülür |
| LM21-T11 | El gövdenin önüne geçtiğinde segmentation doğru yığılma sırası oluşturur |
| LM21-T12 | Saç ve uzun palto sınırı test edilir |
| LM21-T13 | Occluded uzuv varlığında bel/kalça fit kesinliği üretilmez |
| LM21-T14 | Cloud opt-in ekranı olmadan backend token bile istenmez |
| LM21-T15 | Egress allowlist dışında host, field, purpose fail-closed |
| LM21-T16 | Cihaz vault/beden profili/galeri cloud request içinde hiç yok |
| LM21-T17 | Mikrofon izni istenmez, audio track stream edilmez |
| LM21-T18 | Cloud mode kullanıcı durdurduğunda remote session ve local track kapatılır |
| LM21-T19 | Cloud stop sonrası otomatik faturalı reconnect yok |
| LM21-T20 | Background/lock/incoming call'da cleanup/consent yenileme |
| LM21-T21 | Start session öncesi kalıcı API key app bundle/network log'da yok |
| LM21-T22 | Ephemeral token TTL, allowed model, maxDuration, revoke/rate limit test |
| LM21-T23 | 10/15/30 saniye budget enforcement; kullanıcıya fiyat önceden |
| LM21-T24 | Vendor API fiyat değişikliğinde otomatik eski maliyet iddiası yok |
| LM21-T25 | Cloud bağlantısız local mirror kullanılabiliyor |
| LM21-T26 | E2E camera→screen gecikme ölçümü başvuru/p95/p99 bazında |
| LM21-T27 | TTFF p95 per network / device sınıf raporlandı |
| LM21-T28 | 30–60 saniye oturum frame freeze/drop oranı |
| LM21-T29 | 5 dk lokal kaynak/ısı/batarya ve memory ölçümü |
| LM21-T30 | Isı artınca quality downgrade görünür ve kill switch çalışır |
| LM21-T31 | AI logo, ürün dikişleri ve cep yerleşimi kaynakla görsel denetlenir |
| LM21-T32 | Generatif fiziksel ölçü hatası beden motorunu etkilemez |
| LM21-T33 | Bilinmeyen kumaş bileşimi “%100 pamuk” uydurulmaz |
| LM21-T34 | Kullanıcı kesin beden yanıltıcı iddiasını görmez |
| LM21-T35 | Sponsorlu ürün uygunluk sıralamasını gizlice yükseltmez |
| LM21-T36 | Kayıt varsayılan kapalı; kullanıcı eylemi olmadan video diske yok |
| LM21-T37 | Silme/geri alma/Vault politikası cloud loglarıyla çelişmez |
| LM21-T38 | VoiceOver, Dynamic Type, high contrast, Reduce Motion pass |
| LM21-T39 | Fiziksel cihaz testleri Simulator'dan ayrı kanıt sınıfına konur |
| LM21-T40 | Üçüncü taraf sözleşme/DPA yoksa Cloud flag OFF |
| LM21-T41 | Başarısız referans görsel değişiminde eski giysi yeniymiş gibi görünmez |
| LM21-T42 | Kamera ayarları sıfırlanırken background veya eski ses track'i kalmaz |
| LM21-T43 | Cloud video output yüz / beden/arka plan distorsiyon regression raporları |
| LM21-T44 | Kullanıcı iki farklı aynı beden üründe aynı fiziksel fit varsayımına maruz kalmaz |
| LM21-T45 | İki cihaz modelinde milisaniye ve MB/maliyet raporları karşılaştırılabilir |
| LM21-T46 | Sunucu 429/5xx veya TLS error, timeout, broken ICE durumlarında kilitlenme yok |
| LM21-T47 | Model/SDK sürüm yükseltmesi referans regression test olmadan yayına çıkmaz |
| LM21-T48 | Video akışı görsel kalitesi avatar/mesh fidelity tier ile karıştırılmaz |
| LM21-T49 | Fotoğraf referansı için lisans ve görsel ürün hakkı yoksa cloud'a geçilmez |
| LM21-T50 | Disclose: “Bu bir stil önizlemesi, gerçek beden garantisi değil” her modda erişilebilir |

### Release gate (zorunlu)

- P0 mahremiyet, egress, API key, harcama, kullanıcı güvenliği: **0 açık kritik**.
- Ürüne ve kişinin bedenine dair kesin iddialar: kaynaklı/evidence ve fiziksel karşılaştırma zorunlu.
- Testlerin yazılmış olması testlerin geçmiş olması demek değildir; test komutu, exit code, cihaz model/OS, SHA, ekran videosu, network capture, CPU/GPU/termal ölçüm ve bağımsız QA raporları birleştirilmeli.
- Kalite hedefleri gerçekte tutmazsa cloud veya local modu **beta/deneysel** bırak; pazarlama iddiasını gerçeğe göre düzenle.

## LM21-13 — CLAUDE UZMANLARI, SKILL VE MCP PLANI

### Geliştirme/review rollerinin ayrılması

| Rol | Claude ajanı / uzmanlık | Teslim / kendi işini onaylayamaz |
|---|---|---|
| `AG-LM-01` | Live Video Systems Architect | 2 engine ADR, contracts, state machine, integration DAG |
| `AG-LM-02` | Apple Camera / AVFoundation | track lifecycle, orientation, permission, physical device |
| `AG-LM-03` | Body Tracking / Vision | pose, segmentation, uncertainty, occlusion benchmarks |
| `AG-LM-04` | 3D Garment / Blender / RealityKit | asset and rig pipeline, clipping physics tiers |
| `AG-LM-05` | ML Video / Decart Integration | API provenance, Swift SDK POC, actual frames, no fake tests |
| `AG-LM-06` | Network & WebRTC | g2g, ICE, reconnect, bitrate, session limit |
| `AG-LM-07` | Privacy & Cryptography | opt-in, threat model, backend token, egress, revocation |
| `AG-LM-08` | Fit Science / Textile | product fit must not be inferred from video alone |
| `AG-LM-09` | UX / Accessibility & Brand | editorial on-screen panels, one-tap stop, safe copy |
| `AG-LM-10` | Commerce & Unit Economics | per-second billing, price, caps, B2B plan |
| `AG-LM-11` | Independent QA / Red Team | wrong garment, logo/fabric hallucination, camera leak, net cost |
| `AG-LM-12` | Release & External Compliance | Apple review, user claims, DPA, platform/legal gates |

**MCP önceliği:** Resmî GitHub connector mevcutsa repository ve test kanıtı için kullan; XcodeBuildMCP mevcutsa sandbox/izin/versiyon denetimi sonrası gerçek build/test/screenshot için; Blender MCP sadece güvendiğin, sınırlı çalışma alanında varlık üretimi; Decart SDK MCP diye otomatik “güvenilir araç” varsayımı YOK, resmî Swift SDK + izinli API sözleşmesi. Kaynağı belirsiz MCP sunucusuna kamera videosu, Keychain, beden verisi veya token açma. Her MCP minimum yetki, güvenlik ve lisans denetimi sonrası kurulur.

**Skill'ler:** `ios-camera-live-capture`, `vision-body-pose-occlusion`, `realitykit-cloth-rig`, `decard-vton-swift-integration` (doğru sağlayıcı adı **Decart**), `webrtc-stream-quality`, `privacy-consent-egress`, `vendor-license-retention`, `fit-and-garment-truth`, `device-battery-thermal-performance`, `live-mirror-visual-qa`. Repo `.claude/skills/` içinde README/`SKILL.md` olarak proje-özgü içerikler üretilebilir; isim önerisi kurulu oldukları anlamına gelmez.

## LM21-14 — UYGULAMA İŞ SIRASI (MEVCUT V2.0 ÇALIŞMASINI BOZMADAN)

| WP | Öncelik | İş | Bağımlılık / başarı kanıtı |
|---|---|---|---|
| `LM21-WP01` | P0 | Reality baseline; iPhone bağlantısı, repo SHA ve SDK kaynak doğrulama | Gerçek HEAD + cihaz listesi |
| `LM21-WP02` | P0 | Two-engine ADR + local/cloud consent threat model | Gizlilik ve ürün imza sahipleri |
| `LM21-WP03` | P0 | LiveMirror contracts/event/state/error/fidelity | Swift Testing; revizyon guard |
| `LM21-WP04` | P0 | Local native camera mirror shell (no overlay yet) | Fiziksel iPhone capture + stop |
| `LM21-WP05` | P0 | Pose/segmentation + frame sync | Offline + turn/arm tests |
| `LM21-WP06` | P0 | RealityKit/Metal one garment with correct masking | Demo asset; mesh provenance |
| `LM21-WP07` | P0 | FPS, thermal, power, memory governor | 3 iPhone sınıfında ölçüm |
| `LM21-WP08` | P0 | Local mirror UI, truth labels, VoiceOver | Screenshot/video + accessibility |
| `LM21-WP09` | P0 | Fit & product-evidence independent integration | Gerçek beden tabloları veya `ABSTAIN` |
| `LM21-WP10` | P1 | Decart Swift SDK integration research + vendor terms | Signed legal/DPA status; no secret |
| `LM21-WP11` | P1 | Token broker stub, flags OFF, privacy negative tests | Static/dynamic egress tests |
| `LM21-WP12` | P1 | 10-second closed beta cloud VTON POC (adult opt-in) | Actual remote stream + TTFF/latency |
| `LM21-WP13` | P1 | Vendor-switch design; local fallback and price caps | Stop/reconnect/cost proof |
| `LM21-WP14` | P1 | Outfit switch, shopping/wardrobe integration | Real user steps + provenance |
| `LM21-WP15` | P1 | Visual fit truth lab incl. logo distortions | Human/style/textile independent review |
| `LM21-WP16` | P1 | Pilot unit economics with retail partners | Partner permission, consent, B2B budget |
| `LM21-WP17` | P1 | Release audit and app review readiness | Device, DPA, rights, UX, security all pass |

**Önemli bağımlılık:** Önce repo v1.5 `WP15-05/06/07/08` temel koordinatör/gövde/gov işleri ve v2.0 tasarım göçü ile bu LM iş paketleri arasında conflict register çıkar. `WP15-03/04` Citadel/Vault `25897e7` durumunda testli raporlandı; tekrar yazma, ancak **kamera egressi** için ilave politika gerekir. Paralel çalışma ayrı branch ve açıklanmış dosya sahipliği ister.

## LM21-15 — CLAUDE'A ZORUNLU 25 DENETİM SORUSU

1. Son repo HEAD, açık PR/branch, gerçek cihaz, test exit code ve kanıtlar nedir?
2. İlk kullanıcı videosunda gördüğümüz teknolojinin Anywear olduğunu kanıtlayan kaynak var mı? Yoksa UNKNOWN mu?
3. `lucy-vton-3.6` Swift SDK sürümüyle gerçek referans kıyafet görseli ve kamera birlikte çalışıyor mu?
4. Gerekli Swift SDK'nın sürüm/Swift 6/iOS 18 derleme uyumu ölçüldü mü?
5. Yerel kamera önizleme TTFF ve video FPS gerçek cihazda kaç?
6. Gerçek kişinin omuz/kalça tahminleri hangi ölçümü içerir, hangisini içermez?
7. Kıyafet iskelete dönünce yüzde kaç frame'de clipping var?
8. El/saç arkası mask hataları hangi testlerle azaltıldı?
9. Gerçek marka logosu/dikişi generatif videoda değişiyor mu, ölçtün mü?
10. Ürün model/beden/renk kesin tanımlanıyor mu, veri kaynağı ve lisansı nedir?
11. Kumaş bileşimi hangi kanıttan geliyor, videodan tahminle uydurma var mı?
12. Tamamen yerel moddayken paket yakalamada gerçekten sıfır video egress var mı?
13. Cloud başlamadan önce ayrı rıza/aydınlatma ve veri hakları ekranı var mı?
14. Decart hizmet şartları/DPA Türkiye'den canlı görüntü gönderimini kapsıyor mu?
15. Kalıcı API key hangi sunucuda saklanıyor; bundle'a girmediği kanıtlı mı?
16. SDK reconnect/billing kontrolsüz bir maliyet çıkarabiliyor mu?
17. Oturum maksimum saniyeyi gerçekten donanım ve sunucuda zorluyor mu?
18. Ortalama ve p95 glass-to-glass latency hangi ölçüm aracıyla alındı?
19. Mobil veri tüketimi MB/dk ve batarya tüketimi 5 dakikada kaç?
20. Cloud gecikmesi artınca kullanıcıya gerçek fallback iletiliyor mu?
21. Kullanıcı uygulamayı kilitlerse/izin çeker/arka plana geçerse bağlantı kapanıyor mu?
22. Demo videoları gerçek cihaz kayıtları mı, yoksa üretilmiş/önceden çekilmiş mi?
23. 1K/10K aylık aktif kullanıcının P&L modeli sponsor/komisyon gelirinden bağımsız hesaplandı mı?
24. İnsan moda/textile, privacy, accessibility ve external red team sonuçları ayrı mı?
25. P0 eksik olduğunda geliştirici raporu nasıl `BLOCKED` ve `UNKNOWN` yazıyor?

## LM21-16 — İLK ÇALIŞAN İSPAT / MINIMUM VIABLE MIRROR

**Kesin ilk dikey dilim:** `Gerçek iPhone'da lokal kamera → kullanıcının 3D gövde takip noktaları → lisanslı sentetik prototip gömleğin rig üzerinde canlı takibi → 90 derece dönme ve kol kaldırma → tek tuşla durdur → ağda sıfır hassas veri → termal/governor ölçüm → gerçek cihaz videosu ve test raporu`.

Sonraki bağımsız deney: `Kullanıcı rızası + Decart 10 saniye cloud VTON (test token) → gerçek cihaz WebRTC çıktı videosu → maliyet $0.20 teorik standarda karşı sağlayıcı gerçek fatura → gecikme + logo/fit hatası → stop`. **Bu deney kullanıcıların gerçek kamera akışını buluta gönderme onayı/işleme sözleşmesi olmadan yapılmaz.**

Bu iki kanıt olmadan `KABİNSİZ CANLI AYNAYI YAPTIK` deme.

### Claude'a doğrudan ilk mesaj

> `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md` dosyasını **tam kanonik** anayasa olarak oku. Repo `gundogandogancan/kabinsiz` üzerinde ilk önce HEAD/cihaz/test baseline denetimi yap; geçmiş SHA'yı güncel sayma. Bu belgedeki `LM21-00…LM21-16` şartlarını ürünün Canlı Ayna hedefi olarak al. Local Live Mirror'ı güvenilir ve cihaz içi native SwiftUI/AVFoundation/Vision/RealityKit ile kanıtla. Decart Lucy VTON 3.6 native Swift SDK için ayrı izinli POC planı oluştur; gerçek kullanıcı görüntüsünü veya kalıcı API anahtarını asla izinsiz aktararak canlı demosu yapma. Bulut modunu kullanıcıya şeffaflık, vendor hakları, maliyet, session cap ve güvenlik kapıları geçmeden açma. Fit bilimi ile generatif görünüm kanallarını ayır. Tüm iş paketlerini repo kodu ve kaynaklı gerçek test kanıtlarıyla yönet. İlk teslimde `LM21-WP01...WP04` gerçek çıktıları, açık `UNKNOWN/BLOCKED` listesi, test komutları, exit code, ekran/video kanıtı ve bağımsız review ver. Kendi kendine tamamlanmış ilan etme.

## LM21-17 — KAYNAK / LİSANS / RESEARCH REGISTER

_3 Kasım 2026 itibarıyla gözlemlenen resmî dokümanlar; ürün/hizmetler ve fiyatlar değişebilir._

- Decart resmî Lucy VTON platform: https://platform.decart.ai/models/lucy-vton
- Decart resmî gerçek zamanlı fiyat: https://docs.platform.decart.ai/getting-started/pricing
- Decart resmî Swift SDK ve kurulum: https://github.com/DecartAI/decart-ios
- Swift realtime iOS SDK belgeleri: https://docs.platform.decart.ai/sdks/swift-realtime
- Ephemeral token ve yetki: https://docs.platform.decart.ai/getting-started/client-tokens
- Decart resmî Privacy Policy (canlı kayıt/veri işleme kapsamı): https://docs.platform.decart.ai/resources/privacy-policy
- Decart Anywear canlı sanal prova: https://anywear.decart.ai/live-virtual-try-on
- Anywear Pro bağımsız servis açıklaması: https://www.anywear.pro/about
- Apple Vision 3D pose: https://developer.apple.com/documentation/vision/vndetecthumanbodypose3drequest
- Apple canlı insan segmentasyonu + Metal örneği: https://developer.apple.com/documentation/vision/applying-matte-effects-to-people-in-images-and-video
- Apple TrueDepth canlı önizleme: https://developer.apple.com/documentation/avfoundation/enhancing-live-video-by-leveraging-truedepth-camera-data
- Repo: https://github.com/gundogandogancan/kabinsiz
- Instagram asıl video (incelenemedi): https://www.instagram.com/reel/DfMi-cDsECb/

### Asıl mühendislik felsefesi

> “Ayna insana, kıyafet gerçeğe sadık olmalı. Görsel etkileyicilik gerçek ölçünün yerini almamalı. Mahremiyet sessiz bir özellik değil, ürünün temel sözüdür. Her iyi hissettiren deneyimin altında ölçülebilir doğru mühendislik bulunur.”

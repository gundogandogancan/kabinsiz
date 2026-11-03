# KABİNSİZ — GOD LEVEL v2.6
## TARA + AYNA = TEK “DENE” DENEYİMİ
### Teknik entegrasyon, ürün mimarisi, MCP/skills, veri hakları, sağlayıcı sözleşmesi ve kanıt kapıları

**Tarih:** 03.11.2026  
**Durum:** Yeni bağlayıcı ürün kararı / SPEC_ONLY, henüz uygulanmış veya sözleşmesi imzalanmış değildir.  
**Mevcut repo:** https://github.com/gundogandogancan/kabinsiz  
**İncelenen main:** `30ed2ef9ab38db939ca4faf2b098f83fe256e23a` (2026-11-03 15:25 UTC).  
**Önceki kaynaklar:** v2.1 kanonik repo anayasası ve v2.2–v2.5 kullanıcının verdiği ek belgeler. Ürün deneyimi bakımından bu ek, eski ayrı “Tara / Ayna” ekranları kararını değiştirir; güvenlik ve doğruluk konusundaki daha sıkı eski kurallar saklıdır.

---

## 0. YÖNETİCİ KARARI

Kabinsiz'in ana alışveriş yüzeyi tek bir **DENE** alanıdır. “Tara” ürün edinme yöntemidir, “Ayna” aynı yolculuğun ikinci aşamasıdır; iki bağımsız ürün veya kullanıcıdan aynı ürünü iki kez seçmesini isteyen sekme değildir.

**Ürün vaadi:** “Ürünü bul → doğru ürünü doğrula → üstünde gör → hareket et → beden/kumaş kanıtını incele → dolabınla kombinle → satın almaya karar ver.”

**Önemli sınır:** İyi görünen AI videosu, bedenin tam oturduğunun, kumaş drapesinin veya marka logosunun birebir doğruluğunun kanıtı DEĞİLDİR. Kalıp ve ölçü kararı bağımsız gerçek ürün verisi ve vücut ölçüsünden gelir.

**Servis adlandırması:** Anywear, Decart'ın tüketiciye yönelik deneyimine verilen isimdir. Kabinsiz için aday geliştirici servisi Decart **Lucy VTON 3.6 Realtime API**; entegrasyon yolu Decart'ın **native Swift SDK**'sıdır. Hizmeti kullanma yetkisi web ürünü görüntülemekten veya açık kaynak Swift SDK lisansından otomatik doğmaz.

**Hukuk kapısı:** Hiçbir yazılım ajanı kullanıcının/şirketin yerine şirket adına hesap açma şartı kabul etmeyecek, sözleşme imzalamayacak, ücretli plan almayacak, veri işlemeye başlamayacak. Gerçek yetkili insan imzası ve belgeli değerlendirme gereklidir.

---

## 1. UX: TEK EKRANDA TARA VE DENE

### 1.1 Bilgi mimarisi

Önerilen alt menü: `BUGÜN | DENE | DOLABIM`; profil, ayarlar, vücut modeli üst menüde. Bu öneri mevcut 3-tab IA değişikliğidir ve regresyon testli ADR gerektirir. Ayrı `Tara` ve `Live Mirror` tabları olmayacak.

**Giriş noktaları:**

1. Ana sayfadaki `Ürünü Dene` eylemi → Dene.
2. Alt navigasyondaki `Dene` → Dene.
3. Safari/alışveriş sitesi iOS Share Extension → aynı ürün oturumu.
4. Kopyalanmış ürün bağlantısını yapıştırma → aynı ürün oturumu.
5. Kullanıcının galerisinden ürün fotoğrafı seçme → aynı ürün oturumu.
6. Gardırop içindeki kıyafete `Üzerimde Gör` → aynı ürün oturumu.

### 1.2 Ekran akışı

```text
┌──────────────────────────────────────────────┐
│ Kabinsiz                       Profil       │
│                                              │
│                 DENE                         │
│          Ürünü bul ve üstünde gör            │
│                                              │
│  ┌──────── KAMERA / ÜRÜN ARAMA ────────────┐ │
│  │ Mağaza barkodu veya kıyafet etiketi     │ │
│  │      [ kadraj / ürün algılama ]         │ │
│  │                                        │ │
│  │  Fotoğraf   Barkod   Bağlantı   Dolap   │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  Ürün bulundu → MARKA / MODEL / RENK / BEDEN │
│  [Doğrulanmış] [Kaynak] [Yanlışsa düzelt]     │
│                                              │
│          [ ÜZERİMDE GÖSTER ]                  │
│                                              │
│     Yerel 3D önizleme / Kamera provası       │
│                ↓ aynı oturum                 │
│  ┌────────────────────────────────────────┐ │
│  │       CANLI ÖN KAMERA GÖRÜNTÜSÜ        │ │
│  │       KULLANICI + SEÇİLEN ÜRÜN         │ │
│  │                                        │ │
│  │  [Üst] [Alt] [Ayakkabı] [Dış giyim]    │ │
│  └────────────────────────────────────────┘ │
│  [Kıyafeti Değiştir] [Kombinle] [Beden]       │
│  [Durdur]   [Yerel/AI modu — ayrı onay]       │
└──────────────────────────────────────────────┘
```

**Ekranda aşamalı gösterim:** Tarama kamerası arka kamerayla, gerçek kişi aynası ön kamerayla çalışır. Kamera geçişi önce mevcut capture/session'ı güvenle durdurur; kullanıcıya açık durumu gösterir. Ürün kimliği ve seçilen kıyafet state üzerinde taşınır; yeniden girilmez.

**On-screen söz:** “Bu kıyafet sende yaklaşık böyle görünebilir.” Daha kesin sözcükler ancak gerçek ürün verisi ve ayrı kalibre edilen testlerle kullanılabilir.

### 1.3 Hata ve alternatif akışları

- Kod bulunamadı → “Katalogda doğrulanamadı”; fotoğrafla ara / ürün adını gir / yerel genel stil simülasyonu diye ayrı etiket.
- Barkod eşleşiyor ama beden/renk varyantı belirsiz → kullanıcı seçim ekranı.
- Marka logosu referansta okunamıyor → görsel sadakat düşük, saklama/satın alma gerekçesi olarak kullanma.
- Ürün kıyafetse ama görsel asset yok → lisanslı asset varsa yerel 3D; yoksa doğru sınırlama etiketiyle 2D karar kartı; gerçek ürünü giymiş gibi sahte overlay YOK.
- Kamera verilmedi → ürün kartı, vücut modeli ve offline dolap akışı kullanılabilir.
- Bulut onayı yok → yalnız yerel mod; cloud için örtük geçiş YOK.
- Kullanıcı mağazanın içinde ve yanında başka insanlar var → otomatik arka kamera/ön kamera video yükleme YOK; kadraj/arka planı azaltan ve mümkünse sesi almayan güvenli yaklaşım.

---

## 2. AYRILMASI GEREKEN DÖRT TEKNİK GERÇEK

1. **Product Resolution:** Ürün kimliği ve varyantı. Barcode/GTIN tek başına ürünün bütün ölçülerini vermez.
2. **Visual Fit:** Resimde/video akışında görünüm. Jeneratif model; detayları değiştirebilir.
3. **Physical Fit:** Bölgesel beden eşleşmesi. Gerçek bitmiş ürün ölçüleri, beden ve kullanıcı ölçüleri, kalıp toleransı ile ayrı hesaplanır.
4. **Style Recommendation:** Hava/etkinlik/dolap/bütçe ve kişisel stile göre kombin. Affiliate sıralama sinyali bu gerçeği bastıramaz.

Bu dört sonuç `EvidenceRecord`, `ProductIdentityV1`, `VisualTryOnV1` ve `DecisionEnvelope` üzerinden ilişkilendirilecek; tek “%99 uyum” gibi yanlış kesinlik çıkarılmayacak.

---

## 3. HANGİ MODELİ KULLANALIM?

### A. Yerel On-Device Mirror — zorunlu, açık rıza harici bulutsuz

- `AVFoundation`: kamera yakalama, ön/arka geçiş.
- `VisionKit` / Apple `Vision`: barkod/OCR, insan poz noktaları, uygun olduğunda kişi ayrıştırma.
- `RealityKit`, `Metal`, `Core ML`: 3D avatar, giysi rig/overlay, render ve cihaz içi çıkarım.
- `Blender`: runtime DEĞİL, offline model/mesh/material/scene export ve optimizasyon hattı.
- Yerel mod **sadece kamera + sahte giysi efekti** şeklinde sunulmamalı. Gerçek ürün asset'i olmayan durumda fidelity düşmeli ve kullanıcı bunu görmeli.
- Isı/performans için dynamic governor; düşen frame oranında eylemler ve kamera korunur; gerekirse 2D fallback.

### B. Decart Lucy VTON 3.6 — koşullu bulut POC

- Resmî model: `lucy-vton-3.6`; `lucy-vton-latest` bugün 3.6'ya yönleniyor; ürün davranışı için belirli sürümü pinle, yükseltmeyi ADR/testle yap.
- Resmî Swift SDK: https://github.com/DecartAI/decart-ios
- Resmî VTON rehberi: https://docs.platform.decart.ai/models/realtime/virtual-try-on
- Model isteği: doğrulanmış veya kullanıcı tarafından hakları sağlanmış **giysi referans görseli** ve sıkı kapsamlı açıklama; serbest metin “benzer ceket yap” gerçek ürün varyantı değildir.
- iOS SDK API'leri değişebileceği için kod örneklerini doküman/MCP ile kontrol et; eski sürüm ile güncel imzayı karıştırma. SPM sürümünü lisans ve Xcode/Swift 6.2 uyumu kontrolünden sonra sabitle.
- Yalnız izinli kontrollü testte etkinleştir; gerçek kullanıcı/kamera buluta **sözleşme ve mahremiyet kapısından önce** gönderilmez.

### C. Alternatif modeller

- FASHN VTON 1.5 = tek/az sayıda 2D fotoğraf tabanlı prova; canlı video sağlayıcı değildir. Açık modelin tüm ağırlık ve bağımlılık lisansları ayrıca denetlenir. Kullanıcıya canlı iPhone uygulamasında çalışacağı garanti edilmez.
- CatVTON, Mobile-VTON = ticari kısıtlı lisansları sebebiyle ticari uygulamaya doğrudan alınmaz.
- Anywear = tüketici ürünü; otomatik SDK/marka ortaklığı hakkı YOK.

**Seçim:** Local Mirror kalıcı varsayılan; Lucy VTON sözleşme ve teknik kalite testleri geçerse seçilebilir premium servis. Tek sağlayıcıya kilitlenme yok: `MirrorProvider` adaptörü üzerinden tak-çıkar.

---

## 4. MCP, SKILL VE RUNTIME FARKI

| Sınıf | Araç | Amaç | Kontrol |
|---|---|---|---|
| **Claude Docs MCP** | `https://docs.platform.decart.ai/mcp` | Resmî Decart model/SDK/endpoint parametreleri | Kurulabilir; gerçek kullanım için Decart API anahtarı değildir |
| **Claude Skill** | `npx skills add https://docs.platform.decart.ai -a claude-code` | API şablonları ve sık hatalar | CLI ve indirilen içerik güvenlik incelemesinden sonra |
| **GitHub** | Mevcut GitHub konektörü | Repo denetimi, issue/PR, commit | Mevcut dal/şube iş akışı korunur |
| **XcodeBuildMCP (opsiyonel)** | Kuruluysa kontrol et, yoksa güvenilir kaynak araştır | Build, UI/simülatör ekran testleri | Yetkileri, sürüm, güvenli runner ayrı kapı |
| **Blender MCP (opsiyonel)** | Yalnız güvenilir/yetkili dev ortamında | Asset üretim pipeline'ı | Arbitrary Python/script execution riski; sandbox |
| **APP RUNTIME** | Decart Swift SDK + WebRTC/LiveKit | Canlı ayna video akışı | Bu **MCP değildir**; gerçek ürün koduna bağlanır |
| **APP RUNTIME** | Native Apple frameworks | Cihazda yerel ayna | Bulutsuz çalışma ve ayrı renderer |

Resmî Claude Code MCP komutu (önce kullanıcı tarafından dev ortamında incelenip uygulanacak):

```bash
claude mcp add decart-docs https://docs.platform.decart.ai/mcp --transport http
```

Resmî skill kurulum önerisi (üçüncü taraf kodu çalıştırdığı için otomatik çalıştırma yok):

```bash
npx skills add https://docs.platform.decart.ai -a claude-code
```

MCP kurulmuş olması, Decart hesabı açıldığı, anlaşma imzalandığı, API anahtarı alındığı veya gerçek canlı kamera akışı çalıştığı anlamına GELMEZ.

---

## 5. SAĞLAYICI SÖZLEŞMESİ VE İNSAN ONAY KAPISI — P0

### 5.1 Neden kritik?

Decart API Terms (26 Temmuz 2026) **§2.3** içinde Input ve Output için hizmeti işletme/iyileştirme ve model eğitimi amacını içeren çok geniş, sürekli ve alt lisanslanabilir haklar tanımlar. **§4.2** Input/Output'un gizli bilgi sayılmadığını ve kişisel içerik gönderimi risklerinin geliştiriciye ait olduğunu söyler. Ürünümüzün kullanıcıya ait yüz/video/beden görüntüsü açısından bu, varsayılan local-first ilkemizle ciddi gerilim yaratır.

Ayrıca API Terms ilk API kullanımının/kayıt işleminin sözleşme kabulü anlamına gelebileceğini belirtir. Bu nedenle **Claude'un deneme hesabı açması veya ilk API çağrısı bile insan onayından önce yapılmamalıdır.**

Resmî kaynaklar:
- https://docs.platform.decart.ai/resources/api-terms
- https://docs.platform.decart.ai/resources/dpa
- https://decart.ai/privacy-policy
- https://docs.platform.decart.ai/getting-started/pricing

### 5.2 Decart'tan yazılı olarak teyit / sözleşmede değiştirilmesi istenecekler

1. Girdi/çıktı ve canlı video kareleri için **model eğitimi kullanımı yok (no-training)**; devre dışı bırakılabilir ve yazılı bağlayıcı.
2. Ham video, referans görseller, sonuçlar, loglar ve telemetri için **saklama süresi, silme ve alt işleyici davranışı** açık.
3. DPA/KVKK/GDPR bağlamında rol dağılımı, uluslararası aktarım mekanizması ve veri işleme konumu; Türkiye + AB kullanıcıları için ayrı değerlendirme.
4. Alt işleyenler listesi ve hizmetten çıktığımızda veri silme/teslim kontrolü.
5. Son kullanıcıların yüz/beden verisine ilişkin sınırlı amaç, biyometrik çıkarım yasağı veya uygun koruyucu hükümler.
6. Ticari uygulamada kullanım, marka ürün görselleriyle kullanım, ticari gösterim ve çıktı hakları açık.
7. Servisin output'ta marka/logo/desen değiştirme olasılığı ve sorumluluk sınırı.
8. SLA, destek, olay bildirimleri, ücret modeli, hacim indirimi, günlük/aylık harcama limiti, ürün API sürümü ve sonlandırma hakkı.
9. Uygun olduğunda **sipariş formu/özel ek sözleşme** ile standart §2.3/§4.2 hükümlerini daraltan hukuken bağlayıcı yazılı mutabakat.
10. İnsan imzası: yalnız yetkili şirket yöneticisi veya yetkili imzacı, gerektiğinde avukat incelemesinden sonra.

**Durum etiketleri:** `UNREVIEWED -> NEGOTIATING -> HUMAN_APPROVED -> SIGNED/ACCEPTED -> VALIDATED`; uygun değilse `REJECTED` ve cloud feature `OFF`. DPA'nın sitede bulunması **özel no-training anlaşması imzalandı** anlamına gelmez.

### 5.3 Claude'a kesin yasaklar

- Kullanıcı adına sözleşmeyi kabul etme veya kutucuk işaretleme.
- Otomatik hesabı açma, kredi satın alma, ödeme aracı ekleme.
- Gerçek insan videosunu/kimlik bilgilerini sağlayıcıya gönderme.
- Anahtarı git/Info.plist/uygulama binary'sinde tutma.
- SDK örneğindeki kalıcı `apiKey` placeholder'ını production tasarımına taşıma.
- Standart ToS riskini “DPA var, tamam” diye kapatma.

### 5.4 Decart iş geliştirme ekibine gönderilebilecek İngilizce talep metni (taslak)

```text
Subject: Kabinsiz — Enterprise Lucy VTON live try-on, data privacy and integration terms

Hello Decart team,

We are evaluating Lucy VTON 3.6 for Kabinsiz, an iOS-first virtual fitting and personal styling product. Our default architecture is on-device and privacy-first. We are interested in a consent-based, optional real-time AI mirror for commercially licensed garment images.

Before creating an account, accepting API terms or transmitting any real customer video, could you clarify whether you can provide a signed enterprise order form / data protection addendum covering:

1. No training, model improvement or secondary use of our end-user camera video, face/body imagery, garment assets, inputs or outputs;
2. Explicit retention, deletion, subprocessor and region / cross-border transfer commitments, including Türkiye and EU users;
3. Commercial application rights, content usage, security controls and incident response;
4. Per-second realtime pricing, hard spend caps, expected latency, availability/SLA and support;
5. Swift SDK client-token architecture and any recommended restrictions for on-device iOS clients;
6. Resolution of any conflicts with the published API Terms, notably input/output licences and confidentiality language.

We would initially benchmark using synthetic/consented test assets only, subject to agreement and approval. Please send your enterprise documentation and the relevant agreement process.

Regards,
Kabinsiz team
```

Bu metin **gönderilmiş değildir**. Gönderme ve bağlayıcı anlaşma kullanıcı onayı gerektirir.

---

## 6. MALİYET VE ÜRÜN EKONOMİSİ

Resmî pay-as-you-go fiyat sayfası (2026-11-03 kontrol):
- `lucy-vton-3.6` realtime 720p: **$0.02/aktif saniye**.
- Fast mode: **$0.04/aktif saniye** (2x, otomatik kalite iyileştirmesi değil, gecikme/kapasite).
- 10 saniye normal: $0.20; 15 saniye $0.30; 30 saniye $0.60; fast: iki katı.
- Bu yalnız sağlayıcı işleme bedelidir; sunucu, vergi, SDK, mağaza komisyonu, ödeme ve destek dahil değildir. Güncel fiyat yeniden doğrulanmalıdır.

**Gelir-kalite modeli:**
- Local Mirror yerel kullanıma açık; cloud sınırlı deneme kredileri/abonelik dahil olabilir.
- Bulut oturumu açılmadan fiyat/tahmini maksimum tutar görünür.
- Oturum seçenekleri 10/15/30 saniye; ısınma veya bağlantı sorunu varsa kaynak tüketim politikası.
- Sağlayıcı kesintisi veya maliyet eşiği aşılırsa bulut otomatik kapatılır, yerel moda geçilir (kullanıcıyı yanıltmadan).
- Başarı KPI'ı yalnız kullanıcının ne kadar süre AI video oynattığı değil, **daha az sürtünmeyle daha doğru satın alma kararı** vermesidir.

---

## 7. GERÇEK ENTEGRASYON MİMARİSİ

```text
[iOS DENE SCREEN]
 ├─ Capture & Scan (AVFoundation/Vision)
 ├─ Product Intake [barcode | image | URL | photo | wardrobe]
 ├─ Product Resolver -> Evidence/Rights/Variant Gate
 ├─ Selection Session (product_variant_id, garment_ref, body_rev, permissions)
 ├─ Local Mirror Provider (RealityKit/Metal)
 └─ Cloud Mirror Provider (Decart Swift SDK) [FEATURE FLAG OFF]
          |             ^
          |             | ephemeral session token only
          v             |
    [Kabinsiz Minimal Token Broker]
       ├─ server-side DECART_API_KEY [secret manager]
       ├─ signed-in user/anonymous abuse gate
       ├─ consent revision + eligibility
       ├─ per-session cost ceiling / rate limit
       ├─ model scope: lucy-vton-3.6
       ├─ maxSessionDuration <= granted budget
       ├─ audit minimal non-biometric metadata
       └─ request short-lived Decart client token
                |
                v
       [Decart realtime media cloud]
```

### 7.1 Güvenli token tasarımı

- Resmî Decart tavsiyesi: **kalıcı API anahtarını hiçbir zaman client'a koyma.** Backend `client token` üretir.
- `expiresIn` ve `maxSessionDuration` birbirinden ayrıdır. Token süresi dolması açık oturumu kapatmaz; ayrıca `maxSessionDuration` gerekir.
- Model whitelist ve fiyat limiti; SDK reconnect durumunda yeni kısa ömürlü token.
- İstemci SDK'sındaki mevcut auth constructor ve token refresh yolu, pinlenmiş SDK sürümünde canlı dokümantasyondan doğrulanır.
- Cloud relay üzerinden ham videonun kendi backend'imize akması gerekmeyebilir; bağlantı biçimi dokümana göre seçilir. Backend üzerinde kişisel görüntü saklanmaması hedeflenir.
- `CitadelGate` / `ConsentLedger` / `EgressIntent` üzerinden açık, geri alınabilir ağ egress izni. Yetki iptal edilirse oturum kesin kapatılır.
- Kamera capture kapandığında video ve uzak oturum stop; arka plan/ekran kilidi/çağrı/ısı/şebeke/uygulama değişimi için ölüm testleri.

### 7.2 Oturum sözleşmeleri

Var olan `MirrorSessionSpec`, `MirrorPolicy`, `MirrorSession`, `FrameGuard`, `MirrorFidelity` yeniden kullanılır. `productVariantID`, `catalogVersion`, `assetRevision`, `bodyProfileRevision` ve oturum numarası tek uçtan uca kimliktir.

Yeni adapter/feature dosyaları önerisi; adlar mevcut Swift target düzenine göre düzeltilir:

```text
apps/ios/Kabinsiz/Features/TryOn/
  TryOnHubView.swift
  ProductInputPicker.swift
  BarcodeCameraView.swift
  ProductIdentityReviewView.swift
  MirrorModePicker.swift
  MirrorStageView.swift
  GarmentSwapSheet.swift
  MirrorTruthBanner.swift
  TryOnSessionViewModel.swift
apps/ios/Kabinsiz/Services/Mirror/
  LocalMirrorProvider.swift
  DecartMirrorAdapter.swift              [gated, disabled by default]
  MirrorCameraCoordinator.swift
  ProductImageReferencePreparer.swift
  CloudSessionTokenClient.swift           [gated]
Packages/KabinsizCore/Sources/TryOnJourney/
  IntakeIntent.swift
  ProductSelectionState.swift
  TryOnJourneyReducer.swift
  ProviderChoicePolicy.swift
  SessionEvidence.swift
services/token-broker/                       [ONLY IF cloud approved]
  POST /v1/mirror/token
  consent-and-budget-gate
  secret-manager-integration
  audit-without-images
```

**Detaylar:** `DecartMirrorAdapter` içine gerçek API çağrısı `#if` değil, test edilebilir dependency injection ve prod feature flag üzerinden kapatılır. Dış sağlayıcı bağımlılığı olmadan local path test edilebilir kalmalı. Bulut servisi erişimi henüz yoksa mock/fake session açıkça `DEMO` olarak kalır.

---

## 8. TEST STRATEJİSİ — 48 ADLANDIRILMIŞ KAPI

| ID | Test / kanıt | Beklenen |
|---|---|---|
| TD-01 | Barcode scan -> verified variant | Aynı ürünü Dene oturumuna geçirir |
| TD-02 | Ambiguous GTIN/SKU | İnsan varyant seçmeden prova yok |
| TD-03 | Unknown barcode | Gerçek SKU gibi göstermez |
| TD-04 | Product image -> candidate | Kaynak/güven gösterilir |
| TD-05 | Product URL parse | Güvenli host/metadata ve hak kontrolü |
| TD-06 | iOS Share Extension | Aynı oturum açılır; iki kez giriş yok |
| TD-07 | User wardrobe item -> Dene | Doğru asset/revision kullanılır |
| TD-08 | Scan camera -> front camera | Eski capture release edilir |
| TD-09 | Camera permission denied | Ürün kartı kullanılabilir |
| TD-10 | Background/lock on local camera | Capture gerçekten kapanır |
| TD-11 | Local mode offline | Gizli bulut çağrısı yok |
| TD-12 | Cloud feature default off | SDK bağlantısı açılamaz |
| TD-13 | Consent not granted | Token üretimi reddedilir |
| TD-14 | Consent revoked mid-session | Uzak oturum stop + egress kapanır |
| TD-15 | Exact product asset missing | Generic demotion/abstain, sahte marka yok |
| TD-16 | Reference brand/logo mismatch | Aynı ürün diye gösterilmez |
| TD-17 | Visual fit != physical size | Karar katmanları bağımsız |
| TD-18 | Size chart missing | Kesin beden uydurulmaz |
| TD-19 | Background persons in frame | Uyarı/mahremiyet kontrolü |
| TD-20 | Camera audio unintended | Ses izni/kanalı varsayılan kapalı |
| TD-21 | Input output train rights unresolved | Cloud gate RED |
| TD-22 | DPA present, no custom terms | Tek başına signed sayılmaz |
| TD-23 | Model licence unknown | Production blocked |
| TD-24 | Token key exposure static scan | Kalıcı anahtar binary'de sıfır |
| TD-25 | Expired client token | Yeni token yoksa bağlantı reddi |
| TD-26 | Client token model scope | Yetkisiz model çağrısı reddi |
| TD-27 | Session budget expiration | Hard stop + usage reconciliation |
| TD-28 | Misstamped frame | Eski varyant videosu gösterilmez |
| TD-29 | Out-of-order video frame | Drop edilir |
| TD-30 | Pose occlusion | Fidelity uyarısı |
| TD-31 | Hair/hand occlusion | Görsel bozukluk gözlemlenir ve raporlanır |
| TD-32 | Full-body distance tracking | Telefon sabitken/eldeyken kontrol |
| TD-33 | Lighting change store | Ayna stabilitesi/kontrast kontrol |
| TD-34 | Dark clothing vs background | Hata/kontrast/fallback |
| TD-35 | Front-camera mirroring | Logo ve yazı ters dönmez |
| TD-36 | Incorrect aspect/rotation | Frame orientation doğru |
| TD-37 | Cloud network dropout | Kullanıcıya bildir, otomatik ücretli geri bağlanma yok |
| TD-38 | Provider unavailable | Local fallback |
| TD-39 | Device thermal critical | Mirror durur, uygulama ayakta |
| TD-40 | VoiceOver action | Tara/Dene baştan sona erişilebilir |
| TD-41 | Dynamic Type / reduced motion | Ekran kullanılabilir |
| TD-42 | iPhone p50/p95 scan latency | Gerçek cihazda ölç ve raporla |
| TD-43 | iPhone p50/p95 camera-to-output latency | Gerçek cihazda ölç ve raporla |
| TD-44 | Garment switching p50/p95 | Gerçek cihazda ölç ve raporla |
| TD-45 | Cloud seconds cost reconciliation | Tahmini-gerçek farkı raporlanır |
| TD-46 | CV/pose no-person/multi-person | Kasıtsız gösterim önlenir |
| TD-47 | Product image rights expired | Oturum fail-closed veya kısıtlı mod |
| TD-48 | Full journey real iPhone screen recording | Kullanıcı onayıyla güvenli kanıt; demo/gerçek ayrılır |

**Çalıştırılmış test sayısı:** Bu doküman yeni testleri TANIMLAR; hiçbirine PASS iddiası yok. Var olan `LiveMirrorTests` ayrı repo kanıtı ile incelenir.

---

## 9. İŞ PAKETİ DAG'I VE TESLİM DİSİPLİNİ

**TD-WP00 (1):** Repo reality baseline. Yeni SHA, mevcut Mirror sözleşmeleri, güncel UI kodu ve test çıktısı.  
**TD-WP01 (2):** ADR — birleşik Dene IA ve eski ekranlardan taşıma/regresyon haritası.  
**TD-WP02 (3):** Product intake sözleşmesi + tek state machine; sahte ürün ve bilinmeyen varyant sınırı.  
**TD-WP03 (4):** `TryOnHubView`, bütün girişleri aynı oturuma bağlayan navigation.  
**TD-WP04 (5):** Kamera barkod/OCR/fotoğraf pilotu, gerçek izin ve AVFoundation yaşam döngüsü.  
**TD-WP05 (6):** Offline test ürün/gerçek haklı asset referans görüntüleri.  
**TD-WP06 (7):** Yerel ayna provider + kamera preview + model overlay (yalnız varlık uygunsa).  
**TD-WP07 (8):** Ürün ve avatar arasında görsel/geometrik ayrım, fit ve source truth banner.  
**TD-WP08 (9):** Giysi swap ve aynı session ID ile geri dönüş, hak ve varyant testleri.  
**TD-WP09 (10):** Paylaşım/ürün URL ve galeri/wardrobe girişleri.  
**TD-WP10 (11):** Gerçek iPhone test/perf/a11y ve yayınlanamaz P0 bulgu kaydı.  
**TD-WP11 (12):** Decart API Terms + DPA + privacy/data transfer + no-training kırmızı çizgi hukuk incelemesi; kullanıcı/şirket yetkilisi onayı beklenir.  
**TD-WP12 (13):** Decart docs MCP/skill kurulumu ve Swift SDK exact sürüm doğrulaması; mümkünse no-secret local build.  
**TD-WP13 (14):** `DecartMirrorAdapter` fake/provider contract testleri (canlı credential gerektirmez).  
**TD-WP14 (15):** SÖZLEŞME ve HARCAMA onayı + server token broker + limited synthetic POC; onay yoksa `BLOCKED_EXTERNAL`.  
**TD-WP15 (16):** Gönüllü/test cihazında video örnekleri, gecikme, doğruluk ve gerçek maliyet ölçümü, mahremiyet red-team.  
**TD-WP16 (17):** Ürün/pilot kapısı; sonucuna göre LOCAL_ONLY / OPTIONAL_CLOUD / PROVIDER_REJECTED kararı.

**Açık sonucun tanımı:**
- `CODED`: kod var.
- `TESTED_SIMULATOR`: simülatör ve test var.
- `DEVICE_VERIFIED`: gerçek cihaz kanıtı var.
- `LEGAL_APPROVED`: hukuk kontrolü ve uygun yazılı belge var.
- `COMMERCIAL_ACCEPTED`: yetkili imza/hesap/hizmet onayı var.
- `CLOUD_PRODUCTION_ELIGIBLE`: tüm gerekli kanıtlar tamam.
- `BLOCKED_EXTERNAL`: eksik hesap, sözleşme, hak veya insan onayı.

Yukarıdaki aşamaları tek `DONE` etiketiyle örtme.

---

## 10. CLAUDE'A DOĞRUDAN YÖNERGE

> Kabinsiz'de ScanView ve LiveMirror artık tek **DENE** ürün yolculuğu olacak. En güncel repoyu denetle; v2.1–v2.5 teknik/veri/güvenlik kararlarını koru; önce offline ve cihaz içi akışı gerçek SwiftUI/RealityKit üzerinde uygula. `MirrorSession`, `MirrorPolicy`, `FrameGuard`, `ConsentLedger`, `CitadelGate`, `EvidenceCoverageGate` tekrar yazılmayacak; uygun adapter'larla yeniden kullanılacak. Yeni `TryOnHubView` ürünün kamera/barkod/fotoğraf/link/dolap girişini tek oturuma bağlamalı, doğru ürün + doğru asset varsa yerel prova göstermeli, kamera izin ve stop döngüsünü doğrulamalı. Resmî `decart-docs` MCP ve Decart Swift SDK sürümünü incele. Şirket adına Decart API şartlarını kabul etme, hesap açma, ödeme yapma, sözleşme imzalama veya gerçek video gönderme. Published API Terms §2.3/§4.2 veri lisansı ve DPA riskini `BLOCKED_EXTERNAL` olarak kaydet; no-training ve mahremiyet özel şartlarını hukuk/onay gereksinimi olarak kullanıcıya sun. Sağlayıcı girişi ancak yetkili insan onayı sonrası, sunucuda saklı key + kısa ömürlü sınırlı client token ile; bulut feature flag varsayılan kapalı. İlk teslimatı çalışan birleşik Dene UI + gerçek cihaz screenshot/screenrecord + test/evidence dosyaları + ticari risk raporu olsun. Başarısız veya engelli olan hiçbir kısmı bitmiş gösterme.

---

## 11. KAYNAKLAR (03.11.2026 KONTROL)

1. Decart VTON realtime: https://docs.platform.decart.ai/models/realtime/virtual-try-on
2. Decart native Swift SDK: https://github.com/DecartAI/decart-ios
3. Decart Coding Agent MCP/Skill: https://docs.platform.decart.ai/getting-started/ai-coding-agents
4. Decart client tokens: https://docs.platform.decart.ai/getting-started/client-tokens
5. Decart API Terms: https://docs.platform.decart.ai/resources/api-terms
6. Decart DPA: https://docs.platform.decart.ai/resources/dpa
7. Decart pricing: https://docs.platform.decart.ai/getting-started/pricing
8. Decart privacy: https://decart.ai/privacy-policy
9. Apple Vision body pose: https://developer.apple.com/documentation/vision/identifying-3d-human-body-poses-in-images
10. Kabinsiz source: https://github.com/gundogandogancan/kabinsiz

**Tüm hakları saklıdır. Bu metin teknik/sözleşmesel kontrol listesidir; avukat görüşü veya sağlayıcının imzalı teklifi değildir.**

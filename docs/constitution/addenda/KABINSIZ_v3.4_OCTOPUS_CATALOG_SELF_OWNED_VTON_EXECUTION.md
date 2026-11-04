# KABİNSİZ v3.4 — AHTAPOT BEYNİ, SÜREKLİ KATALOG VE BAĞIMSIZ CANLI PROVA

**Tür:** Claude Code için bağlayıcı uygulama eki. **Tarih:** 4 Kasım 2026. **Temel:** v3.3 Reality Audit ve v3.2 Master. **Durum:** SPEC / henüz uygulanmadı.

**Doktrin:** Maximum Intelligence, Minimum Interface. Jobs: tek hareket, sonuç. Woz: güçlü, açık ve ölçülmüş mühendislik. Kanıt: `SPEC → DATA RIGHTS → THREAT → CONTRACT → CODE → TEST → DEVICE → PERF → INDEPENDENT REVIEW → EVIDENCE`.

> **Öncelik:** Hukuk, lisans, kullanıcı rızası, gizlilik, kaynak doğruluğu, gerçek cihaz doğrulaması her zaman estetik ve hız iddiasından önce gelir. Kullanıcı yüzü/bedeni/fotoğraf/dolabı merkezi katalogda ASLA bulunmaz. Sadece kamuya açık/izinli ürün verisi merkezi kataloğa alınır. İstek, doküman veya model çıkışı hiçbir zaman kendiliğinden üçüncü taraf sözleşmesi imzalayamaz, ücretli servis açamaz, gerçek kullanıcı verisi gönderemez.

---

## 1. Tek sayfalık gerçek ürün

Kullanıcı görür: `Bugün (kişisel 3D model + hazır kombin + şehir/hava)` / `Dolabım (gerçek kıyafetler)` / `Dene (fotoğraf/GTIN/link → aynada gör)`. Profil sağ üstte. Tek dokunuşla parça değişir. Teknik ajan, indeks, lisans veya API uygulama yüzünde görünmez; yalnız güven, belirsizlik ve izin bilgileri gerektiğinde görünür.

**Gerçeklik seviyeleri birbirinden ayrı:**
- I0 **Bilinmiyor**, I1 **Görsel aday**, I2 **Kullanıcı doğruladı**, I3 **Yetkili GTIN/model/varyant doğrulandı**.
- F0 **Ölçü bilinmiyor**, F1 **markanın beden tablosu**, F2 **bitmiş ürün ölçüleri**, F3 **fiziksel deneme ile kalibre edilmiş öneri**.
- V0 **2D kart**, V1 **tahmini şekilli 3D ürün**, V2 **marka/CAD/ölçüye dayalı 3D ürün**, V3 **gerçek video üstünde AI görsel deneyim**. V3, F3'e eşit değildir.
- `TimeToBarcode`, `TimeToIdentity`, `TimeToOutfitCandidate`, `TimeTo3DPreview`, `TimeToMirrorFirstFrame` ayrı metriklerdir. İlk ikisini hızlı yapmak, son üçünün doğru olduğunu kanıtlamaz.

---

## 2. Üç ayrı güven sınırı, tek Ahtapot mimarisi

```text
[ORTAK KAMUSAL/İZİNLİ ÜRÜN KATALOĞU]     [TELEFONDA ÖZEL KİŞİSEL ZEKA]
Partner CMS / PIM / ERP / Webhook           PhotosPicker / Barkod Kamera / Body Studio
         ↓                                           ↓
License + Feed Registry                    Private Vision & Core ML
         ↓                                           ↓
Ingest → Validate → Identity Graph         Private Wardrobe + StyleDNA + BodyProfile
         ↓                                           ↓
Embeddings + Catalog Index                 Local OctopusCoordinator + CITADEL + Vault
         ↓                                           ↓
Signed catalog delta / product query  →   On-device candidate rerank + product decision
                                                     ↓
                                          3D Avatar + Garment Asset + Local Mirror
                                                     │
                                                 [KULLANICI AÇIKÇA İSTERSE]
                                                     ↓
                                    [Ayrı izinli video/VTON servis sınırı]
                                    İmzalı haklar + veri kontrolü + maliyet bütçesi
```

**Şart:** Repo `Packages/KabinsizCore/Sources/Octopus/OctopusCoordinator.swift`, `SystemContracts/CitadelGate.swift`, `Vault`, `DomainSchemas`, `LiveMirror` yeniden kullanılır. Yeni ikinci koordinatör, ikinci gizlilik mantığı, ikinci beden doğruluğu motoru yazılmaz. Katalog servisi yönetilen arka plan görevleriyle çalışır; iPhone'un 7/24 çalışacağını varsaymaz.

---

## 3. Sürekli öğrenen Katalog Beyni: 9 uzman işçi

| ID | Uzman | Alır | Üretir | Hata/güven sınırı |
|---|---|---|---|---|
| CAT-01 | Partner Connector | Yetkili API/feed/webhook | İmzalı veri paketi | Yetkisiz kaynağı reddet |
| CAT-02 | Catalog Watcher | ETag/revision/manifest | Ürün değişiklik olayı | İzinli sıklık/429 backoff |
| CAT-03 | Identity Resolver | GTIN + brand SKU + varyant | CanonicalProductID | Belirsizse aday, `verified` değil |
| CAT-04 | Taxonomy Normalizer | Marka alanları | Üniversal giysi kategorisi | Orijinal değerleri de koru |
| CAT-05 | Textile/Pattern Reader | Kumaş, care, tech pack | Kaynaklı tekstil/kalıp bilgisi | Fotoğraftan lif yüzdesi uydurma |
| CAT-06 | Media/CAD Rights Guard | Foto, 3D varlık, sözleşme | MediaUsageGrant | Derivative/embedding hakkı yoksa işlem yok |
| CAT-07 | Variation/Stock Watcher | Webhook/stok/satış fiyatı | Varyant bazlı değişiklik | Stok ve beden revizyonlarını ayrıştır |
| CAT-08 | Quality/Conflict Agent | Kaynaklar / sürümler | PASS, QUARANTINE, RETIRED | Çelişkili veriyi üretime sokma |
| CAT-09 | Index Publisher | Onaylı ürün DAG'ı | Sürüm imzalı delta + arama indeksi | Geri alma, TTL, silme, lisans sonu |

**Ajan ≠ 9 büyük dil modeli.** Gerekirse deterministik tipli Swift/Python/TypeScript işlevleri, hafif multimodal model ve yalnız gözden geçirme ajanları. Tek veri gerçekliği `ProductGraph` olacaktır.

### İzleme takvimi
- **Webhook varsa:** olay geldikçe kısa doğrulama ve indeks güncelleme.
- **Günlük:** yeni SKU, stok, fiyat, lisans sonu, silinmiş ürün için delta / feed hash / ETag kontrolleri.
- **Haftalık:** kategori, yeni koleksiyon, beden tablosu, ürün görseli, kumaş ve varyant uyuşmazlıkları.
- **Aylık:** haklar/sözleşme, kapsam, yanlış eşleşmeler, geri çekme, model kayması, lisans değişimi, kalıp sürümü, kalite raporu.
- **Olay bazlı:** katalog revizyonu/recall/yanlış ürün bildirimi → anında invalidate; eski önbellekten yüksek güvenle tavsiye verme.
- Geliştirici bütçesi/partner limitlerine göre frekans uyarlanır. Rastgele gizli scraping, korumalı sayfalara izinsiz erişim, bot/kota engellerini aşma yok. Public sayfadaki bilgi otomatik yeniden dağıtım hakkı sağlamaz.

### Katalog değişim iş hattı
`Pull/Webhook → Verify source rights → Parse schema → GTIN + SKU + color + size normalize → Detect diff → Cross-source evidence → Quarantine conflicts → Generate embeddings/preview only if rights allow → Sign revision manifest → Publish → Device fetch when allowed → TTL/invalidate → Audit.`

### Öğrenme ile eşitleme ayrımı
- **Öğrenme** = daha iyi eşleştirme, hata örnekleri, eşleştirme kalibrasyonu; ancak eğitim izni olan ve yetkili veriyle.
- **İndeksleme** = yeni ürünleri embedding/FTS veritabanına koyma; model eğitimi olmadan da katalog her gün iyileşebilir.
- **Kişisel öğrenme** = yalnız telefonda kullanıcı beğenisi/beden/deneme geri bildirimi; merkezi beyine varsayılan aktarım yok.

### Partner onboarding / veri sözleşmesi
`merchant_id`, `brand_id`, `catalog_revision`, `market`, `gtin_14`, `retailer_sku`, `brand_style_code`, `variant_color`, `variant_size`, `currency`, `price`, `stock_status`, `product_url`, `media_urls`, `media_rights`, `fabric_fibers_pct`, `care_label`, `construction`, `stretch`, `garment_finished_measurements`, `body_size_chart`, `pattern_revision`, `asset_usdz_url`, `asset_license`, `last_verified_at`, `expiry`, `deletion_webhook`.

- Beden tablosu vücut aralığı ile *bitmiş giysi ölçüsünü* ayrı tut.
- GTIN tek başına tüm kumaş/fit/varlık bilgisini vermez; GS1 Verified temel doğrulama içindir; ürün feed'i hak sahibi mağazadan gerekir.
- Pilot 1 ticari ortak + 1 kıyafet kategorisi + 20–50 gerçek varyant. Genişleme ön koşulu gözlenen doğruluk ve hak güvenidir.
- Marka teknik portalı: dosya yükle/API key/OAuth (uygun kimlik/rotasyon), JSON/CSV/XML feed, schema validation, katalog önizleme, test barkodları, eksik alan raporu, revizyon yayını ve geri çekme butonu. Kurum bazlı RBAC ve tenant izolasyonu şart.

---

## 4. Fotoğraflardan cihaz-içi dolap: 8 uzman işçi

| ID | İş | Çıktı |
|---|---|---|
| WAR-01 | PhotosPicker + izin kapsamı | Seçilmiş fotoğraflar; isteğe bağlı kapsamlı arşiv izni |
| WAR-02 | Çoklu giysi segmentation | Tek görselde ayrı giysi maskeleri |
| WAR-03 | Kategori/renk/desen | GarmentCandidate + belirsizlik |
| WAR-04 | Logo/OCR/barkod | Olası marka/model/etiket |
| WAR-05 | Yerel benzerlik + dedup | Aynı giysinin birden fazla fotoğraftaki eşleşmesi |
| WAR-06 | Yerel kullanıcı onayı | OwnedGarment / yanlışları düzelt |
| WAR-07 | Lisanslı garment template locator | V1 yaklaşık 3D / V2 doğrulanmış 3D |
| WAR-08 | Vault/delete | Şifreli kaydet, açıklanabilir kaynak, gerçek silme |

**Sessiz tam galeri taraması yok.** İlk açılışta izin zorlaması yok. Fotoğrafın farklı kişiler içermesi, görünmeyen arka/yan kıyafeti, dar beden ve kumaş oranları kesin tahmin yapılamaz. Fotoğraf yüzü otomatik kimlik tespiti için taranmaz; kişisel avatar fotoğrafları ayrı açık eylem ve düzeltme ile alınır. İsteğe bağlı kullanıcının izniyle toplu tarama, batarya/ısı sınırı ve ilerleme ile yapılabilir.

**Kullanıcı akışı:** `Dolabım → Fotoğraftan ekle → Seç → Cihazda tespit → İncele (kart başına 1 dokunuş) → Onayla → 3D hazır/tahmini/desteklenmiyor etiketi → Ana ekranda kıyafete dokunup değiştir.`

**Kıyafet 3D nesnesi:** Mesh + dikiş silüeti + PBR materyal + UV haritası + gerektiğinde kumaş drape yaklaşımı; fotoğrafı body mesh'e texture yapıştırmak 3D garment sayılmaz. Tek fotoğraf gerçek pattern ve kumaş ağırlığı için yetersiz; garment CAD, çok açı, marka verisi veya kullanıcı düzeltmesi gereklidir.

---

## 5. Kendimize ait VTON: üç basamaklı teknoloji stratejisi

### MIRROR-L1 / Cihaz içi yerel hareketli 3D ayna (ticari MVP)
`AVFoundation → Vision body pose + person segmentation → private avatar/body fit → garment mesh + collision/occlusion → RealityKit/Metal render → camera compositing.`

- Gerçek iPhone'da FPS, frame latency, hareket, örtülme, kıyafet altına gömülme, önden/yan/arkadan dönüş, bel/kol katmanları ve ısınma ölçülür.
- İnce hazır ürün 3D varlığı olmazsa “doğrulanmış ürün videosu” sunma. Gerekirse tahmini AR katmanı etiketi.
- Çok az ağ maliyeti; kapsamlı yerel GPU/ML mühendisliği gerektirir. Live Mirror'da mevcut kıyafetin altında ne olduğunun tam bilgisi her kamerada bulunmaz; gizlenen bölgelerde belirsizlik var.

### MIRROR-L2 / Kendi statik görsel VTON modelimiz
- **Aday**: FASHN VTON v1.5 Apache-2.0 (model repo ve ağırlıklar), ancak tüm alt bileşenler, eğitim verisi, dağıtım, marka görüntüsü ve derleme lisansları ayrıca incelenir.
- Mevcut yayımlanan model ≈1B parametre, ~2 GB weights, CUDA GPU ağırlıklı. iPhone/Core ML/ANE canlı video performansı **kanıtlanmış değildir**. Kendi GPU altyapımızda statik test ayrı özellik olur; kullanıcı özel fotoğrafı kendi cihazında kalmalı kararını delmez. Bu iş için testte yalnız izinli sentetik/veri setleri kullan.
- Quantization/distillation/pruning/low-rank/smaller student araştır; cihaz performansına göre model seç. Gen VTON görüntü = gerçek ölçü/fit kanıtı değil.

### MIRROR-L3 / Bize ait zaman tutarlı video VTON
- Teknik araştırma: pose-conditioned garment warping + temporal stabilization + optical flow + occlusion + consistent identity/face/hair + multi-frame memory + latency budget + GPU/ANE profiling.
- Model/weights **bizim lisansımızla** geliştirilir veya ticari lisans alınır; veri setlerinin eğitim/türev kullanım hakları belgelenir.
- Önce self-hosted izolasyonlu GPU ile yetkili sentetik veri testleri; sonra küçük öğrenci model ile yerel cihaz portu kanıtı. iPhone yerel canlı üretken VTON şimdiden garanti edilmez.
- Benchmark: kullanıcı gerçekten farklı kıyafet giyerken yeni kıyafetin kollarda, gövde kenarında, saç/ellerin üst üste gelişinde ve tam dönüşte tutarlı kalması.

### Decart “bulut araştırma/karşılaştırma” modudur; üretim varsayılanı değil
- Lucy VTON 3.6 Swift SDK erişimi vardır; Decart **kapalı modelinin** ağırlıklarını / iç algoritmasını vermez.
- Resmî API şartları 2026-07-26 §2.3 girdi/çıktı için geniş, süresiz kullanım ve model eğitimi yetkisi içerir; §3.6 yetkisiz tersine mühendisliği ve kota atlatmayı sınırlar. Bu sözleşmeyle **gerçek kullanıcı yüzü/beden videosunu gönderme**. Özel yazılı no-training + saklama/silme/alt işleyen/DPA + kullanım hakları + maliyet ve veri akış sözleşmesi + hukuk review + insan onayı gerekir.
- Kullanıcı özel vücut/dolap verisi buluta hiç yüklenmez. Açık izinli mod varsa bile frame aktarım kapsamı ve sağlayıcı riski ayrıca açıklanır; kullanıcı reddi üzerine tamamen yerel akış devam eder.

### Araştırma lisans listesi
- FASHN VTON v1.5: Apache-2.0; ticari araştırma olanağı var, **statik** VTON, alt bağımlılıklar audit.
- Mobile-VTON 2026: CC BY-NC-SA 4.0; ticari entegrasyon YASAK (ayrı izin yoksa).
- CatVTON: CC BY-NC-SA 4.0; ticari entegrasyon YASAK (ayrı izin yoksa).
- SMPL-X: standart araştırma kullanımındaki kısıtlar nedeniyle ticari mesh/weights izinsiz dağıtma; özgün parametrik mesh veya ticari lisans gerekir.
- 'Replica' UI skill, VTON engine/weights değildir. Kullanıcının gönderdiği repo kodu ve lisansı önce sandbox'ta security review'dan geçsin. Tasarım incelemede kullanılabilir; kapalı servis modelini çıkarmaya çalışmak için değil.

---

## 6. Ücret sınırı: Kimin kuralı, nasıl yürütülecek?

**Decart'ın sabit bir “30 saniye sınırı” yok.** 720p canlı kullanım ~**$0.02/aktif saniye** standart, **$0.04/aktif saniye** hızlı moda çıkabilir (fiyat revizyonu üretime geçmeden tekrar sorgulanır). Bizim `BudgetGuard` varsayılan `cloud_mirror_enabled=false` tutar. 

**Örnek ürün politikası, henüz satın alma kararı değil:**
- Sandbox: gerçek kişisel görüntü gönderme **YOK**, yetkili test varlığı + manuel onay.
- Production beta: hukuk/DPA/teknik gate tamamlanmadan OFF.
- Açıldığında: demo kullanıcısı başına isteğe bağlı 10/15/30 sn paket; paket başlamadan **yaklaşık USD maliyeti**; 1 denemenin max süre ve model türü; şirket günlük/aylık tavanı.
- **Token:** kalıcı API anahtarı yalnız server vault'ta, kısa TTL ve `allowedModels`, `maxSessionDuration`; istemci sadece scope token alır. Tokenın TTL'i aktif oturumu kendi kendine kesmez. Onay/ödeme/kullanım defteri, kötüye kullanım limiti, açık oturumu kapatma ve katı kill-switch gerekir.
- `spent_today + reserved_next > budget` durumunda token dağıtma, servise geçme; asla kullanıcıyı beklenmedik ücretle karşılaştırma.

---

## 7. Claude'un geliştirici araçları, uygulamanın runtime API'leri değildir

| Araç | Kullanım | Güvenlik/gate |
|---|---|---|
| GitHub connector | Commit, PR, kaynak, kanıt | HEAD ve branch korunur; PR üzerinden |
| Figma MCP | Tasarım atomları ve ekran prototipleri | Bağlantı, kullanıcının eylemiyle; görsel ≠ çalışan app |
| MobileBuildMCP / Xcodebuild tooling | Build, simülatör, iPhone, Instruments | gerçek cihaz testi ayrıca |
| Blender MCP | Model/garment USDZ asset pipeline | Python çalıştırabilir: sandbox, sabit klasör, repo script denetimi |
| Decart docs MCP | Kullanım belgesi, SDK şemaları | SDK dokümanı ≠ canlı erişim/kontrat |
| Playwright MCP | Yalnız bize ait test partner portalı | İzinsiz marka crawling yok |
| License/SBOM check | Model ve dataset provenance | her ağırlık sürümü sürüm kaydı |
| Test/Evidence MCP | CI ve kalite raporları | Exit code, gerçek cihaz, benchmark görüntüleri |

Runtime: Apple VisionKit / Vision / Core ML / AVFoundation / RealityKit / Metal / PhotosPicker / Keychain / CryptoKit / WeatherKit; minimal partner catalog API ve dağıtım. Ajanlar kullanıcının ekranında görünmez.

---

## 8. Tek merkeze bağlı ajan kontratı ve güvenlik

Her uzman için `AgentContract(id, inputSchemas, outputSchemas, readScopes, capabilities, latencyBudgetMs, cpuBudget, gpuBudget, networkPolicy, evidenceMinimum, uncertaintyPolicy, fallback, tests, humanReview)`.

**OctopusCoordinator (yerel)** teknik görev grafiği:
`CaptureUserAction → ConsentPolicy → LocalFeatures → CatalogCandidate → EvidenceCoverageGate → ProductIdentity → Size/Fabric → GarmentAsset → AvatarPreview → Recommendation → DecisionEnvelope → UI`.

**CatalogCoordinator (sunucuda)** kamu/izinli kaynak grafiği: `PartnerAuth → FeedCheck → Parse → IdentityGraph → Rights → Quality → IndexPublish → DeviceDelta`.

Ayrı yetkiler, ortak `ProductIdentityV1`, `FabricSpecV1`, `RegionalFitV1`, `VisualTryOnV1` gibi sürümlü sözleşmeler; aynı veriler iki tarafta farklı isimlerle çoğaltılmaz. `CitadelGate` cihazdan çıkışı engeller, partner gateway yalnız **ürün anahtarı** alır, kişinin fotoğrafını/ölçüsünü almaz.

**Cihaz kaynak bütçesi:** tek büyük model GPU'da çalışırken başka ağır task çalışmaz; en yeni istek kazanır; eskisini iptal et; termal baskıda düşük sadakat; memory pressure'da asset cache trim; offline olduğunda son doğrulanmış TTL sınırında göster ve gerekirse unknown.

**Kalite değerlendirmesi:** reviewer ajanı aynı kodu kendisi kabul etmez. Bağımsız product/fit/fashion/vision/security/privacy/QA değerlendirmesi, gerçek marka karşılaştırması, gerçek beden deneme benchmark'ı, hata ve kalibrasyon raporu gerekir.

---

## 9. Ekranların minimalist çalışma sözleşmesi

| Ekran | Varsayılan görünüm | Tek ana eylem | İkincil durum |
|---|---|---|---|
| Splash | Logo, arka planda 3D sahne hazırlanır | Otomatik geçiş | 1 saniye sabit bekleme değil, gerçekten hazır olduğunda sahne |
| Bugün | Giyinmiş 360° kişi, kendi şehir/hava sahnesi | Yeni Kombin | Kıyafete dokununca tek bağlamsal alt sheet |
| Dolabım | Gerçek kıyafetler, foto/kaynak etiketi | Fotoğraftan ekle | Yeni boş dolapta iki açık seçim: Fotoğraf / Barkod |
| Dene | Tek kamera ve ürün seçimi | Tara/Dene | Barkod, foto, web, dolaptan seç kaynakları küçük bir picker |
| Ürün kartı | Doğrulanmış ürün, marka/varyant, varsa görsel | Üzerimde Gör | Ölçü/fit kanıtı ve tahmin ayrı |
| Local Mirror | Canlı kamera ve üstte görsel overlay | Kıyafeti değiştir | Kamera veri izni, hareket/kalite göstergesi; teknik terim yok |
| AI Mirror | Yalnız onaylıysa ve açık izinle | Başlat / Durdur | Süre + yaklaşık maliyet + veri aktarım açıklaması |
| Ben | Kendi yüzü/saçı ve beden modeli | Modelimi düzenle | Ölçü, rıza, verileri sil |

Her ekranda sıfır gereksiz kart, 1 ana eylem, minimal ikincil işlemler. Renk/typography `AtelierTokens/AtelierTypography`; mavi/grinin birincil marka rengi olduğu eski görünüm yok. Logo kullanıcı onaylı bronz sembol. 3D avatarı örten sürekli üst/alt/kemer/çanta listesi yok. Accessiblity Dynamic Type, VoiceOver, Reduce Motion, minimum touch area, high contrast. Karanlık ve yağmurlu sahnede metin daima okunabilir.

---

## 10. Teslim DAG: Bir sprintte bir gerçek kanıt

| İş | Ön koşul | Kullanıcıya etkisi | PASS kanıtı |
|---|---|---|---|
| OCT34-00 | Repo durumu/branch | Kaybolan iş yok | `git status`, HEAD, unpushed branch ve screenshot farkı |
| OCT34-01 | `Octopus`/`DomainSchemas` | Tek doğruluk hattı | Unit graph + permissions tests |
| OCT34-02 | Partner PIM sandbox, 20–50 lisanslı SKU | Barkodda doğru varyant | Gerçek etiketlerle cihaz test tablosu |
| OCT34-03 | Ürün delta/index | Güncellenen koleksiyon | 2 ardışık feed + revizyon ve silme testleri |
| OCT34-04 | PhotosPicker, Core ML | Fotoğraftan dolap | Gerçek fotoğraflar, izinler, dedup + kullanıcı onayı |
| OCT34-05 | Licensed G1 garment asset | 360 kişisel modelde kıyafet | iPhone videosu, üç açı, doğru SKU/fallback |
| OCT34-06 | `AVFoundation/Vision` | Local Mirror | Gerçek iPhone'da eller/örtülme/dönüş test videosu |
| OCT34-07 | Uyumluluk denetimi | Kişiye uygun beden | İnsan giysi denemeleri ile bölgesel fit ölçümü |
| OCT34-08 | Branded minimal UI | 3 adımda deneyim | Figma ile SwiftUI karşılaştırması, a11y |
| OCT34-09 | VTON research sandbox | Bağımsız model fizibilitesi | Lisans SBOM + izinli sentetik benchmark |
| OCT34-10 | Contract/consent/budget | Opsiyonel bulut mode | Yazılı sözleşme, insan onayı, kamera güvenlik testi |
| OCT34-11 | Pilot geribildirimi | Kendini geliştiren sistem | Kör doğruluk, p95, false match, stability, privacy |

Öncelik `OCT34-02` + `OCT34-05` (tek doğrulanmış real product-to-avatar) ve buna paralel `OCT34-04`. Başarıdan önce 100 marka + 1000 ajan iddiası yok.

---

## 11. Gerçek kabul testleri / başarısızlık olarak say

- `CAT-001` Lisanslı webhook ile ürün ekle; 2 cihaz imzalı delta alır, üçüncü cihaz offline son sürümü görür.
- `CAT-002` Dört renkten birini ve iki bedenini okut; yanlış varyant asla `EXACT_VERIFIED` olmaz.
- `CAT-003` Marka eski ürün görselini siler; cihaz hak bitiminde görüntü göstermez.
- `CAT-004` Kopya ürün çakışması; identity conflict quarantine, yanlış ürün yok.
- `CAT-005` API 429 / key revoked / 0 internet; exponential backoff; rate limit aşma yok.
- `CAT-006` Kumaş yüzdeleri toplamı ve kaynak doğrulanır, görselden yüzde çıkarılmaz.
- `WAR-001` Fotoğrafta iki giysi; iki aday; tek fotoğraftaki kişinin yüzü kaydedilmez.
- `WAR-002` 15 fotoğrafta aynı ceketi dedup ile bir kıyafet; kullanıcı ayrıştırabilir.
- `WAR-003` Fotoğraf erişimi reddi; manuel ekleme/barkod çalışır.
- `WAR-004` EXIF, konum, galeri verisi katalog API çağrılarına sızmaz.
- `MIR-001` Kullanıcı kendi giysisini giyerken seçilen ürün doğru bölgeyi takip eder.
- `MIR-002` Eller ve saç yeni kıyafeti gerektiğinde örter; sınır kırpılması raporlanır.
- `MIR-003` Kamera offline; local mirror çalışır; bulut otomatik açılmaz.
- `MIR-004` Ürün değişince stale frame (eski SKU) gösterilmez; session revizyonu doğrulanır.
- `MIR-005` 10–30sn beta bulut oturumu bütçe/izin/TTL olmadan açılamaz.
- `FIT-001` Doğrulanmış kalıp ile F3, tahmini görüntüyle F3 verilmez.
- `UI-001` İlk açılışta düz splash→hazır önizleme→3D: freeze yok, gerçek cihazda trace.
- `UI-002` 3 sekme, 1 CTA, kıyafete tap, erişilebilir alternatif; UI screenshot/golden.
- `SEC-001` Yanlış mağaza key'i başka işletmenin ürününü değiştiremez.
- `SEC-002` Katalog silinme bildirimi/cache lisansı sonu çalışır.

**Ölçülecek hedefler (öngörü, başarı iddiası değil):** yerel barkod okuma p95 <500ms iyi ışıkta; önbellekten exact çözüm p95 <250ms; kullanıcının taramadan ürün kartına uçtan uca p95 <1.5s; hazır garment swap p95 <500ms; local mirror hedef ≥24fps, gerçek cihaz giriş-çıkış gecikmesi p95 ≤150ms. 3D üretim/üretken video ayrı asenkron sınırda; sonuçları cihaz/ışık/kumaş/kategori kırılımında raporla; başarısızsa hedefi revize et, hile yapma.

---

## 12. Kullanıcıya ait tek somut sonraki iş

Claude **önce** repo HEAD, aktif dal ve en son ekran görüntüsünün kodla eşleşmesini raporlar. Ardından şu bir dikey dilimi tamamlar:

> **Gerçek mağaza partner sandbox'ındaki bir GTIN → `EXACT_VERIFIED` varyantı → hakları bilinen gerçek G1 garment mesh'i → kişinin mevcut 360° modelinde doğru ve hızlı görünüm → kısıt/fit etiketi → real-device test.**

Bu uçtan uca dilim başarısızsa: hangi dış veri/hak/hardware eksik olduğunu belgeleyip, eldeki en ileri doğrulanmış alt işlevi teslim eder. Demo veya masalsı plan sonuç değildir. Başka marka kataloğunu yetkisiz tarayarak eksik veriyi kapatmaz.

---

## 13. Kaynak / hak envanteri (Claude üretime almadan yeniden doğrular)

- Decart fiyat: https://docs.platform.decart.ai/getting-started/pricing
- Decart API terms (2026-07-26), §2.3 / §3.6: https://docs.platform.decart.ai/resources/api-terms
- Decart DPA: https://docs.platform.decart.ai/resources/dpa
- Decart Swift SDK: https://github.com/DecartAI/decart-ios
- Decart client token: https://docs.platform.decart.ai/getting-started/client-tokens
- FASHN VTON v1.5: https://github.com/fashn-AI/fashn-vton-1.5
- Mobile-VTON (NC): https://github.com/tmllab/2026_CVPR_Mobile-VTON
- CatVTON (NC): https://github.com/Zheng-Chong/CatVTON
- GS1 Digital Link: https://support.gs1.org/support/solutions/articles/43000729075-what-is-gs1-digital-link-
- GS1 Verified scope: https://support.gs1.org/support/solutions/articles/43000734119-what-information-is-available-in-verified-by-gs1-
- Kabinsiz repo: https://github.com/gundogandogancan/kabinsiz

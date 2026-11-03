# Contract registry (WP15-02)

Kod: `Packages/KabinsizCore/Sources/SystemContracts/`. Testler: `Tests/ContractTests/` (golden JSON `Fixtures/`).

| Sözleşme | Sürüm alanı | Spec | Ne garanti eder | Test |
|---|---|---|---|---|
| `DomainEventV1<P>` | `schema_version` = 1 | §105.1 | snake_case anahtarlar dondurulmuş; tip `a.b.c`; revision ≥ 1; güven 0…1 | golden, `EventAndStateTests` |
| `EntityRevisionGuard` | — | §105.3 | Eski/aynı revizyon ve tekrar eden event reddedilir, durum değişmez | V15-T-ORC-08 |
| `TaskState` | — | §103.1 | Terminal durumlar değişmez | V15-T-ORC-10 |
| `WorkOrder` | `work_order_version` = 1 | §121.1 | Yol kapsamı; LOCAL_SENSITIVE yasak; test teslimi → kabul testi şart | golden, `workOrders` |
| `ModuleRegistry` | — | §104, §112.1 | §104 alanlarının tamamı; varsayılan red; yükseltme API'si yok; LOW tier ağ/yazma alamaz; ağ yalnız HIGH; geçersiz tablo → `denyAll`, çökme yok | V15-T-AGT-01, 03, 04, 05; doküman drift testi |
| `EgressIntent` | `schema_version` = 1 | §112.2 | Açık kullanıcı eylemi şart; amaç ↔ veri sınıfı eşleşmesi; amaç başına alan izin listesi; ASCII alan adı; geçerli DNS adı | egress testleri |
| `EvidenceRecord` | `schema_version` = 1 | §106.2 | Lisans + varyant + doğrulama + geçerlilik yoksa "doğrulanmış" gösterilemez | `evidenceGate` |
| `DeviceBudget` | `schema_version` = 1 | §113.1 | Fizik kapalı; ön planda P0 hep açık; offline/survival ağ yok | `budgets` |
| `DecisionEnvelope<V>` | `schema_version` = 1 | §103 | Durum ↔ değer/hata şekli; hata kendi durumunu taşır; "doğrulanmış" yalnız temiz tamamlanmada, gösterilebilir `EvidenceRecord`'a çözülen ID'lerle (`validate(citing:now:)`) | V15-T-AGT-06 |
| `ConsentLedger` | `ConsentLedger.schemaVersion` = 1 | §112.3 | Sorulmamış = verilmemiş; her değişiklik `version` artırır; her kapsamın geri alma zinciri var | `revocationChains` |
| `CitadelGate` / `CapabilityGrant` / `AuthorizedEgress` | — | §112, §112.2 | Tek ağ yolu; registry + tek kullanımlık süreli grant + rıza; rota allowlist'i; sınıfsız DTO red; tel alanı birebir; `AuthorizedEgress` yalnız kapıdan çıkar | V15-T-SEC-06/07/08, kapı testleri |
| `UntrustedText` | — | §64.2, §112 | Görünmez/yön değiştiren karakter yok, ≤200 karakter; yetkiye dönüşemez | V15-T-SEC-04 |
| `SensitiveAttributeGuard` | — | §61, §112 | Din, etnik köken, sağlık, cinsellik, siyaset anahtarları kasaya yazılamaz | V15-T-SEC-09 |
| `DeletionReceipt` | `schema_version` = 1 | §116.3 | Yalnız sayı ve tür; kayıt ID'si sızamaz (tür adında rakam yok); erişilemeyen kopyalar her zaman listelenir | V15-T-CRY-10 |
| `VaultRecordV1` / `VaultIndex` / `KeyRegistry` | `formatVersion` = 1 | §111.2, §116 | AEAD + bağlı AAD; index commit noktası; anahtar baytı yazdırılmaz | V15-T-CRY-01..05, SEC-10 |
| `FaultCode` | ham değerler donmuş | §103, §113.4 | Kullanıcı mesajı özel veri içermez | `frozenRawValues` |
| `TaskGraph` / `TaskNode` | — | §103 | Benzersiz ID, bilinen bağımlılık, döngü yok, boş yetki yok; seviyeler sırayla, seviye içi eşzamanlı. Düğüm yalnız adını verdiği bağlamı ve üst düğüm çıktısını görür | graph validation, `minimisedInputs`, V15-T-ORC-01 |
| `OctopusCoordinator` | — | §103, §103.1 | Önce tüm düğümler yetkilendirilir (yetki + her bağlam okuması), sonra bütçe; grant her yolda bırakılır; süre/iptal yarışı (modül iptali yok sayarsa terk edilir); yedek → `DEGRADED` + kısıt; devre kesici; latest-wins hattı; anahtarlı birleştirme | V15-T-ORC-01..06, 09 |
| `ResourceGovernor` / `BudgetGovernor` | — | §113 | Öncelik bütçede olmalı; ağ yalnız ağa izin veren katmanda; ağır slot sınırı (P0 hariç) | governor testi |
| `DeviceSignals` / `TierPolicy` / `TierDecision` | — | §113, §113.1 | Yalnız iOS'un verdiği sinyaller (kaba ısı seviyesi, Low Power, bellek uyarısı, kilit, ağ yolu, boş alan); bilinmeyen pil `unavailable` kalır ve TURBO'yu kapatır; her kademe geçerli `DeviceBudget` üretir; ön planda P0 hep açık; neden kodları değer taşımaz; kullanıcı notunda rakam/derece/yüzde yok | `policyTable`, V15-T-DEV-04, `notes` |
| `DeviceResourceGovernor` | — | §113, §113.4 | Düşüş anında, yükseliş 20 s sabit sinyalle (histerezis); düşüşte izin dışı / ağsız / slot fazlası grant'ler geri alınır (en düşük öncelik, en yeni önce), P0 asla; bellek uyarısı yalnız kayıtlı önbellekleri boşaltır; kilitte yeni iş bekler (`untilProtectedDataAvailable`), iptal edilebilir | V15-T-DEV-01..03, 05, 08, 10 |
| `OctopusCoordinator` önleme | — | §113 | Geri alınan run anında durur, `mustComplete` yazı yine iner, sonuç `RESOURCE_DENIED` (asla değer); latest-wins yeni çağrıyı eskinin durmasını bekleyerek başlatır (slot ve yazı sırası) | V15-T-DEV-03, 08 |
| `EphemeralArea` / `EphemeralFile` | — | §116.1, §113.4 | Disk tabanı + bekleyen rezervasyonlar; bilinmeyen boş alanda küçük sınır; kapasite üstü yazı red (`RESOURCE_DENIED`, tekrar denenebilir); yedek dışı; iOS'ta tam koruma; açılışta yetim süpürme | V15-T-DEV-06, drill 2 |
| `BackgroundWindow` | — | §113.4 drill 6 | Süre dolunca iş iptal, checkpoint çalışır, sonuç `stoppedAtCheckpoint`; süreden sonra biten iş tamamlandı sayılmaz | V15-T-DEV-07 |
| `ComputePlanner` | — | §113.4 drill 7 | Yalnız doğrulanmış hesap birimi seçilir; yoksa ya da bütçe ağır işi yasaklıyorsa elle giriş | V15-T-DEV-09 |
| `BodyProfile` | `BodyProfile.schemaVersion` = 1 | §108, §123 | Uzunluk bir kez, 0,1 mm tamsayı olarak saklanır; her değer kaynak etiketli; güvenli aralık + omuz/boy bağı; NaN/∞ reddedilir; her kabul edilen değişiklik yeni revizyon | V15-T-BOD-02, 03, 04 |
| `AvatarSnapshot` / `Silhouette` | kasada `schemaVersion` = 1 | §102.3, §108.3 | Yalnız revizyon + istasyon geometrisi; ölçü değeri, kaynak, yüz/saç yok; monoton eğri, katlanma/sivri uç yok | V15-T-BOD-02, 09 |
| `BodyMesh` / `BodyMesh.Piece` | — (yalnız bellekte; kasaya yazılmaz) | ADR-007, §108 | Yalnız `AvatarSnapshot`'tan, deterministik; 5 genel parça (gövde, 2 bacak, 2 kol), yüz/saç/anatomi yok; her parça kapalı, dışa dönük, sonlu, birim normalli; gövdenin ön yarı genişliği ve bacakların dış kenarı 2D silüete eşit; bel halkasının çevresi kaydırıcı değerine eşit (Ramanujan); 243 uç kombinasyon geçerli ya da önceden reddedilmiş | `BodyMeshTests` (12) |
| `PreviewScene.mesh` | — | ADR-007 §5 | Bütçe 3B izin veriyorsa mesh + 2D siluet birlikte; `2D_CARD` ya da geçersiz mesh → mesh yok, siluet (G0) | `budgetPicksMesh` |
| `ProductIdentityV1` | `schema_version` = 1 | v1.7 §4, §5.2 | GTIN yalnız kanonik GTIN-14 (GS1 mod-10); tam eşleşme kod + kanıt + kontrol zamanı ister; tahmin/çoklu/yok `verified_at` taşıyamaz; `EXACT_VERIFIED` `DISPLAY_FACTS` hakkı ister ve süresi dolunca `BRAND_IDENTIFIABLE`'a düşer; beden etiketi tek başına kimlik değil | `DomainSchemaTests` (golden, `identityRules`, `identityLevels`, GTIN özellik testi) |
| `ProductPhysicalSpecV1` | `schema_version` = 1 | v1.7 §4, §5.4 | Vücut tablosu ve bitmiş giysi ölçüsü ayrı tür; vücutta "düz yarı genişlik" yok; her nokta kaynak kanıtı ister; beden+bölge+boyut başına tek değer; nokta revizyonu spec'ten yeni olamaz | `physicalRules` |
| `FabricSpecV1` | `schema_version` = 1 | v1.7 §4, §6 | Var olan her değerin kanıtı var, olmayanın yok (`evidence_by_attribute` = mevcut alanlar); lif yüzdeleri tekil ve toplam 99–101; köken listesinde fotoğraf tahmini yok (görsel yalnız `visual_appearance_hint`); esneme toparlanması esneme yönü ister; yıkama °C yalnız bakım (0–95) | `fabricProvenance`, `fabricTruth` |
| `BodyProfileV2` + `BodyProfileMigration` | `schema_version` = 2 | v1.7 §4, §123 A.5 | `local_only` false → `EGRESS_BLOCKED`; gerçek ölçü (`measurements`) ile çizim (`avatar_morph_state`) ayrı; foto tahmini yöntem + güven ister ve beden önerisine girmez; onay yoksa önerilen ölçü yok. v1→v2 kaydırıcı/başlangıç değerini asla ölçüye çevirmez; v1→v2→v1 birebir; okuyucu v1 ve v2'yi alır, v3'ü ve fazladan anahtarlı v1'i reddeder | `bodyRules`, `upgradeKeepsShapesOut`, `roundTripProperty` (300), `downgradeEstimate`, `readEitherVersion` |
| `RegionalFitV1` | `schema_version` = 1 | v1.7 §4, §5.7 | Bölge kararı ölçü + kanıt ister; tek beden (`TRY_SIZE`) yalnız her bölge değerlendirildiyse; "kanıtlandı" yalnız her bölge `FIT_EVIDENCE`; kanıtlanmadıysa sınırlama yazılır; `validate(against:)` aynı gövde revizyonu (`STALE_REVISION`) ve yalnız onaylı, elle girilmiş ölçüler | `fitRules`, `fitAgainstBody` |
| `ThermalAdviceV1` | `schema_version` = 1 | v1.7 §4, §6 B | Hava sayısı → hava kanıtı şart; derece aralığı → ölçülmüş termal veri + hava kanıtı + katman önerisi; aralık yoksa metinde rakam/°/% yok; yıkama sıcaklığı yalnız bakım alanı, öneriyi değiştirmez | `thermalRules`, `washIsCareOnly` |
| `VisualTryOnV1` | `schema_version` = 1 | v1.7 §3.2, §5.9 | G0–G3 merdiveni; yalnız G2 doğrulanmış simülasyon; G1+ ürün varlığı revizyonu + lisansı; üretilmiş görüntü yalnız G3; `mayInformSizeAdvice` = false; uygulama katmanları: 2D ve genel mesh → G0, ürün varlığı → G1 | `tryOnRules` |
| `BrandRegistryV1` | `schema_version` = 1 | V18-01.1, V18-04.1 | Marka ≠ sahip ≠ yerel lisans sahibi; lisans sahibi sahipten farklı ve markanın pazarında; kullanıcı/OCR kaynağı (Tier D) marka kaydı olamaz | `registryRules` |
| `CommerceGraphV1` (`Collection`, `StyleModel`, `Colorway`, `SizeVariant` = ProductVariant, `Merchant`, `Offer`, `ClaimEvidence`, `ProductIdentifier`) | `schema_version` = 1 | V18-04.1/.2, R18-WP02 | Tüm referanslar doğru tür düğüme çözülür, ID'ler türler arası tekil; tanımlayıcı ad alanları ayrı (satıcı SKU'su satıcısıyla); bir GTIN / satıcı SKU'su tek varyant; fiyat kuruş + ISO para birimi; "stokta" her zaman bitiş süresi taşır ve süre dolunca `UNKNOWN` okunur; iddia kademesi iddia sahibine eşit; GS1 (Tier C) yalnız kimlik/beden etiketi/renk; fiyat/stok yalnız teklif düğümünde; olgu olarak gösterim yalnız A/B + lisans + aktif + süre içinde; `validate(against:)` her markanın kayıtlı olduğunu denetler | `graphIntegrity`, `offerRules`, `claimRules` |
| `CatalogRightsV1` | `schema_version` = 1 | V18-04.3 | Lisans başına izinli alan kümesi, ülke kapsamı, geçerlilik penceresi, görsel / 3B türev / affiliate / çevrimdışı önbellek hakları, iptal; 3B türev hakkı görsel hakkı olmadan yok | golden, `refusesBadInputs` |
| `EvidenceCoverageGate` | — (girdileri sürümlü) | R18-WP03, V18-04.2/.4, V18-08.1 | Her öznitelik için: `fact` (A/B + lisans kapsamda + süre içinde + kanıt kaydı canlı) / `basicIdentity` (GS1) / `userEvidence` (Tier D) / `synthetic` / `conflicting` (canlı iki kaynak farklı değer → hiçbir şey söylenmez, fit durur) / `blocked(neden)` / `unknown`; varyant, renk ve model düzeyindeki iddialar varyanta iner; kapsama seviyeleri (V18-00.1 + `VERIFIED_BASIC_IDENTITY`), `LIVE_PARTNER` asla veriden türetilmez; teklif `PURCHASABLE / STALE / NOT_VERIFIED`, affiliate yalnız lisansla; lisans/iddia bitince önbellek temizleme ve affiliate kapatma listesi; bozuk girdi → kapı açılmaz | `CoverageGateTests` (V18-T-003, 010, 011, 015, 020, 025) |
| `MirrorSessionSpec` | — (bellek içi; Codable anahtarları snake_case) | LM21-WP03, LM21-10 | Ürün varyantı + `catalogVersion` + varlık/beden revizyonu + mod + süre; yerel 1…1800 sn, rıza ve fiyat taşımaz; bulut 10/15/30 sn, rıza revizyonu ≥ 1 (`CONSENT_MISSING`) ve önceden bilinen fiyat > 0 | `specRules` |
| `MirrorStatus` / `MirrorStateMachine` | ham değerler donuk | LM21-04/07 | `IDLE…FAILED`; sonlu durumlar emici, kamera tutan durumdan çıkış yalnız `STOPPING` + `closed`; yerel mod ön kontrol/bağlantı durumlarına girmez; ilk neden kalıcı | `frozen`, `transitionTable`, `eventStorms` |
| `MirrorFault` / `StopReason` / `DegradeReason` | ham değerler donuk | LM21-06/07 | 12 hata (her biri `FaultCode`a eşlenir, Türkçe kısa metin, sayı yok), 10 durma nedeni, 5 sadeleştirme nedeni (görünür not) | `frozen`, `truthLabels` |
| `MirrorFidelity` | ham değerler donuk | LM21-08, V18 G0–G3 | `CAMERA_ONLY`=G0, `LOCAL_GARMENT_OVERLAY`=G1, `CLOUD_GENERATED`=G3; her biri ekranda doğruluk etiketi taşır; beden önerisine asla girmez | `truthLabels`, `admitBudget` |
| `MirrorPolicy` / `MirrorSession` / `FrameGuard` | — | LM21-WP03, ADR-008 | Kabul: ürün kesin ve aynı kimlik, doğrulama süresi geçerli, katalog revizyonu aynı, bütçe izinli, bulut bayrağı açık (üretimde kapalı); oturum her durma nedeninde sağlayıcıyı tam bir kez kapatır; kare: revizyon, sıra, 0,5/1,5 sn eşikleri | `LiveMirrorTests` (17) |
| `BodyEventPayload` (`DomainEventV1`) | olay `schema_version` = 1 | §105 | Yalnız tür (COMMITTED/DELETED) + parametre adı; değer yok. `BodyProjection` tekrar/eski/sırasız olayları yok sayar, silinmiş gövdeyi diriltmez | V15-T-ORC-07, `eventsCarryNoValues` |
| `BodyStore` / `VaultBodyStore` | — | §111, §116 | `body-profile` (BODY, LOCAL_SENSITIVE) + türetilmiş `avatar-cache`; revizyon yalnız artar; silme zincirleme + makbuz; geçersiz kayıt okunamaz sayılır, üzerine yazılmaz | V15-T-ORC-08, V15-T-BOD-10 |

## Uyumluluk kuralları

1. Yeni sürüm dosyası (`version > current`) okunmaz: `SCHEMA_NEWER`. Eski sürüme yazılıp ezilmez.
2. Bilinmeyen veri sınıfı `UNKNOWN_CLASSIFICATION` ile reddedilir (fail closed).
3. Aynı sürümde bilinmeyen üst düzey alan **reddedilir** (§105.1 "strictly typed"; ek alanla veri kaçırılamaz). Yeni alan = yeni şema sürümü.
4. Ham enum değerleri `Fixtures/frozen_raw_values.json` ile kilitli. Değiştirmek yeni şema sürümü + göç demektir.
5. `ContractCoder.encode` önce doğrular; geçersiz değer diske yazılmaz.
6. Tarihler RFC 3339 + milisaniye yazılır; kesirsiz dosyalar da okunur. `Set` alanları sıralı yazılır (aynı değer = aynı bayt).
7. Her tipin kendi sürüm anahtarı var (`WorkOrder` için `work_order_version`).

## Spec'ten bilinçli sapmalar

- §121.1 örneğindeki `LOCAL_PRIVATE_SCHEMAS` bir veri sınıfı değil, "özel verinin şeması" anlamında bir etiket. `DataClassification` bunu kabul etmez (`UNKNOWN_CLASSIFICATION`); şema üzerinde çalışmak `SYNTHETIC_FIXTURE` + `LOCAL_PRIVATE` ile ifade edilir.
- `EgressIntent` alanları engel listesi değil, amaç başına izin listesi kullanır (review #3).

R17-02 şemaları `Packages/KabinsizCore/Sources/DomainSchemas/` hedefinde (D-020); golden dosyalar `Tests/ContractTests/Fixtures/*_v1.json`, `body_profile_v2.json`, donmuş enum değerleri `frozen_raw_values_r17.json`. İlk göç kapanışı `BodyProfileMigration` (v1 ↔ v2).

Henüz yok: kalıcı event journal / outbox (gerekirse ADR ile); uygulama hâlâ `BodyProfile` v1 yazıyor (V2'ye geçiş R17-05 ile).

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

Henüz yok: kalıcı event journal / outbox (gerekirse ADR ile), göç kapanışları (ilk v2 şemasında).

# KABİNSİZ — GOD LEVEL: ÜRÜN GERÇEKLİĞİ, BEDEN, KUMAŞ VE PROVA MOTORU
## GitHub kod denetimi + Claude Code uygulama emri · v1.6 · 03 Kasım 2026

> **Kaynak repo:** https://github.com/gundogandogancan/kabinsiz
> **Sabit denetim commit'i:** `77e00fff3c831c4bd0e5f6d9acb1a558e6211edd` (`main`, 2026-11-02 23:42 UTC). İlk incelemede `e96f49d` idi; WP15-01/02 commit'i daha sonra `main`'e geldi. Bu belge, **77e00ff** kaynak ağacını esas alır. Başlamadan önce `git fetch` ve `git rev-parse HEAD` ile yeniden kontrol et; `main` değişmişse bulguları yeniden doğrula.
> **Kanonik ürün şartnamesi:** `docs/constitution/WEARFORM_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v1.5.md`. Bu dosya v1.5'i değiştiren serbest bir ürün manifestosu değil; mevcut v1.5'e bağlı, somut bir **repo-odaklı mühendislik ve doğruluk eki**. Daha sıkı güvenlik/mahremiyet yükümlülüğü her zaman önceliklidir.
> **Durum:** Kod okumasına dayalı denetim. Bu incelemede derleme, Swift testleri, iPhone cihaz testleri, kamera, 3D veya canlı partner API'si çalıştırılmadı. Reponun kendi kanıt dosyalarındaki 113/113 testi **repo tarafından raporlanan** bir sonuçtur; bu incelemenin bağımsız test sonucu değildir.

---

# 0. CLAUDE: BAŞLANGIÇ EMRİ

**Kabinsiz'in gerçek kalite eşiği yeni özellik sayısı değil, mağazada karşılaştığı tek bir gerçek ürün hakkında doğru, kaynaklı ve kullanışlı karar üretmesidir.** Senin görevin, var olan repo üzerinde mümkün olan en küçük değişikliklerle aşağıdaki zinciri çalışır ve denetlenebilir kılmak:

**ETİKET/BARKOD → kesin ürün-varyant kimliği → ürün-veri hakları ve kaynağı → kumaş ve fiziksel ürün ölçüleri → kişinin kendi beden ölçüleri/rahatlık tercihleri → bölgesel uyum değerlendirmesi → hava/aktivite/katman tavsiyesi → doğruluk seviyesi belirlenmiş 2D/3D önizleme → anlaşılır, dürüst karar kartı → geri bildirim → kontrollü öğrenme.**

Mevcut iyi davranışları koru: bilinmeyen ürün için tahmin etme, ambigüiteyi sor, sentetik veriyi etiketle, mağaza/marka farkını koru, sponsorlu ürün sonucunu saptırma, rıza olmadan egress yapma, özel ölçüleri mağazaya gönderme. Bir kerede büyük yeniden yazım veya mikroservis yığını kurma. Önce kodu ve testleri çalıştır; sonra kademeli dikey dilimler üret. Sadece testli ve kanıtlı kodu `TESTED`, fiziksel cihazda kanıtlı olanı `DEVICE_VERIFIED` olarak raporla.

**İnsan onayı gerektirenler:** Gerçek müşteri verisi toplama; ürün kataloğu lisansı ve marka sözleşmesi; ücretli API; Apple Developer/PLA; gerçek verilerin cihaz dışına çıkması; ödeme; pilot ve kamuya açılma. İzin olmadığında güvenli mock/fixture yolunda çalış; gerçek veri varmış gibi davranma.

---

# 1. MEVCUT KODUN GERÇEK DURUMU — SATIR İZLENEBİLİR DENETİM

## 1.1 Olumlu, somut mevcut parçalar

- `Packages/KabinsizCore/Sources/ShoppingCopilot/Catalog.swift`: `ProductResolver` tam-kod, tek model veya çoklu renk varyantı ayrımı yapıyor; bilinmeyen ürün `.notFound`, belirsiz ürün `.ambiguous`; sentetik katalog var. Gerçek marka kataloğu **yok**.
- `Packages/KabinsizCore/Sources/FitPassport/SizeAdvisor.swift`: Beden önerisi `abstain/history/likely/chartMatch` ayrımı kullanıyor; geçmiş denemelerin çelişmesi veya birden fazla bedenin uyması durumunda abstain edebiliyor.
- `Packages/KabinsizCore/Sources/FitPassport/FitPassport.swift`: marka, ürün modeli, kategori, beden ve dar/bol bölge gözlemi için veri modeli mevcut. Kullanıcı geri bildirimini saklama altyapısı var.
- `Packages/KabinsizCore/Sources/ShoppingCopilot/DecisionComposer.swift`: 2D görünüş, beden, gardırop benzerliği ve eksik bilgi bir kartta birleşiyor. Sponsorlu etiket fit kararını değiştirmiyor.
- `Packages/KabinsizCore/Sources/SystemContracts/`: `main@77e00ff` içinde `DomainEvent`, `WorkOrder`, `ModuleRegistry`, `EgressIntent`, `DecisionEnvelope`, `EvidenceRecord`, `DeviceBudget`, `FaultCode`, sözleşme sürümlendirmesi mevcut. `WP15-02.yaml` 113 paket testi + 2 iOS simülatör UI testi rapor ediyor.
- `apps/ios/Kabinsiz/Services/AppleWeatherProvider.swift`: izinli egress tasarımına bağlı WeatherKit adaptörü kodlanmış; Apple hesabının lisans onayı gerekmesi nedeniyle canlı çağrılar repo raporunda engelli.
- `docs/evidence/` simülatör görselleri, `docs/product/TRACEABILITY.md` ve `docs/audit/` gerçeklik kayıtları bulunuyor.

## 1.2 P0 — kritik gerçeklik boşlukları

| ID | Kod kanıtı | Bulgu | Şiddet ve kapanış |
|---|---|---|---|
| FIT-01 | `FitPassport/SizeAdvisor.swift` → `UserMeasurements` | Yalnız `chestCm` ve `waistCm` mevcut. Basen/kalça, omuz, kol, uyluk, gövde/bacak boyu, kol boyu ve değiştirilebilir 3D geometri yok. | **P0**: standartlaştırılmış beden profili + kaynağı + düzeltme + şema göçü. |
| FIT-02 | `FitPassport/SizeAdvisor.swift` → `SizeChart.Row` | Yalnız iki **vücut ölçü aralığı** var; fiziksel bitmiş ürün ölçüsü, kumaş esnemesi, kalıp/ease, tolerans ve ürün bedenine özgü kesim yok. | **P0**: beden tablosu ile gerçek ürün ölçüsü ve giyim rahatlık payını ayır. |
| FIT-03 | `SizeAdvisor.advice` | İki uyumlu kayıt aynı marka+kategori içinde, **başka ürün modeli** için de `.likely` sonuç üretebilir (mevcut test `revisionScopedToModel` bunu kabul ediyor). Farklı kesimli/ölçekli model için fazla güçlü iddia olabilir. | **P0**: ürün-model gözlemi / marka-kategori eğilimi / geçmiş bilgisini ayrı güven seviyelerine böl. |
| FIT-04 | `SizeAdvisor.chartMatch` | Verilen bir vücut ölçüsü, karşılaştırılan ürün satırında yoksa sessizce atlanabilir; diğer ölçüye göre tek beden seçilebilir. Eksik kritiklik, uyarı ve kapsam bilgisi yok. | **P0**: bölge bazlı yeterlilik ve kapsam testleri; eksik ölçüyü gizleme. |
| SKU-01 | `ShoppingCopilot/Catalog.swift` | Sadece yerel sentetik kodlar; gerçek GS1/GTIN doğrulaması, marka-model-beden-renk alias çözümü, barkod kamera girişi yok. | **P0**: opt-in kamera barkod + gerçek ürün varyant şeması; yetkisiz katalog kullanılmasın. |
| MAT-01 | `DomainContracts/Garment.swift` → `MaterialClaim` | `warm`, `breathable`, `stretch`, `waterResistant` gibi etiketler; lif bileşimi yüzdesi, gramaj, örgü/dokuma, astar, katman, geçirgenlik, giyim bakım etiketi yok. | **P0**: malzeme/ısıl bilgi kaynak ve belirsizlik modeli. |
| TMP-01 | `TravelEngine/Weather.swift` | `needsWarmLayer` koşulu sabit `low <= 15°C`. Bu yalnızca **kaba katman kuralı**, ürünün hangi derecede rahat giyileceğini kanıtlamaz. | **P0**: çok değişkenli, kalibre edilebilir ve aralıklı konfor tavsiyesi; veri yoksa abstain. |
| VIZ-01 | `apps/ios/.../Profile/MyModelView.swift` | Uygulama açıkça "3D model bu sürümde yok" diyor. Göğüs ve bel form girişi dışında canlı mesh yok. | **P0 çekirdek**: nötr morphable mesh/gerçek cihaz prototipi ve görsel doğruluk ayrımı. |
| SCAN-01 | `apps/ios/.../Scan/ScanView.swift` | Ekranda "Kamera ile tarama bu sürümde yok" yazıyor; sadece kod yazılıyor. | **P0 mağaza deneyimi**: cihazda barkod/OCR; kullanıcıya yanlış eşleşme gösterme. |
| DATA-01 | `LocalStore/LocalStore.swift` | JSON dosyaları atomik + iOS file protection kullanıyor; uygulama düzeyinde CryptoKit vault + Keychain anahtar yaşam döngüsü henüz yok. Repo roadmap'ında WP15-04. | **P0 güvenlik**: vault/anahtar/bozuk veri/göç/silme ve saldırı testleri. |
| QA-01 | `docs/evidence/V13_PROOF_REGISTER.md`, `WP15-02.yaml` | 113 paket testinin geçtiği raporlu; gerçek fiziksel iPhone, gerçek giysi, marka API'si ve fit doğruluk benchmark'ı yok. | **P0 yayın kapısı**: gerçek kullanıcı-ürün eşleşmesi kanıtı yoksa beden uygunluğu vaat edilmesin. |
| OPS-01 | `main` repo ağacı | `.github/workflows` görünmüyor; aktif GitHub CI kanıtı yok. | **P1 öncelikli**: PR build/test, bağımsız kod inceleme, bozuk build'i engelle. |

**Önemli:** `docs/audit/REALITY_BASELINE_v1.3.md` eski başlangıç anını anlatır ve artık son durum değildir. `docs/audit/REALITY_BASELINE_v1.5.md` + WP15-02 dosyaları güncel commit'le eklenmiştir. Repo değiştikçe sabit SHA ile yeniden baz al.

---

# 2. ÜRÜN BİLGİSİ = KAYNAĞI BELLİ DOĞRULANABİLİR İDDİALAR

## 2.1 Her iddia bağımsız kanıt nesnesi

`ProductFact<T> { value, attribute, sourceKind, sourceId, productVariantId, observationTime, effectiveFrom, expiresAt, allowedUses, licenseId, extractionMethod, modelVersion, reviewState, uncertainty, contradictoryEvidenceIDs, evidenceIDs }`.

- `sourceKind` = `BRAND_PARTNER_FEED | BRAND_PUBLIC_AUTHORIZED | GS1_VERIFIED | USER_LABEL_PHOTO | USER_MANUAL | LICENSED_DATA | INFERRED_IMAGE | SYNTHETIC | UNKNOWN`.
- **Doğrulanmış marka verisi** ile **görsel çıkarım** aynı şey değil. Örn. fotoğraftan "keten gibi" algılanması, "%100 keten" demek değildir.
- Markanın ürün ilanındaki "regular fit" iddiası bile kullanıcının üzerinde kesin böyle duracağını kanıtlamaz.
- `licensed` verinin ürün varyantı / bölge / zaman geçerliliği / kullanım izni işlenir. Lisansı bilinmeyen veri otomatik ticari kullanım için kabul edilmez.
- Kaynaklar çelişiyorsa zeki sistem netleşene kadar **kesin iddiayı bloke eder**, en güncel yetkili kaynak lehine sıralar ama kanıtı korur.
- Çıktı: "Marka etiketi: %98 pamuk, %2 elastan" veya "Fotoğraftan tahmin: örme kumaş olabilir; doğrulanmadı".

## 2.2 Ürün kimliği: yanlış ürün, yanlış beden, yanlış prova kabul edilemez

`ProductIdentity` alanları: `{ gtin?, partnerSKU?, modelId, variantId, sizeCode, sizeSystem, colorCode, colorName, brandId, season?, collection?, region?, catalogRevision, identityEvidence }`.

- Barkod GTIN kontrol basamağını doğrula, leading zero koru, GS1 ana-veri çözümlemesini **yetkili/ücretli varsa** kullan. GTIN barkodun içinde kumaş, beden detayları veya fotoğraf taşıdığı anlamına gelmez: o veri dış katalog/ana veri üzerinden gelir.
- GS1 standardına göre boyut/renk varyantları ayrı GTIN gerektirir; bu nedenle "model aynı" diyerek yanlış beden/renk otomatik seçilemez.
- Kameradan GTIN okunamadıysa OCR ile bakım/ürün etiketinin yazısını okuyabilirsin; aynı ürünü kesinleştirmeden fiyat, markanın beden önerisi veya 3D görseli bağlama.
- Alternatif girişler: EAN/UPC/GTIN; mağazanın SKU'su; ürün etiketi fotoğrafı; markanın paylaşılan resmi ürün URL'si; manuel model seçimi.
- Ürün eşleştirmenin **kesin** (`EXACT_VERIFIED`), **kullanıcının onayladığı** (`CONFIRMED_BY_USER`), **aday** (`CANDIDATE`) ve **çözülemedi** (`NO_MATCH`) seviyeleri ayrı.
- Yetkisiz web sayfası kazıma, gümrük/retailer iç API'si istismarı, giriş engeli aşma yok. İş ortaklığı olmadan canlı stok/ürün ölçüsü uydurma yok.

**Harici referans:** GS1 `https://support.gs1.org/support/solutions/articles/43000734083-how-many-gs1-gtins-do-i-need-when-i-have-a-product-with-many-sizes-and-colours-`; `https://support.gs1.org/support/solutions/articles/43000734469-what-kind-of-information-is-linked-to-the-gs1-identification-key-`.

---

# 3. KİŞİSEL BEDEN VE MODALİTE SINIRLARI

- `BodyProfile` yalnız kullanıcı cihazında: `heightCm`, `weightKg` (isteğe bağlı; fit kararı için tek başına yeterli değil), boyun çevresi, omuz genişliği, göğüs/büst, göğüs altı (isteğe bağlı), bel, üst kalça, kalça, pazu, bilek, uyluk, baldır, iç bacak, dış bacak, torso, kol uzunluğu, omuz eğimi, ayak uzunluğu/genişliği; değer/ünite/kaynak/tarih/ölçüm yöntemi/belirsizlik. Gereksiz hassas ölçü isteme.
- Kadın/erkek/cinsiyetsiz vücut varsayımı ile ölçü tahmini yapma; kullanıcı hedeflediği giysi kategorisini ve model görünümünü kendi seçer. Mahrem bölümler örtülü, nötr avatar varsayılan.
- Kullanıcı kaydırıcıyla ölçü değiştirince mesh geometrisi **realtime** değişir; birbirine aykırı veya anatomik olarak olası dışı kombinasyonlar sessizce düzeltilmez, kullanıcıya anlaşılır sınır gösterilir. `undo/redo`, reset ve kaydet/geri al çalışır.
- Fotoğraftan segmentasyon/pivot/pose çıkarımı bir **ölçüm garantisi** değildir. Fotoğraf perspektifi, geniş açı, poz, kıyafet, aydınlatma ve kamera kalibrasyonu belirsizdir. Fotoğraf verisiyle üretilen ölçüler `ESTIMATED` kalır ve kullanıcı düzeltmesi üstün tutulur.
- ISO 8559-1:2017 antropometrik ölçüm tanımları referans alınır; standart metninin lisanslı olmayan tamamını kopyalama. Kaynak: `https://www.iso.org/standard/61686.html`.

### Önerilen beden sözleşmesi

```
BodyMeasurement {
  region: CHEST | WAIST | HIP | SHOULDERS | UPPER_ARM | ...;
  valueCm: Decimal?;
  origin: USER_MEASURED | USER_SLIDER | PHOTO_ESTIMATE | IMPORTED;
  uncertaintyCm: Decimal?;
  measuredAt: ISO8601;
  confirmedByUser: Bool;
}
```

Bir ölçünün güveni diğer ölçülere otomatik taşınmaz. Örn. bel kullanıcının mezurayla ölçümü; kalça fotoğraf tahmini olabilir. Her karar ihtiyacı olan bölgelerin kanıtlarını ayrı kontrol eder.

---

# 4. GERÇEK GİYSİ ÖLÇÜSÜ, KALIP VE FİZİKSEL RAHATLIK PAYI

## 4.1 Üç ayrı bilgi sınıfı

1. **Body size chart:** Markanın önerdiği **insan vücut ölçü aralığı**. Örnek M = bel 80–86 cm. Gerçek giysi bel çevresi buradan çıkarılamaz.
2. **Finished garment dimensions:** Ürünün **kendisi**: bel çevresi/flat measure ×2, kalça, omuz, göğüs, kol evi, iç bacak, uzunluk ve ölçüm toleransı. Ürün ve beden varyantına bağlıdır.
3. **Material/mechanical behavior:** Esneme yönü ve büyüklüğü, geri toparlanma, drape, ağırlık, astar, dikiş/örgü yapısı ve hareket koşullarında hissedilen sıkılık. Fotoğraf bunu güvenilir sayısal değer olarak vermez; marka laboratuvar/üretim verisi veya kalibrasyon gerekir.

**Ease / rahatlık payı:** Aynı anatomik bölgede ve doğru ölçüm konvansiyonunda `finishedGarmentDimension - bodyMeasurement`, fakat tek başına iyi/rahat/uyar sonucu değildir. Giyim hedefi, kesim, destek/gerilim, kumaşın esnekliği, boyut toleransı, hareket ve kullanıcı tercihi önemlidir. Boyut tablosunu `finishedGarmentDimensions` diye kullanmak yasaktır.

## 4.2 Öneri mimarisi

- `SizeEvidenceResolver`: kullanıcının doğru ölçüleri, resmi body-size chart ve bitmiş ürün boyutlarını eşleştirir.
- `RegionalFitEstimator`: boyun, omuz, göğüs, bel, kalça, pazu, uyluk, uzunluk bölgesi için ayrı `TIGHT_RISK / LIKELY_COMFORTABLE / LOOSE_RISK / UNKNOWN` üretir. Her bölge için kanıt ve hata aralığı şart.
- `FitPreferencePolicy`: slim/regular/relaxed, kişi konforu, mevsim, hareket ve katman tercihini uygular; **boyutu farklı göstererek değil** sonuç gerekçesini açıklayarak.
- `HistoryCalibrator`: aynı SKU+model+revizyon+beden gerçek try-on verisine en yüksek önceliği verir; aynı marka-kategoride farklı model gözlemi yalnız zayıf bağlam olarak kalır, kesin `.likely` üretemez; ayrıntılı test yaz.
- `AbstentionGate`: kritik bölgede ölçü yoksa ya da bilgiler çelişiyorsa ``Bedenini güvenilir biçimde belirleyemedim; kabinde şu bölgeyi kontrol et`` gösterir.
- **Hedef:** sistem hangi bedenin *mümkün* olduğunu söyler; kanıt gerekmiyorsa olumlu sonuca zorlanmaz.

## 4.3 Özellikle düzeltilecek mevcut kod

- `SizeAdvisor.chartMatch`: verilmiş kritik ölçünün ürün satırında eksik olması, yanlışlıkla başka bir ölçüye dayanarak kesin `chartMatch` üretmemeli; kısmi eşleşme açık etiketle gösterilmeli.
- `SizeAdvisor.advice`: tek modelde uyumsuz tarih/revizyon/fit kayıtları varken alakasız başka model gözlemleri bu çelişkiyi bastırmamalı. Model düzeyi → marka kategori düzeyi -> genel eğilim farklı statüler.
- `SizeChart.Row`: üst, alt, elbise, ayakkabı gibi ürün tiplerinin temel bölge ihtiyacı ayrı; yalnız chest/waist yetmez.
- `FitObservation`: müşteri deneyiminden bedeni bilinemeyen kalıba "tam oturur" kanıtı geçmez; temporal ve sürüm kapsamı sürdürülür.

---

# 5. KUMAŞ VE HANGİ DERECEDE GİYİLMELİ?

**Kullanıcı isteğindeki "kaç derece" iki ayrı anlam taşır:**

1. **Giyme/konfor:** Hava kaç °C iken uygun? **Bu bir ürün etiketi sabiti değildir.** İnsan metabolizması/aktivite, katmanlar, rüzgâr, nem, güneş, yağış, içeride/dışarıda olma, kişisel sıcaklık duyarlılığı, giysinin izolasyonu ve geçirgenliği etkilidir. Belirsiz hava için kesin "18°C'ye uygundur" deme.
2. **Yıkama/bakım:** 30°C'de yıkanabilir mi? **Bu bakım etiketi talimatıdır.** Fotoğrafta bir sembol okunamadıysa, sırf lif bileşiminden yıkama sıcaklığı uydurma; etiket, üretici dökümanı veya açık kullanıcı doğrulaması gerekir. Bakım ikonlarının güvenli OCR/vision okumasını ayrı test et.

### Fabric Intelligence — `GarmentMaterialProfile`

`fiberComposition[]` (% ve kaynak; toplam doğrulaması); `weaveOrKnit`; `basisWeightGsm?`; `thicknessMm?`; `lining`; `layerCount`; `stretchAxis`; `stretchRecovery?`; `airPermeability?`; `waterVaporResistance?`; `insulationClo?`; `waterResistanceTest?`; `careInstructions`; `labelLanguage`; `sourceEvidence`; `uncertainty`.

**Yanlış çıkarım yasağı:** "%80 pamuk = kesin 20°C" veya "kalın görünüyor = sıcak tutar" yok. Aynı lif bileşimi farklı örgü/gramaj/astar nedeniyle farklı termal davranış gösterir. Bilgi yoksa ürünün termal sınıfı UNKNOWN.

### `ThermalComfortAdvisor` girdileri

- Ürün/katman kombinasyonu; ISO 9920 yaklaşımına göre kullanılabilir ısıl direnç değeri veya açıkça heuristic veri.
- Gün/saat bazında hava sıcaklığı, hissedilen sıcaklık (varsa), rüzgâr, nem, yağış, güneş; kaynağı ve güncellik süresi.
- Aktivite: yavaş yürüyüş, aktif yürüyüş, ayakta bekleme, iç mekân/klima, uzun dış mekân süreleri.
- Kullanıcının "kolay üşürüm / sıcağı severim" gibi **isteğe bağlı** tercihi, sağlık tanısı veya gizli çıkarım yapılmaz.
- Çıktı kesin tek sayı değil `PREFERRED_CONDITIONS`, `LAYER_SUGGESTION`, `OVERHEAT_OR_COLD_RISK`, `INSUFFICIENT_DATA`; gerekçe, ölçü/kanıt seviyesi, sınırlama.

**Bilimsel referans:** ISO 9920:2007 kıyafet takımının izolasyon ve su buharı direncini ele alır; tek ürün için evrensel “doğru sıcaklık” vermez. `https://www.iso.org/standard/39257.html`. Ticari kullanım için lisanslı veri/standart metni erişimi gerektiğinde sağlanmalı.

**Tavsiye örneği (gerçek veri yoksa yalnız şablon):** "Dışarıda rüzgârlı 12–15°C: bu parçanın sıcaklık direnci doğrulanmadı; hafif montu yanında bulundur. Yürüyüş süren uzunsa farklı katman deneyebilirsin." **Asla** sahte yüzdelik doğruluk verme.

---

# 6. KAMERA, FOTOĞRAF, OCR, MULTİMODAL VE 3D ÇIKTI

**Algı adımları bağımsızdır:**

A. `BarcodeReader` (Vision/AVFoundation; kare izni, düşük güç davranışı, aydınlatma ve hareket bulanıklığı) → `ScannedCode`.
B. `GarmentLabelOCR` → kumaş yüzdeleri, ürün modeli, bakım sembolü adayları; dil/karakter/hatalı toplam kuralı; kullanıcı doğrulama UI.
C. `CatalogResolver` → kaynaklı `EXACT_VARIANT` veya kullanıcıya gösterilen adaylar.
D. `ImageGarmentRecognizer` → yalnız tahmini kategori, renk, dokuma ihtimali; ticari kaynak yokken fiziksel ölçüye geçiş yok.
E. `FitDecisionEngine` → biyometrik olmayan kullanıcı onaylı lokal ölçüler + yetkili ürün bilgisi.
F. `VisualTryOn` → sıralı görsellik: `2D_REAL_PRODUCT_PHOTO` → `GENERIC_SILHOUETTE` → `PARTNER_PRODUCT_ASSET` → `VERIFIED_DRAPE_SIMULATION` (son aşama gerçek fiziksel ölçüm ve validasyon ister). Ekran her zaman hangi tier olduğunu gösterir.

**Render/PDF/AI güven:** Fotoğrafı, renk/fabric tahminini gerçek ürün ölçüsüymüş gibi kullanma. Sadece ürün fotoğrafıyla **ürünün kullanıcının üzerinde birebir nasıl duracağını** garanti etme. 3D kumaş simülasyonu ürünün 3D pattern/mesh, malzeme parametreleri, beden, hareket ve çarpışma modelleri olmadan doğru sayılamaz.

**Zaman:** 0.5–2 s yerel barkod çözümü, 1–3 s önbellekteki katalog sonucu, <=5 s adım adım görünür karar kartı **tasarım hedefidir**, ölçülmüş SLA değildir. Gerçek cihazda p50/p95 ölç; ağ başarısızsa kullanıcı hemen ürün kodunu yazıp devam edebilsin. Ağ beklerken 3D yüklemeyi kritik karar zincirinin önüne koyma. Isı/bellek kötüleşirse ağır render kapatılır, deterministik karar korunur.

---

# 7. AHTAPOT UZMAN ZEKÂ SİSTEMİ — GERÇEK MODÜL GÖREVLERİ

Aşağıdaki tabloda **çalışma zamanı modülleri** var. Claude'un kod yazan subagent'leri değildir; tek bir `OctopusOrchestrator` tarafından `WorkOrder → DecisionEnvelope` sözleşmesiyle çağrılır. Hangi modüle hangi verinin verildiği `ModuleRegistry + CapabilityGate` tarafından uygulanır. Bütün ajanlar aynı veritabanına doğrudan yazmaz.

| Modül | Görev | Girdi / çıktı | Ağ / özel veri kuralı |
|---|---|---|---|
| AGENT-01 Identity | Barkod/kod → varyant | GTIN/SKU → ProductIdentity | İzinli katalog isteği; özel vücut verisi YASAK |
| AGENT-02 Catalog Truth | Ürün iddialarının hak/versiyon/kaynak doğrulaması | ProductIdentity → VerifiedFacts | Partner kaynaklarına izinli ağ; özel ölçü YASAK |
| AGENT-03 Textile Composition | Lif yüzdeleri, kumaş/astar doğrulama | etiket/OCR/partner claim → MaterialProfile | OCR cihazda; tam fotoğrafı varsayılan ağ dışına çıkarma |
| AGENT-04 Garment Geometry | Bitmiş giysi ölçüleri / pattern | partner SKU/ölçü → GarmentGeometry | Ürün verileri kamusal; beden gizli |
| AGENT-05 Personal Body | Profil ve sürümlü kullanıcı düzeltmesi | onaylı ölçü → BodyProfile | Tamamen cihazda; erişim minimum |
| AGENT-06 Fit Mechanics | Bölge bazlı ease/sıkılık/uzunluk | BodyProfile + GarmentGeometry → RegionalFit | Tamamen cihazda; eksik bilgilere abstain |
| AGENT-07 Fit History | Gerçek deneme kayıtları | FitPassport → ScopedFitEvidence | Cihazda ve açıkça opt-in |
| AGENT-08 Weather | Konum veya seçilen destinasyon için hava | şehir/hava isteği → WeatherEvidence | Egress allowlist; ham beden bilgisi yok |
| AGENT-09 Thermal | Hangi koşulda neyle giyilir | materyal+hava+aktivite → ComfortAdvice | Cihazda; bilinmeyeni tahmin diye sunma |
| AGENT-10 Care Label | Yıkama ve bakım talimatı | etiket/üretici → CareAdvice | Cihazda, OCR belirsizse kullanıcıya sor |
| AGENT-11 Visual | Gerçeklik seviyesi etiketiyle 3D/2D | body mesh+ürün asset → VisualPreview | Yerelde; gövde varlığı üçüncü tarafa gitmez |
| AGENT-12 Styling | Kullanıcıya yakışma/etkinlik/renk | gardırop+tercihler → StyleExplanation | Yerelde; yaş/kültürden dayatma yok |
| AGENT-13 Shop Decision | Bütün kanıtı tek kartta özetler | upstream envelopes → ProductDecision | Eksik kanıtla net güvenli iddia yok |
| AGENT-14 Feedback | Satın alma/deneme sonrası doğrulama | kullanıcı onayı → FitObservation | Yerelde, iptal/silme/öğrenmeyi kapama |
| AGENT-15 Model QA | Drift, hatalı öneri ve sürüm karşılaştırma | anonim test fixture → EvalReport | Üretim cihazında otomatik kod indirme yok |
| AGENT-16 Guardian | Mahremiyet, kripto, egress, enerji, termal ve log sınırı | WorkOrder/DeviceBudget → allow/deny/degrade | Denetleyici; diğer modüller bypass edemez |

**İletişim kuralı:** Doğrudan çapraz çağrı yerine koordinatör; immutable karar zarfı, kaynak ID, sınırlamalar, zaman aşımı, iptal, veri sınıfı, schemaVersion ve idempotency key. Model/heuristic her yerde zorunlu değildir; matematiksel ve kural tabanlı güvenilir çözüm önce gelir.

**Öğrenme:** Kişisel Fit Passport güncellemesi cihazda; model güncellemesi imzalı/versiyonlu/rollout ve geri alma kapısından; kaynak kuralı değiştirme yalnız yeni release ile. Devamlı öğrenme = kullanıcının gerçek geri bildiriminden doğrulanmış parametre iyileşmesi; **kendi kendine doğrulanmamış iddialar üretme değil**.

---

# 8. GÜVENLİK, KRİPTO, CİHAZ SAĞLIĞI

- `EgressIntent` yalnız deklarasyon katmanıdır; `WP15-03` çalışma zamanı ağ kapısı uygulanana kadar ürün katalog/özel veri akışı tasarım olarak korunuyor sayılamaz. Testlerde ağ istemcisinin kapı dışından çağrı yapamadığını göster.
- `WP15-04`: CryptoKit authenticated encryption + Keychain anahtar erişimi; file protection, göç ve eski JSON temizleme; yedekleme/restore seçenekleri net, anahtar kaybına davranış testli. Secure Enclave anahtar sınırlarını doğrula; büyük veriyi Secure Enclave içine depolama vaadi verme.
- Fotoğraf arşivini varsayılan topluca tarama. Kullanıcı explicit library picker/izin, kapsamlı seçim, ilerleme ve anlık iptal; tasnif yerel; EXIF hassas meta verileri temizle.
- DeviceGovernor gerçek `ProcessInfo.thermalState`, `isLowPowerModeEnabled`, bellek uyarısı, foreground/background, 3D bütçe, uzun kamera oturumu kapatma. Termal yükselince önce görsel kaliteyi azalt; katalog kimliği, beden/etiket doğruluğunu feda etme.
- Hata metriklerinde fotoğraf, ölçü, cinsel/bedensel detay veya ham OCR yok. Crash analytics kapalı veya minimum ve açık kullanıcı kontrolünde.
- Sahte/bozulmuş partner katalog payload'ı, aşırı büyük resim, prompt injection içeren ürün açıklaması, zararlı URL, tekrar edilen barkod, stale cache ve kurcalanmış model dosyası negatif test şart.

---

# 9. DENETLENEBİLİR DİKEY DİLİMLER — GERÇEK İŞ SIRASI

**v1.5'teki `WP15-03/04/05/06/07/08` güvenlik/avatar önceliğini bozma.** Sonraki ürün-dikey dilimleri aşağıdaki sırada.

| Sıra | Paket | Teslim | Kabul kanıtı |
|---|---|---|---|
| 0 | REPO-00 | HEAD/branch/tüm target/test baseline, no assumptions | `git rev-parse`, Swift test exit 0, Xcode simulator build/test; CI yoksa açık rapor |
| 1 | CORE-SEC | WP15-03/04/05/06 + depolama/egress/koordinatör | consent deny, runtime egress deny, encrypted store tamper/migration, device budget tests |
| 2 | BODY-3D | WP15-07/08: beden profil + mesh morph + kalıcı slider | canlı bel/omuz/basen; screen recording + coordinate checks + simulator + gerçek cihaz engel etiketi |
| 3 | CAT-IDENT | Yetkili katalog adaptörü, GTIN varyant şeması, kamera kod çözücü | code checksum, multi-size multi-color, unknown, ambiguous, duplicate, wrong-brand negatif testleri |
| 4 | FABRIC-TRUTH | Lif bileşimi, bakım sembolleri, malzeme ve kaynak | exact label vs OCR guess vs unknown, 100% total, bakım sembolü belirsizliği, lisans koruması |
| 5 | FIT-TRUTH | Ürün ölçüleri + body chart farkı + regional fit; Fit Passport kalibrasyonu | her bölge için kanıt/caps; farklı modelde aşırı güven engeli; person-sized fixture testleri |
| 6 | THERMAL | Aktivite/katman/hava ve giyme sıcaklığı tavsiyesi | soğuk/sıcak/rüzgâr/yağış/unknown; yıkama sıcaklığına yanlış geçiş yok |
| 7 | SHOP-CARD | 2 saniye progressive UI; 3D tier/beden/konfor/etiket/kaynak kartı | visual + a11y, network off, stale data, sponsorship neutrality |
| 8 | LAB-REAL | Fiziksel ürün/insan ölçü validasyonu ve regresyon | ön kayıtlı pilot protokol, ayrı demografiler/boyutlar; uzman ölçü kanıtı, kalibrasyon, öneri reddetme metriği |
| 9 | LIVE-PILOT | Üretici anlaşması, gerçek mağaza ölçümü | rıza, veri hakkı, stok şartı, bekleme süresi, yanlış öneri/return/fit feedback; kontrol grubu |

**Karar:** Seyahat, günlük stil ve geniş marka kataloğu mevcut koddan silinmez fakat yeni özellik yükü olarak `FIT-TRUTH` ve `FABRIC-TRUTH` kapıları geçilmeden öne alınmaz.

---

# 10. ZORUNLU TEST MATRİSİ — YALANCI İSABET YASAK

## 10.1 Ürün tanıma

- `T-KAB-PROD-001`: GTIN varyantları renge göre ayrı; diğer rengin fotoğrafı otomatik gelmez.
- `002`: aynı modelin S/M/L beden GTIN'leri ayrı, beden karışmaz.
- `003`: yanlış veya kontrol basamağı bozuk GTIN reddedilir, kullanıcıya manuel yol.
- `004`: bilinmeyen ürün için uydurma katalog/uygun beden yok.
- `005`: QR/web URL enjeksiyonu/taklit marka uyarısı ve güvenli URL parse.
- `006`: katalog revizyonu/geri çekilmesi eski beden iddiasını bloke eder.
- `007`: genel ürün bilgisi ile ölçüye özel iddia kaynakları ayrı.

## 10.2 Ölçü ve fit

- `T-KAB-FIT-001`: bel, kalça, omuz, pazu ve iç bacak ölçüleri ayrı girilir/round-trip eder.
- `002`: eksik kalça ölçüsü olan pantolon için kalçanın uygunluğu uydurulmaz.
- `003`: örnek beden tablosu göğüs verir ama bel satırı yok; kritik bel verisi sessizce atlanmaz.
- `004`: body-size chart bitmiş ürün ölçüsüymüş gibi ease hesaplamasına giremez.
- `005`: bir markanın slim jeans fit geçmişi aynı markanın relaxed jean'ine kesin beden önerisi taşımaz.
- `006`: ürün özelindeki iki çelişkili deneme verisi diğer modelden gelen geçmişle bastırılamaz.
- `007`: fotoğraf tahmini mezura ölçümünden üstün değildir.
- `008`: sentetik/izin belirsiz kaynakla verified confidence üretilemez.
- `009`: dar/bol riski bölge bazında gösterilir; fotoğraf 3D doğruluğu için fit yüzdesi sunulmaz.

## 10.3 Tekstil ve sıcaklık

- `T-KAB-MAT-001`: %95 pamuk + %5 elastan etiketi kaynağıyla saklanır.
- `002`: %70 pamuk + %40 polyester hatalı toplam için doğrulama ister.
- `003`: görüntüden "keten gibi" tahmini "%100 keten" iddiasına dönüşmez.
- `004`: ürünün izolasyonu yoksa 12°C'ye uygundur şeklinde kesin çıkarım yok.
- `005`: iç mekân ısısı ile dış mekân ısısı ve hareket ayrı değerlendirilir.
- `006`: gerçek hava yoksa hava tavsiyesi tahmin diye etiketlenmez.
- `007`: 30°C yıkama önerisi yalnız doğrulanmış bakım etiketi/üretici kaynağından gelir.
- `008`: kullanıcı 15°C'de kolay üşüdüğünü bildirirse sadece kendi cihazında tercihler güncellenir.

## 10.4 Güvenlik ve cihaz

- `T-KAB-SEC-001`: marka katalog isteği body profile, photo, raw measurements taşımıyor.
- `002`: egress kapısı devreden çıkarsa ağ otomatik reddedilir.
- `003`: vault yazılırken cihaz kapanırsa ya eski ya yeni geçerli kayıt vardır; plaintext kalıntı yok.
- `004`: dosya bozulması eski profili sessizce sıfırlamaz.
- `005`: thermal serious/critical değerinde avatar LOD düşer; kod/ölçü kararı deterministik kalır.
- `006`: iptal sonrası fotoğraf tarayıcı ham fotoğrafı veya background işini sürdürmez.
- `007`: model güncellemesi imzasız, rollback'siz veya yetkisizse yüklenmez.

## 10.5 Gerçek dünya kabul deneyleri

- Benzer siluetli fakat farklı kesimli ürünler; farklı beden sistemleri ve ölçü konvansiyonları; kumaş esnemesi; stok/etiket uyumsuzluğu; aydınlatma/kamera kalite farkları.
- Fit label ground truth gerçek try-on sonrası **kişinin onayı ve ölçü çizelgesi** ile alınır; tek kişinin tercihi tüm kullanıcıların bedensel gerçekliği olarak sunulmaz.
- Önceden kaydedilmiş holdout, blinding, bağımsız tekstil/modelist uzmanı ve istatistiksel güven aralıkları gerekir. Sadece top-1 beden doğruluğunu değil **yanlış güvenli öneri oranı**, abstention coverage, bölgesel fit precision, ambigüite, geri gönderim, bekleme süresi, pil/termal ve gelir etkisini ölç.
- Hedef eşikler deney öncesi yazılır; eşiğe göre veri seçme, eşik düşürme veya başarısızlığı gizleme yok.

---

# 11. KULLANICIYA TEK EKRANDA GÖSTERİLECEK GERÇEK ÇIKTI

> **Ürün:** [Marka] [Model] [Renk] [Beden] — Kaynak: marka kataloğu [tarih] / kullanıcı fotoğrafı [inceleme]
>
> **Kumaş:** [doğrulanmış bileşim] — bilinmiyorsa "Etiket bilgisi yok".
>
> **Beden:** [Öneri yok / Aday M / M-L karşılaştır] — bölge: bel [veri], kalça [eksik], omuz [uygun aralık] + açıklama.
>
> **Giyim koşulları:** [hava + katman + aktivite / veri yetersiz]. Bakım ayrı: "Yıkama: etiketten doğrulanmadı".
>
> **Üzerimde nasıl durur:** [2D ürün fotoğrafı / genel model / gerçek 3D varlık] — görsellik etiketli; "birebir" vaadi yok.
>
> **Karar:** [Denemeye değer / Önce ölçü kontrolü / Kabinde dene] — en çok üç kaynaklı gerekçe. Sponsorluysa sponsor etiketi ayrıca.

Bu tasarım gerçek kullanıcı etkileşimi görmeden **nihai kullanıcı ekranı olarak onaylanmaz**; ilk iOS denemesinde test edilir.

---

# 12. UZMANLARIN TESLİM SORUMLULUKLARI VE BAĞIMSIZ KAPILAR

Bu uzmanlıkları `.claude/agents` içindeki mevcut rollerle eşleştir; eksik olan AG-06 (Fit Science), AG-07 (Styling), AG-08 (Retail Data) ve AG-11 (Perf/SRE) için birbirinden farklı test/denetim yetkilerine sahip ajan kartları yarat. Hiçbir uzman kendi kodunu son onay makamı olarak kullanmasın.

- **Fit Scientist / Modelist:** antropometri standardı, body chart vs garment measurement, ease, esneme, kesim, hareket ve kalıp validasyonu; bölgesel fit testlerini yazar.
- **Textile Engineer:** kumaş lifleri, gramaj, katman, drape, ısıl direnç/nefes alma, etiket ve bakım talimatının sınırlamaları; ölçü ve source provenance denetler.
- **Data Rights / Brand Specialist:** GTIN, partner SKU, marka kaynakları, lisans/uyarlama, sürüm, veri tazeliği, ambigüite ve veri geri çekme.
- **CV/On-Device ML Engineer:** barkod, OCR, kalite, offline kaynak kullanımı, sınırlı model ve gerçeği uydurmayan tahmin.
- **iOS / RealityKit / Blender Engineer:** nötr morph mesh, UI render, fiziksel ürün mesh'i gelmeden simülasyon iddiası yok; cihaz performansı.
- **Privacy/Cryptography Auditor:** fotoğraf/beden egress kontrolü, şifreli depolama, model tedarik zinciri ve silme.
- **Independent QA/Red Team:** testleri ve gerçek sonuçları bağımsız denetler; çevresel/markasal karşı örnekler; STOP_THE_LINE yetkisi.
- **Commercial Pilot Lead:** mağazada kaç kişi yanlış beden aldığı, bekleme ve dönüşüm; etik iş ortaklığı ve sınırlı veri.

Bir feature için açık `OWNER → INVARIANT → CODE → NEGATIVE TEST → BENCHMARK → REVIEWER → EVIDENCE → ROLLBACK` eşlemesi yoksa o feature **tamam değil**.

---

# 13. KARAR VERME REHBERİ / STOP-THE-LINE

- Ürün kimliği belirsizse **ürün bazlı beden ya da görüntü gösterme**.
- Resmi katalog olmayan ürün için yetkili marka iddiası üretme.
- Body size chart'tan sanki giysinin gerçek çevresi biliniyormuş gibi gerilim/ease hesaplama.
- Kumaşı fotoğraftan kesin yüzdeyle söyleme.
- Evrenin her kentinde, her kullanıcı için tek giysinin tam giyilme sıcaklığı olduğunu iddia etme.
- Isıtılmış telefon/bozuk ağ koşullarında modeli zorlayıp batarya ve veriyi tehlikeye atma.
- 3D görselin gerçekçi görünüşünü fit doğruluğu olarak raporlama.
- Gerçek cihaz ve gerçek ürün deneyleri olmadan "GOD LEVEL", "retail ready", "garantili beden" veya "kabin yok" ticari iddiası üretme.

**Tamamlanan ilk kullanılabilir dikey dilim tanımı:** Bir fiziksel ürünün yetkili 1 marka kataloğunda doğrulanmış GTIN varyantı, gerçek kumaş ve beden ölçüleri + kullanıcı onaylı yerel beden profili → bölge bazında temkinli ve kaynaklı öneri; hava verisi varsa katman önerisi; veri eksikse dürüst sınırlama; 2D/3D tier şeffaf; gerçek cihazda zamanı, pil maliyeti ve güvenliği ölçülmüş. Bu standardı kanıtla, sonra katalog genişlet.

**İlk Claude yanıtı zorunlu:** HEAD/branch; değişen dosya listesi; mevcut test kanıtı (çalıştırıldıysa komut+exit+adet); FIT-01/02/03/04, MAT-01, TMP-01, SKU-01 açıkları; sonraki tek en değerli iş; blokaj; risk; kabul testi; bağımsız reviewer. Ardından sürücü geliştirme döngüsüne geç. Kullanıcı istemedikçe `main` dalına doğrudan yazma veya mağaza anlaşması başlatma.

---

## Kaynak URL'leri (erişim tarihi 2026-11-03)

- Repo: https://github.com/gundogandogancan/kabinsiz/tree/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd
- FIT: https://github.com/gundogandogancan/kabinsiz/blob/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd/Packages/KabinsizCore/Sources/FitPassport/SizeAdvisor.swift
- Material: https://github.com/gundogandogancan/kabinsiz/blob/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd/Packages/KabinsizCore/Sources/DomainContracts/Garment.swift
- Catalog: https://github.com/gundogandogancan/kabinsiz/blob/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd/Packages/KabinsizCore/Sources/ShoppingCopilot/Catalog.swift
- UI: https://github.com/gundogandogancan/kabinsiz/blob/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd/apps/ios/Kabinsiz/Features/Scan/ScanView.swift
- Evidence: https://github.com/gundogandogancan/kabinsiz/blob/77e00fff3c831c4bd0e5f6d9acb1a558e6211edd/docs/evidence/WP15-02.yaml
- ISO antropometri: https://www.iso.org/standard/61686.html
- ISO termal: https://www.iso.org/standard/39257.html
- GS1 GTIN: https://support.gs1.org/support/solutions/articles/43000734083-how-many-gs1-gtins-do-i-need-when-i-have-a-product-with-many-sizes-and-colours-

**Bu dosya Claude'a mühendislik emri ve denetim planı verir; henüz geliştirildi/çalıştırıldı/başardı demek değildir.**

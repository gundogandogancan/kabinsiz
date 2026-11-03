# KABİNSİZ — GOD LEVEL v1.8
## UNIVERSAL BRAND NETWORK · SHOPPING OUTFIT INTELLIGENCE · COMMERCE WITHOUT COMPROMISE
### Claude Code için uygulanabilir ürün, yapay zekâ, veri, güvenlik, perakende ve ticari sistem şartnamesi
**Tarih:** 03.11.2026  
**Durum:** `SPECIFICATION_ONLY` — bu dosya yazılması, hiçbir özelliğin canlı ortamda çalıştığının kanıtı değildir.  
**Repo:** `https://github.com/gundogandogancan/kabinsiz` · İnceleme dayanağı `main@77e00fff3c831c4bd0e5f6d9acb1a558e6211edd`. Claude çalışmaya başlarken HEAD yeniden doğrulanmalıdır.

> **SÜRÜM KURALI:** Bu belge v1.7 ana şartnamesinin **ekidir**, eski sürümü silmez. v1.5 §§0–135, v1.6 ve v1.7 yürürlükte kalır. Hukuk, platform şartları, mahremiyet, fail-closed ürün doğruluğu ve kullanıcı rızası önceliklidir. v1.8, *çok markalı katalog*, *alışveriş esnasında gerçek kombin önerisi* ve *etik gelir* konularında daha somut uygulama sözleşmesidir. Eski uygulama iş paketlerinin P0 güvenlik/3D sırasını atlama; mevcut `ShoppingGuard`, `DecisionComposer`, `ProductResolver`, `FitPassport`, `SystemContracts` ve `EgressIntent` yapılarını yeniden kullan.

---

# V18-00 — ÜST HEDEF: BÜTÜN MARKALARI DESTEKLEYEBİLEN ALTYAPI, DOĞRULANMIŞ ÜRÜN KAPSAMI

**Kullanıcının nihai beklentisi:** Türkiye'de mağazası veya yetkili satışı olan bütün giyim markalarından bir ürünü tarayabilmek; ardından küresel pazarda yoğun satılan markaların ürünlerini tanımak; kendi bedenine, dolabına, ortamına ve bütçesine göre o ürünle *tam bir kombin* görebilmek ve isterse eksik parçaları satın alabilmek. Bunun en hızlı kısmı iPhone'da yerel olarak çalışacak; izinli katalog, fiyat, stok ve sipariş/affiliate gibi kamusal ticari bilgiler gerektiğinde dar kapsamlı ağ servisinden gelecek.

**Çok önemli dürüstlük eşiği:** “Bütün markaları destekler” = *sistemin mimari olarak marka sınırı olmaması*; “bütün markaların bütün ürünlerini ve doğru ölçülerini bugün biliyor” demek değildir. Ürün bazında kaynak/izin/kalite yoksa `UNKNOWN`, kullanıcıdan etiket, marka/model, ölçü eklemesi veya mağaza/barkod kaynağı doğrulaması iste. Başka ürünün verisini sessizce ikame etme. Bütün markalara ait veri veya ticari yetki elde edilmedikçe **evrensel katalog iddiası yayınlama**.

## V18-00.1 Başarı ifadeleri ve yayın iddiaları

- `UNIVERSAL_SCHEMA_SUPPORTED`: marka bağımsız veri modelinin çalıştığı testle kanıtlanmış.
- `BRAND_IDENTIFIABLE`: marka adı ve ürün kodu görülebiliyor; doğru varyant / gerçek beden bilgisi garantisi yok.
- `VARIANT_VERIFIED`: tam marka/model/renk/beden ürün kimliği kaynakla doğrulanmış.
- `FIT_ELIGIBLE`: yeterli beden + bitmiş giysi ölçüsü / geçerli tablo + tercih bilgisi var.
- `TRYON_ASSET_READY`: bu varyanta karşılık gelen yetkili 3D varlık / parametreli model mevcut.
- `COMMERCE_ELIGIBLE`: satıcı teklifinin fiyat/stok/link/komisyon kullanım hakları doğrulanmış.
- `LIVE_PARTNER`: sözleşmesi ve saha testi olan gerçek ortak.

Tek marka bu seviyelerin hepsinde olabilir, başka marka yalnız `BRAND_IDENTIFIABLE` olabilir. UI bu ayrımı gizlemez. Her marka ve ürün için kapsama matrisi otomatik oluşturulacak.

# V18-01 — MARKA KAPSAMI: TÜRKİYE + KÜRESEL PAZAR

## V18-01.1 Türkiye'den başlayan genişleme havuzu (ortaklık veya canlı veri iddiası değildir)

- Yerli/geniş ölçek: **LC Waikiki, DeFacto, Koton, Mavi, Boyner, FLO, Colin's, LTB, Penti, İpekyol, Kiğılı, Altınyıldız Classics, Network, Vakko, Beymen**.
- Türkiye'de faaliyet gösteren/dağıtılan uluslararası örnekler: **Zara, H&M, Mango, Levi's, Jack & Jones, Nike, Adidas, Puma, Calvin Klein, Tommy Hilfiger, Hugo Boss**.
- Genişleme kategorileri: lüks / premium / hızlı moda / denim / spor / ayakkabı / çocuk / modest / büyük beden / outdoor / iç giyim / aksesuar. Her kategori kendi ölçü ve ürün özellikleri sözlüğüne sahip olacak.
- Örnek marka listesi *tamamlanmış envanter* veya onaylı partner listesi değildir. Gerçek marka, mağaza, marka sahibi, distribütör, çok markalı satıcı, e-ticaret mağazası ve ülke pazar varlığı için `BrandRegistry` yetkili kaynaktan güncellenecek. Marka adını tekil sanma: marka sahibi / yerel lisans sahibi / satıcı / ürün üreticisi / sezon ilişkileri ayrı tutulacak.

## V18-01.2 Küresel katman

Ülkeye göre `Market=TR, EU, UK, US, ...`, para birimi, dil, ülke özel varyant, fiyat, vergi sunumu, iade ve bağlantı politikası. Global önceliklendirme “en çok satıyor” sözünü kanıtsız popülerlik sırasına dönüştürmesin. Yıllık ciro, GMV, kategori payı, doğrulanmış talep, katalog lisansı alma imkânı, yerel mağaza yaygınlığı ve test verisi bulunabilirliğine göre **kaynaklı bölgesel puanlama** yapılsın. Veri yoksa “ranking UNKNOWN”. Örnek araştırma havuzu: Inditex/Zara, H&M, Uniqlo, Nike, Adidas, Gap, Levi's, Puma, New Balance, Lululemon, Primark; hiçbirinin Kabinsiz partneri veya erişilebilir API'si olduğu varsayılmasın.

## V18-01.3 “Tüm marka” için beşli fallback

1. Partnerin imzalı SKU/variant feed'i → tam detay.
2. Yetkili pazaryeri / katalog sağlayıcısı → kaynak kapsamındaki detay.
3. GS1 ve hukuken erişilebilir temel ürün tanımları → kimlik seviyesinde kısmi sonuç. **GS1 tek başına giysi ölçüleri, kumaş veya canlı stok sağlamaz**.
4. Fotoğraf / etiket OCR + kullanıcı teyidi → tahmin etiketi, hiçbir zaman otomatik doğrulanmış ürün ölçüsü değil.
5. Hiç veri yoksa → kullanıcının seçtiği ürün türü/renk ve kendi dolabıyla *genel stil önerisi*; beden garantisi veya gerçek ürün simülasyonu yok.

Her fallback, ürünün **gerçek** verisiyle **stil ilhamını** birbirinden açıkça ayırır.

# V18-02 — ALIŞVERİŞ SIRASINDA 15 SANİYELİK KULLANICI DENEYİMİ

Kullanıcı mağazada bir ürün etiketini tarar:

1. **Tara:** On-device VisionKit/Vision barkod/etiket OCR, güvenli manuel giriş; karelerin tümü varsayılan olarak cihazda.
2. **Doğrula:** “Mavi / ürün modeli / renk / beden” (örnek ürün ismi gösterim amaçlıdır). Belirsizse kullanıcı varyant seçer.
3. **Karar:** “Bu beden sana olabilir mi?”, “Yaz–kış hangi kullanımda?”, “Dolabında buna benzer var mı?”, “Seni bu ortamda nasıl tamamlar?”.
4. **Kombinle:** “Dolabımdan tamamla” (varsayılan), “Bu mağazadan tamamla”, “Tüm izinli markalardan tamamla” seçenekleri.
5. **Göster:** Nötr avatar üzerinde uygun fidelity seviyesiyle prova ve 2–4 anlamlı kombin kartı. Eksik varlık varsa iki boyutlu ürün bileşimleri.
6. **Anlat:** “Bu kot, dolabındaki beyaz gömlekle uyumlu; daha resmi ortam için lacivert ceket seçebiliriz.” Nedenler *renk, silüet, kesim, resmiyet, mevsim ve kişisel tercih* kaynaklarıyla açıklanır. Bunlar öznel stil önerisidir; bilimsel kesinlik iddiası değildir.
7. **Satın alma:** Sadece mevcut dolap yeterli değilse veya kullanıcı istiyorsa; fiyat, stok, komisyon ve sponsor etiketlerini açıkça göster; satın almadan çıkış her zaman tek dokunuş.
8. **Öğren:** “Bu kombini beğendim / beğenmedim / denedim dar geldi” olayları cihazda ayrı saklanır ve onaylı kişiselleştirmeye aktarılır.

**Hız sözleşmesi:** Sahip olunan dolap verisi ve önceden önbelleklenmiş ürün ile ilk anlamlı kombin p95 ≤2 saniye, hazır 3D varlıkla görsel p95 ≤3 saniye *tasarım hedefi*; cihaz/termal sınıfı ve ağ ayrı raporlanır. Canlı katalog/teklif ağı saniyelerden uzun sürebilir; kullanıcı sonsuz spinner görmez: `PARTIAL` + kanıt/eksik veri. Bunlar mevcut ölçüm değildir.

# V18-03 — 'BU PANTOLONLA NE GİYİLİR?' KARAR MOTORU

## V18-03.1 Kombinin malzemeleri

- `anchor`: taranan ürün veya kullanıcının seçtiği dolap parçası.
- `wardrobe`: mevcut dolap, temiz/kirli, kullanılabilirlik, renk, kumaş, formality ve kullanım sıklığı.
- `context`: tarih/şehir *kullanıcının seçimiyle*, hava kanıtı, etkinlik, yürüyüş/süre, mekanın dress code'u, kültürel bağlam yalnız somut bilgiye dayanarak.
- `body_fit`: cihazdaki antropometrik profil, beden/kalıp tercihleri ve bölgesel uyum kanıtı.
- `market`: açık onayla seçilen ülke/para birimi, mağaza veya internet arama alanı, fiyat bütçesi, stok zamanı.
- `style`: renk paleti, kumaş yüzeyi, hacim/siluet, formality, aksesuar, katman, ayakkabı, istekli olarak stil referansları.
- `sustainability`: yeniden kullanım, satın almama seçeneği, bakım/durum, önerilen dolap ürünlerini yeniden değerlendirme.

## V18-03.2 Üç ayrı aday havuzu (ayrı yetki, ayrı maliyet)

**POOL A — OWNED FIRST:** `wardrobe` öğeleri; ağ çağrısı yok, alışveriş maliyeti 0, en yüksek kullanıcı yararı. Aynı ürünü iki kere satmaya çalışma.

**POOL B — IN-STORE:** kullanıcının taradığı mağazanın izinli, stok kanıtı güncel ürünleri. Özellikle “Bu ürünle bu mağazadan ne almalıyım?” eyleminde; raf ve depodaki gerçek stok `AVAILABLE_VERIFIED` değilse mağazada varmış gibi söyleme.

**POOL C — CROSS-BRAND:** kullanıcının açık seçimiyle marka ve satıcı ağı. Farklı marka ürünleri bir kombin altında listelenebilir fakat her bir satıcı ayrı fiyat, stok, beden, teslimat, iade ve satın alma bağlantısına sahip. Tek checkout iddiası için yasal ödeme/merchant-of-record anlaşması şarttır.

**REASONED NONE:** “Dolabındaki parçalar yeterli; başka ürün almana gerek yok” başarı sayılır. Bir reklamveren bu sonucu engelleyemez.

## V18-03.3 Öneri boru hattı

`Intent → Identity verified → Context snapshot → User-controlled retrieval → Candidate coverage filter → Hard constraints → Outfit combinator → Fit/thermal/style/price evidence → Pareto ranking → Explanation → Optional sponsored slots → DecisionEnvelope → UI`.

**Hard constraints:** beden kanıtı yoksa fit garantisi verme; kullanılamayan/kirli iç çamaşırını önerme; stok doğrulanmamışsa “stokta” deme; kullanıcının açık yasakladığı renk/kumaş/marka ve bütçe sınırlarını ihlal etme; mekan zorunlu dress code'u varsa kanıtını ve kaynağını sakla. Sert kural ihlal eden aday pazarlama gelirine rağmen elenir.

**Soft objectives:** stil uyumu, çoklu parçayla eşleşebilme, kullanıcının stil beğenisi, hava/konfor, kalite/tekrar kullanım, toplam maliyet, satın alınması gereken yeni parça sayısı. Çok amaçlı/Pareto ranking; **komisyon** ana organik ranker girdisi **olamaz**. V1 deterministik, insan modeliyle test edilmiş özellikler; model ancak ölçülmüş kalite kazancı olursa eklenir.

**Önerilen açıklama:** en fazla üç somut gerekçe + bir uyarı. “Daha özgün” gibi öznel terimleri “fit kesin” gibi olgusal iddialarla karıştırma. Kullanıcı alternatif stil ve beğenmedim geri bildirimiyle yönlendirebilir.

## V18-03.4 Kombinle ilgili çok kritik mantık

- Sadece ürün türü+aynı renk “kombin” değildir. Bağlam ve kesimler arasındaki denge, ayakkabının kullanımı, katman/aktivite, desen ve kumaş yüzeyi önemli.
- Kadın/erkek giyim dayatması yok. Seçilen stil, beden/ürün kesimi ve kullanıcının girdileri esastır; cinsiyet kimliği mağaza ürünü için varsayımsal türetilmez.
- Kişinin doğum tarihinden yaş hesaplanabilir ama moda tercihleri için zorunlu veri olmamalı; burç ve numeroloji yalnız **isteğe bağlı ve etiketli yaratıcı ilham**, bilimsel beden uygunluğunu veya ticari kişiselleştirmeyi etkilemez.
- Ten tonu ve fotoğraf tahmini için izin/yanılma kontrolü ve kullanıcı düzeltmesi; hassas kişisel veriden reklam hedeflemesi yapma.
- Stil puanları (ör. %92 yakışır) ancak ölçülü ve kalibre edilmiş test verisi varsa görüntülenebilir; varsayılan *yakıştırma yüzdesi* üretme.

# V18-04 — ÜRÜN KATALOĞU: HER MARKANIN FARKLI VERİSİNE UYUM

## V18-04.1 Canonical commerce graph

İlişkiler: `BrandOwner → Brand → Collection/Season → StyleModel → Colorway → SizeVariant → Offer → Merchant → StoreLocation`; `StyleModel` birden çok `Colorway`; `Colorway` birden çok `SizeVariant`; aynı varyant birden fazla `Offer`. `GarmentGeometryAsset`, `MaterialEvidence`, `CareLabelEvidence`, `MeasurementSpec`, `FitFeedback`, `AffiliateAgreement`, `CatalogLicense` ilgili düğümlere sürüm ve veri hakkıyla bağlı.

- `BrandOwner` markadan ayrı legal entity; marka sahipliği değişebilir.
- `GTIN/UPC/EAN` uygun seviyede **identifier**, her zaman tam beden tablosu taşıyan bir veri kutusu değil.
- `ManufacturerStyleCode`, `MerchantSKU`, `PartnerVariantID`, `GTIN`, `imageFingerprint`, `userScannedLabelText` aynı ad alanında değildir.
- `SizeVariant`: kullanıcı beden etiketi (XS/M/34/32-32), **ölçü birimleri** ve ülke standardı ayrı. Hem vücut tablosu hem bitmiş giysi ölçüsü farklı alanlar.
- `Offer`: satıcı bazında fiyat/para birimi/vergisel bilgi/stok/validUntil/affiliate URL provenance; katalog ürününden ayrıdır.
- `Fabric`: lif yüzdeleri ve kaynak, esneme/gramaj/örgü/dokuma/astar/termal test; bilinmiyorsa `nil`.
- `Claims`: `claimedBy`, `sourceURI`, `licenseID`, `observedAt`, `validUntil`, `revision`, `evidenceID`, `scope`, `confidenceTier`, `revocationStatus`, `translationProvenance`.

## V18-04.2 Kaynak güvenliği

- **Tier A:** marka/üretici tarafından imzalı ve lisanslı ürün verisi, varyant/ölçü/fit/varlık; ticari içerik hakları ayrı doğrulanır.
- **Tier B:** sözleşmeli perakendeci ya da yetkili pazaryeri feed'i; ölçü ve stoku nereden aldığı kaydedilir.
- **Tier C:** GS1 temel kimlik doğrulaması, yalnız gerçekten sağlanan ürün alanlarında.
- **Tier D:** etiketten yerel OCR veya kullanıcının el ile yazdığı bilgi; kullanıcı doğrulamasıyla *user evidence*; başkalarına marka gerçeği gibi servis etme.
- **Tier E:** model tarafından tahmin edilen kategori, renk ve stil; teknik lif yüzdesi/beden/üretici garantisi yok.

`Unknown` ile `false` farklı. Lisans süresi bitmiş bir feed `VERIFIED` olmaktan çıkar; ürün önbelleğinin temizlenmesi/son kullanımı ve affiliate bağlantısının kapatılması gerekir.

## V18-04.3 Katalog yönetimi ve bağlayıcı ticari haklar

Her marka/merchant satırı için `coverage_status, legal_rights, allowed_field_sets, image_rights, derivative_3d_rights, affiliate_link_rights, offline_cache_rights, country_scope, validity, rate_limit, contact, audit_date, last_feed_sync, partner_signing_key_id`.

Katalog kaynağı protokolü: `PartnerFeedAdapter`, `RetailerAPIAdapter`, `CSV/SFTPAdapter`, `ShopifyAuthorizedAdapter`, `GS1BasicIdentityAdapter`, `UserLabelImportAdapter`, `SyntheticFixtureAdapter`. Shopify Storefront API bir mağazanın GraphQL API'sidir; dünyadaki tüm Shopify mağazalarını izinsiz sorgulama yetkisi vermez. Google Merchant Center hesapları da evrensel ücretsiz ürün veri havuzu olarak düşünülmez. Yetkili bağlantı şart.

**Kazandığımız evrensellik:** Yarın farklı bir markanın CSV/JSON/GraphQL feed'i geldiğinde iOS kodu değiştirilmeden `adapter → schema mapper → evidence validator → catalog index → safe mobile projection` hattına girer. Her partner için ayrı mikroservis zorunlu değil; ilk aşamada küçük modüler backend + on-device local cache kullan.

## V18-04.4 Senkronizasyon ve veri tutarlılığı

- Şema doğrulama, imza/hmac ve tedarik güveni, hash, kaynak lisansı, ETag, TTL, delta sync, atomic publish, canary, rollback.
- Varyant silme/retire; beden tablosu revizyonu; stok fiyat anlık eskime; sold-out ve indirim dinamikliği.
- Tek ürünün farklı veri sağlayıcılarından farklı lif/ölçü bilgisi gelirse `CONFLICTING_SOURCES` ve canlı fit kapısı durur.
- Mobilde marka kapsama verisi ile kullanıcı bedeni **ayrı deposunda**. Mağaza/affiliate backend'e kullanıcı fotoğrafı, beden ölçüsü, avatar, sağlık/özel nitelik, seyahat planı aktarılmaz.
- İndirilebilir katalog endeksleri artımlı/bölgesel, sıkıştırılmış, kullanıcı eylemiyle ve cihaz bütçesine uygun; mağazaların milyarlarca ürününü cihaza çekme.

# V18-05 — ÜRÜN KİMLİĞİNDEN KOMBİN ÖNERİSİNE KADAR API SÖZLEŞMELERİ

## V18-05.1 Örnek kanonik sözleşme — **tamamen sentetik**

```json
{
  "schema_version": 1,
  "source": "SYNTHETIC_DEMO_ONLY",
  "brand": {"id":"demo-brand-01", "name":"Örnek Marka", "owner_id":"demo-company"},
  "style": {"id":"style-01", "category":"bottom", "silhouette":"straight"},
  "colorway": {"id":"color-blue", "color_family":"blue"},
  "variant": {"id":"variant-32", "tag_size":"32", "gtin":null, "market":"TR"},
  "measurements": {"type":"FINISHED_GARMENT", "waist_flat_cm":null, "hip_cm":null, "inseam_cm":null},
  "materials": {"composition":null, "stretch":null, "care_label":null},
  "evidence": {"evidence_id":"synthetic-001", "license_id":null, "revision":1},
  "tryon": {"tier":"2D_CARD", "asset_id":null},
  "offers":[]
}
```

`measurements.type = BODY_SIZE_CHART` ile `FINISHED_GARMENT` kesinlikle karıştırılmaz. Ürün ölçü olmayan alana `0` yazılmaz. Farklı marka ve ülke numaralandırması normalize edilse bile orijinal etiket ve dönüşüm gerekçesi korunur. `evidence_id` olmadan olgusal doğrulanmış sonuç gösterilemez.

## V18-05.2 Backend endpoint taslağı (sözleşme; henüz canlı API yok)

```text
GET  /v1/catalog/coverage?market=TR&category=denim        -> no auth; no private data
POST /v1/catalog/resolve                                  -> code/market/locale only, strict egress
GET  /v1/catalog/styles/{styleId}/variants/{variantId}   -> licensed product attributes
GET  /v1/catalog/styles/{styleId}/assets                  -> rights-filtered asset manifest
GET  /v1/offers?variantId=...&market=TR                   -> price + stock TTL + partner rights
POST /v1/retail/partner/feed                              -> authenticated signed partner upload
GET  /v1/retail/partner/quality                           -> tenant-isolated QA metrics
POST /v1/affiliate/outbound                               -> opaque offer ID / attribution token only
POST /v1/affiliate/conversion                             -> provider-side server-to-server, no body profile
```

Uygulama iOS tarafında kişisel `POST /recommendations` ihtiyacı yaratma. Kombinlerin üretimi cihazda; backend sadece kamusal katalog/teklif parçalarını döndürür. Stok/checkout onayında yetkili satıcıya çıkış yapılır. Cihaz IP ve katalog arama logları kişisel veri sayılabilen metadata olduğundan saklama en aza indirilir.

# V18-06 — GELİR MODELİ: KULLANICIYA İYİ KARAR, İŞLETMEYE KANITLANMIŞ DEĞER

**Evet, potansiyel gelir alanı güçlü.** Ancak kazanç, mağazalara veri hakkı veya satış sözleşmesi olmadan otomatik başlamaz.

## V18-06.1 Gelir kanalları

**A) Affiliate / CPS:** Uygun ve onaylı programların resmi takip linkiyle yönlendirme; satışı gerçekleşen, iadesiz/uygun siparişte komisyon. İlk ticari deneme için düşük sabit maliyet, fakat platform onayı, uygulama içi link ve katalog kullanım koşulları *ayrı* gereklilikler. Awin benzeri publisher ağları, Trendyol'un sosyal medya influencer programı örnek referanslar; bunlar Kabinsiz'in kabul edildiği anlamına gelmez. Özellikle influencer programları bir mobil uygulama içinde otomatik link oluşturma izni vermeyebilir. Hiçbir onay yoksa affiliate claim ve link yok.

**B) Doğrudan marka/mağaza SaaS:** Aylık/mağaza başına katalog senkronizasyonu, dijital prova QR, ürün sayfası entegrasyonu, stokla ilgili anonim *agregat* öneri talebi, ortak pilot raporu. Kullanıcı mahremiyeti ve k-anonim benzeri küçük grup bastırma kuralı. Doğrudan ölçüm paylaşımı yok.

**C) B2B sonuç / teknik entegrasyon:** Sözleşmeyle sabit kurulum ücreti, SKU asset onboarding, yıllık enterprise lisans veya kanıtlanmış satışa bağlı ücret. İade/cancel sonrasında gelir düzeltmesi; çift faturalama engeli.

**D) Bireysel premium:** Gelişmiş kapsül gardırop, valiz ve otomatik stil takvimi gibi *dijital uygulama özellikleri* ücretli olabilir; Apple in-app purchase abonelik kuralları uygulanır. Temel mahremiyet, kendi verisini silme, temel güvenilir beden uyarıları, sponsor ayrımı ve satın almama alternatifi ücretli kilide girmemeli.

**E) Etiketli sponsorlu keşif:** Organik sıralamayı bozmayan açık reklam alanı; hedefli reklamlar için Türkiye'nin 2026 reklam değişiklikleri ve KVKK şartları değerlendirilir. Doğum, beden, fotoğraf, sağlık, seyahat veya ten renginden örtük reklam profili oluşturma. Çocuklara davranışsal hedefli reklam yok.

## V18-06.2 Apple ödeme ayrımı

Fiziksel giyim ürünü alışverişi: App Store Guideline 3.1.3(e) kapsamındaki uygulama dışı tüketilen fiziksel mallar için IAP kullanılmaz; yetkili satıcının güvenli checkout'u, Apple Pay ya da ödeme sağlayıcısı koşulları değerlendirilir. Kabinsiz'in *dijital premium aboneliği* farklı satın almadır; IAP/StoreKit politikaları uygulanır. Tek uygulamada iki ödeme kategorisini aynıymış gibi tasarlama. Apple politikası sürüm ve bölge bazında tekrar doğrulanır.

## V18-06.3 Gelir ledger

`commercial_event_id, event_type, merchant_id, offer_id, partner_program, disclosure_version, attribution_token, click_timestamp, outcome_window, conversion_status, refund_status, commission_currency, gross_commission, net_commission, reversal_reason, reconciliation_status`.

Komisyon tutarı hiçbir zaman garantili değildir; ülke/marka/program/ürün, iade ve atıf penceresine bağlıdır. Raporlarda `clicks→qualified_outbound→approved_orders→net_sales→net_commission→chargebacks`, operasyon maliyetleri düşülerek katkı kârı ve ROI göster. Kişinin beden profili **ledger'da yok**. Sahte tıklama, self-referral, cookie stuffing, sipariş iadesi ve click injection anti-fraud kontrolleri; cihaz profilini izleme amacıyla kullanma.

**Analitik örnek mantık (temsili, tahmin değil):** net komisyon = onaylı satış üzerinden sözleşmedeki geçerli komisyon − iptal/iade/uygunsuz trafik düzeltmeleri. Reklam geliri ve abonelik ayrıca ayrılır.

# V18-07 — ORGANİK FAYDA İLE REKLAMIN AYRILMASI: ÇELİK KUBBE TİCARİ TARAFSIZLIK

1. **ObjectiveFitRanker**: beden, kumaş, hava, renk, etkinlik, maliyet ve kullanıcı tercihine göre göreli fayda. Finansal ödeme bu skorun girdisi olamaz.
2. **CommerceEligibilityGate**: satıcı ve stok, yaş/ülke, lisans, fiyat/tarih, link hakkı, iptal durumunu doğrular. Satış yetkisi olmayan ürün kartı bilgilendirici kalır.
3. **SponsoredPlacementRouter**: kullanıcıya açık sponsorlu yerleşim; yalnız zaten güvenlik/uygunluk kapılarından geçen adaylar. Sponsorun “en iyi beden” iddiasına müdahalesi yasak.
4. **AttributionAdapter**: ürün satışına giden opaque token üretir; vücut/fit/sağlık/foto/şehir içeriği taşımaz. Redirect target allowlist, imza, anti-open-redirect.
5. **IndependentRevenueAudit**: aynı adaylar için affiliate açık/kapalı olduğunda beden kararı, kumaş iddiası ve organik ilk sıralama değişmez. Test ve snapshot zorunlu.
6. **ConsumerControl**: “Sponsorlu içerikleri gizle” veya “yalnız dolabım” filtresi; kullanıcı uygulamanın neden önerdiğini görebilir. Ticari sıralama testine izin verilmediği sürece A/B test yok; kişisel hassas profil üzerinden deney yok.

**Temel gerçek:** Affliate veya sponsorluk, stil önerisinin tamamını satın almaya dönüştürme yetkisi vermez. Kullanıcıya “alma” tavsiyesi, sistem başarısının bir göstergesidir.

# V18-08 — SİSTEM MİMARİSİ VE OCTOPUS GÖREVLERİ

## V18-08.1 Cihaz içi bağımsız işlevler (büyük LLM şart değil)

| Modül | Girdi | Ürettiği kanıtlı çıktı | Sahiplik / erişim sınırı |
|---|---|---|---|
| `ShoppingIntentRouter` | tara / tamamla / yalnız dolap | görev grafiği, zaman bütçesi | kullanıcı eylemi olmadan ağ açmaz |
| `BrandIdentityResolver` | barkod/OCR, katalog sonucu | tam varyant / ambiguite | fotoğrafı dışarı çıkarmaz |
| `EvidenceCoverageGate` | claim+provenance+lisans+TTL | hangi iddianın söylenebileceği | kaynak yoksa engeller |
| `WardrobeAvailability` | gardırop ve giyim durumu | kullanılabilir parçalar | özel yerel DB erişimi |
| `ColorAndSilhouetteStylist` | ürünler, kullanıcı tercihi | stil uyumu ve nedenler | kesin beden kararı vermez |
| `OccasionDressCodeAgent` | kullanıcı ortamı + doğrulanmış mekan kuralı | resmiyet/aktivite filtreleri | kültürel stereotip çıkarmaz |
| `FabricComfortAdvisor` | kanıtlı kumaş + hava | koşullu katman ve konfor | sabit °C garantisi vermez |
| `RegionalFitAdvisor` | beden ve ürün ölçüleri | bölgesel uygunluk ve bilinmeyenler | tam beden için kanıt gerekir |
| `OutfitCandidateGenerator` | anchor + havuz A/B/C | 3–20 geçerli kombin adayı | egress yok |
| `OutfitConstraintSolver` | sert kurallar, ürün özellikleri | çatışmasız kombinler | fazla alışveriş zorlamaz |
| `ObjectiveOutfitRanker` | aday kalite özellikleri | kanıtlı sıralama ve açıklama | affiliate ücretini görmez |
| `VisualPreviewRouter` | haklı 3D/2D varlık | fidelity tier ve önizleme | olmayan varlığı var göstermez |
| `PersonalFeedbackLearner` | kullanıcı beğenisi/deneme | yerel tercih revizyonu | kodu kendi kendine değiştirmez |
| `DeviceResourceGovernor` | termal/bellek/düşük güç | bütçe/fallback | kritik animasyon/sensör sınırı |
| `CommerceEligibilityGate` | fiyat/stok/lisans/satıcı | BUYABLE/INFO_ONLY | mahrem profil yok |
| `SponsorDisclosureRouter` | sponsorluk ve bölge | etiketli ayrı yerleşim | organik fit ranker'a erişmez |
| `RetailCoverageMonitor` | imzalı katalog manifesti | hangi ülke/marka/ürün seviyesi kapsanıyor | kişisel veri yok |
| `OutfitDecisionComposer` | tüm karar zarfları | tek kullanıcı kartı | kanıtsız oran üretmez |

**Kural:** Bunlar sorumluluk modülleridir; 18 ayrı süreç veya 18 ayrı büyük AI modeli değildir. V1 Swift deterministic algoritmalar + seçilmiş küçük Core ML çıkarımı + bir yerel koordinator; yalnız gerekli yerde daha gelişmiş yerel model.

## V18-08.2 Sunucu / partner bileşenleri (kişisel profil taşımaz)

`PartnerOnboarding, ContractRightsRegistry, BrandGraphService, FeedNormalizer, DataQualityGate, EvidenceSignatureService, PublicCatalogIndex, OfferFreshnessService, AffiliateAttributionService, PartnerDashboard, AggregateExperimentService`. Başlangıçta güvenli modüler monolit + arka plan job yeterli; servisleri ölçülmeden bölme.

## V18-08.3 Güvenlik / ürün ayrımı

`Personal Vault` sadece iOS; `Public Commerce Cache` etiketli ve ayrılmış; `Partner Catalog` backend; `Revenue Ledger` backend; `ConsentLedger` kullanıcı onayı; `DecisionEnvelope` egress/claim gate ile son kullanıcıya çıkar. Backend kullanıcı yüzü veya vücut ölçülerini bilmez. Kullanıcı izniyle bir marka için özel fit iletimi ileride önerilirse **ayrı, açık, iptal edilebilir ve veri minimizasyonlu** bir tasarım onayı gerektirir; v1.8'de yasak.

# V18-09 — CLAUDE CODE UZMAN AJANLARI / SKILL VE MCP İHTİYAÇLARI

## V18-09.1 Geliştirme ajan kartları (yeni veya mevcut ajan genişletmesi)

| Rol | Sorumluluk | Teslimat | Bağımsız denetçi |
|---|---|---|---|
| `global-brand-intelligence-architect` | TR/küresel brand graph, market registry, data rights | kaynaklı kapsama matrisi, versioned schema | legal + data QA |
| `retail-feed-integrator` | CSV/JSON/authorized API/adapters | import, validation, delta, revocation | security-appsec |
| `fashion-styling-director` | renk, form, kumaş, ortama uygun kombin bilim/sanat | uzman değerlendirme rubric | independent stylist panel |
| `outfit-constraint-engineer` | aday üretici + hard/soft objectives | Swift pure ranker, invariants, fixtures | model QA |
| `fit-and-fabric-reviewer` | ölçü/ısı iddia sınırları | evidence validation, abstain tests | metrology / garment technologist |
| `commerce-growth-architect` | affiliate, B2B, subscription economics | contract assumptions, revenue model | legal + finance |
| `ad-integrity-auditor` | sponsor tarafsızlığı / disclosure | differential ranker tests | red team |
| `merchant-partner-ops` | onboarding, katalog kalite SLA | demo portal, legal checklist | privacy + ops |
| `privacy-egress-security-auditor` | ağ payload, access, consent | negative network tests | independent security |
| `performance-qa-real-device` | tam yol UX latency | p50/p95/p99 device benchmarks | independent QA |

Repo `.claude/agents/` altında üstteki dosyaları oluştur; işe yaramayan tekrar ajanlar yaratma. Bir ajan sadece aynı LLM'nin farklı rolüdür; gerçek bağımsız doğrulama insan uzman, ikinci toolchain veya red team ile güçlendirilir. Agent görev dosyası: Inputs/Allowed tools/Forbidden data/Outputs/Acceptance evidence/Stop condition/Reviewer.

## V18-09.2 İhtiyaç halinde proje skill'leri

- `brand-catalog-identity-and-rights`: `GTIN, SKU, brand owner, rights, country, variant` haritası ve testleri.
- `universal-product-schema-migration`: Swift+backend migration, golden fixtures.
- `retail-feed-quality-and-provenance`: delta sync, stale, conflict, signature.
- `outfit-constraint-and-styling-eval`: profesyonel stil rubriği + adversarial örnekler.
- `affiliate-compliance-and-disclosure`: program hakları, atıf/gelir, App Store/TR reklam uyumu.
- `monetization-neutral-ranking`: sponsor kapalı/açık differential, no-buy parity.
- `privacy-preserving-commerce-analytics`: kısıtlı olaylar ve anonim agregasyon.
- `real-store-scan-to-outfit-benchmark`: fiziksel cihazda tarama→fit→kombin→açıklama/hata profili.

Her skill için `SKILL.md`, minimum runnable example, fixture, sürüm ve test. Hazır ancak doğrulanmamış üçüncü taraf skill'i çalıştırmadan bağımlılık ve kod güvenliği taraması.

## V18-09.3 MCP birimi — gerçek ile aday ayrımı

- **GitHub MCP (mevcut bağlı):** repo/PR/issue diff, review, SHA, check statuses; production secrets gönderme.
- **XcodeBuildMCP (kurulumu ve erişimi doğrulanacak):** build, UITest, Instruments/physical device kanıtı; hiçbir şeyi “cihazda test edildi” diye varsayma.
- **Blender MCP (kurulumu ve sandbox güvenliği doğrulanacak):** licensed apparel assets, rig/morph USDZ, dosya yazma/çalıştırma yetkisi kısıtlı.
- **Retail Partner Catalog MCP (özel yazılacak):** yalnız sözleşmeli retailer feed, schema validation, private keys server-only. İnternetten her markanın gizli API'sine erişim hakkı vermez.
- **Affiliate MCP/Adapter (özel ve provider koşullarına bağlı):** sadece resmi publisher API, izinli catalog/offer, dashboard, postback; API kabul yoksa `BLOCKED_EXTERNAL`.
- **Eval/Metrology skill:** fiziksel ölçü / kullanıcı denemesi doğruluk veri seti, anonim sentetik benchmark; test kanıtı olmadan “başarılı” deme.
- **Legal/Compliance review:** insan onayı gereken sözleşme, affiliate anlaşma, lisans, görsel telif.

MCP bağlantısı kurulmuş olmak modelin zeki veya veri kapsamının tamam olduğu anlamına gelmez. MCP kaynakları dış güven sınırından gelir; prompt injection ve veri sızıntısına karşı tipli allowlist, output validation, izole subprocess ve secrets vault gerekir.

# V18-10 — GÖRSEL ARAYÜZ / EKRANLAR

1. **Mağazada Tara:** kamera + ürün kodu yedek; yakın mağaza konumu isteğe bağlı, otomatik sürekli GPS yok.
2. **Ürün Gerçekleri:** marka, tam varyant, kumaş, yıkama/bakım, fit evidence, fiyat/son güncelleme, eksik bilgi.
3. **Kombin Tamamla:** segment: `Dolabımdan` / `Bu mağazadan` / `Diğer markalardan`; anında sonuç ve belirsizlik.
4. **Outfit Cards:** 2–4 öneri; anchor merkezli parça seti, aksesuar, ayakkabı, neden iyi, eksikler, toplam fiyat sınırı.
5. **3D Outfit Mirror:** valid asset varsa morph/rotate; aksi halde 2D flat-lay, varlık haklarını göster, provayı garantili gibi sunma.
6. **Mağaza Teklifleri:** satıcı, beden, fiyat, stok kaynak/tarih, online/mağaza türü, gizlilik ve affiliate etiketi.
7. **Benzerini Dolabımdan Bul:** satın almayı bırakma/alternatif seçenekleri.
8. **Alışveriş Listem:** kombinleri kaydet, sadece eksikleri satın alma listesi; kirli/temiz durumunu güncelle.
9. **Marka Kapsamı:** hangi marka/ülke/özellik (kimlik, kumaş, beden, 3D, fiyat) ne ölçüde doğrulanmış.
10. **Partner Portal:** feed yükle, SKU QA, hak/bitme tarihi, mağaza stok eşleme, anonimizasyonlu pilot raporlar.

Her ekran için `loading / no-network / missing-license / unknown-size / partial-catalog / stale-stock / permission-denied / device-hot / VoiceOver / Dynamic Type / RTL and localization` durumları ve UI screenshot+UITest kabul kriterleri. V18 tasarımı mevcut 3 tab'ı korur; gerekmeden yeni ana sekme ekleme. `Tara` eylemine “Kombinle” ikincil yüzey, Dolabım'a “Bu parçayla tamamla” eylemi ekle. Ürün kartında “Sponsorlu/Komisyon bağlantısı” ibaresi görünür ve erişilebilir.

# V18-11 — MAĞAZA ANLAŞMALARI VE EVRENSEL VERİ AĞININ BÜYÜTÜLMESİ

## V18-11.1 Partner teklifinin gerçek değeri

Mağazaya **“Beden tablosu ve teknik özellikleri lisanslı olarak aktarırsanız müşteriye doğru varyantı gösterebilir, kişinin kendi dolabından kombin kurabilir, bilinmeyen yerde 'bilmiyorum' diyebilir ve sizin izninizle ürünlerinizi kombine ekleyebiliriz.”** yaklaşımı. Mağaza faydası ölçülmeli: ürün bulma süresi, doğru beden önerisi, satış katkısı, ek parça dönüşümü, iade, kabin bekleme süresi, katalog QA maliyeti; baseline/control grubu olmadan gelir garantisi yok.

## V18-11.2 Partner sözleşmesi kapsamı

- Brand/merchant tarafı: ürün katalog alanları, variant GTIN/SKU, teknik beden/bitmiş ölçüler, lif/bakım, fotoğraf/3D türev hakları, güncelleme SLA, stok/teklif hassasiyeti, affiliate program yetkisi, attribution gereksinimi, ödeme ve iade ayrıntıları.
- Kabinsiz tarafı: sınırlandırılmış kullanım, hangi ekranda gösterim, görüntü watermark/attribution gerekiyorsa, insan QA ve doğruluk uyarısı, partner portal, hata düzeltme/retire, key rotation, güvenlik sorumluluğu, veri silme, termination, fesih sonrası cache temizliği.
- Veri transferi: public ürün alanları + sözleşmeli offer; tüketici vücut/profil, yüz fotoğrafı ve ham özel veri **yok**. İsteğe bağlı agregat raporlama sadece eşik ve gizlilik incelemesiyle.
- Aynı ürünü birden fazla satıcı satıyorsa tek brand graph ama merchant offer ayrı.

## V18-11.3 Pilot stratejisi

- **Dikey derinlik > yüzeysel marka sayısı:** önce 1–3 farklı ürün kategorisini ve biri yerli biri küresel olmak üzere 2–3 *izinli* katalog veri biçimini kanıtla. Bu marka seçimi satış/ortaklık başarısına bağlı, zorla Levi's/Mavi değil.
- **Pilot-1:** gerçek fotoğraf/etiket/GTIN olan küçük kanıtlı koleksiyon (örn. gömlek + jean + ayakkabı). Ürün kimliği, bakım, ölçü ve outfit farklı testleri.
- **Pilot-2:** çok markalı mix & match (aynı/başka mağaza) + offer link doğruluğu + sponsor differential.
- **Pilot-3:** gerçek alışverişte süre, dönüşüm, iade vekil metrikleri ve dolaptan kullanım oranı; deney tasarımı ve etik inceleme.
- Türkiye'de seçilen şehir ve mağazalar için gerçekten anlaşma yapılmadan “Kabinsiz burada çalışıyor” denmez.

## V18-11.4 Network effect / büyüme halkası

Kullanıcı tarama → doğru ürün bilgi/kombin → zaman tasarrufu → günlük gardırop kullanımının artması → daha anlamlı kişisel geri bildirim → yerel stil kalite artışı → isteğe bağlı kombin paylaşımı (yalnız kullanıcı onaylı ve kişisel beden/fotoğraf temizlenmiş) → yeni kullanıcı → marka feed ilgisi → daha yüksek katalog kapsama → daha iyi öneri. **Büyüme tarafı hassas veriyi satmaya veya gizlice paylaşmaya dayanmaz**. Partner sayısı kadar “doğrulanmış varyant × veri alanı × güncel stok” metriği değerlidir.

# V18-12 — TÜRKİYE HUKUK / GÜVENLİK / REKLAM ÇERÇEVESİ

- KVKK kapsamında vücut/fotoğraf, yaş, konum veya kullanıma göre kişisel veri işleme değerlendirilir. Biyometrik veri/özel nitelikli kategorinin uygulanması işlem amacı ve işleme biçimine bağlı hukuki değerlendirme gerektirir; her beden ölçüsünü otomatik biyometrik diye sınıflandırma ama risk açısından yüksek koru.
- Ticaret Bakanlığı'nın **1 Ağustos 2026'da yürürlüğe giren** reklam düzenlemesi hedefli reklamcılık, AI destekli reklamlar, sponsor tanıtım ve çocuklara hedefli reklam konusunda yeni koşullar getiriyor. Uygulama ekranında net `Sponsorlu` etiketi ve kriterlerin nasıl kontrol edildiğini anlaşılır açıklama; reklam ile stil doğruluğu kesin ayrılır.
- İsteğe bağlı abonelik, reklam kişiselleştirme, üçüncü taraf ölçüm, katalog indirme, konum ve fotoğraf izni ayrı amaçlar; tek varsayılan blanket consent yok.
- Apple App Store Guidelines fiziksel ürün alışverişi için IAP yerine uygun harici fiziksel-mal ödeme yöntemleri ister, dijital uygulama abonelikleri ayrı. AppTrackingTransparency/Privacy Manifest/SDK ve reklam atıf kuralları ayrıca incelenir.
- Yorumlardan kumaş, beden gibi iddia çıkarılacaksa: yorumun gerçekten o ürün varyantına ait olup olmadığı, bot/spam, gönüllü kullanıcıların gönderimleri, izin ve “tekil deneyimdir” açıklaması zorunlu. Yetkisiz review scraping yok.
- Ticari sır/telif/lisans: marka logoları, ürün görselleri, 3D geometriler, yorumlar ve affiliate verisi izinsiz miras alınmış gibi davranılamaz; haklar satır bazında.
- Algoritmanın ikna gücü ile reklam arasına sınır: dolabı kullan, gereksiz satın alma önerme, reklam kapalı kalınca ana stil faydasını koru.

# V18-13 — SİSTEM KALİTESİ / TESTLER (V1.8 YENİ ŞARTLAR, HENÜZ ÇALIŞTIRILMADI)

Aşağıdaki testler yeni gereksinimdir; `PASS` sayılmaz. Her biri test kimliği, kod yolculuğu, veri sınıfı, cihaz/fixture, beklenen sonuç ve ham kanıt gerektirir.

| Test ID | Senaryo | Beklenen kanıt |
|---|---|---|
| V18-T-001 | Farklı üreticiler aynı marka adını kullanıyor | BrandOwner ve Brand kimliği karışmaz |
| V18-T-002 | Aynı stilin iki renk ve 4 bedeni | yanlış varyanta düşmeden tam çözüm |
| V18-T-003 | GTIN var ancak marka ürün feed'i yok | VERIFIED_BASIC_IDENTITY; fit/material bilinmiyor |
| V18-T-004 | Kamera tek etiket yerine iki barkod görüyor | kullanıcıya seçim, otomatik tahmin yok |
| V18-T-005 | Ürün fotoğrafı başka ürüne çok benziyor | görsel eşleşme kesin GTIN kimliği sayılmaz |
| V18-T-006 | Marka A'nın `M` bedeninden marka B'ye geçiş | beden önerisi izinsiz aktarılmaz |
| V18-T-007 | Kadın/erkek/çocuk kalıp + numara farkı | kategori standardı ve açık user preference |
| V18-T-008 | Satıcı `M` vücut ölçüsü, giysi düz ölçüsü değil | measurement type korunur, fit garanti verilmez |
| V18-T-009 | Lif kompozisyonu yok | AI % lif uydurmaz, UNKNOWN |
| V18-T-010 | İki tedarikçi farklı kumaş/etiket bildiriyor | CONFLICTING_SOURCES ve fail closed |
| V18-T-011 | Lisans süresi dolmuş fotoğraf ve 3D asset | derhal gösterim hakkı iptal/yerel cache revoke |
| V18-T-012 | Yerel dolap tam kombini karşılıyor | no-buy önerisi başarılı ve önce gelir |
| V18-T-013 | Aynı mağazada uygun ayakkabı yok | olmayan stok iddia edilmez, alternatif öznel seçenek |
| V18-T-014 | Crossbrand öneride üç farklı merchant | fiyat, teslimat, iade ve linkler ayrılır |
| V18-T-015 | Bir ürün stokta görünürken TTL bitiyor | stale uyarısı/teklif satın almaya kapanır |
| V18-T-016 | User budget kısıtı altında ürün yok | bütçeyi ihlal eden satış push'u yok |
| V18-T-017 | Kullanıcı marka/renk/kumaş reddediyor | aday havuzundan kesilir |
| V18-T-018 | Sponsorlu marka daha çok komisyon veriyor | organik fit + outfit sıralaması değişmez |
| V18-T-019 | Sponsorlu alan label gizlenmeye çalışılıyor | red-team gate ile gösterim engeli |
| V18-T-020 | Affiliate program sona eriyor | özel link devre dışı, organik stil çalışır |
| V18-T-021 | Partner API zarar verici text prompt içeriyor | typed parser, prompt injection kullanıcıya/araçlara geçmez |
| V18-T-022 | Public lookup payload kaydı | fotoğraf/ölçü/doğum/konum sızmaz |
| V18-T-023 | Komisyon referrer URL query string içeriyor | PII URL'ye düşmez; allowlist redirect |
| V18-T-024 | Kullanıcı reklama izin vermiyor | organik öneri aynen çalışır |
| V18-T-025 | Ürün fiyat/para birimi farklı markette | lokasyon bazlı para birimi/vergisel varsayım yok |
| V18-T-026 | `UNKNOWN` kumaş ama hava soğuk | yanlış kesin °C aralığı verilmez |
| V18-T-027 | Fotoğraf ekleme reddedildi | manuel dolap/etiket girişi çalışır |
| V18-T-028 | iPhone sıcak / düşük güç | 2D yerel fallback, stabil uygulama |
| V18-T-029 | 1000+ sentetik katalog ve yüzlerce dolap parçası | planlanan p95 cihaz bütçesiyle ölçülür |
| V18-T-030 | Kullanıcı adları ve görseller tek tıkla silinir | cache, analytics ve export düzeyi deletion test |
| V18-T-031 | İade sonrası affiliate komisyonu iptal | ledger iki kez gelir yazmaz |
| V18-T-032 | Partner feed yarıda kesildi | atomik publish, önceki sağlam sürüm korunur |
| V18-T-033 | Fiyat indirim etiketi hukuka uygun değil | gösterim kaldırılır / source-based fallback |
| V18-T-034 | Çocuk hesabı için reklama dayalı kişisel profil | engellenir |
| V18-T-035 | Kullanıcı 3D asset'e erişemiyor | 2D kanıtlı kart; hatalı fotogerçekçi claim yok |
| V18-T-036 | Aynı SKU farklı mağazada farklı fiyat | `Offer` mağaza bazında ayrı kalır |
| V18-T-037 | Konum kapalı | seçilen şehir/ülke ve offline dolapla öneri |
| V18-T-038 | Multi brand/market seasonal değişikliği | eski variant ve eski fiyat cache'e kilitlenmez |
| V18-T-039 | Fit/konfor vs sponsor sıralama mutasyon testi | sponsor ağırlığı organik ranker'a enjekte edilince test kırmızı |
| V18-T-040 | Etiket görselinde beden bilgisi karışıyor | label inference belirsiz, kullanıcı onayı |
| V18-T-041 | Kullanıcı beğenmedi ve tekrar aynı öneri | yerel personalization revision tutarlı değişir |
| V18-T-042 | Paylaşılan kombin fotoğrafının metadata'sı | izinli paylaşım dışında yüz/EXIF/beden yok |
| V18-T-043 | Partner A panelinden Partner B sipariş/offer | tenant boundary reddeder |
| V18-T-044 | İki gerçek modelist stil değerlendirme uyuşmuyor | kalibrasyon raporu, consensus sanılmıyor |
| V18-T-045 | Renk/kıyafet önerisi için yanlış yüzde güveni | yüzdelik kalibrasyon kanıtı yoksa gösterilmez |
| V18-T-046 | Erişilebilirlik: VoiceOver, büyük yazı, yalnız renk | erişilebilir ve eşdeğer akış |
| V18-T-047 | API request reddedildi veya internet yok | offline dolap önerisi kaybolmaz |
| V18-T-048 | Gerçek marka partneri yok | kullanıcıya “tüm markalarda doğrulanmış prova” pazarlaması yok |

**Test matrisi:** ana cihaz sınıfları / iOS sürümleri; internet açık/kapalı; farklı beden/renk/giyim stili ve hareket kısıtları; VoiceOver + Dynamic Type; sentetik, lisanslı gerçek ürün ve gönüllü gerçek prova veri setleri ayrı. İnsan moda uzmanı blind review ve ölçüm uzmanı ayrı skor verir. Gerçek pilot verileri olmadan “%95 uyum” gibi pazarlama yüzdesi yasak.

# V18-14 — ÜRÜN, VERİ VE TİCARİ KPI'LAR

**Veri coverage KPI:** `verified_variants / indexed_variants`, `measurement_complete_variants / verified_variants`, `fabric_claim_coverage`, `licensed_3d_asset_coverage`, `offer_freshness`, `revoked_claim_recovery`, `market_brand_coverage`; hepsi market/kategori/kaynak bazında ve kanıtla.

**Kullanıcı KPI:** `time_to_first_useful_outfit p50/p95`, `outfit_satisfaction`, `no_buy_accepted`, `repeat_wardrobe_use`, `fit_feedback_consistency`, `revisit_rate`, `scan_resolution_precision`, `manual_correction_rate`, `fit_abstention_rate`, `battery/thermal burden`.

**Ticaret KPI:** `eligible_offer_coverage`, `qualified_outbound`, `net attributable orders`, `refund_adjusted_commission`, `partner cost`, `incremental attach rate` ve `store fitting queue waiting` gerçek pilotla. Organik kaliteyi azaltan büyüme deneyine izin yok.

**KPI tuzağı:** Sadece tıklama sayısı veya affiliate ciro artışı kalite başarısı sayılmaz. Satın almadan doğru karar vermek, iade önlemek ve kullanıcı dolabını değerlendirmek de başarıdır.

# V18-15 — CLAUDE'UN SIRASI: MEVCUT REPODA 15 İŞ PAKETİ

| Öncelik | WP | Kod/doküman sonucu | Bağımlılık/gate |
|---|---|---|---|
| P0A | `R18-WP01` | HEAD/commit reality check, v1.5/1.7 çatışma haritası, yeni ADR | güvenlik ve privacy kapıları önce |
| P0A | `R18-WP02` | `BrandRegistry`, `CommerceGraph`, `ProductVariant`, `Offer`, `ClaimEvidence` sözleşmeleri + migration | `SystemContracts`, golden fixtures |
| P0A | `R18-WP03` | `EvidenceCoverageGate` ve kaynak çatışması/rights TTL | fail closed test |
| P0A | `R18-WP04` | `OwnedFirstOutfitGenerator`, constraints, local-pure ranking | hiçbir network bağımlılığı yok |
| P0A | `R18-WP05` | `OutfitDecisionComposer` mevcut ShoppingCopilot ile köprü | UI demo ve açıklama |
| P0B | `R18-WP06` | `Kombinle` ekranı + “dolabımdan” + “bu mağaza” geçişi | `R18-WP04/05`, VoiceOver |
| P0B | `R18-WP07` | proof fixture katalog + iki/üç marka / çoklu varyant/offer | sentetik test; partner claim yok |
| P1 | `R18-WP08` | `RetailAdapter` protokolleri + veri yetki/kalite geçidi | v1.5 egress + vault tamam |
| P1 | `R18-WP09` | doğru satıcı teklifleri ve stok tazelik UI | partner feed ve lisans kapısı |
| P1 | `R18-WP10` | crossbrand candidategen ve sıralama + offline fallback | `R18-WP08/09` |
| P1 | `R18-WP11` | sponsor/affiliate differential, attribution allowlist | legal program onayı / mock test |
| P1 | `R18-WP12` | partner feed QA portal, tenant access, revoke | human-reviewed B2B pilot |
| P1 | `R18-WP13` | real iPhone scan-to-outfit latency / energy / a11y evidence | fiziksel cihaz bağlanmadan BLOCKED |
| P2 | `R18-WP14` | partner commercial pilot + genuine net conversion/refund metrics | sözleşme ve insan onayı |
| P2 | `R18-WP15` | global market expansion rank + localization + legal market map | lokal pilot sonucu ve veri hakkı |

**Sıra uyumu:** Aynı anda v1.5 WP15-03/04/05/06/07/08 (runtime egress/vault/orchestrator/governor/avatar) aktifse bunları atlayıp canlı affiliate veya retail ağı açma. `R18-WP02/03/04/05` bağımsız sentetik **Swift testli araştırma dalı** olarak yürütülebilir; canlı ağ ve kullanıcı özel verisi entegrasyonu için güvenlik kapıları önce. Her iş öncesi `git status`, branch ve artan commit SHA kontrol; testlerden önce `PASS` deme.

# V18-16 — CLAUDE BAŞLANGIÇ EMRİ (DOĞRUDAN ÇALIŞTIR)

> **Claude Code, Kabinsiz v1.8'i v1.7 ve v1.5 ile birlikte oku.** İlk olarak `gundogandogancan/kabinsiz` güncel SHA'sını, çalışma ağacını, mevcut gerçek kodu ve testleri doğrula. Var olan `ShoppingGuard`, `DecisionComposer`, `ProductResolver`, `FitPassport`, `SystemContracts` ve iOS navigation yapısını koru. Bütün marka ve küresel moda pazarı için **markadan bağımsız bir ürün kimlik/beden/kumaş/teklif şeması** geliştir; fakat veri lisansı yokken canlı marka kapsama iddiası yapma. İki ana kullanıcı akışını ürünleştir: **(1) mağazada ürünü tarayıp gerçek ürün bilgisi/fit/3D fidelity sonucu**, **(2) taranan ürünle dolabımdan veya izinli diğer markalardan kombin oluşturma ve neden uygun olduğunu açıklama**. Organik öneri skoru ve ticari komisyonu kod mimarisinde birbirinden tamamen ayır. Önce sentetik karma marka kataloglarında offline Swift testlerini, sonra iOS UI akışını ve gerçek cihaz ölçümünü kanıtla. Canlı feed/affiliate/mağaza anlaşmaları engelliyse özel arayüz+fixture yap ve `BLOCKED_EXTERNAL` yaz. Mahrem veri hiç bir retailer/affiliate endpoint'ine gönderilmeyecek. Her iş paketinde `SPEC→THREAT→ADR/CONTRACT→CODE→TEST→PRIVACY/PERF→INDEPENDENT REVIEW→EVIDENCE→GATE` sırasıyla git; diff/commit/test/cihaz kanıtlarını, eksikleri ve bir sonraki uygulanabilir adımı raporla. Dış yetki olmadan ücretli harcama, hesap açma, sözleşme kabulü, marka adına iletişim, canlı affiliate kaydı, TestFlight/App Store yayını yapma.

# V18-17 — ARAŞTIRMA VE RESMİ KAYNAK KAYDI (03.11.2026)

1. Apple App Review Guideline — fiziksel ürün ve dijital abonelik ayrımı: https://developer.apple.com/app-store/review/guidelines/
2. GS1 — Verified by GS1 içindeki temel ürün alanları ve sınırları: https://support.gs1.org/support/solutions/articles/43000734119-what-information-is-available-in-verified-by-gs1-
3. GS1 US — ürün varyantlarının ayrı GTIN gereksinimi: https://www.gs1us.org/industries-and-insights/by-topic/verified-by-gs1/brand-owner
4. Shopify Storefront API — merchant scoped, versioned GraphQL: https://shopify.dev/docs/api/storefront/latest
5. Awin Publisher ortaklık ve program onayı: https://www.awin.com/gb/faqs
6. Awin içerik üreticileri ve reklamveren ağı: https://www.awin.com/us/publishers/content-creator-influencer
7. Trendyol Affiliate açıklamaları ve mevcut model: https://www.trendyol.com/s/trendyol-affiliate-programi
8. T.C. Ticaret Bakanlığı 01.07.2026 reklam değişikliği: https://www.ticaret.gov.tr/haberler/ticaret-bakanligi-tarafindan-ticari-reklam-ve-haksiz-ticari-uygulamalar-yonetmeliginde-yapilan-degisikliklerle-tuketicilerin-aldatici-reklam-ve-ticari-uygulamalara-karsi-korunmasi-guclendiriliyor
9. T.C. Ticaret Bakanlığı 28.07.2026 sponsor açıklama dönemi: https://ticaret.gov.tr/haberler/ticaret-bakanligindan-sosyal-medyada-seffaf-reklam-donemi
10. KVKK mevzuatı / 6698: https://www.aile.gov.tr/kvkk/mevzuat/
11. Türkiye'de faaliyet gösteren marka ve işverenlerden örnekler (belirleyici ticari ortaklık kanıtı değil): https://fashionunited.com.tr/news/people/turkiyede-moda-sektorunde-is-firsatlari/20260904572071
12. Türkiye giyim sektörü şirketler (sayılar kaynak yılı ve metodolojiye bağlı; evrensel ranking kanıtı değildir): https://fashionunited.com.tr/news/background/turkiye-giyim-sektoru-raporu-2025/20260326549635

**Lisans, API sürümü, ülke bazlı satış varlığı ve App Store kuralları uygulamaya geçerken tekrar doğrulanır.** Burada adı geçen hiçbir marka Kabinsiz ortağı olarak sunulamaz. Sözleşmesiz veri çekme, platform API erişim engeli aşma veya sahte indirim/beden oranı yasaktır.

---

## V18-SON — YAYIN VE GERÇEKLİK HÜKMÜ

`DONE` için yalnız markdown ve maket yeterli değildir. En az bir (1) gerçek ürünün yetkili veri kaynağı, cihazda doğru variant tarama, fit/comfort evidence, kendi dolabıyla eşleşen kombin, korunmuş özel veri, erişilebilir UI, gerçek iPhone testleri ve doğruluk/performans kanıtı gerekir. Çok markalı production claim için ayrıca birden fazla yetkili partner/kanal, gerçek varyant/offer sahası, süresi dolmuş veri/kimlik/komisyon red-team senaryoları ve canlı pilot kabulü gerekir. Dünya çapında her ürün için kesin prova garantisi verilemez.

**KABİNSİZ'İN TİCARİ VE TEKNİK FELSEFESİ: “Önce kişinin dolabı. Sonra gerçekten uyumlu ürün. En son ihtiyaç varsa satın alma.”**

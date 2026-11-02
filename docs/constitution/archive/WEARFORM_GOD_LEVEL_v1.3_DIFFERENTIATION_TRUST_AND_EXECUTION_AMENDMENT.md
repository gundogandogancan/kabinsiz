# WEARFORM — GOD LEVEL v1.3 BINDING AMENDMENT
## FIT PASSPORT · REAL-WORLD PROOF · ONE-TAP SHOPPING · WARDROBE ECONOMICS · PRIVACY RECOVERY · RETAIL QUEUE OPERATIONS

> **Sürüm:** v1.3 — 03 Kasım 2026. **Durum:** ŞARTNAME / UYGULAMA TALİMATI; **KODLANDI, TEST EDİLDİ VEYA YAYINLANDI ANLAMINA GELMEZ**.  
> **Kanoniklik:** Bu ek, v1.2 ana dosyanın §§0–58 bölümlerine **§§59–74** olarak eklenir. Çelişki hâlinde mevzuat/platform kuralları ve daha önceki mahremiyet, güvenlik, doğruluk ve izin şartları korunur. v1.3 yalnız bu ekte somutlaştırılan alanlarda önceliklidir.  
> **Ürün felsefesi:** Kullanıcının her sorusunda üç şeyi çöz: **Üstümde olası nasıl durur? Hangi beden daha mantıklı? Bu ürüne gerçekten ihtiyacım var mı?** Beklemeyi, yanlış beden seçimini ve pişman alışverişi azalt. Sınırsız özellik yerine güvenilir karar üret.

---

# 59. SÜRÜM DEĞİŞİKLİĞİ / ÖNCELİK / NELERİ TEKRARLAMIYORUZ

v1.2 zaten şunları zorunlu kılar: yerel iOS mimarisi; nötr, canlı 3D avatar; ölçü kaydırıcıları; izinli gardırop fotoğraf analizi; ürün barkodu/OCR; marka/beden ve kumaş kaynak zinciri; kademeli sanal prova; hava/stil/kullanım önerisi; çamaşır döngüsü; isteğe bağlı sembolik ilham; yerel bounded-Octopus; B2B API; privacy/thermal/CI; Travel Intelligence. **Bunları yeniden isimlendirip proje şişirme.**

Bu ek, eksik olan **ürün döngüsünü kapatır:** `tanı → tavsiye → seç → giy → gerçek deneyimi doğrula → bireysel kalibrasyon → gelecek karar`. Ayrıca `mağazaya gir → ürünü okut → doğru karar → isteğe bağlı kabin sırası → satın alma sonrası sonuç` işini uçtan uca tanımlar.

## 59.1 Bağlayıcı öncelik cetveli

| Kod | Öneri | Faz | Neden |
|---|---|---|---|
| `V13-A` | Fit Passport Lite / kişisel rahatlık tercihleri | **P0** | Markadan bağımsız kullanıcı değeri; yeni sunucu gerektirmez |
| `V13-B` | Tek ekranda *Denemeye değer mi?* kararı | **P0** | Gerçek problem ve en kısa aha deneyimi |
| `V13-C` | Yerel ve izinli giydim/uydu/uymadı geri bildirimi | **P0** | Öğrenmenin güvenilir kanıtı; sahte kendiliğinden zekâ yok |
| `V13-D` | Gardıropta benzer ürün / sahip olduklarımla kıyas | **P0** | Daha iyi ve daha sorumlu alışveriş kararları |
| `V13-E` | Fit Truth Lab: ölçülmüş hata ve gerçek prova doğrulaması | **P0 araştırma + P1 kapsamlı** | Ürünün güvenilirliğinin asıl kaynağı |
| `V13-F` | Ürün veri ve 3D varlık kalite hattı | **P1** | Marka ölçeklenmesinin ön koşulu |
| `V13-G` | Şifreli ve isteğe bağlı cihaz taşıma / veri kurtarma | **P1** | Device-first üründe kullanıcı verisi kaybını önleme |
| `V13-H` | Marka/mağaza için yalın bir *Instant Try* yüzeyi | **P1 deneme / P2 App Clip** | Dağıtım; fiziksel QR/Clip kısıtları var |
| `V13-I` | B2B kabin kapasite/sıra optimizasyonu | **P2 pilot koşullu** | İlk değer teklifi kanıtlanırsa ek operasyon katmanı |
| `V13-J` | Kumaş ve hareket/konfor veri modeli | **P1 metadata / P2 doğrulanmış fizik** | Gerçekçi olma hedefinin teknik sınırı |
| `V13-K` | Alışveriş sonrası iade/beden doğruluğu döngüsü | **P1, açık izinle** | Fit doğruluğu + iadelerde azalma; asla gizli veri birleştirme |
| `V13-L` | Kapsayıcılık / beden algısı etkisi ve erişilebilirlik kapısı | **P0 zorunlu** | Ölçü/beden ürünlerinin yüksek hata ve ayrımcılık riski |

**Öncelik kuralı:** P0 çekirdeği kanıtlanmadan P2 kabin rezervasyonunu, hipergerçekçi fizik motorunu, pahalı bulut LLM'lerini, sosyal akışı, yeni e-ticaret pazar yerini veya çoklu ülke perakende entegrasyonunu uygulama. Hedef `tek kişi + tek ürün + tek anlaşılır karar + yerel doğrulama` olmalı.

---

# 60. 10 SANİYELİK KARAR DENEYİMİ — ONE SCREEN SHOPPING COPILOT

## 60.1 Kullanıcının mağazadaki tek sorusu

Uygulama açılır → `Ürün tara` → barkod/etiket/fotoğraf/marka kodu → ürün kimliği doğrulanır veya belirsiz kalır → **tek bir sonuç kartı**. Gereksiz hesap açılışı, cinsiyet seçimi, ölçü, doğum tarihi, konum izni, mağazaya hesap bağlama **zorunlu olamaz**.

Karar kartındaki üç temel yanıt:

1. **Görünüş:** `3D görünüm (yaklaşık)` / `Ürüne özel 3D varlık` gibi dürüst görselleştirme etiketi. Ürün gerçekten tanımlanmamışsa görsel `genel örnek` olarak belirtilir.
2. **Beden:** `M daha olası`, `L daha bol olabilir`, `Yeterli veri yok` gibi veri ve belirsizlik uygun açıklamalar. Ölçüm ve ürün toleransı bilinmiyorsa tek beden garanti edilmez.
3. **Dolabımda var mı?:** `Benzer kot pantolonun var`, `Bu renkte eksik parça`, `Elindeki ceketle eşleşir`; dolap erişimi yoksa sessizce sıfır varsayma: `Dolabın eklenmedi`.

Kullanıcı tek dokunuşla `Avatar üzerinde bak`, `Bedenleri karşılaştır`, `Dolabımla kombinle`, `Kabin için kaydet` (partner varsa) ve `Bu doğru mu?` aksiyonlarından birine gidebilir. `Satın al` çağrısı önerinin niteliğine, sponsorluk ilişkisine ve gerçek envanter doğrulamasına zarar vermez.

## 60.2 Kaynak ve güven mimarisi

Her kararda `productIdentityEvidence`, `catalogSource`, `garmentVariant`, `sizeChartRevision`, `fitEvidenceTier`, `avatarTier`, `renderTier`, `freshness` ve `missingInformation` izleri tutulur; insan okuyabilir üç kısa neden sunulur. `confidence=0.93` gibi kalibre edilmemiş yüzdeler **yasak**. Ürün SKU/GTIN bilinmiyorsa `bulunamadı` sonucu, benzer adayların görsel eşleşmesi ile karıştırılmaz. Dolaptaki benzer ürün *aynısı* diye sunulmaz.

## 60.3 Failure-first UX

- Kamera izni reddi → fotoğraf seçimi / manuel ürün kodu.
- Ağ yok → kayıtlı ürünler + genel görünüm; partner stok/ölçü verisi uydurma.
- Sıcak cihaz → 2D/kart modu; 3D daha sonra.
- İki olası ürün → kullanıcıya 2 aday göster, kaynak karşılaştır.
- Beden tablosu yok → sadece stil ve genel görünüm; fit iddiası durdur.
- Kullanıcı model olmadan → beden şablonu + basit ölçü girişi; baskı yok.

## 60.4 Ürün metriği

**North Star önerisi:** `Haftalık geçerli moda/beden kararı` = kullanıcıya kaynak seviyesi açıklanan ve sonuç/geri bildirim veya bilinçli kaydetme eylemiyle kapanan karar sayısı. Bu yalnız hipotezdir; kullanıcı araştırmasıyla doğrula. Yardımcı metrikler: gerçek *time-to-first-useful-result*, ret/uncertainty oranı, hatalı ürün eşleşme, uygun olmayan beden önerisi, 7/28 günlük kullanım; sahte kullanıcı etkinliği, clickbait, zorunlu bildirim yok.

---

# 61. PRIVATE FIT PASSPORT — GERÇEK BEDENE YAKIN, KULLANICI KONTROLLÜ

**Tanım:** Fit Passport, kullanıcının avatarındaki tahmini anatomik geometri değil; **kendi rahatlık tercihlerini ve gerçek deneme sonuçlarını taşıyan cihaz içi hafıza**dır. Aynı kişinin bir markada M, diğerinde L seçmesi tutarsızlık değil ürün kalıbının doğasıdır.

## 61.1 Veri katmanları

- **BodyProfile:** Kullanıcı tarafından onaylanan ölçüler/şekil; v1.1 `Living Body` ile tek sahip.
- **PreferenceProfile:** Omuzda rahat, belde oturan, oversize seven, kumaşın esnemesini isteyen vb. bölge bazlı *tercih*, beden normu değil.
- **BrandFitMemory:** `brandId`, `modelLineId`, `garmentCategory`, `sizeSystem`, `confirmedSize`, `outcome`, `fitNotes`, `userConfidence`, `date`, `source`, `catalogRevision`.
- **FitCorrection:** `predicted` ile `observed` ayrışması; `fitTooTightAtShoulder`, `waistTooLoose` gibi kontrollü etiketler. Kumaş ve kesim bilgisi yoksa düzeltme yalnız o ürün veya dar kapsam için geçerli kalır.

## 61.2 Kullanıcı etkileşimi

Kullanıcı gerçek ürünü giyince `Nasıl oldu?` → `Tam oldu / Dar / Bol / Denemedim` → isteğe bağlı bölge detayları → `Bu bilgiyi sonraki önerilerimde kullan`. Ücretli ödül, mağaza puanı ya da baskı yok. `Bu bedenini düzelt` ile marka etkisini beden ölçüsünden bağımsız yönet.

## 61.3 Öğrenme kuralları

- Önce deterministik üretici verisi; yerel öğrenilmiş düzeltme yalnız geçerli güven ve veri kapsamıyla uygulanır.
- 1 sonuçtan **tüm marka, tüm kategori veya tüm ülke** için kural üretme. Bir kazak hakkındaki geri bildirim jean bedenini değiştirmez.
- Düzeltmenin dayandığı gerçek gözlem sayısı ve bağlamı yerel olarak sakla; nadir kategori için `henüz yeterli veri yok`.
- Öğrenme yeni model ağırlığı güncellemeyi **gerektirmez**: v1'de küçük kişisel kural tablosu veya açıklanabilir sınırlı model; Core ML updatable yalnız uygun model/kanıt varsa.
- `Sıfırla`, `Düzeltmeyi unut`, `Bu markaya uygulama` tek dokunuş. Tarih/etiket ekranı kullanıcıyla anlamlı ve saygılı olmalı.

## 61.4 Önerilen veri sözleşmesi

```swift
struct FitObservation: Codable, Identifiable {
    let id: UUID
    let garmentCategory: GarmentCategory
    let brandID: String?
    let productVariantID: String?
    let markedSize: String?
    let observedOutcome: FitOutcome // fits, tight, loose, notTried
    let affectedRegions: Set<FitRegion>
    let observationDate: Date
    let origin: ObservationOrigin // manuallyConfirmed, importedWithConsent
    let fitPreferenceRevision: Int
}
```

**İzin sınırı:** Passport ve gözlemler mağaza API'sine gönderilmez. Kullanıcı bilinçli paylaşım seçerse sadece ön izlenmiş, gerekli minimum ürün/beden sonucu ve ayrı izinle; varsayılan sıfır paylaşım. Profil yedekleme/taşıma ayrıca §68.

---

# 62. FIT TRUTH LAB — KENDİ İDDİANI GERÇEK DÜNYAYA KARŞI ÖLÇ

## 62.1 Neden kritik?

Kıyafet önizlemesinin güzel görünmesi, **gerçek bedene uygun olduğu**, iade oranını azalttığı veya kabin kuyruğunu kısalttığı anlamına gelmez. Bu üçü ayrı deneydir. Görsel ve beden tavsiyesinin, **sahip olunan gerçek kanıta göre derecelenmesi** şart.

## 62.2 Üç ayrı benchmark

A. **Identification:** doğru marka / model / SKU / varyant / renk / beden; `top-1`, `top-3`, no-match accuracy, false match, coverage. Ayrı ambalaj/ışık/ezilmiş etiket/barcode testleri.

B. **Fit:** üretici kayıtlarının sürümü + izinli gönüllülerin gerçek fit denemesi; `coverage`, `abstain`, `wrong confident fit suggestion`, `size-distribution`, `body-shape segment fairness`. Kişisel sağlık/beden verisi ayrı korunur. `Calibration curve` ve tahmin seviyelerine göre gerçek uygunluk oranı; tek doğruluk sayısı yeterli değil.

C. **Visual:** izinli referans görüntüler/3D ölçüm veya objektif geometrik kontrol; giysi sınırları, çakışma/penetration, dikiş yönü, doku/renk, hareket artefaktları; kullanıcı algısı testi ile fiziksel uyum testi ayrı. Gerçekliği temsil etmeyen optik illüzyonlar engellenir.

## 62.3 Benchmark veri ve etik

- Her foto, vücut ölçümü, prova sonucu **açık, amaç sınırlı izinli**; gerektiğinde silme hakkı, minimum veri tutma; kurum/ülke hukuki kontrolü.
- Yaş ve vücut şekli çeşitliliği üzerine kapsayıcılık incelemesi; korunan hassas kategorileri gereksiz toplama. İstatistiksel segment testi gerekirse ayrı DPIA ve uygun temel.
- Özel deneme sonuçlarını **otomatik telemetriye** veya platform için zorunlu global eğitime çevirme.
- Sentetik veriyi gerçek insan üzerinde ölçülmüş sonuç gibi raporlama.
- Büyük veri yoksa erken P0 fixture ve gönüllü küçük pilotla `UNKNOWN` raporu; sahte evrensel başarı yüzdesi yok.

## 62.4 Kalite kapıları

`G-FIT-TRUTH` ve `G-VISUAL-TRUTH` ayrı. Kapsam dışındaki beden/ürün/siluet için tavsiye **abstain** etmeli; sadece güzel görselleştirme testi geçmesi fit onayına dönüşmez. Alt/grup bazında ciddi hata görülürse ilgili segmentte daha belirsiz dil veya özellik durdurma. Bağımsız değerlendirme raporu `docs/evidence/fit-truth/` altına sürümlü kayıt; kullanıcıya güven düzeyiyle tutarlı mikro metin.

---

# 63. MATERIAL & MOVEMENT INTELLIGENCE — GÖRSEL İLE GERÇEK KONFORU AYIR

**Gerçek hedef:** kumaşın bollaşması, katlanması, hareket kısıtlaması ve katman uyumu için **kanıt tabanlı rehberlik**. Dokunma hissini, basıncı veya gerçek ısı konforunu yalnız fotoğraftan birebir tahmin ettiğini söyleme.

## 63.1 Giysi teknik pasaportu

`composition` (%), `knitOrWoven`, `fabricWeightGSM` (varsa), `stretchDirection`, `elasticityBand`, `lining`, `thickness`, `waterResistanceClaim` (kaynakla), `fitCut`, `garmentDimensionsBySize`, `careSymbols` (lisans/doğru yorum), `measuredTolerance`, `lastValidated`, `sourceRights`. Kayıp alan `UNKNOWN` olmalı; sıfır/fabrikasyon değil.

## 63.2 Hareket simülasyon basamakları

- `M0`: avatar üzerinde durağan genel mesh — fizik iddiası yok.
- `M1`: lisanslı/izinli 3D giysi ve bağlama/çarpışma düzeltmesi — yaklaşık.
- `M2`: basit hareket seti: otur, kol kaldır, adım at, dön; kullanıcıya `temsili animasyon`.
- `M3`: validasyonu yapılmış marka teknik kalıp ve kumaş parametreleriyle kumaş simülasyonu — yalnız ilgili desteklenen SKU.

Ağır simülasyon cihazı ısıtıyorsa önceden hesaplanmış varyantlardan ilerle; özel ölçü ve fotoğrafı sunucuya gönderme. LOD + sahne cache + termal zamanlayıcı. `Omuz gerilebilir` şeklinde doğrulanmamış basınç sonucu çıkarmak yerine `bu omuz çevresinde yeterli ölçüm verisi yok`.

## 63.3 Kumaş/rahatlık rehberi

Kullanıcı *ben dar giyinmeyi sevmiyorum* veya *kolumu çok hareket ettireceğim* diyebilir. Öneri örtüşen ölçüm verisi ve kumaş özelliği varsa uyum aralığı verir. Aksi halde `kabinle doğrula`. Erişilebilirlik için tek elle giyinme, rahat ayakkabı, hareket kolaylığı gibi **kullanıcının açıkça verdiği ihtiyaçlar** desteklenir; fotoğraftan engellilik/sağlık tanısı çıkarılmaz.

---

# 64. INSTANT RETAIL ENTRY — APP CLIP, QR, NFC, DEEP LINK VE KİMLİKSİZ DEMO

## 64.1 Gerçek kullanıcı yolculuğu

Perakende mağazasında kullanıcı 200 MB'lık uygulamayı indirmeye zorlanmamalı. `Önce anında fayda → sonra isteğe bağlı tam uygulama` düşüncesi.

- **P0:** tam uygulama içinde hızlı tara ve iPhone kamera akışı, account-free.
- **P1:** yetkili mağaza QR → ürün SKU/variant doğrulama → tam uygulama varsa deep link; yoksa küçük güvenli web/preview ve App Store açıklaması. *Kişisel avatarın web'e taşındığı varsayılmaz.*
- **P2 App Clip fizibilite deneyi:** Apple'ın App Clip yapılandırma, invocation ve gerçek uygulama boyut sınırlarını **güncel resmî belgelerle** doğrula. Fiziksel QR/NFC çağrısı ile çok büyük 3D model payload'unu aynı deneyde **garanti etme**; minimal ürün kartı / beden rehberi ve tam app'e dönüş yolu seç. App Clip'te kullanıcının cihaz içi Fit Passport'ının var olduğunu varsayma.

## 64.2 Güvenlik

QR parametreleri güvenilir kaynak değil: doğrula, normalize et, çok uzun/gömülü URL/komut yükünü reddet; sahte mağaza QR değiştirme / kötü niyetli ürün URL / kimlik avı / şüpheli deep link tehdit modeli. Universal link'lerde association ve domain ownership kontrolü; mağaza içi QR etiketinin izinsiz değiştirilmesine karşı basılı fiziksel kontrol süreçleri. Deep link'le özel profil/id/tanım anahtarı aktarma.

## 64.3 Geçiş ve ölçüm

Kullanıcı web/App Clip'te ürünü görür; tam uygulamaya geçtiğinde yalnız **kamusal ürün id** ve isteğe bağlı seçilmiş bağlam taşınır, kişisel beden verisi değil. Bu akış kullanıcı hesabı, izinli fotoğraf, doğum tarihi veya bildirim izni olmadan da işe yarayabilir. QR kaynak/mağaza/ürün id analitiği aggregate ve izinleri uygun; kişi takibi varsayılan değil.

---

# 65. FITTING ROOM FLOW — MAĞAZA KUYRUĞUNU GERÇEKTEN AZALTAN İKİNCİ ÜRÜN

**Önemli ayrım:** WEARFORM'un 3D provası kabin bekleme süresini **otomatik olarak ortadan kaldırmaz**; sadece bazı kullanıcıların kabine gitme ihtiyacını azaltabilir. Mağaza operasyonu ayrı problem.

## 65.1 Sıra mekanikleri (P2 yalnız pilot kanıtıyla)

`FittingRoomInventory` (kabin sayısı/erişilebilirlik), `QueueTicket`, `HoldExpiry`, `CheckIn`, `RoomReady`, `Started`, `Completed`, `NoShow`, `Cancelled`. Personel paneli/SDK için anahtar/rol/tenant ayrımı. **Opsiyonel anonim sıra bileti**; beden/kimlik/özel görünüm isteme. Karşılaştırılabilir pilotlarda hem **gerçek bekleme süresi** hem müşteri eforu ölçülmeli.

Hatalı rezervasyon güveni yerine aşama ile ifade: `yaklaşık sıra`, `mağaza teyidi gerekli`, `yeri hazır`, `iptal oldu`. Sıra tahmini kayıtlı gerçek geliş-hizmet verisi yokken kesin sayı verilmez. No-show / sıra atlama / manipülasyon / personel hatası / erişilebilir kabin önceliği / internet kesintisi / işletmede aynı anda iki cihaz personel aksiyonu test edilir.

## 65.2 Fiziksel mağaza deneyimi

- Kullanıcı fiziksel olarak kabin isterse sistem **kabin kullanma hakkını baskıyla azaltamaz**.
- Uygun bedeni raftan bulma, mevcut stok ve alternatif beden göstergesi ancak **anlık lisanslı envanter** varsa; tahmini stok `var` diye sunulmaz.
- Kabin içerisine kamera veya müşteri avatar verisi koyma; pilot yalnız aggregate/operasyonel sayaç, uygun izin/bilgilendirme.
- B2B panel gerçek satın alma/garantili iade azalması iddiası içermez.

## 65.3 A/B testi

Pilot sonucu: bekleyen kişi sayısı, p50/p90 bekleme, akışta terk etme, gereksiz kabin denemesi, personel yükü, yanlış beden nedeniyle iade, erişilebilirlik ve kullanıcı memnuniyeti. Opt-in teknolojik müşterilerde seçim yanlılığı kaydedilmeli. Perakendecinin hem operasyon hem katalog maliyeti dahil gerçek ROI hesaplanmalı.

---

# 66. SMART SHOPPING GUARD — DOLABINA GÖRE ALIŞVERİŞ GEREKLİ Mİ?

**Ürün ilkesi:**WEARFORM yalnız daha fazla satış yapmak için değil, doğru ve gereksiz olmayan alışverişe yardım etmek için çalışır. Bu tüketici güvenini ve B2B karşılıklı değeri uzun vadede artırabilir.

## 66.1 Temel kararlar

- `Benzeri var`: dolapta aynı renk/kesim/kategori, kullanıcı onaylı deduplikasyon; düşük güven varsa `benziyor`.
- `Gerçek gardırop boşluğu`: seyahat, etkinlik, mevcut kumaş/renk/katman uyumluluğu için eksik parçayı göster. Önce dolaptan alternatif.
- `Birlikte giyilir mi?`: renk, siluet, kullanım bağlamı, ayakkabı/üst-alt uyumu.
- `Kullanım başına maliyet`: yalnız fiyat/kullanım bilgisi kullanıcı girdiyse; *varsayılan tahmin, kesin tasarruf değildir*. Kişisel harcama bütçesi zorunlu değil.
- `İade riskini durdur`: kaynak güveni düşük fit önerisinde `denemeden kesin beden alma` gibi saygılı uyarı.
- `İndirim mi, ihtiyacım mı?`: promosyon ve sponsorluk hiçbir zaman beden önerisinin üzerine yazamaz.

## 66.2 Gizlilik ve ticari çıkar çatışması

Mağaza ücret ödese bile `fitScore`, `sizeRecommendation`, `needScore` etkilenmez. Ticari yerleşim **reklam/sponsorlu** olarak açık işaretlenir; sponsor olmayan en uygun kişisel alternatif bastırılmaz. Mağaza hiçbir şekilde gardırop listesini veya harcama eğilimini alamaz. Başkasının gardırobuna paylaşım bağlantısından erişim yok.

## 66.3 Üç tüketici metriği

1. `Avoidable duplicate purchase reported` (sadece kullanıcı bildirimi; kanıtlanmış maddi tasarruf iddiası değil).
2. `Owned-item outfit adoption` (giydiğini onaylayanlar, takip izni verirse).
3. `Recommendation regret` (beğenmedim, kullanmadım, yanlış beden — ayrı neden kodu).

---

# 67. EXPLAINABLE STYLE MEMORY — KİŞİYİ DEĞİL TERCİHİNİ ÖĞREN

## 67.1 Öğrenme nesnesi

`SavedOutfit`, `RejectedOutfit`, `PreferredColor`, `AvoidedTexture`, `ComfortPreference`, `OccasionPreference`, `WearConfirmation`, `TemperatureSensitivity` (kullanıcı beyanı), `RecommendationReason`. Geçmiş çıkarımlarının eylemlerden tahmin edildiği belirtilir. Kullanıcı iki tarzı aynı anda sevebilir; tek bir `stil kişiliği`ne hapsetme.

## 67.2 Anti-filter-bubble

Günlük 3 kombin için `Güvenli tercihim`, `Biraz farklı`, `Yaratıcı deneme` çeşitlilik kontrolleri; reddedilen stilleri sonsuza kadar engelleme veya mecburen geri getirme yok. `Bu kombin sana uymuyor çünkü X yaşındasın` yasak. Yaş, burç, numeroloji isteğe bağlı belirtilen yaratıcı ilhamdır; kişiye gizlice uygulanmaz. Cilt/saç renklerini sınıflandırmada ışık kalibrasyonu, kullanıcı düzeltmesi ve `veri yok` hâli korunur. Kişiyi çekicilik veya beden puanıyla kıyaslama yok.

## 67.3 On-device öğrenme günlüğü

Kullanıcı `Neden bunu önerdin?` → 2–3 kanıtlı sebep + `öğrenmeyi düzenle`, `bu bilgiyi sil`. Kayıtların varsayılan gizli; dış senkronizasyon/ortak model eğitimi yok. Model güncellemeleri ancak doğrulanmış sürüm, güvenli imza, lisans, performans/enerji kapısı ve geri alma imkânıyla.

---

# 68. LOCAL FIRST ≠ DATA LOSS — GÜVENLİ CİHAZ TAŞIMA VE KURTARMA

**Gerçek ürün açığı:** Beden, dolap, yılların kombin geçmişi sadece cihazda tutulduğunda telefon değişimi/kayıp/cihaz sıfırlamada silinebilir. Bu maliyeti kullanıcıdan gizleme.

## 68.1 P0 güvenli temel

Ayarlar > Verilerim: `Yerel veri boyutu`, `Veriler nerede?`, `Sil`, `Dışa aktar` (P1 aktifleşince), `Şifreli aktarım henüz yok` durumları. iOS cihaz yedeği ve uygulama dosyası yedeklemelerinde mevcut gerçek davranış App Sandbox ve veri koruma ayarlarıyla incelensin; `tamamen cihazda` söylemi yedekleme yolları nedeniyle yanlış olabileceğinden **hassas içeriği koruma/gerektiğinde yedekleme dışı bırakma** kararı ADR ile verilsin.

## 68.2 P1 taşınabilirlik

- Kullanıcının açık seçimiyle `Şifreli Dışa Aktar` → sürümlü manifest (`schemaVersion`, `createdAt`, `counts`, `mediaHandling`, `checksum`), strong authenticated encryption; şifre/parola/anahtar ayrımı, kullanıcıya unutulan parolanın kurtarılamayacağı anlatılır. Ham beden/fotoğrafı platformun sunucusuna varsayılan gönderme.
- Yeni cihazda `İçe Aktar`, taslak önizleme, bozuk paket/yabancı şema/zararlı dosya/sahte dosya boyutu önleme, tutarlı transaction, silme/geri dönüş. İçerik için dosya paylaşım yolu kullanıcı iradesiyle seçilir; erişim kontrolü test edilir.
- Kullanıcı istemedikçe Apple hesabı / iCloud senkronizasyonu zorunlu değil. Eğer ileride opt-in şifreli senkronizasyon eklenecekse anahtar yönetimi, erişim, silme, anahtar kaybı, çoklu cihaz conflict, KVKK/GDPR ve işletme maliyetini ayrıca çöz; yalnız `iCloud encrypted` yazıp geçme.
- İçe aktarılan aynı giysiler için deterministik ID/duplicate çözümü; avatar versiyon ve morph parametrelerinin eski sürümlerle uyumu.

## 68.3 Kritik kabul kriteri

Eski telefon -> şifreli yerel export -> yeni telefona import -> aynı avatar morph değerleri, gardırop ilişkileri, wear/care states, fit observations, trip outfits; aktarım sırasında ağ isteği sıfır veya kullanıcının açıkça seçtiği aktarım kanalı dışında yok. Yanlış parola veya kurcalanmış dosyada veri sızıntısı/sessiz eksik import yok.

---

# 69. BRAND ASSET QUALITY FACTORY — RENDER'I KANITLAYAN VERİ TEDARİK ZİNCİRİ

## 69.1 Kıyaslanabilir ürün verisi hangi kaynakta?

1. **Yetkili üretici**: ürün, varyant, boyut çizelgesi, ürün düz ölçüleri, teknik kalıp, materyal, fotoğraf, CAD/3D, stok, kullanım lisansı. Her şeyi vermeyeceği gerçeğini kabul et.
2. **Yetkili ticari ortak katalog**: feed kalite, yetki, TTL, kaldırma ve denetim. Marka sahibi değilse yetki zincirini araştır.
3. **Kullanıcı görsel/etiket girişi**: ürünün görüntüsünü tanıma adayı; lisanslı gerçek 3D giysi geometrisinin yerini tutmaz.
4. **Özgün Blender proxy**: kategori/kalıp için tamamen özgün placeholder; markanın kendisinin CAD modeli gibi gösterme.

## 69.2 Gerçek pipeline

`rights intake → SKU/style/color/size normalize → tech-pack validation → material schema → Blender import/parametric adapter → safe mesh topology → morph rig compatibility → collision checks → mobile LOD/textures → signed asset manifest → storefront version/cache → revocation and rollback`.

Doğrulama: render hedef cihazda p95 görüntü/termal; avatarı geniş/ince şekillerde giysi mesh bozulması; farklı beden tablosu revizyonu; yoğun parlaklıkta kumaş rengi/renk doğruluğu; lisans iptalinde varlık son kullanıcıya gösterilmez / önbellek politikasına uygun kaldırılır. Satıcı *aynı model* olmadığını bilecek ve kullanıcı yanıltılmayacak. Telif ve logolar konusunda hukuk gözden geçirmesi.

## 69.3 Partner değerini görünür kıl

`Catalog Readiness Score` yalnız **veri kalitesi** için: kaç SKU doğru varyant, beden tablosu kapsaması, ölçü/kalıp alanlarının kaynağı, güncelleme sıklığı, görsel lisans ve 3D temsil seviyesi. Bu bir tüketici beden/çekicilik puanı değil. B2B maliyet/katalog bakım sözleşmesi, 3D asset dönüşüm ücreti olabilir; ücret ve SLA hipotezdir.

---

# 70. HUMAN DIGNITY & ACCESSIBILITY GATE — BODY-NEUTRAL FASHION

## 70.1 Değişmez ürün ilkeleri

- `Çirkin/güzel`, `ideal vücut`, `kusurlu beden`, `incelmelisin`, `yaşına uygun değil` gibi yargılayıcı beden puanları **yok**.
- Farklı boy, beden, omuz/kalça dengesi, geniş göğüs, asimetrik anatomiler ve destek gerektiren hareket ihtiyaçları için model simülasyonu sınırlarını belirle; ölçü aralığı dışı avatar mesh kaymasını engelle; kullanıcıya yanlış beden güvencesi verme.
- Erkek/kadın zorunlu biyometrik kategorileri veya tek beden standardı yok. Kullanıcı istediği perakende kategoriye bakabilir.
- Yaşı küçük kullanıcıların beden görüntülerinin toplanması, paylaşılması veya reklam hedeflenmesi için ayrı yaş ve hukuki/App Store değerlendirme gereklidir; yaş grubu ve görsel içerik tasarımı incelemeden genel çocuk hedeflemesi yapma.
- Fit metinleri `bu cekette omuz 1 beden dar olabilir` gibi giysi ve tercih merkezli olmalı; kullanıcı bedenini problem olarak gösterme.

## 70.2 Erişilebilirlik seviyesi

VoiceOver ile bütün slider adları/değerleri/geri al, Dynamic Type ile sonuç kartı, high contrast, Reduce Motion, bir elle kullanım, sesli/klavyeli barkod fallback, haptik bağımlılığının olmaması, renk körlüğü için yalnız renkle uyum anlatmama, offline ekran okuyucu, ekran görüntüsünde mahrem bilgi sızıntısı kontrolü. Gerçek engelli kullanıcılar/erişilebilirlik denetimi izinli yapılmadan `tam erişilebilir` iddiası yok.

## 70.3 Güvenlik inceleme listesi

Diyet/beden algısı, cinsiyet stereotipleri, bölgesel kültür ayrımcılığı, engellilik varsayımı, çocuklara manipülatif satış, yüz/beden görselinin istemsiz ihracı, içerik görsellerinin telif hakları, kullanıcı kendi mahrem fotoğrafını paylaşırken önizleme ve redaksiyon. Şüpheli durumlarda `STOP_THE_LINE` ve insan denetimi.

---

# 71. COMMERCIAL TRUTH ENGINE — ÖLÇÜLEBİLİR PAZAR VE BÜYÜME

## 71.1 Ticari kullanım senaryoları (tamamı hipotez)

**B2C:** `Free private closet + quick shop + basic avatar`; premium ancak gerçek fayda ve maliyet doğrulanırsa: çoklu valiz, genişletilmiş stil planı/asset paketleri, gelişmiş kıyaslar. Gizlilik/silme/fundamental size uncertainty aboneliğe kapatılamaz.

**B2B:** pilot veri hazırlığı + perakende ürün eşleştirme + marka sayfasından deep link + ölçülebilir gerçek operasyon deneyi; katma değer olursa mağaza/marka abonelik ve entegre varlık dönüşümü. Garanti edilen kabin kuyruğu azalması/return düşüşü vaadi yok.

## 71.2 Üç test edilebilir halka

- **User proof loop:** gerçek tarama → anlaşılır karara dönüş → kıyafet seçimi → manuel sonuç → kalibre öneri → düzenli kullanım.
- **Retail proof loop:** yetkili SKU/size feed → hızlı ve daha az belirsiz tüketici deneyimi → kontrollü mağaza pilotu → ölçülmüş iş değeri → yeni feed kalitesi.
- **Distribution loop:** mağaza içi QR/App Clip veya stilist eğitim iş birliği → ilk ücretsiz fayda → isteğe bağlı uygulama kurulumu → tekrar kullanım; başkalarının beden/görselini viral pazarlama verisi yapma.

Her loop için hipotez kartı: `north-star`, dönüşüm, tamamlanma, p50/p95 sürtünme, uçtan uca maliyet, çekim yanlılığı, güvenli telemetri, basit A/B veya kontrollü önce-sonra, başarısızlık eşiği ve *shutdown* kararı.

## 71.3 Savaş planı değil, gerçek lansman planı

Faz 1: cihazda avatar+wardrobe+quick card ile ücretsiz kullanıcı testi. Faz 2: tek marka/kategori pilotu — moda zincirini tümden entegre etmeye çalışma. Faz 3: bir mağaza, bir bölge, ölçülebilir kabin deneyi. Faz 4: olumlu ve istatistiksel olarak anlamlı/iş açısından faydalı sonuç varsa 5–10 mağazaya genişle; aksi halde tüketici kullanımına odaklan. Pazarlama iddiaları gerçeği aşamaz. İlk partner bulunmadığında uygulama yine kullanışlı kalmalı.

---

# 72. MİMARİ / BAĞIMLILIK / İŞ PAKETLERİ — CLAUDE İÇİN GERÇEK İCRA

## 72.1 Ek alan sorumluluk haritası

| Modül | Tek veri sahibi | Çıktı | Entegrasyon |
|---|---|---|---|
| `DecisionComposer` | Result presentation | `ShoppingDecisionCard` | Existing Fit + Catalog + Wardrobe + Style; ağ yetkisi yok |
| `PrivateFitPassport` | Local preference/outcome storage | `FitObservation`, scope correction | Existing Avatar/Fit; *no network* |
| `FitTruthLab` | Fixture/evaluation harness | Evidence, accuracy by tier | Test target; prod inference ayrı |
| `GarmentMaterialModel` | Technical garment metadata | evidence-tiered material data | Catalog/Renderer |
| `RetailEntryRouter` | Input/URL validation | safe product intent | Full App/App Clip/Web adapter, optional |
| `RetailQueuePilot` | Partner-only operational server | anonymous queue state | Retail partner P2; consumer profile yok |
| `ShoppingGuard` | Local recommendation filter | `AlreadyOwned / Gap / FitWarning` | Wardrobe + DecisionComposer; sponsor veto |
| `StylePreferenceLedger` | Local editable preference memory | user-controlled ranking | Existing Octopus; no model self-update needed |
| `PrivateTransfer` | On-device export/import | encrypted package | v1.2 local schema; no default cloud |
| `AssetQualityFactory` | Build/partner preprocessing | versioned licensed assets | Blender pipeline, Runtime renderer |

**Gerekçe:** Bu, 10 mikroservis kurulacak demek değildir. En küçük modüler iOS proje / bir retail adapter yapısı. Çoğu saf Swift type/function ve test fixture'dır. Modüller mevcut kod gerçekliğine göre isimlendirilir; duplicative classes engellenir. Tüm sensitive data erişimi katman filtresinden geçer. Sürüm numaralı şema/contract, ADR ve test dosyası olmayan kritik yeni veri alanı üretme.

## 72.2 Kod yazma sırası (yeni iş paketleri)

| ID | Öncelik | İş | Ön şart | Kanıt |
|---|---|---|---|---|
| `V13-WP01` | P0 | v1.2 repo gerçeklik denetimi + change map | yok | `docs/audit/V13_BASELINE.md` |
| `V13-WP02` | P0 | yerel Fit Passport schema + migrations | Avatar/Fit mevcut ya da fixture | exportless local SQLite/SwiftData testleri |
| `V13-WP03` | P0 | giydim/uydu/uymadı input + manual edits | WP02 | iPhone akışı, VoiceOver testi |
| `V13-WP04` | P0 | tek kartta karar + abstain + hızlı kamera fallback | existing scan mock | iPhone E2E + p95 kaynak kayıtları |
| `V13-WP05` | P0 | dolabımda var mı kıyası | wardrobe dataset | negatif/false-positive testleri |
| `V13-WP06` | P0 | Fit Truth fixtures ve hata raporu | WP02–04 | gerçek/scoped accuracy report, no fake metrics |
| `V13-WP07` | P0 | inclusivity, body copy, a11y audit | existing UI | screen reader + hostile copy tests |
| `V13-WP08` | P1 | permission-reviewed purchase feedback and returns | WP02 + consent ledger | no-server-default privacy proof |
| `V13-WP09` | P1 | import/export with encrypted package | mature local schema | old/new real-device roundtrip |
| `V13-WP10` | P1 | brand 3D asset factory and garment quality gate | license/sample fixtures | geometry checks + rights register |
| `V13-WP11` | P1 | material/motion metadata and scoped preview | WP10 | correct tier + thermal degradation |
| `V13-WP12` | P1 | partner QR/deep-link entry and security | partner permission | scan-to-card integration and threat tests |
| `V13-WP13` | P2 | App Clip feasibility prototype, not full avatar | real code-size/platform check | device invocation measurements |
| `V13-WP14` | P2 | anonymous partner queue proof of concept | signed partner, actual pilot | tenant-isolation + ops pilot |
| `V13-WP15` | P1 | outcome/recommendation KPIs, experiment plan | user research / consent | registered experiment, privacy-safe metrics |
| `V13-WP16` | P1 | independent adversarial audit / release review | dependency-safe modules | reproducible evidence registry |

**Kritik yürütme kuralı:** Belgenin tamamını tek dev PR, tek simülatör testi veya tek agent loop ile bitirmeye çalışma. P0 için `WP02–07` gerçek cihazda kanıtlanana kadar retail queue/App Clip/cloth-physics yalnız spec/spike olabilir. Yarım kalanı kesin sürüm raporunda `BLOCKED`, `UNVERIFIED`, `SPEC_ONLY` ile göster.

## 72.3 Delivery contracts

Her WP: `Problem, user, supported input, privacy, data owner, failure states, UX screenshot states, unit/integration/UI/device tests, perf/thermal, evidence path, ADR, rollback, sign-off`. Özgün/sentetik fixture'lar belirgin etiketli. `Docs-only completion` **yasak**. Firma lisansı/ödeme/App Store/reklam gönderimi/gerçek kullanıcı verisi için insan yetkisi şart.

---

# 73. v1.3 KABUL TESTLERİ — 64 AYRI KONTROL (T-V13-001..064)

Testler **yazılacak ve çalıştırılacak şartnamelerdir**. Bu dosyada test sonuçları yoktur. Bütün testler atomik otomasyona dönüşür; gerçek cihaz ve kullanıcı incelemesi gerektirenler açık manuel protokol olarak raporlanır.

## 73.1 Quick Decision (001–010)

1. `T-V13-001`: İlk kullanımda hesapsız ürün kartına erişilir.
2. `T-V13-002`: Kamera izni yoksa manuel ürün kodu çalışır.
3. `T-V13-003`: Yanlış SKU için uydurma spesifik ürün çıkmaz.
4. `T-V13-004`: İki benzer adayda doğru varyant sorulur.
5. `T-V13-005`: Ağ yoksa eski stok güncel gibi sunulmaz.
6. `T-V13-006`: Fit kaynağı yoksa tek beden garantisi yok.
7. `T-V13-007`: G0 genel mesh gerçek ürün 3D olarak etiketlenmez.
8. `T-V13-008`: Dolap yoksa `sahip değilsin` sonucu çıkmaz.
9. `T-V13-009`: Reklam/sponsor beden tavsiyesini değiştiremez.
10. `T-V13-010`: Gerçek iPhone'da soğuk/ılık tarama p50/p95 ve downgrade ölçülür.

## 73.2 Fit Passport (011–020)

11. `T-V13-011`: Kullanıcı fit observation kaydeder; yerelde kalır.
12. `T-V13-012`: Dar/bol/tam oldu seçimi kıyafet türüne uygun etiketlenir.
13. `T-V13-013`: Bir tişört sonucu farklı kategorilere global kural yapılmaz.
14. `T-V13-014`: Bir markadaki M başka markaya otomatik M yapılmaz.
15. `T-V13-015`: Ürün revizyonu eski beden tavsiyesini geçersiz kılar.
16. `T-V13-016`: Kullanıcı yanlış kaydı değiştirir ve eski çıkarım geri alınır.
17. `T-V13-017`: Kullanıcı Fit Passport'u ayrı olarak silebilir.
18. `T-V13-018`: Partner isteklerinde beden/fit outcome çıkışı sıfırdır.
19. `T-V13-019`: Sadece 1 gözlemden kesin olasılık yüzdesi üretilmez.
20. `T-V13-020`: Persona/fit düşük veri koşulunda abstain eder.

## 73.3 Truth Lab, Material, Inclusion (021–033)

21. `T-V13-021`: `fit` ölçümü ile `render` güzellik skorları karıştırılmaz.
22. `T-V13-022`: Synthetic fixture performansı gerçek pilot gibi sunulmaz.
23. `T-V13-023`: False confident fit failure sayısı ayrı raporlanır.
24. `T-V13-024`: Beden segmenti dışı mesh deformasyonu fail-safe gösterilir.
25. `T-V13-025`: Render/beden testleri düşük güç/termal durumda bozulmadan degrade olur.
26. `T-V13-026`: Malzeme kaynağı bilinmiyorsa ısı/su dayanımı iddiası yapılmaz.
27. `T-V13-027`: Hareket sahnesi M0/M1/M2/M3 katmanı dürüst etiketlenir.
28. `T-V13-028`: Astrol./numerol. opt-in yokken kişiye gizli stil puanı uygulanmaz.
29. `T-V13-029`: Vücut utandırıcı dil için kopya tarama + insan incelemesi geçilir.
30. `T-V13-030`: VoiceOver ile Slider ve Undo tam işlem akışı tamamlanır.
31. `T-V13-031`: Dynamic Type + high-contrast ile sonuç kartı okunur.
32. `T-V13-032`: Renk uyumu tek renkle anlatılmaz.
33. `T-V13-033`: Çocuk/hedef yaş ve reklam incelemesi olmadan küçük hedeflemeli ürün akışı yayına çıkmaz.

## 73.4 Retail Entry / Queue (034–044)

34. `T-V13-034`: QR URL'si kötücül parametrede reddedilir.
35. `T-V13-035`: Deep link'te kişisel body/DOB data yok.
36. `T-V13-036`: App Clip/web'e tam app Fit Passport varmış gibi yüklenmez.
37. `T-V13-037`: Geçerli mağaza SKU'su ürün kartını açar.
38. `T-V13-038`: QR altyapısı yokken manuel tarama sorunsuz.
39. `T-V13-039`: App Clip fizibilite güncel Apple limitleriyle dokümante edilir.
40. `T-V13-040`: Queue Ticket yalnız doğru perakende tenant'ında görünür.
41. `T-V13-041`: Çakışan check-in işlemleri çift kabin ataması oluşturmaz.
42. `T-V13-042`: No-show/expiry deterministiktir; geri dönüş imkânı vardır.
43. `T-V13-043`: Offline mağaza personel durumları kullanıcıyı yanlış garantilemez.
44. `T-V13-044`: Kuyruk etkisi kontrol/başlangıç verisi olmadan ticari başarı diye ilan edilmez.

## 73.5 Shopping Guard / Learning (045–052)

45. `T-V13-045`: Benzer ürün yanlış pozitifse eşdeğer olarak gösterilmez.
46. `T-V13-046`: Elindeki ürün önerilmeden ücretli ürün zorlanmaz.
47. `T-V13-047`: Satın alma maliyetini bilmeden `tasarruf` kesin denmez.
48. `T-V13-048`: Giyildi kaydı isteğe bağlıdır; kullanıcı istemezse yok.
49. `T-V13-049`: `Neden önerdin?` sebepleri kaynak/tercihle eşleşir.
50. `T-V13-050`: Kullanıcı bir öğrenme nedenini silebilir.
51. `T-V13-051`: 3 stil seçeneği çeşitlilik üretir; öneri baskıcı olmaz.
52. `T-V13-052`: Ödeme/sponsorlu içerik fit sonucunu etkilemez.

## 73.6 Portability / Asset Rights / Ship Gate (053–064)

53. `T-V13-053`: Şifreli export'ta ham özel veriler açık metin bulunmaz.
54. `T-V13-054`: Yanlış parola/bozuk paket içe alınmaz.
55. `T-V13-055`: Eski sürüm migration ilişkisel bütünlüğü korur.
56. `T-V13-056`: Export/import avatar, dolap, fit, travel referanslarını roundtrip eder.
57. `T-V13-057`: Kullanıcı istemeden cloud veya retail'e veri çıkışı yok.
58. `T-V13-058`: Kullanıcı kendi export'unu silme davranışını anlar; dış paylaşılan kopyaların ayrı olabileceği açıklanır.
59. `T-V13-059`: Lisans iptali olan 3D ürün varlığı ağ/önbellek koşuluyla kurala göre kaldırılır.
60. `T-V13-060`: 3D mesh avatar morph uç değerlerinde patlamaz/penetration kontrolü yapar.
61. `T-V13-061`: Tam App / App Clip / web farkları gerçek cihazda belge ve boyut testiyle sınanır.
62. `T-V13-062`: P0 hiçbir partner hesabı olmadan çekirdek değer sunar.
63. `T-V13-063`: Her iddia kaynak, ilgili test, tarih, cihaz, commit hash ile ilişkilendirilir.
64. `T-V13-064`: Bağımsız denetçi `TESTED` ile `USER-VALIDATED` ve `LIVE-PARTNER` arasını doğru ayırır.

---

# 74. CLAUDE START HERE — v1.3 ORTAK EMİR / FIRST EXECUTION SPRINT

> **CLAUDE CODE:** Önce birleştirilmiş **v1.3 canonical** dosyasının §§0, 59–74, 23–38, 39–58 ve sonra 1–22 bölümlerini incele. Önceki işi silme, yeniden başlatma veya ispat olmadan `tamamlandı` deme. Proje reposunda güvenle inceleme ve yerel kod/test geliştirme yetkin var; ücret, üretim yayını, yeni dış hesap, marka sözleşmesi, insan verisi paylaşımı ve kamuya açık işlemler için ayrıca açık yetki gereklidir.

**İlk çalışma seti (sıralı):**

1. `git status`, branch, var olan commit/çalışma dizini, toolchain/CI, iOS hedefleri, cihaz/simulator, dependency/license, mevcut kullanıcı akışları/kanıtları denetle. `docs/audit/REALITY_BASELINE_v1.3.md` hazırla. Varsa önceki çalışma üzerine ekle, kayıp yaratma.
2. v1.0–v1.2 çekirdek requirement/feature/test indeksini yükle. Bu ekteki `V13-WP*`, `T-V13-*`, `G-FIT-TRUTH` izlerini registry'e ekle. Aynı işi yapan birden fazla sınıf/ajan oluşturma.
3. Yeni özellikten **minimum demonstrable vertical slice** seç: `bir kaydedilmiş kullanıcı avatarı (veya nötr varsayılan) + bir gerçeklik etiketi olan örnek ürün + yerel dolap benzerlik kontrolü + anlaşılır tek karar kartı + kullanıcının giydim/uydu/uymadı geri bildirimi`. Ürün katalog fixture'ı özgün ve **sentetik olarak açıkça** etiketli.
4. P0 Fit Passport local persist / edit / delete; kaynak izli Decision Card; Shop Guard; erişilebilir UI ve iPhone görünüm/performans izlerini üret. Önce gerçek sistem build'inin başarısını ve mevcut testi koru; başarısız olunca neden/gate raporu çıkar.
5. Bir cihaz yoksa simulator + test runner çalıştır, `REAL_DEVICE_BLOCKED` yaz. App Clip, marka API, iade/ödeme, B2B queue, gerçek kumaş fizik simülasyonu için harici koşul/kanıt olmadan tamamlanmış iddiası kurma.
6. `docs/evidence/V13_PROOF_REGISTER.md`, `docs/adr/`, `docs/metrics/`, `docs/launch/EXPERIMENT_REGISTER.md` oluştur. Test otomasyonları ve başarısız fixture'ları da sakla.

## 74.1 Tamamlama raporu (her teslimde)

```text
WEARFORM v1.3 — REALITY / EXECUTION REPORT
Repo / branch / commit / git status:
Scope actually touched:
Features: SPEC_ONLY | CODED | TESTED | DEVICE_VERIFIED | USER_VALIDATED | LIVE_PARTNER
User journey + screenshots/video paths:
Unit / integration / UI / on-device test outputs:
Measured performance / thermal / energy with device labels:
Privacy proof, no-body-data-egress proof:
Product/fit/asset source licenses:
Known bugs and blocker IDs:
Next smallest safe work package:
Rollback instructions:
Independent reviewer verdict:
```

**SON TALİMAT:** `GOD LEVEL` = basit kullanıcı yüzeyi + zor mühendisliğin görünmeyen doğru uygulanışı + gerçek kanıt + dürüst belirsizlik. Daha çok ekran/ajan/özellik otomatik olarak daha kaliteli ürün demek değildir. Çekirdeği cihazda doğrula, sonra gerçek kullanıcı geri bildirimi ve markalarla partner pilotlarıyla büyüt.

---

## v1.3 Kaynak/yeniden doğrulama notu

Bu kaynaklar **platform yetenekleri** ve sınırlamalar hakkında referanstır, WEARFORM'un uygulanmış olduğuna kanıt değildir. Uygulamadan önce en güncel SDK/hesap/ülke koşulları tekrar doğrulanmalıdır:

- Apple Photos privacy and picker: https://developer.apple.com/documentation/photokit/delivering-an-enhanced-privacy-experience-in-your-photos-app
- Apple App Clips: https://developer.apple.com/documentation/appclip
- Apple App Clip features, limits: https://developer.apple.com/documentation/appclip/choosing-the-right-functionality-for-your-app-clip
- Apple Core ML on-device update (updatable models only): https://developer.apple.com/documentation/coreml/personalizing-a-model-with-on-device-updates
- Apple App Clip invocation configuration: https://developer.apple.com/documentation/appclip/configuring-the-launch-experience-of-your-app-clip

**No unauthorized scraping, no invented real-time stock, no universal virtual-fit guarantee, no unapproved body data collection, no compulsory biometrics.**

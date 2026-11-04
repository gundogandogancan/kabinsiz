# KABİNSİZ — v3.6 Rakip Gerçeklik Denetimi ve Claude Code Teknik Emri

**Tarih:** 4 Kasım 2026  
**Denetlenen repo:** `gundogandogancan/kabinsiz`, `main`, SHA `30ed2ef9ab38db939ca4faf2b098f83fe256e23a`  
**Bu belge:** v3.5'in yerine geçen kapsam artışı değil, rakip analizi üzerinden hedefi daraltan **bağlayıcı denetim eki**.  
**Ana ilke:** Maksimum zekâ, minimum arayüz. Kanıt olmadan tamamlandı yok.

## 1. Önce tarihleri ve rakipleri doğru sınıflandır

| Ürün | 4 Kasım 2026 için doğrulanmış bilgi | Kabinsiz açısından ders | Bilinemeyen |
|---|---|---|---|
| **Alta Daily** | Ücretsiz dijital dolap; fotoğraftan ürün temizleme/dolap, kişisel avatar, hava ve takvime göre kombin, seyahat, alışveriş ve B2B entegrasyon. Meta, SAM/SAM 3 ile segmentasyon kullandıklarını ve 20M+ görüntü işlediklerini yazıyor. | **En yakın bütün ürün rakibi.** Dolap girişindeki sürtünmeyi azalt, kumaş/beden/ürün kimliğini ayrı doğrula. | Üretime özel tam pipeline, özel model ağırlıkları, cihaz/bulut dağılımı, gerçek beden başarımı. |
| **Doji** | Ücretsiz iOS uygulaması. Birkaç fotoğraftan kişiye benzeyen görünüm, ürün linki, kişisel styling ve Safari uzantısı sunuyor. | Avatar benzerliği ve ürün linkinden deneme akışını karşılaştır. | Tüm iç model mimarisi, fotoğrafın 3D meshe dönüşüp dönüşmediği, real-time fiziksel kalıp. |
| **Anywear / Decart Lucy V-TON** | Beta döneminde ücretsiz gerçek zamanlı kamera tabanlı prova; bulutta Lucy V-TON modelini kullanıyor. | Canlı video ile *görüntü bazlı* prova deneyiminin kalite hedefini belirle. | Model ağırlıkları, ayrıntılı mimari, bedeni gerçekten ölçtüğü iddiası. |
| **Google Shopping Virtual Try-On** | Ücretsiz ürün görselleştirme; fotoğraf/yaratılmış beden görüntüsü, büyük Shopping Graph. **Doppl kapandı: 30 Nisan 2026.** | Katalog doğruluğu ve alışveriş keşfini karşılaştır. | Google'ın özel modelini veya Shopping Graph'i aynen kopyalayabilmek. |

**Birincil kaynaklar:**
- Alta: https://www.altadaily.com/
- Meta'nın Alta mühendislik yazısı: https://ai.meta.com/blog/alta-daily-fashion-app-segment-anything/
- SAM 3 repo/kurulum/lisans: https://github.com/facebookresearch/sam3
- Doji App Store: https://apps.apple.com/us/app/doji-try-on-designer-fashion/id6737292650
- Anywear: https://anywear.decart.ai/live-virtual-try-on
- Google Shopping: https://blog.google/products-and-platforms/products/shopping/how-to-use-google-shopping-try-it-on/
- Doppl kapanma: https://support.google.com/labs/answer/16537062?hl=en
- Marka entegrasyonları: https://techcrunch.com/2026/02/14/clueless-inspired-app-alta-partners-with-brand-public-school-to-start-integrating-styling-tools-into-websites/

## 2. Rakibin mühendisliğini ne kadar biliyoruz?

**Alta hakkında doğrulanmış:** Meta'nın SAM/SAM 3 ile giyim ürünü ayırma (segmentation), karmaşık fotoğraflarda maske kalitesi, moda görsellerinde karşılaştırmalı eval ve düşük maliyetli toplu işleme açıklaması. Alta SAM 3D'yi araştırıyor; bunun üretimde doğrulanmış fiziksel kıyafet motoru olduğu ilan edilmedi. SAM 3 güncel açık kaynak kodu `facebookresearch/sam3`; 848M parametre ve CUDA GPU önkoşulları, iPhone'da varsayılan yerel çalışacağı anlamına gelmez. `SAM License` ayrı değerlendirilmelidir.

**Bilinmeyen:** Alta'nın tüm model ağırlıkları, kişisel stil sıralama katsayıları, garment rig, fiziksel drape motoru, ticari müşteri/partner verileri ve kapalı model kodu. `SAM 3 kurmak = Alta kopyasını kurmak` değildir. Yetkisiz proprietary model tersine mühendisliği yapılmaz.

**Önceki Claude belgelerinde:** v3.2 içinde Alta'nın *ürün karşılaştırması* mevcuttur. Meta'nın 6 Nisan 2026 tarihli SAM 3 mühendislik ifşası/benchmarkı ve ölçülebilir eşdeğer segmentasyon planı bu yeni v3.6 ekiyle ekleniyor. Repo içindeki `CLAUDE.md` hâlâ kanonik v2.1'e referans veriyor; v3.6'nın gerçekten repo içine alınması Claude tarafından doğrulanmalı.

## 3. Kabinsiz karşılaştırma — varsayılan statü: yalnız kod veya çalıştırılmış kanıt varsa 'var'

| Alt sistem | `main`'de görülen durum | Hedeflenen örnek kanıt |
|---|---|---|
| Tasarım sistemi | Quiet Atelier renk ve tipografi tokenları kodlu | On-brand screenshot ve erişilebilirlik testleri |
| 360° nötr beden | RealityKit mesh, elle döndürme | Gerçek cihaz 360°, performans |
| Kişisel yüz/saç | Üretim avatarı doğrulanmamış | Kullanıcı onaylı benzerlik testi, yerel işleme |
| Günlük giyinmiş avatar | `TodayView` bunu henüz üretmiyor | Tam kıyafet mesh'i ile günlük outfit video/screenshot |
| Fotoğraftan dolap | `WardrobeView` manuel/sentetik | Seçilen fotoğraftan obje maskesi, kategori, tekrar eşleşme, kullanıcı onayı |
| Barkod gerçek ürün | `ScanView` manuel sentetik kod | Gerçek cihaz kamera → barkod → doğrulanmış partner ürün varyantı |
| Kumaş/beden | DomainSchema sözleşmeleri mevcut | Üretici ölçüsüyle ürün bazlı karşılaştırma; belirsizlik dürüstlüğü |
| Live Mirror | Durum makinesi/sözleşmeler | Kamera/video provider, giysi dönüşümü, latency/occlusion/identity testleri |
| Brand partner portal | Doğrulanmış gerçek entegrasyon yok | Partner feed/webhook, lisans/TTL, revizyon, değişiklik testi |
| Ahtapot | `OctopusCoordinator` var | Yetki/öncelik/cache/timeouts çok ajanlı uçtan uca test |

**Gerçeklik seviyesi:** Çalışan temel prototip (L1/5 iç değerlendirme); ticari/denenmiş fiziksel uyum henüz değil. Repo kanıtlarını tekrar çalıştırmadan PASS'leri sahiplenme.

## 4. Ürün stratejisi: tek vaade odaklan

**Müşterinin cümlesi:** "Bunu mağazada gördüm. Bu tam ürün hangisi, benim bedenime ne kadar uygun ve üzerimde nasıl duruyor?"

- **Öncelikli kullanıcı akışı:** `Barkod / link / fotoğraf → doğrulanmış ürün varyantı → beden için kanıt/eksiklik → 3D veya görsel deneme → satın alma/alternatif`. 
- **İkinci akış:** `Seçilen iOS fotoğrafları → kıyafetleri ayrıştır → deduplikasyon → onay → yerel gardırop → günlük kombin`.
- **Üçüncü akış:** `Gerçek kamera → kimlik/poz korunarak hareketli prova → video görsel güven skoru → doğru belirsizlik etiketi`.

**Temel fark savımız:** 'ücretsiz avatar + öneri' tek başına fark değil. Doğrulanmış ürün varyantı, gerçek giysi ölçüsü, kişisel beden gizliliği, yerel anlık etkileşim ve gerçek prova karşılaştırması fark yaratabilir. Bu bir *hipotez*, rakiplerin bunlardan hiçbirini yapmadığı iddiası değildir.

## 5. Teknik karar: segmentasyonun çekirdeği

**Benchmark / eğitim etalonları (cihaz üstü dağıtımdan ayrı):** Meta SAM 3.1, daha hafif cihaz içi segmentasyon modeli, Apple Vision/VisionKit görüntü işleme, gerektiğinde lisanslı görsel embedding ve renklendirme/kategori modeli.

Tek görüntü için istenen pipeline:
`PhotoPicker seçimi → on-device decode/EXIF kontrol → garment detection → segmentation → category/color/pattern → multi-photo garment embedding → dedupe → brand/logo candidate → source confidence → user review → encrypted wardrobe`.

Ürün kalıbı, lif yüzdesi, arka yüz ve fiziksel giysi ölçüleri *fotoğraftan güvenilir kesin bilgi* değildir. Bunlar ürün feed'i, etiket OCR, kullanıcı ölçüsü, CAD/teknik föy, objektif deneme ile tamamlanır. 3D kıyafet G1 (şablon) ve G2 (ölçüm+teknik kalıp) ayrı kategorilerde sunulur.

**Benchmark seti önerisi:** 8 kategori × çoklu arka plan × model üstünde / yerde / askıda; düşük ışık, benzer renk, ince askı, çoklu obje, aynı kıyafetin çoklu açıları. Segment mask IoU, recall, duplicate precision, uygulama RAM ve saniye başına kıyafet başına enerji maliyeti. Eğitim için kullanıcı fotoğrafları varsayılan olarak sunucuya GİTMEZ.

## 6. Fiziksel bedeni tanıma ve gerçekçilik — etalon

**Üç ayrı kalite ekseni:** (a) kişinin yüz/beden benzerliği, (b) ürün dokusu/logo/renk ve video hareket tutarlılığı, (c) gerçek beden/fit isabeti. A ve B iyi diye C doğru sayılmaz.

- Önce ölçüleri yerel tutulan kişisel 3D avatar + ürün mesh + RealityKit.
- Sonra aynı kişi/ürün/beden için gerçek deneme görüntüleriyle izinli kör karşılaştırma.
- Live video, ön/yan/arka, kollar yukarı, dönme, çoklu katman ve mevcut giysiyi koruyup değiştirme durumları ile test edilir.
- Ürün varyantı doğrulanmadıysa asla kesin 3D ürün diye sunma. Üretken video fiziksel beden tavsiyesinin yerine geçmez.

## 7. Claude'a uygulanacak ölçülebilir iş paketi

**COMP-01 — Rakip kanıt dosyası:** Altı kaynak için `VERIFIED_PUBLIC`, `CLAIM`, `UNKNOWN` tablosu ve yerel kaynak linki; Doji/Alta/Anywear'in görsel özelliklerini kullanıcı beklentisi benchmarkına çevir, rakibin kodunu çıkarmış gibi konuşma.

**COMP-02 — Dolap modeli karşılaştırması:** SAM 3.1'i izolasyonlu dev makinesinde indirmenin ve benchmark etmenin lisans/CPU/GPU önkoşullarını denetle. iPhone'a doğrudan ekleme. Hafif Core ML adayına karşı *kendi hakları olan* kıyafet görüntülerinde kör mask testi yap.

**COMP-03 — Gerçek doğrulanmış katalog pilotu:** 1 partner, 20–50 ürün varyantı ve doğru marka+model+renk+beden kimliği; ürün lisansı, TTL, revizyon, eksiklik, ne zaman yanlış eşleşmenin reddedileceği.

**COMP-04 — Gerçek kıyafet model üzerinde:** 1 doğrulanmış ürünün 3D varlığını 360° avatar üzerine uygula; ürün kimliği/fiziksel fit/visual tier'i farklı tut. Ekran görüntüsü ve gerçek cihaz testi.

**COMP-05 — Yerel ayna:** Kamera erişimi ve vücut takibi; bir kıyafeti giydirme, hareket ve örtülme testleri; gerçek koşullar kanıtlanmadan 'fotogerçekçi' dememek.

**COMP-06 — Kurallı stil kararları:** hava, sahip olunan kıyafet, temiz/kirli, etkinlik, bütçe, renk/siluet ve tekrar kullanımı tek kombinde bağla. Her sabah önbellek; kullanıcıya üç sekmeli, minimum arayüz.

**COMP-07 — Ekran kalitesi:** Ana ekran tek büyük giyinmiş kişisel model+şehir sahnesi+bir aksiyon; kategoriler yalnız ilgili kıyafete dokununca. Eski kart karmaşasını geri getirme. Bir Figma/SwiftUI/simülatör karşılaştırma seti ve gerçek kullanıcı sürtünme ölçümü.

**COMP-08 — Bağımsız onay:** tasarım/ML QA/ölçü bilimci/privacy/security/retail data audit ayrı imza. `CODED`, `TESTED_SIMULATOR`, `DEVICE_VERIFIED`, `USER_VALIDATED`, `PARTNER_VERIFIED` etiketlerini koru.

**Çıktı formatı:** İlk yanıt en fazla 2 sayfa: `Bugünkü gerçeklik → rakiple fark → tek uygulanan iş paketi → test kanıtı → sonraki engel`. Konu dışı ansiklopedi yazma; çalışır kod + gerçek kanıt öncelikli. Yalnızca gerekli dosyaları değiştir ve PR/diff/test bildir.

## 8. Başarı kapıları — önerilen hedef, henüz ölçülmedi

1. Barkod bulundu ve doğru lisanslı ürün varyantına bağlandı mı? Yanlış eşleşme `UNKNOWN` ile bitti mi?
2. Fotoğraftan kıyafet ayrıştırmada benchmark segment IoU / kullanıcı düzeltme oranı nedir?
3. Giyinmiş model 360° dönüşte kıyafeti korudu mu, cilt/giysi çakışması var mı?
4. Kişisel avatarı kullanıcı 'bana benziyor' olarak onayladı mı?
5. Live Mirror kıyafet değişiminde kimlik, logo, kol/saç örtülmesi ve zaman tutarlılığı korunuyor mu?
6. Ekran ilk açılış p95, cihaz ısınması, pil ve RAM gerçek cihazda ölçüldü mü?
7. Marka anlaşması veri hakkı/özel görünüm/ölçü/GTIN kullanımına gerçekten izin veriyor mu?
8. Beden önerisi bağımsız gerçek denemelerle karşılaştırıldı mı?

**Go/No-Go:** İlk 2 akış ile görsel ayna 1 cihaz/1 marka üzerinde başarıyla kanıtlanmadan 'tüm markalara/gerçek kabin yerine geçti' pazarlamasına geçme. Hedef ticari veri ve gerçek fiziksel doğrulukla test edilir.

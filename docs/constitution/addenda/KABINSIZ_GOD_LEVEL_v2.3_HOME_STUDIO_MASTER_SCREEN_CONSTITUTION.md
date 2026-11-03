# KABİNSİZ — GOD LEVEL v2.3
## HOME STUDIO / ANA SAYFA USTALIK ŞARTNAMESİ

**Ürün:** Kabinsiz  
**Belge türü:** Claude Code için bağlayıcı ürün + UI/UX + etkileşim şartnamesi  
**Tarih:** 2026-11-03  
**Durum:** ADDENDUM / v2.2 üzerine zorunlu düzeltme  
**Amaç:** Ana sayfayı sıradan kart-listesi görünümünden çıkarıp, kullanıcının her sabah kendi modelini, bugünün kombinini ve bulunduğu şehirle ilişkili sahne arka planını gördüğü yaşayan bir “kişisel stil stüdyosu”na dönüştürmek.

> **Bağlayıcı karar:** Bu belge, `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md` ve `KABINSIZ_GOD_LEVEL_v2.2_QUIET_ATELIER_UI_RECOVERY.md` üzerinde **öncelikli ana sayfa düzeltmesi** olarak uygulanır. Çelişki durumunda, ana ekran / home studio davranışı için bu belge geçerlidir.

---

# 01 — YENİ ANA SAYFA FELSEFESİ

Kabinsiz ana sayfası artık bir dashboard olmayacak.

Kabinsiz ana sayfası şu hissi vermelidir:

- Kullanıcı uygulamayı açtığında **kendi stil odasına** girmiş gibi hissetmeli.
- İlk gördüğü şey kart yığını değil, **kendi modeli** olmalı.
- O gün giymesi önerilen kombin, modelin üstünde **hazır giydirilmiş** durumda görünmeli.
- Arka plan, bulunduğu şehir ve günün hissiyle bağlantılı olmalı.
- Hava durumu, ışık, katman ihtiyacı ve sahne atmosferi birbirini desteklemeli.
- Kullanıcı tek tek parçaları değiştirebilmeli: üst, alt, ayakkabı, çanta, kemer, aksesuar.
- İsterse tek tuşla “**yeni kombin üret**” demeli ve model anında yeni kombinle güncellenmeli.

Bu nedenle ana sayfa =

**Personal Home Studio + Today Outfit + Interactive Styling Surface**

olacaktır.

---

# 02 — ANA SAYFA İLK AÇILIŞTA NE GÖSTERMELİ?

## Zorunlu üst seviye yapı

1. **Üst bar / sakin başlık alanı**
   - Kabinsiz logotype
   - şehir
   - sıcaklık / hava durumu özeti
   - profil / bildirim

2. **Hero Studio alanı (sayfanın ana kalbi)**
   - kullanıcının 3D modeli
   - bugünün kombinini model üzerinde giyinmiş halde gösteren canlı sahne
   - şehir bağlamlı arka plan
   - hava durumuna göre ışık / atmosfer
   - direkt etkileşim: kıyafetin parçalarına tıklama

3. **Hızlı stil eylemleri**
   - Üstü değiştir
   - Altı değiştir
   - Ayakkabı değiştir
   - Çanta / kemer / aksesuar değiştir
   - Yeni kombin üret
   - Mağazada tara

4. **Bugün neden bunu öneriyoruz?**
   - hava durumu
   - konum / sahne
   - stil hedefi
   - etkinlik / takvim / plan
   - bütçe veya tekrar kullanım bilgisi

5. **Alternatif kombinler**
   - 2–4 alternatif görünüm
   - aynı model üstünde önizleme
   - “Daha sade”, “Daha güçlü”, “Daha rahat”, “Daha şık” gibi yönler

---

# 03 — ANA SAYFANIN TEMEL DAVRANIŞI

Ana sayfa “scrollable list” merkezli değil, **scene-first** olmalı.

Yani kullanıcı uygulamayı açınca önce aşağıdakileri görmeli:

- kendi avatarı / kendi modeli
- o günün kombini
- yaşadığı şehir veya seçtiği günün bağlamına uygun arka plan
- kıyafetin üzerinde dokunulabilir bölgeler

Liste ve detaylar sahnenin altında ikinci katmanda yer almalı.

---

# 04 — ŞEHİR BAĞLAMLI ARKA PLAN SİSTEMİ

## Ana kural
Arka plan asla rastgele estetik fotoğraf olmayacak.

Arka plan şu sinyallerle üretilecek / seçilecek:

- kullanıcının yaşadığı veya o anda bulunduğu şehir
- günün saati
- hava durumu
- stil bağlamı (iş, günlük, akşam, seyahat, buluşma)
- uygulamanın görsel tonu

## Örnekler

### İstanbul kullanıcısı
- Galata çevresi / Galata Kulesi yakınında sokak hissi
- Bej taş dokular, hafif sabah ışığı, doğal gölge
- Eğer yağmurluysa sokak zemini daha nemli / daha koyu atmosfer
- Eğer serinse katmanlı kombin

### Barcelona kullanıcısı
- sıradan ama estetik bir Barcelona sokağı
- Akdeniz sıcaklığı, açık tonlu duvarlar, hafif şehir yaşamı hissi
- Sahne turistik kartpostal değil; doğal günlük yaşam hissi taşımalı

### Başka şehirler için ilke
- kartpostal klişesi değil
- şehir ruhu okunmalı
- sahne kıyafetin önüne geçmemeli
- kullanıcıyı yutmamalı, sadece desteklemeli

## Teknik karar
- Bu arka planlar uygulama içinde **scene template** sistemiyle çalışmalı.
- Blender tarafında temel çevre sahneleri hazırlanabilir.
- Runtime’da RealityKit/Metal tarafında hafifletilmiş arka plan varyasyonları gösterilir.
- Ağır Blender render’ı cihazda gerçek zamanlı çalıştırılmaz.

---

# 05 — HAVA DURUMU SAHNEYE NASIL YANSIMALI?

Sadece “18°C” yazısı yetmez.

Hava durumu üç katmanda görünmeli:

1. **Kombin kararı**
   - katman sayısı
   - kumaş kalınlığı
   - dış katman ihtiyacı
   - ayakkabı tipi

2. **Görsel atmosfer**
   - ışık tonu
   - gölge sertliği
   - bulutluluk / yağmur hissi
   - arka planın doygunluğu

3. **Açıklama katmanı**
   - “Bugün rüzgâr ve serinlik nedeniyle dış katman öneriyoruz.”
   - “Öğleden sonra ısınacağı için katman çıkarılabilir.”

## Yasak
- bakım etiketindeki 30°C yıkama ile hava sıcaklığı karıştırılmayacak.
- sahne “yağmurlu” görünüyorsa kıyafet kararı da buna mantıklı şekilde eşlik etmeli.

---

# 06 — KULLANICININ KENDİ MODELİNİ GÖRMESİ ZORUNLU

Bu belgeyle şu karar zorunlu hale gelir:

**Ana sayfada kullanıcının kendi modeli görünmeden tasarım tamamlanmış sayılmaz.**

## Model özellikleri
- kullanıcının nötr / kişisel 3D bedeni
- gri / nötr beden tabanı
- kıyafetler model üstünde canlı durmalı
- modelin pozu sakin ve doğal olmalı
- abartılı animasyonlar olmamalı
- model, moda uygulaması standardında rafine görünmeli

## İzin verilen görsel durumlar
- ön görünüm
- hafif 3/4 açı
- kullanıcının drag ile döndürebildiği görünüm

## Yasaklar
- yapay, oyuncak veya fazla avatar benzeri görünüm
- çizgi film estetiği
- aşırı parlayan materyaller
- sahneye göre anlamsız pozlar

---

# 07 — KOMBİN ANA SAYFADA HAZIR GÖRÜNMELİ

Kullanıcı sabah uygulamayı açtığında şunları anında anlamalı:

- “Bugün bana önerilen kombin bu.”
- “Bu kombin benim modelimin üzerinde böyle duruyor.”
- “İstersem parça parça değiştirebilirim.”

## Bu nedenle ana sahnede zorunlu CTA’lar
- Üstü değiştir
- Altı değiştir
- Ayakkabı değiştir
- Çanta değiştir
- Kemer değiştir
- Aksesuar değiştir
- Tüm kombini yenile

Bunlar tek tek sahne çevresinde küçük etiket butonları veya alt tarafta yatay edit bar olarak verilebilir.

---

# 08 — KOMBİNİ PARÇA PARÇA DEĞİŞTİRME DENEYİMİ

## Etkileşim modeli
Kullanıcı model üstünde ilgili parçaya dokunduğunda:

- ilgili bölüm highlight olur
- alt panel açılır
- o kategoriye ait alternatifler görünür
- kullanıcı seçtiği yeni parçayı anında model üzerinde görür

## Parçalanmış kategori yapısı
- Üst giyim
- Alt giyim
- Dış katman
- Ayakkabı
- Çanta
- Kemer
- Takı / aksesuar
- Gözlük / şapka gibi stil tamamlayıcılar

## Kullanıcı akışı
1. kullanıcı cekete dokunur
2. alt drawer açılır
3. “Dolabındaki alternatif ceketler” görünür
4. “Mağazada uyumlu ceketler” ikinci sekme olur
5. seçim yapılınca model gerçek zamanlı güncellenir

---

# 09 — “YENİ KOMBİN ÜRET” DÜĞMESİ

Bu eylem ana sayfada görünür ve güçlü olmalı.

## Çalışma mantığı
“Yeni kombin üret” tetiklenince sistem:
- hava durumunu
- takvimi / planı
- kullanıcının tercihlerini
- dolabındaki parçaları
- tekrar kullanım durumunu
- temizlik durumunu
- bütçeyi
- istenirse stil hedefini

birleştirerek yeni görünüm üretir.

## Kullanıcıya sunulabilecek varyasyon yönleri
- daha sade
- daha güçlü
- daha rahat
- daha şık
- daha premium
- daha yaratıcı
- hava koşuluna daha dayanıklı

---

# 10 — ANA SAYFA = STÜDYO GİBİ OLMALI

Bu istek bağlayıcıdır.

Kabinsiz ana sayfası:
- bir katalog ekranı gibi olmamalı
- yoğun e-ticaret sayfası gibi olmamalı
- klasik görev panosu gibi olmamalı

Bunun yerine şu hissi vermeli:

**kişisel moda stüdyosu + kişisel stil danışmanı + dijital prova aynası**

## Tasarım dili
- sıcak, doğal, sessiz ve rafine
- kumaş hissi veren dokular
- bej / fildişi / taş / kahve / zeytin aksanları
- editoryal ama erişilebilir tipografi
- lüks değil “iyi yetiştirilmiş zevk” hissi

---

# 11 — ÖNERİLEN ANA SAYFA HİYERARŞİSİ

```text
┌──────────────────────────────────────────────┐
│ Kabinsiz                    İstanbul 18°C    │
│ Bugün senin için                            │
│ Sakin, güçlü, doğal.                        │
├──────────────────────────────────────────────┤
│                                              │
│   [ ŞEHİR SAHNESİ / GALATA SOKAĞI ]          │
│                                              │
│            [ KULLANICININ 3D MODELİ ]        │
│      model üstünde bugünün kombini hazır     │
│                                              │
│   ↑ drag ile döndür                          │
│   üst / alt / ayakkabı / çanta tıklanabilir  │
│                                              │
├──────────────────────────────────────────────┤
│ [Üstü değiştir] [Altı değiştir] [Ayakkabı]   │
│ [Çanta] [Aksesuar] [Yeni kombin üret]        │
├──────────────────────────────────────────────┤
│ Bugün neden bunu öneriyoruz?                 │
│ - Hava: serin sabah, ılık öğle               │
│ - Stil: günlük şık                           │
│ - Yer: İstanbul / şehir yürüyüşü             │
│ - Dolap: mevcut parçaların dengeli uyumu     │
├──────────────────────────────────────────────┤
│ Alternatifler                                │
│ [Daha sade] [Daha rahat] [Daha güçlü]        │
├──────────────────────────────────────────────┤
│ Mağazada tara →                               │
└──────────────────────────────────────────────┘
```

---

# 12 — TYPOGRAPHY / PALETTE / MATERYAL

## Tipografi

### Başlıklar
- New York Large / New York Medium veya benzeri editoryal serif hissi
- sakin, premium, dergi estetiği

### Gövde
- SF Pro Text / SF Pro Display
- sade ve okunaklı

### Kural
- serif yalnız başlık ve vurgu için
- bilgi yoğun alanlarda sans-serif
- aynı ekranda fazla font gösterisi yok

## Renk paleti
- Surface Base: sıcak fildişi
- Secondary Surface: kum beji / yumuşak taş
- Primary Text: koyu espresso
- Accent 1: ceviz kahvesi
- Accent 2: yumuşak zeytin / muted olive
- Optional premium highlight: bakır / tarçın tonu

## Materyal hissi
- plastik dijital görünüm yasak
- aşırı cam efekt yasak
- sıcak mat yüzeyler
- çok sert siyahlar yok
- kumaş / taş / doğal ışık hissi tercih edilir

---

# 13 — MOTION / ANİMASYON

## İstenen davranış
- model dönerken akıcı ama abartısız
- kıyafet değişiminde kısa, premium geçiş
- hava durumu / sahne değişiminde yumuşak crossfade
- alt drawer açılışı zarif ve hızlı

## Yasak
- gereksiz bounce
- oyun hissi veren efektler
- aşırı parlak loading animasyonları

## Performans şartı
- ana sayfa ilk render p95 hedefi hızlı olmalı
- sahne hazır değilse önce hafif önizleme, sonra gelişmiş sahne
- cihaz ısınırsa sahne kalitesi yönetimli düşürülebilir

---

# 14 — TEKNİK MİMARİ KARAR: BLENDER NEREDE, RUNTIME NEREDE?

## Kritik düzeltme
Kullanıcı “Blender üzerinde hazır görmeli” hissini yaşamalı; fakat iPhone uygulaması **Blender’ı gerçek zamanlı motor gibi** çalıştırmayacak.

## Doğru mimari
- Blender = içerik üretim hattı
  - kıyafet varlıkları
  - sahne template’leri
  - şehir arka plan kompozisyonları
  - base pose / lighting reference

- Runtime iOS = RealityKit / Metal / SwiftUI
  - modeli gösterme
  - kıyafeti değiştirip preview etme
  - şehir sahnesini yükleme
  - hava durumunu uygulama
  - etkileşimleri yönetme

Bu ayrım zorunludur.

---

# 15 — HOME STUDIO İÇİN ZORUNLU MODÜLLER

1. **Today Outfit Engine**  
   O günün kombinini belirler.

2. **Scene Context Engine**  
   Şehir + hava + zaman + etkinlik bağlamını sahneye dönüştürür.

3. **Avatar Dressing Engine**  
   Kullanıcının modeline kıyafeti uygular.

4. **Interactive Swap Engine**  
   Parça bazında değişim deneyimini yönetir.

5. **Style Atelier Engine**  
   Alternatif kombinler üretir.

6. **Weather Reflection Engine**  
   Atmosfer, katman ve açıklamayı eşler.

7. **Wardrobe Availability Engine**  
   Kullanıcının gerçekten sahip olduğu kıyafetleri filtreler.

8. **Retail Matching Engine**  
   Mağaza ürünlerinden uyumlu alternatif getirir.

---

# 16 — CLAUDE'A BAĞLAYICI UYGULAMA EMRİ

Claude şu sırayla ilerleyecek:

## Aşama 1 — Ana sayfa mimarisi
- mevcut TodayView kaldırılmayacak ama Home Studio mantığına dönüştürülecek
- seyahat odaklı açılış kaldırılacak
- ana sahne üstte yer alacak

## Aşama 2 — 3D model hero
- kullanıcının modeli ana sahnede gösterilecek
- bugünün kombini model üstünde görünecek
- drag ile döndürme çalışacak

## Aşama 3 — scene context
- İstanbul ve Barcelona için iki pilot sahne eklenecek
- hava durumuna göre sahne tonu değişecek

## Aşama 4 — parça değiştirme
- üst / alt / ayakkabı / çanta / aksesuar swap UI
- alt sheet / drawer sistemi

## Aşama 5 — yeni kombin üret
- bugünkü görünümden varyasyon oluştur
- neden açıkla

## Aşama 6 — kalite kapısı
- gerçek SwiftUI ekran görüntüleri üret
- referans kaliteye göre karşılaştır
- başarısızsa “tamam” deme

---

# 17 — KABUL KRİTERLERİ

Aşağıdakiler sağlanmadan home studio tamamlandı sayılmaz:

1. Ana sayfada kullanıcı kendi modelini görür.
2. Ana sayfada model üstünde o günün kombini görünür.
3. Arka plan şehir bağlamına göre değişir.
4. Hava durumu sahne ve kombin kararına yansır.
5. Kullanıcı kıyafetin ana parçalarını tek tek değiştirebilir.
6. “Yeni kombin üret” çalışır.
7. Ana ekran liste-dashbord değil, stüdyo hissi verir.
8. Renk, tipografi ve materyal premium sıcak editoryal kimlikle uyumludur.
9. Uygulama iPhone’da akıcı kalır.
10. Veri yoksa sistem uydurmak yerine açıkça sınırını söyler.

---

# 18 — CLAUDE'A SORULACAK SORU

Claude’a şu zorunlu soru sorulmalıdır:

> Mevcut Kabinsiz iOS arayüzünde, kullanıcının kendi modelini ana sayfada bugünün kombiniyle, şehir bağlamlı arka planla ve parça parça değiştirilebilir şekilde göstermemizi engelleyen teknik, UI, veri ve performans eksikleri nelerdir? Bunu gerçek SwiftUI / RealityKit ekranlarıyla uygulamak için hangi dosyaları nasıl değiştireceksin? Her değişikliği gerçek ekran görüntüsü ve test kanıtıyla göster.

---

# 19 — SON KARAR

Kabinsiz ana sayfası bundan sonra:

- bir görev listesi değil,
- bir sade form sayfası değil,
- bir seyahat ekranı değil,
- bir katalog ızgarası değil,

**kişisel bir sabah stil stüdyosu** olacaktır.

Kullanıcı uygulamayı açtığında kendi modelini, bugünün kombinini ve kendi şehrinin hissini görmelidir.

Bu, Kabinsiz’in kimliğinin kalbidir.

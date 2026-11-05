# ADR-018: Fotoğraftan kendi modelim ("ayna ikiz"), kalıptan 3B giysi, ajan grafiği

- **Tarih:** 2026-11-05
- **Durum:** Kabul edildi. Paket ve simülatör kanıtı `docs/evidence/V37-*.yaml` dosyalarında. Gerçek cihaz `REAL_DEVICE_BLOCKED` (R-002).
- **Kaynak:** kullanıcının 2026-11-05 tarihli açık istekleri (`docs/audit/V37_SELF_MODEL_PROGRAM.md`):
  - yüz, kıyafet ve beden tanıma;
  - model ve kalıp oluşturma;
  - ebat ve marka tanıma;
  - API, MCP, repo ve ajan sistemi;
  - "ana ekranda kendi yüzünü gerçekçi görmeli, ayna gibi";
  - "fotoğrafı çekilen kıyafet 3B kalıp olmalı";
  - Alta, Doji, Anywear ve Giyio'nun iyi yanları.

## Karar

### 1. Tanıma, kimlik tanıma değildir

`AppearanceReader` yalnız şunları okur:
- yanaklardan ten rengi;
- başın üstünden saç rengi;
- siluetten saç uzunluğu sınıfı;
- baş oranı.

Yüz şablonu (embedding) ve kalıcı yer işaretleri hiç üretilmez. Öneri (`SelfModelProposal`) eklem, maske ve fotoğraf taşımaz; bunu SELF-T11 testi doğrular. KVKK md. 6 (biyometrik veri) bu tasarımla hiç tetiklenmez.

Fotoğraf yalnız analiz çağrısının belleğinde yaşar.

### 2. Yüzün modele konması iki ayrı "evet" ister

1. Akışın başında "Yüzümü de modelde göster" açılmalı.
2. İncelemede "Bu bana benziyor" onaylanmalı (v3.5 §D).

Yüz dokusu fotoğrafın kendi pikselleridir. Oval kenarı ten rengine kaynaşır ve önden projeksiyonla başın ön yüzüne konur (`PersonalHead.facePatch`). Rötuş, güzelleştirme ya da üretken model yoktur.

Doku Vault'ta `personal-look` kaydında tutulur (body alanı, `LOCAL_SENSITIVE`). "Yüzümü ve görünüşümü sil" ile tek dokunuşta silinir; "tüm verileri sil" de bu kaydı kapsar.

### 3. Beden fotoğraftan tahmin edilir, ölçülmez

- **Ölçek:** kullanıcının yazdığı boy. Boy yazılmadan santimetre üretilmez (fail-closed; SELF-T08).
- **Okunan değerler:** genişlikler kişi maskesinden okunur. Çevreler, ortalama derinlik oranıyla Ramanujan elipsinden hesaplanır.
- **Kayıt:** değerler `ValueSource.photoEstimated` olarak kaydedilir; ekranda "Fotoğraftan tahmin (ölçü değil)" yazar. Beden önerisine yalnız `userMeasured` girer (ACCEPT-T01).
- **Beden formu:** fotoğraftan çıkarılmaz (ADR-017).
- **Doğruluk:** kendi mankenimizin geometrisinde hata %10'un altında (SELF-T04). Gerçek insanlarda doğruluk bilinmiyor (UNKNOWN); giysi kalınlığı değeri büyütür.

### 4. Üzerindekiler kuraldan okunur

- **Renk:** pikselden (k-means, Lab).
- **Tür:** deri ile giysi rengini karşılaştıran kurallarla. Ön kol açıksa kısa kol; baldır açıksa şort ya da etek; bacaklar ayrıysa şort.
- **Belirsiz durumlar:** renk tene çok yakınsa ya da ayakkabı türü sorulursa "sen seç" denir (`needsUserChoice`).

### 5. Marka yalnız yazılı logodan okunur

- Yalnız katalogdaki markaların yazısıyla eşleşme aranır.
- Eşleşmeyen yazı (slogan, isim) hemen atılır.
- Resimli logo okunmaz: lisanslı eğitim verisi yok (UNKNOWN).

### 6. Ajan sistemi Octopus'un kendisidir

`SelfModelPipeline.graph` altı düğümden oluşur: poz, maske, görünüş, beden, giysi ve marka. Her düğüm kayıtlı bir modüldür:
- OCT-06 Body Landmark Lab bu ADR ile salt-okur olarak kaydedildi;
- OCT-07 beden;
- OCT-05 giysi ve marka.

Koordinatör yetkiyi düğümler çalışmadan önce denetler (SELF-T10), bütçeyi ayırır ve son tarihleri uygular. Başarısız bir düğüm koşuyu `DEGRADED` yapar ve nedenini söyler. Ağ yeteneği yoktur.

### 7. Fotoğraftan 3B giysi kalıptan dikilir

- **Ölçü:** A4 kâğıtla ebat okunur (`FlatGarmentMeasurer`). Kâğıt yoksa santimetre üretilmez.
- **Kalıp:** `PatternDrafter` ölçülerden düz kalıp parçaları çizer (SVG, gerçek ölçek).
- **Dikiş:** `PatternGarmentMesh` parçaları bedenin etrafına dikerek 3B giysi üretir.
- **Doku:** ön panel fotoğrafın kendi kesilmiş piksellerini taşır, böylece desen ve logo net görünür.
- **Kâğıt yoksa:** kalıp kullanıcının bedeninden temel blok olarak çizilir ve ekranda "beden bloğu" diye söylenir; ne kâğıt ne beden varsa giysi eklenmez (`noSizeSource`).
- **Altlar:** düz serilmiş pantolonda kalça genişliği kâğıttan okunamaz; bel / 0,85 ile türetilir ve kayıtta "türetildi" diye yazılır.
- **Arka ve kollar:** fotoğraf yalnız önü gösterir; arka panel ve kollar giysinin rengini taşır, desen uydurulmaz.
- **Saklanan:** `PhotoGarment` (kalıp, ölçüler, kesilmiş ön PNG, renk, dayanak) şifreli kasada `photo-garments` kaydında; asıl fotoğraf saklanmaz.
- **Akış:** Dolabım → Kıyafet ekle → "Fotoğraftan 3B giysi" → fotoğraf → inceleme (ön, ebat ± hata, kalıp) → "Dolaba ekle". Ana ekranda giydir tepsisinde görünür ve figürün üstüne dikilir.

### 9. Vision iş parçacığı kuralı

Eşzamanlı Vision istekleri boş sonuç döndürebildi (simülatörde ve macOS'ta ölçüldü). Ayrıca `VNRecognizeTextRequest` kendi içinde Swift'in ortak iş havuzundaki işi semaforla bekliyor; havuzun bütün iş parçacıkları Vision'da bloklanınca süreç kilitlendi. Karar:
- Her `perform` süreç çapında tek bir kilitten geçer (`VisionSerial`).
- Async çağıranlar Vision'u ortak havuzun dışında, ayrı bir kuyrukta çalıştırır (`VisionLane`). Uygulama, testler ve MCP sunucusu aynı yolu kullanır.
- Düğüm son tarihleri testte `deadlineScale` ile büyütülür; uygulamada 1'dir.

### 10. Vision maskesi yoksa: satır arka planı, ve kapalı başarısızlık

Simülatörde Vision kişi maskesi yoktur. Duvar ve zemin gibi iki tonlu arka planlarda tek renkli yedek de tutmaz. Yedek olarak her satırın sol ve sağ kenar renginden (Lab) arka plan kestirilir (`rowBackgroundMask`). Satırların %10'undan fazlası karışıksa maske verilmez.

Beden tahmini kolların gövdeye değdiği maskeyi reddeder (`armsTouchBody`): göğüs satırı dirseklerin içinde bitmiyorsa genişlik ölçü sayılmaz ve beden önerisi çıkmaz. person-b fikstüründe (kollar gövdeye yakın) bu kural tahmini kapatır; sahte göğüs ölçüsü üretilmez.

### 8. Rakip yöntemi: temiz oda (clean-room)

Yalnız herkese açık kaynaklar kullanılır (`docs/research/rivals/v37-mirror-twin-and-simplicity.md`). Decompile, trafik yakalama, gizli API ya da model çıkarma yoktur (v3.6). Kullanıcının "tersine mühendislik" isteği bu sınırla karşılandı.

Bulgu: Giyio ve Anywear, Decart'ın bulut modelini kullanıyor; kamera kareleri buluta gidiyor. Kabinsiz bunu varsayılan yapmaz (bulut VTON `BLOCKED_EXTERNAL`). Rakiplerden alınanlar sadelik ve akış dersleridir.

## Reddedilen seçenekler

- **Yüz embedding'iyle "kimlik" ve benzerlik puanı:** biyometrik veri üretir, ürüne gerekmez.
- **Üretken yüz (difüzyon):** kişiyi değiştirir, yerelde gerçek zamanlı değil, kanıtlanamaz.
- **Fotoğraftan beden formu tahmini:** ADR-017 kullanıcı kararıyla çelişir.
- **Fotoğrafı giysinin kendisi gibi düz kart olarak göstermek:** kullanıcının "3B kalıp olmalı" kararıyla çelişir.

## Açık kalanlar

- **Gerçek iPhone:** Vision poz ve maskesi, TrueDepth yüz ağı (`ARFaceGeometry`, ileride daha iyi yüz geometrisi için) ve kare hızı `REAL_DEVICE_BLOCKED` (R-002).
- **Simülatörde poz modeli yok:** eklemler macOS'ta önceden okunmuş bir fikstürden gelir. İnceleme ekranının en üstünde bu söylenir.
- **Gerçek insan fotoğrafı:** test seti yok. Repoya gerçek kişi görseli konmaz; doğruluk UNKNOWN.
- **Gerçek düz serme fotoğrafı:** A4 ölçümü yalnız çizilmiş fikstürle doğrulandı (boy 71,9 / göğüs 50,0 / etek 50,0 cm; gerçek 72 / 50 / 52). Gerçek kumaş, kırışık ve gölgeyle doğruluk UNKNOWN.
- **Ortak katalog akışı:** imza ve izin listesi kodlu; gerçek ortak, sözleşme ve alan adı yok (`BLOCKED_EXTERNAL`, EG-004).

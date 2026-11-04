# ADR-016 — Model yalnız elle döner; Giydir (oyun gibi ekle/çıkar)

- **Durum:** Kabul edildi (2026-11-04).
  - ADR-009 §9 ve D-023 (5)'teki "nefes + ±11° salınım" kararının yerini alır.
  - ADR-012'deki kamera kayması (`cameraDrift`) uygulamada artık kullanılmaz.
  - V25-03/04 giydirme durumundaki "üst çıkarılamaz" (`requiredSlot`) kuralının yerini alır.
- **Kaynak:** Kullanıcı isteği (2026-11-04), özetle:
  - Model ana ekranda kendi kendine salınıyor ve hareket ediyor; bu düzeltilmeli.
  - Modeli yalnız kişi döndürebilmeli, oyun gibi olmalı.
  - Kişi parçaları ekleyip çıkarabilmeli.
  - Gerekirse Unity ya da başka bir bağlantı kullanılabilir ("hedefe giden her yol mubah"). Bu kural her alanda geçerli.
- **İş paketi:** TURN-WP01, DRESS-WP01.

## Karar 1 — Hiçbir şey kendi kendine hareket etmez

Kaldırılanlar:

- Ana sahne (`WorldStage`): nefes, salınım, ölçek "canlılığı", kamera kayması ve kamera itmesi.
- Profil 3B gövdesi (`BodyModel3DView`): nefes, salınım ve kare aboneliğiyle çalışan boşta hareket.

Sonuç:

- Kamera sabittir. Cadde sabittir. Figür yalnız kullanıcının parmağıyla döner.
- Yağmur ve şehir ışığı hava durumunun kendisidir, figürün hareketi değildir. Bunlar kalır.
- Canlı Ayna'nın simülatör mankeni (`-mirrorFixture`, yalnız DEBUG) kameradaki canlı bir kişinin yerine geçer ve hareket etmeye devam eder. Bu bir model değil, kamera görüntüsünün sahte karşılığıdır (ADR-015).

## Karar 2 — Turntable: 1:1 sürükleme, savurma, durma, "Önden"

Saf model `LivingWorld.TurntableSpin` (paket testleri TURN-T01..T04):

- **Sürükleme:**
  - Parmak figürü doğrudan tutar. Ekran genişliği kadar sürükleme yarım tur eder.
  - Parmak değdiği anda momentum durur.
- **Savurma (flick):**
  - Bırakılan hız üstel sönümle azalır: sönüm 2,3/sn, tavan 4π rad/sn.
  - Hız 0,06 rad/sn altına düşünce figür durur.
  - 0,6 rad/sn altındaki bırakışlar savurma sayılmaz; figür bırakıldığı yerde kalır.
  - Hareketi Azalt açıkken savurma yoktur.
- **"Önden" düğmesi (`worldFaceFront`):**
  - Figür önden 0,2 rad'dan fazla uzaktaysa görünür.
  - Değeri açıdır (0…359°).
  - En yakın ön açıya döner, fazladan tur atmaz.

**Bulunan hata ve düzeltmesi (yalnız iOS 26):**

- `Entity.move(to:)` ile başlatılan RealityKit dönüşüm animasyonu pivotun dönüşümünü sahipleniyordu.
- Sonraki her `transform` / `orientation` yazımı aynı karede okununca bile birim döndürmeye geri dönüyordu. Değer 167° gösterirken ekrandaki figür hiç dönmüyordu.
- macOS'ta aynı kod çalışıyordu.
- Çözüm: iki sahnede de (ana sahne ve profil gövdesi) `move(to:)` kaldırıldı. Yumuşak dönüşler artık sahnenin kendi kare tikiyle yapılır (3. dereceden ease-out ara değer, `SceneEvents.Update`).
- UI testi artık yalnız erişilebilirlik değerine bakmaz. Figür kırpıntısı sürüklemeden önce ve sonra karşılaştırılır; piksel farkı %1'den büyük olmalıdır. "Önden"den sonra da aynı karşılaştırma yapılır.

## Karar 3 — Giydir: dokun, geri al, sürükle-bırak

- Ana sahnede askı düğmesi (`worldDressUp`) Giydir tepsisini açar. Tepsi alt bilgi alanının yerini alır.
- Giydir bir soyunma odası gibidir: şehir ve hava başlığı çekilir, figür hafifçe kalkar ve başı açık kalır.
- Tepsi, giyilmiş en dış katmanla açılır (palto varsa Dış giyim). Böylece ilk çıkarma hemen görünür.
- Dokunma:
  - Giyili olmayan bir parçaya dokunmak onu giydirir.
  - Giyili bir parçaya dokunmak onu çıkarır. Giyili parçada eksi rozeti ve "Üzerinde" değeri vardır.
- Sürükleme: bir parça tepsiden figürün üstüne bırakılır. Bırakma alanı bakır bir halka ile gösterilir.
- Geri al ve İleri al her değişiklik için çalışır.
- Herhangi bir yuva boşaltılabilir, üst de dahil:
  - `DressedAvatarState.remove` yalnız boş yuvayı reddeder (`EMPTY_SLOT`).
  - `REQUIRED_SLOT` yalnız eski kayıtları okuyabilmek için durur.
- Figürde bir giysiye dokunmak, Giydir açıkken tepsiyi o yuvaya getirir.
- Doğruluk etiketleri yerindedir:
  - "örnek dolap · sentetik" (örnek dolap gösteriliyorsa).
  - "Temsilî 3B giysi, beden uyumunu göstermez".
  - T0/T1 giysi T2/T3 diye sunulmaz.

## Karar 4 — Unity gerekmez

- RealityKit bu iş için yeterlidir: döndürme, momentum, katmanlı giysi, ray-cast ile giysi seçme ve sürükle-bırak.
- Unity eklemek şunları getirirdi:
  - İkinci bir çalışma zamanı.
  - Uygulama boyutunda büyük artış.
  - Ayrı bir lisans ve hesap (insan onayı ister).
  - Bu işler için kazanç yok.
- Bu yüzden eklenmedi. İleride kumaş simülasyonu gibi RealityKit'in yetmediği bir ihtiyaç çıkarsa ayrı bir ADR ile yeniden değerlendirilir.

## Karar 5 — Görünmeyen dünya kendi başına iş yapmaz

Ana sahne iki durumda görünmez: profil tam ekran kapağı açıkken ya da başka bir sekme seçiliyken. Bu durumda:

- `WorldStage.setPaused` kare tikini durdurur. Savurma momentumu ve geçiş animasyonu kesilir, kare hızı raporu gitmez.
- Gizliyken ölçülen düşük bir hız, sahne kalitesini yanlışlıkla düşürmez.
- Sahnenin kendisine dokunulmaz, hiçbir şey yeniden yüklenmez. Kapak kapanınca figür aynı pozda geri gelir.

Denenip reddedilenler (simülatör, 2026-11-04):

- **Sahnedeki varlıkları kapatmak** (figür, ışık, şehir): bu sırada yaratılan RealityView'ler hiçbir şey çizmedi. Örneğin "Nötr başlangıç modeli oluştur"dan sonra profilin 3B gövdesi boş geldi.
- **RealityView'i hiyerarşiden çıkarıp geri koymak:** yeniden yaratılan RealityView hiçbir şey çizmedi, ana sahne beyaz kaldı. Eski varlıklar taşınınca da, taze bir sahne kurulunca da, kurulum kapak kapanana kadar ertelenince de sonuç aynıydı.

**Test:** `TurntableDressUpUITests.testWorldComesBackAfterProfileCover` profili açıp kapatır. Açı aynı kalmalı, sahne ekranda %2'den az değişmeli.

## Bilinen açık — 3B bütçede profil kaydırıcısı ve çizilmeyen RealityView (ADR-016'dan önce de var) — simülatörde ÇÖZÜLDÜ (2026-11-04)

Aşağıdaki maddeler hatanın geçmişidir. Kök neden ve düzeltme bu bölümün sonunda, "Kök neden" başlığında.

- **Hata:** `AcceptanceDemoUITests.testBodyStudioJourney` bel kaydırıcısında (satır 188) aralıklı düşüyor. Kaydırıcının topu ekranda kayıyor, ama değer başlangıçta (82 cm) kalıyor. Binding yalnız dokunuşun başında, 82 ile bir kez çağrılıyor.
- **Önceden vardı:** aynı hata push edilmiş HEAD'de (9727105) de görüldü. 3B şehrin geldiği a101a1a'dan beri var; ondan önceki son yeşil koşu 2026-11-03 21:17.
- **2B bütçede çalışıyor:** termal testte (3B yokken) aynı sürükleme her seferinde çalışıyor.
- **Ayırma deneyleri (gürültülü, makine yüklüydü):**
  - Profil açıkken ana sahne tamamen çıkarılınca bir koşuda düzeldi.
  - 3B gövde görünümünü ya da jest tanıyıcılarını kaldırmak düzeltmedi.
  - Yukarıdaki duraklatma varyantlarının hiçbiri güvenilir biçimde düzeltmedi.
- **Ek gözlem (2026-11-04, V36-01):** `BodyFormUITests`'ta yaklaşık 21 koşunun 11'inde aynı takılma. Sürüklemeden hemen sonra değer değişmemiş; geri sıçrama yok, hata mesajı yok, kaydırıcı etkin ve çerçevesi sabit. 3B görünümün yan kaydırma tanıyıcısı dokunuşu almıyor (figürün açısı değişmiyor). Liste durana kadar beklemek de düzeltmedi. Yani dokunuş kaydırıcıya hiç ulaşmıyor. Aynı tam UI koşusunda `testBodyStudioJourney` geçti.
- **Genişleme (2026-11-04, V36-01):** Aynı ailede iki belirti daha görüldü. Profil satırlarında dokunuşlar düşüyor: geri al, hava rızası anahtarı. Ayrıca profilde sonradan oluşturulan RealityView'lar bazen 15 saniyeden uzun süre hiç çizilmiyor: Kadın başlangıç şekli ve oluşturulduktan hemen sonraki gövde.
  - Deney: ana sahne hiç kurulmadan form testi 2/2 geçti.
  - Ana sahnenin RealityView'ı kapak açıkken hiyerarşiden çıkarıldığında form testi bir seferde 3/3 geçti, sonra tekrar düştü. Geri dönüşte ana sahne bembeyaz kaldı; hem eski varlıklar yeniden eklenince hem de yeni stage kurulunca. Bu yüzden geri alındı.
  - Ara sonuç: bu simülatörde uygulamanın ömrünün ilerisinde oluşturulan RealityView'lar bazen hiç çizmiyor. Kök neden `UNKNOWN`.
- **Önceki durum:** `OPEN`, ayrı iş olarak izlendi.

### Kök neden (2026-11-04, ölçümle bulundu)

Geçici bir ölçüm kodu eklendi, sonra kaldırıldı. Ölçtükleri:
- RealityKit'in kare olaylarının saniyedeki sayısı;
- ana thread'deki `CADisplayLink` boşlukları;
- her ARView'ın pencerede olup olmadığı ve görünür alanı;
- Metal katmanının ayarları;
- RealityKit'in kendi snapshot'ı ile ekranda birleştirilen görüntünün karşılaştırması.

Ayrıca uygulama süreci `sample` ile örneklendi.

- **Donma:** Profil açıkken dakikalarca saniyede yalnız 1 kare çizildi; her karede yaklaşık 1000 ms takılma ölçüldü.
  - Ana thread `ARView.commonRenderCallback → RenderThread::waitForIdleInternal` içinde, RealityKit'in render thread'ini bekliyordu.
  - Render thread `-[CAMetalLayer nextDrawable]` içinde 1 saniyelik zaman aşımında bekliyordu.
  - Tüm 3B görünümler aynı render thread'i paylaştığı için hepsi dondu. Dokunuşlar da bu bekleme yüzünden kayboldu (kaydırıcı, geri al, anahtar).
- **Neden:** Profil kapağındaki RealityKit katmanında `presentsWithTransaction` açıktı (`PWT`); ana sahnenin katmanında kapalıydı.
  - PWT açıkken yeni kare ancak bir Core Animation commit'iyle ekrana çıkar. Hareketsiz profil ekranında commit gelmedi.
  - RealityKit'in snapshot'ı kadın gövdesini çizdi, ekranda ise ilk (nötr) kare kaldı. "Çizilmeyen RealityView" belirtisi buydu.
  - Katmanın drawable'ları dolunca `nextDrawable` beklemeye başladı ve donma geldi.
  - RealityKit görünüm her yeniden boyutlandığında (kapak açılışı, açı düğmelerinin gelişi) PWT'yi tekrar açıyor.
- **Doğrulama:** PWT'yi kapatan tek değişiklikle donma (1 saniyelik takılmalar) 0'a indi ve figür her değişiklikte ekranda güncellendi. Form testi 3/3 geçti, test süresi 150–260 sn'den yaklaşık 95 sn'ye indi.
- **Elenen hipotezler:**
  - Ana sahneyi kapak açıkken çıkarmak (E1) çözmedi.
  - Kapağı sheet yapmak (E3) çözmedi.
  - Yalnız pencere dışında kalan ARView açıklamaya yetmedi: tamamen görünür tek profil görünümüyle de donma oldu.

### Düzeltme

1. **`DirectARView`** (`BodyModel3DView.swift`): Profil figürü artık `RealityView` yerine kendi `ARView` alt sınıfımızla kuruluyor.
   - Metal katmanı her kareden önce ve her yerleşimde doğrudan sunuma (`presentsWithTransaction = false`) alınıyor.
   - Görünüm kalkınca sahne açıkça sökülüyor (`dismantleUIView` → `tearDown`).
2. **`BodyFigureHeader`**: Profilde tek, kalıcı 3B figür var ve List'in üstünde sabit duruyor (`safeAreaInset`).
   - List hücresi içinde değil, `.id` ile değiştirilmiyor. Eski düzende List hücresi değiştirilen eski ARView'ı pencere dışında canlı tutuyordu.
   - Kaydırıcıyla ya da yazarak değiştirirken figür görünür kalıyor.
3. **Referans döngüleri kırıldı:** Stage'in geri çağrıları artık `self` yakalamıyor, yalnız bir binding ya da closure yakalıyor.
   - Önceden şu döngü vardı: Stage → closure → görünümün `@State` deposu → Stage.
   - Bu yüzden değiştirilen görünümlerin Stage'i ve ARView'ı hiç serbest kalmıyordu. Aynı düzeltme ana sahnenin `DressedAvatarView`'ında da yapıldı.
4. **Gövde durumu ile çizim tek adımda yayınlanıyor** (`AppModel.syncBody`). Önceden araya bir `await` giriyordu:
   - `bodyStatus` hazır olduğu halde `bodyScene` boş kalıyordu;
   - ana sahne bir an 2B'ye düşüp 3B görünümü yeniden kuruyordu (uygulama açılışında ve gövde oluşturulurken).

5. **Test yardımcısındaki hata (uygulama hatası değil):** Düzeltmeden sonra `testBodyStudioJourney` yaklaşık 5 koşuda bir geri al adımında düşüyordu.
   - Geçici log, geri alın doğru çalıştığını gösterdi: dokunuş geldi ve bel 61,5 cm'ye döndü.
   - Ekran kaydı nedeni gösterdi: geri al listeyi en üste taşıyordu. Testin kaydırma sürüklemesi ekranın ortasından (x = 0,5) başladığı için "Boy" kaydırıcısının topuna denk geliyordu. Sürükleme listeyi kaydırmak yerine topu tuttu; bel satırı hiç görünür olmadı.
   - Düzeltme: profil kaydırmaları satır kartlarının dışında, listenin sağ kenarından (x = 0,97) yapılıyor (`bringIntoView`, `scrollProfile`).
6. **Kaydırıcıya ulaşmayan sürükleme (test girdisi, donma değil):** Tam suite'te bel kaydırıcısı (satır 188) hâlâ ara sıra kıpırdamıyordu. Suite'te ondan hemen önce koşan döndürme testiyle birlikte 5 koşuda bir kez yeniden üretildi ve geçici ölçümle izlendi.
   - Başarılı sürüklemede kaydırıcı önce "düzenleme başladı" der, sonra değerleri 82 → 61,5 sırayla alır.
   - Başarısız sürüklemede başlangıç ve ara değerler hiç gelmedi; yalnız bırakma anı eski değerle (82) geldi. Yani kaydırıcı izlemeye hiç başlamadı.
   - Aynı koşularda en uzun kare boşluğu yaklaşık 330 ms'ydi; 1 saniyelik donma yoktu.
   - Neden: XCUITest'in `adjust(toNormalizedSliderPosition:)` komutu parmak iner inmez hızla sürüklüyor. Yüklü simülatörde List'in kaydırma jesti bu ilk hareketi alıyor.
   - Düzeltme (yalnız test): `dragThumb(to:)` topa basıp 0,4 sn bekliyor, sonra yavaş sürüklüyor; insan da böyle sürükler. Eski "bir kez daha dene" geri dönüşü kaldırıldı; tek sürükleme sıkı doğrulanıyor.
   - Gerçek iPhone'da hızlı bir parmak savuruşunun liste tarafından alınıp alınmadığı `UNKNOWN` (R-002).

- **Durum:** `RESOLVED_SIMULATOR`. Testler bilinen hatayı artık beklenen başarısızlık (expected failure) saymıyor; çizim, tek dokunuş ve tek kaydırıcı sürüklemesi sıkı doğrulanıyor.
- **Açık kalanlar:**
  - Gerçek iPhone'da PWT davranışı ve donma: `UNKNOWN` (`REAL_DEVICE_BLOCKED`, R-002).
  - Ana sahne hâlâ `RealityView`. Ölçümlerde katmanında PWT hiç görülmedi; bu korumayı almadı, izleniyor.

## Kanıt

`docs/evidence/V32-TURN-DRESS.yaml` dosyası şunları içerir:

- Paket testleri: 366/366.
- UI: `TurntableDressUpUITests` (2 test).
- Ekran görüntüleri: `docs/screenshots/app-2026-11-04/01-bugun/ADR16-*.jpg`.

Durum: `PASS_SIMULATOR_ONLY`. Gerçek iPhone'da dokunma hissi ve kare hızı `REAL_DEVICE_BLOCKED` (R-002).

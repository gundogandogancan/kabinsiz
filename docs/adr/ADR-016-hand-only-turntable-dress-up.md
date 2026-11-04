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

## Çözülen açık — 3B bütçede profil kaydırıcısı takılıyordu (2026-11-04)

- **Belirti:** `AcceptanceDemoUITests.testBodyStudioJourney` bel kaydırıcısında aralıklı düşüyordu. Topu ekranda kayıyor, bırakınca 82 cm'ye geri sıçrıyordu. a101a1a'dan (3B şehir) beri vardı, push edilmiş 9727105'te de görüldü.
- **Ölçüm (simülatör):**
  - Kaydırıcı dokunuşta yalnız bir olay aldı ("başladı", değer 82), sonra hiçbir olay gelmedi. UIKit `UISlider` ile de aynısı oldu; yani sorun kaydırıcı kontrolünde değildi.
  - Ana iş parçacığı örneklemesi (`sample`): ana iş parçacığı zamanının yaklaşık %85'ini RealityKit'in render iş parçacığını beklerken (`waitForIdleInternal`) geçirdi. Render iş parçacığı da `CAMetalLayer nextDrawable`'da bekliyordu.
  - Dokunuş anında penceredeki Metal katmanları: profilin iki `ARView`'i `presentsWithTransaction=false`, kapağın arkasındaki ana sahnenin `RealityView` katmanı `presentsWithTransaction=true`.
- **Kök neden:** Ana sahne profil kapağının arkasında pencerede kalıyor. Karar 5 gereği duraklatılmış ve durağan olduğu için Core Animation commit'i gelmiyor. Bu yüzden kareleri hiç sunulmuyor, çizilebilir yüzeyleri tükeniyor. Render iş parçacığı bütün 3B görünümler için ortak olduğundan önce o, sonra ana iş parçacığı bekliyor, dokunuşlar da kayboluyor. Ana oturum aynı mekanizmayı v35'te profilin kendi katmanında buldu (4e6939b, D-052).
- **Düzeltme:**
  - `DirectPresentation`: penceredeki RealityKit Metal katmanlarını en çok saniyede iki kez bulur, her kare tikinde doğrudan sunuma (`presentsWithTransaction=false`) alır. Ana sahne duraklatılmışken de çağrılır. RealityKit dışındaki katmanlara dokunmaz.
  - Profil gövdesi `RealityView` yerine `DirectARView` ile kurulur (v35'ten taşındı): katmanı her kare doğrudan sunumda tutulur, görünüm kalkınca sahnesi boşaltılır.
  - Profil ve ana figürdeki geri çağrılar artık `self`'i tutmuyor; böylece sahne ve RealityKit görünümü serbest kalabiliyor.
- **Test girdisi de düzeltildi:**
  - Kaydırıcı topa basılıp kısa beklenerek ve yavaş sürüklenir (`dragThumb`).
  - Liste kaydırmaları ekranın sağ kenarından yapılır (`scrollProfile`); ortadan başlayan kaydırma boy kaydırıcısının topunu yakalayabiliyordu.
  - Deneme-tekrar döngüsü kaldırıldı: tek sürükleme değeri değiştirmeli.
- **Sonuç:** düzeltmeyle test 4/4 geçti, koşu süresi yaklaşık 65 sn (önce 100–270 sn). Eski test girdisiyle de geçti. Düzeltmeden önce, yalnız yeni test girdisiyle 1/4 ve 0/4 geçmişti.
- **Denenip bırakılan:** kaydırıcıyı UIKit `UISlider` (`TrackSlider`) ile değiştirmek. Ne kök neden düzeltilmeden ne de girdi değişikliğiyle birlikte işe yaradı (1/4).
- **Gerçek iPhone:** `UNKNOWN` (`REAL_DEVICE_BLOCKED`, R-002).

## Kanıt

`docs/evidence/V32-TURN-DRESS.yaml` dosyası şunları içerir:

- Paket testleri: 366/366.
- UI: `TurntableDressUpUITests` (2 test).
- Ekran görüntüleri: `docs/screenshots/app-2026-11-04/01-bugun/ADR16-*.jpg`.

Durum: `PASS_SIMULATOR_ONLY`. Gerçek iPhone'da dokunma hissi ve kare hızı `REAL_DEVICE_BLOCKED` (R-002).

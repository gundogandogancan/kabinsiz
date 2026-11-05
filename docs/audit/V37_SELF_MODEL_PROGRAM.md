# V37 Programı: fotoğraftan kendi modelim, kalıp, ebat, marka ve ajan sistemi

- **Tarih:** 2026-11-05.
- **Kaynak:** kullanıcının açık isteği (2026-11-05):
  - "yüz tanıma, kıyafet tanıma, beden tanıma, model ol";
  - "model oluşturma, kalıp oluşturma, ebat tanıma, modelleme, görsel tanıma, görselden kıyafet çıkarma, marka logo tanıma, API bağlama, MCP bağlama, repo çalıştırma, skill atama, agent sistemi oluşturma".
- **Bağlayıcı sınırlar:**
  - v3.5 §D (kişisel avatar: seçilen fotoğraf, yalnız yerel, "bu bana benziyor" onayı);
  - v3.6 (kanıtsız tamamlandı yok);
  - ADR-016 (model yalnız elle döner);
  - ADR-017 (beden formu yalnız kullanıcının seçimi);
  - KVKK md. 6 (biyometrik veri özel nitelikli).
- **Döngü:** her paket SPEC → THREAT → CODE → TEST → EVIDENCE.

## Ana karar: "tanıma", kimlik tanıma değildir

Kabinsiz kimseyi tanımaz. Yüzden, kişiyi tanımlayan bir parmak izi (embedding, yüz şablonu) **hiç üretilmez ve saklanmaz**.

Fotoğraftan yalnız modelin görünüşü için gereken birkaç sayı okunur:
- ten rengi;
- saç rengi;
- saç uzunluğu sınıfı;
- baş oranı.

Bu sayılar kullanıcı onaylarsa modele uygulanır. Fotoğrafın kendisi analizden sonra bellekten atılır; kalıcı yere yazılmaz.

Beden okuması ölçü değildir. Kullanıcının yazdığı boy ölçek olarak kullanılır, fotoğraftaki siluetin genişlikleri ise tahmin olarak okunur. Ekranda "fotoğraftan tahmin · ölçü değil" etiketi ve bir aralık görünür. Kullanıcı her satırı tek tek onaylamadan beden profili değişmez.

Beden formu (Kadın, Erkek, Nötr) fotoğraftan **çıkarılmaz** (ADR-017).

## İsteğin karşılıkları

| İstenen | Kabinsiz karşılığı | Nerede | Sınır | Durum |
|---|---|---|---|---|
| Yüz tanıma | `FaceAppearanceReader`: yüz kutusu ya da poz (burun/kulak) → yanak bölgesinden ten rengi, başın üstünden saç rengi ve uzunluk sınıfı | `SelfModel` paketi | Kimlik yok, embedding yok; yalnız seçilen fotoğraf; sonuç yerel | V37-01 |
| Beden tanıma | `BodyProportionReader`: Vision 2B poz + kişi maskesi → omuz, göğüs, bel, kalça genişlikleri → kullanıcının boyuyla santimetre tahmini + aralık | `SelfModel` | Ölçü değil; giysi kalınlığı genişliği artırır; form çıkarılmaz | V37-01 |
| Kıyafet tanıma | `WornGarmentReader`: poz bölgeleri (gövde, bacak, ayak) + kişi maskesi → üst, alt ve ayakkabının rengi; kol ve paça boyu deriden ayrılarak tür | `SelfModel` | Renk pikselden, tür kuraldan; kullanıcı onaylar | V37-01 |
| Model oluşturma / modelleme | `SelfModelProposal` → ten ve saç görünüşü, beden önerisi, üstündekiler → 3B figür (`BodyModel3DView`) | iOS | Varsayılan nötr figür kalır; kişisel görünüş yalnız onayla | V37-05 |
| Görsel tanıma / görselden kıyafet çıkarma | Var: `GarmentPhotoAnalyzer` (V36-03). Yeni: kişi fotoğrafından bölge bölge giysi kesimi | `ProductCapture` + `SelfModel` | Piksel değişmez | V36-03 + V37-01 |
| Marka logo tanıma | `BrandMarkReader`: giysi bölgesinde metin okuma (`VNRecognizeText`) → yalnız katalogdaki markaların yazılı logosuyla eşleşme | `SelfModel` | Yalnız yazılı logo; resimli logo için lisanslı eğitim verisi yok → `UNKNOWN`; marka siteleri kazınmaz | V37-02 |
| Ebat tanıma | `FlatGarmentMeasurer`: giysi düz zeminde, yanında A4 kâğıt → kâğıttan piksel/cm → en, boy, koltuk altı genişliği | `SelfModel` | Tahmin ± hata; kullanıcı onaylar | V37-03 |
| Kalıp oluşturma | `PatternDrafter`: beden ölçüsü + bolluk payından düz kalıp parçaları (ön/arka beden, kol, pantolon ön/arka) → gerçek ölçekli SVG | `SelfModel` | Dikiş kalıbı temel bloktur; marka kalıbı değildir | V37-04 |
| Agent sistemi / skill atama | Octopus görev grafiği: `selfModelGraph` (intake → poz/maske/yüz → beden/giysi/marka → öneri), modül yetkileri kayıtta; geliştirici tarafı `.claude/agents` ve skill eşlemesi | `SelfModel` + `docs/` | Her modül yalnız yetkili olduğu veriyi görür | V37-01, V37-09 |
| API bağlama | `PartnerFeedConnector`: izinli ortak katalog akışı, Ed25519 imzası doğrulanmadan kabul yok, yalnız izinli alan adı, kişisel veri gitmez | `ShoppingCopilot` | Gerçek ortak sözleşmesi yok → `BLOCKED_EXTERNAL`; test yerel imzalı akışla | V37-06 |
| MCP bağlama | `kabinsiz-mcp`: paketteki analizörleri Claude ajanlarına araç olarak açan yerel stdio MCP sunucusu, proje `.mcp.json` kaydı | `tools/` | Yalnız Mac'te, ağ yok, kullanıcı fotoğrafı değil fikstür | V37-07 |
| Repo çalıştırma | `tools/repo-gate`: lisans kapısı + gizli anahtar taraması + ağsız `sandbox-exec` | `tools/` | v3.4: önce lisans ve güvenlik incelemesi; NC lisans uygulamaya giremez | V37-08 |

## Sıra

V37-01 → 02 → 03 → 04 → 05 (iOS) → 06 → 07 → 08 → 09 → kanıt.

Her paket ayrı commit olarak işlenir. Sonuçlar `docs/evidence/V37-*.yaml` dosyalarında tutulur.

## Ek istekler (2026-11-05, aynı oturum)

1. **Ana ekran ayna gibi olmalı.**
   - Kişi kendi yüzünü gerçekçi görür.
   - Model, kişinin boyunu ve genişliklerini fiziksel ölçüde taşır.
   - Kıyafetler ve desenler net görünür.

   **→ V37-10 "Ayna ikiz":**
   - Seçilen selfie'den yüz bölgesi kesilir. Fotoğrafın kendi pikselleriyle, yüz şeklinde bir maske dokusu üretilir ve 3B başın ön yüzüne giydirilir.
   - Yüz dokusu yalnız Vault'ta şifreli saklanır, tek dokunuşla silinir ve "bu bana benziyor" onayı alınmadan gösterilmez. Kimlik şablonu yoktur.
   - Gerçek cihazda TrueDepth varsa ARKit yüz ağı (`ARFaceGeometry`) kullanılır; yoksa 2B işaretler ve şablon derinlik kullanılır. Simülatörde TrueDepth yoktur, bu yüzden gerçek cihaz testi bekler (`REAL_DEVICE_BLOCKED`, R-002).
   - Beden kullanıcının ölçüleriyle santimetre ölçeğinde kurulur. Bu zaten `BodyProfile` ile yapılıyor; yeni olan tek şey, yüzeyin 1:1 gösterimi.
2. **Elle ekleme kalır; fotoğrafı çekilen kıyafet fotoğraf olarak değil, kalıptan dikilmiş 3B giysi olarak görünür.**
   - Akış: kesip çıkarma (V36-03) → ebat (V37-03, A4 kâğıt ya da kullanıcı ölçüsü) → kalıp (V37-04) → `PatternGarmentMesh` (dikilmiş 3B).
   - Ön panel fotoğrafın kendi piksellerini taşır, bu yüzden desen ve logo net görünür. Renk ve desen değiştirilmez.
3. **Canlı ayna "god level" çalışmalı. Alta Daily, Doji ve Anywear'in iyi yanları eklenmeli.**
   - Tersine mühendislik isteği şöyle karşılanıyor: yalnız herkese açık kaynaklarla temiz oda (clean-room) yöntemi uygulanıyor.
   - Decompile, trafik yakalama, gizli API ya da model çıkarma yapılmıyor. Bu v3.6'da açıkça yasaklı; "yetkisiz proprietary model tersine mühendisliği yapılmaz".
   - Rakiplerin ne yaptığı herkese açık kaynaklardan çıkarılır, sonra kendi kodumuzla yazılır.
   - Çıktı: `docs/research/rivals/v37-mirror-twin-and-simplicity.md`.
4. **Giyio'nun (Eren Görkem Şahin) iyi yanları alınmalı; Kabinsiz en az onun kadar sade olmalı.**
   - Aynı araştırma belgesinde bir sadelik bütçesi tutulur: her temel işin dokunuş sayısı ve ekran başına tek birincil eylem.

## Durum (2026-11-05)

Kanıt: `docs/evidence/V37-01-10.yaml`. Hepsi SIMULATOR_ONLY / macOS; gerçek iPhone REAL_DEVICE_BLOCKED (R-002).

| Paket | Durum | Not |
|---|---|---|
| V37-01 SelfModel: görünüş, beden, üzerindekiler, Octopus grafiği | CODED + TESTED (macOS, kendi Blender mankenlerimiz a/b/c) | b'de kollar gövdeye yakın: beden tahmini kapalı (fail-closed) |
| V37-02 Yazılı marka | CODED + TESTED | resimli logo UNKNOWN |
| V37-03 A4 ile ebat | CODED + TESTED (sentetik) | gerçek düz serme fotoğrafı UNKNOWN |
| V37-04 Kalıp → 3B giysi | CODED + TESTED | temel blok; marka kalıbı değil |
| V37-05 iOS "Fotoğraftan modelimi kur" | CODED; `SelfModelUITests` PASS (simülatör fikstürü) | fikstür ekranda en üstte söylenir |
| V37-06 Ortak katalog API | CODED + TESTED (yerel imzalı akış) | gerçek ortak BLOCKED_EXTERNAL (EG-004) |
| V37-07 MCP sunucu | CODED; `tools/mcp/smoke.sh` 16 mesaj beklenen sonuç | Swift birim testi yok |
| V37-08 Repo kapısı | CODED; sahte repolarda kanıtlandı | gerçek üçüncü taraf repo çalıştırılmadı |
| V37-09 Ajan kartları ve yönlendirme | YAZILDI | v3.5 kartlarıyla kısmen örtüşür |
| V37-10 Fotoğraftan 3B giysi | CODED; `PhotoGarmentUITests` PASS | ön panel fotoğraf, arka renk |

# KABİNSİZ — GOD LEVEL v2.5
## LIVING FASHION WORLD + INSTANT OUTFIT + TRUE PERSONAL AVATAR + LIVE MIRROR
### Claude Code için bağlayıcı ürün, deneyim, mimari, uygulama ve kanıt şartnamesi

**Tarih:** 03.11.2026  
**Ürün:** Kabinsiz  
**Bağlam:** v2.4 Master Constitution üzerine yeni üstün UX/ürün kararı  
**Öncelik:** Güvenlik/hukuk/platform → insan mahremiyeti ve doğru iddia → **v2.5 yaşayan deneyim** → v2.4 önceki gerekler → güncel repo kanıtı  
**Durum:** `SPEC_ONLY`. Bu belge kodun çalıştığını ya da videodaki kaliteye ulaşıldığını söylemez.

> **TEK CÜMLEDE ÜRÜN:** Kabinsiz'i açan kişi, kendi bedeninin dijital modelini o günün kıyafetlerini giymiş halde, bulunduğu şehrin gerçek atmosferini hissettiren yaşayan bir sokakta görür; döndürür, kıyafetin kendisine dokunur, saniyeler hedefiyle değiştirir, yeni kombin üretir. Mağazada/internette gördüğü ürünü seçtiğinde kamerada **gerçek kendisini** gösteren Live Mirror'da denemeyi başlatır.
>
> **Önemli ayrım:** 3D avatarla prova ve canlı kamera üstünde AI giysi dönüşümü iki FARKLI görselleştirme hattıdır. İkisi birbiriyle veri paylaşır; eş anlamlı değildir.

---

# 0. CLAUDE'UN İLK YAPACAĞI ŞEY — GERÇEKLİK DENETİMİ

Repo: `https://github.com/gundogandogancan/kabinsiz`

03.11.2026 tarihinde incelenen `main` HEAD: `ba7605943c9c6c0df56bf34735a7c3ba9886e85b`. Bu tarihsel gözlemdir; Claude başlarken HEAD'i tekrar doğrulasın.

| Mevcut parça | Kanıt dosya | Şu anki durum / v2.5 açığı |
|---|---|---|
| 3D beden modeli, 360° drag, pinch, ön/yan/arka | `apps/ios/Kabinsiz/Features/Profile/BodyModel3DView.swift` | **Kısmi temel var**; giydirilmiş kişisel avatar ve ana sayfa sahnesi yok |
| Nötr beden ve kullanıcı ölçüleri | `Features/Profile/BodyStudioView.swift`, `BodyGeometry` | Prosedürel model, insanın tam görsel benzeri veya kişiye özel giysi simülasyonu değil |
| Live Mirror oturum sözleşmeleri/durum makinesi | `Sources/LiveMirror/MirrorContracts.swift`, `MirrorSession.swift`, `MirrorStateMachine.swift` | **Sözleşme/durum makinesi var**; kamera işleme, poz takibi, giysi overlay ve üretken VTON bağlantısı doğrulanmış değil |
| Yerel/bulut ayna ayrımı | `MirrorMode`, `MirrorFidelity`, `MirrorFlags.production` | Bulut kapalı; bu güvenlik varsayılanı korunacak |
| Günlük ana ekran | `Features/Today/TodayView.swift` | Seyahat/uyarı ağırlıklı; stüdyo ve giyinmiş avatar yok |
| Ürün tarama | `Features/Scan/ScanView.swift` | Elle kod/sentetik katalog; gerçek kamera/barkod/URL akışı yok |
| Görsel kimlik | `DesignSystem/Theme.swift` | Soğuk mavi-gri `#283D46`; Quiet Atelier sıcak token'ları uygulanmamış |
| WeatherKit sağlayıcısı | `Services/AppleWeatherProvider.swift` | Var olan bağlayıcı yalnız kullanıcı isteğiyle hava çekiyor; sabah otomatik yenileme için yeni rıza/egress tasarımı lazım |
| Şifreli kasa, egress | `Sources/Vault`, `SystemContracts` | Temel var; foto/video için özel politika ve telemetri testleri gerekli |
| Gerçek mağaza verisi + giysi asset'i | Sentetik katalog; `CatalogRights` ve kanıt kapıları | **Dış anlaşma ve gerçek asset gerektirir**; uydurulmayacak |

**Şeffaflık:** GitHub'daki PNG dosya listesi görüldü; görsel içerikler bu incelemede piksel düzeyinde açılamadı. Mevcut tasarımın eleştirisi kod ve metin kanıtınadır. Claude kendi Mac'inde gerçek simülatör/iPhone screenshot'ı alarak görsel QA yapacaktır.

---

# 1. ÜRÜNÜN ASIL HİSSİ: “İÇİNE GİRDİĞİN MODA DÜNYASI”

Kabinsiz bir moda e-ticaret kart kataloğu, ChatGPT sohbet ekranı, teknik dashboard veya klasik avatar editörü DEĞİLDİR.

Bu deneyim, şu dört kavramın birleşimidir:

1. **Playable Living World:** şehir, ışık, yağmur, zemin, derinlik, hafif hareket.
2. **Personal Digital Twin:** kullanıcıya ait beden oranlarını temsil eden, 360° döndürülebilir kişisel model.
3. **Instant Editorial Stylist:** sabah kombini hazır; parçaya dokunarak değiştir; yeni görünümü anında dene.
4. **Live Fitting Mirror:** gerçek kamera akışında kendini görürken farklı kıyafeti üzerinde deneyimle.

**İlke:** Oyun gibi *etkileşimli ve canlı*, ama çizgi film gibi *çocuksu* değil. AAA oyun bütçesi tüketen ağır şehir simülasyonu değil; mobilde çok iyi kurgulanmış rafine sahne. Moda filmi kadar doğal, oyun kadar keşfedilebilir, Apple düzeyinde sade bir kullanım.

## Steve × Woz ürün ilkeleri

- Steve odak: Açılışta birincil değer hemen anlaşılır; ekrandaki merkez modeldir; açıklama yerine eylem.
- Woz odak: Gerçek dünyadaki zorlukları çözmek için temiz mühendislik; offline fallback; enerji/memory limitleri; denetlenebilir durum makinesi.
- Birincil deneyim için hesap açtırma, uzun form, süslü yapay zekâ terminali, “AI ordusuyla tanış” ekranı yok.
- Sıcak doğal stil: `#F8F6F1` fildişi; `#26221E` espresso; `#654632` ceviz; `#62684B` zeytin; `#E8DED1` kum; New York/SF tipografi. Sahne görseli bu paletle uyumlu olur, fakat yapay tek renk filtreyle şehir ve kıyafet renk doğruluğu bozulmaz.

---

# 2. ANA EKRANIN ZORUNLU TASARIMI (SCREEN-FIRST)

## 2.1 Birinci viewport — Dünya

Uygulama açıldığında ekranın ana gövdesini (hedef yaklaşık %60–75; küçük ekranda adaptif) **3D dünya/stüdyo** kaplar. Üstte Kabinsiz + şehir/hava bilgi satırı; sahnede tek büyük kişisel model; altta minimum araç rayı.

```text
╭──────────────────────── iPHONE ────────────────────────╮
│ KABİNSİZ                         İstanbul · 11°C · ☔  │
│ BUGÜNÜN GÖRÜNÜMÜ             [◌ Stil nedenleri]        │
│                                                       │
│  [ Galata çevresinde bir sokak / derinlik ve ışık ]    │
│       ☔ yağmur damlacıkları                           │
│       ⤋ yere çarpıp dağılan küçük damlalar            │
│       ☁ bulutlu doğal gökyüzü / ıslak taş zemin        │
│                                                       │
│                    [KENDİ 3D MODELİM]                 │
│                     bugünün kombini                   │
│                                                       │
│          👆 üst / pantolon / ayakkabıya dokun          │
│          ↔ 360° döndür       ⊕ yakınlaştır             │
│                                                       │
│     [ Üst ] [ Alt ] [ Ayakkabı ] [ Çanta ] [ ••• ]    │
│                                                       │
│          [ ✧ YENİ KOMBİN OLUŞTUR ]                     │
│                                                       │
│      [ Canlı Ayna ]                  [ Ürünü Tara ]     │
│ ───────────────────────────────────────────────────── │
│ Bugün neden bunu giyiyorsun?  ◦──────────────▶        │
│  Serin/rüzgârlı · katmanlı kombin · dolabından          │
╰───────────────────────────────────────────────────────╯
```

Bu ASCII *yerleşim sözleşmesidir*. UI'da emoji düğme kullanma, ikonlar gerçek SF Symbols ve özgün uygulama bileşenleriyle üretilir.

## 2.2 Hiyerarşi

- En önde insan modeli ve kıyafet: yüksek görsel hiyerarşi.
- Arka planda şehir; kameraya doğru gelip insanı kaplamaz. Doğru derinlik, ölçü ve perspektif.
- Yağmur modelin üstünde yapay bir overlay gibi asılı kalmayacak; farklı depth katmanları, yer çarpma ve zemin ıslaklığı birlikte çalışacak.
- Hava bilgisi ve durum açıklaması okunaklı, sahne üstündeki kontrol kontrastı güvenli.
- “Yeni kombin oluştur” birincil CTA; “Canlı Ayna” ve “Ürünü Tara” görünür iki önemli ikinci yol.
- Kullanıcı seçili kıyafeti doğrudan sahneden değiştirebilir; görsel heves kırıcı zorunlu form açılmaz.
- Alt bölümde stil nedeni, kişisel dolap, öncelikli eksik parça ve alternatifler açılabilir panelde, scene-first ilkesini bozmadan.

## 2.3 Etkileşim modeli

- **Sürükleme (boş/beden üzerinde):** avatarı yatay yönde 360° döndürme; dünya kamerası yerinde kalır. Yatay hareket kontrollü, düşey hareket sheet açma/scroll ile çatışmaz.
- **Kıyafete kısa dokunuş:** RealityKit collision entity veya geometry hit-test yoluyla `GarmentSlotID` tespiti; seçim vurgusu; alt sheet / mini wardrobe tray.
- **İlgili kıyafete uzun basma:** kıyafet bilgisi; marka/model, kumaş, kanıt düzeyi, bakım ve kaynağı.
- **İki parmak:** yakınlaştır/uzaklaştır; çerçeve ve minimum mesafe sınırı.
- **Kıyafet seçim rayı:** dokunma/raycast çalışmazsa da üst-alt-ayakkabı-çanta-kemer-aksesuar kategorileri erişilebilir kalır.
- **Tam görünüm:** “Ön, Yan, Arka” kısayolları; sürüklemeye alternatif.
- **Yeni kombin:** eski görüntü hemen silinmez; uygun hazır yeni `OutfitSnapshot` ile atomik görüntü değişimi. Preload olmadan görünmeyen kaynaklara “anında” demek yasak.
- **Geri al:** bir önceki görünümü anında geri getirme; kullanıcı seçim geçmişi yerel saklanır.

## 2.4 Modelin kişiliğe benzemesi

- Beden formunu gerçek ölçüler + kullanıcı düzeltmeleri belirler; bunlar `BodyProfile` kaynak/tarih alanlarıyla saklanır.
- Stil/saç/ten/avatar görünümü ayrı **isteğe bağlı** kişiselleştirmedir. Selfie ya da kişiye benzeyen yüz üretimi zorunlu değildir.
- Bir fotoğraftan tam doğru beden/3D yüz otomatik üretildiği iddia edilmeyecek. Kullanıcı ölçü düzeltmesi ve doğruluk etiketi korunur.
- Görsel benzerlik, gerçek giysi bedenine oturma konusunda garantili hesap değildir.
- Önce düzgün giydirilmiş nötr avatar; ardından izinli gelişmiş kişiselleştirme.

---

# 3. YAŞAYAN ŞEHİR SAHNESİ — SANAL DÜNYA MİMARİSİ

## 3.1 Şehir seçimi

`sceneCity` için öncelik: kullanıcının seçtiği şehir → uygun izinli konumdan şehir düzeyi → son seçilen şehir → nötr stüdyo. **Kesin GPS gerekmiyor.** Şehir değişimi ayarlardan yapılabilir. İstanbul'da Galata çevresi; Barcelona'da sıradan bir Eixample/Gràcia atmosferi; iki pilot sahne. Şehir şablonu belirli bir noktayı rastgele “kesin burası” diye temsil etmez; görsel şehir ruhu belirtilir.

## 3.2 SceneAsset Manifest V1

```swift
struct SceneAssetManifestV1: Codable, Sendable {
  let cityID: String              // "TR-IST", "ES-BCN"
  let sceneID: String             // "galata-street-01"
  let revision: String
  let provenance: AssetProvenance // owned / licensed / userSupplied
  let approximateLandmark: String?
  let sceneUSDZ: String?         // pre-built low-poly environment
  let panoramaFallback: String? // owned/licensed panorama/depth backdrop
  let collisionProfile: String?
  let groundedWeatherVariants: [String]
  let lowMemoryFallback: String
}
```

Manifest kesin dosya isimlerini varsaymaz; `AssetProvenance` gerçek hakları belirtir. Harita servisinden izin dışı 3D sokak kopyalama/scrape etme yok. Blender çevrimdışı ortam/giysi varlık üretme pipeline'ıdır; iPhone üzerinde Blender çalıştırılmaz.

## 3.3 Hava, zaman ve yer temsili

`SceneWeatherState = {cloudiness, rainIntensity, windIntensity, illumination, wetness, evidence, updatedAt, localeDayPhase}`.

- Gerçek WeatherKit verisi **yalnız izinli ve sözleşmeye uygun ağ kapısından** gelir. Günlük otomatik alma isteniyorsa `EgressIntent` ve kullanıcı rızası güncellenir. Sağlayıcıya cihaz koordinatı yerine şehir düzeyi minimize edilmiş veri gönderimi tercih edilir.
- Yağış olasılığını “şu an yağmur yağıyor” diye yorumlama. Güncel gözlem/nowcast veya açık kullanıcı seçimi varsa aktif yağmur sahnesi. Sadece günlük olasılık varsa “yağmur ihtimali” etiketi; sahne iddiasını abartma.
- Sabah: sıcak/alçak ışık; gün ortası: doğal nötr; gece: çevresel şehir ışığı; önemli olan kıyafet renklerinin yanıltılmaması.
- **Yağmur:** düşük maliyetli GPU/particle instancing, derinliğe göre damla; zemin çarpma sprite/splash, ıslaklık için materyal roughness; performans budget korunur.
- **Rüzgâr:** hafif çevre/hareket ipuçları; gerçek doku/giysi fiziği varmış gibi iddia edilmez.
- **Kar, sis, güneş:** geçilebilir, ama ilk teslimde sadece temiz/yağmur sahnesi yeterlidir.
- Offline: son doğrulanmış veri tarih etiketli; geçersizse nötr hava/atmosfer. Uydurma sıcaklık ve sahte canlı hava yok.
- `Reduce Motion`, düşük güç, termal koşullarda parçacıklar kapatılabilir; bilgi/kompozisyon korunur.

## 3.4 Teknik kompozisyon

`SwiftUI (controls)` + `RealityKit (avatar, giysi/aksesuar entity, sahne, etkileşim)` + `Metal (gerekirse özel düşük maliyetli yağış/zemin FX)` + `Blender offline asset pipeline` + `Asset Catalog / USDZ` + `DeviceBudget / ResourceGovernor`.

- Pilot önce **lisanslı tek basit şehir görüntüsü/panorama + 3D zemin + 3D beden** ile kurulsun; fizikî asset üretilebiliyorsa tam hafif 3D sokak varyantı sonra.
- Kameranın bakış açısı kişinin tamamını görünür kılar; ayak, ayakkabı ve zemin ilişkisi görsel olarak anlaşılır.
- PBR materyaller; doğal ışık; mobil polygon/texture bütçeleri `DeviceBudget` ile eşlenir ve ölçülür. Tahminî cihaz sayısı yazma; profille.
- Model/scene/particle ayrı render ve lifecycle katmanlarında tutulur. Kıyafet değişince tüm şehir yeniden yüklenmez.

---

# 4. İLK AÇILIŞTA BUGÜNÜN KIYAFETİ HAZIR

## 4.1 Beklenen deneyim

Sabah ilk açılışta: “Bugün ne giymeliyim?” sorusunu soran bir buton değil, **modelin üstünde zaten giyilmiş bir kıyafet** görünür. Bir cümlelik stil açıklaması görünür. Sistemin o kombin için kullandığı gerçek veriler açılabilir.

## 4.2 Apple arka plan sınırlaması

- iOS `BGTaskScheduler` veya background refresh, sabah **belirli bir saatte çalışmayı garanti etmez**. “Her sabah tam 07.00'de Blender'da render” sözü verilmeyecek.
- Doğru mimari: sonraki güne aday kombinleri *önceden ve cihaz boşken* yerel cache'e hazırlamak; ilk açılışta en son güvenilir cache'i anında göstermek; uygulama aktif olduğunda güncel hava/etkinlik/kullanım durumunu kurallı biçimde yeniden doğrulamak.
- Blender sonucu yalnız **asset üretiminde**, cihazdaki dinamik kıyafet giydirme **RealityKit runtime'ında**.

## 4.3 OutfitSnapshotV1

```swift
struct OutfitSnapshotV1: Codable, Sendable {
  let localDate: String
  let cityID: String
  let bodyRevision: Int
  let slots: [GarmentSlotID: GarmentReference]
  let candidatePoolRevision: String
  let weatherEvidenceID: String?
  let weatherValidUntil: Date?
  let constraintsUsed: [String]
  let stylistReasons: [String]
  let unsupportedClaims: [String]
  let visualFidelity: VisualTruthTier
  let composedAt: Date
  let isSyntheticDemo: Bool
}
```

Bu örnek kavramsal şemadır; repodaki mevcut `DomainContracts/SystemContracts/DecisionEnvelope` tipleriyle sürümlü entegrasyon yap. Aynı adla paralel kontrat türetip drift yaratma.

## 4.4 Kombin sıralama ve değişim mantığı

Önce zorunlu filtreler: sahiplik/izin, kullanım ve yıkanabilirlik durumu, hava, etkinlik, ölçü yeterliliği, gerçek ürün uyumluluğu, sezon, kullanıcı reddi, uygun bütçe. Sonra stil: siluet dengesi, renk armonisi/kontrast, hacim, katman, kumaş ilişkisi, aksesuarın rolü, tekrar/yeni kullanım, kişisel Style DNA, çeşitlilik ve sadakat.

**Ticari komisyon skoru hiçbir zaman uygunluk skorunun yerine geçmez.** Gerekçeler doğal ve bilgiye dayanır. Astro/numeroloji yalnız açık opt-in, sembolik ve kapatılabilir ilham alanıdır; “kullanıcının ruhunu bilmek” kesin bir sınıflandırma iddiasına dönüşmez.

## 4.5 “Yeni kombin üret” algoritması

1. Önceden hesaplanmış, geçerli 3–5 alternatif varsa bir sonraki öneriye geç; `OutfitSnapshot` atomik değişir.
2. Kullanıcı “Daha sade / daha cesur / daha rahat / bugün yağmurlu” isteği verirse yerel `StyleCandidateEngine` çok hızlı yeniden sıralar.
3. Eşdeğer 3D ürün asset'i önbellekteyse gövde üzerinde geçiş uygula; yoksa kademeli yükle ve **2D/3D önizleme düzeyini açıkça etiketle**.
4. Yeni kombini beğenmediyse geri al; tanımlanabilir geri bildirim local Style DNA'ya yazılır.
5. Dolabında uygun tek kombin varsa “yeni çeşitlilik” uydurma. İsteğe bağlı satın alma eksikleri ayrı etikette.
6. Görünür her kombin, fotoğraf/dolap kaynakları ve görsel varlık lisansı bakımından izlenebilir olmalı.

---

# 5. KIYAFETE DOKUNMA VE GERÇEK GİYDİRME MİMARİSİ

## 5.1 Garment slots

```text
TOP | BOTTOM | OUTERWEAR | DRESS | FOOTWEAR | BAG | BELT |
EYEWEAR | HEADWEAR | JEWELRY | OTHER_ACCESSORY
```

Her ürün slot/katman, `GarmentEntity`/`AssetRevision`/`VariantID`/`Provenance` bağlarıyla tanımlanır. Örn. ceket dış katmandır; gömleğin üstünde render edilir; kullanıcı ceket üstüne dokunduğunda üst iç çamaşırı yerine ceket çekmecesi açılır. Askıdaki ayakkabı mesh'i vücutla zayıf bağlanmaz; sol/sağ ayak attachment sistemi olmalı. Çanta el/omuz attachment ve çakışma kontrolüne sahiptir.

## 5.2 3D varlık seviyeleri

- **T0:** kıyafet giymemiş/kontur model; gerçek ürünün üstünde görünümü iddia edemez.
- **T1:** kategoriye uygun generic giydirme; renk/siluet yaklaşık, açık “temsili” etiketi.
- **T2:** markanın lisanslı veya kullanıcının hazırladığı **ürüne özel** 3D asset; SKU ve renk eşleşmiş.
- **T3:** kalibre kumaş parametreleri/ölçü verisiyle daha gerçekçi drape; gerçek dünya karşılaştırması olmadan “tam uyum” denemez.
- **T4:** görsel üretken video/VTON; fotogerçekçi olabilir ama fiziksel beden doğruluğu değildir.

T0/T1'i T2/T3 diye sunmak `STOP_THE_LINE` sebebidir. Bir fotoğraftan tüm markalara gerçek ve ölçülü 3D kıyafet otomatik üretimi şu an doğrulanmış kabul edilemez. Teknik gereklilikler: pattern/CAD, SKU varlık hakları, kumaş kalibrasyonu, katman ve attachment, gerçek prova veri seti.

## 5.3 Doğrudan seçim

- RealityKit collision/raycast ile dokunulan gerçek kıyafet katmanını bul; mobilde dokunma alanını doğrula.
- Modeli döndürme ve kıyafete dokunmayı farklı gesture failure precedence ile ayır.
- Seçili slot ışıklı animasyon değil, doğal ince çizgi / temas göstergesi; 44×44 erişilebilir kontrol karşılığı her zaman var.
- Alt tray 2 seçenek sunar: **Dolabımdan** (birinci) / **Mağazadan** (ikinci); kullanıcı izin vermedikçe alışverişe yönlendirme yok.
- Kıyafet önerileri mevcut sayfayı değiştirmeden üstüne uygulanır.
- Undo/redo, variant conflict ve eksik asset durumları test edilir.

---

# 6. CANLI AYNA — KULLANICIYA KENDİSİNİ GÖSTEREN GERÇEK VTON

## 6.1 Kritik fark

**Home World:** kameraya bakmayan 3D kişisel avatarı ekranda gösterir. 360° döner. Şehir sahnesinde giydirilir.

**Live Mirror:** ön/arka telefon kamerasındaki *gerçek kişiyi canlı video olarak* gösterir. Kişinin üstünde şu anda başka kıyafet olsa dahi seçilen ürünle değişmiş görsel görünüm hedeflenir. Kullanıcı hareket ettikçe video güncellenir.

Biri diğerinin yerine kullanılamaz. Sadece 3D manken animasyonu yapıp “Live Mirror tamam” demek yasaktır.

## 6.2 Kullanıcı akışı — mağazada

1. Kullanıcı mağazada ürün barkodunu/etiketini tarar veya ürünün fotoğrafını çeker.
2. Sistem `ProductResolver` ile marka-model-renk/beden varyantını eşleştirir; emin değilse kullanıcıya seçenek verir.
3. Ürün kartı: görüntü, kaynak, etiket kanıtı, fiyat varsa kaynağı, kıyafet asset uygunluğu.
4. Kullanıcı **“Üzerimde Canlı Dene”** der.
5. Kamera izni ve local mode açılır; ekranın büyük bölümünde kullanıcının gerçek canlı kamera görüntüsü bulunur.
6. Poz/vücut segmentasyonu + kıyafet hizalama + occlusion/temas yüzeyleriyle seçilen ürünün yaklaşık overlay'i sunulur. Ürün asset'i yoksa gösterim uydurulmaz.
7. Kullanıcı hareket eder; görüntü sürekli güncellenir. Kolun kıyafetin önüne geçmesi gibi occlusion doğru işlenemiyorsa kalite etiketi ve kontrollü fallback gösterilir.
8. Kullanıcı **AI Canlı Dene** opsiyonunu özellikle isterse ek izin/maliyet açıklamasından sonra bulut servisine geçilebilir (varsayılan kapalı).
9. Kapat: kamera ve varsa ağ oturumu derhal sonlanır; frame ve geçici dosya silme denetimi yapılır.

## 6.3 Kullanıcı akışı — internette

- iOS Share Extension, ürün URL'si yapıştırma, PhotosPicker'dan ürün ekran görüntüsü veya katalog içi seçim.
- Sahte SKU üretme; gerçek URL/katalog haklarına ve ticari gösterim iznine bak.
- Link ve ekran görüntüsünün eşleşme güvenini göster; beden/rengin manuel teyidi.
- Ürün sayfasındaki tek görselden kumaş gerçeği veya gerçek beden garantisi çıkarma.
- **Modelimde Gör** → 3D Home World; **Canlı Dene** → Live Mirror. Aynı ürün veri kaynağı kullanılır.

## 6.4 Live Mirror teknik hatları

| Hat | Platform | Amaç | Gerçek sınırlama |
|---|---|---|---|
| Local Camera | AVFoundation | Canlı self-view, mirror flip, kamera ömrü | Fiziksel cihaz kamera testi gerekir |
| Pose/Body | Apple Vision + on-device Core ML segmentasyon | Vücut noktaları, giysi/insan maskeleri, temporal smoothing | Poz algılama tek başına kıyafet değiştirme modeli değildir |
| Overlay/Compositing | Metal/RealityKit | Giysi görsel/mesh bindirme, maskeleme, occlusion, transform | Foto-gerçekçi çok katmanlı drape garantili değildir |
| Remote VTON | Decart iOS SDK `decart-ios` + Lucy V-TON 3.6 | Gerçek kişi videosuna AI giysi dönüşümü | **Cihaz içinde değildir; video buluta gider; ücretli ve rızaya bağlıdır** |
| Precision Fit | BodyProfile + gerçek ürün ölçüsü + fit truth | Hangi beden tahmini, hangi bölgede dar/bol | Görsel VTON'dan bağımsızdır |

**Aday kaynaklar (araştır, kopyalamadan/entegrasyondan önce sürüm-lisans doğrula):**
- https://developer.apple.com/documentation/realitykit
- https://developer.apple.com/documentation/vision/vndetecthumanbodyposerequest
- https://github.com/DecartAI/decart-ios
- https://platform.decart.ai/models/lucy-vton
- `docs/research/VTON_LANDSCAPE_2026-11.md`

Resmî Decart API `lucy-vton-3.6` kamera video stream + giysi referans görüntüsü/prompt alıyor; iOS SDK LiveKit tabanlı yerel Swift bağlantısı sunuyor. **SDK'nin MIT lisansı, uzaktaki modelin ticari lisansını veya görüntü gizliliğini otomatik çözmez.** Geçici token broker (kalıcı anahtar uygulamada bulunmaz), DPA, retention doğrulaması, uygulama içi maliyet limiti, süre sınırı ve kullanıcının açık rızası gerekir. Lisans ve hukuk kapısı açılmadan bulut feature flag'i kapalıdır.

**Kritik görünüm problemi:** Kullanıcının üzerinde gerçek kıyafet bulunurken yeni kıyafet gösterme, eski kıyafetin görünümünü gizleme/değiştirme problemidir. Basit üst üste bindirme bunu her pozda doğal yapmaz. Değerlendirilecek testler: çok bol mont üzeri ince gömlek, çapraz kollar, uzun saç, el/çanta occlusion, geniş kollu ceket, hızlı dönme, ayna karşısı, düşük ışık, reflektif kumaş, logo, yazı/desen, zayıf ağ. Bu durumda **başarısız sahneyi kusursuzmuş gibi gösterme**.

## 6.5 Live Mirror ekran sözleşmesi

```text
╭─────────────────────────────────────────────╮
│ ← Canlı Ayna                  YEREL / AI    │
│                                             │
│    [ GERÇEK CANLI KAMERA GÖRÜNTÜSÜ ]        │
│          kişi hareket ediyor               │
│          seçilen ürün video üzerinde        │
│                                             │
│     [ ürün küçük referans resmi ]           │
│                                             │
│  [Bu ürünü değiştir]    [Beden önerisi]     │
│                                             │
│     Görsel simülasyon ≠ kesin beden         │
│                                             │
│      [Kapat]              [Kaydet*]         │
╰─────────────────────────────────────────────╯
*Yalnız kullanıcı eylemiyle ve açık kayıt izniyle.
```

Kamera açılmadan UI iskeleti gösterilebilir. Ancak kamera-only görüntüyü “kıyafeti denedi” diye etiketleme; `MirrorFidelity.cameraOnly` doğru açıklaması görünür. Yerel overlay başarısızsa kullanıcının kameradaki gerçek görüntüsü durmalı ve “giysi bu pozda gösterilemiyor” bilgisi çıkmalı.

---

# 7. FOTOĞRAFLARDAN DOLAP OLUŞTURMA İLE BAĞLANTI

`PhotoPicker/PhotosPicker` → kullanıcı seçimi/limitli erişim → cihaz içi vision tespit/segmentation → benzer ürün kümesi → taslak kartlar → kullanıcı düzeltme/onay → `Wardrobe`/şifreli `Vault` → `OutfitEngine` → `AvatarDressing` → Home World.

**Önemli:** Fotoğraftaki kıyafet, otomatik olarak kişinin malı kabul edilemez. Mağazada çektiği ürün fotoğrafı ve kendi dolabındaki kıyafet farklı kaynak türleridir (`USER_OWNED`, `SEEN_IN_STORE`, `WISHLIST`, `CATALOG`) ve karışamaz. Fotoğrafları geniş aralıkla taramak açık seçim gerektirir. Tüm fotoğraf işleme otomatik buluta çıkmaz. Duplicate clustering kopya giysileri yanlış birleştirirse inceleme kuyruğundan düzeltilir.

Ürün üzerinde yanlış renk/logo/desen tespiti “kesin doğrulandı” sayılmaz. Ürün/fit kanıtı ayrı yönetilir.

---

# 8. ÇALIŞMA ZAMANI: “AI ORDUSU” ÇOK MODÜL, TEK DENEYİM

**Devasa sayıda ayrı LLM/ajanı her frame'de çalıştırmak teknik olarak yanlış.** Kamera 30 fps çalışırken katalog, astroloji, modelist, güvenlik ve moda ajanlarının her karede eşzamanlı cevap vermesi gecikme, pil ve maliyeti patlatır.

Doğru sistem: **Event-driven Specialist Graph**. Önceki Octopus/Citadel sistemine eklenir; ikinci bir küresel koordinatör yazılmaz.

```text
[App lifecycle] ──────────┬─> World State Orchestrator
[Time/city/weather] ──────┤         ├─ Scene Asset Resolver
[Body profile] ───────────┤         ├─ Today Outfit Composer
[Wardrobe edits] ─────────┤         ├─ Avatar Dressing Engine
[Garment tap] ────────────┤         └─ Weather FX Renderer
[Product scanned] ───────┤
                            └─> Mirror Orchestrator
                                      ├─ Product Identity + Rights
                                      ├─ Local Camera + Pose
                                      ├─ Segmentation + Occlusion
                                      ├─ Local Overlay / Fallback
                                      ├─ [Optional] Consent + Remote VTON
                                      └─ Precision Fit (separate)
All ──> Citadel privacy + DeviceGovernor + EvidenceGate + Telemetry QA
```

**Uzman grupları (rol, tetikleyici, compute):**

1. **Scene Director:** şehir/hava/gün fazı değiştiğinde, deterministic, near-zero-frame overhead.
2. **Weather Interpreter:** güncel/önbellek/eksik ayrımı, event tabanlı.
3. **Personal Avatar Geometry:** ölçü revizyonunda / asset yüklemede; frame başına değil.
4. **Wardrobe Vision:** kullanıcı fotoğraf seçtiğinde; local Core ML, batch.
5. **Product/Logo/Variant Specialist:** taramada; OCR+hak+kanıt.
6. **Fabric/Patternmaker Specialist:** ürün spec ve metrology; katalog güncellendiğinde.
7. **Fit Scientist:** ürün+body ölçüsü değiştiğinde; fiziksel doğruluk.
8. **Creative Stylist:** sabah/istenen yeni kombin; kombin sayısını ve kalitesini sınırlı arama ile optimize eder.
9. **Personal Style Learner:** kullanıcının onaylı beğenme/ret olaylarında hafif yerel güncelleme.
10. **Scene Graphics/Physics:** render loop (Unity/Unreal gerekmedikçe native RealityKit/Metal).
11. **Pose/Segmentation Renderer:** Live Mirror frame path; NPU/GPU budget kontrollü.
12. **VTON Provider Adapter:** yalnız cloud opt-in ve bütçe sonrası.
13. **Privacy/Access Controller:** her erişim ve ağ çıkışı öncesi.
14. **Truth/Evidence Reviewer:** her kullanıcı-facing kesin iddiada kanıt.
15. **Performance Governor:** termal/hafıza/FPS/latency gözlemci.
16. **UX/Accessibility Guardian:** alternatif dokunma hedefleri, VoiceOver, Reduce Motion.

Bu roller farklı `WorkOrder` tipleri veya Swift modülleri olabilir. Kullanıcı bütün ordunun detayını GÖRMEZ; sadece akışkan bir ürün görür.

---

# 9. YENİ SÜRÜMLÜ ARAYÜZ/KONTRAT TASLAĞI

Gerçek `SystemContracts` namespace'i ile uzlaştır; paralel kimlik sistemleri oluşturma.

```text
WorldContextV1
  userSelectedCityID, weatherEvidence, dayPhase, locationSource,
  sceneManifestRevision, sceneMode, lastRefreshedAt

DressedAvatarStateV1
  bodyProfileRevision, bodyGeometryRevision, avatarIdentityRevision,
  selectedOutfitID, slotAssetRefs, visualFidelity, pose,
  cameraYaw, cameraZoom, renderHealth

GarmentSlotSelectionV1
  slotID, garmentReference, productVariantID, assetRevision,
  ownerSource, permissionProof, selectionReason, selectedAt

OutfitChangeRequestV1
  commandID, action={replaceSlot|nextOutfit|undo|redo}, slotID?,
  constraints, source={wardrobe|retail|recommendation}

MirrorTryOnIntentV1
  productIdentityID, requestedFidelity, requestedMode,
  cameraPermission, costConsent?, retentionConsent?, reason

VisualTruthV1
  viewer={avatar|liveCamera}, tier, skuAssetEvidence,
  simulationLimitations, bodyFitProof=independent
```

**Anti-race:** farklı kıyafet setleri ardışık seçildiğinde eski async yükleme yenisini geriye almamalı (`commandID`/revision token). Aynı anda weather background switch + garment swap + kullanıcı rotate gerçekleştiğinde modelin transform'u korunur.

---

# 10. PERFORMANS HEDEFLERİ VE AKILLI FİDELiTE AZALTMA

Bu sayılar **ürün hedefi** olup bu repo için ölçülmüş sonuç değildir. Claude önce baseline alır, cihaz sınıfına göre eşikleri ölçer/revize eder.

| İşlem | Hedef başlangıç SLO | Kanıt |
|---|---|---|
| Soğuk açılıştan ilk anlamlı sahne | p95 ≤ 2,5 sn, desteklenen cihaz sınıfında | Instruments + gerçek cihaz video |
| Önbellekli sıcak açılış / ilk kombin | p95 ≤ 1,0 sn | signpost app lifecycle |
| Hazır 3D asset'le tek parça değişim | p95 ≤ 0,5–1,0 sn | tap-to-visual-stable |
| Önbellekli adaylar arasında yeni kombin | p95 ≤ 1,0 sn | tap-to-dressed-avatar |
| 360° döndürme | hedef 60 fps; enerji sıkışınca ≥30 fps kontrollü | GPU profiler + frame hitches |
| Yerel canlı kamera görüntüsü | doğal kamera akışı hedef ≥24–30 fps | AVFoundation/preview metrics |
| Yerel VTON overlay | mümkün olan en düşük gecikme; cihaz ölçümü olmadan rakam garanti değil | capture-to-render p50/p95 |
| Bulut AI Live Mirror | sağlayıcı/ağ bağımlı; “anlık” iddiası ancak test sonrası | end-to-end cam-to-output p95 |
| Termal/pil kritik | degrade veya stop, durum açıkça görünür | fault injection + gerçek cihaz |

**Önemli ayrım:** Kıyafet “saniyesinde” görünmesi için yeni render hesaplamak yerine **prewarmed kıyafet asset'leri + önceden hesaplanmış outfit adayları + atomik swap** kullan. Gerçek katalog asset'i indirilmemişse veya cloud VTON bağlantısı kuruluyorsa “anında” garantisi yok. Progress feedback ve fail-safe göster.

## DeviceGovernor degradeleri

- P0: 3D şehir / çevre + avatar + tam hava partikülleri.
- P1: LOD/panorama + avatar + sınırlı yağmur.
- P2: statik şehir görüntüsü + 3D avatar + meteoroloji etiketi.
- P3: 2D avatar/kombin kartı + slot seçim UI; 3D yoksa 3D var denmez.

Aynı foto-kalite preset'i bütün cihazlarda sabit zorlanmaz. FPS, CPU/GPU yükü, sıcaklık, RAM, pil, erişilebilirlik tercihi sistemin kararına dahildir.

---

# 11. GÖRSEL DOĞRULUK, GÜVENLİK VE SINIRLAR

1. **Ürün kimliği**: SKU/renk/beden doğru değilse müşteri odaklı sonuç yayımlama. Çok markalı katalog için veri erişimi/sözleşme gerekir.
2. **Giyilebilirlik**: 3D fotogerçekçiliği gerçek ürün ölçüsünün doğruluğu gibi sunma. Precision Fit ayrı kanıt hattıdır.
3. **Logo ve desen**: Referans fotoğrafı ile üretilmiş/overlay görüntünün sapması etiketlenir; yanlış logo ile markalı ürünü gerçekmiş gibi satma.
4. **Yüz ve beden**: Kullanıcı seçerse kişisel görsel; yüz görsellerini dışarı göndermek varsayılan olarak yasak; kayıt açık eylemle.
5. **Yer**: Hassas konum isteği varsayılan değil; şehir seçimi. WeatherKit egress sözleşmesi gerektirir.
6. **Yağmur**: görsel canlı hava iddiası hava kaynağıyla uyumlu; offline/stale data açıkça belirtilir.
7. **Cloud provider**: kamera/video uzak servise gider; kullanıcıya gizlilik, bölge, saklama, maliyet açıklaması; yalnız izinli ayrı oturum. Permanent API key uygulamaya gömülmez.
8. **Çocuklar/yaş**: kişisel görüntü ve fiziksel beden açısından ihtiyaca uygun yaş/gizlilik önlemleri hukuki inceleme gerektirir; yetişkin varsayımıyla kör işlemez.
9. **Ölçü/veri silme**: `Vault`, `CitadelGate`, `ConsentLedger`, `EgressIntent` üzerinden geri alınabilir.
10. **Kayıt/yayın**: varsayılan kayıt yok; screenshot/save yalnız açık eylemle.
11. **Modellerin lisansı**: modellerin kod ve ağırlıkları ayrı denetlenir; SMPL/SMPL-X, Mobile-VTON, CatVTON vb. için ticari haklar doğrulanmadan ürün varlığına alma.
12. **Bağımsız review**: güvenlik ve beden doğruluk testini üretici ajan tek başına PASS yapamaz.

---

# 12. UYGULAMA DOSYA MİMARİSİ: ÖNERİLEN HARİTA

Bu yeni dosyalar **öneridir**. Repo yapısına en az kırıcı biçimde uyarlanır. Mevcut `Octopus`, `BodyGeometry`, `LiveMirror`, `SystemContracts`, `Vault` ve `TravelEngine` kullanılır.

```text
apps/ios/Kabinsiz/
  DesignSystem/
    Theme.swift                       # Warm Quiet Atelier tokens
    StudioControls.swift              # minimal on-scene controls
  Features/Today/
    TodayView.swift                   # living world first
    HomeWorldView.swift               # scene + avatar orchestration UI
    OutfitControlTray.swift           # slot picker, undo, alternatives
    TodayStyleReasonSheet.swift
  Features/SceneWorld/
    SceneAssetLoader.swift            # licensed scene manifest
    WorldWeatherEffects.swift         # device-budgeted rain/ground FX
    CityScenePicker.swift
  Features/Avatar/
    DressedAvatarRealityView.swift    # 3D clothing + avatar entity
    AvatarTapAndRotateController.swift
    ClothingAssetRegistry.swift
  Features/LiveMirror/
    LiveMirrorEntryView.swift
    LocalMirrorCameraView.swift
    MirrorGarmentSelector.swift
    RemoteVTONConsentView.swift
    LiveMirrorSessionView.swift
  Features/ProductImport/
    BarcodeCameraView.swift
    ProductShareIntake.swift
    ProductEvidenceReviewView.swift
Packages/KabinsizCore/Sources/
  LivingWorld/                       # city/weather/context/state contracts
  TodayOutfit/                        # cache, rank, reroll, provenance
  AvatarDressing/                     # slot/raycast/drape truth
  ProductImport/                      # barcode/URL/data rights
  LiveMirror/                         # REUSE existing contracts and state machine
  WardrobeVision/                      # photo-to-wardrobe local
  SystemContracts/                    # REUSE contracts + audit
assets/
  scenes/                              # 2 licensed pilot street scenes
  avatar/                              # commercially permitted body assets
  garments/                            # ONLY licensed/owned demo models
  sources-and-licenses.json

docs/evidence/v25/
  screenshots/                         # real simulator only
  device-videos/                       # real iPhone only, consent, no raw private frames
  performance/
  privacy/
  rights/
  audit/
```

Üçüncü taraf ürün/repo/MCP kurulumları kullanıcı ve güvenlik onayı gerektirir. Ücretsiz görünse bile lisansı ticari doğrulanmadan production build'e girmez.

---

# 13. AŞAMALI GERÇEK UYGULAMA PLANI — ÖNCE OYNANABİLİR DİKEY DİLİM

İş paketleri bağımlılığa göre sıralanır. Claude'un hedefi “bütün MD'yi bir kerede bitirdim” değil, her kapıda çalışan ve kanıtlı bir ürün dilimi olmalıdır.

| WP | İş / gerekli çıktı | Bağımlılık | İlk kanıt |
|---|---|---|---|
| **V25-00** | Güncel repo HEAD/cihaz/SDK/lisans/baseline denetimi; eski anayasa çatışmaları | — | `docs/audit/V25_REALITY.md` |
| **V25-01** | İlk home storyboard, layout, warm tokens, tasarım denetimi | 00 | SwiftUI gerçek screenshot + referans kıyas |
| **V25-02** | BodyModel3DView → `DressedAvatar` entegrasyonu, tüm açılarda 360° dönüş | 01 | Üç açı + serbest dönüş video |
| **V25-03** | Sahip olduğumuz **bir lisanslı/özgün demo giysi** model üstüne gerçek asset ile giydirme | 02 | Önden/yandan/arkadan dikiş/mesh testi |
| **V25-04** | Slot hit-test + üst-alt-ayakkabı değişim tray + geri al | 03 | “Üste dokun → başka üst → model güncellendi” E2E |
| **V25-05** | İstanbul ve Barcelona için iki kontrollü scene manifesti; statik/panorama → hafif 3D | 02 | Şehir değişimi screenshot ve lisans kaydı |
| **V25-06** | Yağmur + yere çarpma + ıslak zemin + gün ışığı değişimi | 05 | Simüle hava testi + FPS/termal kayıt |
| **V25-07** | `TodayOutfitEngine` + yerel cache + “Yeni kombin üret” + undo | 03,04 | Tek dokunmayla tüm görünüm değişimi |
| **V25-08** | `WeatherEvidence` ile gerçek hava/izin/offline senaryoları, kullanıcıya şeffaf gösterim | 05,06,07 | canlı/stale/none ayrım testi |
| **V25-09** | `PhotosPicker` → yerel giysi → onay → Vault → sahne kıyafet seçimi | 04,07 | fotoğraftan dolaba 1 ürün E2E |
| **V25-10** | Barkod/kamera/ürün linki/screenshot intake + varyant/hak denetimi | 00,03 | demo barkod + belirsiz ürün negatif testleri |
| **V25-11** | Live Mirror local: gerçek kamera, poz, segmentation, tek izinli kıyafet overlay | 10 | gerçek iPhone 10 saniyelik videolu kanıt |
| **V25-12** | Live Mirror hareket/occlusion/ışık fallback ve kapanış kaynak yönetimi | 11 | kol/hızlı dönme/ısı/arka plan testleri |
| **V25-13** | Remote VTON provider spike (izinli, izole); kalıcı entegrasyon kararı ayrı | 11,12 | privacy/cost/latency/rights raporu; BLOCKED olabilir |
| **V25-14** | Stil kalite paneli, fit doğruluk, SKU/logo doğruluğu; bağımsız review | 07,10,11 | holdout ve red-team kayıtları |
| **V25-15** | Premium motion/haptics/accessibility/VoiceOver/dynamic type polish | 04–12 | UI/a11y screenshot ve interaction test |
| **V25-16** | Perf/thermal/power gerçek cihaz matris + release gate | 00–15 | p50/p95 ölçümleri ve açık kusurlar |

**Mühendislik önceliği:** İlk `V25-01→07` oynanabilir dünya; ardından `V25-10→12` canlı ayna; iki hatta ürün veri sözleşmesi ortak. `V25-09` fotoğraf dolabı da yüksek önceliktir ama 3D dünyayı bekleterek bütün foto arşivini taramaya saplanmak yasak. Mevcut WP15/LM21/R17 işleri atlanmaz; bağımlılıkların ilgili maddeleriyle ortaklaştırılır.

---

# 14. EKSİKLERİ SAKLAMAYAN 36 KABUL TESTİ

| ID | Senaryo | PASS için gereken |
|---|---|---|
| V25-T01 | App ilk açılış | model bugünün kombiniyle birincil viewport'ta; sahte veri varsa etiketli |
| V25-T02 | İstanbul seçimi | Galata bağlamlı lisanslı/özgün şehir sahnesi |
| V25-T03 | Barcelona seçimi | şehir özgü farklı gündelik sokak sahnesi |
| V25-T04 | Şehir değişimi | sahne yenilenir, beden ve kıyafet kaybolmaz |
| V25-T05 | Canlı yağmur | veri gözlemine uygun damlalar; zemin çarpma; ıslaklık |
| V25-T06 | Yağmur verisi yok | sahte canlı yağmur iddiası yok; neutral fallback |
| V25-T07 | Gece/gündüz | ışık bağlama uygun, kıyafet rengi yalancı kaymaz |
| V25-T08 | 360° | 0–360 döner, görünüm aynı ürün slotlarıyla korunur |
| V25-T09 | Ön/yan/arka | presetler tutarlı ve erişilebilir |
| V25-T10 | Drag/tap | döndürme ile slot seçimi çatışmaz |
| V25-T11 | Üstü değiştir | gerçek üst entity güncellenir; diğer slotlar sabit |
| V25-T12 | Altı değiştir | katman/hacim tutarlı |
| V25-T13 | Ayakkabı değiştir | iki ayak attachment güncellenir |
| V25-T14 | Çanta/kemer/aksesuar | kategoriye uygun attachment ve fallback |
| V25-T15 | Kıyafet değişirken döndür | revizyon yarışından eski asset geri gelmez |
| V25-T16 | Yeni kombin | başka geçerli `OutfitSnapshot` aynı sahnede görünür |
| V25-T17 | Geri al | önceki kıyafet tam slot state ile döner |
| V25-T18 | Hava / stil gerekçesi | gerçek evidence/kişisel tercihle tutarlı |
| V25-T19 | Uygun alternatif yok | yeni/uygun olmayan ürün uydurulmaz |
| V25-T20 | İlk açılış ve cache | p50/p95 gerçek cihaz logu; zaman hedefi raporlanır |
| V25-T21 | Termal düşük güç | yağmur/LOD azalır, kontroller çalışır |
| V25-T22 | Photo → wardrobe | izinli tek foto → insan onayı → local vault |
| V25-T23 | Foto sahiplik kaynağı | mağaza fotoğrafı yanlışlıkla sahiplik olarak işlenmez |
| V25-T24 | Barkod doğru eşleşme | SKU/renk/beden ve kanıt kayıtlı |
| V25-T25 | Barkod belirsiz | manuel seçim ister; sahte kesin ürün yok |
| V25-T26 | Link/screenshot | ürün tanıma hak/provenans içinde; çözülemiyorsa belirsiz |
| V25-T27 | Live Mirror gerçek kamera | kullanıcının gerçek video akışı görünür |
| V25-T28 | Overlay | uygun asset/kamera olduğunda giysi değişimi görünür; kamera-only açık etiketli |
| V25-T29 | Üstünde başka kıyafet | occlusion, kollar, saç ve eski kıyafet tutarlılığı test edilir |
| V25-T30 | Hızlı dönüş / gövde kaybı | hatalı giysi çizilmez; kontrollü degrade |
| V25-T31 | Live Mirror ağ kapalı | local mod çalışır veya doğru fallback; bulut başlamaz |
| V25-T32 | Remote cloud seçimi | kullanıcıdan açık maliyet/video/retention izni olmadan network video yok |
| V25-T33 | Kamera kapat | camera/remote token/temporary frame temizlenir |
| V25-T34 | Beden gerçeği | VTON görüntüsü kesin fit tavsiyesine dönüştürülmez |
| V25-T35 | Ürün asset yok | generic/2D etiketi, yanlış SKU veya logo yok |
| V25-T36 | Erişilebilirlik | VoiceOver slot seçimi, Reduce Motion, yüksek kontrast, alternatif kontrol |

**Bu test listesi yazılmış senaryodur, geçmiş test sonucu değildir.** Claude her test için gerçek `PASS/FAIL/BLOCKED/NOT_RUN`, cihaz, tarih, commit SHA ve artefact sunar.

---

# 15. EN ÖNEMLİ 12 BAŞARISIZLIK MODU

1. Şehir arka planı pahalı olduğundan ana model geç yükleniyor.
2. Yağmur parçacıkları kıyafetin önüne yanlış çizilip plastiksi duruyor.
3. Hava olasılığı gerçek zamanlı yağış gibi gösteriliyor.
4. Avatar döndürüldüğünde ceket arkada kayboluyor veya gerçek mesh dönüşmüyor.
5. Cekete dokununca pantolon seçiliyor; kontrol çakışıyor.
6. Ayakkabı gibi çift varlıklarda tek taraf değişiyor.
7. “Yeni kombin” gerçek 3D avatarı değil yalnız metin kartını değiştiriyor.
8. Uygun ürün asset'i yokken sadece fotoğraf üzerinden gerçek fit iddiası veriliyor.
9. Kamera-only görüntü “Live Mirror başarılı” diye raporlanıyor.
10. Kullanıcının kendi kıyafeti varken üretilen ceket vücutta yapay delik/kol bozulması oluşturuyor.
11. Cloud VTON kullanıcı izni olmadan video gönderiyor / API key uygulamada kalıyor.
12. Test yalnız simülatör sahnesiyle geçip fiziksel iPhone kamera/ısı testleri olmadan DONE yazılıyor.

Her biri ayrı negatif test, failure state ve kullanıcıya doğru açıklama gerektirir.

---

# 16. BAĞIMSIZ UZMAN/AGENT DENETİMİ

- Product Director / Fashion UX: scene-first deneyim ve kullanıcı kararının sadeliği.
- Editorial Design Director: kompozisyon/renk/premium materyal ve görsel bütünlük.
- 3D Technical Artist + Blender/RealityKit Engineer: mobile-ready avatar, rig, clothing attachment, sahne.
- Apparel Patternmaker + Textile Specialist: kalıp/drape/kumaş gerçeği; insan uzman kontrolü.
- Realtime Graphics & Performance Engineer: yağmur/LOD/Metal/Core Animation.
- On-device Vision Specialist: insan segmente/poz takibi/perf.
- Realtime VTON Scientist: local vs cloud çıktı ve temporal coherence.
- Retail Product Data Specialist: marka/SKU/rights.
- AppSec & Privacy: camera, photo, location, remote tokens, retention.
- Accessibility/Interaction Engineer: gestures/VoiceOver/Reduce Motion.
- Independent QA/Red Team: görsel ve kullanışlılık denetimi, gerçeğe yakın test.

Ajanlar insan uzman deneyini taklit edip doğruymuş gibi iddia etmez; gerçek ölçüm paneli ve lisans soruları gerektiğinde `BLOCKED_EXTERNAL` kalır.

---

# 17. CLAUDE'A KESİN YASAKLAR

- Yalnız `TodayView` içine yeni kartlar koyup “oyun gibi dünya” demek.
- Yalnız nötr çıplak manken döndürüp giydirilmiş avatarı tamamlanmış saymak.
- Kamera önizlemesini gösterip kıyafet değiştirmeden “Live Mirror bitti” demek.
- İstanbul ve Barcelona için hakları belirsiz internet fotoğrafı otomatik çekmek.
- Sahte yağmur/gerçek canlı hava bilgisi üretmek.
- Haftalık/sabah iOS background görevlerinin saatini garanti etmek.
- “Her marka, her ürün, her beden, anında gerçek fiziksel fit” iddiası.
- Kaynak şeffaflığı olmayan ticari lisanslı 3D/model yüklemek.
- Uygulama içinde Decart kalıcı anahtar bulundurmak.
- Simülatördeki basit görüntüyü fiziksel iPhone 30 fps kanıtı olarak sunmak.
- v2.4'ü, güvenlik ve çalışan testi geri alacak şekilde silmek.

---

# 18. CLAUDE'UN İLK ÇIKTISI / YAPILACAK KOD

Claude işe başlarken:

1. Güncel HEAD + toolchain + test envanterini doğrula ve `V25_REALITY.md` oluştur.
2. Kullanıcı yolculuğunu `ENTER_WORLD → VIEW_OUTFIT → TAP_TOP → CHOOSE_ALTERNATIVE → SEE_ON_BODY → REROLL → UNDO → SCAN_PRODUCT → OPEN_LIVE_MIRROR → SEE_SELF_WITH_SELECTED_GARMENT → CLOSE` olarak açık state diagram'a bağla.
3. Mevcut `TodayView`, `BodyModel3DView`, `MirrorSession`, `Vault`, `CitadelGate` koduyla sürüm çatışması haritası oluştur.
4. İlk gerçek **oynanabilir Home World** dilimi: tek nötr avatar + owned/lisanslı örnek üst ve alt + küçük lisanslı İstanbul scene + bir slot swap + 360° drag. Göstermelik kart değil, RealityKit sahnesi.
5. Aynı sahnede tasarım token'ları ve premium kontrol rayını uygula; orijinal `.swift` dosya değişikliklerini göster.
6. Kod/test/simulator screenshot + VoiceOver ve Reduce Motion kanıtını üret.
7. Sonra Barcelona sahnesi ve hava efekti/zemin; outfit reroll.
8. Sonra gerçek kamera + yerel overlay prototipi; **gerçek iPhone yoksa `DEVICE_BLOCKED`**.
9. Yalnız kullanıcı izni + hukuk + maliyet doğrulamasından sonra uzaktan Lucy V-TON araştırması.

İlk 3 görevi yalnız raporlayıp çalışmayı durdurma; izinli ve teknik olarak mümkün olan ilk P0 dilimi kodla, testi çalıştır, commit'i göster (korumalı branch; main'e kendiliğinden merge yapma). Kullanıcıdan yalnız gerçekten dış eylem veya ücretli servis onayı gerektiğinde izin al. **Yapılmayanı DONE yazma.**

---

# 19. DEMO VE GERÇEK ÜRÜNÜ AYIR

İlk demo için özgün/generik bir üst ve pantolon giydirme asset'i üretmek mümkündür; bunun amacı **algıdan sonuca 3D etkileşimin** gerçek olduğu kanıtıdır. Ama gerçek marka ürününün kalıbı/dikişi/logosu yerine geçemez.

Gerçek ürün için `VERIFIED_IDENTITY`, `MEASUREMENTS_AVAILABLE`, `ASSET_LICENSED`, `ASSET_MATCHES_SKU`, `BODY_CALIBRATION`, `TRYON_FIDELITY` kanıtları ayrı olmalı. Kullanıcıya her seviyeyi anlaşılır dilde anlat.

---

# 20. NİHAİ ONAY

İlk sürümün değerini şöyle test edeceğiz:

**Kullanıcı kabine girmeden önce bir ürünü üç aşamada sınayabilecek:**

1. **Bana yakışır mı?** → canlı kişisel stilist, gerçek dolap, renk/aksesuar/bağlam.
2. **Üstümde nasıl görünür?** → 360° avatar ve izinliyse gerçek kamera üstü Live Mirror.
3. **Gerçekte bedenim olur mu?** → ayrı ürün ölçüsü/beden kanıtı ve dürüst güven sınırı.

Bu üç cevap hiçbir zaman birbirinin yerine geçmez.

**Çekirdek ürün vizyonu:** Kullanıcı her sabah kendi yaşayan şehrinde giyinmiş dijital kendisiyle karşılaşır. İsterse tek dokunuşla görünümünü değiştirir. Mağazaya girince telefonun kamerası gerçek bir prova aynasına dönüşür. Hepsi mümkün olduğu kadar cihazında çalışır; yanıldığında dürüstçe söyler.

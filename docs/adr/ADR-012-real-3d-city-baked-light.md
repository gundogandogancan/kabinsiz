# ADR-012 — Gerçek 3B şehir: RealityKit geometrisi, Blender'da pişmiş ışık, dürüst etiket ve kalite yöneticisi

- **Durum:** Kabul edildi (2026-11-04). ADR-011 Karar 6'yı (D-034, şehir = 2B kadraj) **3B şehir olan şehirler için** değiştirir. 2B kadraj geri düşüş olarak kalır.
- **Kaynak:** v2.8 §01, §06.8–9, H01/H04, UI28-05; v2.7 "Home World 3D Studio", "Gerçekçi kent arka planı", varlık hakları satırı (`.asset-rights.json`).
- **İş paketi:** UI28-05 (B4).

## Bağlam

v2.8 ana sahnenin arkasında "gerçek zamanlı 3D sahne" istiyor ve "düz resim üzerinde sahte animasyon" yasaklıyor. v2.7 de bunu ekliyor: "3D görünüme dair yapay ekran görseli fiziksel scene tamamlandığı anlamına gelmez". v2.8 ilk diliminde şehir, modelin arkasında Blender'da çizilmiş 2B bir görüntüydü ve dürüstçe öyle etiketlenmişti.

Kısıtlar:

- Telefonda Blender çalışmaz.
- Harita ya da fotoğraf verisi kullanılamaz.
- Bulut kullanılmaz.
- Cihaz şu an ölçüme kapalı (`REAL_DEVICE_BLOCKED`).

## Karar 1 — Şehir gerçek geometri, ışık önceden hesaplı

`tools/scenes/build_city_usdz.py` çalışınca:

- 2B kadrajları üreten **aynı özgün sokağı** (`build_city_scene.py`, yalnız primitiflerden) kurar.
- Statik geometriyi beş gruba ayırır: yakın zemin (kameraya 13 m'den yakın kaldırım ve parke), zemin, sol cephe, sağ cephe, uzak. Bunlara bir de gökyüzü kubbesi eklenir. Yakın zemin kendi atlasını alır; parke taşı figürün ayağının dibinde bulanık kalmasın diye.
- Her grubun lightmap atlasını Cycles'ta pişirir: doğrudan ve dolaylı ışık, fenerler, ışıklı pencereler, uygulama kamerasından görülen ıslak yansımalar ve 2B kadrajlardaki hava perspektifi.
- Sonucu tek bir USDZ olarak dışa aktarır (Y yukarı, metre).

Uygulama bu USDZ'yi RealityKit'te `UnlitMaterial` ile çizer (ton eşleme yok, Blender'ın AgX görünümü korunur). Gerçek zamanlı olanlar:

- derinlik ve örtme
- kamera kayması ve paralaks
- figürün ışığı ve gölgesi
- yağmur parçacıkları

Önceden hesaplanan tek şey ışıktır. Islak zemin ayrı bir pişmiş doku setidir ve hava değişince yalnız doku değişir; şehir yeniden yüklenmez.

**Neden pişmiş ışık:** Kamera sabit bir noktaya yakın kalıyor: yalnız ±0.16 m kayma, elle döndürmede ±0.22 m kayma ve FOV ile zoom. Bu durumda pişmiş ışık, telefonda gerçek zamanlı gölge ve fener ışığı hesaplamaktan hem çok daha gerçekçi hem çok daha ucuz. Islak sokak yansımaları gerçek zamanlı yapılsa ekran-uzayı yansıma gerekirdi; iOS RealityKit'te bu yok.

**Doku yoğunluğu:** UV açılmadan önce köşeler kameraya doğru çekilir (`d0 · (d/d0)^0.32`). Böylece kameraya yakın yüzeyler uzaktakilerden çok daha fazla texel alır. Kameranın hiçbir izinli pozdan göremeyeceği yüzler atlasa neredeyse sıfır alan ayırır ve dışa aktarımda silinir.

## Karar 2 — Etiket ekranda gerçekte ne varsa onu söyler

`SceneQualityPolicy.truthLine` iki durumdan birini yazar:

- **3B şehir ekrandayken:** "Temsili 3B giysi · 3B şehir, hazır ışık · beden uyumunu göstermez" (tek satıra sığsın diye kısaltıldı; "Neden bu kombin" sheet'i "ışık önceden hesaplandı" diye açar)
- **2B kadraj ekrandayken** (yüklenirken, geri düşüşte, yüklenemezse): "… · şehir Blender kadrajı · …"

Kurallar:

- "3B şehir" ifadesi asla 2B görüntü için kullanılmaz (UI28-T024).
- "Neden bu kombin" sheet'i sahnenin ne olduğunu ve neden azaltıldığını söyler. Ayrıca bu cihazda ölçülen sahne güncelleme hızını gösterir.

## Karar 3 — Kalite yöneticisi (v2.8 §06.8)

`SceneQualityPolicy.decide` saf bir fonksiyondur ve her dalı birim testlidir:

| Koşul | Sonuç |
|---|---|
| Model yok ya da yüklenemedi | 2B kadraj |
| Isı `critical` ya da sürekli hız < 24/sn | 2B kadraj |
| Isı `serious`, Düşük Güç ya da sürekli hız < 45/sn | Azaltılmış 3B: yağmur ×0.35, kamera kayması kapalı |
| Hareketi Azalt | Kamera kayması ve dokunuş kayması kapalı (yağmur zaten kapalı) |

Hızdan kaynaklanan düşüş, o şehirdeki oturum boyunca kilitli kalır; sahne gidip gelmez.

## Karar 4 — Haklar

Her şehir bir `city-<şehir>.asset-rights.json` dosyasıyla gelir. Kuru ve ıslak doku setlerinin her biri altı JPEG'dir (yakın zemin, zemin, sol, sağ, uzak, gök). İçeriği v2.7'deki alanlardır:

- `OWNED_ORIGINAL`
- `third_party_inputs: []`
- üretici komut
- Blender sürümü
- üçgen sayısı
- texel yoğunluğu
- `artifact_hash` (SHA-256)

Test, dosyaların bu özetlerle aynı kaldığını doğrular (UI28-T021). Bağımsız gözden geçiren alanı boştur (`reviewer: null`); bu bir insan onayı bekler.

## Sonuçlar ve açık kalanlar

- Cihazda FPS, ısı, bellek ve yükleme süresi **ölçülmedi** (`REAL_DEVICE_BLOCKED`). Simülatördeki hız Mac GPU'sunun hızıdır, cihaz kanıtı değildir.
- Işık önceden hesaplı olduğu için günün saati değişmez. İstanbul akşam, Barcelona ikindi ışığında kalır. Bu, saatin kendisi hakkında bir iddia değildir; v2.5'teki `renderedLight` alanında da öyleydi.
- Gölgeler ve fener ışığı figürün kendisine düşmez. Figür, eşleştirilmiş yönlü ışıklarla aydınlanmaya devam eder.
- Son kalite derlemesi (2026-11-04, `--atlas 2048 --samples 192`, Apple M5 Metal):

  | Şehir | Üçgen | USDZ | Yakın zemin 0–4 m | Cephe 8–12 m | Uzak 40–44 m |
  |---|---|---|---|---|---|
  | İstanbul | 16.204 | 2,3 MB | 184 texel/m (~5 mm) | 66–84 texel/m | 11 texel/m |
  | Barcelona | 56.667 | 3,2 MB | 170 texel/m (~6 mm) | 23–25 texel/m (~4 cm) | 11 texel/m |

  Kuru/ıslak eşleşmesiz yüz: iki şehirde de 0. Toplam paket ~12 MB (iki şehir, 24 JPEG + 2 USDZ).
- **Barcelona cepheleri zayıf:** Barcelona'nın geometrisi İstanbul'un 3,5 katı (balkonlar, korkuluklar). Aynı 2048 atlasa sığınca cephe texel yoğunluğu İstanbul'un üçte biri. Telefonda yakından ince işçilik yumuşak görünebilir. Çözüm seçenekleri: cepheyi iki atlasa bölmek (bellek ×2) ya da tekrarlanan balkonları instancing ile çizmek. İkisi de cihazda bellek ölçümü ister (`REAL_DEVICE_BLOCKED`).
- Daha fazla ayrıntı için ileride CustomMaterial ve ikinci UV seti (tekrarlanan malzeme dokusu × lightmap) gerekir; o yol da cihazda ölçüm ister.

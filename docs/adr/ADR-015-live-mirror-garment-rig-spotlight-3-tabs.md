# ADR-015 — Canlı Ayna giysi iskeleti, ürün detayı, ana sahne spot ışığı ve 3 sekme

- **Durum:** Kabul edildi (2026-11-04).
  - D-030'un 4 sekmeli düzeninin yerini alır: "Ben" artık sekme değil.
  - D-028'in "T1 temsilî çizim" kısmını somutlaştırır.
- **Kaynak:** Kullanıcı isteği (2026-11-04), özetle:
  - Kişi canlı olarak aynaya bakıyor gibi olmalı.
  - Taradığı ya da fotoğrafını çektiği ürün tanınmalı ve üstündeymiş gibi görünmeli.
  - Ürünün beden ve diğer bilgileri gösterilmeli.
  - Bugünün kombininde yukarıdan bir spot ışığı olmalı, ama lambanın kendisi görünmemeli.
  - 12 ekranlık tasarım referansı.
- **Bağlayıcı kurallar:**
  - v3.2 anayasası: V32-UI-01 (3 sekme), V32-UI-10 (kamerasız aynada sahte önizleme yok), V32-WEB-02 (marka sitesi kazınmaz), V32-MIR-* (yerel ayna, iki kişide giysi yok).
  - `CLAUDE_SCREEN_DESIGN_HANDOFF.md`: mockup yalnız görsel hedeftir; 4. sekme kaldırılır.
- **İş paketleri:** MIR-WP02, SCAN-WP02, UI32-SLICE.

## Karar 1 — Canlı Ayna: kamera + cihazda poz + parça parça giysi çizimi

**Akış:**

1. Ön kameranın BGRA karesi alınır.
2. Apple Vision `VNDetectHumanBodyPoseRequest` 14 eklemi bulur.
3. `GarmentRig` her giysi parçasını kendi kemiğine oturtur:
   - Gövde: omuz ortası → kalça ortası.
   - Üst kol, ön kol.
   - Kalça bölgesi, uyluk, baldır.
   - Ayakkabı: bilekte.
4. Her parça bir afin dönüşümle yerleşir:
   - Uzunluk: kemik uzunluğu.
   - Gövde genişliği: omuz genişliği.
   - Kol ve bacak kalınlığı: vücut ölçeği.

**Giysi çizimleri:**

- Blender'da yordamsal olarak üretilir (`tools/garments/build_garment_sprites.py`). Kaynak etiketi OWNED_ORIGINAL; manifest başka bir kaynak etiketini reddeder (MIR-T08).
- Kumaş katmanı nötr renklidir ve ekranda ürün rengiyle çarpılır.
- Düğme, taban ve dikiş katmanı boyanmaz.
- Üst kol başı yuvarlak bir kubbedir, böylece omuz düz kesik bir tüp gibi görünmez.

**Kapılar:**

- `MirrorTracking`:
  - kişi yok,
  - iki ya da daha fazla kişi (giysi çizilmez),
  - eksik eklem (o giysi çizilmez),
  - izleniyor.
- `FrameGate`: 0,25 sn'den eski ya da sırası bozuk kare gösterilmez.
- `OneEuroFilter`: titreşimi yumuşatır.
- `FrameLight`: odanın ışığına göre parlaklığı 0,62 ile 1,08 arasında tutar.

**Gizlilik:**

- Kare saklanmaz ve gönderilmez.
- Fotoğraf yalnız deklanşöre basılınca oluşur ve yalnız paylaşılırsa iPhone'dan çıkar.
- Kamera arka planda çalışmaz.

**Doğruluk etiketi** ekranda sürekli görünür: "Temsilî çizim, kişinin duruşunu izler · kumaş benzetimi değildir · beden uyumunu göstermez".

**Simülatör:**

- Kamera yoktur. DEBUG `-mirrorFixture` kendi çizdiğimiz salınan bir mankeni gösterir.
- `VNDetectHumanBodyPoseRequest` simülatörde kurulamıyor ("Unable to setup request", ölçüldü).
- Bu yüzden mankenin pozu macOS Vision ile aynı görüntüden önceden okunur (`tools/garments/fixture_pose.swift` → `MirrorFixturePose.json`) ve aynı salınım dönüşümüyle hareket ettirilir.
- Ekran bunu söyler: "Simülatör örneği: kamera değil, çizilmiş bir figür · poz önceden okundu".
- Gerçek kamerada Vision'ın canlı çalışması REAL_DEVICE_BLOCKED.

## Karar 2 — Ürün bilgisi: kaynağıyla, kazımadan

**Ürün Detayı ekranı:**

- Büyük temsilî çizim.
- Marka ve ad, renk.
- "Üzerimde Dene" ve "Modelimde 360° gör" düğmeleri.
- Beden tablosu:
  - Yalnız kataloğun kendi tablosu ve kaynak etiketi gösterilir.
  - Vücut ölçüsü ile giysinin bitmiş ölçüsü ayrımı açıkça yazar.
- Kumaş iddiaları: yalnız katalogdan.
- Ürün kimliği:
  - Kod, model, katalog sürümü, GTIN.
  - GS1 öneki: firmanın kayıtlı olduğu GS1 üye kuruluşu. Bu üretim yeri değildir ve ekranda böyle yazar.

**Marka sitesi okunmaz** (V32-WEB-02):

- `BrandSourceGate.licensedHosts` boştur. Lisanslı ortak beslemesi gelene kadar her alan adı `notLicensed` döner.
- file, http, localhost ve IP adresleri reddedilir.

**Kullanıcının kendi araması:**

- "Kodu web'de ara" Safari'de açılır ve aramaya yalnız kod gider.
- Kod kuralları: 6–20 karakter, harf/rakam/tire, en az bir rakam. Uymayan kod temizlenmez, reddedilir.
- Kabinsiz o sayfayı okumaz.
- Gizlilik korumasındaki `openURL` yasağına tek ve gerekçeli istisna budur. Test, tek bir çağrı olduğunu ve URL'nin kapıdan geldiğini doğrular.

**Fiyat ve mağaza bağlantısı uydurulmaz:** "Mağazada Gör" düğmesi kapalıdır ve nedenini söyler.

## Karar 3 — Ana sahne: görünmeyen spot ışığı

**Bugün sahnesindeki ışık:**

- Gerçek bir RealityKit `SpotLight` (gölgeli), figürün 4,6 m üstünde.
- Yerde sıcak bir ışık havuzu.
- Figürün arkasında yumuşak, Gauss dağılımlı bir ışık perdesi: üstü tamamen saydam, aşağı doğru en fazla 0,16 opaklığa çıkar.
- Lamba ve koni hiçbir yerde çizilmez.
- Kenarlar SwiftUI radyal vinyetle kararır.

**Denendi ve reddedildi:** Görünür ışık konisi plastik görünüyordu ve figürü soldurdu.

## Karar 4 — 3 sekme, profil sağ üstte

**Sekmeler:**

- Sekmeler `Bugün · Dolabım · Dene`.
- "Benim Modelim" her sekmenin sağ üstündeki profil düğmesinden tam ekran açılır.
- Sheet değil tam ekran kullanılır: aşağı kaydırma hareketi 3B gövde döndürme ve kaydırıcılarla çakışıyordu.
- Ana ekrandaki "Dene" düğmesi kalktı. Tek güçlü eylem "Yeni kombin"; yanında yuvarlak "i" düğmesi "Neden bu kombin"i açar.

**Ekran ayrıntıları:**

- Kombin önerileri sayfasının üstünde kart karuseli:
  - Her kartta parça çizimleri, motorun ilk gerçek gerekçesi ve "Uygula" düğmesi.
- Değiştirme sayfasındaki karolar renkli kutu değil, giysi çizimidir.
- Dolabım: çizimli ızgara ve kategori çipleri.
- Benim Modelim: Beden · Ölçüler · Yüz · Saç çubuğu.
  - Yüz ve Saç "bu sürümde yok" der.
  - Yüz fotoğrafı alınmaz ve gönderilmez.

## Sonuçlar

**Kazanımlar:**

- Ayna ürün değişince yerinde güncellenir.
- Giysi kişinin kolunu kaldırmasını izler (MIR-T02).

**Kalan:**

- Giysi çizimleri kategori kalıbıdır, ürüne özel değildir (T1). Ürüne özel varlık lisanslı katalog ister (R-004).
- Kumaş benzetimi yok.
- Yan dönüşte (profil) giysi düz kalır.
- Cihaz FPS, ısı ve gecikme ölçümleri REAL_DEVICE_BLOCKED (B1).

## Blender MCP

**Kurulum:**

- `ahujasid/blender-mcp` (MIT) incelendi ve sabitlendi: commit `992233b`, sürüm 2.2.6.
- Kaynak: `~/.local/share/blender-mcp/src-992233b`.
- venv, Blender'ın Python 3.13'üyle kuruldu.
- Claude Code kullanıcı kapsamında `blender` adıyla kayıtlı. `BLENDER_MCP_DISABLE_TELEMETRY=true` ve `DISABLE_TELEMETRY=true` ile çalışıyor.
- Blender eklentisi etkin; telemetri onayı kapalı (varsayılan).

**Riskler:**

- Eklentinin soketi yalnız localhost:9876'da dinler, ama gelen Python kodunu Blender içinde çalıştırır. Yerel her süreç bağlanabilir; sunucu yalnız kullanılırken başlatılmalıdır.
- Dış model sağlayıcıları (Sketchfab, Hyper3D, Tripo, Meshy, fal, Poly Haven) kullanılmaz: varlıklarımız OWNED_ORIGINAL kalmalı.
- Eklentinin kendini güncelleme kontrolü GitHub'a gider. Kurulum yalnız tıklamayla olur; `BLENDERMCP_NO_UPDATE_CHECK=1` bu kontrolü kapatır.

**Kullanım:**

- Yeni bir oturumda etkin olur.
- Blender arayüzünde N panel → BlenderMCP → bağlan.
- Headless üretim hattı (`tools/garments`, şehir) MCP olmadan da çalışır.

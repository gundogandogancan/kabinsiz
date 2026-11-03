# KABİNSİZ — LIVE MIRROR / QUIET ATELIER
## Ultra Detaylı Ekran Atlası · Claude Code Uygulama Sözleşmesi v2.4

**Durum:** TASARIM / GÖRSEL ŞEMA — ÇALIŞAN ÜRÜN KANITI DEĞİL  
**Bağlayıcı:** KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.4.md  
**Platform:** iOS 18+, SwiftUI + AVFoundation + Vision + RealityKit/Metal; bulut VTON yalnız opsiyonel  
**Dil:** Türkçe; yerelleştirilebilir metin dizeleri  
**Referans estetik:** QUIET ATELIER, sıcak fildişi / ceviz / espresso / taş ve kontrollü zeytin; modaya ait, unisex, seçkin, doğal ve sıcak.

> **Kesin ayrım:** Buradaki şemalar gerçek SwiftUI screenshot'ı veya çalışan kamera görüntüsü değildir. Claude her ekranın farklı cihaz boyutlarında gerçek ekran görüntülerini `docs/evidence/ui` altında üretecek; gerekli işlevleri kanıtlamadan tamamlanmış ilan etmeyecek.

## A. Deneyim manifestosu

Live Mirror; galeriden ürün seçme → kamera izni → aynaya geçiş → yerel hareketli 3D bindirme → ihtiyaç varsa açık izinli generatif prova → kıyafet/beden/kombin kararı yolculuğudur. **Ayna önce güvenilir davranmalı, sonra güzel görünmelidir.** Generatif video “kıyafet kesin uyuyor” demek değildir; modelin tanıyamadığı bölgeler ve logo/desen kaymaları anlaşılır görünmelidir.

### Hiyerarşi

1. **Canlı kişinin kendisi**: ekran alanının yaklaşık %65–75'i kamera/ayna sahnesi; gereksiz UI kadrajı kapatmaz.
2. **Seçili ürün**: kompakt ürün çipi, doğrulanmış marka/model/renk; yoksa “ürün doğrulanamadı”.
3. **Tek ana aksiyon**: “Kıyafeti dene” veya “Ürünü değiştir”; ikincil “Beden ve kumaş” bilgi sheet'i.
4. **Kısıt bilgisi**: her modda “3D önizleme” / “AI video önizleme”; gerçek uygunluk kanıtı değil.
5. **Kontrol**: kamera durdur, izinleri geri al, modu değiştir, kaydetme seçimi.

### UI token'ları (kanonik v2.2 paletiyle eşleştir)

| Token | Önerilen değer | Kullanım |
|---|---|---|
| `surface.canvas` | `#F8F6F1` | Kamera harici sayfa arka planı |
| `surface.raised` | `#FFFCF8` | Kart, alt sheet |
| `surface.sand` | `#E8DED1` | Kontrollü ikincil yüzey |
| `ink.primary` | `#26221E` | Ana metin |
| `ink.muted` | `#625B54` | Açıklama |
| `accent.walnut` | `#654632` | Birincil eylem |
| `accent.olive` | `#62684B` | Düşük dikkatli durum vurgusu |
| `stroke.soft` | `#D9D0C4` | İnce çizgi |
| `mirror.scrim` | dinamik siyah saydam gradient | Kamera üstündeki beyaz metnin kontrastı |

Sistem `Dynamic Type`, VoiceOver, Reduce Motion, karanlık mod, Safe Area ve kontrast gereksinimlerini korur. Kamera üstünde açık/koyu arka plana bağlı kaybolan ikonlar yasaktır. Giriş düğmeleri erişilebilir dokunma alanı en az 44×44 pt. Serif sadece büyük editoryal başlıklarda, gövde ve kontrol metinleri sistem sans ile.

---

## LM-01 — Live Mirror giriş / cihaz içi varsayılan

**İş:** Kullanıcı iki modu anlar, mahremiyet sözünü görür; başlangıçta kamera çalışmaz. **Birincil CTA:** `Yerel Aynayı Aç`. **İkincil:** `Nasıl çalışır?`.

| Sol: amaç ve koşullar | Sağ: şematik ekran |
|---|---|
| Modlar fiyat ve mahremiyet açısından ayrıdır. Bulut modu varsayılan seçili değildir. Kullanıcı cihaz içi modu kullanmak için hesap açmak zorunda kalmaz. Kamera izni, kullanıcı bu deneyimi başlattığında istenir. | <pre>┌──────────────────────────┐<br>│ ‹         Kabinsiz       │<br>│                          │<br>│        Live Mirror       │<br>│     Üzerinde keşfet.     │<br>│                          │<br>│  [ yerel ayna / kıyafet ]│<br>│                          │<br>│  ● Yerel Ayna            │<br>│    Görüntü cihazında     │<br>│    işlenir               │<br>│                          │<br>│  ○ AI Video Önizleme     │<br>│    Açık izin gerektirir  │<br>│                          │<br>│ [ Yerel Aynayı Aç     → ]│<br>│ Mahremiyet ve sınırlar  │<br>└──────────────────────────┘</pre> |

**Durumlar:** ilk açılış, kamera reddedildi, aygıt desteklenmiyor, avatar henüz yok. Reddedilince sistem kamera sahnesi taklit etmez; uygulama ayarlarına yönlendirme ve yalnız avatar önizleme alternatifi sunar.

## LM-02 — Ürün seçim paneli

**İş:** Kullanıcı mağaza barkodu, ürün fotoğrafı, ürün linki, dolabındaki parça veya katalog üzerinden denenecek ürünü getirir. 

```text
┌──────────────────────────────────┐
│ ‹            Ürün seç            │
│ Arat / barkod / link yapıştır    │
│                                  │
│ [ Kamera ile tara ]              │
│ [ Ürün bağlantısını ekle ]       │
│ [ Dolabımdan seç ]               │
│                                  │
│ Son görüntülenenler              │
│ [gerçek varlık] [doğrulanmadı]   │
│                                  │
│ Veri var: renk, varyant, beden   │
│ Veri yok: ürünün bitmiş ölçüsü   │
│          [ Bu ürünü seç ]        │
└──────────────────────────────────┘
```

**Şart:** Ürün linki ile gelen görselin yetkili kullanım hakkı ayrı denetlenir. Ürün bulunmazsa yanlış eşleşme yerine `bulunamadı`, birden çok varyant varsa seçim ekranı. Seçilen ürün görselinden lif yüzdesi veya kesin beden çıkarılmaz.

## LM-03 — İlk kamera açılışı ve kalibrasyon

**İş:** Işık, kadraj, mesafe ve tek kişi takibi. Kamera açılmadan hiçbir kare kaydedilmez veya dışarı çıkmaz.

```text
┌──────────────────────────────────┐
│ ✕      Yerel Ayna        ?       │
│                                  │
│      ┌──────────────────┐        │
│      │                  │        │
│      │   [CANLI KAMERA] │        │
│      │  İnsan kadrajı   │        │
│      │  Aydınlık yeterli│        │
│      │                  │        │
│      └──────────────────┘        │
│                                  │
│  Bir adım geri: tam boy görün.   │
│ [ Kalibrasyonu Tamamla ]         │
│ [ Kamera olmadan 3D modele geç ] │
└──────────────────────────────────┘
```

**Durumlar:** çoklu kişi, yüz/kafa dışında kadraj, çok karanlık, kesilen kamera, aşırı hareket, cihaz ısısı artışı. Bunlar makul yardım metni doğurur; görüntüden hassas kişisel kimlik çıkarılmaz.

## LM-04 — Canlı Yerel Ayna / ana deneyim

**İş:** Gerçek kamera üstüne desteklenen giysi/aksesuar 3D bindirmesi. **Bu, fiziksel kumaş simülasyonu veya fotogerçekçi video iddiası değildir.**

```text
┌──────────────────────────────────┐
│ ×   Yerel Ayna      ● CİHAZDA    │
│                                  │
│       [ CANLI KAMERA ]           │
│       [KULLANICI + GIYSI]        │
│                                  │
│      [parçayı seç → dokun]       │
│                                  │
│ [ÜST] [ALT] [AYAKKABI] [ÇANTA]    │
│                                  │
│ Ürün: Doğrulanmış / yaklaşık     │
│ [ Ürünü Değiştir ]   [360° Model]│
│                                  │
│  Bilgi: Görünüm önizlemesidir.   │
│  [Beden ve Kumaş] [Kombinle]     │
└──────────────────────────────────┘
```

**Kontroller:** kamera durdur/döndür, ürün değiştir, ilgili parçayı seç, 360° avatar moduna git, fit sheet, stilist sheet. Canlı kamera modunda çevresel arka plan gerçektir; sanal İstanbul arka planı kamera görüntüsünün gerçek konumu olarak sunulmaz. Görünüm düşük kalitede ise güvenli 3D avatar veya 2D ürüne geri düşer.

## LM-05 — AI Video önizlemeye geçiş / onay

**İş:** Bulut VTON varsa kullanıcının açık, ayrı oturum izniyle aktive edilir. Devam etmeden tahmini süre/maliyet sınırı, veri akışı, üçüncü taraf sağlayıcı, saklama ve silme koşulları net gösterilir.

```text
┌──────────────────────────────────┐
│        AI Video Önizleme         │
│                                  │
│ Görüntü bu oturumda sağlayıcıya  │
│ gönderilir; tamamen cihaz içi    │
│ değildir.                        │
│                                  │
│ [ ] Canlı video gönderimine onay │
│ [ ] Hizmet koşulları ve saklama  │
│     bilgisini okudum             │
│                                  │
│ Oturum sınırı: [ör. 15 sn]       │
│ Kayıt: varsayılan kapalı         │
│                                  │
│ [ İzin Ver ve Başlat ]           │
│ [ Yerel Ayna ile Devam ]         │
└──────────────────────────────────┘
```

**Şart:** Rıza alınmadan token, video/ölçü/fotoğraf veya kimlik verisi sağlayıcıya gönderilmez. Fiyatlar yalnız güncel ve doğrulanmış sağlayıcı koşullarıyla gösterilir. Oturum izin iptalinde hemen kesilir. Sağlayıcı modeli lisans/ToS denetimine tabidir.

## LM-06 — AI Mirror aktif oturum

**İş:** Render edilen canlı video önizlemesi; gecikme, kalite, veri aktarımı ve oturum durumu açıkça görülür. Sonuç “fotogerçekçi” olsa bile kumaşın fiziksel oturuşu kanıtlanmış sayılmaz.

```text
┌──────────────────────────────────┐
│ ✕   AI Ayna        ● BULUTTA     │
│                                  │
│ [CANLI GÖRÜNTÜ + AI GIYSI]       │
│                                  │
│   Gecikme / kalite göstergesi    │
│                                  │
│ [Ürünü Değiştir] [Durdur]        │
│                                  │
│      Ürün önizleme modunda       │
│      Logo/doku farklı olabilir.  │
│ [ Beden Tavsiyesi ve Kaynak ]    │
└──────────────────────────────────┘
```

**Durumlar:** bağlanıyor, aktif, kalite azaldı, bant genişliği düşük, servis kapandı, kullanıcı iptal etti, süre bitti, termal tehlike. Her biri net çıkış/geri dönüş sağlar. Başarı yalnız kamera akışı gelmesi değil; hareket tutarlılığı / tekstil kimliği / gecikme / izin iptali ile ölçülür.

## LM-07 — 360° Avatar Stüdyosu ve parça değişimi

**İş:** Live Mirror’dan tek dokunuşla kullanıcının kişisel modele geçilir. 360° döndürme, zoom, ön/yan/arka, tek parça değiştirme, geri al/yinele bulunur.

```text
┌──────────────────────────────────┐
│ ‹  360° Modelim     Ön Yan Arka  │
│                                  │
│      [KİŞİNİN 3D AVATARI]        │
│      [SEÇİLİ KIYAFET]            │
│        ↺ parmakla döndür ↻       │
│                                  │
│  [Üst] [Alt] [Ayakkabı] [Çanta]  │
│  [Kemer] [Aksesuar]              │
│ ┌──────────────────────────────┐ │
│ │ Dolabımdan   |   Mağazadan   │ │
│ │ [Parça] [Parça] [Parça]      │ │
│ └──────────────────────────────┘ │
│ [Kombini Kaydet] [Yeni Üret]     │
└──────────────────────────────────┘
```

**Güvenlik:** Modelin kullanıcı ölçülerinden üretildiği seviye açık; giysi gerçek fiziksel ölçüsü yoksa `genel görsel örnek` etiketi. Bütün açıların görüntülenmesi “gerçek beden uyumu doğrulandı” anlamına gelmez.

## LM-08 — Ürün gerçekliği, fit açıklaması ve kıyaslama

**İş:** Sahnedeki sonucu “neden böyle gösteriyoruz?” sorusuna bağlamak.

```text
┌──────────────────────────────────┐
│ Ürün ve Beden Gerçekliği         │
│                                  │
│ Ürün       Kaynaklı / Yaklaşık   │
│ Kumaş      % veya Veri yok       │
│ Beden      Bölgesel öneri        │
│ Omuz       Dar olabilir          │
│ Bel        Veri eksik            │
│ Kalça      Girdi eksik           │
│                                  │
│ [Marka tablosunu aç]             │
│ [Kabin denemesini öner]          │
│ [Dolabımdan alternatif bul]      │
└──────────────────────────────────┘
```

**Şart:** `size chart` ile bitmiş giysi ölçüsü ayrı veri. Kaynak/ürün varyantı izlenebilir. Onaylanmamış beden uygunluğu için yüzde yüzdelik güven skorları uydurulmaz.

## LM-09 — Mahremiyet ve kayıt / oturum sonu

**İş:** Kullanıcı isterse görüntüyü açık bir düğmeyle kaydeder; varsayılan otomatik kayıt ve telemetri kamera verisi yoktur. İptalde oturum temizliği doğrulanır. Paylaşım varsa görünür onay ve kırpılmış/anonim seçim.

---

## B. Bileşen ve etkileşim sözleşmesi

| Component | Özellik | Özelleştirme | Test |
|---|---|---|---|
| `MirrorStageView` | Kamera+yerel/AI render tek yüzey | 2D/3D fallback | UI / perf |
| `MirrorModeIndicator` | `CİHAZDA` veya `BULUTTA` | ikon+metin | a11y |
| `ProductIdentityPill` | Ürün kaynağı ve varyant | bilinmiyor durumu | truth |
| `GarmentHotspotLayer` | Parça seçimi | hit-test, VoiceOver | UI |
| `GarmentSwapDrawer` | Owned / partner ayrımı | sponsor işareti | business fairness |
| `ConfidenceDisclosureSheet` | kesin, tahmin, bilinmiyor | kaynaklar | truth |
| `MirrorConsentSheet` | ayrı canlı video izni | iptal / yasal metin | security |
| `MirrorSessionTimer` | kaynak / maliyet sınırlayıcı | manual stop | perf / finance |
| `CameraFallbackCard` | ret/yok/uyumsuz | avatar alternatif | accessibility |

## C. Kamera + avatar durum makinesi

`IDLE → PRODUCT_SELECTED → CONSENT_CHECK → CAMERA_READY → CALIBRATING → LOCAL_ACTIVE → LOCAL_PAUSED → STOPPED`

Opsiyonel bulut kolu:

`LOCAL_ACTIVE → CLOUD_CONSENT → CONNECTING → CLOUD_ACTIVE → CLOUD_DEGRADED → STOPPED`; iptal anında `STOPPING → CLEANUP → STOPPED`. Her durum yasal geçişlerle korunur; “hazır kamera” UI'sında gerçekte kamera açık değilse sonuç üretilmez.

## D. Kabul testleri / gerçek cihaz kapısı

| ID | Senaryo | Beklenen |
|---|---|---|
| LM-UI-01 | Kamera izni verilmemiş | Sessiz erişim yok; açıklama ve seçenek |
| LM-UI-02 | Kamera izni reddedilmiş | Uygulama çökmüyor; avatar fallback |
| LM-UI-03 | Yerel modda çevrimdışı | Kamera/3D önizleme desteklendiği ölçüde çalışır |
| LM-UI-04 | Bulut moduna rızasız geçme | Ağ çıkışı engellenir |
| LM-UI-05 | Bulut rızası geri çekme | Oturum/akış durur; temizlik kaydı |
| LM-UI-06 | Ürün görseli ile varyant tutarsız | Kesin ürün kimliği/fit gösterilmez |
| LM-UI-07 | Çoklu kişi kadraj | Yanlış kişiye giydirme yapılmaz; yeniden kalibrasyon |
| LM-UI-08 | Hızlı dönüş / kolları kaldırma | Bindirme tutarlılığı ölçülür; koparsa fallback |
| LM-UI-09 | Kötü ışık / kısmi beden | Kalite durumu görünür; uydurma sonuç yok |
| LM-UI-10 | 360° ön/yan/arka | Görünüm ve materyal tutarlılığı korunur |
| LM-UI-11 | Üst/alt swap | Yalnız ilgili parça güncellenir; geri alma çalışır |
| LM-UI-12 | Düşük güç/termal ciddi | Güvenli kalite düşümü + açık bilgi |
| LM-UI-13 | Bulut servis çevrimdışı | Yerel mod alternatifi sunulur |
| LM-UI-14 | Kısa oturum bitti | Akış kapanır; otomatik tekrar ücretlendirme yok |
| LM-UI-15 | Save kapalı | İşlenmiş akış galeriye kaydedilmez |
| LM-UI-16 | Logo değişiyor / doku kayıyor | Özellik doğrulanmış gibi sunulmaz |
| LM-UI-17 | VoiceOver | Kamera kontrolleri ve izin anlaşılır |
| LM-UI-18 | Dynamic Type / küçük ekran | Düğmeler erişilebilir ve görsel taşma yok |
| LM-UI-19 | Gerçek iPhone fps/latency | p50/p95 cihaz/model/süre/ısıl durumla raporlanır; hedefe erişilmezse FAIL/DEGRADED |
| LM-UI-20 | Kapat–yeniden aç | Kamera sesizce yeniden başlamaz |

**Hüküm:** Simülatör ekran görüntüsü, kamera hareket tutarlılığını veya gerçek iPhone GPU/ısı davranışını kanıtlamaz. Kullanıcının istediği “gerçek gibi canlı prova” kalite iddiası ölçülmeden verilmez.

## E. Claude uygulama emri

1. Mevcut `Kabinsiz` iOS UI ve LiveMirror sözleşmelerini repo SHA ile eşleştir; uygulanmış/eksik ayrımı yap.
2. Bu atlası `docs/design/LIVE_MIRROR_SCREEN_ATLAS.md` içine al; mevcut tasarım token'larına bağla.
3. Önce LM-01/02/03/04 **yerel mod**; sonra 07/08 360+fit; en son LM-05/06 bulut ve LM-09 paylaşım.
4. Her ekranı gerçek SwiftUI implementasyonu, unit/UI test, gerçek simülatör screenshot, VoiceOver/ReduceMotion kontrolü ve cihaz performans kanıtıyla geçir.
5. Tek prompta bütün özellikleri “yapıldı” demek yasak; teslimat durumları `SPEC_ONLY`, `CODED`, `TESTED`, `SIMULATOR_ONLY`, `DEVICE_VERIFIED`, `BLOCKED_EXTERNAL`, `LIVE_PARTNER` olarak raporlanır.

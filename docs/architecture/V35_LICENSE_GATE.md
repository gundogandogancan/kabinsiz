# V35 Lisans Kapısı (Licence Gate)

Bir dış model, veri ya da servis koda veya pakete girmeden önce bu tablodan geçer. Tablodaki durumlar:

- **SHIP_OK:** Yapıya girebilir. Atıf ve lisans metni gereklidir.
- **RESEARCH_ONLY:** Yalnız Mac'te, deney için kullanılır. Hiçbir yapıya girmez.
- **BLOCKED:** Hiçbir biçimde kullanılmaz.
- **BLOCKED_EXTERNAL:** İnsan onayı, sözleşme ya da hesap gerektirir.

Tarih: 2026-11-04. Hukuki görüş değildir. Ticari yayından önce `support-legal-compliance-checker` incelemesi ve bir avukat gerekir.

| Bileşen | Lisans / koşul | Kullanım amacı | Durum | Not |
|---|---|---|---|---|
| FASHN VTON 1.5 kodu ve ağırlıkları | Apache-2.0 | L1 çevrim dışı tek kare üretici (ADR-017) | RESEARCH_ONLY | 2026-11-04 kullanıcı izniyle indirildi, SHA-256 doğrulandı, repoda değil (`~/research`). PoC: `docs/research/fashn-poc/`. Model kartı ve Apache NOTICE gerekir. Eğitim verisinin hakları belirsiz, ticari yayından önce incelenmeli |
| FASHN insan ayrıştırıcısı | NVIDIA Source Code License, ticari değil | — | **BLOCKED** | Yerine Apple Vision kişi maskesi kullanılır. FASHN `segmentation_free` modu ve düz serili ürün fotoğrafı ayrıştırıcı gerektirmez |
| DWPose / YOLOX (FASHN poz girişi) | Apache-2.0 | L1 poz | RESEARCH_ONLY | Cihazda Apple Vision eklemleri kullanılır |
| Mobile-VTON, CatVTON | CC BY-NC-SA / ticari değil | Kıyas | RESEARCH_ONLY | Ağırlık ya da çıktı gönderilmez |
| SAM 3 | SAM License (telifsiz, sınırlı; Agreement kopyası gerekir; askerî kullanım vb. yasak; ağırlıklar erişim isteğiyle) | Fotoğraftan kesip çıkarma | RESEARCH_ONLY | CUDA ve 848M parametre ister. Cihazda Apple Vision ön plan maskesi kullanılır. Lisans "ticari" kelimesini açıkça içermiyor, hukuk incelemesi gerekir |
| SMPL / SMPL-X | Ticari değil | — | **BLOCKED** | Kendi parametrik gövdemiz kullanılır (`BodyGeometry`) |
| Decart / Anywear (Lucy V-TON) | Kapalı servis | — | **BLOCKED_EXTERNAL** | Hesap, şartname kabulü, kota aşımı ya da model çıkarma girişimi yok. Bulut VTON varsayılan olarak KAPALI |
| Doji, Alta, Google try-on | Kapalı ürünler | Yalnız herkese açık özellik incelemesi | Yöntem: `kabinsiz-rival-recon` | Decompile, ağ trafiği kaydı, özel API ve giriş arkası kazıma yok |
| replica-skill (Jakeschincariol) | MIT | Rakip keşif yöntemi | USE_METHOD_ONLY | Kendi skill'imizde MIT atfıyla. Paket kurulmadı |
| OpenStreetMap verisi | ODbL 1.0 | B katmanı şehir (OSM2World) | SHIP_OK, koşullu | Ekranda "© OpenStreetMap katkıda bulunanlar" atfı. Türetilmiş veritabanı paylaşılırsa ODbL share-alike uygulanır. Üretilen görüntü "Produced Work" sayılır |
| OSM2World | LGPL-3.0 (araç) | Yalnız Mac'te üretim aracı | SHIP_OK (araç pakete girmez) | Çıktı varlık olarak paketlenir, araç uygulamada yoktur |
| Apple Look Around | Apple MapKit koşulları | Cadde fotoğrafı arka planı | SHIP_OK (yalnız canlı gösterim) | Görüntü saklanmaz ya da kaydedilmez. "Apple" atfı gösterilir (ADR-013) |
| Apple CLGeocoder | Apple koşulları | Şehir adı (ters kodlama) | SHIP_OK | Apple'a bir ağ isteği gider. Konum izni metninde açıkça yazılır. Yalnız ad, ülke ve saat dilimi saklanır |
| Google Photorealistic 3D Tiles | Google Maps Platform koşulları (önbellek ve türetim kısıtları) | — | **BLOCKED_EXTERNAL** | Ücretli hesap ve şartname gerekir. Yakalanıp saklanamaz |
| Hunyuan3D 2.x | Tencent Hunyuan Community License (AB, BK ve Güney Kore'de geçersiz; büyük kullanıcı eşiği var) | 3B giysi üretimi | **BLOCKED** | Bölge kısıtı ürün pazarımızla çakışıyor |
| WeatherKit | Apple Developer PLA | Hava gözlemi | BLOCKED_EXTERNAL (R-003) | Kod hazır, hesap sahibi PLA'yı kabul etmeli |
| Blender (araç) | GPL (araç) | Varlık üretimi | SHIP_OK (yalnız çıktı) | Üretilen varlıklar OWNED_ORIGINAL |

## Kapı kuralı (kod)

`LivingWorld.AssetProvenance` yalnız `OWNED_ORIGINAL`, `LICENSED` ve `USER_SUPPLIED` değerlerini kabul eder. B katmanı bir şehir paketlenirse:

- `CitySceneResolver.bundledProcedural` listesine eklenir;
- ODbL atfı `CitySceneDecision.attribution` ile ekrana gelir (CITY-T05).

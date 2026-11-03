# ADR-008 — Canlı Ayna: iki motor, tek doğruluk motoru; bulut kapalı

- Durum: KABUL (yerel kısım) · BLOCKED_EXTERNAL (bulut kısım) · 2026-11-03 · LM21-01, LM21-07, LM21-10, LM21-WP02 · C-9, C-13

## Karar

1. **Local Live Mirror varsayılan ve tek açık mod.** Ön kamera, ayna çevirme, Vision kişi maskesi + poz, yerel 3D giysi asset'i varsa RealityKit ile oturtma. Bu modda dışarı 0 görüntü paketi (LM21-07.1).
2. **AI Live Mirror (Bulut)** — örn. Decart Lucy VTON — **feature flag OFF, yalnız stub.** Açılması için hepsi gerekir: kullanıcı/ürün sahibi kararı, sağlayıcı sözleşmesi + DPA (saklama, eğitimde kullanım, alt işleyiciler, ülke sınırı, silme), Türkiye merkezli hukuk incelemesi (KVKK/GDPR, yurt dışı aktarım), maliyet sınırı, gerçek iPhone testi. v1.5 §5.3 ("kullanıcı görselini buluta yükleme") ve "daha zayıf yeni kural eski güvenlik kontrolünü geçersiz kılamaz" bunu zorunlu kılar.
3. `CitadelGate`'te `liveMirrorVideo` amacı **açılmaz**; bulut modu ancak ayrı bir ADR ile ve kendi tehdit modeliyle eklenir.
4. **Tek doğruluk motoru:** beden/kumaş/ölçü sonucu (`PrecisionFitEngine`, bugün `SizeAdvisor`) iki aynadan da bağımsızdır; aynadaki görüntü beden iddiası üretmez (LM21-08).
5. **Mimari:** `MirrorProvider` protokolü; `LocalMirrorProvider` ve `CloudVTONProvider` (stub). Mod ve maliyet kapıları domain seviyesinde, UI'da değil. Otomatik mod yükseltme yok; tek ortak izin düğmesi yok.
6. **Yüzey:** Canlı Ayna yeni sekme değil; ürün kartından ("Canlı aynada dene") ve stilistten açılan tam ekran rota (C-13).
7. **Kanıt:** kamera ve ayna işlerinin hepsi fiziksel iPhone ister → `REAL_DEVICE_BLOCKED` (LM21-10.9); simülatörde yalnız sözleşme ve UI kabuğu.

## Neden

Kullanıcının istediği "ayna ekranında deneme" deneyimi; ancak araştırma (docs/research/VTON_LANDSCAPE_2026-11.md) cihazda çalışan ticari kullanılabilir bir generatif VTON olmadığını gösterdi (Mobile-VTON ve benzerleri NC lisanslı; FASHN sunucu sınıfı ve ayrıştırıcısı NC). Yerel 3D yol hem lisanslı hem mahremiyet sözüyle uyumlu.

## Tehdit modeli eki

THREAT_MODEL.md T23–T27 (yerel/bulut rıza ayrımı, kamera kapanışı, kayıt yok, telemetri, token).

# V25-00 — Gerçeklik raporu ve sıradaki iş (2026-11-03)

- **Başlangıç HEAD:** `30ed2ef`, main: UI20-WP02-04, 287 paket testi ve 10/10 UI testi, SIMULATOR_ONLY.
- **Çalışma dalı:** `v25/living-world`. Main'e birleşme kullanıcı onayı bekler.
- **Kanon:** v2.5 (D-024).
- **Komut:** `docs/constitution/commands/CLAUDE_KABINSIZ_v2.5_DOGRUDAN_UYGULAMA_KOMUTU.md`.

## 1. Başlangıçtaki bulgular (v2.5'e göre)

1. **Ana ekran:** Bugün, figür + kart düzeniydi. Sahne, şehir, kombin ve hava yoktu. Bu, v2.5 §2'nin "kart değil, yaşayan dünya" şartına aykırıydı.
2. **Giydirme ve kombin:**
   - Figür çıplak nötr gövdeydi; giysi çizimi ve giydirme durumu yoktu.
   - Undo yoktu.
   - Günlük kombin motoru yoktu; TravelEngine yalnız seyahatte kombin üretiyordu.
3. **Live Mirror:** Yalnız sözleşmeler vardı (LM21-WP03: durum makinesi, oturum, bayrak). Ekran, kamera ve duruş takibi yoktu.
4. **Sekmeler ve marka:**
   - Sekmeler `Bugün | Dolabım | Ben` idi; Ayna'nın yeri yoktu.
   - İkon yoktu. Palet v2.0 değerleriyle kullanıcının marka panosundan farklıydı.
5. **Hava:** WeatherKit kodu hazır ama Apple PLA kabul edilmediği için BLOCKED_EXTERNAL (R-003).

## 2. On engel (v2.5 hedefine karşı)

| # | Engel | Durum |
|---|---|---|
| B1 | Gerçek iPhone'da 360° figür + sahne FPS/RAM/ısı ölçümü yok | REAL_DEVICE_BLOCKED. iPhone 14 Pro Max eşli, imzalı kurulum denenmedi ya da kanıtlanmadı. |
| B2 | Lisanslı ürün kataloğu / 3B ürün varlığı yok; "Mağazadan" tepsisi boş | BLOCKED_EXTERNAL (R-004) |
| B3 | Hava sağlayıcısı (WeatherKit) bağlı değil; gerçek yağmur gösterilemez | BLOCKED_EXTERNAL (R-003). Yalnız etiketli önizleme var. |
| B4 | Giysiler T1 prosedürel; fotogerçekçi değil, kumaş benzetimi yok | CODED. T2/T3 için lisanslı varlık ya da yerel model gerekir. |
| B5 | Kullanıcının kendi fotoğraflarından dolap (Photos → Wardrobe) yok | SPEC_ONLY (v2.4 fotoğraf mühendisliği eki) |
| B6 | Live Mirror'da ürün bağlantısı ve ekran görüntüsünden ürün alma yok | SPEC_ONLY. Barkod/kod girişi var (Tara). |
| B7 | Live Mirror kamera yolu yalnız kodlandı; simülatörde kamera yok | CODED, SIMULATOR_ONLY yedek kartı test edildi. Cihazda doğrulanmadı. |
| B8 | Barcelona sahnesi zayıf (düz, gri) | CODED, iyileştirme bekliyor |
| B9 | Bulut VTON (Decart Lucy) | BLOCKED_EXTERNAL. DPA, lisans, maliyet ve rıza gerekir; bayrak OFF (ADR-008). |
| B10 | Figür yüzü/saçı yok; nötr manken | Bilerek. Kimlik çıkarımı yapılmaz, kişisel benzerlik iddiası yok. |

## 3. Çatışma haritası

| Çatışma | Çözüm |
|---|---|
| v2.0 §06 "3 sekme + Tara eylem" ↔ referans görsel 5 sekme | 4 sekme `Bugün \| Dolabım \| Ayna \| Ben`; Tara global eylem (ADR-010, D-025) |
| v2.0 §03 renk değerleri ↔ kullanıcının marka panosu | Marka panosu kazanır; AA için koyulaştırma yapıldı (D-026) |
| Referans görseldeki "yağmurlu Galata" ↔ v2.5 "gerçek değilse sahte hava yok" | Varsayılan "Hava verisi yok"; yağmur yalnız etiketli önizleme (D-027) |
| Gerçek İstanbul/Barcelona görüntüsü isteği ↔ hak/lisans | Blender'da özgün çizim sahneler; fotoğraf ya da harita verisi yok (D-027) |
| "Saniyesinde yeni kombin" ↔ ölçüm şartı | Kombinler önceden hazırlanır. Değişim süresi loglanır ve ölçülür; cihaz değeri yok. |

## 4. Kuyruk (v2.5 sırası)

| ID | İş | Durum |
|---|---|---|
| V25-00 | Gerçeklik, kanon, çatışma haritası | Bu belge |
| V25-01 | Sıcak Quiet Atelier arayüzü (marka paleti, ikon, kâğıt yüzeyler) | CODED + TESTED, SIMULATOR_ONLY |
| V25-02 | 360° figür ana ekranda | CODED + TESTED, SIMULATOR_ONLY |
| V25-03 | Figürü giydir (T1 prosedürel giysi) | CODED + TESTED (paket testi + UI) |
| V25-04 | Parça seç/değiştir + geri al | CODED + TESTED, SIMULATOR_ONLY |
| V25-05 | Pilot şehir sahneleri (İstanbul, Barcelona) | CODED. Barcelona kalitesi zayıf (B8). |
| V25-06 | Hava efekti yalnız kanıttan / etiketli önizleme | CODED + TESTED |
| V25-07 | Önceden hazırlanmış "Yeni Kombin Oluştur" | CODED + TESTED. Süre yalnız model katmanında loglanır. |
| V25-10 | Ürün alma (barkod/kod, dolap); bağlantı ve ekran görüntüsü | Kısmi: dolap + Tara. Bağlantı ve ekran görüntüsü SPEC_ONLY. |
| V25-11 | Yerel Canlı Ayna (kamera + Vision duruş + T1 çizim) | CODED. Simülatörde yedek kart TESTED; cihazda REAL_DEVICE_BLOCKED. |

**Sıradaki engel:** B1/B7. Uygulama iPhone 14 Pro Max'e imzalı kurulmalı, ardından şunlar ölçülmeli:
- 360° dünya için FPS, RAM ve ısı;
- Canlı Ayna'da duruş takibinin kare hızı;
- kombin değişim süresi, p50–p95 olarak.

Kurulum ve kamera izni kullanıcının telefonunda onay ister.

# V19 cihaz içi gecikme planı

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 7 · V19-03.3, V19-12.6, LM21-06, v1.7 §3.3
Ölçüm yöntemi, cihaz matrisi ve kurallar: `docs/quality/V19_BENCHMARK_PROTOCOL.md`. **Bu dosyada ölçülmüş sayı yoktur**; tüm hücreler `NOT_MEASURED`. Cihaz koşuları `REAL_DEVICE_BLOCKED` (3 eşleşmiş iPhone çevrimdışı).

## 1. Yol × koşul matrisi

| Yol | Kod bugün | Soğuk | Sıcak | Önbellekli | Ağ | Hedef (belge) |
|---|---|---|---|---|---|---|
| Manuel kod → karar kartı | `ShoppingCopilot/Catalog.swift:66-75`, `DecisionComposer.swift:21-55` (senkron, yerel) | NOT_MEASURED | NOT_MEASURED | — | Ağ yok | S2+S3 (V19-03.3) |
| Kamera → ilk faydalı kart (S0) | Yok | — | — | — | — | ≤0.8 sn |
| Kod → kimlik (S1) | Yerel çözüm var | NOT_MEASURED | NOT_MEASURED | — | Ürün rotası yok | ≤1.0 sn |
| Kaydırıcı → 2D önizleme | `Octopus/BodyJourney.swift:149`; düğüm sınırı morph 200 ms / render 500 ms (D-013, sert iptal) | NOT_MEASURED | NOT_MEASURED | — | — | registry `deadlineMs` 50/33 ms hedef |
| Kaydet (kasa) | `Vault/Vault.swift:136` + `F_FULLFSYNC` | NOT_MEASURED | NOT_MEASURED | — | — | persist 10 s sert sınır |
| Önbellekli → ilk 3D | Yok | — | — | — | — | ≤3 sn (G1) |
| Seyahat planı | `TravelEngine/TripPlanner.swift` | NOT_MEASURED | — | — | Hava: dokunuşla, PLA bekliyor | ilk plan ≤2 sn (V18-02) |
| Yerel ayna ilk kare / takip→ekran | Yok | — | — | — | Ağ yasak | ≤1 sn / ≤100 ms p95 |
| Bulut ayna TTFF / g2g | Yok | — | — | — | `BLOCKED_EXTERNAL` | ≤3 sn / ≤500 ms p95 |

Mevcut tek zaman ölçümü macOS birim testlerinin süresidir (ör. `swift test` toplam 8.8 sn); bu bir performans kanıtı değildir.

## 2. Ön koşul işler

1. **WP15-06:** `ProcessInfo.thermalState`, `isLowPowerModeEnabled`, bellek uyarısı → `DeviceBudget` kademesi (`SystemContracts/DeviceBudget.swift:43-52`). Bugün sinyal yok (grep 0).
2. **Signpost:** her yolun başlangıç/bitiş noktasına `os_signpost` (`OSSignposter`); kategori `Kabinsiz.Perf`. Kişisel değer yazılmaz (yalnız olay adı, revizyon numarası).
3. **MetricKit** (cihaz, yayın öncesi): yalnız toplulaştırılmış; dışarı gönderim yok (rıza ayrı, V19-12.2).

## 3. Adaptif politika (hedef; WP15-06 kabul testleri)

| Termal / güç | Kademe | Ne düşer | Ne kalır |
|---|---|---|---|
| nominal | `BALANCED` | — | — |
| fair | `BALANCED` | arka plan çıkarımı | her şey |
| serious | `CONSERVE` | 3D → 2D, P2 iş | tarama, kart, kaydırıcı, silme |
| critical / Düşük Güç | `SURVIVAL` | ağ, ağır iş, ayna | P0: kart, kaydırıcı, silme (`DeviceBudget.swift:48`) |

LM21-06: ısınmada ayna 720p/30 → 24 fps + LOD düşür; kritikte provayı kapat, ürün kartına dön. OS'un vermediği kesin sıcaklık gösterilmez.

## 4. Çıkış koşulu

Her satır için 3 cihaz sınıfı × soğuk/sıcak × termal başlangıç, ≥30 tekrar, p50/p95/p99 + örnek sayısı + SHA. Bir sınıf eksikse satır `PARTIAL_DEVICE`; simülatör sonucu yalnız `SIMULATOR_ONLY` sütununa.

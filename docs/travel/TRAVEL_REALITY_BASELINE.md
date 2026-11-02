# Travel Reality Baseline (§57)

Genel baseline: `docs/audit/REALITY_BASELINE_v1.3.md`.

| Konu | Durum (2026-11-03) |
|---|---|
| Mevcut gardırop kodu | YOK. Bu oturumda `DomainContracts.Garment` + `WardrobeDomain` yazılıyor, Travel bunu yeniden kullanır |
| Mevcut 3D kodu | YOK. TRV-12 / TRV-14 `SPEC_ONLY`, 2D kart fallback |
| Hava yetkisi | WeatherKit `UNKNOWN` → `BLOCKED_EXTERNAL`. Varsayılan `NO_DATA`, demo `SYNTHETIC_FIXTURE` |
| İklim normalleri | Lisanslı veri yok, `SEASONAL_GUIDANCE` üretilmez |
| Venue kaynakları | Yok. Yalnız kullanıcının girdiği dress code (`USER_INPUT`) |
| Şehir arama/geocoder | Ağ kullanılmıyor. Yerel küçük şehir tablosu (IANA saat dilimi ile) + manuel giriş; manuel girişte `TIMEZONE_UNVERIFIED` |
| Desteklenen cihaz | Simulator iPhone 17 (iOS 26.x). Fiziksel cihaz `BLOCKED_DEVICE` |
| Algoritma | ADR-003, küçük referans fixture ile brute-force karşılaştırması |

## Çözülmemiş kısıtlar

- Gerçek valiz ağırlıkları bilinmiyor. Kullanıcı girmedikçe toplam ağırlık gösterilmez.
- Havayolu bagaj kuralları hiç varsayılmaz.
- Gerçek kullanıcı araştırması yapılmadı; tüm ürün metrikleri hipotez.

# ADR-004 — Hava ve ürün verisi: yalnız arayüz + sentetik fixture, fail closed

- Durum: KABUL · 2026-11-03 · Anayasa §42, §58, §60.2, §7.5, T-TRV-019/021/025, T-V13-003/005/006

## Hava

- `WeatherProvider` protokolü `WeatherSnapshot` döndürür. `evidence` alanı zorunlu: `LIVE_FORECAST | CACHED_FORECAST | SEASONAL_GUIDANCE | USER_OVERRIDE | NO_DATA`.
- P0 implementasyonları:
  - `NoDataWeatherProvider`: her gün `NO_DATA`, sıcaklık alanları `nil`.
  - `FixtureWeatherProvider`: testler ve demo için, provider adı `SYNTHETIC_FIXTURE`.
- Uygulama varsayılanı `NoDataWeatherProvider`. Demo fixture yalnız açıkça `SYNTHETIC_DEMO_ONLY` etiketli seyahatte kullanılır.
- Bilinmeyen sıcaklık hiçbir zaman 0 °C olarak serileşmez (`Double?`). Negatif değerler korunur.
- WeatherKit adapter'ı `BLOCKED_EXTERNAL` (entitlement doğrulanmadı). Eklendiğinde aynı protokolü uygular, attribution zorunlu.

## Ürün kataloğu

- `ProductResolver` yalnız tam kod eşleşmesinde ürün döndürür. Bilinmeyen kod → `.notFound`. Belirsiz → `.ambiguous([adaylar])`. Benzer ürün asla "aynısı" sunulmaz.
- P0 katalog: uygulama içinde sentetik JSON, her ürün `provenance = SYNTHETIC_DEMO_ONLY`, UI'da rozet.
- Stok ve fiyat alanı yok. Hiçbir koşulda uydurulmaz.
- Beden tablosu yoksa beden önerisi `abstain`.

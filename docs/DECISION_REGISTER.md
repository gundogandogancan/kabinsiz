# Decision Register

| ID | Karar | Durum | Kaynak |
|---|---|---|---|
| ADR-001 | Native iOS + saf Swift `KabinsizCore` paketi + XcodeGen | KABUL | docs/adr/ADR-001-architecture.md |
| ADR-002 | Sürümlü Codable JSON yerel depo, actor | KABUL (P0) | docs/adr/ADR-002-local-persistence.md |
| ADR-003 | Kapsül optimizer: greedy + yerel onarım + brute-force referans | KABUL | docs/adr/ADR-003-capsule-optimizer.md |
| ADR-004 | Hava/katalog yalnız arayüz + sentetik fixture, fail closed | KABUL | docs/adr/ADR-004-weather-and-catalog-sources.md |
| ADR-005 | Fit Passport kapsamlı kural tablosu, ≥2 gözlem, yüzde yok | KABUL | docs/adr/ADR-005-fit-passport-rules.md |
| D-001 | Ürün adı "Kabinsiz", iç kod adı WEARFORM; kamuya ilan yok | KULLANICI KARARI | 2026-11-03 sohbet |
| D-002 | Kamera/barkod yerine P0'da manuel ürün kodu girişi (§60.3 fallback) | GEÇİCİ | Cihaz yok, kamera simülatörde test edilemez |
| D-003 | 3D önizleme P0 dışı; 2D kart fallback (§44.4) | GEÇİCİ | Blender/asset/lisans yok |
| D-004 | Kanonik anayasa v1.5. Yeni iş v1.5 §122 DAG sırasıyla; mevcut travel/shopping kodu korunur, yeni travel özelliği P1'e kadar yok | KABUL | Kullanıcı "sıraya koy" 2026-11-03; docs/audit/V15_QUEUE_AND_CONFLICT_MAP.md |
| D-005 | D-003 gözden geçirilecek: v1.5 §133.1 ilk kanıt gövde kaydırıcıları + 3D mesh istiyor. Blender olmadan prosedürel mesh ile başlanır | AÇIK | v1.5 §122/§133 |

## Açık riskler

| ID | Risk | Sahip | Durum |
|---|---|---|---|
| R-001 | Disk %97 dolu: build/simulator başarısız olabilir | AG-11 | AÇIK |
| R-002 | Gerçek cihaz yok: G-TRV-DEVICE, T-V13-010 yapılamaz | AG-10 | BLOCKED_DEVICE |
| R-003 | WeatherKit entitlement bilinmiyor | AG-13 | BLOCKED_EXTERNAL |
| R-004 | Lisanslı katalog/beden tablosu yok, fit iddiası yapılamaz | AG-08 | BLOCKED_EXTERNAL |
| R-005 | Blender bu Mac'te yok: WP15-07 rig/asset hattı | AG-04 | BLOCKED_TOOL |
| R-006 | Yerel veri şifresiz JSON (v1.5 §111/§116 açığı) | AG-09 | AÇIK → WP15-04 |

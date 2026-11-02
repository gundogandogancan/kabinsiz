# Kabinsiz — REALITY BASELINE v1.3

> Tarih: 2026-11-03 · Anayasa: v1.3 canonical (§74 adım 1, §0.1 adım 1, §57 "before writing code")
> Bu dosya **gözlem**dir; hiçbir özelliğin çalıştığını kanıtlamaz.

## 1. Repository

| Alan | Gerçek durum |
|---|---|
| Repo | `~/Projectkabinsiz`, yerel git, branch `main`, remote **yok** |
| Önceki iş | 1 commit (`Kabinsiz: proje temeli…`): yalnız anayasa dokümanları, CLAUDE.md, `.claude/` skill/agent kopyaları |
| Uygulama kodu | **YOK.** v1.0–v1.2'de tarif edilen gardırop, avatar, 3D, fit, retail kodlarının hiçbiri yazılmamış |
| CI | YOK (GitHub remote yok, `gh` yok) |
| Bağımlılıklar | YOK. Üçüncü taraf Swift paketi eklenmedi |

**Sonuç:** §57'deki "product repo is empty" koşulu geçerli. En küçük geçerli iOS projesi ve testleri kurulacak; sevkiyat hazırlığı iddiası yok.

## 2. Makine ve toolchain

| Alan | Değer |
|---|---|
| Mac | Apple M5, 16 GB RAM, macOS 26.4 (25E246) |
| Xcode | 26.6 (17F113) |
| Swift | 6.3.3 |
| XcodeGen | 2.42.0 (`~/.local/bin/xcodegen`) |
| Simulator | iOS 26.4 ve 26.5: iPhone 17 / 17 Pro / 17 Pro Max / 17e / Air |
| **Disk** | **%97 dolu, 15 GB boş.** Build ve simulator için risk. DerivedData proje içine alınıp temizlenebilir tutulacak |
| Yok | brew, gh, docker, uv, blender |

## 3. Cihaz ve imza

| Alan | Değer |
|---|---|
| Fiziksel iPhone | Xcode'a kayıtlı 3 cihaz, hepsi **offline** (Apocan 26.5, Dogi 26.6, Yones 26.2.1) |
| Signing | 2 geçerli codesigning identity var. Provisioning profili 0 (otomatik signing gerektirir) |
| Sonuç | `REAL_DEVICE_BLOCKED`. Bu oturumda cihaz testi yok, tüm ekran görüntüleri `SIMULATOR_ONLY` |

## 4. Dış yetenekler ve haklar

| Alan | Durum |
|---|---|
| WeatherKit entitlement | `UNKNOWN`. Developer hesabında doğrulanmadı → `BLOCKED_EXTERNAL`. Yalnız sentetik fixture + `NO_DATA` |
| Open-Meteo | Ticari lisans incelenmedi → kullanılmayacak |
| İklim normalleri (seasonal) | Lisanslı veri seti yok → `SEASONAL_GUIDANCE` üretilmez, `NO_DATA` gösterilir |
| Ürün kataloğu / GTIN / beden tablosu | Partner veya lisans yok → yalnız `SYNTHETIC_DEMO_ONLY` katalog |
| 3D avatar / giysi varlıkları | Yok, Blender yok → 3D `SPEC_ONLY`. P0 akışlar 2D kartlarla çalışır (§44.4, §46.2) |
| Venue / kültür kaynakları | Yok → yalnız kullanıcı girdisi dress code (G-TRV-CULTURE fallback) |
| Marka "Kabinsiz" | Tescil/alan adı araştırması yapılmadı → kamuya açık marka ilanı yok |

## 5. Bu oturumda seçilen dikey dilim

v1.3 §74.3 ve v1.2 §57 birlikte uygulanıyor. İkisi de aynı yerel gardırop primitive'lerini kullanıyor.

1. **Ortak çekirdek:** `Garment`, kategori, durum, provenance, sentetik etiket, sürümlü yerel JSON deposu.
2. **Travel (TRV-02..10):** tarih/saat dilimi çözücü, hava provider arayüzü + fixture + `NO_DATA`, aday kombin üretici, kapsül optimizer (greedy + brute-force referans), valiz listesi, plan diff.
3. **v1.3 (WP02–05):** Fit Passport (gözlem, kapsamlı kural, silme), fail-closed ürün çözücü, Shopping Guard (dolapta benzeri), tek ekran karar kartı.
4. **iOS:** 3 sekme (Bugün / Dolabım / Benim Modelim) + Tara eylemi. Seyahat Modu "Bugün" içinde.

Kapsam dışı (`SPEC_ONLY` / `BLOCKED`): canlı hava, 3D/RealityKit, kamera/barkod tarama (manuel kod girişi var), App Clip, retail API, kabin sırası, şifreli export, gerçek cihaz ölçümü.

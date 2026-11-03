# V19 Style DNA ve Atelier

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 5 · V19-07, V19-08, V19-09, V19-10
**Durum: tamamı `SPEC_ONLY`.** Repoda `StyleDNA`, Atelier composer, ranker, sembolik katman yok (`grep -rn "StyleDNA\|astrolog\|numerolog"` Sources/apps: 0). Bu dosya bugünkü temeli, veri sözleşmesi taslağını ve açık kontrolleri yazar; hiçbir şeyi "çalışıyor" saymaz.

## 1. Bugün var olan temel (EVIDENCE)

| Yetenek | Kod | Test | Sınır |
|---|---|---|---|
| Dolap (elle giriş, durum, biçimsellik aralığı, renk adı, nötr bayrağı, yürüyüş konforu) | `DomainContracts/Garment.swift:84-130`, `WardrobeDomain/Wardrobe.swift` | `CapsuleTests.swift` | Siluet/doku/desen alanı yok |
| Alışverişte dolaptan eşleşme (tamamlayıcı kategori + biçimsellik + nötr önce) | `ShoppingCopilot/ShoppingGuard.swift:33-56` | `ShoppingAndFitTests.swift:186,198` | Yalnız kategori/renk/biçimsellik |
| Seyahat kombin adayları + kapsül optimizasyonu | `TravelEngine/OutfitCandidates.swift:89-146`, `CapsuleOptimizer.swift` | `CapsuleTests.swift` | Puan `neutralShare*2 - gaps*5` (`OutfitCandidates.swift:143`) |
| Kullanıcı kontrollü öğrenme (yalnız beden) | `FitPassport/FitPassport.swift:90-118` | `ShoppingAndFitTests.swift:147,163` | Stil öğrenmesi yok |
| Korumalı özellik engeli | `SystemContracts/UntrustedInput.swift:35-60`, `Vault/Vault.swift:145` | `CitadelGateTests.swift:301`, `VaultTests.swift:314` | Ruh hali/kişilik/kültür/ten tonu kökleri yok |

## 2. Girdi alanları (V19-07.1 12 eksen) — sözleşme taslağı

Hepsi `LOCAL_PRIVATE`, kasada `PREFERENCES` alanı, kullanıcı-düzenlenebilir, her biri `source ∈ {USER_STATED, USER_FEEDBACK, DERIVED_FROM_OWNED}`; görüntüden çıkarım kaynağı **yoktur**.

| # | Eksen | Değer tipi (öneri) | Kaynak | Kontrol |
|---|---|---|---|---|
| 1 | Konfor ve hareket | sıralı tercih (dar…bol), katman toleransı | beyan + "bedeni rahatsız" geri bildirimi | düzenle/sıfırla |
| 2 | Siluet dili | çoklu seçim | beyan | düzenle |
| 3 | Renk ifadesi | sevilen/kaçınılan renk adları, kontrast | beyan; **ten tonu yok** | "Beni böyle görme" |
| 4 | Desen ritmi | çoklu seçim + yoğunluk | beyan | düzenle |
| 5 | Doku ifadesi | görünüm tercihi (içerik doğrulaması ayrı, R17-04) | beyan | düzenle |
| 6 | Estetik yön | çoklu stil etiketi | beyan / soğuk başlangıç seçimi | sıfırla |
| 7 | Sosyal niyet | kullanıcının seçtiği niyet | beyan, karar başına | — |
| 8 | Ortam zekâsı | etkinlik türü, mekân kuralı (doğrulanmışsa) | beyan + `TripEvent` (`TravelEngine/TripModels.swift:84-97`) | — |
| 9 | Marka ve logo zevki | sevilen/kaçınılan marka, logo yoğunluğu | beyan | "Bu marka için kullanma" |
| 10 | Bütçe ve dayanıklılık | ürün/toplam üst sınır | beyan | — |
| 11 | İklim ve bakım | kullanıcının belirttiği üşüme/terleme, bakım isteği | yalnız açık beyan (sağlık değil) | — |
| 12 | Çeşitlilik ve evrim | güvenli/küçük yenilik/deneysel | beyan + kayıtlı geri bildirim | revizyon geçmişi + geri al |

Ön şart (rapor §7.4): `SensitiveAttributeGuard` köklerine `mood`, `personality`, `culture`, `skin`/`tone` eklenmeli ve Style DNA kayıt tipi `VaultTests.swift:324` ("every real app record type passes the guard") kapsamına girmeli.

## 3. Kombin yaratımı ve sıralama (V19-08) — hedef boru hattı

`Anchor → Intent → Composition → Hard constraints (beden, hava, temiz/uygun, bütçe, ret geçmişi) → Aspect vektörü → Çeşitlilik → Kişiselleştirme → Gerekçe`.

| Kural | Kaynak | Bugün |
|---|---|---|
| Sert kısıtlar puandan önce | V19-08.3 | Seyahatte `condition.isPlannable` + biçimsellik filtresi (`OutfitCandidates.swift:90`) |
| Kalite tek puan değil, vektör: `occasionFit, bodyComfort, fabricWeather, colorHarmony, proportionBalance, texturePattern, personalResonance, noveltyControlled, wardrobeReuse, budgetCompliance, evidenceQuality` | V19-08.3 | Tek skaler `styleScore` |
| Üç varyant: güvenli klasik / karakterli dengeli / cesur deneysel; aynı kombine üç başlık yasak | V19-08.2, UI20-T-025 | Yok |
| Komisyon/sponsor organik sıralamaya girdi değil | V18-03.3, V19-08.3 | Sponsor yalnız etiket (`DecisionComposer.swift:27,52`) |
| Owned-first (POOL A) | V18-03.2 | `ShoppingGuard` dolap eşleşmesi önce |
| Sembolik katman varsayılan OFF, fit/hava/güvenlik/ticaret puanına girmez | V19-09, V19-T-042/043 | Katman yok |

## 4. Kişisel öğrenme (V19-10)

| Tür | İzin | Geri alma | Bugün |
|---|---|---|---|
| Açık tercih (beyan) | her zaman | düzenle/sil | Fit Passport tercihleri (`FitPassport.swift:72-82`) |
| Onaylı geri bildirim ("gerçekte nasıldı") | kullanıcı kaydederse | kayıt sil → sonuç sıfırdan hesaplanır | Fit Passport (`FitPassport.swift:108`) |
| Örtük sinyal (görüntüleme, kaydırma) | **varsayılan kapalı** | — | Yok |

Kendi kendine kod indirme / yetki yükseltme yok (V19-00 madde 5); öğrenen parametre yalnız kasadaki kullanıcı kaydından türetilir ve kayıt silinince yeniden hesaplanır (embedding yok, bu yüzden "unutma" deterministik).

## 5. Değerlendirme

Rubrik `K01..K10` (V19-08.4) insan paneli ister → `HUMAN_REVIEW_PENDING`. "Claude subagent'i 'insan stilist onayladı' diyemez" (V19-08.4). Sentetik dolap üzerinde yapılabilecek otomatik testler: üç varyantın parça kümesi farklılığı, sert kısıt ihlali = 0, sponsor değişmezliği, ret edilen parçanın tekrar gelmemesi. Ayrıntı: `docs/quality/V19_FIT_FABRIC_VISUAL_BENCHMARKS.md` §4.

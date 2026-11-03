# V19 gereksinim izlenebilirliği (v1.5 → v2.1)

Tarih: 2026-11-03 · Commit `f5caa71` · `swift test`: 194 test / 13 suite, çıkış 0 · V19-21 madde 2
v1.2 travel ve v1.3 shopping/fit satırları: `docs/product/TRACEABILITY.md` (bu dosya onları tekrar etmez, yalnız değişeni yazar).

Durum sözlüğü (LM21-00.1 + §74.1): `SPEC_ONLY` · `CODED` · `TESTED_SIMULATOR` (macOS `swift test` ve/veya iPhone 17 simülatörü) · `DEVICE_VERIFIED` · `USER_VALIDATED` · `PARTNER_VERIFIED` · `BLOCKED_EXTERNAL` · `REAL_DEVICE_BLOCKED` · `HUMAN_REVIEW_PENDING` · `UNKNOWN`.
Bu repoda ulaşılan en yüksek seviye `TESTED_SIMULATOR`. `DEVICE_VERIFIED` ve üstü hiçbir satırda yok.

Sahip sütunu anayasa rolüdür (`CLAUDE.md` ajan tablosu); "—" = rol tanımlı değil (AG-06, AG-11).

## 1. v1.5 iş paketleri (WP15) ve test aileleri

| Gereksinim | Kod | Test | Kanıt | Sahip | Durum |
|---|---|---|---|---|---|
| WP15-01 reality baseline | — | — | `docs/audit/REALITY_BASELINE_v1.5.md` | AG-10 | TAMAM |
| WP15-02 SystemContracts, şema göçü; V15-T-ORC-08/10, AGT-01/03/04/05, AGT-06 (kısmi) | `Packages/KabinsizCore/Sources/SystemContracts/*` | `Tests/ContractTests/*` | `docs/evidence/WP15-02.yaml` | AG-03 | TESTED_SIMULATOR |
| WP15-03 CITADEL egress + rıza; V15-T-SEC-04..09 | `SystemContracts/CitadelGate.swift`, `ConsentLedger.swift`, `UntrustedInput.swift` | `Tests/SecurityTests/CitadelGateTests.swift:37-301` | `docs/evidence/WP15-03.yaml` | AG-09 | TESTED_SIMULATOR; SEC-01..03 NOT_APPLICABLE_YET; paket yakalama REAL_DEVICE_BLOCKED |
| WP15-04 şifreli vault; V15-T-CRY-01..05, 10, SEC-10 | `Sources/Vault/*` | `Tests/SecurityTests/VaultTests.swift:38-389` | `docs/evidence/WP15-04.yaml` | AG-09 | TESTED_SIMULATOR; CRY-06 REAL_DEVICE_BLOCKED; CRY-07..09 SPEC_ONLY; kriptograf HUMAN_REVIEW_PENDING |
| WP15-05 Octopus + gövde yolculuğu; V15-T-ORC-01..09, BOD-01..04, 06..10 | `Sources/Octopus/*`, `Sources/BodyGeometry/*`, `apps/ios/Kabinsiz/Features/Profile/BodyStudioView.swift` | `Tests/OctopusTests/*`; UI `apps/ios/KabinsizUITests/AcceptanceDemoUITests.swift:132` | `docs/evidence/WP15-05.yaml` | AG-03, AG-04 | TESTED_SIMULATOR; BOD-05 SPEC_ONLY (foto yok); 3D WP15-07/08 |
| WP15-06 device governor | `Octopus/ResourceGovernor.swift:12-13` (yalnız arayüz), `SystemContracts/DeviceBudget.swift:43-52` (kademeler) | `Tests/ContractTests/RegistryAndPolicyTests.swift:232,245` (yalnız bütçe geçerliliği) | — | — | CODED (kademe); OS sinyali SPEC_ONLY |
| WP15-07/08 3D mesh + morph + 360° | — | — | ADR-007 (çalışma ağacında, commit yok) | AG-04 | SPEC_ONLY |
| WP15-09..14 foto, dolap, ürün çözücü, fit sınırı, try-on, stilist | kısmen v1.3 kodu (`ShoppingCopilot/*`, `FitPassport/*`) | `Tests/KabinsizCoreTests/ShoppingAndFitTests.swift` | `docs/product/TRACEABILITY.md` | AG-08, AG-06 | v1.3 kısmı TESTED_SIMULATOR; ortak sözleşme bağlantısı SPEC_ONLY |
| WP15-15 travel | `Sources/TravelEngine/*` | `Tests/KabinsizCoreTests/CapsuleTests.swift` vb. | `docs/product/TRACEABILITY.md` §v1.2 | AG-07 | TESTED_SIMULATOR (v1.2); WeatherKit BLOCKED_EXTERNAL |
| WP15-16..20 model lab, retail gateway, kalite kapısı, pilot, Android | — | — | — | — | SPEC_ONLY / BLOCKED_EXTERNAL |

## 2. Ek v1.6 bulguları ve testleri

| ID | Gereksinim | Kod | Test | Durum |
|---|---|---|---|---|
| FIT-01 | Kalça, omuz, kol, uyluk, bacak boyu | Gövde: boy/omuz/göğüs/bel/kalça (`BodyGeometry/BodyProfile.swift:5-10`); öneri yalnız göğüs/bel (`apps/ios/Kabinsiz/App/AppModel.swift:65-67`) | BOD-01..04 (gövde) | KISMEN CODED; öneride SPEC_ONLY |
| FIT-02 | Bitmiş giysi ölçüsü, ease, tolerans | — (`FitPassport/SizeAdvisor.swift:6-10` yalnız vücut aralığı) | — | SPEC_ONLY |
| FIT-03 | Başka modelin geçmişi `likely` üretmemeli | `SizeAdvisor.swift:85-116` marka+kategori kapsamı | `ShoppingAndFitTests.swift:119` bunu **kabul ediyor** | AÇIK (davranış v1.6'ya aykırı) |
| FIT-04 | Eksik ölçü sessizce atlanmamalı | `SizeAdvisor.swift:128-137` atlıyor | test yok | AÇIK; paketli sentetik tabloda tetikleniyor (`V19_REALITY_AND_GAP_REPORT.md` Q10) |
| SKU-01 | GTIN, alias, kamera | `ShoppingCopilot/Catalog.swift:8-11` yalnız kod | `ShoppingAndFitTests.swift:27-40` | AÇIK |
| MAT-01 | Lif %, gramaj, yapı | `DomainContracts/Garment.swift:74` 4 boolean | — | AÇIK |
| TMP-01 | Sabit 15 °C kuralı | `TravelEngine/Weather.swift:77-79` | `WeatherTests.swift` | AÇIK |
| VIZ-01 | Nötr morph mesh | 2D siluet (`BodyGeometry/Silhouette.swift:4-5`) | BOD-08/09 | KISMEN (2D) |
| SCAN-01 | Cihazda barkod/OCR | — | — | SPEC_ONLY; REAL_DEVICE_BLOCKED |
| DATA-01 | Vault | `Sources/Vault/*` | VaultTests | KAPANDI (TESTED_SIMULATOR) |
| QA-01 | Cihaz, gerçek giysi, benchmark | — | — | REAL_DEVICE_BLOCKED / BLOCKED_EXTERNAL |
| OPS-01 | CI | `scripts/check.sh` (yerel) | — | SPEC_ONLY (`.github/` yok) |
| T-KAB-PROD-001..007 | Ürün kimliği | kısmen `Catalog.swift` | T-V13-003/004/034 karşılıkları | Çoğu SPEC_ONLY |
| T-KAB-FIT-001..009 | Bölgesel fit | — | — | SPEC_ONLY |
| T-KAB-MAT-001..008 | Kumaş | — | — | SPEC_ONLY |
| T-KAB-SEC-001..007 | Ürün isteğinde beden yok vb. | `CitadelGate.swift:157-200` | `CitadelGateTests.swift:167` (SEC-08 = T-KAB-SEC-001 eşdeğeri) | Kısmen TESTED_SIMULATOR |
| AGENT-01..16 | Runtime ajanlar | `SystemContracts/ModuleRegistry.swift:161` (OCT eşlemesi) | — | Eşleme `docs/system/V19_OCTOPUS_MODULE_REGISTRY.md` |

## 3. Ek v1.7

| ID | Gereksinim | Kod / test | Durum |
|---|---|---|---|
| R17-00 | Reality audit | bu dosya + rapor | TAMAM (V21-00) |
| R17-01 | Güvenlik çekirdeği | WP15-03/04 | TESTED_SIMULATOR |
| R17-02 | `ProductIdentityV1 … VisualTryOnV1` DTO'ları | — | SPEC_ONLY |
| R17-03 | Vision barkod/OCR | — | SPEC_ONLY; REAL_DEVICE_BLOCKED |
| R17-04 / R17-MAT-01..04 | Kumaş parser | — | SPEC_ONLY |
| R17-05 / R17-FIT-01..06 | Bölgesel fit + abstain | Abstain kısmı `SizeAdvisor.swift:95-124` | KISMEN (abstain TESTED_SIMULATOR) |
| R17-06 / R17-3D-01..04 | Avatar mesh G0/G1 | 2D | KISMEN |
| R17-07, R17-08 (gerçek), R17-11, R17-13 | Lisanslı ürün, asset, Fit Truth Lab, pilot | — | BLOCKED_EXTERNAL |
| R17-09 / R17-THM-01..03 | Termal tavsiye | — | SPEC_ONLY |
| R17-10 / R17-E2E-01..02 | Tek ekran alışveriş kartı | v1.3 kartı (`DecisionComposer.swift`) | KISMEN; e2e REAL_DEVICE_BLOCKED |
| R17-12 | CI, SBOM, release gate | — | SPEC_ONLY |
| R17-14 / R17-ML-01..02 | Mobile-VTON araştırma | — | BLOCKED_EXTERNAL (CC BY-NC-SA) |
| R17-SKU-01..05, R17-DAT-01..03 | Kimlik ve veri | — | SPEC_ONLY |
| R17-PERF-01..02 | Perf | — | REAL_DEVICE_BLOCKED |
| R17-SEC-01..05 | Güvenlik | SEC-04..09 karşılıkları | Kısmen TESTED_SIMULATOR |
| R17-UX-01..02 | Kamera reddi → manuel kod | Manuel kod tek yol (`apps/ios/Kabinsiz/Features/Scan/ScanView.swift:23`) | Fallback var, kamera yok |

## 4. Ek v1.8

| ID | Gereksinim | Durum |
|---|---|---|
| R18-WP01 | Reality audit | TAMAM (V21-00) |
| R18-WP02 | Commerce graph şeması | SPEC_ONLY |
| R18-WP03 | EvidenceCoverageGate | Temel tip var (`SystemContracts/EvidenceRecord.swift:87`, test `RegistryAndPolicyTests.swift:163,179`); kapı SPEC_ONLY |
| R18-WP04/05 | Owned-first kombin | Kısmi: `ShoppingGuard.swift:33-56` owned pairing (T-V13-046) |
| R18-WP06/07 | UI kartları, sentetik çok marka | 7 ürünlük sentetik katalog (`ShoppingCopilot/Resources/SyntheticCatalog.json`); çok marka/offer SPEC_ONLY |
| R18-WP08..WP15 | Retail, affiliate, portal, global | BLOCKED_EXTERNAL |
| V18-T-001..048 | Test seti | Sponsor yalıtımı (V18-T-012/016 ruhu) `ShoppingAndFitTests.swift:65`; geri kalanı SPEC_ONLY |

## 5. Ek v1.9

| ID | Gereksinim | Durum |
|---|---|---|
| WP19-00 | Reality report | TAMAM (V21-00) |
| WP19-01 | Egress/vault/governor | Egress + vault TESTED_SIMULATOR; governor SPEC_ONLY |
| WP19-02 | Event/decision sözleşmesi + revizyon | `DomainEvent.swift`, `DecisionEnvelope.swift`, `BodyJourney.swift`; TESTED_SIMULATOR (yalnız gövde) |
| WP19-03..08 | Kamera, brand graph, ölçü, kumaş, avatar, fidelity | SPEC_ONLY (WP19-07 2D kısmı TESTED_SIMULATOR) |
| WP19-09, 10, 14 | Style DNA, Atelier, sembolik | SPEC_ONLY (`docs/ai/V19_STYLE_DNA_AND_ATELIER.md`) |
| WP19-11 | Uçtan uca alışveriş | KISMEN (manuel kod kartı) |
| WP19-12, 15 | İnsan değerlendirme, partner | BLOCKED_EXTERNAL / HUMAN_REVIEW_PENDING |
| WP19-13 | Cihaz perf | REAL_DEVICE_BLOCKED |
| WP19-16 | CI, supply chain | SPEC_ONLY |
| V19-T-001..066 | Olumsuz test seti | Karşılığı olanlar: kimlik "benzer ikame yok" (T-V13-003), sponsor yalıtımı, korumalı özellik reddi (SEC-09), revizyon (ORC-08), yerel/ağ (SEC-06..08). Diğerleri SPEC_ONLY; "koşulmadan PASS değil" (V19-18) |
| V19-Q01..Q40 | Denetim | `docs/audit/V19_REALITY_AND_GAP_REPORT.md` §1 |

## 6. Ek v2.0

| ID | Durum |
|---|---|
| UI20-WP01 | TAMAM (V21-00 rapor §2) |
| UI20-WP02..10 | SPEC_ONLY. Eski token `apps/ios/Kabinsiz/DesignSystem/Theme.swift:10`; 3 sekme var (`apps/ios/Kabinsiz/App/KabinsizApp.swift:36-39`) |
| UI20-T-005 | Reduce Motion gövde morfu: CODED (`BodyStudioView.swift:10,76`), otomatik test yok |
| UI20-T-009 | "Dolabın eklenmedi" (T-V13-008, `ShoppingAndFitTests.swift:58`): TESTED_SIMULATOR |
| UI20-T-010 | Ürün bulunamazsa uydurma yok (T-V13-003): TESTED_SIMULATOR |
| UI20-T-011 | Yüzde yok, abstain görünür: TESTED_SIMULATOR (paket); FIT-04 istisnası açık |
| UI20-T-012 | 3D yoksa "ürüne özel" denmez (T-V13-007, `ShoppingAndFitTests.swift:51`): TESTED_SIMULATOR |
| UI20-T-013 | Slider VoiceOver etiketi + değer: UI testte kısmen (`docs/evidence/WP15-05.yaml` `accessibility_checks`); tam geçiş REAL_DEVICE_BLOCKED |
| UI20-T-016 | Sponsor etiketi sıralamayı değiştirmez: TESTED_SIMULATOR (`ShoppingAndFitTests.swift:65`) |
| UI20-T-020 | Profil silme: TESTED_SIMULATOR (`AcceptanceDemoUITests.swift:89,132`) |
| UI20-T-021 | Screenshot başına SHA/tema/kaynak: AÇIK |
| Diğer UI20-T-* | SPEC_ONLY |

## 7. Ek v2.1

| ID | Durum |
|---|---|
| LM21-WP01 | TAMAM (V21-00 rapor §3) |
| LM21-WP02 | ADR-008 çalışma ağacında, commit yok → CODED değil, belge |
| LM21-WP03..09, WP11 | SPEC_ONLY; WP04..08 REAL_DEVICE_BLOCKED |
| LM21-WP10, 12, 13, 15, 16, 17 | BLOCKED_EXTERNAL |
| LM21-WP14 | SPEC_ONLY |
| LM21-T01..T50 | Hiçbiri koşulmadı. LM21-T40 "bulut bayrağı OFF" bugün yapısal olarak doğru (bulut kodu yok), test değil |
| LM21-M01..M24 | Eşleme `docs/system/V19_OCTOPUS_MODULE_REGISTRY.md` §3 |

## 8. Çelişki kaydı (kod ↔ ek)

| # | Kod davranışı | Ek hükmü | Karar yeri |
|---|---|---|---|
| X-1 | `SizeAdvisor` marka+kategori geçmişini başka modele uyguluyor (`SizeAdvisor.swift:85-107`; test `ShoppingAndFitTests.swift:119` bunu doğru sayıyor) | v1.6 FIT-03, V19-01 "başka modelde iki kez M tam oldu yeni ürünün garantisi değildir" | R17-05; ADR-005 güncellemesi |
| X-2 | `chartMatch` eksik ölçüyü atlıyor | v1.6 FIT-04 `PARTIAL` | R17-05 (öne çekme önerisi: rapor §7.1) |
| X-3 | `FeatureStatus` v2.1 sözlüğünü içermiyor (`DomainContracts/Evidence.swift:27-30`) | LM21-00.1 | LM21-WP03 |
| X-4 | `VisualFidelityTier` yalnız 3 kademe (`Evidence.swift:12-15`) | v1.7 §3.2 G0..G3 | R17-02 |
| X-5 | `needsWarmLayer` sabit 15 °C | v1.6 TMP-01, V19-05.2 "sabit evrensel derece yok" | R17-09 |
| X-6 | D-003 HEAD'de GEÇİCİ | v1.6 VIZ-01, WP19-07 | V21-01 (ADR-007) |
| X-7 | Üçüncü sekme "Benim Modelim" | v2.0 §06 "Ben" | UI20-WP04; kullanıcı kararı |
| X-8 | `Theme.swift` `#283D46`, serif yok | v2.0 §03–§04 | UI20-WP02 |

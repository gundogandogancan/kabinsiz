# V19 Octopus modül kaydı (R01..R28 ↔ OCT ↔ LM21-M)

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 3 · C-20 (tek filo)
Kodda tek kaynak: `Packages/KabinsizCore/Sources/SystemContracts/ModuleRegistry.swift:161` (`p0Descriptors`) ve onun aynası `docs/system/AGENT_REGISTRY.yaml` (drift testi `Tests/ContractTests/RegistryDocDriftTests.swift:7`). **Bu dosya kod kaydı değildir**; v1.9 R01..R28 ve v2.1 LM21-M01..M24 adlarını mevcut `ModuleID` (OCT-01..24, `SystemContracts/Vocabulary.swift:44-50`) kimliklerine eşler. v1.7 §8: "ikinci paralel filo kurulmayacak" → yeni ad = yeni kimlik değil, mevcut OCT'nin görevi.

## 1. Çalışan çalışma zamanı (EVIDENCE)

| Parça | Kod | Test |
|---|---|---|
| Koordinatör (actor): DAG, düğüm başına deadline + fallback, circuit breaker, latest-wins, coalescing, must-complete yazma | `Octopus/OctopusCoordinator.swift:14-276`, `Octopus/TaskGraph.swift` | `Tests/OctopusTests/CoordinatorTests.swift:13-358` |
| Governor (yalnız bütçe; OS sinyali yok) | `Octopus/ResourceGovernor.swift:23-50`, `SystemContracts/DeviceBudget.swift:43-52` | `CoordinatorTests.swift:101` |
| Yetki: düğüm `reads` ↔ registry; varsayılan red | `OctopusCoordinator.swift:140-150`, `ModuleRegistry.swift:142-155` | `CoordinatorTests.swift:54` (ORC-09), `RegistryAndPolicyTests.swift:20-54` |
| Olay günlüğü + revizyon koruması | `Octopus/BodyJourney.swift:51-94`, `SystemContracts/DomainEvent.swift` | `BodyJourneyTests.swift:287,314` |
| Egress kapısı | `SystemContracts/CitadelGate.swift:78-200` | `SecurityTests/CitadelGateTests.swift` |

Uygulamada koordinatörü kullanan tek yol gövde stüdyosu (`apps/ios/Kabinsiz/App/AppModel.swift:243`). Tarama kartı (`apps/ios/Kabinsiz/Features/Scan/ScanView.swift:71`) ve seyahat planı (`AppModel.swift:383`) koordinatörsüz.

## 2. R01..R28 eşlemesi

Kayıt sütunu: `KAYITLI` = `p0Descriptors` içinde (13 modül); `KİMLİK` = `ModuleID` var ama kayıtsız → her yetki reddedilir; `YOK` = kimlik de yok.

| v1.9 | Ad | OCT | Kayıt | Yetkiler (kayıtlıysa) | Kod durumu | Kapatan iş |
|---|---|---|---|---|---|---|
| R01 | ScanController | OCT-09 (girdi) | KAYITLI | `catalog.readLicensed` | Kamera yok; manuel kod | R17-03 |
| R02 | ImageQualityGate | OCT-05 | KAYITLI | `photos.readUserSelected` | Kod yok | R17-03 |
| R03 | ProductIdentityResolver | OCT-09 | KAYITLI | `catalog.readLicensed` | `ShoppingCopilot/Catalog.swift:40-75` (koordinatör dışı) | R17-02/03 |
| R04 | CatalogEvidenceGate | OCT-21 | KİMLİK | — | `EvidenceRecord.isDisplayableAsVerified` tip olarak var | R18-WP03 |
| R05 | BrandGraphIndex | OCT-10 | KİMLİK | — | Yok | R17-02 |
| R06 | GarmentMeasurementParser | OCT-10 | KİMLİK | — | Yok | R17-05 |
| R07 | FabricDNAEngine | OCT-11 | KİMLİK | — | Yok | R17-04 |
| R08 | CareLabelInterpreter | OCT-11 | KİMLİK | — | Yok | R17-04 |
| R09 | ThermalAdvisor | OCT-16 (bağlam) | KAYITLI (hava) | `weather.fetch` | Yalnız 15 °C kuralı | R17-09 |
| R10 | BodyProfileManager | OCT-07 | KAYITLI | `body.readExact`, `body.writeManual` | `BodyGeometry/*`, `Octopus/BodyJourney.swift:149` | WP15-07/08 |
| R11 | RegionalFitEstimator | OCT-12 | KAYITLI | `body.readExact`, `catalog.readLicensed` | `FitPassport/SizeAdvisor.swift` (göğüs/bel) | R17-05 |
| R12 | FitPassportLearner | OCT-20 | KAYITLI | `learning.updateLocal` | `FitPassport/FitPassport.swift` | R17-05 |
| R13 | AssetRightsGate | OCT-21 | KİMLİK | — | Yok | WP19-08 |
| R14 | GarmentGeometryEngine | OCT-13 | KİMLİK | — | Yok | WP19-08 |
| R15 | LogoTextureVerifier | OCT-13 | KİMLİK | — | Yok | WP19-08 |
| R16 | WardrobeGraph | OCT-18 | KAYITLI | `wardrobe.read`, `wardrobe.write` | `WardrobeDomain/Wardrobe.swift` (liste, grafik değil) | WP19-09 |
| R17 | StyleDNAEngine | OCT-14 | KAYITLI | `wardrobe.read` | Yok | WP19-09 |
| R18 | OccasionCultureAgent | OCT-17 | KİMLİK | — | Kullanıcı dress code metni | WP19-10 |
| R19 | AtelierCandidateComposer | OCT-14 | KAYITLI | `wardrobe.read` | Seyahat adayları (`TravelEngine/OutfitCandidates.swift:89`) | WP19-10 |
| R20 | OutfitConstraintSolver | OCT-19 | KAYITLI | `travel.readPrivate`, `wardrobe.read` | `TravelEngine/CapsuleOptimizer.swift` | WP19-10 |
| R21 | OutfitMultiObjectiveRanker | OCT-15 | KİMLİK | — | Yok | WP19-10 |
| R22 | SymbolicInspiration | — | YOK | — | Yok | WP19-14 (yeni kimlik ADR ister) |
| R23 | CommerceEligibility | OCT-23 | KAYITLI | `catalog.readLicensed`, `network.productOnly` | Rota yok (EG yok) | BLOCKED_EXTERNAL |
| R24 | SponsorIndependenceGate | OCT-22 (açıklama) | KİMLİK | — | Sponsor etiket-yalnız (`DecisionComposer.swift:27,52`) | R18-WP04/05 |
| R25 | DeviceResourceGovernor | OCT-03 | KİMLİK | — | Governor koordinatör içinde, modül değil | WP15-06 |
| R26 | PrivateVault+Egress | OCT-02, OCT-24 | KAYITLI | `vault.delete`; `diagnostics.readRedacted` | `Vault/*`, `CitadelGate.swift` | — |
| R27 | DecisionEvidenceComposer | OCT-22 | KİMLİK | — | `DecisionEnvelope` tipi var, kart kullanmıyor | R17-02 |
| R28 | FeedbackOutcomeLab | OCT-20 | KAYITLI | `learning.updateLocal` | Yok (yalnız Fit Passport) | WP19-12 (dış) |

## 3. LM21-M01..M24 eşlemesi (v2.1; tamamı SPEC_ONLY)

| LM21 | Önerilen sahip OCT | Not |
|---|---|---|
| M01 CameraOwner, M02 FrameClock, M03 PoseTracker, M04 PersonMatte | OCT-06 BodyLandmarkLab (kayıtsız) | Kamera izni için yeni `Capability` (ör. `camera.liveLocal`) ve `ConsentScope` gerekir; bugün yok (`Vocabulary.swift:21-38`, `ConsentLedger.swift:4-9`) |
| M05 BodyCalibration | OCT-07 | Çevre ölçüsü üretmez; yalnız oran (LM21-04) |
| M06 GarmentReference, M07 RigRetarget, M08 ClothApproximation, M09 OcclusionComposer | OCT-08 / OCT-13 | OCT-08 bugün yalnız `avatar.readRenderSnapshot` |
| M10 LogoTextureGuard | OCT-13 | R15 ile aynı |
| M11 PrecisionFit, M12 FabricTruth, M13 ThermalContext | OCT-12, OCT-11, OCT-16 | Aynadan bağımsız (ADR-008 madde 4, çalışma ağacında) |
| M14 StyleCompanion, M15 ProductSwitcher | OCT-14, OCT-09 | — |
| M16 ModeConsentGate, M17 EgressGate, M23 PrivacyLedger | OCT-02 + `CitadelGate` | `EgressIntent.Purpose.liveMirrorVideo` **açılmaz** (ADR-008 madde 3) |
| M18 EphemeralTokenBroker, M19 CloudVTONAdapter, M20 ConnectionGovernor, M22 SessionBillingGuard | yeni kimlik (ADR ister) | Bulut `BLOCKED_EXTERNAL`; yalnız stub (LM21-WP11) |
| M21 DeviceGovernor | OCT-03 | WP15-06 |
| M24 IndependentMirrorQA | süreç rolü, runtime modül değil | AG-12 |

## 4. Yetenek matrisi boşlukları

| Boşluk | Etki | Kapatan |
|---|---|---|
| Kamera için `Capability` ve `ConsentScope` yok | R01, M01 kodlanamaz | R17-03 / LM21-WP03 |
| `OCT-03` kayıtsız; governor modül değil | Termal kararları denetim kaydına girmez | WP15-06 |
| `OCT-21`, `OCT-22` kayıtsız | Kanıt ve açıklama kapısı koordinatörde yok | R17-02, R18-WP03 |
| Upstream düğüm çıktıları politika denetiminden geçmiyor | `docs/evidence/WP15-05.yaml` `residual_risks` | WP15-18 |

## 5. Olay zaman çizgisi ve tehdit modeli

Bugün yayılan olaylar yalnız gövde `COMMITTED` ve `DELETED` (`docs/evidence/WP15-05.yaml` `residual_risks`); değer taşımaz (`BodyJourneyTests.swift:244`). §105.2 `MorphRequested/MorphValidated/SceneRendered` ayrı olay değil. Tehdit modeli: `docs/security/THREAT_MODEL.md` T1–T22 (HEAD). Kamera/ayna tehditleri için yeni satırlar LM21-WP02 kapsamında.

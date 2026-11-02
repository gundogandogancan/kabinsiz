# WEARFORM — GOD LEVEL V1.1 / LIVING BODY, UNIVERSAL FIT INTELLIGENCE, OCTOPUS COGNITION & RETAIL GROWTH CONSTITUTION

> **Issued:** 03 November 2026. **Status:** Product and engineering specification; NOT implemented, NOT device-verified, NOT commercially licensed.  
> **Supersedes:** Any less precise or conflicting formulation in v1.0 on body morphing, catalog/review evidence, local learning, symbolic styling, partner strategy and quality targets. **All other v1.0 requirements remain binding.**  
> **Operator:** Claude Code, working as an evidence-first Principal Product/Systems Architect with independent quality-auditor and specialized implementer roles.  
> **Language:** Product-facing TR-first, architecture/code contracts may use English.  
> **Rule:** `SPECIFIED ≠ BUILT ≠ TESTED ≠ DEVICE-VERIFIED ≠ COMMERCIAL-READY`.

---

# 23. AMENDMENT CONTROL / CEO MANDATE / ONE PRODUCT, TWO MARKETS

## 23.1 Founder intent, translated into engineering

WEARFORM is an **adaptive private human avatar + virtual outfit laboratory + reliable product-fit decision engine**, where users can reshape their digital model live, import owned clothing, scan merchandise in stores, see a plausible on-body preview, understand fit and size evidence, receive exceptional occasion-aware styling, and optionally join partner shopping experiences. The retailer value proposition is **reducing unnecessary fitting-room visits and decision time without making false exact-fit claims**.

**Two-sided product:** `Consumer WEARFORM` is the user's trusted private fashion companion. `Retail WEARFORM Partner` is a licensed product-data and experiment platform. Neither partner nor advertisements may gain access to private body profiles, faces, photo libraries, precise measurements, birthdays, inferred characteristics or wear history.

**Founder’s 5 upgrades from v1.0:**
1. A **live parametric body-editor**, segmented by anatomy, ± and continuous sliders, undo/revert, symmetric/asymmetric when safe, privacy-neutral gray model; accessible even without photographs.
2. **Brand- and variant-specific fit intelligence** prioritizing manufacturer size charts, pattern/cut, garment measurements, fiber/stretch, size system, source time/version, and validated optional wearer feedback.
3. **Time-to-preview multi-tier renderer**: immediate meaningful result with graceful progressive refinement; do not promise physically exact cloth in seconds from arbitrary photo.
4. A **bounded local cognitive orchestration system** — the “Octopus” — with specialist modules, personal preferences, energy/thermal-aware scheduler, local memory, safety/privacy veto, and rigorously gated improvements.
5. **Complete retail acquisition, commercial integrations, consumer GTM, referral loops, privacy-safe analytics and testable growth economics.**

## 23.2 Seven product laws

- **The person owns the person.** All body measurements/avatar/corrections remain on-device by default. No retailer can request them through a client API.
- **The user is the gold-standard editor of subjective anatomy and style.** Photogrammetric estimates are editable suggestions, never a forced final identity.
- **Measured reality beats photogenic illusion.** Brand+variant size specs and validated measurements drive size suggestions. 3D appearance does not prove fit.
- **Fast first impression, progressively truthful detail.** Quick silhouette is not falsely labeled photoreal garment behavior.
- **Useful intelligence without mysterious collection.** The system must explain which inputs it used in simple language and let the user opt out or delete.
- **Cultural respect, not cultural profiling.** A selected city helps with weather; it does not reveal a user's cultural identity, religion, ethnicity, dress expectations or gender.
- **Evidence beats “God Level” marketing.** Honest absence of data and calibrated uncertainty are evidence of quality, not failure.

## 23.3 Explicit changes to prior assumptions

| Area | v1.1 authoritative decision |
|---|---|
| Android | Native SwiftUI/RealityKit/Core ML iOS reference product first; future Android native Kotlin/Compose + suitable 3D/NN runtime after device validation. No cross-platform promise of identical native speed without proof. Shared **protocols, asset formats, product/fit algorithms and test vectors** over premature shared UI framework. |
| Demographics | Optional age band or birth date **only if user chooses**; avoid requiring exact birth date. Age is context, not fashion rule; no age-based derogatory norms. |
| Astro/numerology | Opt-in, clearly disclosed **symbolic inspiration** only; never hidden use, never called science or a reliable fit/color/health predictor. No transfer from XRAI or other products. |
| Culture | Explicit destination/event dress-code preference (formality/modesty/custom) rather than inferring identity from locale/photos. |
| Skin tone | If user opts in, local image color sampler with lighting uncertainty plus editable palette; **never infer race/ethnicity** or label someone's attractiveness. |
| Retail websites | No bypassing bot protection, fake partner access, unlicensed extraction, protected photos or review datasets. User-visible links allowed; actual import requires terms/license/permission and source provenance. |
| Self-learning | Local ranking/feedback updates only after rules, safety and regressions; no uncontrolled background self-retraining or unsanctioned network model download. |
| Fit + photorealism | Tiered rendering; ‘same feeling as physically wearing it’ is visionary, not an achievable guaranteed simulation of stretch, weight, warmth, pressure and touch. |

---

# 24. LIVING BODY STUDIO — PRECISION MORPHOLOGY WITHOUT FORCED BIOMETRICS

## 24.1 Fundamental UX: from blank avatar to editable living silhouette

`Start model → select neutral silhouette template (or optional image-assisted draft) → enter optional height/known measurements → rotate 3D avatar → tap body region or choose Body Studio → drag ± slider or directly enter cm → see live deformation → compare side-by-side/undo → save this revision.`

- **No compulsory selfie or gender choice.** User chooses template **shape** and optional presentation rather than inferred biological sex. Neutral gray full-body cloth-like mannequin/coverage material, no nude texture, visible genital contours or sexualized controls. The chest/hip/waist sliders are neutral fit geometry controls.
- Screen splits into `model preview` (65–75% area where practical) and collapsible `adjustments tray`; the tray does not obscure the region being adjusted. Tap a highlighted body region to open only relevant controls. Pinch to zoom; drag to orbit; double tap reset camera; front/side/back preset camera chips; quick reset and undo/redo.
- Each slider has (a) descriptive name, (b) current value `± dimensionless morph` or optional calibrated centimeters, (c) increase/decrease buttons for accessibility, (d) min/max bounds defined by trained mesh topology and device limits, (e) reference-line overlay available on demand, (f) confidence/source badge (`Manuel`, `Ölçüm bandı`, `Görsel taslak`).
- **Crucial:** A slider position is a mesh deformation, **not** an accurate physical circumference in cm unless the avatar engine is *calibrated against measurement geometry*. Never print “96 cm bel” based solely on arbitrary visual dragging. A user-entered verified waist circumference may constrain the mesh; keep separate fields `visualMorph` and `confirmedBodyMeasure` with explicit consistency warning.
- Body edits change the currently previewed garment's collision/ease calculation only when genuine garment geometry exists. If garment is merely a proxy, preview still updates but its fidelity badge remains `Siluet önizlemesi`.

## 24.2 Anatomical slider and measurement register (extendable)

| Stable `parameterKey` | Turkish UI name | Axis/meaning | Source & unit | Fit effect / note |
|---|---|---|---|---|
| `stature` | Boy | overall calibrated height | manual cm, estimated photo only draft | garment length ratio; strong user source |
| `neckCircumference` | Boyun çevresi | neutral neck perimeter | user tape cm or visual morph | collars; no health attribution |
| `neckLength` | Boyun uzunluğu | head–shoulder vertical space | morph proportion | neckline rendering |
| `headScale` | Baş oranı | head size relative to body | dimensionless | visualization only; no identity recognition |
| `shoulderBreadth` | Omuz genişliği | biacromial-like width, clear landmark definition | manual cm or morph | jacket/shirt shoulder seam |
| `shoulderSlope` | Omuz eğimi | shoulder line tilt | morph | neckline and sleeve silhouette |
| `upperChestCircumference` | Üst göğüs | upper torso perimeter | user-confirmed cm / morph | tops/outerwear |
| `fullChestCircumference` | Göğüs çevresi | widest torso/bust circumference | user-confirmed cm / morph | tops/dresses |
| `underChestCircumference` | Göğüs altı | under-bust torso measure | optional cm / morph | fitted garments, optional not default |
| `torsoLength` | Gövde uzunluğu | shoulder-to-waist distance | morph/cmtape if defined | shirt/jacket hem |
| `naturalWaistCircumference` | Bel çevresi | natural-waist perimeter | manual cm / morph | bottoms/dresses; high priority |
| `waistHeight` | Bel yüksekliği | waist vertical anchor | morph | rise/hem position |
| `abdomenFullness` | Karın oranı | anterior lower torso profile | morph, dimensionless | shape not medical data |
| `highHipCircumference` | Üst basen | upper hip perimeter | optional manual cm / morph | bottom waistband |
| `fullHipCircumference` | Kalça/basen çevresi | widest hip/glute perimeter | manual cm / morph | jeans/skirts |
| `hipWidth` | Basen genişliği | lateral hip width | morph | profile silhouette, not circumference |
| `seatProfile` | Arka kalça profili | rear depth/seat shape | morph | pants seat visual fit only |
| `upperArmCircumferenceL/R` | Üst kol kalınlığı | left/right arm girth | manual cm / morph | sleeves; symmetry by default |
| `forearmCircumferenceL/R` | Ön kol kalınlığı | left/right forearm | manual cm / morph | tailored sleeves |
| `armLengthL/R` | Kol uzunluğu | shoulder to wrist | manual cm / morph | sleeve length |
| `wristCircumference` | Bilek çevresi | wrist girth | optional cm | cuffs |
| `thighCircumferenceL/R` | Uyluk kalınlığı | thigh girth | manual cm / morph | slim jeans/shorts |
| `kneeCircumference` | Diz çevresi | knee region girth | optional cm/morph | tapered pants |
| `calfCircumferenceL/R` | Baldır kalınlığı | calf girth | manual cm/morph | boots/pants |
| `legLength` | Bacak uzunluğu | hip-to-floor proportion | manual cm / morph | trouser silhouette |
| `inseam` | İç bacak boyu | crotch-to-ankle measured definition | manual cm | denim length sizes |
| `ankleCircumference` | Ayak bileği | ankle perimeter | optional cm/morph | pant cuff |
| `footLength` | Ayak uzunluğu | heel-to-toe measurement | user cm | shoe size separate; no shoe fit promise |
| `footWidth` | Ayak genişliği | max forefoot width | optional cm | shoes, future partner |
| `postureUpperBack` | Duruş/profil | relaxed/straight visual posture | morph | changes silhouette but cannot infer spinal condition |
| `hairSilhouette` | Saç hacmi/uzunluğu | selected hairstyles | template/morph | visualization; no biometric reconstruction |

**No one must see 30 sliders initially.** Default screen shows `Omuz • Göğüs • Bel • Basen • Kol • Bacak`, with “Ayrıntılı ölçüler” accordion and context-sensitive measurement affordances. Sliders are curated by garment category: jeans highlights waist/hip/thigh/inseam; shirts highlight shoulders/chest/arm; dresses highlight chest/waist/hip; others hidden until requested.

## 24.3 Physical-model calibration and shape safety

- A single global slider scaling arbitrary vertex coordinates is unacceptable: it distorts joints and causes cloth intersection. Build a consistent **canonical skeleton**, semantic body region masks and interpolated deformation targets (blend shapes/morph targets or controlled cage/FFD), preserve joint attachment, bone lengths and surface continuity.
- Blender DCC pipeline: open/licensed base mesh → topology/UV/skeleton/weight-paint → region morph shape keys → lossless test avatar presets → `USDZ` or verified supported asset pipeline → iOS render runtime. Blender is for **offline asset creation and batch baking**; it does not run inside consumer iOS app.
- Runtime deformation options: RealityKit skinned-mesh/blend-shape deformation where supported on target OS and hardware; otherwise maintain a versioned fallback mesh swap or low-complexity local geometry pipeline. The Apple mesh deformation API and deployment target must be validated against stable SDK/Xcode; no beta-only hard dependency without fallback.
- Surface constraints: no negative radii/self-intersection, no topology tear, no collapsed triangles, normal/tangent recomputation, no unintentionally exposed torso when morphing, stable ground contact, consistent garment anchoring, camera/frustum fit after stature edits.
- Subjective edits saved as immutable versioned snapshots with hashes; quick undo/redo is UI-session local, `Save model` commits a revision; revisions can be restored and deleted. App version updates never silently mutate user-authored body.
- Auto-proposed changes (e.g., image-assisted head/shoulders) appear as ghosts until `Accept`; rejected suggestions are not re-applied without explicit user action.
- `BodyProfile`: allow multiple profiles only for the same individual on a shared device if secure; third-party child profile/no-consent capture out of v1.
- Calibration test uses a synthetic parametric reference mesh with ground-truth landmark measurements and 3D geometry distances. Human measurement validation must be consensual, independently measured, demographically inclusive, holdout, and report distributions rather than guarantee an exact personal replica.

## 24.4 Runtime deformation algorithm (contract and fallback)

```text
onDrag(parameterKey, proposedValue):
  normalized = clampToSafeBounds(parameterKey, proposedValue)
  draft = BodyMorphState.with(parameterKey, normalized)
  if !topologySafetyPrecheck(draft): show safe bound, reject invalid update
  commitToRenderBuffer(draft)  // coalesce frames, don't rerun photo ML
  previewMesh = avatarMorphEngine.deform(draft, LOD=currentLOD)
  garment = garmentPreviewEngine.adjustForAvatar(previewMesh, currentGarmentTier)
  present(previewMesh, garment, fidelityDisclosure)
onGestureEnd:
  publishAccessibilityValue(); scheduleLocalSnapshot(); optionally recompute fit evidence
```

Frame-by-frame drag **never** triggers brand API, large local inference, fresh weather calls, photo analysis, model retraining or upload. The immediate feedback path is geometry/graphics only. Fit recalculation after gesture end is coalesced and source-dependent. The UI must remain responsive if recomputation is queued.

---

# 25. THE TWO VISUAL TRUTHS: REAL PERSONAL AVATAR VS PRODUCT-ACCURATE DIGITAL TWIN

## 25.1 Never collapse these different capabilities

**A. Identity-adjacent avatar:** gray mannequin whose *proportions* the user intentionally tunes. It is not proof of actual anthropometric identity. 
**B. Visual garment overlay:** mesh silhouette/texture on avatar. This is an aesthetic approximation when no technical garment asset exists. 
**C. Dimensional fit analysis:** compare measured body landmarks against source-supplied garment/pattern dimensions/ease. Can guide size independently of photorealism. 
**D. Physics-informed drape:** material/pattern/seam/stretch validation plus cloth simulation, body collision, animation and objective evaluation. Expensive; partner-limited research track, not universal v1 guarantee. 
**E. Tactile/physical feeling:** pressure, thermal sensation, textile hand-feel, flexibility, comfort cannot be completely reproduced through a conventional phone screen. Never promise identical sensation to wearing it physically.

## 25.2 Garment fidelity ladder with truthful UI names

| Tier | Input sufficient | Render | Label | Claim allowed |
|---|---|---|---|---|
| `G0` | only text/style/category | stylized generic garment placeholder | `Örnek siluet` | category and color story only |
| `G1` | photo, approximate garment segmentation, rough category | cropped texture on generic category proxy | `Yaklaşık görünüm` | general silhouette/color, not true cut |
| `G2` | partner front/back views + attribute dimensions and size chart | tailored proxy param mesh, calibrated length/shape | `Ürüne göre modellenmiş önizleme` | better proportions; not physical drape |
| `G3` | licensed per-size 3D garment asset + known authored dimensions | skinned/mesh variant with fit constraints | `3D ürün modeli` | appearance in known poses with limits |
| `G4` | validated technical CAD/pattern/cloth physics and device hardware | material-aware simulated drape + validation cases | `Test edilmiş kumaş simülasyonu` | only to tolerance and cases actually tested |

Tier label must remain visible via small `(i)` tooltip, not visually overpower screen. Unknown store clothing defaults `G0/G1`, never claimed `G3/G4` by simply running generative AI. If photo is blurry, rights unclear or catalog absent, show precise fallback and what more input would help. 

## 25.3 Digital garment asset studio

- Create authored synthetic garment templates in Blender: tee, shirt, knit, blazer/jacket, jeans, pants, skirt, dress, outerwear. Prove skinning, texture mapping, occlusion, cloth layering and pivot anchors on diverse body morph presets.
- Per product asset package: `garmentAssetId`, `sourceVariantId`, `licenseId`, `garmentCategory`, `geometryVersion`, `LOD`, `materialVersion`, `patternOrProxy`, `measurementAnchors`, `compatibleAvatarTopology`, `provenance`, `fidelityTier`, `checksum`, `expiresAt`.
- Separate **body mesh** and **garment mesh**; garment assets never carry user-specific body texture or shape into shared catalog. Mesh/shaders signed/verified; format is robust against malicious malformed assets and OOM.
- Physics: collision tolerance, anti-clipping clipping maps, dynamic constraints, mesh parameter interpolation, lighting presets, material PBR only when licensed and validated. Simpler offline-safe proxy is the mandatory fallback.
- Size changes should visibly adjust geometry when enough size-specific data exists; swapping label from M to L without changing render or explaining limitation is prohibited.
- Dramatic pose, lying/sitting, bending must be marked unsupported if deformation data not available; default honest neutral upright stance, controlled walk/turn motion only after proof.

## 25.4 Scene, city and real-world authenticity

- City/location selection can show **licensed general scene visuals** or procedural environments, not photographs of a person secretly superimposed into unlicensed scenes. Landmark depiction (e.g. Galata) must be labeled illustrative, with weather and daylight determined from timestamp where available.
- Preload a handful of **legally obtained** environment assets: neutral studio (P0), walking street (P1), café/meeting, office, evening/restaurant, rainy outdoors (P2), selected public-landmark scene (P2). No need to build an entire geospatial 3D globe.
- Weather animation is illustration (rain/wind), not certified weather truth; never simulate exact future location lighting as guaranteed. Provide studio compare mode to avoid distractions when evaluating cut.

---

# 26. GLOBAL BRAND & FIT KNOWLEDGE GRAPH: PROVENANCE FIRST

## 26.1 What is actually identifiable in a store?

Recognition ladder: **EAN/GTIN scan** → authorized partner variant → correctly matched size/color/collection/country → official technical chart → fit recommendation. Without exact GTIN: visible label/OCR and logo brand candidate → user confirms product style/size → authorized searchable partner catalog → multiple candidates with confidence. **Similar looking shirt is not necessarily the exact SKU.** Different production runs/markets alter dimensions; no brand-global sizing assumption.

Brands requested as **priority discovery queue, not existing partners or unlocked APIs**: LC Waikiki, Mavi, Levi's, Jack & Jones, Hugo Boss, Calvin Klein; later: Koton, DeFacto, Zara, H&M, Mango, Nike, Adidas and category specialists. All partner names remain reference brands only until executed agreements. For Levi's, manufacturer-published waist/hip/inseam size-guide examples support need for actual category-specific charts, not authorization to scrape or redistribute them.

## 26.2 Catalog hierarchy and permissible acquisition

1. **Signed partner feed/API**: contract permits product attributes, size systems, measurements, licensed images, asset cache, freshness and display rights; priority S0.
2. **Retailer-authorized export** (CSV/JSON/ERP/PIM/POS/Shopify-compatible connector, public partner feed with written permission); S1.
3. **Rights-cleared third-party catalog/affiliate data**: permitted fields and conditions; S2.
4. **Official public web page viewed with user action / user-provided product URL**: may provide user-facing link; automated copying/reprocessing/photographs require applicable right and terms review; S3, not automatically a production source.
5. **User photograph of owned item/store tag**: ephemeral local OCR; no assumption of copyright to republish marketing imagery; S4.
6. **Visual ML guesses**: low confidence, no guarantee of exact product/size/fabric; S5.

Google Merchant Center Merchant API requires authenticated **merchant-granted access** and cannot be treated as open catalog of all brands. Where catalog available, map group+variant fields such as item group ID, size, color, material, size system, GTIN; inventory may be different freshness. GS1 ID alone is a lookup key, not full textile spec.

**Prohibited:** unauthorized credential usage; scraping despite contractual prohibitions; bypassing robots/anti-bot; collecting customer reviews without rights; copying customer photos; finding protected merchant API credentials; presenting invented partner data as verified. Legal review of terms is a work item, not an afterthought.

## 26.3 Variant-specific knowledge graph schema

```json
{
  "brandId":"mavi-reference-id-not-partner",
  "catalogRights":"DEMO_ONLY",
  "styleId":"jeans-regular-x",
  "variantId":"style-x-blue-w32-l32",
  "gtin":"OPTIONAL_VERIFIED_GTIN",
  "market":"TR",
  "category":"denim_jeans",
  "targetCut":"regular_straight",
  "merchantSize":{"display":"W32/L32","system":"brand_denim_WL"},
  "bodyChart":{"waistCm":{"min":null,"max":null},"hipCm":{"min":null,"max":null}},
  "garmentMeasurements":{"waistFlatCm":null,"inseamCm":null,"thighFlatCm":null,"legOpeningCm":null},
  "fabric":{"composition":[],"stretchClass":"UNKNOWN","weightGsm":null,"shrinkTolerance":"UNKNOWN"},
  "evidence":[{"kind":"MANUFACTURER_SIZE_CHART","sourceId":"not-yet-connected","effectiveAt":null,"licenseId":null}],
  "previewAsset":{"tier":"G0","id":null},
  "isDemonstrationData":true
}
```

- Separate wearer/body circumference from *flat garment* measurements; `flatWaistWidth × 2` may not equal comfortable wearable waist because of cut, rise, fabric stretch, elastic, curvature and measurement conventions. Define unit/measurement method for every value.
- `BrandSizeChart` scoped by market/sex-based retail department label **when manufacturer uses one**, category, season/model, variant, size system, effective dates; user's personal gender is not assumed from retailer department.
- Knowledge graph associations: `Brand → Collection/Market → ProductStyle → Variant(GTIN/size/color) → GarmentSizeSpecs → SourceEvidence → RenderAssets → WearerFitFeedbackAggregate` with stable IDs and provenance.
- Content hash/version, expiration, supersession, source dispute/quarantine and consistency validators are mandatory. Retain evidence chain for every recommendation.

## 26.4 Fit engine: deterministic constraints + calibrated learned residuals

```
fit(productVariant, bodyProfile, desiredEase, wearerFeedback):
  0. Validate product identity and source rights/freshness.
  1. Verify measurement semantics and units (cm/in, flat/circumference, rise etc.).
  2. Identify fit-critical landmarks per garment category.
  3. Select user-entered confirmed measurements. Morph-only values are visual.
  4. Infer permissible range of ease for exact cut/material/fit preference using
     authored garment rules; if unsupported keep UNKNOWN.
  5. Evaluate each available size independently for impossible tightness,
     plausible room, length, desired ease, and uncertain elastic properties.
  6. Optionally combine calibrated anonymous permitted size-feedback trends as a
     *weak* prior, never overriding verified manufacturer specs arbitrarily.
  7. Return 0–2 supported suggestions; include size-system, source, timestamp,
     missing dimensions and a human explanation; else abstain.
```

No “%98 fits” or ``same on-body look`` unless independent calibration supports it. `S/M/L` is not internationally stable. Shirts: collar+shoulder+chest+sleeve. Denim: waist+hip+thigh+inseam+rise+stretch. Jackets: chest+shoulder+sleeve+layering. Dresses: full chest+waist+hip+length+cut. Shoes: separate domain with foot dimensions.

## 26.5 Review intelligence: permitted, aggregated, explainable

Only ingest **licensed, explicitly permitted** reviews or voluntary opt-in feedback. For per-product fit signals extract evidence-attributed attributes: `runsSmall`, `runsLarge`, `accurateSize`, `tightShoulder`, `waistLoose`, `sleevesShort`, `stretchy`, `seeThrough`, `materialHot`, `afterWashShrink` with per-label precision tests. Ignore photos/private demographic inference; redact PII and hate content. Retain review rights/version and deletion requests. Do not infer someone's true body shape from review texts. Review statistics require sample size and coverage; an isolated review is weak evidence.

Example: “Bu modelin omuz bölgesinin dar olduğuna dair yeterli, hakları doğrulanmış kullanıcı verisi yok” should be shown instead of inventing aggregation. If reviews disagree with chart, label `CONFLICT`, allow user to compare both and recommend a physical check.

## 26.6 Source disagreement resolver

```
SOURCE_VETTED → MEASUREMENT_SEMANTICS_OK → SIZE_SYSTEM_MATCH →
USER_MEASUREMENTS_CONFIRMED → WEIGHTED_EVIDENCE → FIT_RESULT
                           ↘ unresolved conflicts → ABSTAIN + explain
```

Hard safety rules outrank crowd feedback. Product dimension staleness, wrong country chart, counterfeit label, size chart category mismatch or shared GTIN ambiguity => fail closed. Footwear, underwear, compression wear, maternity/medical garments and protective equipment require distinct policy and staged authorization; no fit certainty from generic rules.

---

# 27. <SECONDS> TRY-ON EXPERIENCE / PERFORMANCE CONTRACT

**Architectural objective:** The user should receive a **useful stage** within seconds for supported local cached assets. This is **not** the claim that every internet-unknown SKU becomes a physically accurate, photo-real 3D garment model in seconds. Latency SLOs are **targets until measured on named devices, not achieved performance**.

| Stage | Indicative goal for supported devices* | Work | Fallback |
|---|---|---|---|
| L0 camera scan feedback | p95 within ~0.5 s after readable frame* | Vision/barcode frame | user enters text/GTIN |
| L1 product identity | p95 ≤ 2 s **cached licensed record** | validated lookup | `Aranıyor` with OCR/manual candidate |
| L2 first visible garment preview | p95 ≤ 3 s **prepackaged generic proxy, warmed engine** | select body mesh+G0/G1 garment | static silhouette immediately |
| L3 partner-specific G2/G3 | tier-conditional, separately measured; 3–10 s **experiment goal only** | downloaded/cached verified 3D asset | G1/G2 with fidelity badge |
| L4 cloth physically plausible | no user-facing universal seconds promise | material-aware simulation / QA | G2/G3; not a blocker to basic try-on |
| Morph drag | UI target 60 fps capable devices, fallback 30 fps; input-to-photon p95 tuned by device* | cached mesh interpolation | reduced LOD / frame coalescing |

`*` Hypotheses to be profiled on entry-tier supported iPhone, 2–3 representative mid/high tier devices, normal/low-power and thermal `fair/serious`, offline/slow network, cold/warm caches. Never print numeric performance as achieved until device evidence exists.

**Critical path design:** barcodes lightweight -> local normalized key -> encrypted/private avatar in memory -> precompiled/shader-warmed category garment mesh -> first preview; catalog asynchronous; available product detail enriches scene incrementally. The ML recognizer must not freeze the first frame. Preload one neutral avatar and popular generic garment assets at app idle within battery budget; do not prefetch unknown store catalogs without consent. Cancel stale scan requests; avoid GPU readback. For unknown SKU: immediate `Önizleme yaklaşık`, not a fake photoreal texture.

**Device scheduler:** `ProcessInfo.thermalState`, `isLowPowerModeEnabled`, camera activity, active interaction, memory pressure, available storage, visible screen, user's selected battery-sensitive settings, network reachability and explicitly approved cellular policy influence work queue. Core critical UI first; heavy gallery scanning and model updates only when safe/foreground or permitted OS scheduling. `critical` thermal -> stop nonessential camera/3D/ML and present respectful resume message; do not keep a hidden scanner alive. Download models and large assets primarily on Wi-Fi unless opt-in. The app should never claim direct control of battery health or hardware temperature, only adaptive usage.

**Memory/performance:** Per-model memory budget set by measurement, not arbitrarily; include resident model sizes, cold load times, peak RSS, battery draw estimate, thermal transitions, frame times p50/p95/p99, dropped frames, scan accuracy vs speed. If assets are too large, use LOD/texture compression/streaming and precomputed skeletal morph targets. Surface capabilities by device tier; no automatic denial of all functionality on older supported devices.

---

# 28. OCTOPUS COGNITION — LOCAL SPECIALIST MODULES + SINGLE ACCOUNTABLE BRAIN

## 28.1 Principle

The “octopus” is a metaphor for **independently testable specialist capabilities coordinated by one local policy-aware orchestrator**, not a collection of uncontrolled LLM agents running in parallel or constantly sending personal data to servers. **Every arm has an explicit input contract, output contract, permissible actions, power budget, evidence level, degradation and deletion rule.** A single visible explanation surface tells the user **why** an outfit/size was suggested.

## 28.2 Arm inventory / owners

| Arm and contract ID | Responsibility | Allowed inputs | Output | Must not do |
|---|---|---|---|---|
| `OCT-01 PrivacySentinel` | gate all data flows and retention | per-feature consents, data classes, device policies | allow/deny + audit reason | silently expand permissions |
| `OCT-02 DeviceSteward` | thermal, RAM, energy and scheduler | platform resource status, task priority | work budget, pause, LOD | overrule safety or background policy |
| `OCT-03 VisionWardrobe` | identify garment category/color/crop/dedup | only selected/authorized local photos | local wardrobe candidates | retain bystander faces or upload source |
| `OCT-04 MorphIdentity` | morphs, calibration and user corrections | local body inputs/asset geometry | safe param mesh + uncertainty | claim exact measurements from image |
| `OCT-05 CatalogResolver` | product GTIN/SKU/version resolver | label, barcode, authorized catalog | product variant + provenance | fabricate product ID or scrape without right |
| `OCT-06 PatternFit` | pattern/size/ease decision | confirmed body measures + approved SKU data | fit verdict + evidence | guarantee physical comfort |
| `OCT-07 RenderStudio` | LOD 3D, proxy garment, lighting, pose | body mesh, licensed garment assets | rendered frame + fidelity tier | fake G4 from photo |
| `OCT-08 ClimateStylist` | weather/time/activity/fabric layering | selected city/date/activity, wardrobe | compliant weather outfit candidates | present stale weather as current |
| `OCT-09 CreativeDirector` | palette, silhouette, mood, occasion | user-declared aesthetic preferences, selected image colors | diverse outfits + readable rationale | beauty/body scoring or identity stereotypes |
| `OCT-10 CareWardrobe` | wear, laundry and availability | user-tagged wear and care records | clean/uncertain/laundry advice | claim item is physically dirty from elapsed days |
| `OCT-11 FeedbackLearner` | local preference fitting and safe updates | explicitly given corrections/ratings | versioned personal ranking | unsupervised destructive retraining |
| `OCT-12 SymbolicInspiration` | **opt-in** astrology/numerology style prompts | explicitly supplied DOB or locally derived symbols | optional color/mood inspiration tagged non-scientific | covert affect/identity/fit decision |
| `OCT-13 ExplanationQA` | provenance, consistency and uncertainty veto | other arms' structured evidence | user explanation, abstention | invent source or mislabel preview |
| `OCT-14 RetailBoundary` | minimum anonymized business query/metrics | public catalog key, partner access token | product-only lookup; aggregate retailer metrics | transmit exact body, DOB, photos, local style history |

**Explicit rejected pattern:** 14 on-device foundation LLMs permanently active. Most arms are deterministic Swift modules, local Core ML models or RenderEngine tasks, not chatbots. An optional small local language model is only approved after measurable improvement over templated explanations, with resource and hallucination gates. Front-end remains deceptively simple.

## 28.3 Orchestrator event/data flow

```text
USER ACTION / FOREGROUND EVENT
     ↓
PrivacySentinel(consent, local data class) → DENY OR PASS
     ↓
DeviceSteward(priority, thermal, memory) → resource budget / defer
     ↓
Domain request routing (typed immutable messages, cancellation tokens)
   ├─ Photo → VisionWardrobe → user review → local wardrobe vault
   ├─ Body sliders → MorphIdentity → RenderStudio → interactive frame
   ├─ Barcode → CatalogResolver → PatternFit → RenderStudio
   └─ Event/day → ClimateStylist + CreativeDirector + CareWardrobe
                     [SymbolicInspiration only if opted-in]
     ↓
ExplanationQA(verifiable evidence, capability and confidence)
     ↓
PERSON: visible result / correction / explanation / delete / revert
     ↓
FeedbackLearner(versioned local preference update, never hidden)
```

Every domain object has `value, confidenceClass, provenance[], inputVersion, modelVersion, createdAt, expiry, permissionsUsed`. Internal access only to fields needed; the policy layer must be central and testable even when tools/agents misbehave. Use actors/structured concurrency and bounded worker pools, never unlimited queues. Durable event journal excludes sensitive source images. 

## 28.4 Decision protocol and explainability

```
StyleDecision {
  selectedClosetItems[]; suggestedPurchases[]; occasion;
  factualReasons[]; preferenceReasons[];
  evidenceRefs[]; excludedCandidates[];
  unknowns[]; confidenceClass; usedSymbolicInspiration: Bool;
  latencyMs; algorithmVersion;
}
```

Consumer default microcopy: “18° ve yağmurlu: nefes alan iç katman + suya dayanıklı dış katman. Bu ceket temiz olarak işaretli. Bedende kesinlik için etiketi kontrol et.”

Tap `Neden bunu önerdin?` for `Hava / Tarzım / Dolabım / Ürün verisi / Sembolik ilham` provenance. Personal data and hidden heuristics do not become opaque persuasive tactics. Supplier-paid promotions are labeled and do not alter fit verdict.

---

# 29. LEARNING WITHOUT LOSING CONTROL — PERSONALIZED LOCAL EVOLUTION

## 29.1 Three separate improvement mechanisms

**(I) Immediate deterministic preference updates:** User says `dar`, `rahat`, `bu renk hoşuma gitmedi`, `bugün giydim`, `yıkamaya girdi`, `bu modelin belini düzelttim`. Persist local events, update the personal style state and re-rank next outfit. Easy to undo, inspect and erase. No ML training needed.

**(II) Bounded local ML fine-tuning:** Only if a genuinely *updatable* Core ML model is selected and benchmarked. Consent and available training data required. Train from user-labeled examples on safe schedules; run candidate vs baseline on untouched local validation; only commit improvement if no privacy/quality regressions. `MLUpdateTask` is supported for appropriately configured models, not an automatic capability of every Core ML model.

**(III) Audited product-wide model upgrades:** Developers curate rights-cleared datasets, validate held-out accuracy/fairness/security/performance, sign the model manifest, ship App Store app/model update via legal distribution path; feature flags+rollback. Updating user's local models never implies exporting their private data. Federated learning and differential privacy are **research options**, not default proven privacy guarantees.

## 29.2 Non-negotiable local learning gates

```
OBSERVATION
 → user explicitly confirms or corrects
 → local candidate update
 → schema/model compatibility check
 → privacy + fairness + energy check
 → A/B vs frozen baseline / replay validation
 → accept improvement OR reject
 → append versioned user-visible change log
 → rollback in one action
```

Disallow silent rewrites of manually confirmed measurements, DOB, skin palette, consent, explicit excluded styles, wardrobe ownership or garment truth. Training on nonconsenting bystanders, body images, retail purchased histories for ad targeting, or transferring personal states across products is forbidden. No continuous background loop: OS allows bounded opportunities and users control battery/network. Local learning can stop indefinitely without breaking the app.

## 29.3 Expert stylist as creative domain logic, not omniscience

A professional styling taxonomy shall be authored with qualified stylists/pattern makers: color relationships, saturation/contrast/undertone with opt-in, silhouette balance, texture/material pairing, layering, occasion formality, activity comfort, weather, cultural **self-declared** requirements, mobility, clothing access and sustainability. Each rule gets source, scenario, exclusions, case examples, measurement and user override. Personal tastes outrank rigid fashion orthodoxies. Multi-candidate diversity prevents one-size-fits-all aesthetic stereotypes. “Most beautiful/ideal body” classifiers are prohibited.

**Feedback test:** `sample body/style → context → 3 candidates → expert blind comparative ratings + user preference` using consenting users. Score decision *usefulness and explanation*, not an objective “beauty percentage”. Track mismatch and opt-out.

---

# 30. THE PERFECT STYLIST INPUT POLICY — AGE, CULTURE, SKIN TONE, ASTRO, OCCASION

## 30.1 User-understood input layers

**Core (P0):** desired occasion, time, city (manual allowed), activity and dress code, weather, garment availability/clean state, user favorite/avoided colors and cuts, outfit history. 
**Optional (P1):** age band or birth date, hair style silhouette, voluntary approximate skin-palette sample, fit/comfort preferences, meeting significance, culture-specific dress rules **explicitly provided by user**, personal calendar event manually selected and summarized locally (never silently read full calendar). 
**Symbolic (P2):** opt-in astrology/numerology inspired color or mood prompts, with a clear explanation. No default hidden astrological personalization.

Questions should be as human as “Nereye gidiyorsun?” / “Nasıl hissetmek istersin?” / “Rahat mı, daha resmi mi?” / “Kendini burada nasıl görmek istiyorsun?” rather than personal-data questionnaires. Avoid ageist dress rules (“30 yaşını geçtiğin için giyme”). Do not deduce religion, ethnicity or cultural identity from GPS or skin color.

## 30.2 Occasion types and dress intelligence

Registry: work/office; job interview; first date; romantic dinner; school/university; graduation; wedding attendee; wedding party; family visit; religious/cultural ceremony **only if stated**; sports/outdoor; festival/concert; brunch/café; travel/airport; formal presentation; beach/hot weather; rainy commute; night out; business casual; at-home. For each: declared dress-code, exposure to outdoors, temperature variability, mobility, sitting/walking duration, shoe comfort, layering, weather, garment cleanliness, and formalness, with outfit explanations and alternatives. No inferred safety/health claims.

## 30.3 Skin/hair and color recommendations

If user chooses `Renk önerilerini kişiselleştir`: optional user-selected photos or live camera sampling **on-device**, suggest broad illumination-robust palette with color-temperature uncertainty, let user manually select what looks right. No face recognition or face embedding necessary; pixel sampling from selected area with transient exposure. Mixed lighting/filters/makeup may defeat color estimations; never guarantee undertone classification. All palette processing optional, revocable, confined to device, no skin-ethnicity estimation. Accessibility: do not rely on color alone; explicit labels and high-contrast mode.

## 30.4 Birthdate and symbolic layer: transparency required

- User requests birthdate-based age and symbols. Offer `Yaş aralığı` and `İsteğe bağlı doğum tarihi` as distinct inputs. For routine age-aware event logic, retain only age band rather than full birth date when possible; user can delete all symbolic inputs separately.
- `Astroloji ve numeroloji ilhamını kullan` OFF by default; dedicated consent, non-scientific disclosure, concise purpose, on-device calculation only. Display `İlham kaynağı: sembolik stil seçimi` if it influenced anything. 
- Never hide use simply because user asked “belli etmeden”: **subtle, beautiful UX is allowed; undisclosed inferred profiling is not.** A professional app can keep the presentation elegant while being honest in Settings and “Neden?” details.
- `SymbolicInspiration` can only modestly re-rank visually equivalent outfits/colors if safety/weather/garment fit is not worsened, and must not assert that astrology/numerology objectively determines which clothes fit or attract success.
- This feature must work without importing XRAI datasets; no data sharing without new explicit purpose-appropriate consent and separate legal design.

## 30.5 Clean/worn control

Wear event ≠ dirty verdict. The app never knows sweat, stains or hygiene from calendar days. Optional user tagged: `Temiz`, `Giyildi—kontrol et`, `Havalandır`, `Yıkamada`, `Dolaba döndü`. Proactive nudge if worn on consecutive days: “Bu parçayı tekrar kullanmak ister misin? Temizliğini sen kontrol et.” No automatic negative judgment of the person or recommendations based on unfounded assumptions.

---

# 31. UX/UI EXTENSION — ONE-GLANCE PRODUCT WITH DEEP BODY LAB

## 31.1 IA (top-level remains minimal)

Four tabs maximum: `Bugün`, `Dolabım`, `Dene`, `Ben` — optional swipe segmented views within; no giant wall of AI tool names. The intelligence exists below the surface, not as 14 scary bots. Primary screen should answer **what should I wear today?** and **can I quickly try this item?**.

### Critical new screens and states

| Screen ID | Surface & task | Key interactions | States and accessibility |
|---|---|---|---|
| `UI-B01` | Create My Model | select neutral shape, optional selfie, height, direct privacy explanation | no photo path required; no gender forced |
| `UI-B02` | Living Body Studio | tappable 3D body, region sliders, ±, undo/redo, front/side/back, clothes on/off only with safe mannequin | VoiceOver slider semantics, large increment controls, thermal degrade |
| `UI-B03` | Precision Measurements | optional measured cm, source badges, tapemeasure guide, warning mismatch with visual morph | user-manual; no fake cm estimate |
| `UI-B04` | Compare Revisions | before/after side-by-side synchronized camera, restore/cancel | no auto-save during accidental drag |
| `UI-T01` | Instant Scan | center framing, detected barcode/OCR, brand/variant uncertainty, no tracking indicator | denied camera → manual SKU & photo picker |
| `UI-T02` | Product Identity Check | possible matches, choose correct style/color/size, source details | ambiguous → user picks, never fabricate |
| `UI-T03` | Try-on Stage | avatar+product, instantly show G0/G1 then optional richer asset, size controls, rotate, back view | offline cached, slow connection, render fallback, visible G-tier |
| `UI-T04` | Size & Fit Evidence | suggested 0–2 sizes, labeled sizing source, body measurements used (only on phone), unknowns | no size chart → honest abstain |
| `UI-T05` | Fabric/Cut Inspector | material, stretch, cut, thickness, shrink risk only if evidenced | contradiction details, no invented spec |
| `UI-T06` | Compare Sizes/Brands | two product variants or sizes, same camera/body for fair comparison | show missing info, no brand bias |
| `UI-S01` | Occasion Composer | where/when/formality/feeling, weather, self-declared dress constraints | manual city/time no permission needed |
| `UI-S02` | Mood/Palette Preferences | palette and outfit inspirations, optional camera color analysis | opt-in / disable / delete |
| `UI-S03` | Recommendation Why | facts vs tastes vs symbols vs promotion, source drilldown | clear labels, minimum tap count |
| `UI-S04` | Symbolic Styling Settings | OFF by default, opt-in DOB, delete and separate purpose toggle | can turn off without losing outfits |
| `UI-R01` | Partner Scan Badge | store partner catalog verified, scanned variant TTL, no personal data visible | offline/unpartnered store path |
| `UI-R02` | Privacy & Data Controls | separate gallery/photos/body/location/age/symbols/retail consents, delete locally | test revocation and deletion |

All existing v1.0 UI layouts and design tokens still apply. The above extends them, not replaces them. No surprise mandatory account sign-up. Hero copy avoids medical language, body beauty rankings, “perfect body” messaging or guarantee that no fitting room is needed. 

## 31.2 Visual language and interaction specifics

- **Body editor:** a calm neutral graphite background vs warm-gray avatar, subtle gold/soft-blue focus outline only as interaction; tactile slider track, not anatomical sensual emphasis. Ensure WCAG-compliant text, reduced-motion, high-contrast alternative, small-screen layout and Dynamic Type for controls. Do not use accent red/green as sole confidence cue.
- Motion: changing selected body zone smoothly crossfades highlight; updating geometry must be continuous even while user pans camera; haptics light on slider detent and undo; no loud sound. Avoid aggressive gamification of body change.
- Interactive slider UI behavior: `tap body area` → contextual controls, `drag slider` → active live morph, `hold ±` → controlled increments, `type value` → if confirmed cm known then explicit mode, `double tap value` → reset local region, `Undo` and `Before` → restore.
- No “sex/gendered anatomy sliders.” Breast/chest circumference is fit geometry without sexualized texture. Garment department filters may be chosen on browsing, independently from any user identity field.
- `Confidence capsule`: “Ürün doğrulandı” / “Yaklaşık görsel” / “Beden tablosu yok” / “Deneyerek doğrula” are neutral, not high-pressure. 
- Product compare should normalize visual zoom and scene light; otherwise users misinterpret differences caused by camera position.

## 31.3 Example micro-journeys

**A. Without gallery access:** open app → choose model template → enter optional height → fine-tune waist/shoulder in studio → add one garment from camera → manually tag → same-day outfit. 
**B. At Levi's shop:** barcode → partner licensed? if yes exact variant → ask for waist/hip/inseam *only if missing and necessary* → display candidate size evidence → display G-tier on avatar → “Gerçek deneme gerekebilir” → optional owned item / shop page. If no partner, fall back to user-visible size guide + manually entered label values without false precision. 
**C. First date tomorrow:** user selects city and evening outside→in, selects style/mood, local weather→layer-compatible options, avoid laundry items; one-tap outfit and plan; optional symbolic personalization only if opted in. 
**D. Low battery:** quick store scan still possible at reduced graphics; optional gallery batch paused; privacy audit local; user never sees unexplained battery drain.

---

# 32. RETAIL GO-TO-MARKET: HOW TO WIN BRANDS AND STORES

## 32.1 B2B product is measurable operational software, not “look, 3D!”

**Retailer pains to validate** (not assume universal): fitting-room queues, staff handling overhead, shopper indecision, wrong-size purchase/returns, online/offline inconsistency, missing product attributes, excess store traffic load. For a retailer, the value is proven on **specific SKUs, conditions, store layouts and shoppers**; not all customers will skip try-on. 

**What partner receives:** Retail Dashboard with product/catalog quality scores, anonymized aggregated scans and candidate sizes by product without person-level body, opt-in usage funnels, fitting-room queue study outcomes, product feed validation, and experiment cohort analysis. No raw body measurements/photo/avatar/disclosed birthday/astrological state. 

**Partner integration options** (in order):
1. `Lite feed pilot`: simple CSV/JSON product variants + licensed images + size chart + pilot GTIN. Lowest barrier for boutiques.
2. `PIM/ERP Sync`: partner-approved catalog imports, versioned returns, failures surfaced, inventory optional. Validate SKU/GTIN uniqueness.
3. `Store link/QR`: signage/QR pointing to WEARFORM verified preview with explicit catalog licensing, no Wi-Fi tracking or hidden person linkage.
4. `Retail Console`: tenant-specific catalog QA and aggregated experiments; staff has no access to personal consumer body data.
5. `Enterprise SDK/API` (later): embedded try-on inside retailer apps, strict process boundary, audited privacy SDK without remote body transmission, commercial SLA, kill-switch.
6. `Technical garment pipeline`: vendor-provided CAD/3D garment size variants and fabric metadata under license to improve G3/G4. Contractually secure rights and usage permissions.

## 32.2 Founder outreach sequence and agreement plan

`Partner shortlist → commercial discovery → evidence packet → permission & security checklist → scope contract → 100–500 licensed variants (pilot hypothesis, partner-dependent) → 2–4 week baseline → limited controlled deployment → independently measured impact → renewal decision`.

- **Phase A**: One small cooperative fashion shop (can iterate GTIN/SKU and test body data boundary). **Phase B**: Local chain store/retailers in the same city. **Phase C**: Approach brand HQ/product teams for model-specific size/drape data. Do not imply existing LC Waikiki/Mavi/Levi's/J&J/Hugo Boss/CK agreements.
- Roles to identify: e-commerce director, retail operations manager, PIM/ERP integration lead, legal/privacy officer, merchandising/product development lead, procurement and marketing. Technical fit data often originates with **pattern makers and production tech packs**, not a marketing web page.
- Pitch 30-second logic: “Müşteriniz ürünü okutur, kendi telefonundaki gizli avatarında görür, mevcut beden tablonuzla en olası bedeni anlayabilir. Siz müşteri vücudunu görmezsiniz. Bir pilotta kabin kuyruğu, karar süresi ve iade etkisini birlikte ölçeriz.” 
- Required partner assets: verified brand ownership/authorized representative, terms of catalog/media/size-chart usage, region/currency/date rights, API key and scopes, cache/update limits, per-SKU measurements, video/photo license, product removal process and data-protection commitments.

## 32.3 B2B contracts and negotiation cards

| Contract module | Required commercial/legal decision |
|---|---|
| Data processing & roles | controllers/processors/independent controllers by function, minimum access, retention, lawful basis |
| Product rights | display/transform/cache licensed garment imagery/CAD/technical charts; territories; revocation and takedown |
| Data quality SLA | variant keys, chart completeness, sizing method, update cadence, known errors and dispute procedure |
| Security | tenant isolation, authentication/authorization, audit logs, incident notice, penetration testing |
| No-body-data commitment | no raw measures, photos, derived personal fit vectors in network or partner exports; client-side computation |
| Pilot | stores, dates, KPI definitions, control groups, consent/signage, who collects queue data, thresholds |
| Pricing | setup/import/support costs, trial period, per store/SKU/API call SaaS structure, enterprise custom SLA, no guaranteed financial benefit |
| Exit and portability | catalog removal, data deletion, export of partner-owned inputs, user autonomy from partner app |
| Legal review | KVKK/GDPR, consumer protection, marketing claims, copyright/trademark, retailer terms |

## 32.4 Pilot design and cause of queue change

**Primary experimental question:** For eligible products and participating customers, does providing WEARFORM lower *unnecessary* cabin usage and time-to-decision without lowering satisfaction/raising returns?

- Measure baseline and controlled test for comparable days/hours/season/store footfall, with control groups or stepped rollout; don't just compare a quiet Tuesday to a busy Saturday.
- Record **aggregate counters**: actual fitting-room arrivals/queue waits, median and p90 duration, foot traffic, scanned candidate products, self-reported decision confidence (optional), purchase conversion if retailer can measure privacy-preserving, returns over sufficient follow-up, store staff time, problem incidents. Report measurement bias: only tech-savvy users opt in, promotional confounders, category and traffic effects.
- `Queue reduction % = (baseline eligible queue demand – adjusted treatment queue demand) / baseline eligible demand`, with control adjustment and uncertainty interval; do not attribute all changes to the app.
- Critical negative test: shoppers follow false fit guidance → increased returns/rework. This can invalidate the rollout even if queue shortens.
- **Privacy:** Retailers receive only sufficiently aggregated, thresholded data; small-cell suppression and no timestamp-location quasi-identification. Aggregation claims require technical proof; no user-specific event trail.

## 32.5 Brand partnership roadmap

`Local authorized retailer data → one brand category with documented size chart → style-specific fit validation → enriched garment CAD feed with tech packs → optional in-store signage/QRGateway → national retailer pilots → regional expansion → licensed marketplace integrations.`

B2B sales cycle may be long; maintain consumer utility even with zero signed partners. Retailer must never gate personal closet access or user-provided photos. Distinguish consumer product-lookup cache from privileged partner feeds.

---

# 33. CONSUMER MARKETING, GROWTH LOOPS, REVENUE AND COMMERCIAL DEFENSIBILITY

## 33.1 Consumer “aha” and acquisition

Strongest demonstration: **scan a real product → instantly see plausible silhouette on own adjustable avatar → see credible size-guide evidence or transparent uncertainty**. Secondary sticky value: **tomorrow's outfit from what you already own**, with weather and laundry-awareness.

Go-to-market channels to test independently: short before/after scan explainer with synthetic/demo avatars, store QR co-marketing, microcreator fashion educators, university/city style challenges based on outfit ideas (not body ideals), referral to garment collection/template (not private body), SEO search for brand size guides where allowed, partner announcements, App Store product page, organic wardrobe digitization guides. Never show someone's body data or private photo as viral bait.

**Conversion funnel:** `App Store discovery → install → no-login first useful result → optional avatar save → first outfit → first store scan → second weekly use → referral/shop partner` with consented coarse measurements; zero-data analytics path remains fully functional. Focus on time-to-value, not aggressive notifications.

## 33.2 Growth loop engine (hypotheses, not guaranteed virality)

1. **Outfit Share Loop:** User builds outfit → creates a **privacy-safe composition** (garment thumbnails, generic avatar or user chosen render; neutral background; no body dimensions/DOB/coordinates) → exports share card by explicit action → viewer sees product utility → installs app. Share preview is inspectable before export.
2. **Retailer QR Loop:** Retailer places approved signage → shopper scans product → useful fit/preview → retailer sees aggregate experiment value → more product-data completeness → more shoppers. Requires genuine permission and proof.
3. **Wardrobe Value Loop:** More accurately categorized clothes + accepted outfit feedback → better everyday suggestions → more engagement and items organized. Avoid turning into endless photo import workload.
4. **Size Accuracy Loop:** User manually confirms optional fit outcome → local model learns individual preference; only **voluntary appropriately consented** aggregated fit outcome outside device if the privacy architecture/purpose is approved and users may still use everything without it. Default zero export.
5. **Creative Inspiration Loop:** Stylish occasion templates (public/editorial rights-cleared) → user customizes own wardrobe → optional share → peer discovery. Never rank human bodies.

**Experiment hierarchy:** correctness and privacy > first scan usefulness > retention > referrals > monetization. K-factor calculation only after attribution is lawful and real event data exists. No fake badges or manufactured scarcity.

## 33.3 Pricing hypotheses and sanity math

Consumer: core avatar/body sliders, basic wardrobe and free outfit planning should be available without payment to prove value. Potential premium after validation: higher catalog coverage, expanded scene packs, bulk wardrobe management, advanced fit comparisons, styling collections, planning features. **Never paywall data export/delete/privacy or exact-fit disclaimers.**

B2B: fixed monthly SaaS per store or partner group; setup/integration fee if real cost; enterprise catalog/API tier and separate licensed 3D asset conversion service. Affiliate payments only with clear label, separate from fit ranking. Avoid forcing commission per item if retailer's own sale attribution is weak; start with repeatable pilot fee or limited proof-of-value contract where commercially appropriate. 

Model baseline equations:

```
Revenue_month = activeConsumerPremium * ARPPU + sum(partnerMonthlyFees)
                + validIntegrationFees + explicitAffiliateRevenue
GrossMargin = (Revenue_month - variableCloudAndPartnerCost - supportCost
               - royalties - paymentFees) / Revenue_month
RetailValue = eligibleSalesReturnSavings + staffMinutesSaved*hourlyCost
              + optionalConversionLiftGrossMargin - partnerDeploymentCost
PaybackMonths = CAC / max(positiveContributionPerCustomerMonthly, epsilon)
```

No imaginary CAC/LTV, retailer returns or usage metrics. Inventory of real price/metered GPU/3D authoring costs must be obtained before quotes. Use simple sensitivity scenarios with clearly stated assumptions.

## 33.4 Defensibility test

Not defensible: use of AI, a nice avatar, sliders, dressing recommendations, user reviews alone. Potentially defensible after execution: **deep signed SKU-specific manufacturer quality, consistent local morph-to-garment geometry pipeline, independently validated fit outcome datasets with rights, exceptional privacy trust, low time-to-value, long-term wardrobe preference continuity, real partner distribution**. No false moat claim before data.

---

# 34. PRIVACY, ETHICS, LEGAL, RELIABILITY — HARD REFINEMENTS

## 34.1 Sensitive data and market policy

- Whether a particular body-image/measurement workflow legally qualifies as biometric data depends on purpose and identifiability; treat it as **high-sensitivity personal information by design**, complete DPIA/impact assessment and counsel review before launch. **Do not claim every numeric body measurement is automatically statutory biometric data**, nor that device-only processing magically removes all legal duties.
- Turkey: KVKK's special-category data framework includes biometric information and certain **dress/clothing** data; legal interpretation of the exact use, nature and storage requires qualified local counsel. The product must satisfy proportionality, purpose limitation, revocation, security and deletion.
- EU operation, if any: examine GDPR personal data/biometrics, transparency, automatic profiling, consent, DPIA where applicable, data subject rights and cross-border transfers. No marketing of health, sex or ethnicity signals.
- Apple rules require informed permission and describe data sharing; no sneakily inferred hidden profile. Age and symbolic styling purpose must be visible and independently revocable. Subject safety and appropriateness for teenagers/minors requires separate age policy; initial adult-focused design avoids collecting child body photos.

## 34.2 Attacker and failure scenarios

1. **Partner query carries raw profile** → prevent via compile-time outbound allowlist DTO, integration interception test, independent packet-capture verification.
2. **Photos authorization escalated silently** → permission ledger and limited-library test, no background scan if denied.
3. **Morph engine exposes intimate anatomy** → full neutral coverage mesh, regression screenshots front/side/back/extreme slopes and state transitions.
4. **Malicious 3D asset or decompression bomb** → asset signing, per-file size/vertices/textures bounds, parser sandbox, negative tests.
5. **Review poisoning/fake size feedback** → partner/license verification, spam detection, provenance, threshold, quarantine, abstention.
6. **Calibrated waist overwritten by estimated slider** → independent fields, write ACL, user confirmation, audit and restore.
7. **Model self-learning degrades previous preferences** → frozen baseline and rollback, no silent production rollout.
8. **Location reveals presumed religion/culture** → no such inference; user-entered dress preferences only.
9. **Low battery overheats phone** → DeviceSteward stop/degrade with measured device energy tests.
10. **Retail 'aggregate' leaks one person's scan** → k-threshold grouping, delay, censor small cohorts, no per-user links.
11. **Size chart changed but cache stale** → content version/TTL, user date disclosure, invalidate, fail closed.
12. **Unlicensed brand product photo** → takedown/expiration path, no asset import without rights.
13. **Recommendation embeds hidden astrology** → UI explanation and explicit policy/consent test, default OFF.
14. **Social sharing exports precise body mesh metadata** → redacted, manually previewed share artifact, no EXIF GPS, never export personal measurements silently.
15. **Large local model extraction / app tampering** → appropriate code signing, file protection, model manifest hash, privacy of local data, reasonable limits of device compromise.
16. **Thermal/fairness trade-off** → low-tier device receives correct text alternative, not misleading or silently disabled fit.

## 34.3 Privacy acceptance invariants

```
assertNoNetworkTransfer(BodyProfile, AvatarMesh, PortraitCrop, BirthDate,
                        RawWearHistory, FaceEmbedding, PersonalPalette)
assertProductLookupOnlyContains(authorizedCatalogKey, coarseMarketIfNeeded)
assertDataDeletionPurges(localRawAndDerivedAssets, retainedIndexes,
                         cachedPersonalPredictions, personalModelDeltas)
assertOptionalFeaturesHaveIndependentConsentAndPurpose()
assertOffModeHasNoSymbolicStylingInfluence()
```

Private user exports require explicit action, understandable packaging, encryption option and clear scope. OS backups are a distinct surface; choose file protection and backup exclusion rules according to data type, test restore/deletion. Avoid misleading promise “we cannot ever access anything” if any voluntary support/telemetry path exists; specify actual network egress.

---

# 35. ADDITIONAL DOMAIN DATA CONTRACTS — IMPLEMENTATION-READY SKETCH

## 35.1 Body morph model

```swift
struct BodyMorphControl: Codable, Identifiable {
    let id: String                   // e.g., naturalWaistCircumference
    let region: String               // torso, arms, hips, legs
    var visualNormalizedValue: Double // -1.0 ... +1.0, morph not centimeters
    var safeMin: Double
    var safeMax: Double
    var confirmedCm: Double?          // only separately entered & confirmed
    var measurementMethod: String?    // landmark and protocol
    var source: MeasurementSource     // manual, imageDraft, importedUser
    var isUserConfirmed: Bool
    var updatedAt: Date
}
struct PrivateAvatarRevision: Codable {
    let revisionId: UUID
    let userProfileLocalId: UUID
    let topologyVersion: String
    let controls: [BodyMorphControl]
    let approvedByUser: Bool
    let createdAt: Date
    let contentHash: String
}
```

**Normative data invariants:** visual morph and centimeters never silently copied into each other; source and author recorded; unknown is null rather than 0; revision hashes independent of photos; random local profile ID never transmitted; production serializations versioned + migration tests.

## 35.2 Fit evidence result

```swift
struct ProductFitEvidence: Codable {
    let catalogVariantId: String
    let category: String
    let merchantSizeSystem: String?
    let options: [SizeOptionEvidence]   // 0..2, only if supportable
    let sourceIds: [String]
    let bodyMeasurementKeysUsed: [String]
    let fitAssumptions: [String]
    let unresolvedConflicts: [String]
    let missingRequirements: [String]
    let freshnessDate: Date?
    let claimLevel: String               // NO_EVIDENCE, GUIDE_BASED, VERIFIED_DIMENSIONS
    let renderedGarmentTier: String      // independent of claimLevel
    let rulesetVersion: String
}
```

`RenderedGarmentTier` cannot elevate `claimLevel`. Render can be G3 while no size chart is present; the UI displays a good-looking virtual garment and **no size recommendation**, not an invented W32/M.

## 35.3 Legal catalog adapter

```ts
type PartnerProductVariant = {
  tenantId: string;
  brandId: string;
  sourceRightsId: string;
  sku: string;
  gtin?: string;
  variantMarket: string;
  merchantSize: { label: string; system: string };
  garmentDimensions?: Record<string, {valueCm:number; measurementMethodId:string}>;
  bodyChart?: Record<string, {minCm:number; maxCm:number}>;
  fabric?: { fibers?: Array<{name:string;percent:number}>;
             stretchClass?: 'low'|'medium'|'high'|'unknown' };
  assetTier: 'G0'|'G1'|'G2'|'G3'|'G4';
  authorizedMediaIds: string[];
  version: string;
  lastVerifiedAt: string;
};
// PUBLIC consumer lookup accepts GTIN+market only. NO body/photo/DOB fields.
```

All examples are illustrative contracts pending ADR/SDK compilation, not existing code or deployed endpoints.

---

# 36. IMPLEMENTATION PROGRAM / UPGRADE PACKETS / REAL GATES

Existing WP01–WP26 remain; append **WP27–WP42** with dependencies, owners, evidence and tests. Claude must re-order without violating dependencies and must avoid idle agent proliferation.

| WP | Title | Required predecessor / proof | Non-negotiable deliverable |
|---|---|---|---|
| `WP27` | Canonical body morphology spec | avatar base, topology decision | parameter registry, safety bounds, two unit systems, UX spec |
| `WP28` | Blender body asset compiler | WP27 | shape keys, rig, tests of all parameter extremes, license records |
| `WP29` | iOS live morph engine | WP28, RealityKit capability spike | slider updates, frame metrics, neutral coverage, undo |
| `WP30` | Body measurement wizard | WP27–29 | tape instructions, confirmed/visual separation, edit history |
| `WP31` | Avatar calibration evidence lab | WP30 | synthetic/consented measurement datasets, error stats, abstention |
| `WP32` | Garment tiers & asset compiler | WP28–29 | G0/G1 mandatory and G2/G3 spike, fidelity UI, asset rights |
| `WP33` | Multi-source brand resolver | base catalog and licensing architecture | adapter contracts, GTIN normalization, failure matrix, no illegal scraping |
| `WP34` | Brand/category chart fit engine | WP30, WP33 | case-by-case size selection, sources, missing-evidence abstention |
| `WP35` | Review intelligence and fraud lab | rights-cleared optional data, WP34 | extraction with calibrated precision, report, quarantine, never fabricated reviews |
| `WP36` | Progressive fast try-on pipeline | WP29, WP32–34 | supported cold/warm latency traces, LOD, cancel, fallback |
| `WP37` | Octopus privacy + orchestration | P0 privacy/architecture, existing engines | typed arms, per-arm IO, policy veto, tracing without PII |
| `WP38` | Local feedback/model update lab | WP37 | deterministic personalization + guarded updatable-ML experiment and rollback |
| `WP39` | Occasion and creative stylist | wardrobe/weather baseline | qualified style rules, diversity, explanation, optional color sampling |
| `WP40` | Symbolic mode explicit opt-in | WP39 + legal/consent | separated OFF-by-default local module, data delete, scientific distinction |
| `WP41` | Retail partner acquisition kit | WP33–36 + product claims review | pilot contract template, pitch, feed spec, data sharing matrix, KPI design |
| `WP42` | Consumer GTM & growth engine | actual useful app and privacy review | share preview, QR proof, funnel experiments, no fabricated commercial KPI |

### 36.1 Realistic execution sequence

```
Phase A — decision correctness:
  Current v1 reality audit → morphology physics & data contracts → Blender rig spike →
  locally editable live avatar prototype → safe fit/evidence threshold.
Phase B — trustworthy core:
  wardrobe/photo consent + weather/occasion + fast barcode →
  brand feed mock → complete scan→fit→render flow with G0/G1 → device lab.
Phase C — quality depth:
  garment tier G2/G3 validation + source-specific charts →
  CPU/GPU energy optimization → feedback learner → independent audit.
Phase D — real commercial feasibility:
  partner licensing, first 1–3 merchant pilot, collect audited queue/fit outcomes →
  approve/reject scale-up/Android on evidence.
```

**Do not wait for 100 brand integrations before producing an end-to-end working iOS demo.** Build from transparent `DEMO_ONLY` fixtures, then replace with signed licensed partner feed when available. No partner creates a blocker to the consumer-only release if product catalog is clearly limited.

### 36.2 Minimum new tests — actual runnable evidence required

#### Avatar editor and visual geometry (`T-V11-001` .. `018`)

- 001 live ± slider changes only selected anatomical region; 002 continuous drag responsive on supported device; 003 reset+undo+redo deterministic; 004 saved revision roundtrip; 005 0/unknown does not imply centimeters; 006 manually entered circumference preserved after morph; 007 feet stay grounded; 008 no joint tearing/extreme self-intersection; 009 mannequin stays fully neutral/covered from every camera angle; 010 hair not mistaken for head shape; 011 VoiceOver adjustable action works; 012 Dynamic Type doesn't obscure preview; 013 left/right optional symmetry; 014 changes propagate to supported garment silhouette; 015 no automatic photo inference on drag; 016 iOS fallback mesh path; 017 unbounded low-memory stress abort; 018 front/side/back screenshot evidence.

#### Catalog, brand, fit and reviewer evidence (`T-V11-019` .. `038`)

- 019 GTIN known exact variant; 020 unknown GTIN no fabricated name; 021 wrong country chart refused; 022 shirt vs jeans chart mismatch refused; 023 W/L denim separate axes; 024 inch/cm correct; 025 flat vs circumference no naive 2×; 026 contradictory partner evidence -> abstain; 027 stale chart warning; 028 customer review with ambiguous quality no certainty; 029 missing license excludes asset; 030 no fake `Levi's partnership` badge; 031 missing body measurement permits partial non-numeric explanation; 032 user entered exact measurement is honored; 033 different fit preferences yield reasoned different suggestions; 034 no size label conflated with photoreal G-tier; 035 comparison renders same camera; 036 visual look-alike candidate requires confirmation; 037 no unsanctioned web scraping; 038 manufacturer feed takedown invalidates local cache.

#### Octopus learner, energy, context (`T-V11-039` .. `058`)

- 039 per-arm input least privilege; 040 reject data egress from body; 041 low-power pauses optional gallery work; 042 thermal serious reduces LOD/work; 043 thermal critical suspends heavy processing; 044 photo permission revoked stop scan; 045 offline previously indexed closet still works; 046 model update only on supported compatible model; 047 failed model candidate rollback; 048 user manual avatar data never overwritten; 049 deterministic preference update after `NotMyStyle`; 050 `No symbolic consent` means no astrological influence; 051 explicit consent reveals influence in why; 052 deleting DOB removes symbolic record and predictions; 053 city doesn't infer religion/culture; 054 lighting ambiguity prevents categorical undertone; 055 nonconsenting portrait neither stored nor uploaded; 056 event-only occasion without age works; 057 elapsed wear days doesn't falsely mark item dirty; 058 partner analytics has no narrow single-user cell.

#### End-to-end marketing and pilot (`T-V11-059` .. `075`)

- 059 cold+warm supported cached demo measured per device; 060 unknown SKU error gracefully degrades; 061 moving camera doesn't rerun photo CV; 062 slow network shows G0 first; 063 no accidental deep-link secret sharing; 064 share card preview redacts location/body dimensions/DOB; 065 consentless funnel logs stay off; 066 partner QR verified; 067 tenant isolation cross-account 403; 068 revoked catalog license takes effect; 069 queue baseline denominator formula reproducible; 070 control/treatment footfall matching documented; 071 false fit advice return-rate adverse condition causes rollout halt; 072 consumer use works with no partners; 073 premium off doesn't block core editing/deletion; 074 partner pricing uses true cost estimates; 075 all release claims map to real measured artifacts.

For **every one** of these 75 additions: implement executable case(s), status `NOT_RUN|FAIL|PASS|BLOCKED` linked to file, device/build/OS/commit/result. A bullet on paper is a **test specification**, not a passed test. If a target cannot be tested now, status `BLOCKED` with exact reason and safe fallback.

### 36.3 Gate requirements

| Gate | PASS requires | FAIL/BLOCKED response |
|---|---|---|
| `G-MORPH` | native 3D drag, coverage geometry, undo, no cm fabrication, device screenshot | ship static editable templates only / stop claiming live morph |
| `G-GARMENT` | G0/G1 correct and clearly labeled, license and motion tests | generic style-only visual, not “virtual try-on” claim |
| `G-FIT` | per-SKU unit/size protocol validated, abstention/fairness tests | no suggested sizes; user-visible chart when permitted |
| `G-RETAIL` | signed rights, catalog SLA, partner isolation, measured pilot methodology | no brand partnership or retailer impact claims |
| `G-LOCAL-AI` | reproducible model card, thermal/power/privacy tests, rollback | deterministic model+local user edits only |
| `G-ETHICS` | no hidden symbolic inference / culture deduction / body scoring, full consent controls | disable relevant feature |
| `G-RELEASE` | real devices, accessibility, legal review, security, build, evidence mapping | do not call product production-ready |

### 36.4 New expert implementation roles (augment existing 15, consolidate overlaps)

`Parametric Human Geometry Engineer` (topology, morphs, rig); `Technical Apparel Patternmaker/Size Scientist` (pattern ease and semantics); `Computational Garment Simulation Engineer` (real vs proxy drape); `Retail Catalog Licensing/Data Steward` (rights/version); `Edge ML Energy and Thermal Engineer` (models, battery, scheduler); `Retail Experiment Statistician` (causal queue assessment); `Fashion Color/Occasion Creative Director` (style rules); `Independent Body Inclusivity/Accessibility Auditor`. Expertise roles are logical review responsibilities; do not claim 8 paid specialists were hired or that separate runtime AI systems exist. A single agent may implement several with independent scripted checks, but no one self-certifies a critical gate without a separable audit.

---

# 37. FINAL CLAUDE CODE INSTRUCTION — V1.1 PRECEDENCE & AUTONOMY

> **CLAUDE: READ THE ENTIRE v1.0 IN THE CANONICAL MERGED v1.1 FILE PLUS THIS V1.1 AMENDMENT; START CODE, NOT JUST A LONG PLAN.** First determine repository facts, code and toolchain. Prepare one concise baseline, one ADR for avatar morph and fit/rights boundary, then implement the first meaningful vertical slice in the existing repo. Do not invent real customer data, merchant rights, test passes or screenshot evidence. You are authorized to perform reversible repository work and run available local tests. Paid cloud, public publication, accessing external paid/secret accounts, signing commercial agreements, sending marketing messages and shipping to stores require human permission. Work locally with synthetic assets when blocked; clearly report blockers.

At the end of each execution unit, return:

```
WEARFORM V1.1 EVIDENCE REPORT
- Repository/branch/commit:
- Implemented / tested / device-verified (separately):
- Tests (exact commands, summary, logs):
- UX evidence (screenshots with device/build/OS):
- Avatar fidelity tier and fit evidence tier:
- Privacy/energy/resource observations:
- Partner catalog licensing and source status:
- Benchmark deltas and regression:
- Critical risks / BLOCKED / UNKNOWN / STOP-THE-LINE:
- Next dependency-safe work package:
```

**Mandatory first user-visible execution target:** iPhone prototype where person starts with a neutral gray body, drags waist/hip/shoulder/chest/thigh sliders, sees continuous valid geometry live, safely changes clothes from G0/G1 original licensed templates, scans a synthetic barcode and receives an explicitly source-supported or abstaining size suggestion; all local private measurements remain offline. This is the “proof of taste” of the product, not a generated marketing video.

---

# 38. VERIFIED REFERENCE LINKS & RESEARCH TO RECHECK

Sources below describe publicly documented **capabilities/policies only**; they do not evidence a built WEARFORM feature, accessible partner data or model accuracy. Recheck at implementation time against specific SDK version and country's law:

1. Apple RealityKit mesh deformation / skinning / blend shapes: https://developer.apple.com/documentation/realitykit/scene-content-mesh-deformation
2. Apple RealityKit models and meshes: https://developer.apple.com/documentation/realitykit/scene-content-models-and-meshes
3. Apple on-device updatable models (only designated updatable Core ML): https://developer.apple.com/documentation/coreml/personalizing-a-model-with-on-device-updates
4. Apple PhotoKit user permission and limited library: https://developer.apple.com/documentation/photokit/delivering-an-enhanced-privacy-experience-in-your-photos-app
5. Apple energy/thermal responses: https://developer.apple.com/documentation/xcode/responding-to-power-notifications
6. Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
7. Google Merchant product attributes and variant structures: https://support.google.com/merchants/answer/14779112?hl=en
8. Google Merchant API authenticated account access: https://developers.google.com/merchant/api/guides/authorization/access-your-account
9. Levi's actual apparel size chart (example of a manufacturer chart, not blanket licensing): https://www.levi.com/GB/en_GB/info/sizechart
10. Alta feature comparator (official current public claim, do not assume technical implementation): https://www.altadaily.com/
11. Turkish KVKK special-category data overview: https://www.kvkk.gov.tr/Icerik/2051/Ozel-Nitelikli-Kisisel-Veriler

**Standing mandate:** If public references, Apple APIs, laws or partner terms changed after this document's date, Claude must verify current authoritative sources and record updated ADRs before relying on them. No claims about contracts or consent are inferred from publicly visible brand websites.

---

**END OF V1.1 ADDITIONAL CONSTITUTION.**

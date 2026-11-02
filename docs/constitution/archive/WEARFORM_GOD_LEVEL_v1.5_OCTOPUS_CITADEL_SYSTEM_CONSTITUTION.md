# WEARFORM — v1.5 OCTOPUS INTELLIGENCE + CITADEL SECURITY + UNIVERSAL EXECUTION CONSTITUTION

> **CANONICAL AMENDMENT — 03 November 2026.** Binding extension to v1.4 §§0–100. New §§101–135 supersede older conflicting implementation advice; user-approved product intentions and all stronger privacy/safety requirements are retained. All contents are **design and executable acceptance requirements**, not evidence of built or tested software.
>
> **CLAUDE EXECUTION DIRECTIVE:** Read §§101–135 **before** implementing or modifying any runtime intelligence, security, learning, brand integration, data storage, or device scheduler. Read original §§0–100 for complete product requirements. Audit repository; implement architecture as a modular monolith on iOS first. Do not create independent microservices or autonomous LLM agents where a deterministic actor/function suffices. No claim of GOD LEVEL without measured evidence.
>
> **Operating principle:** `GOD LEVEL = right question × correct evidence × bounded intelligence × secure execution × measurable performance × simple UX × continual verified improvement`.

## 101. NON-NEGOTIABLE DEFINITIONS, INVARIANTS AND REALITY

WEARFORM is a privacy-first wearable intelligence product for personalized 3D appearance previews, size/fit estimation, private wardrobe, context-aware outfit recommendations, trip packing, and retail-assisted shopping. It must behave as **one coherent brain** while internally using specialized bounded modules.

### 101.1 What the founder means by “every atom”

Every unit — data field, transform, ML inference, network request, texture, garment asset, push, slider frame, API, encryption key, cache, model version, business action, payment, analytics event — must declare:

1. **Purpose/owner:** Which user job and domain owns it; which team/agent changes it.
2. **Inputs:** Exact types, data classification, provenance, freshness, units, user consent, confidence.
3. **Outputs:** Exact schema, uncertainties, errors, source references and version.
4. **Invariants:** Conditions that cannot become false even under failure.
5. **Dependencies:** Allowed calls, performance budget and offline fallback.
6. **Security:** Threats, allowed access, allowed egress, key management and retention.
7. **Quality:** A fixture-based executable test, adverse cases and real-device evidence.
8. **Evolution:** Versioning, rollout gate, rollback path and deletion strategy.
9. **Economics:** CPU/GPU/battery, storage/network cost and recurring services cost.
10. **Observability:** Privacy-safe diagnosis, alarm thresholds and evidence locations.

No “unowned” field, no undocumented external request, no unversioned critical domain model, no unreviewed dependency, no background photo harvesting, no unsupported fashion/fit claims.

### 101.2 Non-negotiable runtime invariants (security-sensitive tests MUST assert each)

- `INV-01 PRIVATE_INPUT_LOCAL`: Raw person photos, measurements, avatar geometry, private wardrobe and inferred personal metadata never leave the device by default; egress only through an explicit purpose-bound user action that names destination/data.
- `INV-02 NO_GENDER_INFERENCE`: Identity, gender, ethnicity, age, attractiveness, health, or protected trait never inferred from visual inputs for style personalization. Age from optional birth date only if user supplies it; age and culture NEVER justify degrading recommendations.
- `INV-03 NO_FAKE_FIT`: A fit result cannot claim verified physical fit unless eligible validated garment and body measurements exist and a defined evaluation gate passes. No centimeter certainty from a single photograph.
- `INV-04 DATA_RIGHTS`: Any third-party product/brand/photograph/review/3D asset used must have an accepted source, documented permitted purpose, license and deletion/expiry semantics.
- `INV-05 TRUST_BOUNDARY`: Catalog text, barcode results, reviews, photos, travel descriptions and model outputs are untrusted DATA, not executable instructions.
- `INV-06 LEAST_PRIVILEGE`: Each specialist accesses only required fields and can call only explicit capabilities in its registry.
- `INV-07 USER_OVERRIDE`: User can correct manual measures, garment identity, recommendations, and app permissions; all feedback is reversible.
- `INV-08 OFFLINE_SURVIVAL`: Core avatar, saved wardrobe and cached styling function without login or network; gracefully label stale weather/brand data.
- `INV-09 SAFE_DEGRADATION`: Under resource pressure or low confidence, degrade visual quality/accuracy claim, postpone nonessential work, never disable privacy or authentication to get speed.
- `INV-10 MUTATION_GUARD`: A runtime specialist never changes executable application code or replaces untrusted binary/model; updates require signature, policy, tests and approved release channel.
- `INV-11 TENANT_ISOLATION`: Retail partner A cannot access B’s catalog edits/order details/analytics; a partner cannot retrieve user private shape/photos.
- `INV-12 EVIDENCE_BEFORE_DONE`: Build passing, test passing, hardware measurements and legal rights evidence separately reported; no performed-evidence invented.
- `INV-13 LIFECYCLE_CLOSURE`: Deletion, consent revocation, backup, migration and key rotation cannot leave private caches, derived vectors, thumbnails or telemetry behind.
- `INV-14 NO_BODY_SHAMING`: No beauty score, body 'ideal' ranking, compelled demographics or stigmatizing language.
- `INV-15 EXPLAINABILITY`: Users see evidence level, reasons, alternatives, provenance freshness and ability to challenge important recommendations.
- `INV-16 SAFETY_OVER_ENGAGEMENT`: Fashion, health, travel and commerce suggestions may never override user wellbeing, spending guardrails or consent.

### 101.3 Three independent kinds of intelligence

- **Decision intelligence:** Rules, constraints, provenance-weighted ranking, optimization, graph queries; default when precise data exists.
- **Perceptual intelligence:** Core ML/Vision for segmentation, garment attributes, pose landmarks and matching; probabilistic and error-prone, calibrated and limited.
- **Generative intelligence:** Optional on-device text/explanation/style variation on compatible devices; outputs must be validated. Never a source of truth for product dimensions, identity, weather, legal requirements or cryptographic policies. Must have deterministic, accessible fallback.

“Self-learning” means updating **preferences and measured uncertainty**, not claiming independent consciousness, autonomous software rewriting, infallibility or unlimited device access. No real system is guaranteed flawless or breach-proof.

## 102. WHOLE SYSTEM — ONE BRAIN, SPECIALIZED ORGANS, ZERO MAGIC

### 102.1 Reference architecture

```text
      USER INTENT: Scan / Wardrobe / Fit / Outfit / Trip / Retail
                                |
                       SwiftUI Interaction
                                |
                 Intent Gateway + Permission Center
                                |
             [CITADEL: policy + privacy + capability check]
                                |
                  OCTOPUS ORCHESTRATOR (Swift actor)
             /                  |                      \
   Context Snapshot        Task DAG / Cache         Resource Governor
             \                  |                      /
              BOUNDED DOMAIN SPECIALISTS (on device)
         BODY   VISION   GARMENT   FIT   RENDER   STYLE
         WEATHER   TRAVEL   CARE   LEARNING   EXPLAIN
                       |         |
      DOMAIN SOURCE OF TRUTH + PROVENANCE + CONFIDENCE
                       |         |
         ENCRYPTED LOCAL VAULT / SIGNED PUBLIC ASSETS
                       |         |
         EGRESS FIREWALL (explicit capability only)
                       |
        OPTIONAL PARTNER API (product only; no body data)
                       |
        PRIVACY-SAFE AUDIT + QUALITY/RELEASE EVIDENCE
```

This is a **logical architecture**, not a mandate for dozens of processes, microservices, GPUs or concurrently executing models. iOS implementation: Swift/SwiftUI, Swift actors/async, Core ML, Vision, RealityKit/Metal where justified, SQLite/SwiftData after ADR, Keychain, CryptoKit, URLSession and structured tests. Blender generates approved rigged assets offline; Blender is not required inside the mobile runtime.

### 102.2 End-to-end trust boundaries

| Boundary | Allowed | Forbidden | Evidence |
|---|---|---|---|
| UI → Intent Gateway | Typed user intent, explicit consent | UI bypassing authorization to raw data | Permission tests |
| Gateway → Orchestrator | Sanitized task request + capability ID | Arbitrary free-form executable prompts | Contract tests |
| Orchestrator → Modules | Minimized scoped input, context budget | Full personal database broadcast | Capability inspection |
| Vision → Vault | Approved derived garment info, optional original if user chooses | Automatic export/secondary use | Filesystem/egress audit |
| Local Vault → Brand Network | Product identifier / region / locale if requested | Avatar, face, waist, shopping history | Network interception fixture |
| Remote Catalog → Local Brain | Verified/sanitized product facts with provenance | Instructions, HTML execution, secret-bearing data | Prompt injection tests |
| Local Brain → UI | Labeled hypotheses, choices, visual outputs | Fabricated certainty or blind commercial endorsements | Golden tests |
| Update channel → Runtime | Signed, compatible, allowed model/resource versions | Runtime-generated or unsigned executable content | Signature-failure tests |
| Retail Tenant → Service | Authorized tenant-owned product data | Any other tenant/user private data | Cross-tenant penetration tests |

### 102.3 In-process modularity rules

- Use a small set of Swift packages/targets for domain seams, not one target per trivial helper.
- Each domain has one canonical state owner; no second undocumented copy of body or wardrobe truth.
- Calls are synchronous within actor or structured asynchronous by default; events only for state transitions, invalidations, and user-visible progress.
- No generic 'AI prompt' that can inspect all databases; any LLM receives a minimal DTO with redacted fields.
- Render is a consumer of a stable immutable `AvatarSnapshot`, never an authority allowed to overwrite measurements.
- Local store must support atomic writes, crash recovery and schema migration tests.

## 103. OCTOPUS ORCHESTRATOR — EXECUTION SEMANTICS, NOT ROLE PLAY

Implement a single accountable controller `OctopusCoordinator` (conceptual Swift actor) that never invents business facts. It owns operation graph, prioritization, cancellation, deduplication, privacy checks, result assembly, partial progress, timeout and recovery.

**Intent flow:** validate user action → inspect permissions → build minimal immutable `ContextSnapshot` → construct task DAG → request resource budget → dispatch eligible modules → validate outputs/schema → reconcile authoritative conflicts → apply truth/uncertainty policy → assemble user-facing result → commit permitted state → privacy-safe audit.

**Pseudocode (illustrative, not compiled source):**

```swift
actor OctopusCoordinator {
  func execute(_ intent: UserIntent) async -> DecisionEnvelope {
    let authorization = await policy.authorize(intent)
    guard authorization.allowed else { return .denied(authorization.reason) }
    let context = await snapshots.minimalSnapshot(for: intent, grant: authorization)
    let plan = taskPlanner.makeDAG(intent: intent, context: context)
    let grant = await resourceGovernor.reserve(plan.costEstimate, priority: intent.priority)
    guard grant.allowed else { return await fallback.evaluate(intent, context) }
    defer { Task { await resourceGovernor.release(grant) } }
    let outputs = await executor.run(plan, within: grant, cancellation: intent.cancellation)
    let verified = verifier.rejectInvalid(outputs, context: context)
    return await presenter.compose(verified, provenance: context.provenance)
  }
}
```

This code is a **design sketch**; Claude must replace undefined types with compilable, tested implementations. Actor isolation is not by itself a privacy boundary; `policy.authorize` must be at every restricted egress/storage operation, not solely at the UI entrance. Beware `defer`/async cleanup behavior and test cancellation/resource leak cases.

### 103.1 Task state machine

`CREATED → AUTHORIZED → SCHEDULED → RUNNING → {PARTIAL, COMPLETED, DEGRADED, CANCELLED, TIMED_OUT, FAILED, BLOCKED_POLICY}`.

- Terminal states are immutable; event replay must not mutate already committed purchase/fit history.
- UI intent supersedes stale prior intent (`latest-wins` for slider and scan preview) without stopping critical persistence/cleanup.
- Duplicate barcode requests are coalesced with TTL and product+variant key, not user identity.
- Background work is opportunistic and OS-controlled; no guarantees of continuous 24/7 inference or unrestricted photo access.
- Orchestrator is restartable: unfinished transient tasks do not masquerade as finished; durable jobs are idempotent.
- Repeated failed modules cause circuit breaker and deterministic fallback, not cascading retries.

### 103.2 Scheduling priorities

| Priority | Work | Preemption policy |
|---|---|---|
| P0 interactive | avatar slider, camera permission, show cached outfit, delete data | Highest; keep UI responsive |
| P1 user-requested | barcode product lookup, local CV, fit calculation, packing plan | Timeboxed; progressive output |
| P2 opportunistic | wardrobe dedupe, thumbnails, precomputation | Pause if thermal/memory/energy adverse |
| P3 maintenance | preference training, model benchmarking, data migration, catalog refresh | Only allowed by user, platform and resource policy; cancellable |

User-visible performance budgets are hypotheses until measured on named devices. No “guaranteed 1 second” or arbitrary concurrency promises.

## 104. SPECIALIST REGISTRY — REQUIRED EXECUTION CONTRACT

Each specialist is a bounded capability, generally a Swift component or Core ML model, not necessarily an independent AI/LLM. Registry entry has `id, owner, version, inputs, outputs, readScopes, writeScopes, networkCapabilities, modelId, resourceCost, deadlineMs, confidencePolicy, failureFallback, evaluationDataset, goldenTests, prohibitedActions, securityTier`.

**Hard rule:** The runtime does NOT grant a module an unrestricted `network` or `storage` handle. Calls go through scoped repositories and egress/consent guards. A module cannot promote itself, change policy or install new modules.

### 104.1 24 runtime specialist contracts

| ID / specialist | Expertise / inputs | Output & authority | Failure / privacy |
|---|---|---|---|
| `OCT-01 Intent Interpreter` | Typed navigation intent, explicit user question | Normalized `UserIntent`, never executes from prose alone | Ask/offer choices; no gallery |
| `OCT-02 Consent Guardian` | Consent ledger, permission status, policy matrix | Capability-grant or denial; sole policy authority | Deny by default; revoke cascade |
| `OCT-03 Device Governor` | Thermal, Low Power, memory, OS capability | Resource grants / defer / quality tiers | Switch to cached/basic view |
| `OCT-04 Photo Intake` | User-picked image / authorized PhotoKit access | Bounded decoded image, retained according to consent | Reject unexpected scope; no upload |
| `OCT-05 Garment Vision` | Selected image, permitted local model | Category, color, pattern, attributes with uncertainty | Manual entry if uncertain |
| `OCT-06 Body Landmark Lab` | Explicit user-supplied body image | Coarse landmarks/shape hypotheses only | No claimed precise measurements |
| `OCT-07 Body Geometry` | User-verified anthropometric sliders/units | Canonical morph state, valid ratios | Restore safe last mesh |
| `OCT-08 Avatar Renderer` | Canonical geometry + signed assets | 3D neutral avatar/scene | Low-poly 2D silhouette fallback |
| `OCT-09 Product Identifier` | Camera barcode/image + user selection | Candidate GTIN/brand/SKU, confidence | Require confirmation on conflicts |
| `OCT-10 Brand Data Resolver` | Product key, partner catalog license | Version-specific factual garment passport | Unknown if no licensed facts |
| `OCT-11 Material Analyst` | Labeled composition/care info + verified sources | Fabric behavior *constraints*, not physics certainty | Generic preview only |
| `OCT-12 Fit Specialist` | User measures + product measurements + tolerance | Fit band/unknown, sensitivity and reason | Abstain if sparse/conflicted |
| `OCT-13 Visual Try-on` | Avatar snapshot + garment asset/geometry | Labeled silhouette/3D preview fidelity tier | Switch to flat overlay |
| `OCT-14 Style Director` | Wardrobe, preferences, weather, occasion | Ranked looks and explanations | Deterministic rules on ML failure |
| `OCT-15 Color Coordinator` | User-selected color preference, garment palette | Palette pairings; preference-centric | Avoid skin/ethnicity labels |
| `OCT-16 Weather Context` | User city or destination, authorized forecast | Timestamped weather + reliability | Cached/seasonal labeled |
| `OCT-17 Occasion & Venue` | User-stated plans, verified venue dress rules | Occasion suitability constraints | No cultural stereotyping |
| `OCT-18 Wardrobe Steward` | Items, wear/clean states, explicit logs | Availability/rotation recommendation | Dirty is hypothesis; user corrects |
| `OCT-19 Capsule Travel Planner` | Itinerary, outfit constraints, baggage rules | Packing list and daily outfits | Conservative fallback on unknowns |
| `OCT-20 Fit Memory Learner` | Opt-in corrections and purchase feedback | Calibrated preference/size residual, versioned | Rollback if worse; never train on others |
| `OCT-21 Knowledge Provenance` | Sources, versions, licenses, locale, timestamps | Evidence ledger and conflict flags | Quarantine stale/unlicensed |
| `OCT-22 Explanation & Uncertainty` | Structured results/trace without raw private data | Short plain-language reason and limitation | No invented source/measurement |
| `OCT-23 Retail Privacy Gateway` | Public product ID, partner contract, user action | Minimized network request + sanitized response | No private avatar/photo export |
| `OCT-24 Health & Integrity Watch` | App errors, memory/thermal trends, signature state | Local diagnostics and recoverability status | No secret logging; no spying |

### 104.2 Specialist invocation guardrails

Every registry row becomes `docs/architecture/AGENT_REGISTRY.yaml`, Swift protocols and contract tests. In code-review, block `OCT-xx` from importing or directly instantiating clients outside declared capabilities. A garment-vision classifier cannot upload pictures. A style-generator cannot read private body measurements without a measured need; where a fit category suffices, send category only. A brand resolver cannot alter user body data. The runtime cannot observe other apps or access their sandboxes.

### 104.3 Domain outputs and genuine multidisciplinary judgment

The garment expert provides pattern/block, grading, ease, garment construction data; textile expert provides weave/stretch/care; biomechanics expert supplies a **nonmedical** movement envelope; 3D expert supplies mesh & cloth approximation; color/style expert optimizes user-specified expression; ethnographic/local context specialist provides verifiable venue norms, not stereotyped predictions; privacy engineer checks data separation; accessibility reviewer checks controls; retail ops expert checks queue logistics; statistician audits fit/recommendation calibration. A person’s body is not a medical diagnosis.

## 105. EVENT PROTOCOL — THE NERVOUS SYSTEM

Avoid building a heavyweight distributed message broker for an offline iOS app. Implement typed in-process domain events (`AsyncStream`/Combine or actor-based transport after ADR) with durable journaling *only* for important state changes. Separate **commands** (request to change) from **events** (fact that change committed).

### 105.1 Canonical `DomainEventV1`

```json
{
  "schema_version": 1,
  "event_id": "uuid-v4",
  "event_type": "wardrobe.item.categorized",
  "occurred_at_utc": "RFC3339",
  "trace_id": "non-identifying-random-id",
  "causation_id": "prior-event-or-null",
  "source_module": "OCT-05",
  "entity_kind": "wardrobe_item",
  "entity_local_id": "opaque-local-id",
  "revision": 4,
  "payload_classification": "LOCAL_PRIVATE",
  "provenance": {"source_kind":"user_selected_photo","model_version":"id","confidence":0.74},
  "payload": {"category":"shirt","needs_user_confirmation":true},
  "ttl_seconds": null
}
```

The payload is schema-validated and strictly typed. `confidence` is an internally calibrated model estimate, not automatically a 74% probability of correctness; only display a percentage after calibration evidence. Event IDs support dedupe; revision is monotonic per entity; tracing identifiers must not become cross-app identifiers. Private payload must never be sent to analytics, crash or network logging.

### 105.2 Critical commands/events

- `UserSelectedPhoto → PhotoAccepted → GarmentCandidateRecognized → UserConfirmedGarment → WardrobeItemCommitted`.
- `BodySliderChanged → MorphRequested → MorphValidated → AvatarRevisionCommitted → SceneRendered`.
- `BarcodeScanned → CandidateIdentified → ProductDataChecked → FitEstimated/Unknown → TryOnPrepared`.
- `UserCreatesTrip → ForecastChecked → CapsuleOptimized → PackingPlanCommitted → UserEditsPacking`.
- `UserRevokesConsent → JobsCancelled → ScopedCachesPurged → LedgerCommitted → UserReceiptCreated`.
- `ModelUpdateAvailable → SignatureVerified → CompatibilityChecked → ShadowEvaluated → Activated/Rejected → Monitored → RolledBackIfNeeded`.
- `ThermalStateChanged → GovernorRebudgeted → NoncriticalJobsPaused → VisualTierDowngraded`.

### 105.3 Event guarantees

- In-process delivery may be lost on process termination; never claim exactly-once end-to-end. Durable state changes must use transactional state + outbox/replay **only if warranted**.
- Subscribers are idempotent; event replay of delete/update cannot resurrect private data or purchase orders.
- UI uses snapshot revisions to discard stale results; cancellation propagates from user to CV/render/HTTP where supported.
- Expired weather/catalog events must not trigger unlimited retraining or network loops.
- Outbox payload contains only minimum safe fields; no persistent raw camera frames.
- Important state invariants are checked at persistence boundary, not delegated to a language model.

## 106. KNOWLEDGE, EVIDENCE, PROVENANCE AND CONFLICT RESOLUTION

### 106.1 Single source of truth by domain

| Domain | Canonical source | May be inferred? | Reconciliation |
|---|---|---|---|
| User body dimensions | User-edited/local measured values | Photo only as uncertain initial estimate | User wins; units explicit |
| Avatar geometry | Deterministic transform of dimensions | 3D model preview yes | Never reverse-write without consent |
| Product identity | Verified GTIN + partner variant mapping | Candidate from camera | Confirm on mismatch |
| Garment measurement | Licensed manufacturer variant data | Approximate from media only as lower tier | Provenance and version required |
| Weather | Timestamped authorized provider | Forecast only | Distinguish forecast/climatology |
| Wardrobe possession | User-confirmed item | Photo classifier candidate | User confirms |
| Worn/washed status | User logging | Provisional suggestion | User can override |
| Venue rules | Official/verified venue source | Not from regional stereotypes | Stale = uncertain |
| Style preference | User choices + reversible feedback | Weak inferred preference | Prevent feedback lock-in |
| Model integrity | Signed release manifest | Never | Fail-closed |

### 106.2 EvidenceRecord schema

Mandatory properties: `evidence_id`, `fact_key`, `subject_product_id`, `variant_id`, `fact_value`, `unit`, `source_type`, `source_uri_or_licensed_dataset_id`, `license_id`, `collected_at`, `effective_from`, `expires_at`, `region`, `model_or_parser_version`, `confidence_kind`, `verification_method`, `user_override`, `revocation_tombstone`. A fact without rights, identity/version or legal use cannot appear as verified.

### 106.3 Conflict engine

Case: retailer listing says jacket M chest 102 cm; another source says 106 cm. Do not average blindly. Check source date, seller, model code, season, cut, unisex/mens/womens variant label as **catalog category** (not user gender), size measurement method and tolerance. If unresolved show conflict and refrain from single definitive size. Contrast product reviews as weaker, biased signals; never fabricate an observation of other customers' bodies or private data.

## 107. MULTIDISCIPLINARY FASHION/PRODUCT REASONER

A professionally reasoned look has distinct axes: `Physical Fit`, `Silhouette Preview`, `Color Harmony`, `Material/Weather`, `Occasion/Social Context`, `Wearability`, `Wardrobe Reuse`, `Personal Preference`, `Price/Budget`, `Source Trust`. One axis must not falsely substitute for another (e.g., a stylish outfit may be a poor fit; an attractive image may not be physically accurate).

- **Modelist:** construction, darts, seams, graded sizes, ease margin and construction-type tolerances; requires source data.
- **Textile engineer:** fiber blend, stretch direction, weight, breathability, wrinkle tendency; attributes not guessed as physical certainty from photo.
- **Color expert:** user-chosen undertone/palette can inform matching; never infer race from skin or lock user to presumed colors.
- **Stylist:** cohesion, shoes, layers, social intention, formality, personality and repeatability; supplies alternative aesthetics, not one 'correct' appearance.
- **Meteorologist/context:** temperature, rain, wind, humidity, local forecast uncertainty and relevant travel timing; no remote weather if unavailable.
- **Culture/venue specialist:** actual dress codes and norms, respectful options, uncertainty; no inferred religion, ethnicity or ideology from GPS.
- **3D/graphics:** visual fidelity tiers and garment interaction approximate; cloth movement must not be conflated with physical size certainty.
- **Behavioral science/privacy:** suggestions are opt-in, non-manipulative, can be overridden; no shame or commercial coercion.

**Structured decision** is a Pareto-style selection plus user priorities, not one mythical composite number. Hard constraints (cannot wear wet/dirty/too-cold item, venue requirement, unsuitable size with high-confidence) are separated from soft preferences. Display three useful alternatives (e.g., understated, expressive, weather-safe) where feasible, with concise reasons and access to source evidence.

### 107.1 Example person-first decision (not hardcoded policy)

`Trip 5 days, 1 formal dinner, 2 rainy days, carry-on 8 kg`: wardrobe optimizer selects two compatible outer layers, reuses shoes/neutral pants, handles dress requirements, reserves a weather backup, tracks clean states, flags missing product without forcing purchase. A 3D scene illustrates **possible look**, not accurate future body/scene lighting.

## 108. BODY & FIT SCIENCE — CALIBRATION AND ABSTENTION

1. Separate **measured circumference, clothing measurement, ease allowance, stretch and shape preference**. Units carry precision/tolerance and method.
2. User-edit sliders control coherent correlated morph weights, not disconnected cylinders; mesh stays watertight when specified and never tears/overlaps beyond documented tolerances.
3. No hidden inferred genital anatomy or anatomy claims; neutral covered avatar; shape controls to assist fit only.
4. Every fit result carries `recommendation` (`likely_small | likely_fits | likely_large | unknown`), `confidence_band`, `evidence_grade`, `critical_missing_inputs`, `fit_by_region` only with sufficient data, and `needs_physical_try_on` flag.
5. The visual tier carries a separate `garment_asset_fidelity` (`generic_overlay | simplified_3d | partner_pattern | material_validated`) and must not be promoted on scene prettiness.
6. When a user reports physical try-on (`too_tight_shoulders`, `right_waist`, etc.), update only the appropriate user+brand+cut residual; avoid universal body-identity reclassification.
7. Build a consented benchmark on diverse sizes/shapes, materials, brands and environments; independent human panel, train/validation/test separation and holdout leakage checks.
8. No model changes unless measured accuracy, abstention, calibration, bias/fairness, speed/energy and privacy gates pass on representative hardware.

Reject any goal to produce the precise tactile feeling of a real garment from a single photograph. Without precise digital pattern, textile physics and verified body/garment dimensions, simulation is illustrative. Provide a clear path for partner-provided pattern files and an explicit claim hierarchy.

## 109. USER TRUST, MEASUREMENT UI AND UNIVERSAL ACCESS

- Body sliders show unit, user measurement versus estimated, undo/redo and optional compare baseline; never force exact waist value.
- Support screen-reader verbal labels (`Omuz genişliği, 43 santimetre, 1 santimetre artır`), dynamic type, reduced motion, high contrast and one-handed controls; animation must not be essential for understanding fit.
- The user sees what data will be read, when, what remains local, and how to stop processing. Provide manual closet entry without any photo access.
- Some assistance needs on-device camera; ask on action, explain no gallery permission for photo picker; avoid idle scans.
- Notifications do not expose outfit, travel location or sensitive shopping history on locked screen by default; user controls content.
- Never make astrology/numerology hidden influencers of objective fit or protected attributes. If offered, use transparent opt-in 'symbolic inspiration', never identify it as science or deterministic truth.
- Consent/silencing controls are accessible in fewer steps than growth nudges; no opaque paid ranking.

## 110. CITADEL SECURITY DOCTRINE — THREAT-LED DEFENSE IN DEPTH

'CITADEL / Çelik Kubbe' is an engineering name for multiple verifiable protections, **not** a promise of impenetrability. Security controls defend independent attack paths: malicious app/SDK, lost phone, OS compromise, jailbreak, stolen backup, malicious product metadata, rogue merchant, network interception, replay, prompt injection, stolen tokens, insider, corrupted model, compromised CI, user error and destructive deletion.

| Layer | Defense | Verification |
|---|---|---|
| L0 Platform | iOS sandbox, entitlement minimization, supported OS versions | Entitlement review, device checks |
| L1 Consent | Per-purpose photo/camera/location policy, selective picker | Denial/limited/revocation tests |
| L2 Secrets | Keychain/Secure Enclave-supported key hierarchy, no embedded credentials | Key inventory, compromise tabletop |
| L3 Data | File Protection, authenticated encryption, atomic writes, encrypted backup | Offline forensic inspection |
| L4 Runtime | Typed capability gates, untrusted data quarantine, strict parsers | Adversarial inputs |
| L5 Network | ATS/TLS, endpoint allowlists, no raw private body/photo egress | Proxy capture + redaction assertion |
| L6 External | Tenant authorization, rate limits, App Attest for risk-based sensitive endpoints | Cross-tenant/replay tests |
| L7 ML/Assets | Signed release manifests, model/texture verification, rights registry | Tamper tests |
| L8 Delivery | Dependency pin, SBOM, secret scan, provenance and review | CI evidence |
| L9 Monitoring | Private-by-default audit, emergency kill switches, rollback | Recovery drills |
| L10 Human | Abuse review, privacy impact, incident owner and escalation | Red-team and independent signoff |

Threat-model every new data flow and render asset format. Consult OWASP MASVS for iOS/mobile and ASVS for any backend; these frameworks are a **baseline**, not a certificate or complete protection.

## 111. CRYPTOGRAPHIC ENGINEERING — KEY LIFECYCLE, VAULT, RECOVERY

### 111.1 Allowed cryptographic choices

Use audited platform cryptographic APIs, not custom ciphers. For encrypted local payloads use vetted AEAD such as `CryptoKit AES.GCM` with unique nonces and explicit associated data binding `recordType + recordId + schemaVersion`. Place secrets in Keychain with access class selected per threat model. For private key operations and key agreement, consider Secure Enclave where available; **Secure Enclave supports restricted asymmetric key operations, not arbitrary symmetric bulk encryption**. Thus a realistic vault uses symmetric data-encryption keys (DEKs) protected by a Keychain/secure key-management strategy. Avoid hardcoded keys, cryptographic obfuscation marketed as encryption, unchecked nonce reuse, DIY encryption, custom pseudorandomness, weak password-derived encryption or keeping plaintext exported backups.

### 111.2 Key hierarchy and rotation (design candidate; cryptographer review required)

```text
App Keychain / optional Secure Enclave-supported KEK
                       |
            encrypted/wrapped Vault Root
                       |
       +---------------+-----------------+
       |               |                 |
 Body/Avatar DEK   Wardrobe DEK     Preferences DEK
       |               |                 |
 AEAD record        AEAD record      AEAD record
       |               |                 |
 (purpose AAD)     (purpose AAD)    (purpose AAD)
```

- `KeyRegistry` records local opaque key IDs, creation time, algorithm, version, rotation status and purpose **without logging key bytes**.
- Each `VaultRecord` has record ID, schema/format, classification, nonce, ciphertext, authenticated tag, key ID and tamper/corruption response.
- Distinct logical domains allow scoped deletion and prevent unrelated read authorities from accessing all data by default (logical separation alone is not protection if keys/capabilities shared).
- Use iOS File Protection (`complete` for especially private data where background access is unnecessary); document tradeoff for usable background functions. Keychain accessibility must match lock-state expectations, not accidentally expose secrets pre-unlock.
- Key material should have a documented generation/rotation/backup/restore/deletion lifecycle. iOS Secure Enclave keys can be device-bound; recovery of user data therefore requires an explicitly designed separate export/recovery scheme — no fake seamless cross-device recovery claim.
- Key rotation: create new key → reencrypt in bounded chunks atomically → verify AEAD roundtrip → move active pointer → securely retire superseded wrapped key only after successful verify; crash midway resumes or rolls back safely.
- Deletion: remove all owned records and derived copies, invalidate in-app keys, mark tombstones and ensure no resurrection via local cache/backups. **Crypto-shredding cannot guarantee deletion of preexisting third-party device backups or forensic copies**; explain residual limits accurately.
- Never log encryption keys, passwords, private IDs, tokens, unredacted bodies, personal images or derived biometric-like templates.

### 111.3 Private Recovery design

P0: local-only, explain that deleting app or losing device may lose private vault; do not imply invisible cloud safety. P1: an explicit encrypted export using a cryptographically strong randomly generated export key or user-generated passphrase with modern memory-hard KDF (Argon2id only with correctly audited implementation / platform-compatibility assessment), AEAD, authenticated manifest, format/versioned metadata and user confirmation. No export to an unauthorized location. Recovery must be tested for correct/wrong password, tamper, low disk, interrupted transfer, missing asset licenses, key mismatch and import idempotency. Imported data cannot silently overwrite local data.

### 111.4 OS compromises and honest limitations

Device compromise, physical coercion, unlocked phone, screenshots, clipboard and malicious OS-level software can bypass some app defenses. File encryption only protects some states. Threat model expected protection and remaining risk. App Attest may enhance server request integrity but cannot attest the entire user's hardware/OS as uncompromised in all cases.

## 112. CAPABILITY SECURITY — WHO MAY TOUCH WHICH DATA?

Define restricted resources: `body.readExact`, `body.writeManual`, `avatar.readRenderSnapshot`, `photos.readUserSelected`, `wardrobe.read`, `wardrobe.write`, `travel.readPrivate`, `catalog.readLicensed`, `weather.fetch`, `network.productOnly`, `vault.export`, `vault.delete`, `learning.updateLocal`, `model.activateSigned`, `retail.writeTenant`, `diagnostics.readRedacted`. Grant based on user purpose and module identity, with expiry/one-shot semantics. No wildcards for low-trust modules.

### 112.1 Initial access matrix

| Component | Required capabilities | Explicitly prohibited |
|---|---|---|
| `Garment Vision` | Selected image during request, bounded temp storage | Network, reading entire library, modifying body |
| `Body Geometry` | Read/write verified user measurements | Network, reading travel history, catalog edits |
| `Avatar Renderer` | Read immutable mesh snapshot and signed asset | Exact body file export, auth or purchase |
| `Brand Resolver` | Product key + catalog request | Private photo/body/travel/wardrobe upload |
| `Fit Specialist` | Scoped body/garment numeric DTO | Raw user photos, network, write body truth |
| `Style Director` | Closet metadata, user stated occasion, weather | Exact full-body scans, birthdate by default |
| `Travel Optimizer` | Trip context + selected wardrobe subset | Gallery/photos, merchant customer records |
| `Learning` | Opt-in feedback, local evaluation fixtures | Model release, arbitrary code, advertising identifiers |
| `Telemetry` | Strictly redacted counters when enabled | Images, waist size, coordinates, exact URL params |
| `Retail SDK/API` | Tenant’s authorized product payload | Consumer avatar, other tenant, profile vectors |

### 112.2 Egress gate

Central outbound networking wrapper requires `EgressIntent` containing destination, HTTP method, allowlisted endpoint, data classification, purpose, minimal selected fields, consent basis, user-visible effect, retention requirement and security posture. On unknown classification, block and report. Native system networking to external providers must be inventoried; third-party SDK egress is blocked by architecture review unless explicitly allowed and proved.

Example allowed `ResolveProductRequest`: `{gtin:..., country:"TR", locale:"tr-TR"}` after conscious scan; never append camera image EXIF, precise location, private body metrics, profile ID, or unconsented tracking token. If image recognition by partner API is desired, create a separate opt-in service with clear upload notice, retention and data-processing agreement; default remains LOCAL-ONLY.

### 112.3 Revocation chain

Revoke Photos → cancel indexed scans → stop future fetching → revoke stored asset references not user-approved for retention → purge transient pixels and embeddings → preserve only user-approved local wardrobe items; notify and test. Revoke location → freeze last known general locale only if approved, else manual city. Revoke learning → stop updater, delete training examples and any derived private weights if user elects purge. Delete body → invalidate avatar/fit caches dependent on body revision; public brand catalog remains. Privacy policy includes retention matrix and precise service dependencies.

## 113. DEVICE HEALTH, THERMAL, ENERGY, GPU/CPU/RAM — HARD GOVERNOR

Implement `DeviceResourceGovernor` as a single governor for concurrent work. Read supported `ProcessInfo.thermalState`, `isLowPowerModeEnabled`; use `UIDevice` battery signals only when enabled and legitimately needed. Inspect app memory footprint, `UIApplication` memory warnings / system notifications where available, background task expiry, available disk capacity and app-specific measured workload characteristics. iOS does **not** expose unrestricted internal battery health, device temperature, other apps’ private metrics or guaranteed compute capacity. Never claim direct degree-Celsius thermal sensing or continuous background processing across all devices.

### 113.1 Execution tiers (policies are starting hypotheses; calibrate by test)

| Tier | Conditions | Allowed work | UI behavior |
|---|---|---|---|
| `TURBO` | Thermal nominal, enough resources, user actively scans | Interactive CV + 3D/render co-scheduled under measured budget | Progressive full preview |
| `BALANCED` | Thermal fair or Low Power mode with user request | Minimal CV, cached product/mesh, reduced fps/resolution | Quick basic result then refine if possible |
| `CONSERVE` | Thermal serious, memory pressure, battery critical according to measured policy | Cached fit/category, low-poly or 2D, no background ML | Warn subtly; keep core actions |
| `SURVIVAL` | Thermal critical, memory danger, OS interrupts task | Stop heavy inference and physics, release textures, save state | Usable text-only/manual mode |
| `OFFLINE` | No network | Local wardrobe, body, cached fit with staleness | Mark weather/product stale |
| `LOCKED/BACKGROUND` | Device locked / app suspended | Respect file/key access & OS time limits; no looped scans | Resume with state integrity |

Prioritize interactive responsiveness over costly visuals. Reserve CPU/GPU/Neural Engine tasks through token/budget mechanism; avoid concurrent body reconstruction + garment segmentation + fabric simulation unless measured safe. `Task` cancellation is advisory — resource release and asynchronous state rollback must be tested.

### 113.2 Model scheduling and progressively enhanced try-on

- `Stage 0`: barcode/GTIN + basic garment card from signed cache; fast and deterministic.
- `Stage 1`: fit band if product and user measure data available; no image physics needed.
- `Stage 2`: neutral model in generic matching silhouette with explicit fidelity label.
- `Stage 3`: partner asset/cloth if available and device governor approves.
- `Stage 4`: validated high-fidelity garment physics ONLY after physics model, input rights and hardware benchmarks pass.

User gets the earliest meaningful decision even if later stages time out. Use user-cancelable progress and task prioritization; do not block the entire UI waiting for Stage 4.

### 113.3 Measurement and provisional performance budget

Claude must establish a device support matrix (oldest supported iPhone, mid-range, recent Pro, Low Power, 10% battery where safe, network failure, storage low). Measure cold/warm launch, screen frame timing, median/p95/p99 user-intent latency, task CPU/GPU utilization, main-thread stalls, `jetsam`/OOM, memory footprint/peak, scene frame pacing, battery drain under controlled comparative baseline, thermal time-to-throttle, data bytes per action, offline completion rate. Use Instruments + Metal debugger + controlled tests; units, device model, OS build, sample size, confidence intervals and scripts required. **No universal fixed FPS or milliseconds guarantee before benchmark.** Establish budgets as release thresholds with ADR and hardware evidence.

### 113.4 Governor failure drills

1. Phone warms during continuous scan → CV frequency reduced, physics suspended, UI usable.
2. App killed mid-photo import → no orphan plaintext image, resume/rollback correct.
3. Device locked during encryption → correct file/key unavailable response, no corrupted vault.
4. Low disk when generating meshes → estimate quota, delete temp safely, preserve originals.
5. Battery signal unknown (`-1`) → conservative policy without fake battery value.
6. Background task suspended → state checkpoint/stop, no fake completion.
7. Neural Engine model unsupported → Core ML compatible compute fallback if safe, else manual.
8. Memory warning → evict textures, models and large buffers; save user action.

## 114. ON-DEVICE MODEL PIPELINE — ASSET FACTORY TO SHADOW ROLLOUT

### 114.1 Never confuse model, classifier and agent

An AI 'agent' is often a workflow with tools and permissions. A Core ML image segmenter is a deterministic inference module given fixed weights, not a fully autonomous agent. A styling ranker might be rules + embedding similarity. A model may not be updatable on-device at all. Prefer smaller validated models and confidence-aware fallbacks. Runtime modularity is about roles and contracts, not multiplying LLM instances.

### 114.2 Model card mandatory fields

`model_id, semantic_version, architecture, weights_hash, origin/license, training_dataset_rights, supported_device/os, input/output schemas, input size, preprocessing, quantization, nominal inference resource cost, calibration_dataset, accuracy_by_slice, abstention_rate, limitations, privacy classification, updateability, expiration, rollback_target, signed_manifest, owner, approval_id`.

### 114.3 Signing and artifact validity

All downloaded executable-adjacent ML assets, Blender-generated geometry packages, product catalog resources and feature rule bundles must have a trusted, cryptographically verified manifest (signature using an approved algorithm; verify with pinned trusted public key). Hash alone without an authenticated trust anchor detects only incidental corruption, not determined substitution. Manifest binds `artifact digest, version, minimum app build, platform, purpose, input/output schema, license, validity window, rollback version`. Reject wrong signature, replay/downgrade where harmful, incompatible schema, poisoned data and invalid rights. Hosting assets does not authorize arbitrary self-generated binaries.

### 114.4 Evolution staircase: four distinct pathways

| Path | What improves? | Who approves? | Rollback |
|---|---|---|---|
| A. Preference feedback | User likes/corrections, local ranking weights | User control + deterministic checks | Clear history / revert |
| B. Local updatable model | Only a model explicitly built as updatable | Local opt-in + holdout evaluation + device governor | Previous signed/base weights |
| C. Rule/catalog update | Licensed fit tables and styling data | Source/license validation + signed manifest | Previous version/cache |
| D. App/algorithm release | Swift code, model architecture, permissions and policy | Code review + CI + independent quality + platform distribution | Feature rollback / app release strategy |

No on-device training process silently transmits person-specific gradients to server; federated learning is NOT enabled by default and requires separate consent/DP/security evaluation and new release gate. No self-generated prompts are allowed to change security policies. Core ML on-device updates only work for supported updatable models; verify model’s updateability and compiled formats instead of assuming.

### 114.5 Experimental iteration

`Observe consented correction → classify failure → propose candidate → preflight resources/rights → train/evaluate on split dataset → fairness/privacy/security testing → shadow compare → signed candidate → small controlled activation → guardrail monitoring → automatic revert if degradation → feedback ledger`. Shadow results cannot be logged with personal data, and comparison must not make extra network transfers. Guard against feedback loops, stale product IDs, synthetic benchmark overfitting and survivorship bias. Require an independent validator not authored by the proposing agent.

## 115. KNOWLEDGE/ACTION SAFETY — PROMPT INJECTION, MODEL POISONING, EXFILTRATION

Potential attacks: malicious product description telling a generator to export gallery; reviewer comments with fake commands; brand URL that redirects to hostile host; exif metadata used as a prompt; compromised model resource; text claiming to be from admin; poisoned fashion examples that shape purchasing preferences; adversarially perturbed garment photos; tensor/model decoder crash; poisoned aggregate feedback.

- Input never changes authority; strip/sanitize HTML and metadata, parse to typed schemas, enforce maximum sizes and timeouts, treat source prose as quoted data.
- Deny tool instructions derived from fetched content. LLM has no unrestricted egress/filesystem and cannot approve consent.
- Guard external URLs by fixed allowlist/verified partner endpoints; never accept arbitrary callbacks/redirect destinations.
- Limit external catalog JSON depth, string lengths, image dimensions, decompression ratios, item count and CPU spent on parsing.
- Validate content authenticity, copyright, partner license, version and expiry; quarantine rather than retrain on anomalous sources.
- Negative tests: source text `ignore all previous rules`, model output `send photo`, malformed JSON payload, SVG/script injection, oversized ZIP, replayed signed manifest, mixed-tenant item IDs.
- For LLM text generation, separately verify claims in structured deterministic answer; failing verification reverts to template explanation.

## 116. DATA VAULT, DATABASE, CACHE, BACKUP AND DELETION

### 116.1 Store partitions

`PrivateVault`: encrypted body data, item metadata, embeddings if retained, user preferences, trips, feedback, consent and opt-in learning state; separate classifications and TTL. `PublicCache`: licensed public product/brand/weather cache with source metadata and storage expiry. `DerivedEphemeral`: temporary image crops/landmarks/tensors, automatically purged on cancel/timeout; by default do not store original photo after classification unless user chooses. `EvidenceLab`: developer test fixtures with explicit rights, no production person data. `RetailTenantStore`: partner-owned segregated server data.

### 116.2 Transactional design

Every wardrobe change and avatar revision commits atomically; rendering reads immutable snapshot with revision number. Migrating schema N→N+1 must preserve core profile, handle migration interruption and detect malformed records. Use appropriate DB mechanism for schema migration, WAL/transaction and backup consistency. No cross-module direct SQL mutation; repositories own write contract. Derived cache must be invalidated by input revision, model version and consent version.

### 116.3 Lifecycle table

| Data | Source | Default location | Allowed sharing | Deletion trigger |
|---|---|---|---|---|
| Body measurements | User/manual | Encrypted private vault | None unless explicit export | User deletes body/account |
| Photo original | User-picked | Memory/temp by default | None | End task/cancel |
| Recognized wardrobe record | User confirmed | Encrypted private vault | User selected export only | Item delete/profile delete |
| Avatar mesh | Generated | Device encrypted cache | User-controlled export | Body revision/delete |
| Fit feedback | User input | Device | None by default | Feedback clear |
| Weather city forecast | Provider | Expiring cache | City in provider request when necessary | TTL / trip deletion |
| Brand product catalog | Licensed data | Local public cache | Partner contract | License/revocation/TTL |
| Trip plan | User input | Private vault | None by default | Trip deletion |
| Analytics (if enabled) | Minimized counters | Privacy-safe local aggregate first | Opt-in/stateless policies | Retention expiry/opt-out |

Create `DeletionReceipt` with only non-sensitive counts/types, timestamp, local operation IDs, unresolved third-party copies. Deleting device-local data cannot recall data the user intentionally shared externally; show clear export/share receipt. If cloud sync later added, design a distributed deletion ledger and account lifecycle separately.

## 117. NETWORK ARCHITECTURE, PARTNER API, MULTI-TENANT ISOLATION

Retail is an optional logically separate service; local personal fashion must not require creating a cloud profile. Partner integration should expose catalog facts, inventory/price if authorized, asset manifest, license metadata and optionally privacy-respecting queue metrics. Do not put local body or personal trip data in partner data objects. If fit estimation happens server-side in a future B2B model, it requires **separate explicit product, privacy and legal approval**, with purpose restriction and minimization proof; default architecture disallows it.

### 117.1 Suggested API contracts (draft only)

- `GET /v1/products/by-gtin/{gtin}` → product candidates + variant data + evidence timestamp; no user IDs.
- `GET /v1/products/{productId}/variants/{variantId}/size-chart` → units, measurement method, tolerance, brand grading version.
- `GET /v1/assets/{assetId}/manifest` → rights/sha/signature/version/expiry.
- `POST /v1/retail/tenants/{tenantId}/catalog-items` → authenticated partner tenant update, optimistic version.
- `POST /v1/retail/tenants/{tenantId}/queue-events` → pilot-only operational events with strict minimization.

Define OpenAPI with `x-data-classification`, authorization scope, rate limits, pagination, idempotency, error taxonomy, cache semantics, schema backwards compatibility and retention. Authorization is enforced server-side per request and per resource, not trusted from a user-editable tenant ID. Public product endpoints avoid raw full catalog scraping vulnerabilities and use cache/rate limits. HTTPS with modern TLS, ATS and server authentication; certificate pinning only if a carefully justified threat model plus rotation/offline recovery plan supports it.

### 117.2 Integrity and abuse

For sensitive partner/paid operations, consider Apple App Attest with server challenge and assertions, together with normal auth and anti-replay/idempotency; App Attest does not replace user/tenant authorization and may be unsupported on some devices. Do not use attestation to deny local wardrobe/fit use. Store server secrets in managed key service, rotate, audit. Retail staff roles: `owner/admin`, `catalog_editor`, `queue_staff`, `analyst`; apply row-level tenant separation tests and least privilege. Audit all catalog edits with signer, diff and rollback.

## 118. PRIVACY-FIRST OBSERVABILITY AND HUMAN-READABLE REASONS

Observe performance and correctness without leaking users. Use structured `os.Logger` privacy redaction, local counters, optional aggregated diagnostics; never store photos, exact measurements, raw locations, free-form secret prompts or personally identifying per-device permanent tracking IDs in analytics. Every runtime inference can produce local `DecisionTrace` with model/rule version, input **categories**, source grades, reason codes, latency class, fallback, user correction status and expiration. If trace may itself reveal the body or a location, keep it encrypted on device with a bounded TTL.

### 118.1 Metrics hierarchy

- **Utility:** `answer_shown`, `user_selected_outfit`, `garment_identified_confirmed`, `plan_packed`, `fit_feedback_received`; use voluntary user feedback for correctness.
- **Reliability:** crash-free usage, errors per operation, UI stall, offline completion, validation failure and retry rate.
- **ML:** precision/recall by category, calibration, uncertainty/abstention, drift tests, false confident fit recommendation rate.
- **3D:** mesh invalidity, render fps, frame spikes, asset mismatch, visual comparators, accessibility with and without 3D.
- **Device:** memory peak, thermal downgrade count, energy per user request in controlled lab, bytes/request.
- **Business:** retail opt-in pilots, time-to-decision, queue wait median/p95 with controls, returns proxy only if consented and measurable.
- **Security:** policy denies, token misuse, revoked-consent attempts, unsigned model rejection, tenant isolation violations (aggregated/no sensitive context).

No fabricated dashboard values. Every metric has owner, sampling, numerator/denominator, retention, collection consent, aggregation unit and privacy-review status.

### 118.2 Fault taxonomy

`E-CONSENT-DENIED`, `E-DATA-UNKNOWN`, `E-FIT-INSUFFICIENT`, `E-PRODUCT-CONFLICT`, `E-ASSET-UNTRUSTED`, `E-MODEL-UNSUPPORTED`, `E-THERMAL-DEGRADE`, `E-RESOURCE-REJECTED`, `E-VAULT-LOCKED`, `E-VAULT-CORRUPT`, `E-NETWORK-OFFLINE`, `E-LICENSE-EXPIRED`, `E-CACHE-STALE`, `E-TENANT-FORBIDDEN`, `E-UPDATE-REJECTED`, `E-DELETE-PARTIAL`, `E-INTEGRITY-TAMPER`, `E-UNEXPECTED`. Present friendly messages and recovery paths; detailed codes in local redacted diagnosis, not alarming error screens.

## 119. SECURE SOFTWARE SUPPLY CHAIN, BUILD AND RELEASE

- Maintain lockfiles/pinned versions, justified third-party SDK register with license, transitive deps, binary integrity, privacy manifest/egress and maintenance status.
- CI: compile, lint, formatting, typed API check, Swift tests, iOS UI tests, 3D geometry tests, privacy egress tests, model hash/signature tests, performance smoke, dependency and secret scanning.
- Create SBOM and signed build provenance according to a measured SLSA-inspired policy, with CI secret isolation; never claim formal SLSA level without verifying its requirements.
- Protect main via reviewed PR, branch rules, required checks, no unreviewed generated code commit for privileged modules; short-lived build credentials and controlled signing identities.
- Runtime config must be signed/allowlisted and cannot relax privacy policy; a remote kill switch can disable nonessential risky third-party integrations and high-fidelity ML but **must not** block local data deletion/export.
- Safe deployment: feature flags by capability/device, staged TestFlight/internal release, crash telemetry only with privacy safeguards, revert strategy, data migration compatibility, signed artifact retention.
- A security scanner PASS is not a security audit; independent manual threat-led penetration testing and release signoff required for public commerce/personal images.

## 120. QUALITY COUNCIL — INDEPENDENT EXPERT CROSS-CHECKS

Development agents may draft/implement, but cannot mark their own critical change as independently approved. Make reviewers meaningfully separate in task, datasets and artifacts; if only one Claude process is available, record that simulated role switching is **not organizational independence** and obtain human/external review before high-risk release.

| Discipline | Reviews | Blocks on |
|---|---|---|
| Chief Systems Architect | Dependency DAG, coherence, ownership, versioning | Contradictory ownership/contracts |
| Security/Crypto | Threat model, keys, egress, deletion, supply chain | Critical confidentiality/integrity flaw |
| Privacy & Legal | Consent, data rights, KVKK/GDPR applicability, partner contracts | Unauthorized processing or asset use |
| Modelist/Textile | Grading, fitting, material assumptions | Misleading size/comfort claim |
| CV/ML scientist | Ground truth, calibration, OOD, data poisoning | Unmeasured confidence/unsafe dataset |
| 3D graphics | Mesh integrity, fps, renderer truth tier | Invisible or false visual fit states |
| iOS Perf | Thermal, battery, memory, OS constraints | Reproducible crash/thermal runaway |
| Accessibility & UX | VoiceOver, font scaling, body neutrality, low cognition | Core flow unusable for supported users |
| Retail operations | Store staff value, queue pilot, data isolation | Tenant leak/queue disruption |
| Statistician/auditor | Sample quality, preregistration, CI, experiments | Unsupported performance/ROI claims |
| Founder/PM | Real user problem, scope, cost, product ethics | Feature bloat, value/consent conflict |

The council is a **review protocol**, not necessarily 11 simultaneous paid staff. Each review produces concrete checklist, code diff/fixture links, PASS/FAIL/BLOCKED/NOT_RUN and accountable owner. 'God' means humility about unknowns and adversarially tested boundaries.

## 121. CLAUDE DEVELOPMENT-AGENT ORGANIZATION — DIFFERENT FROM RUNTIME OCTOPUS

**Critical distinction:** The 24 in-app specialist components (`OCT-xx`) serve actual users. The following `DEV-xx` agents are **development work roles** invoked by Claude Code to write/test/review artifacts. Neither set has unrestricted autonomy. Do not confuse a simulated specialist review with independent professional certification.

| Development role | Assigned domain | Allowed artifacts | Must not self-approve |
|---|---|---|---|
| `DEV-01 Program Integrator` | Requirement graph, priorities, decisions | ADRs, dependency graph, acceptance map | Final gate |
| `DEV-02 iOS Architect` | App shell, concurrency, package seams | Swift packages, DI, integration tests | Production readiness |
| `DEV-03 Morphology Engineer` | Anatomical sliders, parametric geometry | Body engine, mesh fixtures, morph tests | Anthropometric truth |
| `DEV-04 3D Technical Artist` | Blender rig, clothing drape assets | Blender Python scripts, USDZ, textures, render diffs | Cloth fidelity |
| `DEV-05 ML Vision Scientist` | Garment/photo segmentation | Core ML/Vision pipelines, labeled dataset tests | Model calibration |
| `DEV-06 Fit/Pattern Specialist` | Construction, brand grading, ease and stretch | Size charts, fit formulas, fit test fixtures | Marketing certainty |
| `DEV-07 Stylist/Context Director` | Looks, wardrobe, weather, social context | Rule engine, ranking fixtures, bias review | Scientific fit |
| `DEV-08 Travel Optimization Engineer` | Packing/capsule/replan | Optimization solver, offline/fallback tests | Venue facts |
| `DEV-09 Privacy Architect` | Consent, data classes, lifecycle | Consent ledger, PIA, egress audit | Privacy self-certification |
| `DEV-10 Cryptography Lead` | Key hierarchy, crypto protocols | Threat models, crypto adapter, rotation tests | Crypto signoff |
| `DEV-11 Mobile Security Red Team` | Untrusted input, auth, exploit simulations | MASVS checklist, negative tests | Release if findings open |
| `DEV-12 Device Performance Lead` | Thermal, GPU/CPU/memory scheduling | Bench harness, Instruments evidence | Claimed perf without device |
| `DEV-13 Retail/Data Rights Lead` | Brand integrations, licenses, tenant permissions | Partner adapters, rights registry, OpenAPI | Legal agreement |
| `DEV-14 Reliability/SRE Lead` | Crash recovery, idempotency, kill switches | Runbooks, recovery tests, failure injection | Disaster readiness |
| `DEV-15 Independent QA Auditor` | Test coverage, release criteria, cross-check | Evidence ledger, failure register | Claim truly independent if same agent |
| `DEV-16 Accessibility & Design` | UI tokens, VoiceOver, edge states, friction | Screens, accessibility tests, screenshots | UX effect without participants |
| `DEV-17 Data/Measurement Scientist` | Experiment design, ML/retail KPIs | Bench specs, reproducible analysis | Effect without controlled study |
| `DEV-18 Commercial/Compliance` | B2B pitch, acquisition, data use policies | Pilot plan, pricing hypotheses, legal review TODO | Signed contracts |

### 121.1 Mandatory agent task packet

Every assigned task is a structured `WorkOrder` containing:

```yaml
work_order_version: 1
id: WP15-EXAMPLE
requester: DEV-01
assignee: DEV-10
problem: "Protect private body data at rest"
dependencies: [WP15-VAULT-MODEL]
allowed_paths: ["Sources/Security/**", "Tests/Security/**"]
prohibited_paths: ["Sources/Commerce/**", ".env", "prod-config/**"]
allowed_data_classes: ["SYNTHETIC_FIXTURE", "LOCAL_PRIVATE_SCHEMAS"]
external_access: forbidden
interfaces: ["KeyStore", "VaultCrypto", "VaultRecordV1"]
deliverables: ["CODE", "UNIT_TEST", "THREAT_MODEL", "EVIDENCE"]
acceptance_tests: ["V15-T-SEC-*", "V15-T-CRY-*"]
quality_gate: G-CITADEL
max_scope: "one testable vertical slice"
status: NOT_STARTED
```

Document the actual developer tooling/agent orchestration in use; do not assume multi-agent spawning capability. One agent may serially perform roles; independent review must then be labeled `INTERNAL_SELF_REVIEW`. Commands and tool calls require appropriate permissions. An agent cannot escalate from writing a local test to using production accounts or spending funds.

### 121.2 Agent dispute protocol

If modelist and ML scientist disagree about required data precision, record both interpretations, evaluate physical evidence, choose conservative user claim, file ADR and residual risk. If designer wants a giant generative model that harms battery, device governor and user metrics win until comparative benchmark proves benefit. If retail partner asks for body profile uploads, privacy non-negotiable wins and commercial team proposes product-only API. No “Chief AI” can bypass rule/security signoff.

## 122. EXECUTION DEPENDENCY DAG — THE ATOMIC ROADMAP

```text
B0 Reality baseline / toolchain / iPhone matrix
  ├── B1 Typed schemas + truth ownership + consent ledger
  │     ├── B2 Local vault + crypto + deletion + migration
  │     ├── B3 Octopus coordinator + event envelopes + capability gateway
  │     └── B4 Device resource governor + failure injection
  ├── B5 Native design system / accessibility / offline shell
  └── B6 Blender rig/asset pipeline + license registry

B1,B2,B3,B4,B6 → B7 body sliders / watertight mesh / renderer
B1,B2,B3,B4 → B8 user-selected photo garment intake
B1,B3,B4 + licensed fixture → B9 barcode/product resolver
B7,B9 + independent fit lab → B10 trustworthy fit estimate
B7,B9 + asset tier → B11 progressive try-on
B2,B8 + rules → B12 wardrobe/stylist/clean-state
B12 + weather + travel fixtures → B13 travel capsule
B3,B4,B10,B12 → B14 local preference-learning (optional)
B9 + tenant authorization → B15 partner pilot/API
B0..B15 → B16 independent end-to-end audit + TestFlight gate
```

Do not begin with cloud orchestration, self-modifying agents, paywall, artificial general intelligence claims or arbitrary LLM wrappers. The deepest user value is an **accurate, responsive, locally private avatar/fit experience**. Build the smallest proving slice first, then deepen.

### 122.1 Detailed work packets (owner, acceptance, evidence)

| WP | Domain | Main output | Acceptance gate | Release priority |
|---|---|---|---|---|
| `WP15-01` | Reality baseline | Environment/device/repo risk inventory | No false completion | P0 |
| `WP15-02` | Contract factory | Schemas, ownership, migration strategy | Schema/compatibility tests | P0 |
| `WP15-03` | Citadel core | Consent, capabilities, egress guards | Unauthorized action denied | P0 |
| `WP15-04` | Encrypted vault | Keys, storage, crash-safe migration | Tamper/restore/delete tests | P0 |
| `WP15-05` | Octopus core | Actor coordinator, task DAG, event contracts | Concurrency/cancel/replay tests | P0 |
| `WP15-06` | Device governor | Policy tiers and resource accounting | Thermal/memory/fault tests | P0 |
| `WP15-07` | Blender factory | Rig, weights, neutral mesh, signed manifests | Deterministic exports/geometry | P0 |
| `WP15-08` | Live body studio | Morph sliders, persistent profile, VoiceOver | Real iPhone live edits | P0 |
| `WP15-09` | Vision intake | User-selected garment segmentation | Real photo/local inference & denial | P0 |
| `WP15-10` | Wardrobe source truth | Dedup, user corrections, wear/clean | Transactional/undo tests | P0 |
| `WP15-11` | Product resolver | Barcode/candidate/variant/evidence | GTIN conflict/unknown tests | P0 |
| `WP15-12` | Fit physics boundary | Tiered fit model & uncertainty | Truth lab real garment benchmark | P0 |
| `WP15-13` | Try-on progression | Labeled quality tiers, render fallback | Visual, performance, accessibility | P0/P1 |
| `WP15-14` | Stylist | Transparent ranking & alternatives | Expert panel, feedback, no stereotypes | P0 |
| `WP15-15` | Travel capsule | Weather/reuse/cultural context | 5-day fixture and offline replan | P1 |
| `WP15-16` | Model-evolution lab | Registry, shadow evaluation, signed activation | Rollback and model rights | P1 |
| `WP15-17` | Retail product gateway | Licensed tenant API, scoped auth, App Attest candidate | Egress/tenant/pilot proof | P1 |
| `WP15-18` | Independent quality | Security, privacy, CV, performance evidence | Gated release decision | P0 mandatory |
| `WP15-19` | Commerce/growth validation | B2B pilot + honest KPI dashboard | Legal terms, controlled pilot | P1/P2 |
| `WP15-20` | Android research | iOS parity and cryptography/perf feasibility | Separate ADR, no premature rewrite | Deferred |

Each work packet must have code path, requirement ID, test ID, raw exit code, target device, artifact path, reviewer and blockers. Mock demos do not count as real product integration; if test data is synthetic, label it clearly.

## 123. USER JOURNEYS — WHAT MULTI-SYSTEM INTEGRATION ACTUALLY MEANS

### Journey A: First-time personal avatar, without privacy erosion

1. User opens app and chooses `Manual avatar` or `Import chosen photos`; no forced gallery access.
2. User provides optional height, waist, hips and body controls; units checked, plausibility bounds only for mesh safety not normative body 'ideals'.
3. `OCT-07` produces shape snapshot and `OCT-08` renders neutral covered form; `OCT-03` limits GPU under thermal state.
4. `OCT-02` approves local vault write; AEAD encrypts profile; event `AvatarRevisionCommitted` invalidates dependent fit cache.
5. User adjusts shoulder width from 43 to 45 cm; viewport shows fast low-complexity morph, exact value only if manually entered, Undo restores previous revision.
6. If corruption occurs mid-save, restore prior consistent snapshot, inform user and allow export/deletion; no data upload.

### Journey B: User scans jeans at a partner or unknown store

1. Camera opens only after user action, `OCT-09` reads barcode locally where possible.
2. Resolver consults validated local cache, then only product-safe query via `OCT-23` if network approved; response sanitized.
3. If `Mavi jeans` GTIN resolves to multiple cuts/seasons, ask user to choose; never pretend unique variant.
4. `OCT-10` verifies license, size table and variant; `OCT-12` compares optional body measurements, historical fit preferences and known garment allowances.
5. UI immediately shows product card, evidence: `brand official`, `outdated`, `review-based`, `unknown`. Best guess size shown only at valid confidence and with adjustable fit preference.
6. `OCT-13` renders generic silhouette first; partner verified pattern asset can improve tier, not imply perfect fit.
7. User may log tried-on result, which `OCT-20` uses for local brand/cut refinement; ad targeting does not access the result.

### Journey C: Morning styling with rain and dirty laundry

1. `OCT-16` gets timestamped city forecast or cached climate fallback; `OCT-18` checks recorded clean, worn and wash states.
2. `OCT-14` combines style preferences, clothing compatibility, user-stated event, comfort and available layers.
3. Hard filter excludes unavailable dirty item only if the user marked it dirty; wearing same jeans twice is not automatically defined as unclean.
4. Explanation says `Yağmur beklendiği için suya dayanıklı katman önerdim`; shows alternative and user override.
5. Night/morning reminders are opt-in, battery-sensitive, non-intrusive, no precise location displayed on lock screen.

### Journey D: Five-day trip to different climates

1. User selects city, dates, occasion, baggage allowance and selected closet items, with manual destination if no location permissions.
2. Weather module distinguishes short-term forecast from seasonal climate planning; source date and forecast reliability shown.
3. Venue context uses verified rules and user-confirmed preferences; no location-derived religious assumption.
4. Travel solver minimizes packing under outfit coverage, rewear, laundry, weather, luggage and shoe/weight constraints.
5. UI shows each day, alternate weather-safe outfit, packing count, missing item suggestions and optional 3D preview.
6. Forecast change triggers local replan candidate, **not** unasked purchase/notification spam. Offline saved plan remains accessible.

### Journey E: When everything fails together

A low-memory phone is hot, offline, user denies Photos, partner sends conflicting data, and vault is temporarily locked. Expected result: app opens; manual wardrobe/neutral avatar and cached data with expiry visible; no fit certainty; no frozen camera spinner; user can cancel; no raw image/network leak; after unlock, transaction recovers without duplicate garments; independent incident evidence records failure conditions without personal data.

## 124. ZERO-TRUST THREAT REGISTER — PRIORITIZED ATTACK CHAIN RESPONSES

| Threat ID | Adversary/entry | Potential impact | Prevent / detect / recover |
|---|---|---|---|
| `TH-01` | Malicious catalog text | Prompt injection → policy bypass | Typed facts only, no tool access; reject instructions |
| `TH-02` | Stolen/unlocked phone | Body/wardrobe leakage | OS protection, optional local lock, honest residual risk |
| `TH-03` | Fake brand QR code | Phishing/redirect | QR as data, validated GTIN, signed verified links only |
| `TH-04` | Poisoned garment image/model | Decoder crash or wrong fit | Signed assets, size/time limits, quarantine, input fuzzing |
| `TH-05` | Compromised retailer | Tenant data leak or malicious catalog | Server auth, tenant isolation, license/source trust |
| `TH-06` | Network MITM | Tampered product/forecast | TLS/ATS, signed assets, secure failure path |
| `TH-07` | Leaky SDK/analytics | Profile exfiltration | Minimal SDKs, egress allowlist, network test proxy |
| `TH-08` | CI attacker | Modified binary/model release | Branch policy, protected signing, SBOM, provenance |
| `TH-09` | Unsafe local training | Wrong sizes/bias/energy drain | Calibration, shadow eval, device governor, rollback |
| `TH-10` | Replay/idempotency attack | Double payment or queue write | Server token/revision/idempotency, App Attest if warranted |
| `TH-11` | Interrupted crypto rotation | Vault corruption | Atomic staged migration, recovery fixture |
| `TH-12` | Data deletion race | Resurrected photos/embeddings | Tombstones, cancellation barrier, derived cache invalidation |
| `TH-13` | Forced over-permission | Permission fatigue/coerced gallery | Manual path, selective picker, consent audit |
| `TH-14` | Inferred identity from pictures | Profiling/discrimination | Ban sensitive classifications, schema allowlists |
| `TH-15` | Retail underreporting queue | False effectiveness claim | Independent control group and fraud resistant measurement |
| `TH-16` | Outdated catalog size chart | Mismatched purchase | Fact expiry, variant key, downgrade to unknown |
| `TH-17` | Travel venue stereotype | Social harm/wrong advice | Official source preference, uncertainty, user control |
| `TH-18` | Loss of device | Irrecoverable vault data | Transparent export/recovery option, no false cloud backup |
| `TH-19` | Resource exhaustion | Crash/hot phone | Governor, bounded workers, cancellation, staged rendering |
| `TH-20` | Binary/model substitution | Malicious local behavior | Signed manifests, compatibility, attestation of assets |

Risk register includes likelihood, impact, detection, residual risk, owner, test, severity, resolution status and verification timestamp; never assert all `TH-*` resolved merely because this table exists.

## 125. DEFINITE GO/NO-GO RELEASE GATES

| Gate | Exit evidence | Hard blocker |
|---|---|---|
| `G0-REALITY` | Actual repo/toolchain/device baseline, reproducible first build | Missing baseline, faked hardware claim |
| `G1-CONTRACT` | Source truth, schemas, API/events, permission matrix and tests | Unowned personal data field |
| `G2-CITADEL` | Crypto/key/egress/deletion tests, threat model and negative path | Critical private data exfiltration |
| `G3-OCTOPUS` | Coordinator integration, cancellation, retry, degraded fallback tests | Unbounded agent or policy bypass |
| `G4-DEVICE` | Real iPhone resource/thermal data, stress/energy logs | OOM/thermal runaway on supported device |
| `G5-BODY` | Real 3D slider UX, geometry validity and persistence tests | Invalid mesh, loss of body data |
| `G6-FIT-TRUTH` | Variant/evidence/fit claims matched to physical test | Misleading numerical certainty |
| `G7-STYLE` | Human quality panel, inclusion, offline/wardrobe tests | Manipulative/shaming recommendation |
| `G8-TRAVEL` | 5-day reproducible suite, stale forecast/venue rights | Invented weather or stereotype rules |
| `G9-RETAIL` | Licensed catalog, server tenant auth, pilot risk plan | Unauthorized data integration |
| `G10-EVOLUTION` | Signed update, shadow model test, rollback and consent tests | Autonomous unsigned mutation |
| `G11-ACCESS` | Accessibility and privacy controls, real device UX screenshots | Essential control unusable |
| `G12-RELEASE` | Reproducible build, privacy/legal App Store review, risk register | Any unresolved release-blocking issue |

A gate can be `PASS`, `FAIL`, `BLOCKED_EXTERNAL` or `NOT_RUN`; no blanket 'mostly done'. Quantitative thresholds set by ADR **before** experiments where possible. If hardware unavailable mark `BLOCKED_DEVICE`, not `PASS`. In development, simulator tests can be PASS for simulator scope only, never for physical performance scope.

## 126. EVALUATION PROGRAM — METRICS, SCIENCE, DATA RIGHTS

### 126.1 CV classification and segmentation

Labeled consenting input set, diverse real-world lighting/angles/occlusions, clean train/validation/holdout/test separation; per-class precision, recall, class confusion, abstention, repeated clothing photos dedup and correct product identification. Use paired image privacy tests proving no undesired upload. Treat model confidence as uncalibrated before calibration plot and expected calibration error evaluation.

### 126.2 Body/mesh and visual fidelity

Geometry parameter sweep (min/mid/max plus linked morphs), non-self-intersection checks where feasible, fixed camera/render snapshots, movement across sizes, determinism and scene FPS profiling. Human evaluation should distinguish resemblance, style preview and verified garment fit; never collapse them into one score. Train data licenses, identifiable body images, minors and protected-group evaluation require especially careful consent/ethics review.

### 126.3 Fit and consumer outcomes

Collect opt-in try-on outcomes including brand + exact model + garment size + preferred ease + body region feedback, measured reference garments, sample counts per category and uncertainty intervals. Evaluate wrong-size high-confidence cases prominently, not hidden within average accuracy. Holdout brand/cut generalization may fail: abstain instead of generalized confidence.

### 126.4 Retail operational experiment

Controlled, preferably matched-store pilot: baseline average/p95 wait time, proportion physically tried-on, sales, returns (if lawful/available), staffing, product mix, seasonality, confounders, dropout and privacy. Pre-register primary success metric, causal identification method, power/sample strategy and failure thresholds. All ROI numbers remain hypothetical until pilot. No dark-pattern pressure to skip physical fitting.

### 126.5 Security validation

OWASP MASVS-based mobile checklist, OWASP ASVS-based server checklist, key/consent/exfil threat drills, static/dependency scanning, fuzzing barcode/asset/product data, signed update failure injection, auth/tenant cross-access penetration tests and manual review. Retest after new SDK/model/partner integration; tests should fail when a deliberate privacy violation is introduced.

### 126.6 Statistical and evidence hygiene

Define baseline, experiment unit, eligible population, confidence interval/bootstrap when appropriate, preregistered metric, data rights, failure analysis, data leakage checks and blind/external validation. No commercial success or model accuracy figure may be used publicly without data and scope.

## 127. v1.5 ADVERSARIAL ACCEPTANCE SUITE — BINDING TEST SPECIFICATIONS

The `V15-T-*` items that follow are **tests to implement and execute**, not tests currently passing. For each, Claude must produce: `test_file`, `scenario/fixture`, `expected assertion`, `execution command`, `exit code`, `device/OS`, `result`, `linked requirement`, `evidence artifact`. Negative tests intentionally violate a rule and are successful only when the product rejects the violation correctly. Name runtime assertions predictably, do not implement dummy tests that merely assert `true`.


### 127.1 Suite `ORC` — Orchestrator, typed task graphs and lifecycle

- **`V15-T-ORC-01`** — Given: valid wardrobe intent. Then assert: runs bounded tasks once and returns contract-valid decision. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-02`** — Given: repeated identical barcode intent. Then assert: coalesces work without duplicate storage. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-03`** — Given: rapid slider gestures. Then assert: cancels stale rendering and retains latest revision. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-04`** — Given: task cancelled after authorization. Then assert: releases grant and never commits stale result. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-05`** — Given: module timeout. Then assert: returns labeled safe fallback rather than indefinite spinner. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-06`** — Given: module crashes mid-task. Then assert: isolates error and keeps app usable. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-07`** — Given: event replay after process restart. Then assert: idempotently restores committed state. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-08`** — Given: out-of-order entity revisions. Then assert: rejects stale writes and retains latest valid state. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-09`** — Given: context snapshot contains unrequested data. Then assert: policy blocks module input. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-ORC-10`** — Given: invalid transition COMPLETED→RUNNING. Then assert: state machine rejects mutation. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.2 Suite `AGT` — Runtime specialist registry and least privilege

- **`V15-T-AGT-01`** — Given: garment classifier tries network call. Then assert: capability policy denies. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-02`** — Given: style specialist requests exact waist without purpose. Then assert: minimization guard denies. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-03`** — Given: retail gateway accesses private avatar. Then assert: resource denied and event redacted. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-04`** — Given: unregistered specialist ID invokes capability. Then assert: default deny. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-05`** — Given: specialist attempts own permission escalation. Then assert: immutable registry prevents escalation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-06`** — Given: explanation module invents source URI. Then assert: structured verifier rejects claim. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-07`** — Given: unsupported ML model variant. Then assert: module switches to documented fallback. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-08`** — Given: specialist output wrong schema version. Then assert: reject and request compatible adapter. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-09`** — Given: cross-module write to canonical body truth. Then assert: blocked by single-owner repository. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-AGT-10`** — Given: specialist failure combined with network outage. Then assert: bounded retry; no cascade. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.3 Suite `SEC` — Citadel threat boundaries and consent

- **`V15-T-SEC-01`** — Given: user denies photo access. Then assert: manual flow works without gallery scanning. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-02`** — Given: limited photo access. Then assert: only user-authorized assets are available. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-03`** — Given: user revokes Photos during import. Then assert: future reads stop, temporary image purged. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-04`** — Given: untrusted product text contains tool instructions. Then assert: treated as data only. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-05`** — Given: barcode contains phishing URL. Then assert: URL is not opened automatically. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-06`** — Given: third-party SDK adds unexpected endpoint. Then assert: egress allowlist test fails build. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-07`** — Given: unclassified outgoing DTO. Then assert: fail-closed before network transmission. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-08`** — Given: body data accidentally serialized to product request. Then assert: wire-level egress assertion fails. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-09`** — Given: travel place metadata contains inferred religion. Then assert: sensitive inference schema rejects. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SEC-10`** — Given: deleted avatar cache is addressed later. Then assert: tombstone prevents resurrection. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.4 Suite `CRY` — Cryptography, vault, backup and key lifecycle

- **`V15-T-CRY-01`** — Given: AEAD record ciphertext modified. Then assert: decryption rejects authentication. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-02`** — Given: record AAD swapped. Then assert: decryption rejects cross-record substitution. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-03`** — Given: two distinct encryptions. Then assert: unique nonces observed per key. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-04`** — Given: wrong key after rotation. Then assert: read fails safely without exposing plaintext. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-05`** — Given: rotation interrupted mid-migration. Then assert: recovers coherent old or new vault. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-06`** — Given: device locked under complete protection. Then assert: read obeys OS lock state. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-07`** — Given: export wrong password. Then assert: authenticated import fails without partial writes. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-08`** — Given: export manifest modified. Then assert: import rejected with no overwritten data. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-09`** — Given: import same backup twice. Then assert: no unintentional duplicates or silent overwrite. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-CRY-10`** — Given: user deletes body profile. Then assert: all owned derived private caches are invalidated. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.5 Suite `DEV` — Device health, battery, thermal and resource governor

- **`V15-T-DEV-01`** — Given: thermal serious while rendering. Then assert: lowers tier; UX remains usable. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-02`** — Given: thermal critical during cloth sim. Then assert: stops compute and restores simple render. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-03`** — Given: Low Power Mode toggled mid-inference. Then assert: rebudgets without corrupting result. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-04`** — Given: battery reporting unavailable. Then assert: no fabricated percentage or battery-health claim. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-05`** — Given: simulated memory pressure. Then assert: evicts safe textures/caches, not uncommitted state. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-06`** — Given: local storage nearly full. Then assert: bounded temp writes and recoverable error. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-07`** — Given: OS suspends background work. Then assert: honors expiration, resumes without false success. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-08`** — Given: user starts new scan during old inference. Then assert: preemption/cancellation prevents resource pileup. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-09`** — Given: Neural Engine unavailable/unsupported model. Then assert: uses measured fallback or manual mode. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-DEV-10`** — Given: device locked while vault processing. Then assert: defers protected operation without plaintext persistence. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.6 Suite `MLU` — Model integrity, learning and signed evolution

- **`V15-T-MLU-01`** — Given: downloaded asset signature invalid. Then assert: reject and retain current safe model. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-02`** — Given: manifest signed but wrong input schema. Then assert: reject compatibility failure. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-03`** — Given: artifact hash does not match manifest. Then assert: reject before deserialization. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-04`** — Given: model version rollback requested after regression. Then assert: restores prior known-good behavior. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-05`** — Given: user declines local training. Then assert: no private training examples collected. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-06`** — Given: unsupported updatable model. Then assert: no attempt at runtime weight mutation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-07`** — Given: shadow evaluation worse than current. Then assert: activation denied. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-08`** — Given: model explanation invents precise fit. Then assert: truth verifier downgrades to unknown. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-09`** — Given: training feedback contains extreme outlier. Then assert: bounded robust update/abstention. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-MLU-10`** — Given: model update interrupted. Then assert: atomic old-version fallback remains loadable. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.7 Suite `BOD` — Body editor, avatar geometry and render truth

- **`V15-T-BOD-01`** — Given: adjust waist slider. Then assert: coherent morph and saved revision. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-02`** — Given: adjust linked shoulder/arm/torso controls. Then assert: mesh stays within geometric safety bounds. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-03`** — Given: undo three edits. Then assert: exact prior parameter revision restored. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-04`** — Given: units inches to centimeters. Then assert: converts once; preserves semantics. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-05`** — Given: photograph only gives uncertain landmarks. Then assert: no centimeter accuracy claim. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-06`** — Given: user opts out of photos. Then assert: manual avatar fully available. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-07`** — Given: 3D engine fails to load. Then assert: neutral 2D/manual fallback visible. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-08`** — Given: heavy garment asset under conserve tier. Then assert: renders lower LOD and preserves controls. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-09`** — Given: neutral body model rendered. Then assert: no nude/intimate anatomy visuals. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-BOD-10`** — Given: avatar deleted. Then assert: renderer drops stale mesh and vault data. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.8 Suite `FIT` — Brand identity, product facts and fit honesty

- **`V15-T-FIT-01`** — Given: same GTIN maps to two variants. Then assert: asks for disambiguation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-02`** — Given: official table missing garment measurement. Then assert: reports unknown where needed. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-03`** — Given: size chart inches vs centimeters. Then assert: normalizes with unit provenance. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-04`** — Given: outdated season size chart. Then assert: stale warning, no verified badge. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-05`** — Given: two sources conflict on hip measure. Then assert: records conflict and abstains where material. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-06`** — Given: single photo of clothing. Then assert: no verified physical cloth drape claim. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-07`** — Given: user confirms brand-specific tight fit. Then assert: updates only relevant local residual. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-08`** — Given: user wants loose fit vs close fit. Then assert: result responds to preference. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-09`** — Given: partner pattern verified but no stretch data. Then assert: visual tier not full fabric physics. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-FIT-10`** — Given: size unknown but style look available. Then assert: separates style preview from fit confidence. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.9 Suite `WAR` — Wardrobe, styling and human dignity

- **`V15-T-WAR-01`** — Given: duplicate garment photographs. Then assert: proposes dedup with user confirmation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-02`** — Given: clothing marked dirty. Then assert: excludes or asks preference without shame. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-03`** — Given: item worn yesterday. Then assert: does not automatically declare unclean. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-04`** — Given: user rejects proposed item classification. Then assert: editable field becomes canonical. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-05`** — Given: three styles fit same constraints. Then assert: offers user choice and explanation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-06`** — Given: no location permission. Then assert: manual city allows weather-aware choice. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-07`** — Given: symbolic astrology disabled. Then assert: has no impact on factual fit. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-08`** — Given: culturally sensitive venue unknown. Then assert: does not invent stereotyped rule. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-09`** — Given: user asks why blue shirt recommended. Then assert: reasons trace to available factors. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-WAR-10`** — Given: user clears preference history. Then assert: learned ranks revert without deleting wardrobe. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.10 Suite `TRV` — Travel, weather, capsule and packing

- **`V15-T-TRV-01`** — Given: trip date outside forecast horizon. Then assert: labels climatology rather than false forecast. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-02`** — Given: 5-day rainy city itinerary. Then assert: includes weather-aware backups and coherent outfits. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-03`** — Given: 8kg baggage constraint. Then assert: optimizes within declared weight uncertainty. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-04`** — Given: formal dinner on day 3. Then assert: reserves dress-code eligible outfit. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-05`** — Given: laundry available day 4. Then assert: reuses permitted items correctly. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-06`** — Given: forecast becomes stale offline. Then assert: shows timestamp and old-plan usability. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-07`** — Given: user removes a packed item. Then assert: replans dependent outfits without hallucinated item. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-08`** — Given: religious/cultural inference from GPS. Then assert: policy rejects guess. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-09`** — Given: venue rule lacks source. Then assert: labels uncertain and offers adaptable option. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-TRV-10`** — Given: user cancels trip. Then assert: private plan and dependent reminders removed. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.11 Suite `RET` — Retail, tenant API and commercial trust

- **`V15-T-RET-01`** — Given: tenant A requests tenant B resource. Then assert: 403 and no existence disclosure. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-02`** — Given: catalog update replayed. Then assert: idempotent or rejected by version. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-03`** — Given: unauthorized catalog editor. Then assert: write denied. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-04`** — Given: unlicensed third-party image. Then assert: quarantined and not shown. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-05`** — Given: retail partner requests avatar upload. Then assert: client and server deny. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-06`** — Given: App Attest unavailable device. Then assert: risk-appropriate fallback without disabling offline core. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-07`** — Given: queue staff tries to see body size. Then assert: no schema or authorization path. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-08`** — Given: partner catalog becomes stale. Then assert: fact freshness downgrade. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-09`** — Given: QR points outside verified domain. Then assert: no automatic network navigation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-RET-10`** — Given: pilot analysis lacks control/usable baseline. Then assert: no queue reduction claim. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.12 Suite `OPS` — Observability, deletion and resilience

- **`V15-T-OPS-01`** — Given: debug logger receives body measurement. Then assert: marks private/redacts and fails sensitive-log policy. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-02`** — Given: crash report contains image path/private URL. Then assert: redacts/sanitizes. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-03`** — Given: user consent disabled telemetry. Then assert: no analytics egress. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-04`** — Given: force-kill during wardrobe transaction. Then assert: atomic state restored. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-05`** — Given: force-kill during data erasure. Then assert: tombstone resumes deletion. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-06`** — Given: public product cache expires. Then assert: refresh within policy or show stale. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-07`** — Given: remote kill switch engaged. Then assert: disables nonessential risky feature, not delete/export. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-08`** — Given: private backup already shared externally. Then assert: user-facing deletion receipt states limitation. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-09`** — Given: app reinstall without recoverable export. Then assert: does not promise data magically restored. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-OPS-10`** — Given: incident responder reviews evidence. Then assert: finds no private bodies/photos in logs. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.13 Suite `UXA` — Accessibility and app interaction

- **`V15-T-UXA-01`** — Given: VoiceOver on body slider. Then assert: announces attribute, value, increment and hint. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-02`** — Given: dynamic type max setting. Then assert: no clipped essential controls. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-03`** — Given: reduce motion enabled. Then assert: critical avatar changes remain perceivable. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-04`** — Given: phone offline and product lookup fails. Then assert: cached/manual path with recovery. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-05`** — Given: camera access refused. Then assert: manual GTIN entry offered. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-06`** — Given: visual garment preview not loadable. Then assert: text/size output remains understandable. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-07`** — Given: user flags wrong brand image. Then assert: report/correction accessible. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-08`** — Given: privacy center from onboarding. Then assert: consent/deletion controls discoverable. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-09`** — Given: lock screen notification shown. Then assert: sensitive travel/wardrobe hidden by default. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-UXA-10`** — Given: one-handed small phone layout. Then assert: primary confirm/back/delete actions reachable. Capture PASS/FAIL with raw test output and a counterexample fixture.

### 127.14 Suite `SPL` — Supply chain, legal rights and research validity

- **`V15-T-SPL-01`** — Given: new SDK added to dependency tree. Then assert: license/egress/maintenance review required. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-02`** — Given: unauthorized model weights submitted. Then assert: build gate rejects license provenance gap. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-03`** — Given: unsigned build artifact. Then assert: release gate fails. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-04`** — Given: CI secret accidentally committed. Then assert: secret scan fails and rotation triggered. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-05`** — Given: SBOM omitted in release candidate. Then assert: release artifact gate fails. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-06`** — Given: source claims model verified without benchmark. Then assert: evidence gate fails. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-07`** — Given: test run only on simulator. Then assert: physical device gate remains blocked. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-08`** — Given: two design reviewers are same model session. Then assert: cannot label review independent. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-09`** — Given: app store privacy disclosure differs from observed egress. Then assert: release blocked. Capture PASS/FAIL with raw test output and a counterexample fixture.
- **`V15-T-SPL-10`** — Given: external brand API not authorized. Then assert: integration marked BLOCKED_EXTERNAL. Capture PASS/FAIL with raw test output and a counterexample fixture.

**New v1.5 acceptance tests specified: 140** across 14 suites. All initially **NOT_RUN**; do not mark verified based on textual presence.

## 128. EVIDENCE PACKET FORMAT AND EXECUTION JOURNAL

Every WP/PR or phase completion requires a single machine-auditable packet; examples below illustrate structure, not real results:

```yaml
evidence_schema: 1
work_package: WP15-08
status: NOT_RUN # PASS, FAIL, BLOCKED_DEVICE, BLOCKED_EXTERNAL
commit_sha: null
branch: null
implementation_paths: []
unit_test_command: null
unit_test_exit_code: null
ui_test_command: null
ui_test_exit_code: null
hardware: null # iPhone model / OS / build / battery/thermal conditions
benchmarks: []
privacy_egress_capture: null
security_threat_cases: []
visual_artifacts: []
accessibility_checks: []
independent_reviewer: null
review_independence_level: UNVERIFIED
open_p0: []
open_p1: []
blocked_reasons: []
raw_artifact_index: null
```

**Definition of done** is never a note written by the implementation author. It includes executable code, accessible UI (if user-facing), tests, device evidence where required, contract and threat model checks, baseline comparison, explicit failures, decision record, rollback, cost effect and independent/risk-appropriate review. Use `UNKNOWN` rather than guessing.

## 129. MANDATORY REPOSITORY DELIVERABLES

Adapt to actual repository structure; avoid blindly overwriting existing files. At minimum the complete plan must generate and maintain:

```text
docs/
  system/SYSTEM_MAP_v1.5.md
  system/DOMAIN_BOUNDARIES.md
  system/CONTRACT_REGISTRY.md
  system/EVENT_PROTOCOL.md
  system/DEPENDENCY_DAG.md
  system/CONSENT_AND_CAPABILITY_MATRIX.md
  system/AGENT_REGISTRY.yaml
  system/DEGRADATION_MATRIX.md
  system/MODEL_REGISTRY.yaml
  system/RESOURCE_GOVERNOR_POLICY.md
  security/THREAT_MODEL.md
  security/CRYPTO_KEY_LIFECYCLE.md
  security/EGRESS_REGISTER.md
  security/INCIDENT_RUNBOOKS.md
  security/PRIVACY_IMPACT_ASSESSMENT.md
  research/BRAND_DATA_RIGHTS_REGISTER.md
  research/FIT_TRUTH_EVALUATION_PROTOCOL.md
  research/DEVICE_BENCHMARK_PROTOCOL.md
  research/RETAIL_QUEUE_EXPERIMENT.md
  quality/REQUIREMENT_TEST_MATRIX.md
  quality/INDEPENDENT_GATE_DECISIONS.md
  quality/FAILURE_MEMORY.md
  architecture/ADR-INDEX.md
  audit/REALITY_BASELINE.md
  audit/CURRENT_STATUS.md
  reports/RELEASE_READINESS.md
Tests/
  Unit/ Integration/ Security/ Offline/ Migration/ Performance/
  UX/ Accessibility/ ModelIntegrity/ FitTruth/ Travel/ Retail/
Tools/
  blender/ validation/ benchmarks/ provenance/ privacy-egress/
```

The requirement matrix must trace old `REQ-*`, `T-*`, `V14-T-*` and new `V15-T-*` to implementation, actual run and evidence. Do not claim to have generated these repository files merely because they are enumerated here. New architecture should be reviewed against v1.4 and earlier contract definitions for collisions.

## 130. AUTONOMY BOUNDARIES — AUTHORIZE PROGRESS, NOT UNCONTROLLED ACTIONS

Claude may autonomously read local code, design, code, create synthetic fixtures, run tests, refactor in small reviewed commits, generate docs and benchmark within granted local environment. Claude must not automatically publish to App Store, accept/execute third-party brand contracts, pay for services, send personal photos off-device, access production secrets not granted, send outreach emails, deploy live retail infrastructure, change irreversible production data, weaken privacy gates, or do unreviewed spending. If external access blocked, create interface, mock and test contract, then record `BLOCKED_EXTERNAL`.

**No permanent autonomous deployment loop.** The “continuous improvement” pipeline operates when the app/device is permitted, and developer CI/release change follows human governance. No secret self-replication, privilege escalation, prompt-based override, or hidden network connections.

## 131. ECONOMICS AND SIMPLICITY — SYSTEM QUALITY PER UNIT COST

Choose features by outcome per risk-adjusted cost: `expected consumer utility × evidence confidence – privacy/security risk – device/engineering/partner cost`. Cost ledger per feature: one-time R&D, training/asset licensing, app binary weight, RAM/CPU/GPU and energy on supported devices, backend/API per request, brand partner fees, human review, data deletion/support and model maintenance. Smaller models, reuse and deterministic cache often outperform sprawling agent orchestration on an iPhone.

Keep B2B economics separate from end-user data incentives: platform may monetize licensed retailer catalog tools, SaaS pilot and consumer premium styling, but **never sell intimate body profiles, raw selected images or precise travel plans for advertising**. Sponsored product suggestions, if introduced, must be explicit, user controlled and cannot corrupt objective size/fit evidence. A purchase not needed should be a valid outcome.

## 132. STOP CONDITIONS, CONFLICT RESOLUTION AND RECOVERY RULES

Mandatory `STOP_THE_LINE`: unauthorized private egress, key compromise, unsigned model activation, cross-tenant read/write, fabricated source or measurement certainty, crash causing body-data loss, verified harmful styling discrimination, license rights missing for live product, unrecoverable migration, unbounded background task draining battery. Suspend relevant feature flag, preserve evidence without personal data, revert to safe offline/manual mode, file risk/incident record, require explicit reapproval after fixes and independent regression tests. Prioritize safety over feature completeness.

When two directives conflict: (1) applicable law/platform/security controls, (2) privacy/consent/invariants, (3) latest v1.5 binding architecture, (4) prior v1.4 rules, (5) product preference decisions, (6) local ADR. If latest proposal inadvertently weakens a prior privacy protection, preserve the stronger protection and record it. No marketing or executive goal can override absence of data rights or user consent.

## 133. IMPLEMENTATION START SEQUENCE — EXACT CLAUDE FIRST WORK

1. Read entire canonical v1.5 and the earlier v1.4 inherited requirements; print concise conflict map, version decision register and actual repo reality status.
2. Identify currently available Mac, Xcode, Swift compiler, project, connected iPhones, signing access, installed packages and local test capability. If none, report and create smallest buildable skeleton; do not invent test results.
3. Generate typed domain ownership matrix, `DomainEventV1`, `WorkOrder`, `ModuleRegistry`, `EgressIntent`, `EvidenceRecord`, `DeviceBudget`, `DecisionEnvelope` and `FaultCode`; implement migration-compatible tests for schemas.
4. Implement first consent/egress privacy gate, an encrypted-vault vertical slice with platform-backed crypto, and a fail-closed denied-action test before connecting any external catalog provider.
5. Implement Octopus coordinator on a **single** user journey (`slider changed → body revision → 3D preview → local save`) with structured concurrency, resource governor and offline fallback.
6. Confirm neutral Blender avatar rig/mesh and exact RealityKit/Metal API availability for the target Xcode/OS version; build simplest genuine rendering prototype on real device.
7. Execute code tests, release-security negative tests and actual hardware measurements; record limitations and independent reviewer status.
8. Only then add garment photo classification, barcode resolver, validated size engine, wardrobe/stylist, travel and optional retail; each layer must reuse core policy/contract architecture rather than creating a second brain.
9. After each slice: `git diff`, compile/test, device check, regression and threat model update, evidence packet, ADR, commit only after gates. No fake pass.
10. End every interaction with actual state, exact commit/branch, artifact paths, PASS/FAIL/BLOCKED/NOT_RUN tests, hardware used, highest open risks and **the next smallest executable step**. Do not tell user to wait for future asynchronous activity.

### 133.1 Minimum first executable proof

A person opens the iPhone app offline, creates a neutral body, drags waist/shoulder sliders, observes smooth *correct* mesh changes, saves locally, force-quits/relaunches, finds same values, removes profile, and sees data gone. Throughout, network is denied for private data, cancellation works, thermal/resource fallback is visible and tests produce real logs. This is more valuable than a fake complex AI demo.

## 134. PUBLIC TECHNICAL REFERENCES / MANDATORY SOURCE RECHECK

The following are **public primary references** inspected in November 2026; Claude must revalidate API availability for the chosen SDK/device and license terms. Referencing an API does not demonstrate correct implementation.

- Apple ProcessInfo Thermal State and Low Power Mode: https://developer.apple.com/documentation/foundation/processinfo
- Apple UIDevice battery level; availability/unknown behavior: https://developer.apple.com/documentation/uikit/uidevice/batterylevel
- Apple BackgroundTasks (OS controls scheduling and interruption): https://developer.apple.com/documentation/BackgroundTasks
- Apple background processing limitations: https://developer.apple.com/documentation/BackgroundTasks/BGProcessingTask
- Apple user-selected Photos picker privacy: https://developer.apple.com/documentation/PhotoKit/selecting-photos-and-videos-in-ios
- Apple Secure Enclave private-key limitations: https://developer.apple.com/documentation/Security/protecting-keys-with-the-secure-enclave
- Apple Keychain Services: https://developer.apple.com/documentation/security/keychain-services/
- Apple CryptoKit AES-GCM: https://developer.apple.com/documentation/cryptokit/aes/gcm
- Apple DeviceCheck App Attest: https://developer.apple.com/documentation/DeviceCheck/establishing-your-app-s-integrity
- Apple RealityKit mesh deformation and lower-level geometry: https://developer.apple.com/documentation/realitykit/scene-content-mesh-deformation
- Apple Core ML on-device personalization (updatable model only): https://developer.apple.com/documentation/CoreML/personalizing-a-model-with-on-device-updates
- Apple File Protection: https://developer.apple.com/documentation/foundation/fileprotectiontype/complete
- Apple os.Logger privacy controls: https://developer.apple.com/documentation/os/oslogprivacy/
- OWASP Mobile ASVS/MASVS scope: https://mas.owasp.org/MASVS/03-Using_the_MASVS/
- OWASP ASVS for services: https://asvs.owasp.org/
- NIST AI RMF (GOVERN/MAP/MEASURE/MANAGE): https://airc.nist.gov/airmf-resources/airmf/5-sec-core/
- SLSA v1.2 Build Track (provenance/CI, not claim of certification): https://slsa.dev/spec/v1.2/build-track-basics

## 135. FINAL SYSTEM CONSTITUTION — WHAT 'GOD LEVEL' MUST REALLY MEAN

> A tiny code change can affect geometry, a personal profile, cryptographic keys, user privacy, battery life, network expenses, partner trust, company liability, and the human being looking at their own body. Therefore every change is governed by purpose, least privilege, typed contract, limited resource budget, measured uncertainty, reversible learning, incident containment and evidence.

**Mandatory philosophy:** The user sees one calm, fast, beautiful app. Internally every specialist is bounded, every critical fact has provenance, every key has a lifecycle, every unit has a cost, every model has a card, every update has a signed manifest, every recommendation can say “unknown”, every data operation can be reversed/deleted within documented limits, and every release can be audited. The system grows like a coordinated organism, **not like an uncontrolled self-editing intelligence**.

This document does **not** mean every risk has been thought of or solved; unknown unknowns necessarily remain. Claude must continuously amend the threat register, validation methods and source rights inventory as new evidence arises. Absolutely impenetrable cryptography, perfect simulation or creator-level omniscience are not testable product claims. The achievable engineering goal is disciplined, user-respecting, explainable, continuously evaluated excellence.

**v1.5 STATUS AT AUTHORING:** Specification complete at document level; every newly specified feature/test is `NOT_IMPLEMENTED/NOT_RUN` until project repository and independent evidence say otherwise.

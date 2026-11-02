# WEARFORM — GOD LEVEL v1.2 BINDING AMENDMENT
## TRAVEL INTELLIGENCE · DESTINATION STYLIST · CAPSULE PACKING · CULTURAL CONTEXT · PRIVATE ON-DEVICE TRIP BRAIN

> **Version:** v1.2, 03 November 2026. **Status:** binding product/engineering specification; not implementation or test evidence. **Canonical priority:** This amendment takes precedence over any conflicting v1.0/v1.1 assumption *only for travel-mode scope*. All existing privacy, evidence, truthfulness, body neutrality and external-action authorization rules remain in force. **Instruction to Claude:** Read canonical v1.2 merged file section 0, then §§39–58, then base §§1–38; audit repository and implement the first dependency-safe travel vertical slice after or alongside stable shared wardrobe primitives. Work autonomously on reversible local engineering tasks; do not claim external service access, paid subscription, partnership or deployment without evidence and authorization.

---

# 39. V1.2 CHANGE CONTROL — WHAT TRAVEL MODE MUST ACTUALLY DO

## 39.1 Founder's non-negotiable intent

**Bir kişi bir destinasyon ve seyahat süresi seçtiğinde WEARFORM, o kişinin gerçek dijital dolabından yararlanarak seyahat boyunca nerede/ne yaparken/ne giyeceğini, hangi kıyafetleri valize koyacağını, gerektiğinde neleri tamamlaması gerektiğini, hangilerini yeniden kullanabileceğini ve seyahatin şartları değiştiğinde planı nasıl uyarlayacağını güvenilir biçimde önermelidir.** Sistem bir kişisel stilist, modelist, kumaş/kalıp bilgisi uzmanı, valiz planlayıcısı ve kültürel bağlamı saygıyla yorumlayan seyahat asistanı gibi davranmalıdır; bunlar gerçek dışı tek-model süperzekâ iddiaları değil, ayrı sorumlulukları ve testleri olan modüllerdir.

Kullanıcının seyahat tipine göre şehir, ülke, tarih, süre, günlük program, yürüyüş miktarı, konaklama/çamaşır imkânı, valiz sınırı, etkinlik ve stil tercihleri birlikte değerlendirilir. Dört ekranı açıp 30 ayar yaptırmak yerine kısa bir akışla ilk sonuç çıkarılır; ayrıntılar isteğe bağlıdır.

## 39.2 Rekabetçi gerçeklik / konumlandırma

Whering, seyahat kombin planlama ve packing list özellikleri sunmaktadır; PackPoint süre, hava ve etkinliğe göre valiz listesi oluşturduğunu belirtmektedir. Bunlar kullanıcı gözünde mevcut taban beklentilerdir. WEARFORM'un sınanacak farklılaşması: **gerçek yerel gardırop + ayarlanabilir kişisel 3D avatar + ürün varyantı ve kumaş bilgisi + hava/bölgesel koşullar + etkinlik günlüğü + kapsül valiz optimizasyonu + kaynak/güven açıklaması + yolculuk sırasında yerel yeniden planlama**. Bir fonksiyonun rakipte olup olmadığını uygulamayı incelemeden kategorik iddia etme.

## 39.3 Scope/prioritization

| Priority | Output | Boundary |
|---|---|---|
| P0 | 1 destinasyon, 1–14 günlük seyahat; tarih ve etkinlikler; gardırop bazlı günlük 1–3 kombin; valiz listesi; elle düzenleme; offline mevcut plan | Dış hava API'si yoksa durum etiketi ve örnek/iklim fallback; gerçek ürün/kişisel veri uydurma yok |
| P0 | Hava kaynağı/zaman etiketi, forecast-vs-climatology ayrımı; kıyafet temizliği onayı; içeriği silme; düşük pil/ısı uyumu | Giysi hijyeni ve hava kaynaklarının belirsizliği gösterilir |
| P1 | Çok duraklı seyahat, valiz ağırlık limiti, kültürel/venue giyim gereklilikleri, etkinlik-saat eşlemesi, yeniden paketleme ve tatil esnasında adaptasyon | Kaynak yoksa kullanıcı doğrulaması gerekir |
| P1 | 3D günlük prova/şehir sahnesi; eksik parçayı marka-ürün karşılaştırmasıyla arama; mağaza ön hazırlığı | Görsel sahne gerçek yer/gerçek zaman iddiası yapmaz; lisanslı veriler |
| P2 | Tren/uçak takvimi *izinli* içe aktarma, seyahat arkadaşıyla yalnız redakte paylaşım, gelişmiş bagaj bölme/katlama önerileri | Haricî hesaplar ve veri paylaşımı ayrıca onaylanmalı |
| Deferred | Kabinin/kültürün gelecekteki havasını kesin bilme; üniversel beden uygunluğu; her ülkede otomatik resmî giyim kodu; tam fotogerçekçi 3D gezi sahnesi | Bunlar yanlış kesinlik veya maliyet üretir |
| Rejected | Kullanıcının dinini/etnisitesini/kimliğini konumdan çıkarmak; kültürü stereotiplemek; gizlice rezervasyon/e-posta/galeri taramak; sessiz satın alma | Mahremiyet, güven ve adalet ihlali |

## 39.4 Non-negotiable design slogans

`PACK WHAT YOU OWN FIRST.` · `DRESS FOR THE DAY, NOT JUST THE CITY.` · `SHOW THE WHY.` · `NEVER FAKE WEATHER.` · `NO CULTURAL STEREOTYPES.` · `THE USER OWNS THE FINAL SUITCASE.` · `AIRPLANE MODE MUST WORK.`

---

# 40. TRAVEL JOBS, PERSONAS, OUTCOMES AND HARD CASES

## 40.1 Core jobs-to-be-done

1. **Tatile çıkmadan:** “Beş günlüğüne gidiyorum; dolabımdakilerle az eşya taşıyarak her güne hazır olmak istiyorum.”
2. **Gezide:** “Bugün serin ve rüzgârlı; öğlen müzeye, akşam restorana gideceğim. Valizimden hangilerini kombinleyeyim?”
3. **Özel davette:** “Akşam düğün/konferans/restoran için giyim beklentisine uygun, bana yakışan seçenek olsun.”
4. **Bütçe kısıtlıyken:** “Eksik bir parça gerekirse önce mevcut dolabımdan alternatif bul; satın almayı zorunlu gösterme.”
5. **Valiz sınırı varken:** “Kabin çantama sığsın; fazla eşya ve son gün çamaşır sıkıntısı yaşamayayım.”
6. **Birden çok iklimde:** “İzmir'den Oslo'ya, sonra başka şehre geçiyorum; transfer ve katmanlı giyim hesaba katılsın.”
7. **Dolap eksikken:** “Henüz fotoğraf yüklemedim; yine de kategori bazında işe yarar genel valiz listesi alayım.”

## 40.2 Success outcomes (do not invent improvement figures)

- Anlaşılır ilk planın oluşturulma oranı; kullanıcı başına gerekli manuel etkileşim sayısı.
- Kullanıcının gerçekten valize koyduğu listenin önerilen listeye eşleşmesi, daha sonra isteğe bağlı geri bildirim.
- Yanlış / unutulan kritik öğe bildirim oranı; yanlış hava/venue iddiaları sıfıra yaklaştırılmalı.
- Outfit satisfaction, cold-start, offline utility, battery usage, travel retention; uygun örneklemde yeniden kullanım.
- *Kullanıcı beyanına dayalı* “fazla eşya aldım/eksik aldım” oranı; doğrulanmamış bagaj tasarrufu reklamı yasak.
- Hassas konum/kültür/yaş etkilerinde sıfır gizli çıkarım; ayrımcılık ve açıklanamaz öneri red-team testleri.

## 40.3 Deliberately difficult travel cases

- Forecast horizon ötesi, tarih henüz belirli değil, iki ülkede aynı adlı şehir, hem yaz hem kış bölgeleri, 3+ mikro iklim, yağmur + rüzgâr + gece soğuğu, ani hava değişimi.
- Açık hava yürüyüşü/deniz/plaj + resmi akşam yemeği aynı gün; aktivite kıyafet değişimi ihtiyacı.
- Uygun ayakkabı yok; ayakkabının aşınma durumu bilinmiyor; önemli uyum konuları fotoğraftan çıkarılamaz.
- Hijyen belirsizliği, her gün aynı jean'in giyilebilmesi ama iç çamaşırının yeniden kullanımının varsayılmaması; kullanıcı hassasiyeti.
- Kullanıcı erkek/kadın/başka kimlik fark etmeksizin giyim önerilerinin beden ve tercih üzerinden çalışması; zorunlu cinsiyet kategorisi bulunmaması.
- Görme veya hareket kısıtlılığı olan kullanıcının rahat giyim/ayakkabı tercihini kendisi belirtmesi; sağlık çıkarımı yapılmaması.
- Hava API çevrimdışı; son güncelleme eski; varış saat dilimi ve yaz saati farkı; uçağın gecikmesi kullanıcı doğrulaması olmadan varsayılmaz.

---

# 41. 30-SECOND TRIP WIZARD — DATA MINIMIZATION WITH HUMAN CONTROL

## 41.1 P0 quick input

**Step 1: Nereye/ne zaman?** Destination city/place lookup or manual city+country, departure & return calendar dates; dates are inclusive and computed in destination's IANA time zone. “5 gün” = user-visible 5 calendar days, unless the user entered 5 nights; ambiguity must be resolved in UI not silently guessed.

**Step 2: Ne yapacaksın?** Multiple-select presets: gezi/yürüyüş, iş/toplantı, resmi etkinlik, sahil/havuz, müze/şehir, akşam yemeği, doğa/trekking, spor, aile ziyareti, gece eğlencesi, rahat dinlenme, diğer. For each day optionally add time block, indoor/outdoor, formality, dress code from invitation, footwear demands. Non-selected activity cannot be inferred from GPS history.

**Step 3: Valiz/çamaşır?** Cabin bag/check-in/none, manually supplied dimensions/weight or “bilmiyorum”; access to laundry yes/no/unknown; willingness to repeat bottoms, outerwear, and tops individually; weather sensitivity optional. Travel companions are irrelevant unless requested; children's packing is explicitly separate consent/control scope.

**Step 4: Kendi dolabından planla.** Preselected owned wardrobe (never auto-upload), missing catalog fallback; user can skip photo permission; no mandatory birthday, skin-tone classification, gender, precision location or account. Generate draft then reveal five-day timeline, compact list and rationale.

## 41.2 Optional profiles

`TripPreferences` holds preferred aesthetics, modesty coverage and venue dress constraints *by explicit input*, favorite palette, heel/flat preference, layering tolerance, packing-light priority, comfort-vs-formality, shoes-per-day limit, reuse/laundry rules, special-purpose items (equipment). Body sliders affect visualization/fit only as designed in §§24–26; travel location cannot read full mesh when not necessary.

## 41.3 Location and permissions

- The travel mode needs a **destination**, not necessarily device geolocation. Default to searched/typed city; don't prompt “always allow location.”
- Current location only for optional departure weather; foreground *when-in-use* only with explanation and clear “Yazarak seç” alternative.
- `PhotosPicker` user-selected garment import is default; bulk library scan is separate opt-in and follows existing photo privacy constitution.
- No calendar/e-mail/booking sync by default. Future import requires explicit action, narrow permission and local parsing.
- Birthdate is never necessary for packing. Age/life stage may be expressed as mobility/comfort style preference; no covert age scoring. Astrology/numerology remains optional disclosed inspiration, never a factual weather or venue rule.

## 41.4 Trip states

`DRAFT → PLANNED → PACKING → DEPARTED → IN_TRIP → RETURNED → ARCHIVED | DELETED`, with non-destructive edits, versioned plan, day selection, data expiration option. Changing dates/destination invalidates weather, event contexts and freshness flags; wardrobe stays intact. Cancellation does not delete the user wardrobe. Travel plan and event notes stay device-local.

---

# 42. DESTINATION WEATHER ENGINE — REAL FORECAST, CLIMATOLOGY, AND OFFLINE

## 42.1 Source strategy and capability boundary

**Primary iOS candidate:** Apple WeatherKit Swift API, subject to actual developer entitlement, quota, terms and attribution verification; WeatherKit exposes current, hourly/daily forecasts and applicable alerts. Its public overview advertises up to 10-day hourly forecasts. Do not hardcode a guaranteed horizon across places/conditions; inspect available returned periods. This app may show a provider-attributed weather card (must implement current contractual attribution requirements). Reference: https://developer.apple.com/weatherkit/ ; https://developer.apple.com/documentation/weatherkitrestapi ; https://developer.apple.com/documentation/weatherkit/weatherattribution .

**Alternative:** Open-Meteo, only after reviewing its applicable commercial plan, dataset licensing, attribution and current terms; noncommercial public endpoint must not be assumed authorized for commercial launch. Reference: https://open-meteo.com/en/pricing . Use `WeatherProvider` interface with mock fixtures to avoid hard dependency.

**A trip dates beyond forecast window:** Show `SEASONAL_GUIDANCE` based on legitimately sourced climate normals/ranges with source, granularity and explicit “mevsimsel beklenti, hava tahmini değil”. If no verified climate dataset is licensed/cached, show `NO_DATA` and broad human-editable layering suggestions, not fabricated degree numbers. When days enter forecast range, refresh only if user has granted network and quota permits.

## 42.2 Weather data contracts

For each destination/day/time block:

- `timeZoneID`, `localDate`, optional `timeBlock`, `forecastIssuedAt`, `retrievedAt`, `validFrom`, `validTo`, `provider`, `licenseAndAttribution`.
- Temperature min/max/apparent if available, precipitation chance/intensity, wind/gusts, humidity, UV, cloud, snow/ice, weather alerts and confidence/freshness metadata.
- Required `sourceMode`: `LIVE_FORECAST | CACHED_FORECAST | SEASONAL_GUIDANCE | USER_OVERRIDE | NO_DATA`.
- `forecastAge` dynamic; selected day can show “Tahmin henüz yok”, “Son güncelleme: …” or “Çevrimdışı, son bilinen tahmin”. Do not fabricate confidence percentage; confidence must derive from evaluated forecast/provider metrics, otherwise verbal label only.
- Alerts appear with official provenance and exact unmodified wording where rights/policies require; do not invent local safety recommendations and don't convert clothing app into emergency-service replacement.

## 42.3 Weather-to-wardrobe decision layer

Determine outfit utility from `perceivedTemperature × precipitation × wind × activityIntensity × indoorOutdoor × timeOfDay × garmentLayering × userTempPreference` and available wardrobe materials. Prefer adjustable layers over a single outfit when day/night variability high. For active walking/travel suggest comfortable footwear and breathable layers conditional on actual owned inventory. No claims that a specific fabric is waterproof or thermal unless catalog/user evidence supports it. Exact SPF/waterproof rating and sun/heat safety are not inferred from garment color alone.

## 42.4 Refresh and resource budgets

- On trip creation fetch destination weather *once* with dedupe, debounced replan; cache per destination/time period; TTL depends on provider policy and weather change risk; surface stale flags.
- Do not poll every minute or run constant GPS. OS-sanctioned refresh/background delivery where practical, subject to user settings and OS scheduling; no promised exact notification time.
- On airplane mode recompute outfits from cached signals; if absent show date/activity-only recommendations and prominent “Hava tahmini yok”.
- If forecast update conflicts with selected clothes, offer user a diff and a one-tap “Yeni öneriyi uygula” rather than silently replacing an already packed outfit.

---

# 43. CULTURAL, VENUE AND SOCIAL CONTEXT — RESPECTFUL AND GROUNDED

## 43.1 Source-of-truth hierarchy

1. Explicit invitation/venue dress code supplied by user or official venue/organizer source, with validity window.
2. Documented site restrictions from authorized official tourism/venue sources (e.g., explicit covered-shoulder or footwear requirement for *a particular site*).
3. User's expressed formality, modesty, personal values and comfort.
4. Broad, explicitly labeled *suggestions*, not facts, for weather/occasion; no sweeping national rules.

**NEVER** infer user's ethnicity, religion, gender identity, beliefs, body health or “how people of this culture dress” from GPS, birth data or photographs. A city may contain very different venues and communities. Ask for specific destination+activity and permit “Bu öneriyi yok say”. If no qualified source for a cultural rule, show “Mekânın güncel kıyafet kurallarını doğrulayın.” Reject racist/sexist/exclusionary outfit logic. Respect local regulations when verifiable but do not universalize norms across all residents or travelers.

## 43.2 Provenance object

`VenueGuidance { venueRef, jurisdiction?, dressRequirement, sourceURL, officialStatus, observedAt, validThrough?, geographicScope, uncertainty, userOverride, language }`. Never claim venue rule from anonymous review or AI synthesis alone. Store only guidance needed for trip and allow manual correction. A link to official guidance is different from an affiliation/partnership.

## 43.3 Sensitivity and cultural safety test

The same climate/activity/wardrobe should yield equivalent baseline utility regardless of arbitrary name, skin tone, gender expression or inferred country-of-origin labels. When user asks for faith-based/modesty dress explicitly, respect those constraints without tagging the person's religion. For multi-venue trips include a removable modest layer only when specific venue requirements or user preferences justify it.

---

# 44. FASHION DIRECTOR + TECHNICAL MODELIST — OUTFIT SELECTION FOR TRAVEL

## 44.1 Expert responsibilities and inputs

- **Stylist/creative director:** silhouettes, shapes, palettes, texture, cohesion, repeatable capsule combinations, context-appropriate formality.
- **Technical patternmaker:** fit tolerances, mobility, ease, actual brand garment measurements when licensed/known; never infer unavailable physical measurements from product glamour photos.
- **Fabric specialist:** material tag evidence, drape estimate fidelity class, breathability/warmth/wrinkle/drying propensity only if supported; no “% waterproof” invented.
- **Comfort and itinerary planner:** walking, long transit, indoor/outdoor transitions, layered packing.
- **Color coordinator:** preferences, garment colors and user-controlled palette; optional user-selected undertone estimates with uncertainty, not definitive facial profiling.
- **Cultural context specialist:** verifiable venue norms and user-controlled modesty preferences.
- **3D visual editor:** shows saved avatar and outfits in neutral virtual staging, fidelity tiers from §§24–25.

## 44.2 Travel outfit cards

Each day yields: `Primary daytime look`, optional `Evening/occasion look`, optional `Weather fallback`, source set, garment IDs, reason chips (“12–18°C tahmini / müze / yürüyüş / yağmurluk”), validated fit/visual tiers, packed availability, laundry/reuse warnings, manual edit and save. If forecast not available, the card displays `MEVSİMSEL` or `HAVA VERİSİ YOK`. If jeans are already in use across 3 days, evaluate user preference and reasonable care signals, never automatically diagnose “kirli”.

## 44.3 Color and capsule coordination

Build a small neutral/anchor-color palette chosen from wardrobe inventory; generate compatible swaps, avoid 5 duplicate dresses when 2 versatile outfits plus one extra cover needs less luggage. A style score is a **preference-based ranking**, not scientific attractiveness/beauty/objective body judgment. Explain “neden” in concise local language. Account for style preferences and fit constraints over arbitrary birthdate-based instructions. Symbolic astrology/numerology themes may only add a clear optional creative accent with opt-in and reversible state.

## 44.4 Travel outfit visualization

Use existing `BodyMorphProfile` and licensed G0–Gx garments. For trips, do not load a whole city's photogrammetry or download giant scene packs by default. Offer a generic destination-inspired stylized background; a recognizable exact landmark scene only when asset rights, geometry provenance, download size and user expectation are addressed. Label generative city visuals “temsili sahne”, avoid “şu anda bu noktada birebir böyle görünürsün” assertion. Allow offline neutral studio avatar. App must also function without 3D hardware capability via 2D outfit tiles.

---

# 45. THE CAPSULE SUITCASE OPTIMIZER — AN ENGINEERING SYSTEM, NOT A RANDOM LIST

## 45.1 Inputs and variables

- `D`: days or half-day/occasion slots, with weather and venue constraints.
- `G`: owned garments plus user-added generic garment concepts. Attributes: category, season, colors, layers, fit, footwear, material, cleanliness state, availability, approximate packed weight/volume if known, rewear limits user-selected, special needs, purchase eligibility.
- `O`: feasible outfits made from `G` covering slot constraints, distinctness/style utility, mobility, coverage and weather evidence.
- `B`: baggage type and user-entered size/weight restrictions; baggage allowance is **not universally fixed**. A carrier itinerary may later add authoritative baggage rules, never guessed from destination.
- `L`: laundry availability and optional detergent/drying time, if known. Packing policy respects undergarments, socks, workout clothing, swimwear and emergency reserves by configurable user defaults; no private hygiene conclusions.

## 45.2 Optimization formulation

Implement two-stage deterministic planner with explainable ranking:

1. Construct candidate outfits `O(d, a)` for each day/occasion using constraints `feasibleFit`, `dressCode`, `weatherCompatibility`, `comfort`, `cleanliness/rewear`, `ownedAvailable`, `coverage`.
2. Choose a small union of garments to cover every slot. With binary `x_g` = pack garment g, `y_o` = use outfit o:
   - each required slot covered by at least one selected outfit;
   - if outfit selected, every required garment in it is packed or explicitly marked `PURCHASE_NEEDED` / `RENTAL_OR_BORROW`;
   - clean/reuse capacity and drying/wash constraints enforced;
   - known bag weight limit respected; unknown weights do **not** generate fake accurate weights;
   - prohibited/unsafe or unlicensed garments excluded from product claims.
3. Optimize lexicographic priorities (not a single unexamined magic score): **(a) requirements & essential coverage (b) physical/weather comfort (c) user-stated preferences (d) minimize carried items/volume/known weight (e) maximize reuse versatility and cohesive style**. Expose adjustable preference: `light luggage ↔ outfit variety`.
4. If an exact solver fits performance/memory budget and problem small, compare against bounded brute force fixtures; otherwise stable deterministic greedy+local repair with invariants. Never hide an uncovered occasion behind an overall score. All outputs are revisable.
5. Recognize case `NO_FEASIBLE_PLAN`: clearly identify missing items/required constraints and propose substitutions / laundering / purchase *only if needed*; do not fabricate catalog stock or prices.

## 45.3 Packing list categories and quantities

`Tops`, `Bottoms`, `Dresses/sets`, `Outerwear`, `Shoes`, `Underlayers and socks`, `Sleepwear`, `Activewear`, `Swimwear`, `Accessories`, `Weather protection`, `Occasion-specific`. Optional separate **non-clothing essentials** checklist (toiletries/chargers/travel documents) is generic, user-editable and clearly separated; document/visa requirements depend on nationality/route and must never be confidently fabricated. Never include prohibited airline items without verifying authoritative policy.

Every item shows `owned garment preview`, selected quantity, days used, packed checkbox, condition `CLEAN | WORN | IN_LAUNDRY | UNKNOWN`, source/provenance, optional estimated weight band and editability; automatic “packed” only after user check/confirmation. Unknown item status defaults to `UNKNOWN`, not `CLEAN`.

## 45.4 Laundry, reuse and outfit tracking

- At packing time items can be set clean/available; when worn user may mark `worn`; app may prompt gently but never assume from calendar plan that garment was worn.
- Setting `WORN` does not mean unsafe/dirty. User chooses whether still wearable and when to wash; undergarment hygiene uses conservative user-controlled defaults.
- Laundry cycles, hotel laundry access or overnight drying are only scheduled with explicit input and realistic uncertainty.
- If rain causes a shoe to be wet, surface “kurudu mu?” user question; no sensor fantasy.
- Reuse preferences vary by category and wearer; user can lock any favorite garment to a specific day.

## 45.5 Avoid impulsive shopping

Run owned-wardrobe search and substitute analysis first. Shopping gap result only if feasible owned set fails or user chooses purchase. Gap card states `missing function`, not “buy brand X”; optionally authorized brand inventory lookup through existing licensed retail catalog with `verified size fit status`, region/currency, stock timestamp and provenance. No paid partner favoritism disguised as neutral recommendation. Do not imply a brand partnership without contract.

---

# 46. FULL TRAVEL EXPERIENCE — SCREEN-BY-SCREEN UX / MICROCOPY

## 46.1 Navigation placement

Do not add a fourth/fifth top-level tab if base IA does not justify it. Put **Seyahat Modu** prominently inside existing `Today/Planner` entry point, with a concise CTA: “Seyahatini planla”. Persistent active-trip tile on home screen with number of days and `valiz ilerlemesi`, only while user opts in. Travel never takes over retail try-on flow.

## 46.2 Required screens and states

| Screen ID | Name / primary action | Minimum states and interactions |
|---|---|---|
| `TRV-01` | **Seyahat Modu giriş** — Yeni seyahat / geçmiş plan | empty, saved offline, edit/delete, description, permission-independent |
| `TRV-02` | **Nereye gidiyorsun?** — destination + dates | ambiguous city disambiguation, IANA timezone, invalid past date, multiple match, no-network manual entry |
| `TRV-03` | **Seyahatin nasıl?** — purpose/events and day/time | suggested chips, add exact venue and official dress code, optional skip, screen-reader |
| `TRV-04` | **Valiz ve tercihler** — bag/laundry/repeat | unknown baggage, no-laundry, light/variety selector, manual overrides |
| `TRV-05` | **Planın hazırlanıyor** — staged local computation | safe loading, progress explanation, offline, slow/partial weather, cancellation, resource fallback |
| `TRV-06` | **Seyahat özeti** — 5-day timeline and confidence | first outfit, forecast provenance, days coverage, missing essentials, refresh banner |
| `TRV-07` | **Günlük kombin** — day/evening/backup | swap, lock outfit, 3D view, weather/venue rationale, no-3D fallback |
| `TRV-08` | **Akıllı valiz** — checklist grouped by category | packed/unpacked, quantities, unknown weights, baggage limits, duplicates, offline updates |
| `TRV-09` | **Kapsül gardırop** — what can be remixed | cross-day outfits, reused garments, visualization, manual substitutions |
| `TRV-10` | **Eksik parçalar** — own-item alternative first | optional licensed store lookup, missing-availability, price/stock provenance, no-merchant mode |
| `TRV-11` | **Hava ve ortam** — trusted context | forecast vs seasonal explicit, official venue guideline, attribution, map optional |
| `TRV-12` | **3D seyahat provası** — living avatar | fidelity tier, loaded-garment license, compare outfits, no fake landmark authenticity |
| `TRV-13` | **Seyahat içinde yeniden planla** | forecast change diff, packed limits, laundry state, user approval, offline |
| `TRV-14` | **Tamamlanan seyahat** — optional reflection | what was worn vs planned, opt-in corrections, locally saved notes, delete all trip data |

Common screen states for **every** screen: no permission; offline; no wardrobe; empty catalog; insufficient weather; stale/weather alert; loading; canceled; partial results; untrusted official-source data; long locale text; accessibility VoiceOver/Dynamic Type; low-power mode; missing saved avatar. `TRV-12` is optional for a usable travel plan.

## 46.3 Microcopy examples

- “**5 gün için 9 parçayla 12 kombin seçeneği**” *only if actually computed from the current plan; never hardcode counts.*
- “**Önce dolabından önerdik.** Eksik olursa alternatifleri görebilirsin.”
- “**Bu tarihler için henüz günlük hava tahmini yok.** Mevsimsel koşullara göre geçici plan hazırladık.”
- “**Mekân kuralı doğrulanmadı.** Resmî sayfayı kontrol et.”
- “**Bu kıyafeti giydin mi?** Planlamış olman giydiğin anlamına gelmez.”
- “**Çantanın gerçek ağırlığı bilinmiyor.** Dilersen eşyaları tartarak gir.”
- “**3D önizleme yaklaşıktır.** Kumaşın gerçek dökümü ürün verisine göre değişebilir.”

## 46.4 Interaction / visual design

Reuse WEARFORM design tokens, pale neutral wardrobe cards, high-contrast typography, day/weather symbols with text alternative, stacked itinerary cards, compact packing checkbox rows, single bottom primary CTA. Do not build a separate gaudy travel design system. Crisp transition `destination → trip days → pack → ready`, short animation only, `Reduce Motion` respected, no blocked layout while 3D warms. Destination photo and skyline optional and licensed; no image required for P0.

---

# 47. DOMAIN MODEL — SOURCE-OF-TRUTH CONTRACTS / REVISIONS

**Implementation note:** The following language-neutral typed specification is a contract; generate production Swift models with `Codable` and compatible local persistence schemas, versioned migrations and stable IDs. Do not claim pasted schema is compiled production code.

```typescript
type TripState = 'DRAFT'|'PLANNED'|'PACKING'|'DEPARTED'|'IN_TRIP'|'RETURNED'|'ARCHIVED';
type WeatherEvidence = 'LIVE_FORECAST'|'CACHED_FORECAST'|'SEASONAL_GUIDANCE'|'USER_OVERRIDE'|'NO_DATA';
type ProvenanceKind = 'OFFICIAL_VENUE'|'LICENSED_PROVIDER'|'USER_INPUT'|'PUBLIC_REFERENCE'|'UNKNOWN';
type Coverage = 'REQUIRED'|'OPTIONAL'|'CONDITIONAL';
type ItemCondition = 'CLEAN'|'WORN'|'IN_LAUNDRY'|'UNKNOWN';

type Trip = {
  id: string; schemaVersion: number; state: TripState;
  stops: Array<{id:string; placeID?:string; city:string; country?:string;
    timeZoneID:string; startLocalDate:string; endLocalDate:string; approximateCoordinates?: [number,number]}>;
  packingPolicy: {bagType:'CABIN'|'CHECKED'|'OTHER'|'UNKNOWN';
    maxWeightKg?:number; maxVolumeLiters?:number; laundryAccess:'YES'|'NO'|'UNKNOWN';
    preference:'LIGHT'|'BALANCED'|'VARIETY'; repeatRulesByCategory:Record<string,number|undefined>};
  eventIDs: string[]; outfitPlanIDs: string[]; packingListID?:string;
  ownerLocalOnly:true; createdAt:string; lastEditedAt:string; revision:number;
};
type TripEvent = {id:string; tripID:string; stopID:string;
  localDate:string; timeBlock?:'MORNING'|'AFTERNOON'|'EVENING'|'FULL_DAY';
  activity:string; indoorsOutdoors:'INDOORS'|'OUTDOORS'|'MIXED'|'UNKNOWN';
  requestedFormality?:string; footwearNeed?:string; venueGuidanceID?:string;
  userLocked:boolean};
type WeatherSnapshot = {id:string; stopID:string; localDate:string;
  evidence:WeatherEvidence; provider?:string; issuedAt?:string; retrievedAt?:string;
  validUntil?:string; lowC?:number; highC?:number; feelsLikeC?:number;
  precipitationProbability?:number; windKph?:number; alertReferenceIDs?:string[];
  attributionURL?:string; uncertaintyDescription:string};
type ContextEvidence = {id:string; kind:ProvenanceKind; sourceURI?:string;
  officialVerified:boolean; capturedAt:string; validThrough?:string;
  scope:'VENUE'|'LOCATION'|'EVENT'|'USER_PREFERENCE'; description:string};
type TripOutfitPlan = {id:string; tripID:string; eventID:string;
  garmentIDs:string[]; fallbackGarmentIDs:string[]; locked:boolean;
  weatherSnapshotID?:string; contextEvidenceIDs:string[];
  fitEvidenceTier:string; visualFidelityTier:string;
  why:string[]; confidenceKind:'VERIFIED_FACTS'|'HEURISTIC'|'PARTIAL'|'ABSTAIN';
  gaps:string[]; revision:number};
type PackingListItem = {id:string; tripID:string; garmentID?:string;
  genericCategory?:string; quantity:number; assignedEventIDs:string[];
  condition:ItemCondition; isPacked:boolean; itemWeightKg?:number;
  estimatedWeightRangeKg?:[number,number]; missing:boolean;
  userEdited:boolean; source:'OWNED'|'USER_ENTERED'|'GENERIC_NEED'|'LICENSED_CATALOG'};
type TripPlanDiff = {oldRevision:number; newRevision:number;
  changes:Array<{eventID:string; reason:'WEATHER'|'SCHEDULE'|'GARMENT'|'USER_EDIT'|'SOURCE_CHANGED';
    beforeItemIDs:string[]; afterItemIDs:string[]}>; requiresApproval:boolean};
```

**Invariants:** Trip local day uses destination timezone; ID references validate; deletion removes trip/private annotations while preserving wardrobe; outfit planning never mutates avatar body dimensions; packing checkboxes are user-controlled; unknown forecast never serialized as 0°C; item clothing condition is not inferred solely from planned wear; a missing `brandSKU` cannot become a purchase link; provenance never falsely claims official status. Use optional coordinates at destination granularity only, not user's live whereabouts. User-controlled export explicitly redacts personal body, birthdate, exact coordinates and private itinerary by default.

**Storage:** Existing local encrypted/protected database pattern (`SwiftData`/SQLite depending ADR). Persistence migration v1.1→v1.2 must be backward-compatible and recoverable. No server trips table by default. Weather cache separated from locally private itinerary; cache expiry and purge on trip deletion. `TripPlanDiff` tracks local version updates and supports undo. Retained travel history is opt-in and deletable.

---

# 48. OCTOPUS TRAVEL ARMS — LOCAL KNOWLEDGE, CONTROLLED EVOLUTION

This is an extension of **existing §28 Octopus**, not an excuse to build 12 new concurrent LLM processes. Start with bounded native modules and tiny opt-in ML where relevant. Each arm has a defined contract and can be tested independently.

| Arm / owner | Data read | Output | Failure / privacy constraint |
|---|---|---|---|
| `TRIP_ORCHESTRATOR` | minimal Trip and revisions | tasks, dependency graph, decisions | no unbounded recursive agents; cancellable |
| `DESTINATION_WX` | city/day/coarse coordinates | sourced weather evidence | stale/not-in-horizon explicitly labeled |
| `ITINERARY_ACTIVITY` | user events | outfit slots/needs | no silent calendar/account reading |
| `VENUE_CULTURE_EVIDENCE` | official venue/user rules | grounded restrictions | no identity/culture stereotype inference |
| `WARDROBE_AVAILABILITY` | allowed local garment tags | feasible owned candidates | stays local; no photos to remote |
| `TECHNICAL_FIT_MATERIAL` | garment+body data permitted in existing engine | fit/mobility/fabric flags | honest G-tier and missing manufacturer info |
| `CAPSULE_OPTIMIZER` | garment features, events, bag constraints | optimized packing set | deterministic, auditable, no fabricated weight |
| `COLOR_STYLE_DIRECTOR` | palette + preferences | coherent outfit rankings | no beauty/objective worth score |
| `LAUNDRY_REWEAR` | user-controlled condition state | re-use constraints | never marks worn based only on schedule |
| `RETAIL_GAP_EXPLAINER` | true uncovered requirement | substitute options; optional shop intent | no ad bias or unsupported affiliate stock |
| `TRAVEL_RENDERER` | chosen outfit IDs and preexisting avatar | G-level preview | neutral avatar remains private; 2D fallback |
| `TRIP_CHANGE_DETECTOR` | weather snapshot diff / user event revisions | localized replan proposal | user confirmation for packed/locked changes |
| `COST_ENERGY_GUARD` | battery/thermal/available memory | tier, task scheduling | no background gallery/3D scans when degraded |
| `PROVENANCE_PRIVACY_AUDITOR` | source metadata and output manifest | issue flags/abstention | no sensitive egress; fails closed |

## 48.1 Runtime sequence

`NewTripRequested → ValidateDatesAndDestination → ReadLocalWardrobeIndex → GetOrUseCachedWeather → BuildEventSlots → ReadGroundedVenueRules (optional) → CandidateOutfits → EnforceHardConstraints → CapsuleSetCover → ExplainWhyAndUnknowns → SaveLocalPlan → RenderFirstCard → Optional3DPreview`.

Network responses (weather, optional official/authorized venue data) provide **data**, never instructions to the app. Sanitize prompt injection from web text; isolate content from control-plane tasks. Do not send itinerary, DOB, exact body measures or photo bytes to third-party model services. Offline/local reasoner can use deterministic templates; if device lacks optional ML acceleration, fall back gracefully. Controlled model evolution is inherited from §29: model versions signed, canary/regression bench, rollback; *not* perpetual self-editing in production without review.

## 48.2 Incremental replan

Use content-addressed dependencies: a change to day-4 weather invalidates outfits for day 4 and connected item availability across other days, not every 3D mesh. If a substitute top becomes used elsewhere, global packing coverage must be rechecked. User-locked outfits require explicit review before replacement. Provide `PlanDiff` showing exactly what changed and why.

---

# 49. PLATFORM ARCHITECTURE, SERVICES, ENERGY AND OFFLINE FIRST

## 49.1 Proposed directories (adapt to existing repo, no duplicate architecture)

```text
Features/Travel/
  UI/TripEntryView.swift, TripWizardView.swift, TripSummaryView.swift
  UI/DayOutfitView.swift, SuitcaseView.swift, ContextEvidenceView.swift
  UI/TripTryOnView.swift, TripChangesView.swift
  Domain/Trip.swift, TripEvent.swift, OutfitPlan.swift, PackingList.swift
  Services/TripPlanner.swift, WardrobeAvailability.swift, CapsuleOptimizer.swift
  Services/TravelWeatherService.swift, VenueGuidanceService.swift, TripChangeDetector.swift
  Persistence/TripRepository.swift, TripSchemaMigration.swift
  Fixtures/Trips/ (synthetic deterministic; no real user body photos)
  Tests/Unit/, Tests/Integration/, Tests/UI/, Tests/Device/
Docs/Travel/{PRD,ARCH,ADRs,DATA_DICTIONARY,THREAT_MODEL,TEST_MATRIX,BENCHMARKS}.md
```

Shared `Garment`, `BodyMorphProfile`, `Outfit`, style engine, 3D renderer, weather adapter and privacy modules must be **reused**, not cloned. Dependency-inject interfaces; no massive monolith view. A standalone microservice is not justified for an on-device packing-list feature. If retailer feed exists, only product/category gap lookup uses contracted endpoint.

## 49.2 Failure/resource handling and SLO candidates

- **Target to validate, not guarantee:** After warm cached-wardrobe state, first 5-day plan summary on an agreed baseline device within a user-perceived responsive window; record p50/p95, memory peak and energy before choosing hard threshold. Suggested engineering trial: warm/cached p95 ≤2s for 100 garments/5 days, excluding network; cold network explicitly shows progressive UI and cancellation. If benchmark cannot meet target, optimize planner or reduce enrichment before releasing.
- **No permanent camera/AR** while the user edits packing. On device high thermal (`serious`/`critical`) stop optional 3D and expensive enrichment; preserve checklist/outfit list; low power uses low-res cached thumbnails.
- Weather fetched on explicit planning, foreground refresh and OS-allowed limited background pathways; budget network calls, cache, dedupe, exponential backoff; do not promise polling while app suspended.
- Cache only derived weather/context not a third-party copyrighted travel photo unless licensed; purge expired contextual data; respect entitlement/attribution and provider quotas.
- City lookup needs disambiguated region/country and time zone; inaccessible geocoder has manual city/country fallback with `TIMEZONE_UNVERIFIED` until confirmed.
- All core packing and itinerary operations work without account, Internet, Photos access, Core ML availability or 3D. Smartphone should not become hot merely to tick a packing checkbox.

## 49.3 Security boundaries

`TravelWeatherService` sees destination (not current location unless opted in); `VenueGuidanceService` sees requested place/activity only, no body or name; `CapsuleOptimizer` reads local abstract garment metadata and returns local suggestions; `TripRenderer` reads avatar locally. Remote `PartnerRetailService` sees a requested SKU/region, never body mesh or private events. Links open safely and ask permission before external application transitions. NS* permission strings must describe intended use accurately.

---

# 50. PERSONALIZED TRAVEL UX INTELLIGENCE — RELEVANCE WITHOUT SURVEILLANCE

## 50.1 Personalization signal levels

- **Tier 0:** no account/no photo → travel day categories, weather source and generic editable packing list.
- **Tier 1:** wardrobe added → recommend from actual owned items and show thumbnails.
- **Tier 2:** optional style preferences, events, fit/body editor → stronger personalized silhouettes and 3D preview.
- **Tier 3:** local feedback from prior user-approved trips → learn their reuse, comfort and bag-lightness preferences, with undo/reset.
- **Never automatic:** religious affiliation, national origin, medical state, financial status, exact body change over time, intimate image interpretation. Avoid using age as a universal dress restriction; let requested occasion and personal taste guide choices.

## 50.2 Trip preference memory (local only)

“Bu pantolonu yolculukta hep seviyorum”, “Sık yürüyüşte topuklu ayakkabı önermeyin”, “Mümkün olduğunca tek kabin valizi”, “Akşam yemeği için bir şık alternatif” can become reversible local preference rules. Each change has origin `EXPLICIT / CONFIRMED_FEEDBACK` and last updated timestamp. Suggestions about future travel can be declined without penalty. No automatic general-purpose inference about lifestyle from past location trails.

## 50.3 Optional reminders

Packing deadline/reminder and forecast-refresh notice (when new data exists) are **opt-in**, OS-approved local notifications, cancelable and quiet. Do not guarantee exact time or continuous monitoring. Calendar integration is a separate consent gate; neither destination nor trip dates should be broadcast as analytics events.

---

# 51. RETAIL, FIRM PARTNERSHIP AND GROWTH IN THE TRAVEL CONTEXT

## 51.1 Consumer loop

`Own wardrobe → first travel plan → check/pack → wear and adjust → voluntarily rate useful suggestions → better local personal plan next trip`. Shareable card can show “5 gün / 9 parça” *only if actually computed and reviewed*, without destination/date by default. No unsolicited contact or uploading trip plans. Encourage “use what you already own”; missing-item acquisition is optional and honest.

## 51.2 Brand/retailer collaboration surfaces

- **Authorized retailer gap fulfillment:** “Böyle bir yağmurluğum yok” → partners may offer region/size/season matched **actual products** via licensed feed; no browsing other brands' copyrighted catalogs without permission.
- **Travel capsule collections:** Retailer supplies verified product bundles, size variants and material data. Label sponsored placements clearly and protect unbiased fit recommendations.
- **In-store integration:** Customer scanning a product can add it to a trip bag “bu tatilde kaç kombinle çalışır?” without disclosing personal itinerary/body to partner. Computation stays on user phone.
- **B2B reporting:** Aggregated opt-in data with suppression thresholds; no specific traveler routes, trip dates, images, age or body measurements. Measure *incremental* conversions/returns without claiming causality from views alone.
- **Merchant pitch:** “Kullanıcı zaten dolabında olanı önce görür; siz ihtiyaca gerçekten uyan eksikleri sunarsınız. Doğru ürün, şeffaf beden ve anlık mağaza deneyimi.” This is a commercial hypothesis needing pilot measurement.

## 51.3 Revenue guardrails

Don't make weather safety, privacy deletion, essential list or basic packing paywalled. Potential premium: multi-stop adaptive capsules, unlimited saved trip lookbooks, advanced luggage optimization, style customization. Price willingness, subscription conversion, and travel partner commissions are **research hypotheses**, not revenue projections. Affiliate relationships must never override accuracy and user ownership; obey app store policy and region-specific advertising laws.

## 51.4 Go-to-market experiments

A: Consumer landing-page tests and truthful travel demos; B: 20–30 moderated users planning upcoming trips, collect before/after items and satisfaction; C: opt-in existing digital wardrobe users with packing behavior; D: one authorized travel apparel retailer feed pilot; E: evaluate fit and conversion impact with randomized or comparable controls. Plan sample size before making statistically strong claims; no “%60 daha hafif valiz” without matched measured results.

---

# 52. TRAVEL PRIVACY, LAW, ABUSE AND SAFETY THREAT MODEL

## 52.1 Threats and mitigations

| Threat | Mitigation / test oracle |
|---|---|
| Inferred home vacancy from trip dates / destination | never transmit private trips by default; share cards redact dates/destination unless deliberate preview and user action; no public profile itinerary |
| Third-party weather API receives detailed current location | use destination-level coordinates only; don't send precise phone location without separate explanation and consent |
| Official venue pages inject instructions into AI or display false rules | treat as untrusted content, allow only parsed cited dress-code evidence after validation; safe allowlist/escaping; human confirmation |
| Tracking exact religious/cultural preferences | optional styling constraints stored local and not reclassified as user religion; accessible delete |
| Sensitive wardrobe/private body inferred by brand | only SKU, locale and optional generic size choice with explicit user consent; never body mesh, DOB, face, trip itinerary |
| Weather forecast unavailable/stale and misleading | prominent state/provenance, no fabricated hazard or temperature; seasonal fallback clearly named |
| Unknown airline baggage size/weight presented as confirmed | require airline-specific verified policy or user input; otherwise unknown, no precise fee prediction |
| Incorrect event dress code or footwear causing embarrassment/inconvenience | source/validity/override and conservative fallback; never universal cultural stereotypes |
| Automatic “dirty item” label harms user trust | never infer washing need solely from plan and never make shaming judgments |
| Baggage optimization removes critical essentials | hard constraints, critical-coverage tests, editable lock/reserve and independent coverage audit |
| Foreground battery/thermal cost excessive | incremental calculations, lazy 3D, low-power fallback, performance test on real iPhones |
| Unlicensed brand/site photographs used in travel scenes | require provenance/licensed rights or local generated original assets; render neutral fallback |

## 52.2 Retention/access/erasure

Trip and itinerary are private local records; do not sync unless the product introduces a separately audited opt-in cloud feature. Delete selected trip removes its events, packed states, trip-derived local notes, cached custom contextual records where lawful/technically applicable; wardrobe remains unless separately deleted. Reset preference history deletes only travel learning. Accessibility alternatives (VoiceOver, large text, reduced motion, color-blind accessible category indicators) are P0.

## 52.3 Permission/marketing safety

No SMS marketing, no hidden pixel, no sale of itinerary, no public social route map by default. If destination suggestions involve official safety warnings, show accurate source links, not invented medical/safety guarantees. Children/minors need special age/privacy policy review before features that share location or identity; do not expand scope silently.

---

# 53. RELEASE / VALIDATION GATES AND MEASUREMENT PROTOCOL

| Gate | Required evidence | Blocker response |
|---|---|---|
| `G-TRV-BASE` | no-account wizard; 5 days; real local wardrobe fixtures; 1–3 outfits/day; linked packing checklist; accessible iPhone UI; durable persistence | mark feature `NOT_READY`, keep existing wardrobe working |
| `G-TRV-WX` | WeatherKit/offline/mock distinction; source/issue/TTL attribution; forecast horizon and seasonal fallback; change diff | no live weather claims; show local no-data planner |
| `G-TRV-CAPSULE` | deterministic 5-day coverage; user locks; handling no-feasible plan; source/unknown weights; no duplicates; capacity scenario suite | simple editable checklist, no “optimized” claim |
| `G-TRV-CULTURE` | official venue references valid; no identity inference; no stereotype; manual overrides | only user-entered venue dress codes |
| `G-TRV-3D` | device 3D tier truth; no raw body uploads; studio fallback; frame/thermal evidence | show outfit thumbnails instead |
| `G-TRV-REPLAN` | revisioned forecast/itinerary/wardrobe changes; packed garment preservation; explicit diff/approve | do not silently mutate saved trip plan |
| `G-TRV-PRIVACY` | static/dynamic egress tests; share redaction; delete data; permission-denied workflows | block release until resolved |
| `G-TRV-DEVICE` | agreed physical iPhone matrix, iOS version, locale, Dynamic Type, VoiceOver, airplane mode, warm/cold benchmark results | do not claim real-device pass from simulator |
| `G-TRV-RETAIL` | legal feed/attribution/variant truth, transparent sponsor disclosures, no body itinerary leak | shopping gap remains category-level and partner-free |

## 53.1 Performance and correctness benchmark fixtures

Build **synthetic** deterministic fixture matrix: 0/15/100/500 garments; 2/5/14 days; 0/1/3 destinations; 0/3/20 events; network online/offline/stale; no/lite/full avatar; low battery/thermal; culturally sensitive venue constraints; empty/partly owned travel wardrobe. Track plan p50/p95/max and peak memory and energy on devices. Benchmark deterministic helper with seed and expected packed-ID set. Observe not just aggregate speed but missing essential coverage, repeated outfit alternatives and user editing time.

## 53.2 Counterfactual and benchmark honesty

A theoretical packing weight computed from guessed garment weights is not proof of savings. A mocked 5-day weather fixture is not a verified forecast. A beautiful travel image is not a real landmark scene. A checklist written in Markdown is not an interactive app. A success in simulator is not automatically an iPhone pass. External API documentation does not establish WeatherKit entitlement exists in developer account.

---

# 54. v1.2 ACCEPTANCE TEST MATRIX — REQUIRED EXECUTABLE TESTS

Every test below is a **specification awaiting implementation**. Create runnable tests with explicit `PASS|FAIL|NOT_RUN|BLOCKED` and attach commit, command, device/OS, fixture, screenshot/log, observable result and source metadata when applicable. No generic “all good” statement.

### 54.1 Trip flow, date, offline (T-TRV-001..016)

- `001` new user with no account creates 5-day trip; `002` skip all photo/geo permissions and still see generic plan; `003` city duplicate disambiguation; `004` timezone crossing resolves local dates correctly; `005` 5 days vs 5 nights distinction; `006` two-day leap-year transition; `007` DST spring/fall transition; `008` invalid zero/past dates handled politely; `009` 1–14-day limit clear with future extension path; `010` offline create/edit/save/check; `011` trip survives app termination/restart; `012` simultaneous edit resolves deterministic revision; `013` delete trip keeps wardrobe untouched; `014` trip active state never reveals itinerary on home notification without opt-in; `015` VoiceOver wizard completion; `016` long-text/Dynamic-Type layout.

### 54.2 Weather and climatology (T-TRV-017..030)

- `017` known forecast source shows issued time and provider; `018` fetched after validity expires triggers stale label; `019` future day outside actual forecast coverage never shows invented forecast; `020` seasonal guidance explicitly nonforecast; `021` no climate dataset yields no-data not invented numbers; `022` official weather alert exact source/required link; `023` wet/windy evening triggers reasonable layering recommendation via fixture; `024` opposite-hemisphere summer/winter handled; `025` negative temperatures preserved not “0 means unknown”; `026` no location permission still permits destination weather; `027` API fails → cached degraded mode; `028` cached weather changes only relevant days; `029` attribution appears correctly under provider's actual terms; `030` forecast return order changed does not mix dates/timezones.

### 54.3 Cultural and venue safety (T-TRV-031..041)

- `031` same destination, differing venues gives venue-specific recommendation; `032` unknown venue guideline never fabricated; `033` expired source flagged; `034` official dress code + user locked style visible rationale; `035` destination country doesn't infer religion; `036` name/skin-tone changes do not alter baseline venue requirement; `037` official-source prompt injection ignored; `038` anonymous review cannot become mandatory dress code; `039` manual user override persists; `040` accessible respectful wording; `041` no unsupported universal rule about local culture.

### 54.4 Capsule packing, garment, laundry (T-TRV-042..066)

- `042` 5-day all-occasions covered; `043` exact small case matches reference optimal cover; `044` no viable outfit yields explicit gap; `045` owned substitute before store offer; `046` locked outfit preserved; `047` same garment packed once for multiple outfits; `048` quantity for socks/underlayers editable; `049` dirty status never inferred from planned usage; `050` user-worn confirmation updates state; `051` laundry unavailable disables fictional refresh; `052` laundry available user-configurable drying constraints; `053` unknown garment weight not treated as 0 in exact weight guarantee; `054` user-entered baggage max produces true overlimit warning for measured weights; `055` unknown carrier allowances remain unknown; `056` capsule-versus-variety slider changes optimization predictably; `057` event addition causes valid localized replan; `058` alternate shoes selected where walking constraints require; `059` rain protection only attributed when supported; `060` new garment in wardrobe appears without duplicate; `061` removed garment invalidates dependent outfits; `062` weather update generates diff instead of silent rewrite; `063` three destinations, separate date/timezone weather scopes; `064` 500-item performance memory bounded; `065` reusable bottoms aren't automatically marked unclean; `066` explicit manual suitcase contents override suggestions.

### 54.5 3D, on-device ML, resource and privacy (T-TRV-067..081)

- `067` 3D uses same neutral local avatar without server upload; `068` unsupported garment G-tier labeled; `069` offline 2D fallback works; `070` no landmark asset licence means generic scene; `071` low-power skips optional 3D and keeps checklist; `072` thermal serious/critical cancels enrichment; `073` no background gallery scan initiated by travel; `074` no personal itinerary sent to retail endpoint; `075` no body/DOB sent to weather endpoint; `076` share preview hides destination/dates by default; `077` delete trip removes private annotations/cache according to contract; `078` reset preference personalization independent of wardrobe; `079` symbolic layer not used without explicit opt-in; `080` unknown real-time weather and unlicensed data clearly abstain; `081` no ongoing GPS tracking.

### 54.6 Business, UX evidence and ship gates (T-TRV-082..092)

- `082` no retailer integration still fully usable; `083` sponsored items labeled and neutral fit not overridden; `084` unlicensed partner image is not rendered; `085` missing inventory availability not invented; `086` date/region-sensitive product feed stale flagged; `087` local packing actions do not trigger external API requests; `088` empty/error/no-permission/partial loading snapshots captured; `089` reduce motion and accessibility contrast honored; `090` real-device p50/p95 memory/thermal logs attached; `091` saved outfit and wardrobe cross-references survive schema migration; `092` pilot claims supported by measured results or clearly hypothesis only.

**Do not mark any of these 92 cases PASS merely because it appears in the document.** Build executable tests and real-device evidence. Target strict release gates for P0 failures. If no iPhone hardware available, maintain `BLOCKED_DEVICE`; simulator screenshots are labeled `SIMULATOR_ONLY`.

---

# 55. PHASED IMPLEMENTATION BACKLOG — 18 DEPENDENCY-SAFE WORK PACKAGES

All items use `WP-TRV-xx`. `REQ-TRV` map defined below. Claude should choose concrete code ownership, testing command and evidence path per packet; avoid parallel agents changing one domain type before it is frozen.

| WP | Deliverable | Priority | Dependency / minimal acceptance |
|---|---|---|---|
| `TRV-01` | Reality audit + trip PRD + threat/model/provider ADRs | P0 | existing repo design, no new false claims |
| `TRV-02` | Typed trip/event/weather/packing domain + schema migrations | P0 | unit tested, reversible |
| `TRV-03` | Travel entry and 30-second wizard | P0 | no permissions required, VoiceOver |
| `TRV-04` | Destination identity, date/timezone resolver and manual fallback | P0 | edge-case tests |
| `TRV-05` | Local wardrobe availability/condition adapter | P0 | existing garment schema reused |
| `TRV-06` | Synthetic weather fixtures + provider interface + NO_DATA fallback | P0 | deterministic tests before external API |
| `TRV-07` | Deterministic feasible outfit candidate generator | P0 | weather/activity/venue hard constraints |
| `TRV-08` | Capsule cover optimizer + explanations | P0 | 5-day coverage and optimal small fixtures |
| `TRV-09` | Packing checklist + explicit packed/manual states | P0 | airplane mode/persistence |
| `TRV-10` | Day planner timeline and daily outfit cards | P0 | change/swap/lock/why/unknown |
| `TRV-11` | Authorized WeatherKit adapter + attribution + stale controls | P0/P1 | entitlement/cost/availability gate |
| `TRV-12` | Forecast/plan revision diff and user-approved replan | P1 | saved packed/locked garments preserved |
| `TRV-13` | Licensed venue guidance + cultural non-stereotype audit | P1 | verifiable source or abstain |
| `TRV-14` | Existing 3D avatar and garment rendering reuse | P1 | real-device fidelity/perf tests |
| `TRV-15` | Multi-destination and baggage capacity variants | P1 | timezone and unknown weights |
| `TRV-16` | Retail gap fulfilment, only with valid catalog rights | P1 | optional and privacy-safe |
| `TRV-17` | Real-device benchmark, privacy audit, UI snapshots | P0 release gate | tests/logs/screenshots/rollback |
| `TRV-18` | Controlled market pilot & monetization experiment plan | P2 | no partner/ROI claims without proof |

**Priority order:** If base app's wardrobe, permission layer, thermal governor, body/3D and model contracts are not verified, build only a self-contained demo travel vertical slice with synthetic closet fixtures and the existing stable primitives. Do not let Travel Mode block core WEARFORM iOS launch unless explicitly chosen as release scope. Never create 18 services/teams because there are 18 work packages.

## 55.1 Traceable v1.2 requirements register

- `REQ-TRV-001..005`: destination/time/date and event wizard; no-location/no-photo path; timezone; state lifecycle.
- `REQ-TRV-006..010`: source-tagged forecast; climatology boundary; cache/TTL/attribution; alerts; graceful offline.
- `REQ-TRV-011..016`: activity/formality/weather candidate looks; fit/comfort/material evidence; local 3D; manual override.
- `REQ-TRV-017..026`: capsule packing; owned-first; laundry/wear; baggage constraints; gap explanation; checklist persistence.
- `REQ-TRV-027..031`: venue source policy, no culture stereotyping, user modesty preferences, no religious/identity inference, safe overrides.
- `REQ-TRV-032..037`: on-device data partition; no trip/face/body egress; deletion; share redaction; battery and thermal controls.
- `REQ-TRV-038..042`: provider licensing, retail catalog permissions, documented purchase gap, sponsored placement transparency, brand data provenance.
- `REQ-TRV-043..048`: deterministic plan diff, multi-destination handling, real-device metrics, accessibility and localization, controlled personalization/rollback, independent audit.

The range IDs above are **requirements registry placeholders**, not implemented acceptance conditions. Claude must expand each into one atomic `docs/requirements/REQ-TRV-NNN.md` item with fields `owner, problem, user, flow, input/output, source rights, data access, business rules, failure state, offline fallback, tests, evidence`. Reject any broad “travel mode finished” ticket without atomic mapping.

---

# 56. CONCRETE FIVE-DAY DEMONSTRATION — EXPLICITLY FICTIONAL FIXTURE

This example demonstrates expected **structure**, not live weather, verified venue policy, actual user wardrobe or proven recommendation results. Test data must be tagged `SYNTHETIC_DEMO_ONLY` in the UI and CI.

**User selected:** “5 gün, Barselona, şehir gezisi + müze + 1 şık akşam yemeği; kabin valizi; çamaşır yok; hafif ve rahat giyim.” Dates/weather not supplied. Thus **no degree values** and no “yarın yağmur” claim. Owned synthetic closet: 2 basic tops, 1 lightweight overshirt, 1 casual shirt, 1 trousers, 1 jeans, 1 light jacket, 1 comfortable shoes, 1 evening shoes, socks/underlayers. All inventory/condition statuses synthetic.

| Day | Event | Primary styling idea | Source truth |
|---|---|---|---|
| 1 | Arrival + walk | comfy shoes + trousers + neutral top + light layer | activities/user preference; weather pending |
| 2 | Museum + outdoor stroll | jeans + second top + light jacket optional | activity/style; venue code unknown |
| 3 | Day walk + dinner | daytime swap; evening: casual shirt + trousers + evening shoes | explicit formal occasion |
| 4 | Walking + shopping | trousers + reused lightweight top only if user confirms wearable | wardrobe/condition state |
| 5 | Departure | travel-comfort capsule, weather layer if verified later | activity/weather pending |

The system computes and displays actual **union of used garment IDs**, not 5 outfits pasted as 5 separate packing lists. Socks/underlayers use user-specified quantities (safe editable defaults). It can suggest outerwear even if not owned, but only as an unresolved gap, not a pretend possession. It never silently switches to a different brand's product. If weather enters forecast horizon, user gets a change proposal with “hangi gün hangi parça değişti.”

**Acceptance demo script:** Create trip without Photos or Location permission → use locally seeded synthetic closet → select 5 days + events → generate 5 cards and a deduplicated checklist → tick packed → lock dinner look → simulate weather update fixture → show plan diff preserving lock → open neutral 3D/2D preview → airplane mode and reopen → edit/delete trip and check isolation. Record actual run/build/device logs and screenshots.

---

# 57. CLAUDE START HERE — BINDING V1.2 EXECUTION ORDER / DELIVERABLE

> **CLAUDE, execute and verify, not only summarize.** From canonical v1.2 read §§0 and 39–58 first. Check actual repo, active branch, Xcode/toolchains, entitlement, existing modules, device availability and test runner. Do not assume v1.1 app is finished. Build a dependency-safe `TRV-01..TRV-10` working slice with local fixtures and no external account dependencies, starting with local trip types + wizard + 5-day offline capsule optimizer + packing checklist; reuse existing wardrobe UI and model schemas. If product repo is empty, scaffold the smallest valid iOS project and tests without claiming shipping readiness. Make every meaningful code change reviewable and backout-able.

**Before writing code:** Record in `docs/travel/TRAVEL_REALITY_BASELINE.md` actual status of existing wardrobe/3D code, available weather entitlements, available source rights, supported devices and unresolved constraints. Decide ADR for algorithm (simple deterministic first) and compare one small reference optimization fixture. Do not do paid web API calls, install paid service, scrape brand sites, connect private external accounts, send live mail or push app release without explicit owner approval.

**After a meaningful vertical slice:** Provide a truthful report exactly like this:

```text
WEARFORM v1.2 — TRAVEL INTELLIGENCE EVIDENCE REPORT
Date / repo / branch / commit:
Canonical spec version: v1.2
Already existed before current session:
Newly implemented (file paths / exact behavior):
Only specified / mocked / blocked:
Weather provider (live / cached / synthetic / absent) + rights / attribution:
5-day packing coverage and known gaps:
Garment and avatar source / 3D fidelity tier:
Privacy: local data and explicit network request inventory:
Tests: actual command + result + IDs + log:
Device: model / iOS / p50-p95 / power / temperature / screenshots:
Accessibility and negative/adversarial cases:
Rollbacks / unresolved critical risks / gate statuses:
Next dependency-safe work package:
```

**No false certification:** A file creation, green unit test or pretty simulator screenshot does not prove the 3D clothes fit, the real weather is accurate, the garment will feel as real as wearing it, the destination's venue policies are correct, or the app is production ready. These require separate measurements, rights checks and user research. If needed, say `UNKNOWN`.

---

# 58. CURRENT PUBLIC REFERENCE / EVIDENCE REGISTER (REVERIFY AT IMPLEMENTATION)

| Source | What it establishes | What it does NOT establish |
|---|---|---|
| Apple WeatherKit https://developer.apple.com/weatherkit/ | weather SDK/REST, forecasts and subscription/attribution documentation | this project has an active entitlement; unlimited calls or availability at every destination |
| Apple WeatherKit REST https://developer.apple.com/documentation/weatherkitrestapi | daily/hourly, supported dataset concepts, alerts and attribution | predictions beyond returned horizon or stored use beyond terms |
| Apple Weather Attribution https://developer.apple.com/documentation/weatherkit/weatherattribution | provider attribution available and publishing obligation | attribution can be omitted from this product |
| Open-Meteo pricing https://open-meteo.com/en/pricing | commercial plan/licence information for provider comparison | public noncommercial free endpoint is automatically cleared for WEARFORM commercial use |
| Whering packing guide https://whering.co.uk/faq/planner-and-packing-list | current competitor states event-linked outfit planning + packing lists | all competitor internal algorithms/features are known |
| PackPoint App Store https://apps.apple.com/us/app/packpoint-travel-packing-list/id896337401 | competitor states date/destination/activity/weather/optional laundry-informed packing lists | its internal recommender performance or code |

These are public product/SDK descriptions accessed for architecture at document revision. Prior to API/production implementation verify current eligibility, legal terms, source validity, provider availability, cost and local jurisdiction. Never use another provider's branded imagery, scraped garment datasets or destination photographs without a lawful basis/licence.

---

**END — BINDING WEARFORM v1.2 TRAVEL INTELLIGENCE AMENDMENT.**

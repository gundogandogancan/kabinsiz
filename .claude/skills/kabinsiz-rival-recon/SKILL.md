---
name: kabinsiz-rival-recon
description: Study a competitor (Alta, Doji, Anywear, Google try-on, Cladwell, Daily Dress Me, Whering…) from public sources only and turn what users value into Kabinsiz features built our own way, on the device. Use when the founder asks to "take the best of competitor X", "reverse-engineer their features", or wants a parity / gap check. Never for extracting models, code, APIs or assets.
---

# Kabinsiz rival recon

Method adapted from `replica-recon` and `replica-entrepreneur` in Jake Schincariol's replica-skill
(MIT, © 2026 Jake Schincariol, https://github.com/Jakeschincariol/replica-skill). We used the method only;
no files were copied (ADR-017, Karar 4).

## Hard rules (fail closed)

- Public sources only: help pages, pricing, changelogs, official blogs, App Store listings, Apple's
  official customer-review RSS feed, press, walkthrough videos. Never log in to a rival, never make an
  account, never accept their terms on the founder's behalf.
- Never: decompile an IPA/APK, read JS bundles, record network traffic, call private APIs, bypass paywalls
  or quotas, scrape sites whose terms forbid it (Trustpilot, G2, Reddit API), or try to extract a model.
  v3.6: "Yetkisiz proprietary model tersine mühendisliği yapılmaz."
- Never copy text, images, icons, colours, layouts pixel for pixel, or brand names. We rebuild the job a
  feature does, in Kabinsiz's own design (Atelier tokens), on the device. Apple 4.1 (copycats) applies.
- Every claim gets an evidence class: `V` verified on an official page, `C` marketing/press claim,
  `U` unknown. Never invent numbers. Quotes stay under 15 words.
- Reviews: no reviewer names; excerpts of at most 20 words.

## Steps

1. **Scope.** Platform, the part of the app that matters to Kabinsiz, audience.
2. **Sources, ranked.** List them with URLs and dates.
3. **Screen and flow inventory.** Name each screen with a stable id and its empty, loading and error
   states. Count the taps on the happy path (from what is public: store screenshots, videos, help pages).
4. **Inferred data model.** Write each entity with a confidence level and the evidence for it.
5. **`features.csv`.** One row per feature, columns `feature × rival`, each cell an evidence class, plus a
   priority `must/should/could` for Kabinsiz.
6. **Can't-copy list.** Network effects, licensed catalogues, cloud-only models, B2B widgets.
7. **Reviews.** Collect 100+ from 3 or more sources. Sort them into themes. Write down what users hate,
   what is missing and what nobody has solved. End with the top 5–8 fixes.
8. **Parity (`parity.md`).** Score Kabinsiz on each row by whether it does the same job, not whether it
   looks the same: `DONE` / `PARTIAL` / `MISSING` / `BLOCKED_EXTERNAL`, with the file or test that proves
   it.
9. **Queue.** Turn every `MISSING` must/should row into a work package. For each package say:
   - the on-device approach;
   - the privacy line;
   - the tests;
   - the status class (CODED / SIMULATOR_TESTED / DEVICE_VERIFIED).

## Outputs

`docs/research/rivals/`: `recon.md`, `features.csv`, `reviews.csv`, `feedback.md`, `parity.md`.
The queue goes to `docs/audit/V36_FEATURE_QUEUE.md`.

# Rival App Store reviews: what users say

Collected 2026-11-04. Raw rows: `reviews.csv` (420 rows).

## Method
- Source: Apple's public customer-reviews RSS JSON feed (`itunes.apple.com/{sf}/rss/customerreviews/page=N/id=ID/sortby=mostrecent/json`), read with WebFetch. IDs from App Store listings / iTunes Search API. No login, scraping or downloads.
- Each review paraphrased (≤18 words), hand-tagged with 1–2 themes and one sentiment. No reviewer names.
- Caveats: counts are approximate (tagged from paraphrases). Cladwell gb/tr is mostly 2017–2024. One off-topic review was excluded. Unlisted pages were not fetched.

Counts (storefront: rows):
- **Alta Daily** (6481705400): us 99 (pages 1–2), gb 50, tr 0 (feed empty). Total **149**, average 4.56★.
- **Cladwell** (1140550878): us 50, gb 50, tr 3. Total **103**, average 2.76★.
- **Whering** (1519461680): us 50. Average 4.24★.
- **Acloset** (1542311809): us 50. Average 3.18★.
- **Doji** (6737292650): us 40 (whole feed), gb 6, tr 1. Total **47**, average 3.55★.
- **Daily Dress Me** (6447927117): us 20 (whole feed), gb 1. Total **21**, average 3.95★.
- Not fetched: Indyx (1599179405), Stylebook. Anywear skipped (web-only).
- Sentiment: 191 praise, 164 pain, 65 request.

## Themes ranked (rows tagged / rows where it is a complaint)
1. Paywall / price / billing (surprise charges, item caps, credits): 59 / 43
2. Outfit suggestion relevance: 59 / 29. In 7 rows the app suggests clothes the user does not own.
3. Crashes, bugs, save errors, data loss: 37 / 36
4. Organisation (categories, notes, drag-and-drop): 36 / 5. Mostly requests.
5. Adding items is tedious (photographing, misclassification, caps): 32 / 16
6. Weather / calendar: 27 / 16
7. Avatar realism / likeness: 26 / 10
8. Shopping links / catalog: 21 / 4
9. Background removal / AI clean-up that alters garments: 20 / 12
10. Navigation, UX, accessibility: 17 / 12
11. Account / login friction (phone OTP, lockouts): 16 / 15
12. Accessories and layering: 16 / 4, plus many requests
13. Support unresponsive: 10 / 10
14. Fit accuracy vs. looks: 9 / 6
15. Sizing, measurements, body diversity: 9 / 6
16. Speed: 5 / 3
17. AI forced on, no opt-out: 4 / 4
18. Privacy / photo: 3 / 2
19. Men's / gender options: 1 / 1

Avatar, fit, and sizing together: 25 non-praise rows about a body unlike the user. Men's/gender barely appears; the sample skews female, so this is unverified, not proof of no demand. Praise-only themes: wear more / buy less (26), planning and packing (17), saves time (14).

## Per app (top 3 loved / top 3 hated)
- **Alta Daily**
  - Loved: wearing more of the clothes they own; surprising combinations; seeing looks on the avatar.
  - Hated: suggestions that use unowned items or clash; "prettify" changes garments (skirt became a shirt, colours drift); avatar daily cap cut 25→10, plus logouts that wiped closets.
- **Doji**
  - Loved: realistic try-on; fast generations; pasting product links.
  - Hated: avatar too tall and skinny with the wrong face (the #1 complaint); phone-only sign-up and OTP failures; garments mis-rendered (miniskirt became a long skirt) and link parsing fails.
- **Cladwell**
  - Loved: capsule breakdown; less buying; weather-based suggestions (older reviews).
  - Hated: subscriptions (weekly charges, charged after cancelling); no accessories or layering and rigid categories; AI forced on users who opted out, plus update regressions.
- **Whering**
  - Loved: free with no catch; organisation; cutout quality.
  - Hated: photographing every item; poor generated outfits; save errors, lost calendar history, crashes on large closets.
- **Acloset**
  - Loved: free tier; mass import; packing and stats.
  - Hated: a 100-item cap found only after hours of uploading; crashes and slow uploads; paid "beautify" alters clothes and the weather is wrong.
- **Daily Dress Me** (pre-styled looks, no personal closet)
  - Loved: weather-by-city planning; simplicity.
  - Hated: stale, repeating looks; no item details or shop links; location bugs.

## What everyone fails at (unsolved)
1. A body that looks like *me*: defaults to a tall, thin model; no app takes typed measurements (Doji users ask).
2. Capture without hours of photos or AI rewriting garments.
3. Suggestions that stay inside the real closet, season, and weather.
4. Layering and accessories: jacket over shirt, tucked or untucked, jewellery.
5. Honest limits shown before users invest hours.
6. Reliable data: no logouts, failed saves, or lost history.

## Top 8 fixes for Kabinsiz (on-device)
1. **Body from typed measurements.** Height, shoulder, chest/bust, waist, and hip drive the parametric body, with a Kadın/Erkek/Nötr form. Never default to a model body.
2. **Garment fidelity.** The original photo stays the source of truth. Remove backgrounds on device (Vision foreground mask), offer a before/after toggle, never recolour or reshape, and add mirror and back-side slots.
3. **Owned-only suggestions.** The outfit engine reads only the local closet index, with a hard "only my items" invariant and mute and season flags.
4. **No account, offline data.** No login or OTP. Store locally (SwiftData/files) with export and backup.
5. **Fast batch capture.** Multi-select from Photos, on-device classification with editable categories, and a quick-confirm queue.
6. **Layering and accessories on 3D shells.** Ordered shell slots (base, mid, outer, accessory) with tuck and open-jacket states on the hand-turned model.
7. **Weather and calendar.** WeatherKit plus a persistent local plan/worn calendar and multi-day packing.
8. **Fit vs. look, shown honestly.** Compare optional garment measurements with body measurements and show a tight/loose heatmap on the shell, labelled as an estimate, never a flattering render.

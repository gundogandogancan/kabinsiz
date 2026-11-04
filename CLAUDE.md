# Kabinsiz — Claude Code proje talimatı

**Ürün adı:** Kabinsiz. Anayasadaki iç kod adı `WEARFORM` ile aynı ürün. Kodda, dokümanda ve UI'da ürün adı olarak **Kabinsiz** kullan. Anayasa §0'a göre marka/alan adı/tescil araştırması yapılmadan kamuya açık marka ilanı yok (`BLOCKED_EXTERNAL`).

## Bağlayıcı kaynak

- **Kanonik:** `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v3.2.md` + ekler `docs/constitution/addenda/` (v3.3 gerçeklik denetimi, v3.4 Octopus/katalog/kendi VTON, v3.5 şehir dünyası/kişisel avatar, **v3.6 rakip teknik benchmark**, `EXTERNAL_STACK_AND_RIGHTS_MATRIX.csv`, `V33_GAP_REGISTER.csv`). Başlangıç komutları `docs/constitution/commands/` (son: `CLAUDE_START_HERE_v3.5.md`, `CLAUDE_EXECUTION_DIRECTIVE_v3.3.md`). v2.8 ve eski ana dosyalar `docs/constitution/archive/`. Figma token taslağı `docs/design/figma/`. Live Mirror atlası `docs/design/LIVE_MIRROR_SCREEN_ATLAS.md`.
- **Okuma sırası:** v3.6 → v3.5 → v3.4 → v3.3 → v3.2 ana → gerektikçe archive (v2.8 IA/sabah hazır kuralları hâlâ geçerli olduğu yerde).
- **Öncelik:** hukuk/KVKK/platform → kullanıcı rızası ve yerel-öncelikli mahremiyet → güvenlik/kanıt ve fail-closed → **kullanıcının açık kararları** (ör. 2026-11-04 "model yalnız elle döner" ADR-016, "kadın/erkek beden formu" ADR-017) → v3.6 → v3.5 → v3.4 → v3.3 → v3.2 → archive → kanıtlı repo durumu → eski ADR. Daha sıkı güvenlik kuralı her zaman kazanır; çatışma ADR ile çözülür (son: `docs/adr/ADR-017-owned-live-mirror-body-form-city-tiers.md`; ADR-016 elle dönen model/giydir, ADR-015 canlı ayna iskeleti, ADR-012/013 şehir, ADR-014 barkod/fotoğraf). Bulut VTON (Decart dahil) asla varsayılan değil: açık rıza + sözleşme/DPA + maliyet sınırı + gerçek iPhone testi olmadan kapalı (`BLOCKED_EXTERNAL`). FASHN insan ayrıştırıcısı (NVIDIA NC), SMPL/SMPL-X, Hunyuan3D BLOCKED; lisans tablosu `docs/architecture/V35_LICENSE_GATE.md`. Figma: View koltuğu → `BLOCKED_EXTERNAL_FIGMA`.
- **Sıradaki iş:** `docs/audit/V35_REALITY_LOCK.md` + `docs/audit/V36_FEATURE_QUEUE.md` (rakiplerin en iyisi, cihazda). Rakip keşfi yöntemi `.claude/skills/kabinsiz-rival-recon` (yalnız herkese açık kaynak; model/kod çıkarma yok), çıktılar `docs/research/rivals/`. Kod `v35/world-avatar` (v25/living-world üstüne) branch'inde; main'e kullanıcı onayı olmadan birleşmez.
- `docs/constitution/archive/` sadece geçmiş içindir. Çatışmada v3.6 → v3.2 öncelik zinciri geçerlidir.
- Araştırma: `docs/research/VTON_LANDSCAPE_2026-11.md` (VTON/avatar modelleri ve lisans hükümleri: NC lisanslılar ve SMPL/SMPL-X ticari kullanılamaz).
- Karar hiyerarşisi: güvenlik/hukuk/platform → kullanıcının açık kararları → anayasanın değişmez ilkeleri → teknik varsayımlar → ADR.

## Çalışma kuralları (özet; ayrıntı anayasada)

- Platform iPhone-first, offline-first, on-device. Android ayrı kapıdan sonra.
- Her iş paketi şu döngüden geçer: `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → TEST → PERF/PRIVACY → BAĞIMSIZ REVIEW → EVIDENCE → GATE`.
- ID'ler: `REQ-*`, `EV-*`, `T-*`, `ADR-*`. Kararlar `docs/DECISION_REGISTER.md` dosyasında tutulur.
- **Sahte bitmişlik yok.** Mock, sentetik ve engelli olanları raporda ayrı yaz; bilinmiyorsa `UNKNOWN` de.
- İnsan onayı gerektirenler: ücretli harcama, dış hesap, gerçek kullanıcı verisi, sözleşme, marka tescili, canlı ödeme, App Store/TestFlight yayını, kamuya gönderim.
- `STOP_THE_LINE` koşulları: mahremiyet sızıntısı, yanıltıcı beden/uyum iddiası, belirsiz veri hakkı, App Review ihlali, kırık build.
- iOS projesi XcodeGen ile üretilir (`~/.local/bin/xcodegen`). Toolchain: Xcode 26.6. Bu Mac'te brew, docker ve uv yok; `gh` `~/.local/bin/gh`, Blender 5.2.3 `~/Applications/Blender.app` (PATH'te değil). Blender MCP kullanıcı kapsamında `blender` (telemetri kapalı, ADR-015); giysi çizimleri `tools/garments/` (headless).
- Kullanıcıyla Türkçe konuş.

## Uzman ajanlar (anayasa §17 → `.claude/agents/`)

Ajanlar ayrı süreç değil, ayrı review bakış açısıdır. Kendi yazdığın güvenlik kodunu aynı ajan nihai olarak onaylayamaz.

| Anayasa rolü | Projedeki ajan(lar) |
|---|---|
| AG-01 Product/Consumer Research | `product-manager`, `design-ux-researcher` |
| AG-02 Product Design Director | `design-ux-architect`, `design-ui-designer`, `design-brand-guardian`, `design-ui-finish-gate-reviewer` |
| AG-03 iOS Tech Lead | `engineering-mobile-app-builder` |
| AG-04 Geometry/3D (RealityKit) | `visionos-spatial-engineer` (RealityKit/USDZ bilgisi için) |
| AG-05 CV/On-device ML QA | `specialized-model-qa` |
| AG-09 Privacy/Security | `engineering-privacy-engineer`, `data-privacy-officer`, `security-architect`, `security-appsec-engineer` |
| AG-10 QA/Accessibility | `testing-accessibility-auditor`, `testing-reality-checker` |
| AG-12 Independent Red-Team | `security-ai-generated-code-auditor`, `testing-reality-checker` |
| AG-13 Release/App Review | `engineering-mobile-release-engineer`, `marketing-app-store-optimizer` |
| AG-14 Commercial/Legal | `support-legal-compliance-checker` |
| Growth (§33) | `marketing-growth-hacker` |

AG-06 (Fit Science), AG-07 (Styling), AG-08 (Retail) ve AG-11 (Perf/SRE) için hazır ajan yok. Bunlar gerektiğinde anayasa §17.2 kart formatıyla `.claude/agents/` altına yazılır.

## Skill'ler

- **Projeye özel (`.claude/skills/`):** `design-motion-principles` (MIT, kylezantos; hareket/etkileşim: mobil = incelikli cila önce, sık işlem animasyonsuz, Hareketi Azalt'a uy), `swiftui-patterns`, `swift-concurrency-6-2`, `swift-actor-persistence`, `swift-protocol-di-testing`, `ios-icon-gen` (ECC); `spec-to-code-compliance`, `differential-review`, `sharp-edges`, `audit-context-building` (Trail of Bits); v3.5 paketi (`city-scene-geo-pipeline`, `local-live-mirror-engine`, `private-avatar-face-hair`, `weather-material-stage` …) ve `kabinsiz-rival-recon` (replica-skill yöntemi, MIT atıflı).
- **Global (zaten kurulu):** superpowers (TDD, planlama, debugging, verification), planning-with-files, impeccable, ui-ux-pro-max, plugin87 tasarım skill'leri (design-doctrine, a11y-audit, design-review, design-tokens …), context-engineering, Trail of Bits çekirdek seti.
- Hangi repodan neyin alındığı ve neyin neden alınmadığı: `docs/VENDOR_INTEGRATION.md`.

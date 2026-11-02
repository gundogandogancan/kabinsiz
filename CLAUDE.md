# Kabinsiz — Claude Code proje talimatı

**Ürün adı:** Kabinsiz. Anayasadaki iç kod adı `WEARFORM` ile aynı ürün. Kodda, dokümanda ve UI'da ürün adı olarak **Kabinsiz** kullan. Anayasa §0'a göre marka/alan adı/tescil araştırması yapılmadan kamuya açık marka ilanı yok (`BLOCKED_EXTERNAL`).

## Bağlayıcı kaynak

- **Kanonik:** `docs/constitution/WEARFORM_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v1.3.md`. Bu dosya §§0–74'ü kapsar (taban + v1.1 + v1.2 Travel + v1.3 Fit Passport / Shopping Copilot / Trust).
- **Okuma sırası (anayasa emri):** §0 → §§59–74 → §§23–38 → §§39–58 → §§1–22.
- `docs/constitution/archive/` sadece geçmiş içindir. Çatışmada v1.3 kazanır (yalnız kendi kapsamında).
- Karar hiyerarşisi: güvenlik/hukuk/platform → kullanıcının açık kararları → anayasanın değişmez ilkeleri → teknik varsayımlar → ADR.

## Çalışma kuralları (özet; ayrıntı anayasada)

- Platform iPhone-first, offline-first, on-device. Android ayrı kapıdan sonra.
- Her iş paketi şu döngüden geçer: `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → TEST → PERF/PRIVACY → BAĞIMSIZ REVIEW → EVIDENCE → GATE`.
- ID'ler: `REQ-*`, `EV-*`, `T-*`, `ADR-*`. Kararlar `docs/DECISION_REGISTER.md` dosyasında tutulur.
- **Sahte bitmişlik yok.** Mock, sentetik ve engelli olanları raporda ayrı yaz; bilinmiyorsa `UNKNOWN` de.
- İnsan onayı gerektirenler: ücretli harcama, dış hesap, gerçek kullanıcı verisi, sözleşme, marka tescili, canlı ödeme, App Store/TestFlight yayını, kamuya gönderim.
- `STOP_THE_LINE` koşulları: mahremiyet sızıntısı, yanıltıcı beden/uyum iddiası, belirsiz veri hakkı, App Review ihlali, kırık build.
- iOS projesi XcodeGen ile üretilir (`~/.local/bin/xcodegen`). Toolchain: Xcode 26.6. Bu Mac'te brew, gh, docker, uv ve blender yok.
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

- **Projeye özel (`.claude/skills/`):** `swiftui-patterns`, `swift-concurrency-6-2`, `swift-actor-persistence`, `swift-protocol-di-testing`, `ios-icon-gen` (ECC); `spec-to-code-compliance`, `differential-review`, `sharp-edges`, `audit-context-building` (Trail of Bits).
- **Global (zaten kurulu):** superpowers (TDD, planlama, debugging, verification), planning-with-files, impeccable, ui-ux-pro-max, plugin87 tasarım skill'leri (design-doctrine, a11y-audit, design-review, design-tokens …), context-engineering, Trail of Bits çekirdek seti.
- Hangi repodan neyin alındığı ve neyin neden alınmadığı: `docs/VENDOR_INTEGRATION.md`.

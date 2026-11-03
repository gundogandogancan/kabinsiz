# Kabinsiz — Claude Code proje talimatı

**Ürün adı:** Kabinsiz. Anayasadaki iç kod adı `WEARFORM` ile aynı ürün. Kodda, dokümanda ve UI'da ürün adı olarak **Kabinsiz** kullan. Anayasa §0'a göre marka/alan adı/tescil araştırması yapılmadan kamuya açık marka ilanı yok (`BLOCKED_EXTERNAL`).

## Bağlayıcı kaynak

- **Kanonik:** `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.8.md` (v2.7 birleşik ana + v2.8 Figma/sabah-hazır bölümü; önce PART I v2.8'i oku). Ekler `docs/constitution/addenda/` (v1.6..v2.8; v2.6 Tara ve Dene, v2.7 True 3D Digital Twin, v2.8 Figma All Screens & Morning Ready), başlangıç komutları `docs/constitution/commands/` (son: `CLAUDE_START_HERE_v2.8.md`), eski ana dosyalar (v2.1, v2.4, v2.5, v2.6, v2.7) `docs/constitution/archive/`. Figma token taslağı `docs/design/figma/`. Live Mirror atlası `docs/design/LIVE_MIRROR_SCREEN_ATLAS.md`.
- **Okuma sırası (v2.8 emri):** v2.8 komutu → v2.8 eki (§02 IA, §05 sabah hazır, §06 sahne kuralları, §11 WP, §12 testler) → v2.7 eki (dijital ikiz, foto→dolap, Blender giysi) → v2.6 eki (Tara ve Dene, Decart kapalı) → gerektikçe eski bölümler.
- **Öncelik:** hukuk/KVKK/platform → kullanıcı rızası ve yerel-öncelikli mahremiyet → güvenlik/kanıt ve v1.9 fail-closed → **kullanıcının açık kararları** (ör. 2026-11-03 marka panosu/ikon, "Figma'yı sonra bağlayacağız") → v2.8 → v2.7 → v2.6 → v2.5 → v2.4 → … → kanıtlı repo durumu → eski ADR. Daha sıkı güvenlik kuralı her zaman kazanır; çatışma ADR ile çözülür (son: `docs/adr/ADR-014-product-intake-barcode-photo.md`; ADR-012 3B şehir, ADR-013 dünya caddeleri). Bulut VTON (Decart dahil) asla varsayılan değil: açık rıza + sözleşme/DPA + maliyet sınırı + gerçek iPhone testi olmadan kapalı (`BLOCKED_EXTERNAL`). Figma: View koltuğu → `BLOCKED_EXTERNAL_FIGMA`; Figma dosyası varmış gibi yazma.
- **Sıradaki iş:** `docs/audit/V28_REALITY.md` (V25_REALITY'nin devamı). Kod `v25/living-world` branch'inde; main'e kullanıcı onayı olmadan birleşmez.
- `docs/constitution/archive/` sadece geçmiş içindir. Çatışmada v2.8 öncelik zinciri geçerlidir.
- Araştırma: `docs/research/VTON_LANDSCAPE_2026-11.md` (VTON/avatar modelleri ve lisans hükümleri: NC lisanslılar ve SMPL/SMPL-X ticari kullanılamaz).
- Karar hiyerarşisi: güvenlik/hukuk/platform → kullanıcının açık kararları → anayasanın değişmez ilkeleri → teknik varsayımlar → ADR.

## Çalışma kuralları (özet; ayrıntı anayasada)

- Platform iPhone-first, offline-first, on-device. Android ayrı kapıdan sonra.
- Her iş paketi şu döngüden geçer: `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → TEST → PERF/PRIVACY → BAĞIMSIZ REVIEW → EVIDENCE → GATE`.
- ID'ler: `REQ-*`, `EV-*`, `T-*`, `ADR-*`. Kararlar `docs/DECISION_REGISTER.md` dosyasında tutulur.
- **Sahte bitmişlik yok.** Mock, sentetik ve engelli olanları raporda ayrı yaz; bilinmiyorsa `UNKNOWN` de.
- İnsan onayı gerektirenler: ücretli harcama, dış hesap, gerçek kullanıcı verisi, sözleşme, marka tescili, canlı ödeme, App Store/TestFlight yayını, kamuya gönderim.
- `STOP_THE_LINE` koşulları: mahremiyet sızıntısı, yanıltıcı beden/uyum iddiası, belirsiz veri hakkı, App Review ihlali, kırık build.
- iOS projesi XcodeGen ile üretilir (`~/.local/bin/xcodegen`). Toolchain: Xcode 26.6. Bu Mac'te brew, docker ve uv yok; `gh` `~/.local/bin/gh`, Blender 5.2.3 `~/Applications/Blender.app` (PATH'te değil).
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

- **Projeye özel (`.claude/skills/`):** `design-motion-principles` (MIT, kylezantos; hareket/etkileşim: mobil = incelikli cila önce, sık işlem animasyonsuz, Hareketi Azalt'a uy), `swiftui-patterns`, `swift-concurrency-6-2`, `swift-actor-persistence`, `swift-protocol-di-testing`, `ios-icon-gen` (ECC); `spec-to-code-compliance`, `differential-review`, `sharp-edges`, `audit-context-building` (Trail of Bits).
- **Global (zaten kurulu):** superpowers (TDD, planlama, debugging, verification), planning-with-files, impeccable, ui-ux-pro-max, plugin87 tasarım skill'leri (design-doctrine, a11y-audit, design-review, design-tokens …), context-engineering, Trail of Bits çekirdek seti.
- Hangi repodan neyin alındığı ve neyin neden alınmadığı: `docs/VENDOR_INTEGRATION.md`.

# Kabinsiz — Claude Code proje talimatı

**Ürün adı:** Kabinsiz. Anayasadaki iç kod adı `WEARFORM` ile aynı ürün. Kodda, dokümanda ve UI'da ürün adı olarak **Kabinsiz** kullan. Anayasa §0'a göre marka/alan adı/tescil araştırması yapılmadan kamuya açık marka ilanı yok (`BLOCKED_EXTERNAL`).

## Bağlayıcı kaynak

- **Kanonik:** `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md` = v1.5 + v1.6..v2.1 ekleri; yalnız başlık/ayraç satırları farklı (difflib, 2026-11-03; ayrıntı `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md` §1). Ekler ayrıca `docs/constitution/addenda/`; v1.5 ve öncesi `docs/constitution/archive/`. v1.6 ana metni hiç yok (yalnız ek).
- **Okuma sırası (v2.1 emri):** LM21-00, -01, -06, -07, -14, -16 → v2.0 güvenlik/avatar/ürün doğruluğu/Quiet Atelier → V19-00, V19-20, V19-22 → V18-00..son → v1.7 BÖLÜM C → v1.6 BÖLÜM B → v1.5 BÖLÜM A gerektikçe (önce §§101–135).
- **Öncelik:** hukuk/KVKK/platform → kullanıcı rızası ve yerel-öncelikli mahremiyet → güvenlik/kanıt ve v1.9 fail-closed → v2.1 LM21 (yalnız canlı ayna konularında) → v2.0 UI → v1.8 → v1.7 → v1.6 → v1.5 → kanıtlı repo durumu → eski ADR. Daha sıkı güvenlik kuralı her zaman kazanır; daha zayıf yeni kural eski güvenlik kontrolünü geçersiz kılamaz; çatışma ADR ile çözülür. Bulut VTON asla varsayılan değil: açık rıza + sağlayıcı sözleşmesi/DPA + maliyet sınırı + gerçek iPhone testi olmadan kapalı (`BLOCKED_EXTERNAL`).
- **Sıradaki iş:** `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md` (V15 haritasının yerini aldı).
- `docs/constitution/archive/` sadece geçmiş içindir. Çatışmada v2.1 öncelik zinciri geçerlidir.
- Araştırma: `docs/research/VTON_LANDSCAPE_2026-11.md` (VTON/avatar modelleri ve lisans hükümleri: NC lisanslılar ve SMPL/SMPL-X ticari kullanılamaz).
- Karar hiyerarşisi: güvenlik/hukuk/platform → kullanıcının açık kararları → anayasanın değişmez ilkeleri → teknik varsayımlar → ADR.

## Çalışma kuralları (özet; ayrıntı anayasada)

- Platform iPhone-first, offline-first, on-device. Android ayrı kapıdan sonra.
- Her iş paketi şu döngüden geçer: `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → TEST → PERF/PRIVACY → BAĞIMSIZ REVIEW → EVIDENCE → GATE`.
- ID'ler: `REQ-*`, `EV-*`, `T-*`, `ADR-*`. Kararlar `docs/DECISION_REGISTER.md` dosyasında tutulur.
- **Sahte bitmişlik yok.** Mock, sentetik ve engelli olanları raporda ayrı yaz; bilinmiyorsa `UNKNOWN` de.
- İnsan onayı gerektirenler: ücretli harcama, dış hesap, gerçek kullanıcı verisi, sözleşme, marka tescili, canlı ödeme, App Store/TestFlight yayını, kamuya gönderim.
- `STOP_THE_LINE` koşulları: mahremiyet sızıntısı, yanıltıcı beden/uyum iddiası, belirsiz veri hakkı, App Review ihlali, kırık build.
- iOS projesi XcodeGen ile üretilir (`/opt/homebrew/bin/xcodegen`). Toolchain: Xcode 27.2. Homebrew `/opt/homebrew`'da. 2026-11-05 kontrolünde `uv`, `gh` ve Blender bulunamadı.
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

- **Projeye özel (`.claude/skills/`):** otomatik yüklenir. Hareket kararlarında `design-motion-principles`: mobilde önce incelikli cila, sık işlemde animasyon yok, Hareketi Azalt'a uy.
- **Global skill'ler** (superpowers, impeccable, ui-ux-pro-max, plugin87 …) her makinede kurulu olmayabilir; yoksa varmış gibi davranma.
- Hangi repodan neyin alındığı ve neyin neden alınmadığı: `docs/VENDOR_INTEGRATION.md`.

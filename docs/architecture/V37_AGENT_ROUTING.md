# V37 ajan ve skill yönlendirmesi (V37-09)

- **Tarih:** 2026-11-05.
- **Kaynak:** kullanıcının "skill atama, agent sistemi oluşturma" isteği. Program: `docs/audit/V37_SELF_MODEL_PROGRAM.md`.
- **Kurallar:**
  - Ajanlar ayrı süreç değildir; ayrı inceleme bakış açısıdır (CLAUDE.md, anayasa §17).
  - Bir ajan kendi yazdığı güvenlik ya da beden kodunu nihai olarak onaylayamaz. "Uygulayıcı" ve "denetçi" sütunları bu yüzden ayrıdır.
  - Ajan kartları: `.claude/agents/`. Skill'ler: `.claude/skills/`.

## Yeni kartlar (V37-09)

| Kart | Anayasa rolü | Ne yapar | Kim denetler |
|---|---|---|---|
| `avatar-face-hair-engineer` | AG-04 (+AG-09 onayı) | Fotoğraftan ten, saç ve baş oranı okur. Kimlik tanımaz. | `private-biometric-redteam`, `engineering-privacy-engineer` |
| `garment-pattern-engineer` | AG-04 | Düz giysi ölçümü, temel kalıp, SVG ve 3B giysi ağı | `apparel-cad-metrology-engineer`, `fit-science-reviewer` |
| `ondevice-vision-engineer` | AG-05 | Apple Vision ile maske, poz, etiket ve yazılı logo okuma | `specialized-model-qa`, `testing-reality-checker` |
| `fit-science-reviewer` | **AG-06** | Beden ve uyum iddialarını denetler. Yalnız okur, kod yazmaz. | `testing-reality-checker` |

Dört kartta ortak yasaklar:
- kimlik tanıma;
- rakip uygulamaların ve tescilli modellerin tersine mühendisliği;
- yüz verisi için bulut.

Mevcut v3.5 kartlarıyla örtüşme bilinçlidir:
- `face-and-hair-avatar-engineer` → `avatar-face-hair-engineer`
- `apparel-cad-metrology-engineer` → `garment-pattern-engineer`
- `ondevice-mirror-inference-engineer` → `ondevice-vision-engineer`

Eski kartlar denetçi bakış açısıdır, yeni kartlar V37 uygulayıcısıdır. Çatışmada daha sıkı kural kazanır.

Hâlâ kartı olmayan roller:
- AG-07 Styling;
- AG-11 Perf/SRE.

Bu roller aşağıdaki tablolarda en yakın kartla eşlenmiştir. Kartları ayrı bir iş olarak yazılmalıdır (`UNKNOWN` sahiplik riski).

## V37 iş paketleri

| Paket | Konu | Uygulayıcı | Denetçi | Skill'ler | Durum notu |
|---|---|---|---|---|---|
| V37-01 | `SelfModel` okuyucuları: yüz görünüşü, beden oranı, üstteki giysiler, `selfModelGraph` | `avatar-face-hair-engineer`, `ondevice-vision-engineer` | `private-biometric-redteam`, `fit-science-reviewer`, `specialized-model-qa` | `private-avatar-face-hair`, `local-wardrobe-photo-ai`, `swift-concurrency-6-2`, `swift-protocol-di-testing` | Başka ajanlar yazıyor |
| V37-02 | `BrandMarkReader`: yazılı logo, yalnız katalogdaki markalar | `ondevice-vision-engineer` | `retail-catalog-rights-engineer`, `support-legal-compliance-checker` | `barcode-visual-identity`, `catalog-partner-sync` | Resimli logo `UNKNOWN` |
| V37-03 | `FlatGarmentMeasurer`: A4 referansıyla ebat ölçme | `garment-pattern-engineer`, `ondevice-vision-engineer` | `apparel-cad-metrology-engineer`, `fit-science-reviewer` | `garment-cad-pattern-fidelity`, `local-wardrobe-photo-ai` | Başka ajan yazıyor |
| V37-04 | `PatternDrafter`: beden + bolluktan blok, SVG, 3B ağ | `garment-pattern-engineer` | `apparel-cad-metrology-engineer`, `fit-science-reviewer` | `garment-cad-pattern-fidelity` | Başka ajan yazıyor |
| V37-05 | iOS akışı: fotoğraf → öneri → satır satır onay → 3B figür | `engineering-mobile-app-builder`, `avatar-face-hair-engineer` | `design-ui-finish-gate-reviewer`, `testing-accessibility-auditor`, `private-biometric-redteam` | `swiftui-patterns`, `minimal-figma-swiftui-gate`, `design-motion-principles`, `local-live-mirror-engine` | ADR-016: model yalnız elle döner |
| V37-06 | `PartnerFeedConnector`: imzalı, izinli, lisanslı ortak kataloğu | `retail-catalog-rights-engineer`, `security-appsec-engineer` | `security-architect`, `data-privacy-officer`, `support-legal-compliance-checker` | `catalog-partner-sync`, `sharp-edges`, `swift-protocol-di-testing` | Kod + 12 test. Ortak yok → `BLOCKED_EXTERNAL` |
| V37-07 | `kabinsiz-mcp`: yerel stdio MCP sunucusu | `ondevice-vision-engineer` (araç tablosu), `security-appsec-engineer` (yol koruması) | `security-ai-generated-code-auditor` | `sharp-edges`, `differential-review`, `swift-concurrency-6-2` | `.mcp.json` → `kabinsiz` |
| V37-08 | `tools/repo-gate`: lisans, gizli anahtar, kurulum listesi, ağsız kum havuzu | `security-architect`, `generative-vton-benchmark-lead` (kullanıcı) | `security-ai-generated-code-auditor`, `support-legal-compliance-checker` | `generative-vton-research-gate`, `audit-context-building`, `sharp-edges` | `sandbox-exec` deprecated riski |
| V37-09 | Ajan kartları ve bu yönlendirme | `product-manager` | `independent-proof-controller`, `testing-reality-checker` | `spec-to-code-compliance` | Bu belge |
| Kanıt | `docs/evidence/V37-*.yaml` | `independent-proof-controller` | `testing-reality-checker` | `spec-to-code-compliance`, `differential-review` | Her paket ayrı commit |

## Octopus modülleri (OCT-01…24)

Modül kimlikleri `Packages/KabinsizCore/Sources/SystemContracts/Vocabulary.swift` dosyasındaki `ModuleID` listesinden gelir. "Kayıtlı" bilgisi `ModuleRegistry.p0Descriptors` listesinden gelir. Kayıtsız modül, registry tarafından her yetki için reddedilir.

| ID | Modül | Kayıtlı (sahip) | Uygulayıcı kart(lar) | Denetçi | Skill'ler |
|---|---|---|---|---|---|
| OCT-01 | `intentInterpreter` | Hayır | `product-manager`, `design-ux-architect` | `testing-reality-checker` | `spec-to-code-compliance` |
| OCT-02 | `consentGuardian` | Evet (AG-09) | `engineering-privacy-engineer` | `data-privacy-officer` | `sharp-edges`, `swift-actor-persistence` |
| OCT-03 | `deviceGovernor` | Hayır | `ondevice-mirror-inference-engineer` (AG-11 kartı yok) | `engineering-mobile-release-engineer` | `swift-concurrency-6-2` |
| OCT-04 | `photoIntake` | Hayır | `ondevice-vision-engineer` | `engineering-privacy-engineer` | `local-wardrobe-photo-ai` |
| OCT-05 | `garmentVision` | Evet (AG-05) | `ondevice-vision-engineer` | `specialized-model-qa` | `local-wardrobe-photo-ai` |
| OCT-06 | `bodyLandmarkLab` | Hayır | `ondevice-vision-engineer`, `avatar-face-hair-engineer` | `fit-science-reviewer`, `private-biometric-redteam` | `private-avatar-face-hair` |
| OCT-07 | `bodyGeometry` | Evet (AG-04) | `visionos-spatial-engineer`, `garment-pattern-engineer` | `fit-science-reviewer` | `garment-cad-pattern-fidelity` |
| OCT-08 | `avatarRenderer` | Evet (AG-04) | `visionos-spatial-engineer`, `avatar-face-hair-engineer` | `ondevice-mirror-inference-engineer`, `private-biometric-redteam` | `local-live-mirror-engine`, `private-avatar-face-hair` |
| OCT-09 | `productIdentifier` | Evet (AG-08) | `retail-catalog-rights-engineer`, `ondevice-vision-engineer` | `testing-reality-checker` | `barcode-visual-identity` |
| OCT-10 | `brandDataResolver` | Hayır | `retail-catalog-rights-engineer` | `support-legal-compliance-checker` | `catalog-partner-sync` |
| OCT-11 | `materialAnalyst` | Hayır | `garment-pattern-engineer` | `apparel-cad-metrology-engineer` | `garment-cad-pattern-fidelity`, `weather-material-stage` |
| OCT-12 | `fitSpecialist` | Evet (AG-06) | `apparel-cad-metrology-engineer` | **`fit-science-reviewer`** | `garment-cad-pattern-fidelity` |
| OCT-13 | `visualTryOn` | Hayır | `generative-vton-benchmark-lead`, `ondevice-mirror-inference-engineer` | `private-biometric-redteam`, `support-legal-compliance-checker` | `generative-vton-research-gate`, `local-live-mirror-engine` |
| OCT-14 | `styleDirector` | Evet (AG-07) | `product-manager` (AG-07 kartı yok) | `design-ux-researcher` | `kabinsiz-rival-recon` |
| OCT-15 | `colorCoordinator` | Hayır | `design-ui-designer` (AG-07 kartı yok) | `design-brand-guardian` | `minimal-figma-swiftui-gate` |
| OCT-16 | `weatherContext` | Evet (AG-11) | `engineering-mobile-app-builder` | `security-architect` (egress EG-001) | `weather-material-stage` |
| OCT-17 | `occasionVenue` | Evet (AG-02) | `city-world-architect` | `geo-data-license-reviewer` | `city-scene-geo-pipeline` |
| OCT-18 | `wardrobeSteward` | Evet (AG-07) | `engineering-mobile-app-builder` | `testing-reality-checker` | `swift-actor-persistence` |
| OCT-19 | `capsuleTravelPlanner` | Evet (AG-07) | `engineering-mobile-app-builder`, `product-manager` | `testing-reality-checker` | `swift-protocol-di-testing` |
| OCT-20 | `fitMemoryLearner` | Evet (AG-06) | `engineering-mobile-app-builder` | **`fit-science-reviewer`**, `data-privacy-officer` | `swift-actor-persistence` |
| OCT-21 | `knowledgeProvenance` | Hayır | `independent-proof-controller`, `retail-catalog-rights-engineer` | `testing-reality-checker` | `spec-to-code-compliance` |
| OCT-22 | `explanation` | Hayır | `design-ux-architect` | `fit-science-reviewer` (uyum dili) | `design-motion-principles` |
| OCT-23 | `retailPrivacyGateway` | Evet (AG-09) | `security-architect`, `retail-catalog-rights-engineer` | `engineering-privacy-engineer` | `sharp-edges`, `catalog-partner-sync` |
| OCT-24 | `healthIntegrityWatch` | Evet (AG-11) | `engineering-mobile-release-engineer` (AG-11 kartı yok) | `engineering-privacy-engineer` | `audit-context-building` |

OCT-23 notu (V37-06): `PartnerFeedConnector.authorizeFetch` kancası, uygulamada OCT-23'ün `network.productOnly` tek kullanımlık grant'ini tüketmek için tasarlandı. EG-004 rotası bir ortak sözleşmesi imzalanana kadar kayıtlı değildir (`docs/security/EGRESS_REGISTER.md`).

## Geliştirici araçları

- **MCP sunucusu `kabinsiz`** (`.mcp.json`): analizörleri yukarıdaki ajanlara araç olarak açar. Hangi ajanın hangi aracı kullandığı:

  | Araç | Ajan(lar) |
  |---|---|
  | `analyze_garment_photo` | `ondevice-vision-engineer`, `garment-pattern-engineer` |
  | `read_product_label` | `ondevice-vision-engineer`, `retail-catalog-rights-engineer` |
  | `body_profile_defaults` | `fit-science-reviewer`, `avatar-face-hair-engineer` |
  | `measure_flat_garment` | `garment-pattern-engineer`, `fit-science-reviewer` |
  | `analyze_person_photo` | `avatar-face-hair-engineer`, `ondevice-vision-engineer`, `fit-science-reviewer` (yüz kırpımı ya da yüz kutusu döndürmez) |
  | `draft_pattern_svg` | `garment-pattern-engineer`, `apparel-cad-metrology-engineer` |

  Araçlara yalnız fikstür verilir, gerçek kişi fotoğrafı verilmez.
- **Repo kapısı** (`tools/repo-gate`): `generative-vton-benchmark-lead` ve `generative-vton-research-gate` skill'i, dış repoyu yalnız bu kapıdan geçirerek çalıştırır.

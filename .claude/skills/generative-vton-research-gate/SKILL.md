---
name: generative-vton-research-gate
description: Kendi generative VTON R&D test yatağı
---

# generative-vton-research-gate

## Ne zaman çalışır?
Kendi generative VTON R&D test yatağı. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
FASHN VTON 1.5 source+parser license audit; GPU PoC; temporal consistency/identity/logo benchmark; quantize CoreML feasibility; options matrix.

## Kabul kanıtı
Licenses independently verified + GPU benchmark + risk register; no production switch until passed.

## Yasak / güvenlik
NC models commercial app içine girmez; rakibin gizli modelini kopyalamaya çalışma.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

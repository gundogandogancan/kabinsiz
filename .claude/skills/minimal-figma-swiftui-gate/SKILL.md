---
name: minimal-figma-swiftui-gate
description: Jobs/Woz tasarım sistemi ve Figma-SwiftUI ekran uyumu
---

# minimal-figma-swiftui-gate

## Ne zaman çalışır?
Jobs/Woz tasarım sistemi ve Figma-SwiftUI ekran uyumu. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
Single source AtelierTokens, SF Pro/New York, Figma frames, minimal 3-tab nav, scene-first hero, tap-to-change; screenshot compare, accessibility.

## Kabul kanıtı
Figma editable frame+SwiftUI screenshot diff 3 devices dynamic text/contrast and touch targets.

## Yasak / güvenlik
5 sekme, floating button duvarı, kullanıcı modelini kapatan CTA ve sahte 3D UI yok.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

---
name: local-live-mirror-engine
description: Cihaz içinde canlı 3D giysi önizlemesi
---

# local-live-mirror-engine

## Ne zaman çalışır?
Cihaz içinde canlı 3D giysi önizlemesi. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
AVFoundation permission; Vision pose/masks; RealityKit/Metal garment rig/occlusion; MirrorSession CITADEL; thermal, background, latency, consent.

## Kabul kanıtı
Physical iPhone camera screen recording with actual body/arms/turn and FPS/heat/privacy evidence.

## Yasak / güvenlik
Overlay fiziksel fit kanıtı değildir; buluta otomatik upload yok.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

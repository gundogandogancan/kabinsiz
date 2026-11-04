---
name: garment-cad-pattern-fidelity
description: Kumaş/kalıp verisiyle gerçek ürün 3D ikizi
---

# garment-cad-pattern-fidelity

## Ne zaman çalışır?
Kumaş/kalıp verisiyle gerçek ürün 3D ikizi. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
Brand licensed CAD, techpack/measurements and material evidence; target avatar rig, cloth simulation approximations; stitching/logo, size-specific validation.

## Kabul kanıtı
Licensed one garment model across 3 sizes, physical try-on blind comparison, mesh/texture QC.

## Yasak / güvenlik
Tek fotoğraftan gerçek kumaş yüzdesi, arkadaki dikiş veya bitmiş ölçü uydurma.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

---
name: city-scene-geo-pipeline
description: OSM/coarse-city verisini özgün, lisanslı, optimize 3D sahne manifestlerine dönüştürme
---

# city-scene-geo-pipeline

## Ne zaman çalışır?
OSM/coarse-city verisini özgün, lisanslı, optimize 3D sahne manifestlerine dönüştürme. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
City manifest cityID/latlon-generalized/locale/culture/sceneTier/evidence; GIS+Blender+RealityKit LOD pipeline; ODbL attribution; error/stale checks.

## Kabul kanıtı
Yozgat, Gaziantep, New York pilot scene manifest + attribution screenshot + 2 cihaz FPS/L0-L2 benchmark.

## Yasak / güvenlik
Konumun tam adresi, marka logoları veya partner görsel verisini sahneye sızdırma; gerçek olmayan landmarkı gerçek yer diye sunma.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

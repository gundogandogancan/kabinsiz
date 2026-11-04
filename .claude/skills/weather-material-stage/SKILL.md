---
name: weather-material-stage
description: Hava ve gün ışığını fiziksel sahneye bağlama
---

# weather-material-stage

## Ne zaman çalışır?
Hava ve gün ışığını fiziksel sahneye bağlama. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
WeatherKit provider permission+TTL; sun/cloud/rain/snow/wind/night material variants; water droplet-on-ground collisions, PBR roughness; thermal/Reduce Motion fallback.

## Kabul kanıtı
5 hava × 3 şehir golden + offline/denied case + device thermal test.

## Yasak / güvenlik
Bakım etiketi 30°C ile hava durumu karışmaz; uydurma hava sayısı gösterme.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

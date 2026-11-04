---
name: catalog-partner-sync
description: Markaların izinli kataloglarını sürekli güncelleme
---

# catalog-partner-sync

## Ne zaman çalışır?
Markaların izinli kataloglarını sürekli güncelleme. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
PIM feed/webhook/Shopify/Woo read-only; GTIN+SKU+color+size; rights TTL; delta/ETag; signed manifest; conflict quarantine; timestamp.

## Kabul kanıtı
Partner demo 50 variations with add/edit/delete rights revoke; no false exact match.

## Yasak / güvenlik
Gizli scraping/bot yasağı aşma/partner izni olmadan ürün resmi yeniden dağıtma yok.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

---
name: barcode-visual-identity
description: Barkod ve görsel ürün kimliği çözme
---

# barcode-visual-identity

## Ne zaman çalışır?
Barkod ve görsel ürün kimliği çözme. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
VisionKit barcode text/OCR; GTIN normalization; offline cache lookup; read-only partner catalog; multi candidate score; revision/rights checks.

## Kabul kanıtı
Exact verified vs ambiguous/not found; wrong color/size adversarial; p95 device latency.

## Yasak / güvenlik
Bir fotoğraf benziyor diye gerçek ürün/beden eşleştirmesi yapma.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

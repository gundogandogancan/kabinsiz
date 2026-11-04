---
name: local-wardrobe-photo-ai
description: Cihaz içi fotoğraftan otomatik dolap
---

# local-wardrobe-photo-ai

## Ne zaman çalışır?
Cihaz içi fotoğraftan otomatik dolap. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
PhotosPicker+limited PhotoKit; Vision segmentation; CoreML categorical hints/OCR/duplicate clustering; review and local encrypted vault; offline fallback.

## Kabul kanıtı
No permission, limited, 100+ images, duplicates, face mixup, interrupt/resume, data deletion.

## Yasak / güvenlik
Tam galeri izinsiz tarama yok; fotoğraftan marka/kumaş hakkında kesinlik yok.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

---
name: private-avatar-face-hair
description: Kişiye benzeyen yüz ve saç için private local avatar pipeline
---

# private-avatar-face-hair

## Ne zaman çalışır?
Kişiye benzeyen yüz ve saç için private local avatar pipeline. Yalnız ilgili work package aktifken devreye gir. Bu skill doğrudan uygulama runtime modeli değildir.

## Girdi ve uygulama
User-selected selfie/multi-view opt-in; ARKit support gate; morphable facial topology, original hair mesh, skin/hair material; BodyProfile revision/QA; privacy by default.

## Kabul kanıtı
User confirmed lookalike score, front/side/back screenshot, network trace zero face bytes.

## Yasak / güvenlik
İzinsiz galeri tarama yok, rastgele yüzü kullanıcı diye atama yok, ARKit face anchor kimlik modeli sayılmaz.

## Repo sözleşmesi
Mevcut `OctopusCoordinator`, `CitadelGate`, `Vault`, `DomainSchemas`, `AtelierTokens` kullanılabilir temeldir; kopyasını üretme. Gerçek SHA, kaynak dosya/satır, test/exit-code ve fiziksel cihaz kanıtını `docs/evidence/` altında tut. Eksikse `BLOCKED` yaz. İzin, lisans ve cihaz bütçesi aşılamaz.

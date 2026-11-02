# ADR-001 — Native iOS + saf Swift çekirdek paketi + XcodeGen

- Durum: KABUL · 2026-11-03 · Anayasa §3.1 (ADR-001/003), §49.1, §72.1

## Karar

- Uygulama: SwiftUI, iOS 26 hedefi, `project.yml`'den XcodeGen ile üretilir. `.xcodeproj` git'e girmez.
- İş mantığı tek SPM paketinde: `Packages/KabinsizCore`. Platform bağımsız modüller (UIKit/SwiftUI yok) olduğu için `swift test` ile macOS'ta hızlı test edilir.
  - `DomainContracts`: ortak tipler (Garment, kategoriler, durum, provenance, evidence tier).
  - `WardrobeDomain`: dolap deposu ve sentetik dolap fixture'ı.
  - `TravelEngine`: tarih/saat dilimi, hava evidence, aday kombin, kapsül optimizer, valiz, plan diff.
  - `FitPassport`: fit gözlemleri, kapsamlı beden hafızası, abstain kuralları.
  - `ShoppingCopilot`: fail-closed ürün çözücü, Shopping Guard, DecisionComposer.
  - `LocalStore`: sürümlü JSON dosya deposu.
- Modüllerin hiçbiri ağ kodu içermez. Egress testi `URLSession`/`Network` import'unu kaynakta arar (`T-PRIV-EGRESS-STATIC`).

## Gerekçe

Boş repo, tek geliştirici, cihaz yok. Mikroservis/sunucu yok (ADR-003). Saf Swift çekirdek, anayasanın "UI doğrudan SQL/Vision/ağ çağırmasın" kuralını derleyici seviyesinde sağlar. LinguAI projesindeki iki modüllü desen burada da işe yaradı.

## Geri alma

Paket bağımsız. Uygulama hedefi silinse de çekirdek ve testler kalır.

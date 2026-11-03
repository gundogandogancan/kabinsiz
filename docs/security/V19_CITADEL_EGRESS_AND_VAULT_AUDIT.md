# V19 CITADEL egress ve vault denetimi

Tarih: 2026-11-03 · Commit `f5caa71` · V19-21 madde 8 · V19-12, LM21-07
Ayrıntılı tehdit tablosu: `docs/security/THREAT_MODEL.md` (HEAD: T1–T22, R1–R7). Rota tablosu: `docs/security/EGRESS_REGISTER.md`. Anahtar yaşam döngüsü: `docs/security/CRYPTO_KEY_LIFECYCLE.md`. Bu dosya onları tekrar etmez; v1.9/v2.1 sorularına karşı durum ve açık negatif testleri listeler.

Ek v1.6 DATA-01 ve Ek v1.9 V19-01'in "vault yok / egress yalnız beyan" bulguları `77e00ff` içindir ve **kapandı** (WP15-03/04).

## 1. Veri akışları

| Veri | Sınıf | Nerede durur | Dışarı çıkabilir mi | Kanıt |
|---|---|---|---|---|
| Gövde profili (5 parametre, kaynak etiketli) | `LOCAL_SENSITIVE` | Kasa `BODY` | Hayır | `apps/ios/Kabinsiz/App/AppModel.swift:20`; `Octopus/BodyJourney.swift:100`; SEC-08 |
| Avatar önbelleği (siluet) | `LOCAL_SENSITIVE` | Kasa `BODY`, `derivedFrom` gövde | Hayır | `BodyJourneyTests.swift:422` |
| Dolap | `LOCAL_PRIVATE` | Kasa `WARDROBE` | Hayır | `AppModel.swift:17` |
| Fit Passport, rıza defteri | `LOCAL_PRIVATE` | Kasa `PREFERENCES` | Hayır | `AppModel.swift:18,22` |
| Seyahat, plan, valiz | `LOCAL_PRIVATE` | Kasa `TRAVEL` | Yalnız şehir merkezi koordinatı, dokunuşla (EG-001) | `AppModel.swift:21-25`; `StoreAndPrivacyTests.swift:135` |
| Ürün kodu (elle) | `PUBLIC_PRODUCT` | Bellek | Rota yok | `EGRESS_REGISTER.md` Notlar |
| Olay günlüğü | değer yok | Süreç içi, 500 olay | Hayır | `BodyJourneyTests.swift:244` |
| Egress denetim kaydı | yalnız alan adları | Bellek, 200 satır | Hayır | `CitadelGateTests.swift:255` |
| Fotoğraf, kamera, video | — | **Yok** (özellik yok) | — | grep 0 |

## 2. Egress: soru → durum

| Soru | Durum | Kanıt | Açık |
|---|---|---|---|
| Tüm ağ yolları kapıdan mı (V19-Q30) | Statik EVET | `StoreAndPrivacyTests.swift:78-91`; `CitadelGate.swift:39-41,157-200` | Dinamik yakalama `REAL_DEVICE_BLOCKED` |
| Kayıtsız host | Engelli | `CitadelGateTests.swift:111` (SEC-06) | — |
| Sınıfsız / yanlış sınıf DTO | Engelli | `CitadelGateTests.swift:139,154` (SEC-07) | — |
| Ürün isteğine beden sızması | Engelli (tam anahtar + skaler + ≤64 ASCII) | `CitadelGateTests.swift:167,196` (SEC-08) | Değer anlamı denetlenmez (T9) |
| Grant: tek kullanımlık, ≤60 sn, modüle bağlı | EVET | `CitadelGateTests.swift:51-109` | Grant'in dokunuştan geldiği kodla kanıtlanamaz; statik tarama (D-009) |
| Rıza geri alınınca uçuştaki cevap | Atılır | `CitadelGateTests.swift:227` | Gönderilmiş paket geri alınamaz |
| Üçüncü taraf paket / SDK | Yok; eklenirse test kırılır | `CitadelGateTests.swift:124` | — |
| Canlı ayna video egress (LM21-07) | Amaç yok (`EgressIntent.swift:12-13`); ADR-008 açılmasını yasaklıyor (çalışma ağacında) | — | Kamera gelince yerel modda 0 paket testi (LM21-T) |
| Attribution (EG-002) | Kapı dışı, kullanıcı verisi yok | `EGRESS_REGISTER.md` | Sistem ağ envanterinde doğrulanmalı (cihaz) |

## 3. Vault: soru → durum

| Soru | Durum | Kanıt | Açık |
|---|---|---|---|
| Şifreleme (V19-Q31) | AES-256-GCM, KEK→kök→alan DEK | `Vault/VaultModel.swift:160-165` | Kriptograf incelemesi `HUMAN_REVIEW_PENDING` |
| Anahtar yeri | Keychain, `WhenUnlocked` (D-008, şifreli yedekle taşınır) | `Vault/KeyStore.swift:64` | R1: `ThisDeviceOnly` kararı AG-09/kullanıcıda açık |
| Kurcalama / kayıt takası / nonce | Fail-closed | `VaultTests.swift:83-126` (CRY-01..03) | — |
| Rotasyon, çökme | Tutarlı | `VaultTests.swift:145-199` (CRY-04/05) | KEK/kök rotasyonu SPEC_ONLY (R6) |
| Kilitli cihaz | Mantık testi | `VaultTests.swift:184` (CRY-06 logic) | `REAL_DEVICE_BLOCKED` |
| Silme kaskadı, diriltme | Testli | `VaultTests.swift:229,249,271` | R2 eski yedek; R3 monoton sayaç yok |
| Düz metin göçü, rollback | Doğrula-sonra-sil; bozuk dosya korunur | `Vault/LegacyImport.swift:18`; `VaultTests.swift:389` | R5 flash kalıntısı |
| Korumalı özellik | Kasa sınırında red | `Vault/Vault.swift:145`; `VaultTests.swift:314,324` | Değerlere bakmaz (T14); ruh hali/kişilik/kültür/ten kökleri yok |
| Dışa aktarma / kurtarma | Yok | — | CRY-07..09 SPEC_ONLY |

## 4. Açık negatif testler (yazılması gereken)

| ID | Test | Gereken | İş |
|---|---|---|---|
| N-1 | Paket yakalama: tüm sekmeler, rıza kapalı → 0 uygulama paketi | iPhone + `rvictl` | WP15-18 / U-1 |
| N-2 | Kilitli cihazda kasa okunmaz (CRY-06) | iPhone | WP15-18 |
| N-3 | Güç kesintisi sırasında yazma | iPhone | WP15-18 |
| N-4 | Yerel ayna 5 dk → 0 görüntü paketi | Kamera kodu + iPhone | LM21-WP04 |
| N-5 | Mikrofon izni hiç istenmez, ses izi yok | Kamera kodu | LM21-WP04 |
| N-6 | Arka plan / kilit / izin geri alma → kamera izi kapanır | Kamera kodu + iPhone | LM21-WP04 |
| N-7 | `SensitiveAttributeGuard` ruh hali/kişilik/kültür/ten tonu anahtarları | Kod | WP19-09 öncesi |
| N-8 | Upstream düğüm çıktısının politika denetimi | Kod | WP15-18 (`WP15-05.yaml` residual) |
| N-9 | Uzantı / ikinci süreç aynı kasayı açar (T16) | Uzantı yoksa N/A | ileride |

## 5. Tedarik zinciri (V19-12.5)

Üçüncü taraf Swift paketi yok (`Packages/KabinsizCore/Package.swift`: `.package(` 0); ML modeli/ağırlık yok. SBOM ve CI yok → WP19-16. Geliştirici MCP/araç izinleri (V19-12.4) bu repoda denetlenmedi → `UNKNOWN`.

# v1.5 iş sırası ve çatışma haritası (§133 adım 1)

Tarih: 2026-11-03 · Kanonik: `docs/constitution/WEARFORM_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v1.5.md`
Bu dosya plandır, kanıt değildir. Durumlar §74.1 sözlüğüyle.

## 1. Sürüm doğrulaması

| Belge | İçerik | Doğrulama |
|---|---|---|
| v1.4 birleşik | v1.3 (§§0–74) + v1.4 eki (§§75–100) | v1.3'ün 3640/3644 satırı sırayla içinde; farklar yalnız başlık |
| v1.5 birleşik | v1.4 (§§0–100) + v1.5 eki (§§101–135) | v1.4'ün 4525/4528, v1.5 ekinin 1129/1131 satırı içinde; farklar yalnız başlık |

Ayrı ek dosyaları ve v1.4 birleşik `archive/` altında; çalışma için yalnız v1.5 okunur.

## 2. Çatışma haritası (mevcut repo ↔ v1.5)

| # | Çatışma | v1.5 hükmü | Karar |
|---|---|---|---|
| C-1 | Seyahat motoru ve kapsül valiz P0 gibi kodlandı (v1.2/v1.3) | §75.2 ve §122: travel **P1**; P0 çekirdeği gövde/avatar + vault + egress | Mevcut kod silinmez, `TESTED` kalır. Yeni iş v1.5 DAG sırasıyla. Travel'a yeni özellik eklenmez (D-004) |
| C-2 | Yerel depo şifresiz JSON + iOS file protection (ADR-002) | §111/§116: platform destekli kriptolu vault, anahtar yaşam döngüsü | ADR-002 → WP15-04 ile yenilenecek (CryptoKit + Keychain). Göç testi zorunlu |
| C-3 | Egress kontrolü statik kaynak taraması | §112/§117: deny-by-default `EgressIntent` kapısı, çalışma zamanında reddedilen eylem testi | WP15-03 |
| C-4 | Ortak tip sözleşmesi yok (`DomainContracts` kısmi) | §133.3: `DomainEventV1`, `WorkOrder`, `ModuleRegistry`, `EgressIntent`, `EvidenceRecord`, `DeviceBudget`, `DecisionEnvelope`, `FaultCode` | WP15-02 |
| C-5 | Kaynak yöneticisi yok | §113: termal/düşük güç governor + görünür fallback | WP15-06 |
| C-6 | 3D yok (D-003: 2D fallback) | §133.1: ilk kanıt gövde kaydırıcıları + doğru mesh değişimi | WP15-07/08. Blender bu Mac'te yok → parametrik prosedürel mesh ile başla, Blender rig `BLOCKED_TOOL` |
| C-7 | Test klasörleri tek hedefte | §129: `Tests/Unit, Security, Offline, Migration, ...` | Swift Testing tag'leri + klasör ayrımı, yeni testlerde |
| C-8 | Evidence dosya adları v1.3 | §128/§129 klasör yapısı | `docs/system`, `docs/security`, `docs/quality` aşamalı açılır; eski dosyalar taşınmaz, bağlanır |

## 3. Sıra (v1.5 §122 DAG + §133, bu repoya uyarlanmış)

| Sıra | WP | İş | Bağımlılık | Durum | Engel |
|---|---|---|---|---|---|
| 1 | WP15-01 | Reality baseline v1.5 (araç, cihaz, disk, repo) | — | KUYRUKTA | Cihazlar çevrimdışı |
| 2 | WP15-02 | Tip sözleşmeleri + şema göç testleri (C-4) | 1 | KUYRUKTA | — |
| 3 | WP15-03 | Rıza / capability / egress kapısı, fail-closed red testi (C-3) | 2 | KUYRUKTA | — |
| 4 | WP15-04 | Şifreli vault: CryptoKit + Keychain, kurcalama/geri yükleme/silme testleri (C-2) | 2 | KUYRUKTA | Keychain testi için simülatör yeterli; Secure Enclave cihaz ister |
| 5 | WP15-05 | Octopus koordinatör, tek yolculuk: kaydırıcı → gövde revizyonu → önizleme → yerel kayıt | 2,3,4 | KUYRUKTA | — |
| 6 | WP15-06 | Device governor + hata enjeksiyonu (C-5) | 2 | KUYRUKTA | Gerçek termal ölçüm cihaz ister |
| 7 | WP15-07/08 | Nötr gövde mesh + morph kaydırıcıları + RealityKit önizleme + VoiceOver (§133.1 ilk kanıt) | 5,6 | KUYRUKTA | Blender yok (BLOCKED_TOOL); gerçek cihaz yok |
| 8 | WP15-18 | Bağımsız kalite kapısı: güvenlik negatif testleri, perf, a11y | 1–7 | KUYRUKTA | — |
| 9 | WP15-09..14 | Fotoğraf girişi, dolap gerçeği, ürün çözücü, fit sınırı, try-on, stilist — mevcut kodu ortak sözleşmeye bağla | 8 | KUYRUKTA | Lisanslı katalog yok |
| 10 | WP15-15 | Travel (mevcut motor) ortak sözleşme + vault'a taşınır | 9 | CODED/TESTED (v1.2) | P1 |
| — | WP15-16/17/19/20 | Model lab, retail gateway, ticari pilot, Android | — | SPEC_ONLY / BLOCKED | İnsan onayı / dış hesap |

## 4. §133.1 ilk kanıt — ölçüt

Uygulama çevrimdışı açılır, nötr gövde oluşturulur, bel/omuz kaydırıcıları mesh'i doğru değiştirir, yerel kaydedilir, zorla kapat/aç sonrası aynı değerler, profil silinince veri gider; özel veri için ağ reddedilir; iptal çalışır; kaynak fallback'i görünür. Bu repo için hedef: önce `SIMULATOR_ONLY`, cihaz bağlanınca `DEVICE_VERIFIED`.

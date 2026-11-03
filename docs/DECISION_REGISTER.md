# Decision Register

| ID | Karar | Durum | Kaynak |
|---|---|---|---|
| ADR-001 | Native iOS + saf Swift `KabinsizCore` paketi + XcodeGen | KABUL | docs/adr/ADR-001-architecture.md |
| ADR-002 | Sürümlü Codable JSON yerel depo, actor | KABUL (P0) | docs/adr/ADR-002-local-persistence.md |
| ADR-003 | Kapsül optimizer: greedy + yerel onarım + brute-force referans | KABUL | docs/adr/ADR-003-capsule-optimizer.md |
| ADR-004 | Hava/katalog yalnız arayüz + sentetik fixture, fail closed | KABUL | docs/adr/ADR-004-weather-and-catalog-sources.md |
| ADR-005 | Fit Passport kapsamlı kural tablosu, ≥2 gözlem, yüzde yok | KABUL | docs/adr/ADR-005-fit-passport-rules.md |
| ADR-006 | Kanon v2.1 ve öncelik zinciri | KABUL | docs/adr/ADR-006-canon-v2.1.md |
| ADR-007 | Nötr 3D morf avatar P0, özgün prosedürel mesh, 360° manuel; 2D siluet G0 yedeği (D-003 kapandı) | KABUL | docs/adr/ADR-007-neutral-3d-avatar.md |
| ADR-008 | Canlı Ayna iki motor: yerel varsayılan; bulut bayrak OFF + stub, insan kararı + DPA olmadan açılmaz | KABUL / BLOCKED_EXTERNAL (bulut) | docs/adr/ADR-008-two-engine-live-mirror.md |
| D-001 | Ürün adı "Kabinsiz", iç kod adı WEARFORM; kamuya ilan yok | KULLANICI KARARI | 2026-11-03 sohbet |
| D-002 | Kamera/barkod yerine P0'da manuel ürün kodu girişi (§60.3 fallback) | GEÇİCİ | Cihaz yok, kamera simülatörde test edilemez |
| D-003 | 3D önizleme P0 dışı; 2D kart fallback (§44.4) | KAPANDI (ADR-007) | Blender/asset/lisans yok |
| D-004 | (D-014 ile değişti) Kanonik anayasa v1.5. Yeni iş v1.5 §122 DAG sırasıyla; mevcut travel/shopping kodu korunur, yeni travel özelliği P1'e kadar yok | KABUL | Kullanıcı "sıraya koy" 2026-11-03; docs/audit/V15_QUEUE_AND_CONFLICT_MAP.md |
| D-006 | WeatherKit, kullanıcının isteğiyle P1 sırasından öne alındı. İstek yalnız açık dokunuşla, yalnız şehir merkezi koordinatıyla; ilk plan `NO_DATA` | KULLANICI KARARI | 2026-11-03 sohbet; docs/security/EGRESS_REGISTER.md |
| D-007 | Bundle ID `app.kabinsiz.ios`, takım `47XQMQZLF6` (WeatherKit için App ID gerekiyor). Kamuya marka ilanı değildir | KABUL | §0, R-003 |
| D-008 | Vault: Keychain KEK erişimi `kSecAttrAccessibleWhenUnlocked` (şifreli yedekle taşınır, telefon değişiminde veri kaybı yok; §68). Alternatif `…ThisDeviceOnly` daha sıkı ama geri yüklemede veri kaybı. Constitution'daki 3 alana `TRAVEL` alanı eklendi (seyahat ayrı silinebilsin). Dosyalar `completeFileProtection` | KABUL (AG-09 onayı bekliyor) | docs/security/THREAT_MODEL.md R1, CRYPTO_KEY_LIFECYCLE.md |
| D-009 | Hava isteği rızası: varsayılan "her dokunuşta sor yok, dokunuş = rıza"; Profil'deki anahtar kapatılınca (`REVOKED`) dokunuş da çalışmaz. Her dokunuş tek kullanımlık, 60 sn grant üretir | KABUL | docs/security/EGRESS_REGISTER.md |
| D-005 | D-003 gözden geçirilecek: v1.5 §133.1 ilk kanıt gövde kaydırıcıları + 3D mesh istiyor. Kaydırıcı yolculuğu WP15-05'te 2D ile kapandı (D-010); 3D mesh WP15-07/08 | KAPANDI (ADR-007) | v1.5 §122/§133 |
| D-014 | Kanonik anayasa v2.1 (v1.5 + v1.6..v2.1 ekleri). Sıra `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md`; D-004'ün yerini alır. Bulut VTON (Decart/Anywear) bayrağı OFF + yalnız stub, insan kararı + DPA olmadan açılmaz (C-9) | KULLANICI KARARI ("sıraya al") | 2026-11-03 sohbet; V21 haritası §3 |
| D-015 | Hareket tasarımı ilkeleri: `.claude/skills/design-motion-principles` (MIT). Sık işlemler (kaydırıcı sürükleme) animasyonsuz doğrudan manipülasyon; seyrek ayrık geçişler kısa yumuşak morf; Hareketi Azalt açıkken morf yok | KULLANICI İSTEĞİ | 2026-11-03 sohbet |
| D-010 | WP15-05 önizlemesi 2D ön siluettir (G0 yedek katmanı). 3D nötr mesh ve 360° manuel döndürme WP15-07/08'de; o zaman bu siluet 3D çizilemediğinde gösterilen yedek olarak kalır | KABUL | v1.5 §108.3, §133.1; v2.1 kuyruğu C-11 |
| D-011 | Nötr başlangıç değerleri (170/42/95/82/98 cm) bir norm ya da hedef değildir; ekranda böyle yazılır ve `NEUTRAL_START` etiketiyle saklanır. Beden önerisi yalnız `USER_MEASURED` değerleri kullanır | KABUL | §123 A.5, §109 |
| D-012 | Omuz/boy bağı: omuz ≤ 0,45 × boy. Kaydırıcı aralığı buna göre daralır; aksi halde 120 cm boy + 60 cm omuz çizimi boyunda kırıyor (V15-T-BOD-02 buldu). Gerçek oranlar ≈0,23–0,27 | KABUL | `BodyProfile.allowedRange` |
| D-013 | Koordinatör düğüm süreleri (morph 200 ms, render 500 ms, persist 10 s) sert iptal sınırıdır; registry'deki `deadlineMs` (50 / 33 ms) performans hedefidir ve gerçek cihazda ölçülecek (WP15-06/WP15-18) | KABUL | §103, §113 |
| D-016 | Cihaz yöneticisi (WP15-06): kademe eşikleri (pil kritik ≤ %10, düşük ≤ %20; geri yükselme 20 s; bellek uyarısı 60 s sürer; kamera kare tavanı 15/8/2/0) başlangıç hipotezidir, cihazda kalibre edilecek (WP15-18). Değişmeyenler: düşüş anında, yükseliş bekleyerek; P0 (kaydırıcı, kaydet, sil) ön planda her kademede açık ve hiç geri alınmaz; bilinmeyen pil TURBO'yu kapatır ve sayıya çevrilmez; kullanıcı notu derece, yüzde, kare sayısı içermez | KABUL | v1.5 §113, V15-T-DEV-01..10 |
| D-017 | `NWPathMonitor` yalnız `DeviceSignalMonitor.swift` içinde, yalnız erişilebilirlik okumak için kullanılır (OFFLINE kademesi). Bağlantı açan Network API'leri (NWConnection, NWListener, NWBrowser, NWEndpoint) ağ taramasında yasak kalır | KABUL | WP15-03 egress kaydı, T28 |
| D-018 | V21-00 boşluk 1 (STOP_THE_LINE sınıfı): tablo eşleşmesi kullanıcının verdiği ama tablonun listelemediği ölçüyü sessizce "uydu" saymaz. Kart yalnız karşılaştırılan ölçüyü adlandırır ("Göğüs ölçüne göre tabloda M") ve karşılaştırılamayanı söyler ("Bel ölçün bu tabloda yok; karşılaştırılmadı"); hiçbir ölçü karşılaştırılamazsa çekimser kalır; eksik ölçü varken güven `verifiedFacts` olamaz. Kuyrukta 15. sıradaki R17-05'i beklemeden hemen düzeltildi. Aynı marka + kategori "olası" kuralı (ADR-005) bilinçli olarak korunuyor; kart bunun marka düzeyinde olduğunu zaten söylüyor | KABUL | V19_REALITY_AND_GAP_REPORT §boşluk 1, `SizeAdvisor.chartMatch` |
| D-019 | Nötr 3B gövde oranları (WP15-07/08): torso derinliği çevreden Ramanujan ile (ön yarı genişlik = C/5,2 → derinlik/genişlik ≈ 0,64); bacaklar silüetin dış kenarına oturur, bileklerde doğal bir duruş aralığı; kollar ölçüsüz nötr, 8°–30° A-duruşu, dirsekten aşağısı kalçaya girmez (gerekirse kol dışa kayar); baş önden ve yandan çeyrek elips. Silüette uyluk/diz/bilek genişlikleri gerçekçi orana çekildi (2D'de de bacaklar iğne gibi görünmüyordu). Hepsi görünüm hipotezidir; ölçü veya uyum iddiası değildir | KABUL | ADR-007, `BodyMesh`, `Silhouette.make` |
| D-020 | R17-02 şemaları yeni `DomainSchemas` hedefinde, `SystemContracts`'ın aynı `ContractCoder`'ı ile (sürüm kapısı, katı anahtar, doğrulama). Ayrı hedef: `BodyProfileV2` göçü `BodyGeometry`'ye bağlı, `SystemContracts` bağımlılıksız kalmalı. Spec alan adları korundu; eklenenler: `FabricSpecV1.composition_origin` (köken listesinde fotoğraf tahmini yok) ve `visual_appearance_hint`, `RegionalFitV1.recommended_sizes`, `Offer.price_minor` (para kuruş, asla `Double`). `VisualTryOnV1` v1.7 §3.2 merdivenini kullanır (G0 = ürüne özel 3B yok); uygulamanın `2D_CARD` ve `G0_GENERIC` katmanları G0, `G1_PRODUCT_ASSET` G1'e eşlenir. GTIN tek biçimde (GTIN-14) saklanır. Göç: v1'de elle girilen ölçü zaten beden önerisine giriyordu → `APPROVED`; kaydırıcı ve başlangıç değerleri çizimde kalır. Golden'lar sentetik (GS1 mağaza içi 200 öneki, uydurma marka/sahip), `SYNTHETIC_DEMO_ONLY` | KABUL | v1.7 §4, V18-04, `DomainSchemas`, `DomainSchemaTests` |

## Açık riskler

| ID | Risk | Sahip | Durum |
|---|---|---|---|
| R-001 | Disk %97 dolu: build/simulator başarısız olabilir | AG-11 | AÇIK |
| R-002 | Eşleşmiş 3 iPhone var (16 Pro iOS 26.5, 14 Pro Max 26.6, 13 Pro Max 26.2.1; `xcrun devicectl list devices`, 2026-11-03) ama hepsi `unavailable` (bağlı/kilidi açık değil). G-TRV-DEVICE, T-V13-010, WP15-06 termal kalibrasyonu cihaz bağlanınca yapılır | AG-10 | BLOCKED_DEVICE (kullanıcı telefonu bağlayıp açmalı) |
| R-003 | WeatherKit: kod + entitlement hazır; Apple PLA güncellemesi kabul edilmeden App ID/profil oluşmuyor | AG-13 | BLOCKED_EXTERNAL (hesap sahibi kabul etmeli) |
| R-004 | Lisanslı katalog/beden tablosu yok, fit iddiası yapılamaz | AG-08 | BLOCKED_EXTERNAL |
| R-005 | Blender bu Mac'te yoktu | AG-04 | KAPANDI: 5.2.3 LTS kuruldu, SHA-256 + notarizasyon doğrulandı |
| R-006 | Yerel veri şifresiz JSON (v1.5 §111/§116 açığı) | AG-09 | KAPANDI (WP15-04): CryptoKit kasası + düz metin göçü. Kalan riskler THREAT_MODEL R1–R7 |

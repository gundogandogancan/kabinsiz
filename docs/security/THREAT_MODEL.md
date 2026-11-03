# Tehdit modeli: WP15-03 kapısı + WP15-04 şifreli kasa (§110, §111.4, §112, §116)

Durum: `TESTED` (macOS birim testleri + simülatör). Kriptografi uzmanı incelemesi yapılmadı (§111.2 "cryptographer review required"); bu yüzden tasarım `DESIGN_CANDIDATE` olarak kalır.

## Korunan varlıklar

| Varlık | Sınıf | Nerede |
|---|---|---|
| Vücut ölçüleri | `LOCAL_SENSITIVE` | Kasa, `BODY` alanı |
| Dolap | `LOCAL_PRIVATE` | Kasa, `WARDROBE` alanı |
| Fit Passport, rıza defteri | `LOCAL_PRIVATE` | Kasa, `PREFERENCES` alanı |
| Seyahat, plan, bavul | `LOCAL_PRIVATE` | Kasa, `TRAVEL` alanı |
| Seyahat şehrinin merkezi (istek anında) | `LOCAL_PRIVATE` | Yalnız EG-001, dokunuşla |

## Saldırgan ve beklenen koruma

| # | Tehdit | Savunma | Test | Kalan risk |
|---|---|---|---|---|
| T1 | Dosya sistemine erişen biri kayıtları okur (yedek dosyası, adli kopya, kilitli cihaz) | Her kayıt AES-256-GCM ile şifreli; anahtar hiyerarşisi KEK → kök → alan DEK'i; dosyalarda düz metin yok; iOS'ta `completeFileProtection` | "no plaintext anywhere on disk" | Kilidi açık cihazda uygulama veriyi okuyabilir (§111.4) |
| T2 | Kayıt bayt bayt değiştirilir | AEAD etiketi; index ve anahtar kaydı da doğrulanır | V15-T-CRY-01 (iki test) | Yok (fail-closed, veri gösterilmez) |
| T3 | Bir kayıt başka kaydın yerine kopyalanır | AAD = tür, kimlik, şema, alan, sınıf, anahtar, nesil; AAD dosyadan değil mühürlü index'ten kurulur | V15-T-CRY-02 | Yok |
| T4 | Nonce tekrarı | Her mühürde CryptoKit'in rastgele 96 bit nonce'u | V15-T-CRY-03 (300 kayıt + 1000 doğrudan) | Anahtar başına ~2^32 mühür sınırı; P0 hacminin çok altında |
| T5 | Silinmiş kayıt eski kopyadan geri gelir | Mezar taşı (tombstone) + nesil numarası; açılışta index'in göstermediği dosyalar silinir | V15-T-SEC-10 | Kasanın tamamı eski bir yedekten geri yüklenirse eski durum geri gelir (bkz. R1) |
| T6 | Yazma/döndürme sırasında çökme veya güç kaybı | Önce yeni dosyalar, commit noktası index; her yazmadan sonra dosya ve klasör için `F_FULLFSYNC`; açılışta kurtarma; ilk açılışta index önce, `keys.json` en son | V15-T-CRY-05 (3 çökme noktası), `crashedFirstOpen`, `missingIndex` | Güç kaybı davranışı `F_FULLFSYNC` garantisine dayanır; cihazda çekip-çıkarma testi yok |
| T7 | Yanlış veya kaybolmuş KEK | Kasada veri varken yeni anahtar üretilmez; `keyUnavailable` | V15-T-CRY-04, CRY-06 (mantık) | Anahtar kaybında veri geri gelmez; kullanıcı yalnız sıfırlayabilir |
| T8 | Bir modül kendi yetkisi dışında ağ kullanır | `CitadelGate`: registry, rıza ve grant. Ağ grant'i her zaman tek kullanımlıktır ve en fazla 60 sn yaşar | Kapı testleri: yanlış modül, tekrar, süre, `grantLimits` | Grant'in bir dokunuştan geldiğini kod kanıtlayamaz. Bunun yerine statik tarama iki şeyi zorlar: canlı sağlayıcıyı yalnız dokunuş işleyicisi kurar, WeatherKit çağrısı kapının closure'ı içindedir |
| T9 | Özel veri ürün isteğine sızar | Tel üzerindeki alan kontrolü: tam anahtar eşleşmesi, düz skaler değer, ≤64 ASCII | V15-T-SEC-08 | Değer düzeyinde anlam kontrolü yok (ör. geçerli görünen bir sayı) |
| T10 | Sınıflandırılmamış DTO ağa gider | `egressClassification == nil` → `UNKNOWN_CLASSIFICATION` | V15-T-SEC-07 | — |
| T11 | Yeni SDK veya host gizlice eklenir | Kod allowlist'i = kayıt tablosu; üçüncü taraf paket yasak; statik tarama | V15-T-SEC-06 | Dinamik ağ yakalama yok (cihaz gerek) |
| T12 | Katalog metnindeki talimatlar | `UntrustedText`: görünmez ve yön değiştiren karakterler silinir; `Text(verbatim:)` ile gösterilir; metinden yetkiye giden bir API yok | V15-T-SEC-04 | P0'da LLM yok; ileride model eklenirse ayrı test gerekir |
| T13 | Barkoddaki oltalama URL'si | Girdi normalizasyonu URL'yi reddeder; uygulamada `openURL` yasak | V15-T-SEC-05 | — |
| T14 | Hassas özellik çıkarımı (din, etnik köken, sağlık…) | Kasaya yazılmadan önce anahtar adları taranır. Kısa sözcükler yalnız tam token olarak eşleşir; uzun kökler bitişik yazımda da yakalanır (`HEALTHSCORE`, `religion2`) → `POLICY_DENIED` | V15-T-SEC-09 | Değerlere bakmaz (ör. `{"note": "religion: x"}`); bazı zararsız adları da engeller (`healthyDrinks`) |
| T16 | Aynı klasörde iki kasa örneği veya silme sonrası eski örnek | Süreç başına klasör kaydı (`alreadyOpen`); `deleteAll` ve `close` örneği kapatır (`closed`); uygulamada `load` tek seferdir ve kayıt kuyruğunun başında çalışır | `singleInstance`, `deleteEverything` | Başka süreç (ör. ileride bir uzantı) bu kilidi görmez |
| T17 | Rıza kaydı okunamaz veya kasa açılamaz | Hava izni kapalı başlar (fail closed); kullanıcıya hata gösterilir | AppModel `closedLedger` (UI testi yok) | — |
| T15 | Rıza geri alınırken yolda istek | Geri alma epoch'u; dönen cevap atılır | `revokeDuringFlight` | Ağa giden paket geri çağrılamaz |
| T18 | Renderer vücut ölçülerini okur ya da sızdırır | Koordinatör her düğümün `reads` bağlamını registry'ye karşı denetler; OCT-08 yalnız `AvatarSnapshot` görür (ölçü değeri ve kaynak etiketi yok) | V15-T-ORC-09, V15-T-BOD-09 | Snapshot yarı genişlikleri ölçülerden türetilir; tersine çevrilebilir (yaklaşık). Bu yüzden `LOCAL_SENSITIVE` ve kasada |
| T19 | Eski bir yazım yeni gövdenin üzerine yazar | Revizyonlar yalnız artar; depo `revision <= son` ise `staleRevision`; başarısız commit revizyonunu "yakar" | V15-T-ORC-08, `lateWriteDoesNotWedge` | Süreç yeniden başlarsa depo sayacı kayıttan okunur |
| T20 | "Tümünü sil" sonrası kuyruktaki kaydırıcı commit'i yeni kasaya yazar | Silmeden önce stüdyo `close()` ile kapanır; kapalıyken commit reddedilir; silmeden sonra `load()` geçmişi temizler | `closeAndReload` (paket), UI `testVaultSurvivesRelaunchAndDeletes` | Uygulama düzeyinde eşzamanlı sürükleme + silme UI testi yok |
| T21 | Geri al, silinmiş gövde değerlerini geri getirir | Silme ve `load()` geri-al geçmişini sıfırlar; geçmiş diske yazılmaz | `deleteCascades`, `closeAndReload`, UI testi (yeniden başlatmada yinele kapalı) | — |
| T22 | Olay günlüğünden ölçü sızar | `BodyEventPayload` yalnız tür + parametre adı taşır, değer yok; günlük süreç içi, 500 olay sınırlı | `eventsCarryNoValues` | Parametre adı (ör. "bel") hangi ölçünün değiştiğini söyler |
| T23 | Yerel aynada görüntü dışarı çıkar | Yerel modda ağ amacı yok; `CitadelGate` canlı video amacı tanımlamaz (ADR-008) | Statik tarama (WP15-03) + LM21-T ağ koşum testi | Dinamik ağ yakalama gerçek cihaz ister (`REAL_DEVICE_BLOCKED`) |
| T24 | Bulut aynası izinsiz/otomatik açılır | Bayrak OFF, yalnız stub; otomatik mod yükseltme yok; ayrı rıza | LM21-WP11 (kuyrukta) | Bulut modu `BLOCKED_EXTERNAL` |
| T25 | Kamera arka planda / kilitte açık kalır | Stop, arka plan, kilit, izin geri alma → track kapanır (LM21-07.8) | LM21-WP04 (kuyrukta) | Gerçek cihaz |
| T26 | Ayna videosu kaydedilir veya yedeğe gider | Varsayılan kayıt yok; kayıt ikinci eylem + ayrı izin (LM21-07.7) | LM21-WP04/08 (kuyrukta) | — |
| T27 | Telemetride görüntü/beden koordinatı | Yalnız toplulaştırılmış teknik ölçüm; ham görüntü, embed, koordinat yazılmaz (LM21-07.9) | Henüz telemetri yok | — |
| T28 | Ağ yolu izleyicisi veri sızdırır | `NWPathMonitor` yalnız var/yok okur; bağlantı açan Network API'leri ağ taramasında yasak; dosya bazlı istisna (D-017) | `T-TRV-087 / T-V13-057` statik tarama | Statik tarama dinamik yakalamanın yerini tutmaz (`REAL_DEVICE_BLOCKED`) |
| T29 | Kilitliyken kasa işi yarıda kalır ya da düz metin yedeğe düşer | Kilitte yeni P0 reddedilir; gövde yazıları `untilProtectedDataAvailable` ile kilit açılana kadar bekler; geçici dosyalar tam koruma + yedek dışı + açılışta süpürülür | `lockedDefers`, `orphanSweep` | Gerçek dosya koruması yalnız cihazda doğrulanır |
| T30 | Cihaz durumu parmak izi / yanıltıcı sıcaklık iddiası | Kademe nedenleri yalnız kod (değer yok); kullanıcı notunda rakam, derece, yüzde yok; pil izlemesi kapalı | `notes`, `batteryUnknown` | — |
| T31 | 3B mesh vücut ölçülerini geri verir ve dışarı çıkar | Mesh yalnız bellekte, `PreviewScene` içinde; diske/kasaya yazılmaz (kasada yalnız `avatar-cache` = snapshot, LOCAL_SENSITIVE); RealityKit görünümünde paylaşım/dışa aktarma yok; ağ yolu yok | `structuralOnly`, statik ağ taraması | Ekran görüntüsünü kullanıcı kendisi alabilir (OS düzeyi) |
| T32 | Ürün/ticaret verisi gerçekten güçlü görünür: tahmin "tanındı", eski stok "stokta", GS1 kaydı ölçü taşır, kullanıcı OCR'ı marka gerçeği olur, sentetik veri olgu gibi gösterilir | Şema düzeyinde fail-closed: kanonik GTIN; tam eşleşme kanıt + zaman; doğrulanmış kimlik ve stok süreyle düşer; iddia kademesi iddia sahibine kilitli; GS1 yalnız kimlik; olgu gösterimi yalnız A/B + lisans + aktif; sentetik asla olgu | `identityLevels`, `offerRules`, `claimRules`, `graphIntegrity` | Gerçek katalog/lisans yok; kapsam kapısı (R18-WP03, kuyruk 11) henüz yok |
| T33 | Gövde v2 dosyası cihazdan çıkabilir diye işaretlenir ya da göçte kaydırıcı şekli ölçüye dönüşür (yanıltıcı beden) | `local_only` false → `EGRESS_BLOCKED`; sınıf `LOCAL_SENSITIVE`; göç yalnız `USER_MEASURED`'ı ölçü yapar; foto tahmini öneriye girmez; uyum kararı yalnız onaylı elle girilmiş ölçülere dayanır | `bodyRules`, `upgradeKeepsShapesOut`, `fitAgainstBody` | Uygulama henüz v2 yazmıyor |

## Bilinçli kalan riskler

- **R1. KEK cihaz yedeğiyle taşınır.** Erişim sınıfı `kSecAttrAccessibleWhenUnlocked` (D-008). Şifreli bir iCloud/Finder yedeğini ve parolasını ele geçiren biri kasayı açabilir. Bunun karşılığında telefon değişince veri kaybolmaz (§68). Alternatif `…ThisDeviceOnly`: daha güvenli, ama geri yüklemede veri kaybı. Karar kullanıcıya/AG-09'a açık.
- **R2. Anahtarı silmek (crypto-shredding) önceden alınmış yedekleri silmez.** Her silme makbuzu `DEVICE_BACKUPS`, `USER_SHARED_EXPORTS` ve `FLASH_STORAGE_REMNANTS` maddelerini gösterir. Alan silme (`deleteDomain`) DEK'i siler, ama kök anahtar ve KEK aynı kalır. Bu yüzden eski bir `keys.json` kopyası, eski kayıt dosyalarıyla birlikte o alanı yeniden açabilir. Tam silme (`deleteAll`) KEK'i de siler ve bu açığı kapatır.
- **R3. Geri alma (rollback).** Kök anahtar değişmediği için eski bir `index.sealed` ile eski kayıt dosyalarını geri koymak eski tutarlı durumu açmaya yeter. `keys.json`'ı değiştirmeye gerek yoktur. `VaultIndex.sequence` sayılır ama güvenilir bir monoton sayaçla karşılaştırılmaz. Cihaz tarafında böyle bir sayaç yok.
- **R4. Anahtar durum alanları (PENDING/ACTIVE) doğrulanmaz.** Değiştirilirse yalnızca hizmet reddi olur, gizlilik bozulmaz; aktif anahtar işaretçisi mühürlü index'tedir.
- **R5. Düz metin göçünde eski JSON dosyası silinir, ama flash bellekten güvenli silme garanti edilemez.** Bu durum makbuzda yazılıdır.
- **R6. KEK döndürme ve dışa aktarma/kurtarma (CRY-07/08/09) yok.** P1, `SPEC_ONLY`.
- **R7. Secure Enclave kullanılmıyor.** SE simetrik toplu şifreleme yapmaz (§111.1); KEK Keychain'de durur.

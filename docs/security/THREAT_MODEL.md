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

## Bilinçli kalan riskler

- **R1. KEK cihaz yedeğiyle taşınır.** Erişim sınıfı `kSecAttrAccessibleWhenUnlocked` (D-008). Şifreli bir iCloud/Finder yedeğini ve parolasını ele geçiren biri kasayı açabilir. Bunun karşılığında telefon değişince veri kaybolmaz (§68). Alternatif `…ThisDeviceOnly`: daha güvenli, ama geri yüklemede veri kaybı. Karar kullanıcıya/AG-09'a açık.
- **R2. Anahtarı silmek (crypto-shredding) önceden alınmış yedekleri silmez.** Her silme makbuzu `DEVICE_BACKUPS`, `USER_SHARED_EXPORTS` ve `FLASH_STORAGE_REMNANTS` maddelerini gösterir. Alan silme (`deleteDomain`) DEK'i siler, ama kök anahtar ve KEK aynı kalır. Bu yüzden eski bir `keys.json` kopyası, eski kayıt dosyalarıyla birlikte o alanı yeniden açabilir. Tam silme (`deleteAll`) KEK'i de siler ve bu açığı kapatır.
- **R3. Geri alma (rollback).** Kök anahtar değişmediği için eski bir `index.sealed` ile eski kayıt dosyalarını geri koymak eski tutarlı durumu açmaya yeter. `keys.json`'ı değiştirmeye gerek yoktur. `VaultIndex.sequence` sayılır ama güvenilir bir monoton sayaçla karşılaştırılmaz. Cihaz tarafında böyle bir sayaç yok.
- **R4. Anahtar durum alanları (PENDING/ACTIVE) doğrulanmaz.** Değiştirilirse yalnızca hizmet reddi olur, gizlilik bozulmaz; aktif anahtar işaretçisi mühürlü index'tedir.
- **R5. Düz metin göçünde eski JSON dosyası silinir, ama flash bellekten güvenli silme garanti edilemez.** Bu durum makbuzda yazılıdır.
- **R6. KEK döndürme ve dışa aktarma/kurtarma (CRY-07/08/09) yok.** P1, `SPEC_ONLY`.
- **R7. Secure Enclave kullanılmıyor.** SE simetrik toplu şifreleme yapmaz (§111.1); KEK Keychain'de durur.

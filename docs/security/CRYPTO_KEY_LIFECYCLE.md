# Anahtar yaşam döngüsü (§111.2): `Packages/KabinsizCore/Sources/Vault`

```text
Keychain KEK (app.kabinsiz.vault / kek.v1, WhenUnlocked)        ← KeychainKeyStore
        │ AES-GCM wrap, AAD "kabinsiz.wrap.v1|ROOT|<id>|AES-256-GCM|1"
   Vault root (keys.json)
        ├── wraps DEK:BODY / DEK:WARDROBE / DEK:PREFERENCES / DEK:TRAVEL   (keys.json)
        └── seals index.sealed  (AAD "kabinsiz.index.v1|<rootID>")
DEK:<domain> → records/<id>.<generation>.vrec
   AAD "kabinsiz.record.v1|type|id|schema|domain|class|keyID|generation"
```

| Aşama | Ne olur | Çökme olursa |
|---|---|---|
| İlk açılış | KEK üretilip Keychain'e yazılır. Kök anahtar üretilir ve KEK ile sarılır. Önce boş index yazılır, `keys.json` en son | `keys.json` yoksa ve kayıt yoksa baştan başlanır (KEK'in üzerine yazılır). Keys varsa ama index ve kayıt yoksa boş index yazılır. Index yok ama kayıt varsa `corrupted`, hiçbir şey silinmez |
| Örnek | Süreç başına bir klasörde yalnız bir `Vault` örneği açık olabilir (`alreadyOpen`). `close`/`deleteAll` sonrası eski örnek `closed` hatası verir | — |
| Diske yazma | Her dosya atomik yazılır, ardından dosya ve klasörü için `F_FULLFSYNC` çağrılır; bu, güç kaybında da yazma sırasını korur | — |
| Alan anahtarı | İlk yazmada DEK üretilir, kökle sarılır, `PENDING` olarak `keys.json`'a eklenir. Kayıt dosyası yazılır, sonra index commit edilir, sonra anahtar `ACTIVE` olur | Commit öncesi çökme: anahtar ve dosya kurtarmada silinir |
| Yazma | Yeni nesil dosyası yazılır, index commit edilir, eski nesil dosyası silinir | Eski veya yeni nesil tutarlı kalır; artık dosyalar süpürülür |
| Döndürme (`rotateKey`) | Yeni DEK (`PENDING`) üretilir. Her kayıt açılıp yeni anahtarla yeniden mühürlenir ve geri okunarak doğrulanır. Index commit edilir (aktif işaretçi taşınır). Eski anahtar ve dosyalar silinir | CRY-05: üç noktada da tutarlı eski veya yeni kasa |
| Kayıt silme | Mezar taşı commit edilir (nesil +1). Türetilmiş kayıtlar zincirle silinir. Dosyalar silinir | Index mezar taşı içerir; eski dosya geri gelemez |
| Alan silme | Alan + türetilmişler mezar taşına çevrilir. DEK `keys.json`'dan silinir (crypto-shred) | Kullanılmayan anahtar kurtarmada silinir |
| Her şeyi silme | Klasör tek adımda `.<ad>-trash-<uuid>`'e taşınır ve silinir. KEK silinir. Yeni boş kasa açılır | Çöp klasörü açılışta temizlenir |
| Anahtar kilitli / kayıp | KEK şu an okunamıyorsa (cihaz kilitli) `keyUnavailable`, veri varken KEK hiç yoksa `keyLost` döner. İkisinde de hiçbir şey üretilmez veya silinmez. Kayıpta kullanıcı Profil'den sıfırlayabilir (`Vault.destroy`); göç etmemiş düz metin dosyaları korunur ve yeni kasaya taşınır | — |

## Kurallar

- Anahtar baytları hiçbir zaman loglanmaz ve yazdırılmaz. `KeyRecord`'un `description` ve `Mirror` çıktıları sarılı baytları içermez; test bunu doğrular.
- `derivedFrom`: türetilmiş bir kayıt yalnız canlı kaynaklara bağlanabilir (`missingSource`). Böylece hiçbir kayıt silme zincirinin dışında kalamaz.
- Kimlikler `[A-Za-z0-9_-]{1,128}` olmalı. Bu, yol kaçışını önler ve `|` ayracıyla kurulan AAD'nin belirsiz olmamasını sağlar.
- iOS'ta her dosya `completeFileProtection` ile yazılır: cihaz kilitliyken okunamaz. Uygulamanın arka plan işi olmadığı için bu kısıt sorun değildir.
- Keychain erişim sınıfı `kSecAttrAccessibleWhenUnlocked`. Gerekçe için bkz. D-008 ve THREAT_MODEL R1.

## Yapılmayanlar

| Başlık | Durum |
|---|---|
| KEK döndürme | `SPEC_ONLY`: iki Keychain öğesiyle crash-safe tasarım gerekiyor |
| Kök anahtar döndürme | `SPEC_ONLY` |
| Şifreli dışa aktarma ve kurtarma (§111.3, CRY-07/08/09) | P1, `SPEC_ONLY` |
| CRY-06 gerçek kilit durumu | `REAL_DEVICE_BLOCKED`. Mantık testi var: kilitli `EphemeralKeyStore` |

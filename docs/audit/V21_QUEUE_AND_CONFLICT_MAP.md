# v2.1 iş sırası ve çatışma haritası

Tarih: 2026-11-03 · WP15-05 bu haritayla aynı commit'te TESTED
Kanonik: `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md`
Ayrı ekler: `docs/constitution/addenda/` (v1.6, v1.7, v1.8, v1.9, v2.0, v2.1). v1.5 birleşik metin: `docs/constitution/archive/`.
Bu dosya plandır, kanıt değildir. `V15_QUEUE_AND_CONFLICT_MAP.md` dosyasının yerini alır. Durumlar §74.1 sözlüğüyle; v2.1 ayrıca `CODED / TESTED_SIMULATOR / DEVICE_VERIFIED / USER_VALIDATED / PARTNER_VERIFIED / BLOCKED_EXTERNAL / UNKNOWN` ayrımını zorunlu kılar (LM21-00.1).
Kısaltma: "Ek v1.x" = `addenda/` içindeki ayrı dosya. § numaraları eklerin kendi başlıklarıdır (v1.6/v1.7/v2.0 numaralı bölümler; v1.8 `V18-*`, v1.9 `V19-*`, v2.1 `LM21-*`).

---

## 1. Sürüm doğrulaması (Python difflib, satır bazlı, `autojunk=False`)

Betik: `SequenceMatcher(birleştirilmiş_bileşenler, ana_metin)`; satır sonu boşlukları kırpıldı. "Eşleşen" = sırayı koruyarak birebir aynı satır.

| Ana metin | Satır | Bileşenler (ana metindeki sırayla) | Bileşen satırı | Eşleşen | Ana metinde fazla olan |
|---|---:|---|---:|---:|---|
| v1.7 | 6517 | Ek v1.7 (424) + Ek v1.6 (360) + v1.5 (5702) | 6489 | 6489 (%100) | 29 satır: v1.7 başlık bloğu (satır 1–18) + `BÖLÜM C/B/A` ayraçları |
| v1.8 | 7006 | v1.7 (6517) + Ek v1.8 (470) | 6989 | 6989 | 18 satır: v1.8 başlığı + `KISIM I/II` ayraçları |
| v1.9 | 7689 | v1.8 (7006) + Ek v1.9 (667) | 7675 | 7675 | 15 satır: v1.9 başlığı + `BÖLÜM D` ayracı |
| v2.0 | 8746 | v1.9 (7689) + Ek v2.0 (1038) | 8729 | 8729 | 18 satır: v2.0 başlığı + `CİLT I/II` ayraçları |
| v2.1 | 9194 | v2.0 (8746) + Ek v2.1 (428) | 9176 | 9176 | 19 satır: v2.1 başlığı + `CİLT I/II` ayraçları |
| **v2.1 doğrudan** | 9194 | Ek v1.7 + Ek v1.6 + v1.5 + Ek v1.8 + Ek v1.9 + Ek v2.0 + Ek v2.1 | 9096 | 9096 | 99 satır (41 dolu): iç içe beş ana başlık bloğu (satır 1–68) + 6 ayraç (`---` + bölüm başlığı) |

(Satır sayıları `wc -l`; betik bölme nedeniyle +1 sayar.)

Sonuçlar:

- **v2.1 ana metin = v1.5 + altı ekin tamamı + yalnız başlık/ayraç satırları.** Hiçbir ek veya v1.5 satırı değişmemiş, atlanmamış; ters yönde de her bileşen satırı v2.1'de var (eksik: 0). Ana metinde eklerde bulunmayan içerik yalnız başlık blokları; bunlar **öncelik ve okuma sırası** hükümleri taşıdığı için bağlayıcıdır (bkz. §2).
- **Sıra kronolojik değil:** v2.1 içinde Ek v1.7 (`BÖLÜM C`) → Ek v1.6 (`BÖLÜM B`) → v1.5 (`BÖLÜM A`) → Ek v1.8 (`KISIM II`) → Ek v1.9 (`BÖLÜM D`) → Ek v2.0 (`CİLT II`) → Ek v2.1 (`CİLT II — v2.1`).
- **v1.6 ana metni yok ve eksik değil:** v1.6 yalnız ek olarak yazılmış; v1.7 başlığı "v1.5 + v1.6 GitHub denetimi + v1.7" diye üçünü birleştirir. Repodaki v1.5 (`df0937d7…`) v1.7'nin `BÖLÜM A`sı ile birebir aynı.
- Ek v1.6–v1.9 `77e00ff` SHA'sını denetler (WP15-03/04 açık sanılır); Ek v2.1 `25897e7`'yi denetler. Eklerdeki "vault yok / egress yalnız beyan" bulguları (v1.6 DATA-01, §8; V19-01 tablosu) WP15-03/04 ile **kapandı**; yeniden yazılmaz (LM21-14 "tekrar yazma").

### 1.1 Her ekin eklediği bölümler ve ID aileleri

| Ek | Bölümler | İş paketi ID'leri | Test / soru ID'leri | Diğer ID'ler |
|---|---|---|---|---|
| v1.6 | §0–§13 | `REPO-00, CORE-SEC, BODY-3D, CAT-IDENT, FABRIC-TRUTH, FIT-TRUTH, THERMAL, SHOP-CARD, LAB-REAL, LIVE-PILOT` (§9) | `T-KAB-PROD-001..007`, `T-KAB-FIT-001..009`, `T-KAB-MAT-001..008`, `T-KAB-SEC-001..007` (§10) | Bulgular `FIT-01..04, SKU-01, MAT-01, TMP-01, VIZ-01, SCAN-01, DATA-01, QA-01, OPS-01` (§1.2); runtime `AGENT-01..16` (§7) |
| v1.7 | §0–§19 | `R17-00..R17-14` (§15) | `R17-SKU-01..05, R17-DAT-01..03, R17-FIT-01..06, R17-MAT-01..04, R17-THM-01..03, R17-3D-01..04, R17-PERF-01..02, R17-SEC-01..05, R17-ML-01..02, R17-UX-01..02, R17-E2E-01..02` (§14) | Görsel kademeler `G0..G3` (§3.2); runtime `RT-01..24` (§8); kapılar `Gate A..G` (§17); sözleşmeler `ProductIdentityV1, ProductPhysicalSpecV1, FabricSpecV1, BodyProfileV2, RegionalFitV1, ThermalAdviceV1, VisualTryOnV1` (§4) |
| v1.8 | `V18-00..V18-17`, `V18-SON` | `R18-WP01..WP15` (V18-15) | `V18-T-001..048` (V18-13) | Kapsam durumları `UNIVERSAL_SCHEMA_SUPPORTED … LIVE_PARTNER` (V18-00.1); kaynak kademesi `Tier A..E` (V18-04.2); havuzlar `POOL A/B/C` (V18-03.2) |
| v1.9 | `V19-00..V19-23`, `SON HÜKÜM` | `WP19-00..WP19-16` (V19-17) | `V19-T-001..066` (V19-18), `V19-Q01..Q40` (V19-20) | Runtime `R01..R28` (V19-11); hız `S0..S3` (V19-03.3); kumaş `F0..F4` (V19-05.1); `StyleDNA` 12 eksen (V19-07.1); stil rubriği `K01..K10` (V19-08.4); teslim dosyaları 1–12 (V19-21) |
| v2.0 | §01–§17 | `UI20-WP01..WP10` (§15) | `UI20-T-001..030` (§14.1); 12 denetim sorusu (§16) | Ekranlar `UI-00..UI-14` (§07); bileşenler `K-001..K-020` (§09); renk tokenları (§03) |
| v2.1 | `LM21-00..LM21-17` | `LM21-WP01..WP17` (LM21-14) | `LM21-T01..T50` (LM21-12), 25 denetim sorusu (LM21-15) | Modüller `LM21-M01..M24` (LM21-05); roller `AG-LM-01..12` (LM21-13) |

---

## 2. Okuma sırası ve öncelik (belgelerin kendi hükümleri)

Her ana metin kendi başlığında öncelik verir; v2.1 en güncel olanıdır. Alıntılar kısaltılmıştır.

| Kaynak | Okuma sırası | Öncelik |
|---|---|---|
| **v2.1 ana başlık** (satır 5–7) | "İlk okunacak: `LM21-00`, `LM21-01`, `LM21-06`, `LM21-07`, `LM21-14`, `LM21-16`, ardından v2.0 anayasasının güvenlik, avatar, ürün doğruluğu ve Quiet Atelier bölümleri." | "Hukuk, veri koruma ve KVKK → kullanıcı rızası/yerel-öncelikli mahremiyet → güvenlik/kanıt → v2.1 LM21 live mirror (**yalnız canlı ayna için**) → v2.0 UI ve önceki ürün kararları → en son kanıtlı repo uygulama durumu. Daha yeni maddeler eskileri otomatik silmez; çelişki ADR ile çözülür." Bulut VTON asla varsayılan olmaz. "Cloud demo öncesi mutlak durdurma kapısı: açık izin + sağlayıcı sözleşmesi ve veri hakları + maliyet sınırı + gerçek iPhone testi." |
| v2.0 ana başlık | — | "Hukuk, güvenlik, mahremiyet, veri doğruluğu > v1.9 sistem değişmezleri > v2.0 renk, tipografi, ekran düzeni > mevcut repo gerçekliği." Eski tasarım tokenı ile çelişkide v2.0; "gerçek kod ile belge çeliştiğinde gerçek kod tamamlanmışlık kanıtıdır". Ek v2.0 başı "BÖLÜM ÖNCELİĞİ" aynı sırayı + "> estetik tercih" verir. |
| v1.9 ana başlık | "Önce `V19-00`, `V19-20`, `V19-22`; ardından repo SHA ve kanıtlar." | "Hukuk/platform/güvenlik → kullanıcının veri tercihleri/izinleri → v1.9 gerçeklik/uzman doğrulama ve fail-closed → v1.8 ve önceki." "Repo CLAUDE.md henüz daha eski kanona işaret ediyor olabilir; Claude bunu önce denetlemeli." |
| v1.8 ana başlık | "v1.8 `V18-00..V18-SON`, önceki v1.7 eki, v1.5 koordinasyon/güvenlik." | "Güvenlik/hukuk/platform → kullanıcı rızası/veri minimizasyonu → v1.8 çok markalı/alışveriş/gelir sözleşmeleri → v1.7 ve v1.5 temel mimari → gerçek repo kanıtları." "Tarihsel v1.5 maddesi daha eski versiyon çağırdığında bu bütünleştirilmiş dosyanın güncel versiyonunu esas al. Daha sıkı güvenlik önlemini koru." |
| v1.7 ana başlık | "Önce v1.7 `BÖLÜM C`, sonra v1.6 `BÖLÜM B`, sonra v1.5 `BÖLÜM A`." | "Yasa/platform → daha sıkı mahremiyet/güvenlik değişmezi → v1.7 → v1.6 → v1.5 → eski ADR. **Daha zayıf bir yeni kural eski güvenlik kontrolünü geçersiz kılamaz.** Çatışmayı ADR ve diff ile belgele, gizlice çözme." |
| v1.5 (archive) | §§101–135 → §0 → §§75–100 → eski bölümler | hukuk/platform/güvenlik → rıza/mahremiyet → v1.5 → §§0–100 (sıkı kural korunur) → repo kanıtı → ADR |

**Birleşik kural (bu repoda uygulanacak):** (1) hukuk/KVKK/platform → (2) kullanıcı rızası ve yerel-öncelikli mahremiyet → (3) güvenlik ve kanıt / fail-closed doğruluk (v1.9) → (4) LM21 yalnız canlı ayna konularında → (5) v2.0 tasarım/UI → (6) v1.8 → v1.7 → v1.6 → v1.5 ürün kararları → (7) kanıtlı repo durumu → (8) eski ADR. Her seviyede daha sıkı güvenlik/mahremiyet kuralı kazanır (v1.7 başlık, v1.8 başlık). Çatışma ADR ile kaydedilir (v1.7, v1.9, v2.1 başlıkları). Canon değişikliği için V19-17 "`CLAUDE.md` ve `docs/constitution/` conflict resolution ADR'ı oluştur; yeni dosya eski kanonu sessizce ezmesin."

**Önerilen okuma sırası (v2.1 emri + önceki ekler):** LM21-00, -01, -06, -07, -14, -16 → v2.0 güvenlik/avatar/ürün doğruluğu/Quiet Atelier (§03–§07, §11) → V19-00, V19-20, V19-22 → V18-00..V18-SON → v1.7 `BÖLÜM C` → v1.6 `BÖLÜM B` → v1.5 `BÖLÜM A` gerektikçe (§§101–135 önce).

---

## 3. Çatışma haritası

C-1..C-8 `V15_QUEUE_AND_CONFLICT_MAP.md` içinde; C-2/C-3 çözüldü, diğerleri aşağıda güncellendi.

| # | Çatışma | Belge hükümleri | Öncelik kuralının verdiği çözüm |
|---|---|---|---|
| C-9 | **Cihaz-içi zorunluluğu ↔ bulut canlı VTON** | v1.5 §5.3 "Kullanıcı görselini hiçbir zaman buluta yükleme"; §3.1 ADR-003 "bulut görüntü işleme altyapısı YOK"; §18.1 reddedilen "hidden cloud photo upload", P2 "high realism photo try-on (on-device and privacy budget proven)"; v1.7 §3.2 G3 "izin olmadan gizli bulut GPU fallback'i yasak". v2.1 LM21-01 "iki mod + tek doğruluk motoru": `Local Live Mirror` + açık rızalı `AI Live Mirror (Bulut)` (Decart). | Rıza/yerel-öncelik ve "daha zayıf yeni kural eski güvenlik kontrolünü geçersiz kılamaz" LM21'den üstün. v2.1 kendisi de bulutu varsayılan yapmaz, sözleşme/DPA/hukuk/maliyet/iPhone testi olmadan `BLOCKED_EXTERNAL` ve feature flag OFF der (LM21-00.5, LM21-07.6, LM21-T40). **Çözüm:** Yerel ayna ilerler; bulut modu ADR (§5.3/ADR-003'e yalnız "canlı kamera akışı, açık rıza, süreli oturum" istisnası) + kullanıcı kararı + hukukçu + DPA olmadan kodda yalnız test double/stub, canlı akış yok. Kayıtlı fotoğraf/avatar/ölçü/dolap hiçbir modda gitmez (LM21-00.3). |
| C-10 | **Fotoğraf ve beden verisi mahremiyeti** | v1.5 §5.3, §117 (sunucu tarafı fit ayrı onay ister); v1.6 §8 (PhotosPicker, EXIF temizliği, toplu tarama yok); v1.7 §3.1, §12 (retail gateway ölçü/foto almaz); V18-04.4, V18-08.3 (özel fit iletimi v1.8'de yasak); V19-12; LM21-00.2–3, LM21-07. | Çelişki yok; en sıkı kural uygulanır: beden/foto/avatar/StyleDNA/seyahat `PRIVATE_LOCAL` (V19-12.2); toplu galeri taraması varsayılan OFF; analytics'te özel veri yok; mikrofon her modda kapalı (LM21-06). WP15-03 SEC-01..03 (foto) fotoğraf özelliği gelince açılır. |
| C-11 | **D-003 (3D P0 dışı, 2D kart) ↔ yeni ekler** | v1.6 VIZ-01 "P0 çekirdek: nötr morphable mesh", §9 `BODY-3D`; v1.7 §3.2 G0..G3, R17-06 "avatar mesh + G0/G1"; WP19-07; v2.0 UI-06; LM21-WP06. D-005 (AÇIK) zaten D-003'ün gözden geçirilmesini istiyor. | D-003 artık hiçbir belgeyle uyumlu değil. **Çözüm:** D-003 kapatılır, yerine ADR: "nötr 3D morph avatar P0; 2D kart G0 olarak etiketli fallback kalır." Bu WP15-07/08'in kapsamıdır. 3D görünüm fit kanıtı sayılmaz (v1.7 §3.2, V19-06.6). |
| C-12 | **360° döndürülebilir avatar** | v1.5 §87.4 "360° görünüm", V14-T-030; §5.5.4 tek fotoğraftan 360 giysi geometrisi üretilmez; v2.0 UI-06 "Ön/yan/arka, pinch/rotate", §05.2 Reduce Motion'da otomatik dönme KAPALI; V18-10.5 "valid asset varsa morph/rotate"; LM21-02 90° dönüş, LM21-T09 90/180°. | Çelişki yok: **gövde avatarı** 360° döndürülebilir (manuel), otomatik dönme Reduce Motion'da kapalı; **giysi** 360° yalnız yetkili/hazır asset varsa, yoksa "Genel silüet önizlemesi" etiketi (UI-06). |
| C-13 | **Canlı Ayna "birinci sınıf yüzey" ↔ 3 sekmeli IA** | Ek v2.1 başı "birinci sınıf kullanıcı yüzeyi Canlı Ayna"; v2.0 §06 P0 `Bugün | Dolabım | Ben`, 5 sekmeye test olmadan geçilmez; v1.5 §4.2; V18-10 "mevcut 3 tab'ı korur"; v1.5 §18.1 "AR camera composite" P2. | LM21 yalnız canlı ayna konularında üstün; IA v2.0'da. **Çözüm:** Canlı Ayna, ürün kartından ("Canlı aynada dene", LM21-03 A) ve stilistten açılan tam ekran rota; yeni sekme yok. Önceliği LM21-14 P0 sırasıyla yükselir, ama gerçek iPhone olmadan `DEVICE_VERIFIED` olamaz (LM21-10.9). Ayrı sekme gerekip gerekmediği `UNKNOWN` (kullanıcı testi). |
| C-14 | **Tasarım tokenları** | v1.5 §4.3 `brand.ink #283D46`, "başlıklarda serif değil"; kod `apps/ios/Kabinsiz/DesignSystem/Theme.swift:10` aynı değeri kullanıyor. v2.0 başı: `#283D46` ve "serif yasak" yerine Atelier Linen paleti + sistem serif başlık. | v2.0 tasarım kararı eski tokenı geçer (v2.0 başlık). **Çözüm:** UI20-WP02 token göç ADR'ı; `Theme.swift` uyarlanır, global yeniden yazım yok (v2.0 §10). Kontrast değerleri cihazda ölçülene kadar hedef. |
| C-15 | **Üçüncü sekme adı** | v1.5 §4.2 ve kod: "Benim Modelim"; v2.0 §06 / UI-11: "Ben". | v2.0 UI/IA kararı; ad değişikliği UI20-WP04'te. Küçük; kullanıcı onayı tercih edilir (`UNKNOWN`: bilinçli mi). |
| C-16 | **Kamera/barkod (D-002 manuel kod)** | v1.7 R17-03, V19-03, WP19-03, v2.0 UI-03, V18-02 kamera taraması ister; D-002 geçici manuel kod. | D-002 geçici kalır; kamera kodu yazılabilir, ama S0–S3 p95 ve kamera kanıtı fiziksel iPhone ister → `REAL_DEVICE_BLOCKED`. Kamera izni reddinde manuel kod zorunlu fallback olarak kalır (R17-UX-01, UI20-T-008). |
| C-17 | **Ticaret / affiliate / sponsor** | v1.5 §93 "P0 account, payment, ads … yok", §18.1 P2; v1.8 tüm gelir modeli. | v1.8 kendisi: P0 güvenlik bitmeden canlı affiliate/retail açılmaz (v1.8 başlık, V18-15 "Sıra uyumu"). **Çözüm:** R18-WP02..07 sentetik, ağsız; R18-WP08+ ve tüm canlı gelir `BLOCKED_EXTERNAL`. Organik sıralama komisyonu girdi almaz (V18-07, V19-08.3). |
| C-18 | **Travel** | v1.5 §75.2/§122 P1, D-004 yeni travel özelliği yok; v2.0 UI-01 hızlı yol "Seyahat", UI-10 Seyahat Stilisti. | V19-17 "Seyahat ve Android hiçbir zaman temel ürün doğruluğunun önüne geçirilmez." **Çözüm:** D-004 geçerli; UI-10 yalnız mevcut motorun görsel cilası (UI20-WP09), P0 sonrası. |
| C-19 | **Astroloji/numeroloji** | v1.5 §59 civarı (satır 648), §1765, `OCT-12`; V19-09; v2.0 Görev G; LM21-09. | Uyumlu: varsayılan KAPALI, açık opt-in, fit/hava/güvenlik/ticaret puanlarını değiştirmez (V19-T-042/043). WP19-14. |
| C-20 | **Üç ayrı runtime modül numaralandırması** | v1.5 §104.1 24 uzman (OCT-*), v1.6 `AGENT-01..16`, v1.7 `RT-01..24`, v1.9 `R01..R28`, v2.1 `LM21-M01..M24`. | v1.7 §8: "ikinci paralel filo kurulmayacak"; `docs/system/RUNTIME_MODULE_MAPPING.md` ile eşleme + drift testi. v1.9 V19-21.3 `V19_OCTOPUS_MODULE_REGISTRY.md`. WP15-05 (Octopus) ile aynı dosyalara dokunur → WP15-05 bittikten sonra. |
| C-21 | **Ajan/skill önerileri çakışıyor** | v1.7 §9 (9 ajan) + §11 (8 skill); V18-09 (10 ajan, 8 skill); V19-15 (12 ajan), V19-16 (10 skill); v2.0 §14 (9 rol); LM21-13 (12 rol, 10 skill). Repoda 20 ajan, hiçbiri bu adlarla değil. | V19-15 "Gereksiz yeni ajan üretme; eşdeğeri varsa genişlet"; v2.0 §14 "tek implementer, ayrı reviewer". **Çözüm:** ihtiyaç doğduğunda tek eşleme tablosu; toplu ajan yaratma yok. |
| C-22 | **CI yok** | v1.6 OPS-01 (P1), v1.7 §16, WP19-16, R17-12. Repoda `.github/` yok. | P1; GitHub Actions macOS runner maliyeti insan onayı ister (ücretli harcama) → kısmen `BLOCKED_EXTERNAL`. Yerel `scripts/check.sh` sürer. |
| C-23 | **Fit kararının kaynağı** | LM21-00.4, LM21-T32: generatif video fit kanıtı değil; v1.7 §5.9 VTON beden motoruna geri beslenmez; v1.5 §27, §79. | Uyumlu. `PrecisionFitEngine` = mevcut `FitPassport/SizeAdvisor` üzerinde v1.6 §4.2 / v1.7 §5 kurallarıyla genişletilir; VTON çıktısı hiçbir zaman girdi değil. |

---

## 4. Birleşik iş sırası

Kurallar: v1.6 §9 "v1.5 WP15-03..08 güvenlik/avatar önceliğini bozma"; v1.7 §1 "Önce v1.5 güvenlik/çerçeve WP15-03..08; bağımsız fixture/şema araştırmaları çakışmasız dalda paralel"; V18-15 "R18-WP02..05 bağımsız sentetik Swift testli dal olarak yürütülebilir"; V19-17 "Kamera ve katalog işi sentetik fixture üzerinde ayrı dalda yapılabilir; entegrasyon testleri tamamlanmadan merge edilmez"; LM21-14 "Önce WP15-05/06/07/08 ve v2.0 tasarım göçü ile LM iş paketleri arasında conflict register çıkar". Aynı işi tanımlayan farklı ID'ler tek satırda birleştirildi. Bu birleştirme belgelerin bağımlılıklarından türetilmiştir; tek bir belgede bu biçimde yazılı değildir.

Durum sütunu: TESTED / IN_PROGRESS / KUYRUKTA / SPEC_ONLY / BLOCKED_EXTERNAL / REAL_DEVICE_BLOCKED.

| Sıra | ID (eşdeğerler) | İş | Bağımlılık | Durum | Engel |
|---|---|---|---|---|---|
| 1 | WP15-01 (REPO-00 kısmen) | Reality baseline v1.5 | — | TESTED/TAMAM | Cihazlar çevrimdışı |
| 2 | WP15-02 | SystemContracts + şema göçü | 1 | TESTED | — |
| 3 | WP15-03 (R17-01, WP19-01 egress kısmı) | CITADEL egress kapısı | 2 | TESTED | Dinamik ağ yakalama cihaz ister |
| 4 | WP15-04 (R17-01, WP19-01 vault kısmı) | Şifreli vault | 2 | TESTED | CRY-06 cihaz; kriptografi uzmanı yok |
| 5 | WP15-05 (R17-06 kısmı, WP19-02 kısmı) | Octopus koordinatör + kaydırıcı→gövde revizyonu→önizleme→yerel kayıt | 2,3,4 | TESTED (SIMULATOR_ONLY; `docs/evidence/WP15-05.yaml`) | 2D önizleme (D-010); 3D WP15-07/08 |
| 6 | V21-00 (R17-00, R18-WP01, WP19-00, UI20-WP01, LM21-WP01) | Birleşik gerçeklik/boşluk raporu: V19-Q01..Q40, v2.0 12 soru, LM21 25 soru; `V19_REALITY_AND_GAP_REPORT.md`, `V19_REQUIREMENT_TRACEABILITY.md`, `V19_DEPENDENCY_DAG.md`, `V19_BENCHMARK_PROTOCOL.md` (V19-00, V19-21) | 5 bitince (HEAD kararlı) | TAMAM (10 belge; 54 EVIDENCE / 2 ASSUMPTION / 5 UNKNOWN / 16 BLOCKED) | Cihaz/SDK satırları `UNKNOWN` |
| 7 | V21-01 (V19-17 canon ADR) | Canon değişikliği ADR'ı + `CLAUDE.md` güncellemesi + D-003 kapanışı (C-11) + LM21 iki motor ADR'ı (LM21-WP02) | 6 | TAMAM (ADR-006/007/008) | Bulut istisnası insan kararı (bayrak OFF) |
| 8 | WP15-06 (R17-06, WP19-01 termal, LM21-WP07 temeli) | Device governor + hata enjeksiyonu | 2 | TESTED (simülatör + macOS; `docs/evidence/WP15-06.yaml`) | Gerçek termal ölçüm cihaz |
| 9 | WP15-07/08 (BODY-3D, R17-06, WP19-07, UI20-WP07 kabuğu) | Nötr mesh + morph kaydırıcıları + RealityKit + 360° manuel döndürme + VoiceOver; V19-T-023..025, 028, R17-FIT-05 | 5,8 | TESTED (simülatör; `docs/evidence/WP15-07-08.yaml`; V19-T-025 giysi önizlemesi yokken açık) | Cihaz perf `REAL_DEVICE_BLOCKED` |
| 10 | R17-02 (R18-WP02, WP19-04/05 şema kısmı) | `ProductIdentityV1, ProductPhysicalSpecV1, FabricSpecV1, BodyProfileV2, RegionalFitV1, ThermalAdviceV1, VisualTryOnV1` + `BrandRegistry/CommerceGraph/Offer/ClaimEvidence` + golden fixture + göç | 2 (paralel dal) | TESTED (macOS; `docs/evidence/R17-02.yaml`; D-020) | Uygulama v2'ye R17-05'te geçer; gerçek katalog yok |
| 11 | R18-WP03 | `EvidenceCoverageGate`: kaynak çatışması, lisans TTL, fail-closed | 10 | KUYRUKTA | — |
| 12 | LM21-WP03 | LiveMirror sözleşmeleri: `MirrorMode`, `MirrorStatus`, `MirrorSessionSpec`, hata/fidelity, revizyon koruması | 7,10 | KUYRUKTA | — |
| 13 | UI20-WP02→WP03→WP04 | Token göç ADR'ı (C-14) → tipografi + 20 atomlu bileşen kataloğu (`K-001..K-020`) → 3 sekme/sheet/CTA IA | 6 | KUYRUKTA | Kontrast cihazda |
| 14 | WP15-18 (R17-12, WP19-16 kısmı) | Bağımsız kalite kapısı: güvenlik negatif, perf, a11y | 1–9 | KUYRUKTA | — |
| 15 | R17-05 (FIT-TRUTH, WP19-05) | Bitmiş giysi ölçüsü + bölgesel fit + abstain; FIT-01..04 düzeltmeleri `SizeAdvisor` | 10 | KUYRUKTA (V21-00 boşluk 1 öne alınıp kapatıldı: D-018) | Gerçek ölçü verisi yok → sentetik |
| 16 | R17-04 (FABRIC-TRUTH, WP19-06) | Lif/bakım parser, yıkama °C ≠ giyim °C | 10 | KUYRUKTA | OCR cihaz kanıtı |
| 17 | R17-09 (THERMAL) | ThermalComfortAdvisor + bakım | 16 | KUYRUKTA | Canlı WeatherKit PLA bekliyor |
| 18 | R17-03 (CAT-IDENT, WP19-03) | Vision barkod/OCR + GTIN + varyant çözücü | 10, 3 | KUYRUKTA | Kamera ve S0–S3 p95 `REAL_DEVICE_BLOCKED`; gerçek katalog yok |
| 19 | R18-WP04/05 (WP19-09 kısmı) | `OwnedFirstOutfitGenerator` + `OutfitDecisionComposer` köprüsü, ağsız | 10 | KUYRUKTA | — |
| 20 | WP19-09 | Style DNA (12 eksen) + dolap grafiği, unut/sıfırla | 3,4,19 | KUYRUKTA | — |
| 21 | WP19-10 | Atelier aday + kısıt + Pareto sıralama, 3 farklı görünüm, sponsor yalıtımı | 15,16,20 | KUYRUKTA | İnsan stil paneli yok → `HUMAN_REVIEW_PENDING` |
| 22 | R18-WP07 | Sentetik çok marka/varyant/offer fixture kataloğu | 10 | KUYRUKTA | Partner iddiası yok |
| 23 | UI20-WP05/06 (R18-WP06 kısmı) | Today/boş/fallback + Tara/Ürün/Fit doğruluk UI | 13,15,18 | KUYRUKTA | Screenshot simülatör; cihaz ayrı |
| 24 | LM21-WP04→WP05→WP06→WP07→WP08 | Yerel kamera ayna kabuğu → poz/segmentasyon + kare senkron → RealityKit tek giysi + maske → FPS/termal/güç governor → ayna UI + doğruluk etiketleri | 8,9,12 | KUYRUKTA | Hepsi fiziksel iPhone ister (LM21-10.9) → `REAL_DEVICE_BLOCKED`; WP07 "3 iPhone sınıfı" |
| 25 | LM21-WP09 | Fit + ürün kanıtının aynadan bağımsız entegrasyonu | 15,24 | KUYRUKTA | Gerçek tablo yoksa `ABSTAIN` |
| 26 | WP19-08 (R17-08 sentetik kısmı) | Ürün fidelity + hazır giysi örtüsü, logo/doku/renk testleri | 9,10 | KUYRUKTA | Lisanslı asset yok → sentetik prototip |
| 27 | UI20-WP08 (R18-WP06) | Stilist + "Kombinle"/Kombin Tamamla kartları, owned-first | 21,23 | KUYRUKTA | — |
| 28 | R17-10 (SHOP-CARD, WP19-11) | Tek ekran tara→beden→kumaş→hava→3D→kombin | 15–18,21,26 | KUYRUKTA | 1 iPhone e2e `REAL_DEVICE_BLOCKED` |
| 29 | WP19-14 | Sembolik opt-in katman + etik testleri | 21 | KUYRUKTA | — |
| 30 | LM21-WP11 | Token broker stub, bulut bayrağı OFF, mahremiyet negatif testleri | 7,12 | KUYRUKTA (yalnız stub) | Canlı token/sunucu yok |
| 31 | UI20-WP09 | Seyahat, dolap, gizlilik cilası (C-18) | 23 | KUYRUKTA | — |
| 32 | WP19-13 (R18-WP13, R17-PERF) | Gerçek cihaz p50/p95/p99, termal, batarya, bellek | 28 | REAL_DEVICE_BLOCKED | Cihaz |
| 33 | UI20-WP10 | Bağımsız UX/a11y/cihaz incelemesi | 23–31 | KUYRUKTA | Cihaz kısmı blok |
| 34 | R17-12 / WP19-16 (OPS-01) | CI, tehdit modeli, SBOM, release gate | 14 | KUYRUKTA | GitHub Actions maliyeti insan onayı |
| 35 | WP15-09..14 | Fotoğraf girişi, dolap gerçeği, ürün çözücü, fit sınırı, try-on, stilist — ortak sözleşmeye bağlama (büyük kısmı 15–28 ile örtüşür) | 14 | KUYRUKTA | Lisanslı katalog yok |
| 36 | WP15-15 | Travel ortak sözleşme + vault'a taşıma | 35 | CODED/TESTED (v1.2) | P1; WeatherKit PLA |
| — | **Dış engelli** | aşağıda | — | BLOCKED_EXTERNAL / SPEC_ONLY | — |

**BLOCKED_EXTERNAL / SPEC_ONLY (insan onayı, hesap, sözleşme, para, gerçek veri, lisans, GPU/sunucu, App Store):**

| ID | İş | Engel türü |
|---|---|---|
| R17-07 | 1 lisanslı gerçek ürün ailesi | Marka sözleşmesi + veri hakkı |
| R17-08 (gerçek kısım) | Ürüne özel G1 asset üretimi | Marka CAD/foto hakkı |
| R17-11, LAB-REAL, WP19-12, LM21-WP15 | Fit Truth Lab: kör deneme, insan modelist/tekstil/stil paneli | Gerçek kişi verisi, uzman, rıza |
| R17-13, LIVE-PILOT, R18-WP14, LM21-WP16 | Marka pilotu, KPI, birim ekonomi | Partner sözleşmesi |
| R17-14 | Mobile-VTON araştırma (G3) | Ticari lisans (CC BY-NC-SA) + benchmark |
| R18-WP08..WP12 | Retail adapter, teklif/stok, çok marka aday, affiliate, partner portalı | Feed lisansı, affiliate programı, backend sunucu |
| R18-WP15 | Küresel pazar sıralaması | Pilot sonucu + veri hakkı |
| WP19-15 | Partner/affiliate entegrasyonu | Sözleşme, hukuk |
| LM21-WP10 | Decart SDK araştırması + sağlayıcı şartları/DPA | Hesap, sözleşme, hukuk |
| LM21-WP12 | 10 sn kapalı beta bulut VTON POC (yetişkin, opt-in) | Ücretli API, gerçek video, DPA, token sunucusu |
| LM21-WP13 | Sağlayıcı değişimi, fiyat tavanı kanıtı | WP12'ye bağlı |
| LM21-WP14 | Ayna içinde kombin değişimi, alışveriş entegrasyonu | Gerçek kullanıcı adımları; kısmen yerel yapılabilir |
| LM21-WP17 | Release audit, App Review hazırlığı | App Store, cihaz, DPA |
| WP15-16/17/19/20 | Model lab, retail gateway, ticari pilot, Android | v1.5'teki gibi |

---

## 5. Yeni paketlerin ayrıntısı

Her satır: kapsam · test/kanıt ID'leri · bağımlılık · `BLOCKED_EXTERNAL` kısmı. Kanıt formatı V19-19.3: `requirement_ids, sha, build_output, test_command, test_result, device/os, dataset_version/rights, screenshots/video, privacy_egress_capture, perf_trace, model_license, known_failure, independent_reviewer, release_gate, rollback_plan`.

### 5.1 Çekirdek ve sözleşmeler

| Paket | Kapsam | Testler / kanıt | Bağımlılık | Dış engel |
|---|---|---|---|---|
| V21-00 | Q01..Q40 (V19-20) `EVIDENCE/ASSUMPTION/UNKNOWN/BLOCKED` etiketli, `path:line` ile; V19-21 1–9 dosyaları | V19-21 dosya listesi | WP15-05 | — |
| V21-01 | Canon ADR, `CLAUDE.md`, D-003 kapanışı, iki motor ADR'ı + yerel/bulut rıza tehdit modeli (LM21-WP02) | ADR + DECISION_REGISTER | V21-00 | Bulut istisnası: kullanıcı kararı |
| R17-02 / R18-WP02 | v1.7 §4 DTO'ları, V18-04.1 commerce graph, V18-05.1 sentetik örnek; `0` yerine `null`; BODY_SIZE_CHART ≠ FINISHED_GARMENT | golden schema, cross-version; V18-T-001, 002, 008; T-KAB-FIT-001 | WP15-02 | — |
| R18-WP03 | Kaynak kademesi Tier A–E, `CONFLICTING_SOURCES`, lisans bitince `VERIFIED` düşer | V18-T-003, 010, 011, 015, 038; R17-DAT-01..03; V19-T-006, 008, 009 | R17-02 | — |
| WP15-06 | `thermalState`, Low Power, bellek; önce görsel kalite düşer (v1.6 §8) | T-KAB-SEC-005, R17-3D-04, V19-T-050, 055 | WP15-02 | Gerçek ölçüm cihazda |
| WP15-07/08 | Nötr yetişkin mesh, monoton kaydırıcılar, undo/redo, kalıcılık, 360° manuel | V19-T-023..025, 028, 032; R17-FIT-05; UI20-T-005, 013; V14-T-030 | WP15-05, WP15-06 | SMPL-X kullanılamaz (akademik lisans, v1.7 §3.2) → özgün Blender mesh |

### 5.2 Ürün doğruluğu (v1.6 / v1.7 / v1.9)

| Paket | Kapsam | Testler | Bağımlılık | Dış engel |
|---|---|---|---|---|
| FIT-TRUTH (R17-05) | `SizeEvidenceResolver`, `RegionalFitEstimator`, `FitPreferencePolicy`, `HistoryCalibrator`, `AbstentionGate` (v1.6 §4.2); kategoriye göre gerekli bölgeler (v1.7 §5.3); `SizeSystemRegistry` (V19-04.6) | T-KAB-FIT-001..009, R17-FIT-01..06, V19-T-012, 013, 017..022, V18-T-006, 007 | R17-02 | Gerçek ölçü/insan doğrulaması (Gate F) |
| FABRIC-TRUTH (R17-04) | `CompositionParser`, `CareLabelParser`, `FabricInference` (v1.7 §6); F0–F4 (V19-05.1); `WashCareTemperature` ≠ `WeatherWearComfort` | T-KAB-MAT-001..008, R17-MAT-01..04, V19-T-011, 014..016, V18-T-009 | R17-02 | ISO 3758/9920/11092 metin lisansı (v1.6 §5, v1.7 §6) |
| THERMAL (R17-09) | Katman tavsiyesi; sabit °C yok | R17-THM-01..03, V18-T-026 | R17-04 | WeatherKit PLA |
| CAT-IDENT (R17-03) | GTIN check digit, Digital Link, çoklu barkod, `EXACT_VERIFIED / CONFIRMED_BY_USER / CANDIDATE / NO_MATCH` | T-KAB-PROD-001..007, R17-SKU-01..05, V19-T-001..005, 010, V18-T-004, 005, R17-SEC-01, R17-UX-01 | R17-02, WP15-03 | Kamera cihazı; GS1 erişimi/lisansı (V19-Q07) |
| SHOP-CARD (R17-10) | Tek karar kartı (v1.6 §11, V19-13), progressive disclosure (V19-03.4) | R17-E2E-01..02, V19-T-056..058 | 15–18, 21, 26 | 1 iPhone e2e |

### 5.3 Kombin, stil, ticaret (v1.8 / v1.9)

| Paket | Kapsam | Testler | Bağımlılık | Dış engel |
|---|---|---|---|---|
| R18-WP04/05 | POOL A önce; sert kısıtlar; komisyon organik ranker girdisi değil (V18-03.3) | V18-T-012, 016, 017, 024, 047 | R17-02 | — |
| WP19-09 | `StyleDNA` 12 eksen, cold start, unut/sıfırla (V19-07) | V19-T-035..038, 044, 045 | WP15-03/04 | — |
| WP19-10 | Atelier composer, `occasionFit…evidenceQuality` vektörü, güvenli/dengeli/cesur (V19-08) | V19-T-033, 034, 039..041, 046; V18-T-018, 039 | FIT, FABRIC, WP19-09 | İnsan stil paneli (K01..K10) |
| WP19-14 | Sembolik ilham, varsayılan OFF | V19-T-042, 043; UI20-T-024 | WP19-10 | — |
| R18-WP08..15, WP19-15 | Retail/affiliate/sponsor/portal/global | V18-T-013..015, 018..023, 031..034, 036, 043, 048 | v1.5 egress+vault, partner | Tamamı `BLOCKED_EXTERNAL` (feed lisansı, affiliate onayı, backend, hukuk, Apple 3.1.3(e)) |

### 5.4 UI (v2.0)

| Paket | Kapsam | Testler | Bağımlılık | Dış engel |
|---|---|---|---|---|
| UI20-WP02/03 | Atelier Linen / After Hours tokenları, sistem serif başlık + SF Pro gövde, `AtelierTokens.swift`, Asset Catalog Any/Dark/High Contrast, `AtelierComponentCatalogView` | UI20-T-001..003 | UI20-WP01 | — |
| UI20-WP04 | 3 sekme, Tara toolbar eylemi, sheet politikası (v2.0 §08.3) | UI20-T-006, 007 | WP03 | — |
| UI20-WP05..09 | Ekranlar (bkz. §6) | UI20-T-004..030 | WP03/04 + ilgili motor | Cihaz screenshot ayrı sınıf (UI20-T-023) |
| UI20-WP10 | Bağımsız UX/a11y/cihaz | UI20-T-021, 022 | WP05..09 | Cihaz |

### 5.5 Canlı ayna (v2.1) — §7'de ayrıntı

| Paket | Kapsam | Testler | Bağımlılık | Dış engel |
|---|---|---|---|---|
| LM21-WP03 | Sözleşmeler | Swift Testing, revizyon guard | V21-01 | — |
| LM21-WP04..08 | Yerel ayna | LM21-T01, 02, 07..13, 25..30, 38, 39, 41, 42, 48, 50 | WP15-06/07/08 | Fiziksel iPhone (3 sınıf) |
| LM21-WP09 | Fit/kanıt bağımsız | LM21-T32..34, 44 | FIT-TRUTH | — |
| LM21-WP11 | Stub, bayrak OFF | LM21-T14..16, 21, 22, 40 | V21-01 | — |
| LM21-WP10, 12, 13 | Decart bulut | LM21-T17..20, 23, 24, 26, 27, 31, 43, 45..47 | DPA, hukuk | Hesap, ödeme, sözleşme, sunucu |

---

## 6. v2.0 ekran atlası (Ek v2.0 §07, §11)

| ID | Ekran | Ana eylem / ikincil | Zorunlu durumlar (fail-closed / empty) | Kanıt (§11) |
|---|---|---|---|---|
| UI-00 | Native launch + ilk karşılama | "Hemen başla" / "Nasıl çalışır?" | İlk ekranda galeri/konum/doğum tarihi izni yok; hesapsız | UI20-T-008 |
| UI-01 | Bugün (ana ekran) | "Kombini Gör"; hızlı yollar Tara · Stilist · Seyahat | Dolap boş; hava verisi yok (satır gizlenir) | Screenshot + UI test |
| UI-02 | Bugün — yeni kullanıcı boş durum | "İlk kıyafetimi ekle" (Fotoğraf · Kamera · Elle tek sheet) | "Dolabında var" yazmak yasak | UI20-T-009 |
| UI-03 | Mağazada Tara / kamera | Barkod/etiket; Fotoğraf, Kod yaz, flaş | İzin red → elle kod; offline → cache veya "bulamadık"; belirsiz → iki varyant seçimi; iptal | Kamera mock + cihaz |
| UI-04 | Ürün kimliği ve gerçeklik kartı | "Bana uyumunu gör" / "Dolabımdan kombinle" | Doğrulama düzeyi: Marka kataloğu / Etiketten okundu / Kullanıcı girdi / Doğrulanamadı; eksik alan "Veri yok" | Çift varyant testi |
| UI-05 | Beden / bölgesel uyum | 1 beden + en fazla 1 alternatif; "Neden?" | Yüzde skor yok; eksik ölçü tek soru; abstain "mağazada dene" | Golden fixture |
| UI-06 | 3D Deneme — canlı beden stüdyosu | Kaydet / "Ürünü dene" | Ön/yan/arka, pinch/rotate, reset, geri al; üst %60 viewport + bottom sheet; asset yoksa "Genel silüet önizlemesi"; sıcak cihaz → 2D | 3D screenshot / perf |
| UI-07 | Stilist / bugün ne giymeli | "Kombini Kaydet" / "Alternatif gör"; Sade · Karakterli · Cesur | Az veri → açıklamalı öneri; fotoğrafsız çalışır | UX senaryosu |
| UI-08 | Kombin tamamla / gelir yüzeyi | Dolabımdan (varsayılan) → Bu mağazadan → Diğer markalar | Feed yok → kendi dolabı; "doğrulanmış ürün bulunamadı"; sponsor ayrı etiket | Sponsor invariance |
| UI-09 | Dolabım | Ekle (kamera/foto/elle); grid/liste, filtre, arama | Temiz/Giyildi/Yıkamada/Bilinmiyor; otomatik "kirli" yok | Privacy/UI |
| UI-10 | Seyahat stilisti | Wizard: şehir, tarih, plan | Tahmin ufku dışı "tahmin yok"; kullanıcı kilidi korunur | Offline + TZ |
| UI-11 | Ben / kişisel veri | Ölçülerimi düzelt, Fit geçmişini sil, izinler | Skor yok; izin yok; yükleme hatası | Silme/VoiceOver |
| UI-12 | Veri yok / internet yok / düşük güven (StateKit) | Kod yaz / fotoğraf değiştir / alternatif / sonra dene | loading, empty, error, permission denied, no catalog, ambiguous product, offline, thermal fallback, low-confidence | UI20-T-015, 027 |
| UI-13 | Fit Passport / denedim | Beden, oldu/dar/bol, bölge, konfor | Düzenle/sil; tek sonuçtan marka genellemesi yok | — |
| UI-14 | Alternatif / karşılaştırma | 2 beden veya 2 ürün, aynı açı | Farklı fidelity (3D/2D) açıkça gösterilir | UI20-T-029 |

Ek yapı: bileşenler `K-001..K-020` (§09); ana ekran hiyerarşisi 7 katman (§08.1); modal kuralı: tarayıcı tam ekran, beden editörü tam sayfa + sheet, kanıt medium sheet, geri bildirim compact sheet, silme native dialog, 2'den fazla üst üste modal yasak (§08.3); hedef klasörler `apps/ios/Kabinsiz/DesignSystem/Atelier*.swift`, `docs/design/*_v2.0.md` (§10); 8 görev mikro-akışı A–H (§12); ilk teslim: design system + Today + screenshot + T-001..010 (§16).

Canlı ayna ekranları (Ek v2.1 LM21-03): **A** tarama sonrası davet, **B** Local Live Mirror (`Yerel · Çevrimdışı` etiketi, Ön/Yan/Arka/Önce-Sonra, Ürün A/B/Kombin, Beden/Kumaş/Stil, Bitir/Kaydet), **C** AI ayna izin kapısı (10/15/30 sn, ücret, "Yerel aynaya dön"), **D** AI ayna aktif (sayaç, "Bulutta işleniyor", OTURUMU DURDUR), **E** bağlantı/ısı düşüşü, **F** stilist aynası. Kamera sırasında alt navigasyon gizlenebilir, çıkış görünür kalır.

---

## 7. v2.1 canlı ayna mühendislik gereksinimleri

**İki mod + tek doğruluk motoru (LM21-01):** `Local Live Mirror` (ücretsiz, çevrimdışı, cihaz içi, varsayılan) · `AI Live Mirror (Bulut)` (açık rıza, fiyat bilgisi, kapılar) · `PrecisionFitEngine` ikisinden bağımsız. Tek veri yolu, tek izin düğmesi veya otomatik mod yükseltme yok.

**Adaylar ve lisans (LM21-01, v1.7 §3.2, V19-06):**

| Aday | Nerede çalışır | Lisans / durum | Karar |
|---|---|---|---|
| Decart `lucy-vton-3.6` (`3.5` eski) + resmî Swift SDK (`RealtimeModel.lucyVton3_6`, LiveKit/WebRTC, 720p) | Bulut | SDK açık kaynak olsa da model API şartları + DPA ayrı; Decart privacy policy canlı video kaydı/işleme ihtimali belirtiyor (LM21-07.5) | Yalnız opt-in POC; sözleşme yoksa `BLOCKED_EXTERNAL` |
| FASHN VTON v1.5 | Sunucu GPU (H100 ≈5 sn), ~972M param, ~2 GB ağırlık | Apache-2.0; bağımlılık lisansları ayrıca | Araştırma/karşılaştırma; iPhone hızı kanıtsız |
| Mobile-VTON (CVPR 2026) | Cihaz içi araştırma | CC BY-NC-SA 4.0 | Ticari lisans olmadan entegre edilmez (R17-14, R17-ML-01) |
| CatVTON | — | CC BY-NC-SA | Ticari dağıtımda kullanılmaz |
| SMPL-X | Gövde modeli | Akademik | Ticari lisans yoksa kullanılmaz → özgün Blender mesh |
| Apple Vision 2D/3D body pose, person segmentation, TrueDepth; RealityKit + Metal | Cihaz içi | Platform | Yerel ayna temeli; 3D pose çevre ölçüsü vermez (LM21-04 NOT) |
| `anywear.pro` (EchoSub AI), `anywear.live` | — | Decart değil | Karıştırma (LM21-01) |

Kaynak Instagram videosu oynatılamadı; teknolojinin Anywear olduğu `UNKNOWN` (Ek v2.1 başı, LM21-15.2).

**Boru hatları (LM21-04):** LOCAL `AVCaptureSession → Vision 2D/3D pose (+ person matte) → temporal smoothing → anchors → 3D rig & garment LOD → RealityKit/Metal → ekran`. CLOUD OPT-IN `AVCapture (ses yok) → Decart Swift SDK / LiveKit WebRTC → uzak video → ekran`. Modüller `LM21-M01..M24` (LM21-05): görev sözleşmesidir, 24 model/servis değildir; her biri `ModuleRegistry` descriptor + `WorkOrder` + timeout + hata kodu + fixture.

**Performans bütçeleri (LM21-06; hepsi hedef, ölçülmedi):**

| Metrik | Yerel | Bulut |
|---|---|---|
| İlk kamera görüntüsü | ≤1 sn p95 | — |
| Takip→ekran gecikmesi | ≤100 ms p95 (referans iPhone) | g2g ≤500 ms p95 (uygun ağ) |
| FPS | 24+ hedef; normal 720p/30, ısınınca 24 | — |
| İlk dönüştürülmüş kare (TTFF) | — | ≤3 sn p95 (referans Wi-Fi) |
| Adaptif | ısınma: AI askıya, LOD düşür; kritik: provayı kapat, ürün kartına dön | `fast`/`standard` ayrı ölçülür |
| Diğer | kare damgası + monoton sıra; ≥500 ms sapmada gecikme etiketi; mikrofon her modda kapalı | preflight: ağ kötüyse Cloud CTA kapalı |

Ölçülecekler: first preview, connect, TTFF, glass-to-glass, jitter, frozen frame, drop, bellek tepe, termal geçiş, güç/5 dk, MB/60 sn. Ek bütçeler: V19-03.3 S0 ≤0.8 sn, S1 ≤1.0 sn, S2 ≤2.0 sn, S3 ≤1.5 sn; v1.7 §3.3 ilk karar ≤1.5 sn, G1 ≤3 sn; V18-02 ilk kombin ≤2 sn, 3D ≤3 sn — hepsi tasarım hedefi.

**Güvenlik ve rıza (LM21-00, LM21-07):** yerel modda 0 dışa görüntü paketi (ağ harness'ı ile); "Başlat"tan önce token/track/model yok; onaylı host + TLS + kısa ömürlü token, kalıcı anahtar bundle'da yok; token sunucusu yüz/vault/dolap görmez; yeni `EgressIntent.Purpose.liveMirrorVideo` yalnız ayrı review/ADR sonrası; video varsayılan kaydedilmez; arka plan/kilit/izin geri alma/maliyet sınırı/ağ düşüşünde oturum gerçekten kapanır, faturalı otomatik reconnect yok; telemetri yalnız toplulaştırılmış; 18 yaş altı veya yaş bilinmiyorsa uzak canlı video açılmaz; KVKK/GDPR, yurt dışı aktarım için Türkiye merkezli hukukçu incelemesi şart.

**Maliyet (LM21-01, LM21-11; 2026-11-03 sayfası):** standart $0.02/sn, fast $0.04/sn; 30 sn ≈ $0.60/$1.20; 1000 kullanıcı × 30 sn ≈ $600. Oturum 10/15/30 sn, kullanıcı/gün tavanı, idle-stop, fatura uzlaşması.

**İlk kanıt (LM21-16):** gerçek iPhone'da yerel kamera → gövde takip → lisanslı sentetik prototip gömlek → 90° dönüş + kol kaldırma → tek tuş durdur → ağda sıfır hassas veri → termal ölçüm → cihaz videosu. Sonra ayrı: rızalı 10 sn Decart deneyi (sözleşme olmadan yapılmaz). İkisi olmadan "canlı aynayı yaptık" denmez.

---

## 8. Kapılar

- v1.7 §17: Gate A güvenlik · B ürün kimliği · C ölçü/kumaş · D görsel · E performans · F gerçek fit · G mağaza.
- v1.6 §13: ilk kullanılabilir dikey dilim tanımı (1 yetkili marka GTIN'i + gerçek ölçü + yerel profil + bölgesel öneri + cihazda ölçülmüş).
- V18-SON: `DONE` için en az 1 gerçek ürün + cihaz taraması + gerçek iPhone testleri.
- V19-19.2: eşikler önceden kaydedilir; `PASS` için p95 + hatalı karar oranı + gizlilik.
- v2.0 §14.1 çıkış kapısı; LM21-12 release gate (P0 mahremiyet/egress/anahtar/harcama: 0 açık kritik).

---

## 9. UNKNOWN ve belge içi tutarsızlıklar

- v2.0 §16 ilk teslimde "UX20-T-001..010" yazıyor; test listesi `UI20-T-*`. Aynı set kabul edildi; yazım hatası olabilir (`UNKNOWN`).
- V18-12 reklam düzenlemesi "1 Ağustos 2026'da yürürlüğe giren"; V18-17 kaynak 8 "01.07.2026". Tarih `UNKNOWN`, hukuk incelemesinde doğrulanır.
- LM21-13 skill adı `decard-…`; belge doğru adın Decart olduğunu kendisi not ediyor.
- Ek v1.9 V19-01 ve Ek v1.6 §1.2 `77e00ff` durumunu anlatır; WP15-03/04 bulguları kapandı, ekler bunu bilmiyor.
- Decart SDK'nın VTON referans görsel desteği, Swift 6 / iOS hedef uyumu, sürüm: `UNKNOWN` (LM21-01, LM21-15.3–4).
- Canlı Ayna'nın ayrı sekme olup olmayacağı (C-13), üçüncü sekme adı (C-15): `UNKNOWN`, kullanıcı kararı.
- Bulut VTON istisnası (C-9): insan kararı bekliyor.

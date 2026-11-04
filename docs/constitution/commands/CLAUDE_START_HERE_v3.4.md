# CLAUDE CODE — KABİNSİZ v3.4 DİREKT UYGULAMA EMRİ

**Amaç:** Önce gerçek ürün. Sonra gerçek 3D/fit. Ardından kamera aynası. Her yerde “Maximum Intelligence. Minimum Interface”. 3 tab `Bugün / Dolabım / Dene`. Teknik zeka arayüzden gizli.

**Belgeler:** Önce `KABINSIZ_v3.4_OCTOPUS_CATALOG_SELF_OWNED_VTON_EXECUTION.md`; sonra v3.3 `KABINSIZ_v3.3_REALITY_AUDIT_AND_PRODUCT_ENGINEERING_BLUEPRINT.md` ve repo CLAUDE.md / kanıtlar. v3.4 yeni öncelikleri tanımlar, eski güvenlik/kullanıcı verisi kurallarını zayıflatmaz.

## İLK 10 ADIM
1. `pwd; git status --short; git branch --show-current; git rev-parse HEAD; git log -8 --oneline; git diff --stat`; sentetik/fiziksel cihaz/özel ekran farkını kanıtla.
2. `OctopusCoordinator`, `ProductIdentityV1`, `FabricSpecV1`, `RegionalFitV1`, `LiveMirror`, `Vault`, `CitadelGate` mevcut kodunu incele, yeniden yazma.
3. `docs/audit/V34_REALITY_MATRIX.md` aç: her gerekli modül `CODED/TESTED_SIM/DEVICE_VERIFIED/PARTNER_VERIFIED/USER_VALIDATED/BLOCKED_EXTERNAL`, kaynak satırı, test kanıtı.
4. `docs/architecture/V34_PRODUCT_GRAPH_AND_FEEDS.md` ile JSON/CSV partner feed sözleşmesi, `webhook/delta/revoke` ve imzalı index tanımla; lisans filtresi sonrasında indeksle.
5. Bir anlaşmalı partner sandbox'ı veya gerçek veri hakları varsa 20–50 SKU ile barkod exact resolve kur. YOKSA partner adaptörünü fake üzerinden test et ama `BLOCKED_EXTERNAL` olarak raporla; marka ürününü gerçekmiş gibi sunma.
6. Yerel `PhotosPicker → segmentation → dedup → review → Vault` akışını tek gerçek fotoğraf için tamamla; fotoğraflar sunucuya çıkmasın.
7. Bir lisanslı 3D garment varlığını mevcut döndürülebilir `BodyMesh` üstüne bağla ve bir dokunuşta farklı ürünle değiştir. Görselden kaynaklı tahmini kalıp ise etiketle.
8. `AVFoundation` gerçek kamerada person segmentation/pose → local garment overlay baseline oluştur; cihaz testi yoksa `DEVICE_VERIFIED` iddia etme. Bulut feature flag OFF.
9. Bağımsız VTON araştırma dalı: FASHN v1.5 statik model ve alt lisanslarını SBOM ile denetle; live video diye sunma. Mobile-VTON/CatVTON ticari NC, üretime girmez. Kapalı Decart modelini tersine mühendislikle çıkarma/kota aşma YOK.
10. Her PR `SPEC→THREAT→ADR→CODE→TEST→DEVICE→PERF→REVIEW→EVIDENCE`, `main` üzerinde doğrudan riske girme.

## ÇIKTI: SADECE 6 BAŞLIK
1. HEAD ve gerçek implementasyon farkları (satır referansları).
2. Yetenek olgunluğu ve dış haklar/cihaz engelleri.
3. İşleyen en yüksek değerli bir uçtan uca dikey dilim, test komutları ve sonuçları.
4. Güncel `CatalogBrain` diff ve insan onayı gereken sözleşmeler.
5. Local Mirror vs Own VTON fizibilite ölçüm raporu; lisans, benchmark, belirsizlik.
6. Tek sıradaki iş, PASS şartı, ölçülen hız ve screenshot/video kanıtı.

**HARİCİ YETKİ KAPILARI:** Dış hesap, ücretli bulut, marka sözleşmesi, izinsiz scraping, kişisel foto/video aktarımı ve GitHub korumalı dal değişikliği için yetkili insan kararı gerekir. Onay olmadan bloklanmış özelliği açık yapma.

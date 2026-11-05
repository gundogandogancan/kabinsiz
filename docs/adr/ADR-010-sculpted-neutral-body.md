# ADR-010 — Yontulmuş nötr gövde: NAVER Anny tabanlı, cihazda karıştırılan şekil tabanı

- Durum: KABUL · 2026-11-04 · kullanıcı kararı (2026-11-04 sohbet: "model kötü duruyor", seçenek "NAVER Anny") · ADR-007 §2'yi günceller · v1.5 §108.3, v1.7 §3.2, docs/research/VTON_LANDSCAPE_2026-11.md §3.4 / Katman A1
- İnsan onayı: dış kaynak (Anny) indirme ve lisans incelemesi kullanıcı tarafından onaylandı (2026-11-04).
- **Güncelleme 2026-11-05 (ADR-011):** §3'teki "tek fenotip" artık varsayılan nötr şablondur. Kişi isteğe bağlı olarak Kadın ya da Erkek şablonunu seçebilir; isteğe bağlı kilo yalnız çizimi şekillendirir. Kaynak dosyalar `SculptedBody-{neutral,female,male}.*` adını aldı; biçim 3'te `.bin` sıkıştırılmıştır (≈ 0,5 MB). Kilo tahmini Anny'den değil ANSUR II'den gelir.

## Karar

1. **3D katmanının birincil gövdesi, NAVER Anny'den fırınlanmış bir şekil tabanıdır.** Kaynak: Anny kodu Apache-2.0, MakeHuman/MPFB2 varlıkları CC0 1.0 (lisans dosyaları `vendor/anny/LICENSE`, `vendor/anny/src/anny/data/mpfb2/LICENSE.md` okundu). Yalnız varsayılan `anny` topolojisi kullanılır; ticari olmayan `smplx`/`smpl` topolojileri hiç indirilmez ve kullanılmaz.
2. **Cihazda model çalışmaz, ağ yok.** `scripts/avatar/bake_sculpted_body.py` geliştirici Mac'inde bir kez çalışır ve `BodyGeometry/Resources/SculptedBody.{bin,json}` üretir (1,65 MB). Bu dosyalar bir nötr mesh (12 411 köşe, 24 818 üçgen), 18 tek yönlü şekil tabanı (MakeHuman ölçü hedefleri: omuz, göğüs, bel, kalça; gövde/kalça genişlik ve derinlik; kilo fenotipi) ve dört mezura tanımı taşır. Uygulama PyTorch ya da Anny çalıştırmaz.
3. **Nötr ve örtülü (v1.5 §108.3).** Tek bir fenotip (cinsiyet 0,5, genç yetişkin); cinsiyet ya da etnik şekillendirme hiç uygulanmaz. Göz, ağız ve dil boşlukları çıkarılıp kapatılır; baş ve kulaklar kafatasına oturtulmuş tek bir pürüzsüz yumurtaya çekilir (yüzsüz manken başı). Göğüs ucu, göbek ve kasık yerel olarak düzleştirilir. Kollar A-duruşundan indirilip 9° açıyla yanda sabit durur.
4. **Ölçüye bağlama.** Hedefler `AvatarSnapshot`'tan okunur (renderer ölçüye değil anlık görüntüye bakar, §102.3): omuz = 2 × omuz yarı genişliği, çevreler = `Silhouette.halfWidth` tersi. Sırayla: (a) kutu kısıtlı en küçük kareler (`‖J w − r‖² + λ Σ cₖ wₖ²`, `0 ≤ w ≤ üst sınır`) ile taban ağırlıkları; (b) mezuralarda kalan farkı kapatan, boy boyunca yumuşak radyal düzeltme (en çok ±%25; kollar ölçeklenmez, gerekirse omuzdan dışa açılır); (c) omuz için aynı şekilde yan ölçek; (d) tam boya ölçek, ayaklar y = 0. Gerçekçi ızgarada (150/170/195 cm × 5 vücut) çevre hatası < 1 cm, omuz < 1 cm, boy < 0,1 mm (test).
5. **Yedek sırası (G0) korunur.** `BodyMesh.best`: önce yontulmuş gövde; kaynak dosya eksik, bozuk (SHA-256 uyuşmazlığı, boyut, indeks) ya da sonuç doğrulamadan geçemezse ADR-007 prosedürel gövde; o da olmazsa 2D siluet. Yontulmuş gövde ADR-007'deki yapısal doğrulamanın aynısından geçer (kapalı, dışa dönük, sonlu, dejenere üçgen yok).
6. **Görünüm kanıt değildir** (v1.7 §3.2): değişmedi; etiket aynı kalır.

## Neden

Kullanıcının hedefi "kendine benzeyen" bir model; prosedürel tüp gövde (ADR-007) bunu karşılamıyordu (kalçada dikiş, kopuk kollar, el/ayak/omuz anatomisi yok). Araştırma belgesi Anny'yi en düşük lisans riskli aday olarak seçmişti. Tüm işlem adımları köşe konumlarında doğrusal ya da sabit olduğundan, telefonda karıştırılan şekiller Anny'nin kendi çıktısıyla en çok 0,5 mm farklıdır (fırınlama raporu, `provenance.linearityWorstMm`).

## Sonuç

- Kod: `BodyGeometry/SculptedBody.swift`, `BodyMesh.Part.body`, `BodyMesh.best`; `PreviewScene.render` ve `AppModel.neutralStandIn` `best` kullanır.
- Testler: `OctopusTests/SculptedBodyTests.swift` (yükleme ve fail-closed, geçerlilik, ölçü ızgarası, simetri, belirlenimcilik, 3⁵ uç kombinasyon, yüzsüz baş profili, yedek sırası).
- Yeniden fırınlama: `vendor/anny` klonu + `pip install ./vendor/anny scipy` ile kurulmuş bir venv; komut betiğin başında. Çıktının SHA-256'sı JSON'da; Swift yüklerken doğrular.
- Lisans bildirimi uygulama paketinde: `BodyGeometry/Resources/NOTICE.md`.
- **Ölçülmedi / UNKNOWN:** gerçek cihazda kare süresi ve bellek (`REAL_DEVICE_BLOCKED`, WP15-18 / WP19-13). Simülatörde debug derlemede gövde başına ≈ 60 ms (doğrulama dahil) gözlendi; bu bir performans iddiası değildir.
- **Sınırlar:** güvenli aralığın uç köşelerinde (ör. 160 cm boy + 155 cm bel) radyal düzeltme sınırına takılır; şekil pürüzsüz kalır ama mezura hedefin altında kalabilir. Eller parmaklı, ayaklar parmaklıdır (manken düzeyinde; yüz yok).
- Hukuki not: lisans yorumu mühendislik okumasıdır; ticari yayından önce AG-14 onayı gerekir.

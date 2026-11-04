# ADR-017 — Kendi canlı aynamız (FASHN yolu), beden formu, şehir katmanları ve rakip keşfi

- **Durum:** Kabul edildi (2026-11-04). ADR-015 (Canlı Ayna iskeleti) ve ADR-016'yı (model yalnız elle döner) korur, genişletir.
- **Kaynak:** Kullanıcı istekleri (2026-11-04):
  1. "fashn-vton-1.5 … tüm sistemini çözüp kendi live mirror'ımıza yapmalıyız".
  2. "kadın erkeğe göre model değişmeli; bel, göğüs, omuz bu ölçüler önemli; kullanıcıya göre bir app olmalı".
  3. "Anywear, Alta, Daily Clothes, Doji … iyi yönlerini ve bizden iyi olan her şeyini alıp bu app'e koyacağız".
  4. "replica-skill ile rakiplerin en iyi özelliklerini tersine mühendislikle çöz".
- **Bağlayıcı kanon:** v3.6 → v3.5 → v3.4 → v3.3 → v3.2.
  - v3.4: Replica bir UI skill'idir, VTON motoru değildir; kapalı servis modelini çıkarmak için kullanılmaz.
  - v3.6: yetkisiz proprietary model tersine mühendisliği yapılmaz.
  - v3.5: şehir için üç katman (A/B/C); varsayılan şehir uydurulmaz.

## Karar 1 — Canlı aynanın sahibi biziz: F1 yerel ayna canlı katman, FASHN çevrim dışı üretici

FASHN VTON 1.5'i inceledik (Apache-2.0 kod ve ağırlık). Teknik özellikleri:

- Piksel uzayında MMDiT, 972M parametre.
- Çıktı 576×864, 30 Euler adımı.
- H100'de yaklaşık 5 saniye; 8 GB VRAM ister.
- Eğitim kodu yayımlanmamış.

**Sonuç:** Bu model iPhone'da canlı video hızında çalışamaz (kare başına saniyeler gerekir, canlı ayna için ise 30 fps). Bu yüzden:

| Katman | Ne | Durum |
|---|---|---|
| L0 canlı | F1 yerel ayna: Vision 14 eklem → `GarmentRig` → OWNED_ORIGINAL giysi çizimi (ADR-015) | CODED + SIMULATOR_TESTED; cihaz R-002 |
| L1 tek kare | "Bu kareyi gerçekçi yap": FASHN 1.5, `segmentation_free`, düz serili ürün fotoğrafıyla, **Mac'te çevrim dışı** PoC | RUN 2026-11-04 (`docs/research/fashn-poc/`): gerçek insan fotoğrafında çalışıyor; bizim 3B mankenimizi fotogerçekçi yapmıyor; M5 MPS'te 64–290 s/kare → canlı değil, avatar yolu olarak yürümez |
| L2 cihazda | FASHN'ın Core ML anlık görüntü dönüşümü (fp16/int8, 30→4–8 adım) | ERTELENDİ: Mac'te 10 adım 64 s; iPhone'da makul hedef yok, önce L3 |
| L3 damıtma | Kendi küçük öğrenci modelimiz; L1 çıktısıyla, yalnız rızalı ya da sentetik veriyle | Araştırma; veri hakkı kapısı (R-004) |

**Kesin yasaklar:**

- FASHN insan ayrıştırıcısı (NVIDIA lisansı, ticari değil) hiçbir yapıya girmez. Gerekirse yerine Apple Vision kişi maskesi kullanılır.
- Mobile-VTON ve CatVTON yalnız araştırmada kullanılır; NC lisanslıdırlar, gönderilmez.
- Decart/Anywear kapalı kalır: hesap yok, şartname kabulü yok, kota aşımı yok, modeline erişme girişimi yok.
- Kullanıcının yüzü ya da canlı görüntüsü buluta gitmez.
- L1 çıktısı ekranda "Üretilmiş görüntü · beden uyumunu göstermez" etiketiyle gösterilir. T0/T1 giysi T2/T3 diye sunulmaz.

## Karar 2 — Beden formu: Kadın / Erkek / Nötr, kullanıcı seçer

- `BodyForm` (`FEMININE`, `MASCULINE`, `NEUTRAL`) yalnız kullanıcının seçimidir. Fotoğraftan, isimden ya da sesten çıkarılmaz.
- Form çizim oranlarını değiştirir:
  - boyun ve baş;
  - göğüs genişliği ile derinliği arasındaki pay;
  - uyluk;
  - kadında büstün öne çıkışı: halka `zShift` ile yalnız ön yüz öne gelir, sırt yerinde kalır.
- Form, kullanıcının girdiği ölçüleri asla değiştirmez:
  - `withForm` yalnız başlangıç değerlerini taşır, revizyonu bir artırır;
  - ölçülmüş değerler aynen kalır (BFORM-T02).
- Kayıt uyumu: nötr profil eski biçimde yazılır, `form` anahtarı olmayan kayıt nötr okunur (BFORM-T01).
- Giysiler `zShift`'i izler, büst dahil deri dışında kalır (BFORM-T06).
- Uç değerler: her form için 243 uç beden denenir; ya geçerli bir kapalı ağ ve geçerli giysiler çıkar, ya da beden çizimden önce reddedilir (BFORM-T05).
- Rakip kanıtı: Alta boy ve kilo alıyor; Doji fotoğraf alıyor. Hiçbirinin göğüs, bel ya da kalça girdisi aldığını belirtmediğini gördük. Bu bizim ayırt edici özelliğimiz.
- Beden uyumu iddiası yok: lisanslı beden tablosu olmadan "size olur" denmez (R-004).

## Karar 3 — Şehir kimliği ve üç katman (WP35-01/03)

- `CityIdentity` yalnız ad, ülke kodu ve saat dilimini tutar; konum noktası saklanmaz (CITY-T07).
- Şehir adının kaynakları:
  - kullanıcının seçimi;
  - paketteki cadde kataloğu (60 km içinde);
  - Apple ters coğrafi kodlayıcı. Bu Apple'a bir istektir; konum izni metninde açıkça yazılır.
- `CitySceneResolver` katmanları:
  - **A (küratörlü sokak):** ad ve ülke birlikte eşleşirse.
  - **B (OSM2World):** yalnız şehir paketlenmişse, ODbL atfıyla. Bu yapıda yok.
  - **C (nötr atölye):** diğer her durumda, gerçek şehir adıyla.
  - **Yanlış ülke koruması:** Barcelona/VE, Eixample sokağını almaz (CITY-T03).
- Şehir seçilmemişse varsayılan C'dir (stüdyo). İstanbul varsayılan olmaz; kullanıcının şehri değilse onun şehri gibi gösterilmez.
- Güneş: NOAA genel formülleri ile gündüz, altın saat, alacakaranlık ve gece hesaplanır (SUN-T01..T04). Ağ gerekmez.
- Hava altı durumludur: açık, bulutlu, yağmur, kar, rüzgâr, sis.
  - Yalnız kanıtla çizilir: taze gözlem ya da açıkça etiketli önizleme. Olasılık tek başına bir şey çizdirmez (WX-T03).
  - **Rüzgâr yalnız çevreyi hareket ettirir:** parçacıklar ve yağmur açısı. Giysi ve figür ADR-016 gereği kendiliğinden kıpırdamaz. v3.5'teki "rüzgârda giysi hareketi" maddesi bu ADR ile **SUPERSEDED**.

## Karar 4 — replica-skill: yöntemi al, paketi kurma

- İnceleme: `Jakeschincariol/replica-skill`, MIT lisanslı, tek commit. 11 SKILL.md dosyası ve 6 saf Python yardımcı betik içerir:
  - ağ, alt süreç, eval, kanca ve ayar değişikliği yok;
  - Python betiklerinde yalnız standart kütüphane kullanılıyor.
- Paketin kendi kuralları da tersine mühendisliği yasaklar: tarayıcı/kazıyıcı yok, JS paketi okunmaz, decompile yok, ağ trafiği kaydı yok, özel API yok, kod/asset kopyası yok.
- **Karar: USE_METHOD_ONLY.**
  - Eklenti olarak kurulmaz: sabitlenmemiş güncellemeler gözden geçirilmeden gelir, ve paket web/SaaS klonlamaya göre kuruludur.
  - Yöntemin keşif → özellik matrisi → yorum temaları → parite adımları kendi skill'imiz olarak yazıldı: `.claude/skills/kabinsiz-rival-recon/`. MIT atfı içindedir.
- Kaynaklar yalnız herkese açık olanlardır:
  - yardım sayfaları;
  - App Store listeleri ve Apple'ın resmi yorum RSS akışı;
  - resmi bloglar ve basın.
- Rakip uygulamaya giriş yapılmaz, hesap açılmaz.
- Çıktılar `docs/research/rivals/`: `recon.md`, `features.csv`, `reviews.csv`, `feedback.md`, `parity.md`.
- Kopya yok: rakip metni, görseli, renk ya da ticari görünümü alınmaz. Yalnız "işi yapan" özellikler kendi tasarımımızla ve cihazda yapılır. Apple 4.1 (kopya uygulama) riski böylece düşük tutulur.

## L1 PoC sonucu (2026-11-04)

Ayrıntı `docs/research/fashn-poc/README.md`.

- Ayrıştırıcısız çalıştı: stub + `segmentation_free` + düz serili giysi.
- Gerçek fotoğrafta fotogerçekçi sonuç veriyor. Bizim 3B mankenimizde fotogerçekçilik yok, giysi ayrıntısı kayboluyor ve silüet alttaki giysiden geliyor.
- **Sonuç:** canlı ayna L0 olarak kalır. Cihazda gerçekçilik için öncelik V36-12 (kabuk malzeme ve ışık) ve V36-03 (fotoğraftan doku). FASHN yalnız rızalı stüdyo görselleri ya da L3 öğretmeni olarak sunucu/Mac tarafında kalır.

## Sonuçlar

- Yeni testler:
  - BFORM-T01..T06 (OctopusTests);
  - CITY-T01..T07, SUN-T01..T04, WX-T01..T04 (LivingWorldTests).
- İnsan onayı bekleyenler:
  - iPhone bağlantısı (R-002);
  - WeatherKit PLA (R-003);
  - "Daily Clothes" adının netleşmesi (Daily Dress Me mi, Cladwell mi).

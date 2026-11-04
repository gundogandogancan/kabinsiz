# Rakip keşfi (kabinsiz-rival-recon) — 2026-11-04

**Yöntem:** `.claude/skills/kabinsiz-rival-recon`. Yöntem replica-skill'den (MIT) alındı, paket kurulmadı (ADR-017 Karar 4).

**Kaynak sınırı:** Yalnız herkese açık kaynaklar kullanıldı. Hiçbir rakibe giriş yapılmadı, hesap açılmadı, decompile edilmedi, ağ trafiği kaydedilmedi.

**Kanıt sınıfları:**
- **V:** resmi sayfada doğrulandı.
- **C:** pazarlama ya da basın iddiası.
- **U:** bilinmiyor.

## 1. Kapsam

Platform iPhone. İncelenen alanlar ve amaç:

- **Avatar ve beden:** rakiplerin avatarı nasıl kurduğu.
- **Deneme:** canlı ve tek kare.
- **Dolaba ekleme:** fotoğraf, kesip çıkarma, etiket, fiş, bağlantı.
- **Günlük kombin:** hava ve takvim.
- **Dolap zekâsı:** giyim günlüğü, giyim başı maliyet, boşluklar.
- **Seyahat:** valiz.
- **Mahremiyet.**

## 2. Kaynaklar (sıralı)

| Rakip | Birincil | İkincil |
|---|---|---|
| Alta Daily | altadaily.com ve /guide, App Store listesi, Meta AI blogu (SAM) | TechCrunch 2026 |
| Doji | App Store listesi | TechCrunch 2025 |
| Anywear (Decart) | anywear.decart.ai | — |
| Google try-on | support.google.com/googleshopping 16253678, blog.google | jetstream.blog (Doppl kapanışı, ikincil kaynak) |
| Cladwell | App Store id1140550878 | — |
| Daily Dress Me | App Store id6447927117 | — |

**"Daily Clothes" belirsiz:** bu adla tam eşleşen bir uygulama bulunamadı. Adaylar Daily Dress Me ve Cladwell; kurucunun hangisini kastettiğini teyit etmesi gerekiyor.

## 3. Akışlar (herkese açık bilgiden)

- **Alta, avatar:**
  1. Yüz fotoğrafı
  2. Beden fotoğrafı
  3. Boy ve kilo
  4. Avatar hazır.
  Göğüs, bel ve kalça girdisi belgelenmemiş (U).
- **Doji, avatar:**
  1. Birkaç selfie ve 2 tam boy fotoğraf
  2. Yaklaşık 30 dakika bekleme (C, basın)
  3. Fotogerçekçi benzerlik.
  Basına göre "nasıl görünür" gösteriliyor, "nasıl oturur" değil.
- **Anywear:**
  1. Kamerayı aç
  2. Yaklaşık 1,5 saniyede canlı giysi (C)
  Fotoğraf yok, hesap yok. İşlemin nerede yapıldığı belirtilmemiş (U).
- **Google:**
  1. Tam boy fotoğraf ya da selfie
  2. Ürün
  3. Üretilmiş görsel
  Fotoğrafı silme kontrolü var; "eğitimde kullanılmaz" diyor (V).
- **Cladwell:**
  1. Fotoğraflardan toplu ekleme (yapay zekâ)
  2. Yaklaşık 33 parçalık kapsül
  3. Giyim başı maliyet (V)
  Ücretli: yıllık 59,99–79,99 $.

## 4. Çıkarılan veri modeli (güven derecesiyle)

- **Garment:** kategori, renk, mevsim, dress-code etiketi. Alta (V).
- **Avatar:** yüz, beden fotoğrafı, boy ve kilo. Alta (V). Model eğitimi ve işlem yeri U.
- **Outfit log / style calendar:** gün → parçalar. Alta (V).
- **Trip:** yer, aktiviteler, valiz boyu, çok şehir. Alta (V).
- **Wishlist:** ürün → indirim bildirimi. Alta (V). Sunucu gerektirir.

## 5. Kopyalanamaz / alınmayacaklar

- Doji ve Decart'ın üretken modelleri: kapalı modeller, model çıkarma yasak.
- Alta'nın "Style with Alta" marka düğmesi: B2B, sunucu ister.
- Wishlist indirim bildirimi: lisanslı fiyat akışı olmadan yapılamaz (V32-WEB-02).
- Hiçbir rakibin metni, görseli, rengi ya da düzeni alınmaz.

## 6. Zor kısımlar ve boyut

| Konu | Zorluk ve durum |
|---|---|
| Canlı fotogerçekçi deneme (Anywear seviyesi) cihazda | En zor parça. Bugün F1 yerel ayna (temsilî) var; fotogerçekçi tek kare için L1–L3 yolu tanımlı (ADR-017) |
| Kesip çıkarma ve etiket | Orta. Apple Vision ön plan maskesi iOS 17+ cihazda çalışır |
| Takvim | Kolay. EventKit izni gerekir; başlıklar cihazda okunur, saklanmaz |

## 7. Bizim önde olduğumuz yerler (kanıtlı)

- **Beden formu (Kadın/Erkek/Nötr):** göğüs/büst, bel, kalça ve omuz ile kurulan 3B gövde. Hiçbir rakip bunu belirtmiyor.
- **Mahremiyet:** fotoğraf ve yüz cihazdan çıkmaz. Google "eğitimde kullanılmaz" diyor; biz "hiç gönderilmez" diyoruz.
- **Şehir dünyası:** gerçek şehir adı, 3 katman (A/B/C), güneşe göre ışık, 6 hava durumu (yalnız kanıtla).
- **Elle döndürülen 3B model ve giydir/çıkar oyunu** (ADR-016).

Ayrıntılı matris: `features.csv`. Durum karşılaştırması: `parity.md`. Kullanıcı yorumları: `feedback.md` ve `reviews.csv`.

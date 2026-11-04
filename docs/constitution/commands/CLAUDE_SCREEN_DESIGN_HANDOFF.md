# Kabinsiz — GOD LEVEL Minimal Screen Reference v3.1

## Steve + Woz Tasarım Kararı

**Maximum Intelligence. Minimum Interface.** Ekranlar kullanıcıdan mühendislik bilgisini gizler; ekranda mümkün olan en az sayıda ve daima işlevsel eylem bulunur. Görseller **görsel referans** olup gerçek Figma/SwiftUI/3D uygulama kanıtı değildir.

### Ürün bilgi mimarisi

- Ana navigasyon yalnız **Bugün · Dolabım · Dene**. **Ben/Profil** sağ üstte ikincil rota. Görsellerdeki dördüncü profil sekmesi **nihai tasarımda kaldırılacak**.
- **Bugün:** kişinin kendi 3D modelinde hazır günlük kombin; ikamet ettiği/geçerli izinli konumla ilişkili sahne; güncel hava durumu ve buna uygun doğal yağmur/kar/güneş/rüzgâr efekti. **İstanbul/Barcelona sabit değil**; yer ve hava bilgisi izin, güven ve önbellek durumuna bağlı.
- **Döndürme:** model tek parmakla 360° döner; kıyafet yüzeyine dokunmak alt seçim çekmecesini açar. **Ana ekranda kalıcı üst/alt/kemer/aksesuar butonları yok**.
- **Yeni kombin:** tek ana eylem; kişinin dolabı ve bağlamıyla çalışan alternatifler önceden hazırlanır; model üstünde uygulanır. Bulunmayan gerçek kıyafet varmış gibi sunulmaz.
- **Dolabım:** cihaz içindeki fotoğraflardan isteğe bağlı tanıma, ürün/fotoğraf/barkod/link ile ekleme; görseller yalnız kayıt/ürün tanıma kaynağıdır. **3D modelin ürüne özgü doğruluğu ayrı kanıt seviyesidir.**
- **Dene:** barkod, fotoğraf, web bağlantısı tek alana girer; doğrulanmış ürünü 3D modelinde dene; **Canlı Ayna**ya geç. Yerel AR overlay ile bulut video üretimi açıkça ayrılır.
- **Canlı Ayna:** gerçek kamera, mahremiyet ve maliyet kapıları. Bulut VTON kullanıcı açık rızası, sağlayıcı sözleşmesi ve insan onayı yokken kapalı kalır.
- **Ben:** yüz/saç/ölçü özelleştirme; Fit Passport; veri ve gizlilik yönetimi; ayrı gerekliliklerden doğan bilgiler ana ekrana yüklenmez.

### Ekran dosyaları

1. `01_Acilis.png`
2. `02_Bugun_Yasayan_3D_Studio.png`
3. `03_Kiyafete_Dokun_Degistir.png`
4. `04_Dolabim.png`
5. `05_Tara_ve_Dene.png`
6. `06_Canli_Ayna.png`
7. `07_Kombin_Alternatifleri.png`
8. `08_Urun_Detayi_3D.png`
9. `09_Kisisel_Model.png`
10. `10_Hava_ve_Sehir.png`
11. `11_Seyahat.png`
12. `12_Profil.png`

### Claude kabul kapısı

**Bu görseller ekranın nasıl görüneceğini anlatır, gerçek sistemin çalıştığını kanıtlamaz.** Claude her ekranı Figma'da düzenlenebilir bileşenlerle tasarlamalı, SwiftUI/RealityKit uygulamasını geliştirmeli, simülatör ve fiziksel iPhone ile doğrulamalı; statik fotoğrafı 3D avatar diye göstermemeli. Marka adı/fiyat/konum gibi örnek veriler gerçeğe dayanmayan demo içeriğidir. UI’da yanlış yer adını, kesin beden uyumu iddiasını ve yanlış logo/markayı göstermemeli.

Geliştirme kanonu: `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v3.0.md`. Bu dosya **yalnız tasarım handoff ekidir**; teknik anayasayı kaldırmaz.

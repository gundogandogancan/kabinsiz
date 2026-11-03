# ADR-010 — Yaşayan dünya ana ekranı, dört sekme ve marka paleti

- **Durum:** KABUL (2026-11-03). Branch `v25/living-world`; main'e kullanıcı onayı olmadan birleşmez (v2.5 komutu).
- **Bağlam:** v2.5 ana anayasası, Bugün ekranının kart yığını olmaktan çıkıp kullanıcının kendi 360° figürünün günün kombiniyle bir şehir sokağında durduğu bir "yaşayan dünya" olmasını istiyor (§2). Kullanıcı ayrıca Live Mirror'a görünür bir yer istedi ("live mirror yeri olmalı … kabine gitmeden görebilmeli") ve 5 sekmeli bir referans görsel gönderdi. v2.0 §06 ise "3 sekme + Tara tek eylem" diyor; v2.5 ana metni (satır 34) iki kuralı körlemesine uygulamayı yasaklıyor. Kullanıcı ayrıca uygulama ikonunu ve uygulama içi tasarımı gönderdiği marka panosuna/ikona göre istedi.

## Karar

1. **Bugün = yaşayan dünya (`HomeWorldView`).** Önce sahne gelir, kontroller kenarlarda durur:
   - **Arka plan:** Kabinsiz için Blender'da çizilmiş özgün bir sokak (`tools/scenes/build_city_scene.py`, `SceneAssetManifestV1`). Gerçek sokak fotoğrafı ya da harita verisi kullanılmaz.
   - **3B katman:** RealityKit kamerası, render kamerasıyla aynıdır: yatay, 0,45 m yükseklik, 3,40 m uzaklık, 60° dikey görüş açısı. Bu sayede figürün ayakları zemine oturur ve figür tam boy, düğmelerin üstünde kalır.
   - **Hareketler:** yana kaydırma 360° döndürür; dikey kaydırma figüre gitmez; iki parmak yakınlaştırır (sahne de birlikte ölçeklenir); bir parçaya dokunmak ışın izleme (raycast) ile o parçanın bölümünü seçer.
   - **Sol ray:** Üst, Alt, Dış giyim, Ayakkabı, Çanta, Kemer, Aksesuar. Herhangi biri dokunulduğunda tepsi açılır: önce "Dolabımdan", sonra "Mağazadan". Mağazadan sekmesi dürüst "katalog bağlı değil" mesajı ve Tara düğmesi gösterir.
   - **Sağ sütun:** açı değiştir, geri al, yağmur önizlemesi, stil nedenleri, plan ve seyahat. Eski `TodayView` bu son düğmeyle açılır.
   - **Alt bölüm:** kombin nedeni, tek birincil eylem "Yeni Kombin Oluştur" (`primary.newLook`), iki ikincil yol "Canlı Ayna" ve "Ürünü Tara", ve doğruluk etiketi.
2. **Hava.** Hava sağlayıcısı bağlı değilken etiket "Hava verisi yok" der. Yağmur yalnız kullanıcı önizlemesi olarak ve "gerçek hava değil" etiketiyle çizilir. Yalnız olasılık verisi ekranda yağmur yağdırmaz (`SceneWeatherEvidence`; aynı adlı `TravelEngine.WeatherEvidence` ile çakıştığı için yeniden adlandırıldı).
3. **Sekmeler: `Bugün | Dolabım | Ayna | Ben`.** Dört sekme seçildi:
   - **Neden dört:** v2.5 satır 5086 ana tab barını 4–5 öğeyle sınırlıyor.
   - **Ayna neden sekme:** Live Mirror'ın kendine ait bir yeri olsun diye.
   - **Tara neden sekme değil:** Tara REQ-004 gereği tek bir global eylem olarak kalır. Erişildiği yerler: her sekmenin araç çubuğu, Bugün'deki "Ürünü Tara" düğmesi ve Ayna'daki "Mağazadaki ürünü tara" düğmesi.
   - **Stilist AI neden yok:** Referanstaki "Stilist AI" sekmesi eklenmedi. Stil nedenleri Bugün'de duruyor ve sohbet tabanlı bir stilist bu sürümün kapsamında değil.
   - **Doğrulama durumu:** v2.5'e göre sekme yapısı gerçek cihaz testinde sabitlenir. Şimdiki durum SIMULATOR_ONLY.
4. **Canlı Ayna (LM-01..04, yerel mod).**
   - **Giriş ekranı:** Kamerayı açmaz. Mod seçiminde "Yerel Ayna" seçilidir. "Yapay zekâ video" seçeneği kapalı gösterilir (ADR-008 gereği bayrak OFF).
   - **Yerel ayna:** Ön kamerayı açar, vücut duruşunu Apple Vision ile cihazda bulur ve seçilen parçayı bu duruşa göre temsili bir çizim olarak üstüne çizer.
   - **Gizlilik:** Kareler ne kaydedilir ne gönderilir. Uygulama arka plana geçince kamera durur.
   - **Kamerasız durum:** Kamera yoksa (Simülatör) ya da izin verilmemişse `cameraFallbackCard` gösterilir. Sahte kamera görüntüsü yoktur. Yalnız kamera görüntüsü ya da nötr avatar "deneme" sayılmaz.
5. **Marka paleti.** Kullanıcının marka panosu v2.0 §03.1/§03.2 değerlerinin yerine geçer:
   - **Panodaki renkler:** Fildişi #F7F1E7, Taş #D6C4B3, Zeytin #7A8461, Bakır #B3714E, Espresso #2B1E18.
   - **Metin taşıyan roller:** AA sağlansın diye koyulaştırıldı. Marka #93562F, bakır vurgu #9A5D3C, mürekkep #2B1E18. Artırılmış Kontrast varyantlarında 7:1 sağlanır.
   - **Doğrulama:** `AtelierContrastRules` testleri ve `docs/design/COLOR_CONTRAST_REPORT.md` yeniden üretildi.
   - **Dünya kontrolleri:** gri cam yerine ikonun malzemesi kullanılır, yani `paperSurface`: fildişi kâğıt, ince bakır kenar ve yumuşak gölge. Seçili durum bakır dolgudur.
6. **Uygulama ikonu.** Kullanıcının gönderdiği ikon `tools/icon/draw_app_icon.swift` ile vektör yollarla yeniden çizildi:
   - **Öğeler:** kalın sapı inceltip kemerleşen bakır şerit, gömme ayna paneli, ince bıçak ve kumaş kıvrımı.
   - **Çıktılar:** 1024 px açık ve koyu (espresso) varyant.

## Sonuçlar

- **Testler:** UI testleri yeni yapıya göre güncellendi: dünya ilk açılışı, tepsi + değiştir + geri al, yeni kombin, yağmur önizlemesi, şehir seçimi, Ayna girişi ve kamera yedeği, AX-XXXL.
- **Sahneler:** Sahne görselleri asset kataloğunda (`Assets.xcassets/Scenes`). Barcelona sahnesi hâlâ zayıf ve iyileştirme bekliyor.
- **Görsel doğruluk:** Giysiler T1 seviyesindedir (prosedürel, temsili). Hiçbir yerde T2/T3 diye sunulmaz ve beden önerisini beslemez.

# Ekran görüntüsü kaydı (UI20-T-021)

Tüm görüntüler **SIMULATOR_ONLY**. Fiziksel cihazda çekilmedi (REAL_DEVICE_BLOCKED). Görüntüler tasarım uyumunu gösterir; işlevin kanıtı değildir, işlev kanıtı UI testleridir (UI20-T-022).

- Uygulama durumu: commit `ba76059` üzerine UI20-WP02→04 değişiklikleri; bu dosyayı ekleyen commit'e bakın.
- Çekim: `xcrun simctl io screenshot`, sonra `sips -Z 1100` ile küçültüldü. Tema ve kontrast `xcrun simctl ui` ile ayarlandı.
- Veri kaynağı: boş kasa. Katalogdaki bütün değerler `SYNTHETIC_DEMO_ONLY` (ekranda "Örnek veri — gerçek değil" rozeti).
- En küçük kullanılabilir simülatör iPhone 17e. SE sınıfı (4,7") bu Xcode kurulumunda yok; küçük ekran kanıtı bu yüzden eksik.

| Dosya | Ekran | Cihaz | Sistem | Tema | Veri |
|---|---|---|---|---|---|
| [iphone-17-dark-catalog.png](screenshots/ui20/iphone-17-dark-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 (orta) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-dark-hc-catalog.png](screenshots/ui20/iphone-17-dark-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 (orta) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-dark-hc-home.png](screenshots/ui20/iphone-17-dark-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 (orta) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-dark-home.png](screenshots/ui20/iphone-17-dark-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 (orta) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-light-catalog.png](screenshots/ui20/iphone-17-light-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 (orta) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-light-hc-catalog.png](screenshots/ui20/iphone-17-light-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 (orta) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-light-hc-home.png](screenshots/ui20/iphone-17-light-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 (orta) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-light-home.png](screenshots/ui20/iphone-17-light-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 (orta) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-dark-catalog.png](screenshots/ui20/iphone-17-pro-max-dark-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-dark-hc-catalog.png](screenshots/ui20/iphone-17-pro-max-dark-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-dark-hc-home.png](screenshots/ui20/iphone-17-pro-max-dark-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-dark-home.png](screenshots/ui20/iphone-17-pro-max-dark-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-light-catalog.png](screenshots/ui20/iphone-17-pro-max-light-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-light-hc-catalog.png](screenshots/ui20/iphone-17-pro-max-light-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-light-hc-home.png](screenshots/ui20/iphone-17-pro-max-light-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17-pro-max-light-home.png](screenshots/ui20/iphone-17-pro-max-light-home.png) | Bugün (boş dolap, UI-02) | iPhone 17 Pro Max (büyük) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-dark-catalog.png](screenshots/ui20/iphone-17e-dark-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17e (küçük) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-dark-hc-catalog.png](screenshots/ui20/iphone-17e-dark-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17e (küçük) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-dark-hc-home.png](screenshots/ui20/iphone-17e-dark-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17e (küçük) | iOS 26.4 simülatör | Koyu + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-dark-home.png](screenshots/ui20/iphone-17e-dark-home.png) | Bugün (boş dolap, UI-02) | iPhone 17e (küçük) | iOS 26.4 simülatör | Koyu | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-light-catalog.png](screenshots/ui20/iphone-17e-light-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17e (küçük) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-light-hc-catalog.png](screenshots/ui20/iphone-17e-light-hc-catalog.png) | Bileşen kataloğu (ilk ekran) | iPhone 17e (küçük) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-light-hc-home.png](screenshots/ui20/iphone-17e-light-hc-home.png) | Bugün (boş dolap, UI-02) | iPhone 17e (küçük) | iOS 26.4 simülatör | Açık + Increase Contrast | sentetik / boş kasa (`-resetForUITest`) |
| [iphone-17e-light-home.png](screenshots/ui20/iphone-17e-light-home.png) | Bugün (boş dolap, UI-02) | iPhone 17e (küçük) | iOS 26.4 simülatör | Açık | sentetik / boş kasa (`-resetForUITest`) |

UI testlerinin eklediği görüntüler (`ui20-home-empty`, `ui20-home-synthetic-wardrobe`, `ui20-home-axxxl`, `ui20-catalog-light-*`, `ui20-catalog-dark-*`) xcresult paketinde tutulur; depoya kopyalanmadı.

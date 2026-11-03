# Claude Code'a Doğrudan Verilecek Başlangıç Komutu — Kabinsiz v2.4

Aşağıdaki metni, yanında **`KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.4.md`** ve gerektiğinde iki odak belgesi olacak şekilde Claude Code'a gönder:

---

**KABİNSİZ ANA EMRİ**

`https://github.com/gundogandogancan/kabinsiz` projesini aç. `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.4.md` dosyasını kanonik ürün/mühendislik anayasası olarak kabul et; eski şartnameleri ve yeni UI/photo/Live Mirror eklerini tek bir iş sırasına indir. Dosya büyükse **başlangıç / öncelik / gereksinim bölümlerinden başlayıp ilgili alt bölümleri görev bazında oku**; hiçbir şeyi okumadan uygulanmış sayma.

**ÖNCE DENETİM:** HEAD SHA'yı, mevcut kodu, derleme/test kanıtlarını, simulator ve fiziksel iPhone imkânlarını, cihaz izinlerini, model/SDK lisanslarını, hangi ekranın gerçekten çalıştığını kontrol et. Daha önce raporlanan commit `ba760594...` yalnız tarihsel başlangıç noktasıdır; güncel durumu yeniden doğrula. `SPEC_ONLY`, `CODED`, `TESTED`, `SIMULATOR_ONLY`, `DEVICE_VERIFIED`, `BLOCKED_EXTERNAL` ayrımını koru.

**ÜST ÜRÜN HEDEFİ:** Kabinsiz ana sayfası bir dashboard değil, **Home Studio** olsun: kullanıcı 360° döndürülebilen kendi 3D modelini şehir/hava bağlamlı sahnede bugünün kombinini giymiş halde görsün; üst, alt, ayakkabı, çanta, kemer ve aksesuarları tek tek değiştirebilsin; “Yeni Kombin Üret” ve “Live Mirror” birincil eylemler arasında bulunsun.

**PHOTO-TO-WARDROBE HEDEFİ:** `PhotosPicker` ile seçilen bir fotoğrafı **cihaz içinde** analiz et → giysi adayını göster → kullanıcı düzeltip onaylasın → `Wardrobe` ve `Vault`a güvenle kaydet. Ardından izinli batch, dedup, kategori/renk/desen, görsel kanıt sınırı, iptal/silme, ısı/bellek yönetimi ekle. Fotoğrafta görülen giysiyi otomatik “sahip” sayma.

**LIVE MIRROR HEDEFİ:** iOS üzerinde yerel kamera+gerçek zamanlı poz/3D giysi bindirme dikey akışını kur. Ürün tarama/katalog/URL ile ürünü seçebilsin; gerektiğinde 360° avatara dönsün. Fotogerçekçi bulut VTON, **ancak ayrı açık rıza, hak/lisans/maliyet ve cihaz testi sonrası** opsiyonel olarak eklenebilir. Bulut varsayılanı kapalı olacak. Render kalitesi, kumaşın gerçek oturuş kanıtı gibi sunulmayacak.

**ÇALIŞMA YÖNTEMİ:** `SPEC → THREAT MODEL → ADR/CONTRACT → CODE → TEST → PERF/PRIVACY → BAĞIMSIZ REVIEW → EVIDENCE → GATE`. İşleri DAG'a ayır, P0 ilk çalışan dikey dilimi koru. Mevcut çalışan kodu ve kullanıcı verilerini silme. Gerekli tüm ajan/skill/MCP'leri keşfet; lisans, güvenlik ve bakım doğrulaması olmadan rastgele MCP yükleme. Geliştirme için branch aç; main'e körlemesine commit/merge etme. Gereksiz 32 model çalıştırma: doğru görev ayrımı, Core ML ve Swift ile en düşük sürdürülebilir maliyeti seç.

**İLK SOMUT TESLİMAT:** 1) `docs/audit/V24_REPO_REALITY.md`; 2) çatışma ve bağımlılık haritası; 3) tasarım token'ları + Home Studio gerçek SwiftUI ekranı; 4) bir fotoğraf → kullanıcı onayı → şifreli dolap dikey akışı; 5) 360° avatar ve bir kıyafet swap'i; 6) Live Mirror izin + yerel kamera/deneme prototipi; 7) test/performans/mahremiyet/screenshot kanıtları. Başarısız veya dış izne bağlı konuları **dürüstçe BLOCKED** diye bildir. Fiziksel cihaz test edilmediyse `DEVICE_VERIFIED` kullanma.

**CEVAPLAMAN GEREKEN 8 SORU:**
1. Hangi gereksinim gerçekten çalışıyor; hangisi yalnız MD'de?
2. Gerçek ürün kataloğuna erişim ve ürün görseli hakları nasıl sağlanacak?
3. Kıyafet segmentation ve ürün kimliği için hangi ticari lisanslı cihaz içi model kullanılacak?
4. 360° avatarın kişinin ölçülerini yansıtması nasıl test edilecek?
5. Kamera+3D, kötü ışık ve hareket altında nasıl fallback gösterecek?
6. 3 saniyelik ürün önizleme hedefi hangi varsayımla sağlanabilir; p50/p95 nasıl ölçülecek?
7. Hangi veriler hiçbir zaman cihaz dışına çıkmayacak; bulut aynada açık rıza nasıl uygulanacak?
8. Ana sayfanın referans tasarımı ve gerçek ekran görüntüsü arasındaki farkları kim bağımsız onaylayacak?

**İLK YANITIN:** Zaman vaadi veya “hepsi tamam” iddiası değil; güncel repo kanıtı, bulunan 10 kritik engel, ilk P0 dikey dilim planı ve doğrudan çalıştırılan ilk test sonucu olsun. Sonra en yüksek öncelikli engeli kodla çözmeye devam et.

---

**Kullanım notu:** Bu bir komuttur; ChatGPT tarafından repoya commit atılmadı. Harici servis hesabı, ücretli API, marka sözleşmesi, fotoğraf verisinin dışarı aktarılması veya App Store yayını kullanıcının ayrıca onayını gerektirir.

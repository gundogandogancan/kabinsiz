# CLAUDE CODE — KABİNSİZ v2.7 UYGULAMAYA BAŞLA

**İşe bu komutu, ardından `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.7.md` dosyasını vererek başla.**

Mevcut `gundogandogancan/kabinsiz` reposunda çalış. Giriş verisi olarak paketteki 5 ekran görüntüsünü `screenshots/` içinden incele; `references/` altındaki yapay zekâ ile üretilmiş görseller yalnız **estetik hedef**tir, çalışan UI veya gerçek model kanıtı değildir.

## Görev

Kabinsiz'i **kullanıcının kişisel yüz/saç/body digital twin + fotoğraflarından tanınan 3D garment digital twin + günün canlı şehir/hava sahnesi + 360° giysi değişimi + barkod/web “Tara ve Dene” + gerçek Live Mirror** deneyimine dönüştür. Tek bir ürünü fotoğraftan görsel olarak 3D yapmakla üretici kalıbı/doğru fit için veri kanıtlamayı karıştırma.

### İlk yapılacaklar — programatik kanıtla

1. `git status`, HEAD/branch, Xcode, simulator/gerçek cihaz, Blender, mevcut kaynak testleri ve var olan ekran görüntülerini yaz. `CLAUDE.md`/v2.1/v2.2–v2.6/v2.7 belge çelişki matrisi ve ADR oluştur. **Working code'u silme/bozma.**
2. MobileBuildMCP'yi resmî sürümü ve çalışma yetkisiyle doğrula; iki `build`, `test`, `screenshot` kanıtı üret. Mevcut ekranların 5 baseline'ını incele; karşılaştırma raporu yaz.
3. Blender offline asset pipeline'ı deterministic `bpy` ile 3 sınıf (ceket, pantolon, ayakkabı) için **giyilebilir 3D garment mesh** üret, PBR/UV/LOD, rig, rights manifest + USDZ export + 360°/clipping testleri yap. Blender MCP Python execution riskini denetle; çok gerekli değilse hiç kurma.
4. Mevcut `BodyModel3DView` üstüne kıyafet giydirme/swap + geri alma + 360° çalıştır. Kullanıcıya benzeyen yüz/saç katmanını, izinli multi-view foto + yerel veri kasası + user-confirmed likeness olarak projelendir ve küçük gerçekçi ilk kanıtını uygula; nötr yüzü bitmiş sanma.
5. Seçilen kullanıcı fotoğraflarını **PhotosPicker + cihaz içi Vision/Core ML** ile işleyip kıyafet kes/öner/duplikasyon grupla/onayla/dolaba ekle. Sonra G1 yaklaşık 3D garment template ile avatar üstüne bağla; G2 için gerçek CAD/techpack/partner kanıtını ayrı beklet. İlk pilot kullanıcının izni olmadan yüz görseli gönderme.
6. `Home World`: İstanbul/Barcelona demo scene (özgün/lisanslı), hava kanıtına göre rain/wet/lighting, avatarın yüzü-saçı önde, 3D giydirilmiş kıyafet; kıyafete dokunup kategoriyi değiştir; `Yeni Kombin Üret` aynı 3D sahnede. UI `screenshots/03` ve `/04`'teki buton taşmasını ve modelin arkadan/oyuncak görünümünü düzelt.
7. `Tara` ve `Ayna` tek **TARA VE DENE**: barcode/GTIN/foto/link/wardrobe -> evidence/variant -> 3D Avatar / Local Live Camera alt görünümleri. Mevcut `LiveMirror` sözleşmesi ve Citadel gate kodunu yeniden kullan. **Cloud Decart kapalı**; DPA/terms/legal/cost onayı sonrası ancak ayrı test.
8. MobileBuildMCP ile gerçek Simulator ekranlarını al, cihazda FPS/termal/camera testleri yap, QA fail/abstain tablosu oluştur. `REAL_DEVICE_BLOCKED` ise bunu dürüstçe raporla.

### Durum ve yetki

- Her adım `CODED / UNIT_TESTED / SIMULATOR_VERIFIED / DEVICE_VERIFIED / HUMAN_VALIDATED / BLOCKED_EXTERNAL / UNKNOWN` olarak raporlanır.
- 32 runtime uzmanı, **32 paralel ağır model değil**; küçük işlevsel modül + Core ML paylaşımı + deterministik scheduler. Kullanıcının görüntüsü varsayılan olarak cihazdan çıkmaz.
- Bütün markaların bütün ürünlerini tek günde tanıdığına dair iddia yok; evrensel veri kontratı + gerçek, lisanslı partner pilotu var.
- Şirket adına sözleşme imzalama, hesap açma, ücretli servis kullanma, yüz veya kamera videosunu cloud'a yollama, marka/3D veri izni kabul etme; **insan onayını bekleyen kapı olarak raporla**.
- Her ekran için görsel kalite ve veri doğruluk testi; *screenshot yerine render edilmiş demo/mockup koymak* yasak.
- Birden çok iş paralel yürütülecekse bağımlılıkları ve branch çakışmalarını yönet.

### İlk yanıt formatı

```
HEAD SHA / branch / temiz mi?
Mevcut çalışan kod: kanıt yolu
İstenen vizyonla eksikler: P0/P1 + somut dosya
Mimari karar: Blender asset factory + SwiftUI/RealityKit/Metal runtime
Foto->3D doğruluk tier'i: G0/G1/G2/G3 ve kaynak
Gereken izinler/lisanslar: listesi, kim onaylayacak
İlk dikey slice: seçili foto->3D garment->360° avatar->swap
İlk commit/test/screenshot: gerçek dosya yolu ve exit code
Bloklananlar ve sıradaki en küçük iş
```

**Bunu yalnız planlayıp bırakma; ilk bağımlılığı hemen repo üzerinde doğrula ve kullanıcıya kanıtlı sonuç göster.**

# CLAUDE CODE — KABİNSİZ v3.5 DOĞRUDAN UYGULAMA EMRİ

Repo: `gundogandogancan/kabinsiz`. Bu paketin ana belgesini ve `.claude/skills` ile `.claude/agents` dosyalarını oku. Kullanıcının daha önce talep ettiği v3.4 katalog ve owned-VTON kararlarını koru. Hedef `Maximum Intelligence, Minimum Interface`.

**1. Önce gerçek repo denetimi (kod yazmadan):** `git status -sb`, `git log -5`, `git diff`, `CLAUDE.md`, `docs/audit/`, `docs/evidence/`, mevcut skill+agents ve son simülatör görüntüleri. Main SHA ile yerel branch farklarını çıkar; daha önce oluşturulmuş dosyayı ikinci defa yazma. `docs/audit/V35_REALITY_LOCK.md` ve `docs/audit/V35_REQUIREMENT_TRACE.md` üret. Fotoğraf/kamera/şehir/3D ürün/face/Live Mirror yolculuklarının her biri için `CODED | SIMULATOR_TESTED | DEVICE_VERIFIED | PARTNER_VERIFIED | BLOCKED_EXTERNAL | NOT_RUN` statüsü koy.

**2. Hak/lisans koruması:** Tüm 3D city, model ve katalog SDK'larını `docs/architecture/V35_LICENSE_GATE.md` içine yaz. OSM attribution, partner hakları, FASHN parser/NVIDIA, Mobile-VTON/CatVTON NC, fotoğraf rızası, Decart bulut sözleşmesi kapılarını açılmadan `BLOCKED` tut. Hiçbir sözleşme imzalama, ödeme başlatma veya izin olmadan video/görsel yükleme.

**3. İlk çalışan WP35-01..03:** Coarse konum → gerçek city ID → 3 kademeli city manifest/fallback; hava koşuluna göre güneş/yağmur/kar/rüzgar sahnesi; `TodayView` içindeki 3D model önünde buton duvarı olmadan sahne. İlk kareyi bloke etmeden asset hazırlığı. Yanlış şehir, izinsiz konum ve offline testleri.

**4. İkinci çalışan WP35-04..08:** Selfie onaylı yüz/saç digital twin (kimlik onayı), gerçek lisanslı 3D giysi, VisionKit gerçek barkod, exact GTIN/SKU, kullanıcı fotoğrafından lokal dolap, model üzerinde swap ve local live mirror. Her biri için gerçek iPhone ekran videosu / kare süresi / bellek ve test raporu.

**5. Sonraki WP35-09..13:** FASHN VTON 1.5 ayrı PoC; parser ve ağırlık lisansına göre kabul/red; iPhone generative canlı gerçeklik asla varsayılmasın. Marka partner portalı (read-only feed/webhook) ve uzman gözden geçirmesi. İkinci Octopus motoru oluşturma.

**Kurulacak/denetlenecek MCP'ler (önce gerçek varlığını sorgula):** `MobileBuildMCP` (getsentry), resmî Figma MCP (hesap/izin gerekir), sandboxed Blender MCP (`BLENDER_MCP_SAFE_MODE=1`, `DISABLE_TELEMETRY=true`), GitHub. OSM2World CLI ve CoreMLTools, gerekirse bağımsız test araçları. Onay olmadan bilinmeyen MCP, skiller veya OS komutları yükleme.

**Her tamamlanan WP için zorunlu sonuç:** değiştirilmiş dosyalar/commit, test komutu+exit code, gerçek cihaz modeli/iOS, ekran görüntüsü/video, p95/FPS/termal/bellek sonuçları, data rights, açık risk, sürüm farkı, kullanıcıya anlaşılır minimal arayüz; kanıt yoksa `not verified`.

**İlk cevabın:** yalnızca `Repo SHA / gerçek durum / WP35-00 net bulgular / ilk 2 yatay bağımlılık / uygulanacak ilk dikey iş` olsun. Sonsuz plan ve ajan listesi üretmek yerine çalışan kod + kanıt teslim et.

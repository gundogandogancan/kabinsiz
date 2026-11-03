# Claude Code — KABİNSİZ v2.6 DOĞRUDAN İŞ EMRİ

Bu iki dosyayı oku: `KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.6.md` ve `KABINSIZ_GOD_LEVEL_v2.6_TARA_VE_DENE_LIVE_MIRROR_COMMERCIAL_INTEGRATION.md`.

**Yeni ürün kararı:** “Tara” ve “Ayna” ayrı bölümler değil, aynı **DENE** akışının iki aşaması. Barkod/foto/link/dolap -> ürün kimliği/varyant doğrula -> aynı oturumla ön kameraya geç -> yerel 3D/gerçek video deneyimi -> beden ve dolap kararları. Kamera ve giysi gerçeği uydurma.

1. `main` SHA ve açık kodları doğrula; `TodayView`, `ScanView`, `RootView`, `MirrorSession`, `MirrorPolicy`, `FrameGuard`, `ConsentLedger`, `CitadelGate`, `EvidenceCoverageGate` ve UI testlerini kanıtlı denetle.
2. “Dene” birleşik bilgi mimarisi ADR'sini ve ProductIntake -> SelectionSession -> LocalMirror -> Decision state machine'i tasarla. Var olan kodu yeniden kullan.
3. ÇALIŞAN ilk dikey dilimi kodla: ürün seçimi, gerçek kamera izin yaşam döngüsü, barkod, alternatif giriş, doğrulanmış ürün kartı, asset varsa yerel önizleme, yerel/no-network mode. Kullanıcının bir kez seçtiği ürün oturumda kalacak.
4. Resmî MCP `claude mcp add decart-docs https://docs.platform.decart.ai/mcp --transport http` ve skill `npx skills add https://docs.platform.decart.ai -a claude-code` kurulumlarını **risk ve yetki gözden geçirmesi yaparak** değerlendir; eğer kullanıcı onayı gerekiyorsa dur. Güncel Swift SDK API uyumluluğunu araştır.
5. API Terms §2.3 ve §4.2'nin eğitim/gizlilik kullanım hakkı riski için `BLOCKED_EXTERNAL` aç. **Hesap açma/şart kabulü/sözleşme imzası/ödeme/gerçek video yükleme yapma**; imza yalnız şirket yetkilisinin ve gerektiğinde avukatın işi. Decart'tan no-training, retention, deletion, DPA/KVKK/GDPR ve data transfer şartları yazılı onaylanmadan cloud mod kapalı.
6. `DecartMirrorAdapter`'ı feature flag OFF ve fake token/provider ile test edebilirsin; ancak gerçek servise bağlanma. Gerçek prod için server token broker, kısa ömürlü model-scope token, session cap, günlük maliyet limiti; permanent key asla iOS binary'sine yazılmaz.
7. Simülatör/build/gerçek cihaz mümkün olduğunda kanıt; ekran görüntüsü, risk raporu, gerçek PASS/FAIL/BLOCKED ve sonraki WP. Bütün testler geçmeden “god level bitti” deme.

**İlk çıktı:** Repo gerçeği + bağımlılık DAG + çalışan birleşik Dene ekranı (veya engelin somut kanıtı) + test sonuçları + sözleşme/redline kontrol listesi.

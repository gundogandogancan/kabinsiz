# FASHN VTON 1.5 — L1 Mac PoC (ADR-017), 2026-11-04

Kullanıcı ağırlık indirmesini onayladı (2026-11-04). Sınıf: **RESEARCH_ONLY**. Hiçbir dosya uygulamaya girmez.

## Ne indirildi (SHA-256 Hugging Face'in yayımladığı değerle aynı)

| Dosya | Kaynak | Lisans | Boyut | SHA-256 |
|---|---|---|---|---|
| `model.safetensors` | `fashn-ai/fashn-vton-1.5` | Apache-2.0 | 1 943 668 048 B | `d6cd3828…c05bdd35a` |
| `dwpose/yolox_l.onnx` | `yzd-v/DWPose` (fashn-ai aynası ile bayt bayt aynı) | Apache-2.0 | 216 746 733 B | `7860ae79…97855a411` |
| `dwpose/dw-ll_ucoco_384.onnx` | `yzd-v/DWPose` | Apache-2.0 | 134 399 116 B | `724f4ff2…cd913b1843` |

- **İndirilmeyen:** FASHN insan ayrıştırıcısı. NVIDIA'nın ticari olmayan lisansıyla gelir ve BLOCKED durumdadır.
- **Konum:** Ağırlıklar `~/research/fashn-weights`, kod `~/research/fashn-vton-1.5` (commit `7c0f10a`). İkisi de repoda değil.
- **Ortam:** Ayrı bir venv, Blender'ın Python 3.13'üyle kuruldu. torch 2.15.0, onnxruntime 1.31.1 (CPU).
- **Kod incelemesi:**
  - ağ çağrısı yok;
  - `torch.load` yalnız `.pt` için var, biz `safetensors` kullanıyoruz;
  - `eval`, `exec` ve alt süreç yok.

## Ayrıştırıcısız çalıştırma

- `segmentation_free=True` ile düz serili (flat-lay) giysi verildiğinde FASHN ayrıştırıcının çıktısını hiç kullanmaz (`disable_masking` görüntüyü olduğu gibi döndürür).
- `tools/vton/stubs/fashn_human_parser` yalnız etiket adlarını sağlar ve ayrıştırıcıyı başlatmayı reddeder.
- `tools/vton/fashn_poc.py` ayrıştırıcıyı hiç yüklemez.
- **Apple MPS uyarlaması:** MPS float64 desteklemiyor. RoPE açıları CPU'da float64 ile hesaplanıp float32 olarak taşınıyor; upstream ile aynı matematik.

## Ölçümler (Apple M5 Mac, 16 GB, macOS 26.4, MPS, bf16, 576×864)

| Çalıştırma | Girdi | Adım | Üretim süresi | Adım başına | MPS bellek |
|---|---|---|---|---|---|
| A referans | FASHN örnek kişisi + örnek tişört | 30 | 289,7 s | 9,66 s | 6,09 GB |
| B | Kabinsiz 3B avatar ekran görüntüsü + Blender gömleği (OWNED_ORIGINAL) | 30 | 199,9 s | 6,66 s | 6,09 GB |
| B | aynı | 10 | 63,9 s | 6,39 s | 6,09 GB |

- Isınma (ilk MPS çekirdek derlemesi) süreye dahil değil.
- Model yükleme 9–18 s sürdü.
- Karşılaştırma: FASHN'ın H100 için verdiği süre yaklaşık 5 s/görüntü. M5'te bu 40–60 kat yavaş.

## Bulgular (dürüst)

1. **Gerçek insan fotoğrafında çalışıyor (A).**
   - Fotogerçekçi çıktı, giysi doğru aktarılıyor.
   - Tişört üzerindeki yazı bozuluyor (logo harfleri karışıyor).
   - A'nın çıktısı repoya konmadı, çünkü gerçek bir kişiyi gösteriyor.
2. **Bizim 3B mankenimizde amaçlanan işi yapmıyor (B).**
   - Görüntüyü fotogerçekçi yapmıyor: manken başı ve stil kalıyor.
   - Gömlek, altındaki paltonun uzun silüetini alıyor. `segmentation_free` mevcut giysi hacmini koruyor.
   - Düğme hattı ve cep gibi ayrıntılar kayboluyor.
   - Şehir arka planı değişiyor.
   - 10 adım ile 30 adım arasında gözle görülür fark yok.
3. **Canlı ayna için uygun değil.**
   - Mac GPU'da bile tek kare 64–290 s sürüyor.
   - iPhone'da 972M parametre ve 6 GB bellek ihtiyacıyla canlı (30 fps) çalışma mümkün değil.

## Karar etkisi (ADR-017 güncellemesi)

- **L0 (F1 yerel ayna) canlı katman olarak kalır.** Bu PoC bunu doğruluyor.
- **L1 "avatarımızı fotogerçekçi yap" yolu bu modelle yürümez.** Model, gerçek insan fotoğrafı için eğitilmiş.
  - FASHN'ın ürüne katkısı yalnız şu olabilir: rızalı mankenlerle kendi stüdyo görsellerimizi üretmek, ya da L3 damıtma için öğretmen çıktısı. İkisi de sunucu ya da Mac tarafında, kullanıcının fotoğrafı olmadan.
  - Kullanıcının kendi fotoğrafıyla deneme, cihazda bu modelle mümkün değil. Bulut ise kapalı (ADR-017).
- **L2 (cihazda Core ML) önceliği düştü.** 64 s/kare (Mac, 10 adım) ile iPhone'da makul bir hedef yok. Önce küçük bir öğrenci modeli (L3) gerekir.
- **Sonraki en verimli adım cihazda gerçekçilik:** 3B gövde ve giysi kabuğunun kendi malzeme/ışık kalitesi (V36-12), ve fotoğraftan kesip çıkarma ile giysi dokusu (V36-03).

## Dosyalar

| Dosya | İçerik |
|---|---|
| `input-avatar.jpg` | Kabinsiz ana sahne ekran görüntüsünden kırpılmış 3B figür (sentetik) |
| `input-shirt-flatlay.jpg` | Blender gömlek çizimi (OWNED_ORIGINAL) |
| `B-avatar-shirt-30.jpg`, `B-avatar-shirt-10.jpg` | FASHN çıktıları (araştırma; uygulamada gösterilmez) |

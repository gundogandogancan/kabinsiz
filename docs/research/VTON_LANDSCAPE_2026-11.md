# VTON ve 360° Avatar Teknoloji Haritası — Kasım 2026

**Tarih:** 2026-11-03 · **Durum:** `RESEARCH` (salt okuma; hiçbir şey klonlanmadı, indirilmedi, kurulmadı, çalıştırılmadı) · **Kapsam:** "Ayna ekranı" sanal prova (VTON) + 360° döndürülebilir kişisel avatar
**Yöntem:** GitHub REST API (`gh api`) ile README/LICENSE/kaynak dosyaları; Hugging Face API metadata (dosya listesi/boyut, lisans etiketi); resmî proje/makale/doküman sayfaları. Doğrulanamayan her şey **UNKNOWN** olarak işaretlendi. Kaba hesaplar **TAHMİN** olarak işaretlendi ve ölçüm değildir.
**Anayasa bağı:** `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md` (C bölümü G3/R17-ML-01, LM21-00…07). Bu belge oradaki kararları değiştirmez; kanıt ekler. (Not: `CLAUDE.md` hâlâ v1.5'i kanonik gösteriyor, ancak çalışma ağacında v1.5 dosyası `archive/`'e taşınmış ve v2.1 eklenmiş; bu tutarsızlık ayrıca çözülmeli.) Yeni ve önemli bulgu: FASHN boru hattındaki **insan ayrıştırıcı (human parser) ağırlıklarının ticari olmayan lisansı** (bkz. §1.4).

> Hukuki not: Aşağıdaki lisans yorumları mühendislik okumasıdır, hukuki görüş değildir. Ticari build'e herhangi bir model/ağırlık girmeden önce insan (hukuk) onayı gerekir.

---

## 0. Özet tablo — lisans hükümleri

| Bileşen | Kod lisansı | Ağırlık lisansı | Ticari kullanım | Cihaz içi (iPhone) durumu |
|---|---|---|---|---|
| FASHN VTON v1.5 çekirdek model | Apache-2.0 | Apache-2.0 (HF kartı) | **Evet** (çekirdek) | Kanıt yok; yalnız sunucu (H100) kanıtlı |
| FASHN boru hattı → `fashn-human-parser` | (repo "Other") | **NVIDIA Source Code License for SegFormer** | **Hayır** (yalnız araştırma/değerlendirme) | — |
| FASHN boru hattı → DWPose / YOLOX | Apache-2.0 | Apache-2.0 olarak beyan; eğitim verisi şartları UNKNOWN | Büyük olasılıkla evet (veri şartı UNKNOWN) | Küçük ONNX → Core ML olası, UNKNOWN |
| Mobile-VTON (CVPR 2026) | **CC BY-NC-SA 4.0** | **CC BY-NC-SA 4.0** | **Hayır** | iPhone'da test yok; yalnız Android NPU ~80 s |
| CatVTON / IDM-VTON / OOTDiffusion | CC BY-NC-SA 4.0 | CC BY-NC-SA 4.0 | **Hayır** | — |
| StableVITON / Any2AnyTryon | Lisans dosyası yok (GitHub: none) | UNKNOWN | **Hayır** (lisanssız = tüm haklar saklı) | — |
| Leffa | MIT (repo) | UNKNOWN | Ağırlıklar doğrulanmadan hayır | — |
| Decart Anywear / Lucy VTON | Swift SDK MIT | Model kapalı, yalnız bulut API | Yalnız ticari sözleşme + DPA ile | **Cihaz içi değil** (bulut akışı) |
| SMPL / SMPL-X | Akademik model lisansı | Akademik | **Hayır** (ticari lisans Meshcapade üzerinden, ücretli) | — |
| Meta MHR (Momentum Human Rig) | Apache-2.0 | Repo LICENSE Apache-2.0; ayrı indirilen asset şartları ayrıca teyit edilmeli | **Evet** (asset teyidi şartıyla) | Parametrik mesh, cihazda çalıştırılabilir (TAHMİN) |
| NAVER Anny | Apache-2.0 | MakeHuman/MPFB2 asset'leri CC0 1.0 | **Evet** | Parametrik mesh, cihazda çalıştırılabilir (TAHMİN) |
| Meta SAM 3D Body | SAM License | SAM License | Evet, kısıtlarla (ihracat/ITAR, dava fesih maddesi) | Sunucu ölçekli; iPhone UNKNOWN |
| LHM (Alibaba aigc3d) | Apache-2.0 | Apache-2.0 | **Dolaylı engel:** SMPL-X parametrelerine dayanıyor | 14–24 GB GPU; cihazda değil |

---

## 1. FASHN VTON v1.5

Kaynaklar: https://github.com/fashn-AI/fashn-vton-1.5 · https://fashn.ai/research/vton-1-5 · https://huggingface.co/fashn-ai/fashn-vton-1.5

### 1.1 Ne?
FASHN AI'ın (ticari VTON API şirketi) açık ağırlıklı, **maskesiz (segmentation-free), piksel uzayında** çalışan difüzyon tabanlı VTON modeli. Girdi: bir kişi fotoğrafı + bir giysi fotoğrafı (manken üstü veya flat-lay ürün çekimi) + kategori (`tops` | `bottoms` | `one-pieces`). Çıktı: kişinin o giysiyi giydiği **tek bir fotogerçekçi 2D görüntü** (1–4 örnek). Video/canlı akış veya 3D değil.

### 1.2 Mimari (kaynak koddan doğrulandı: `src/fashn_vton/tryon_mmdit.py`, `pipeline.py`)
- MMDiT (FLUX tarzı): `hidden_size=1280`, `n_heads=10`, **8 double-stream + 16 single-stream** blok, 4 patch-mixer bloğu, `patch_size=12`.
- **VAE yok**; RGB pikseller doğrudan 12×12 patch embedding ile tokenleştiriliyor. Kişi ve giysi akışları ortak dikkatte işleniyor.
- Poz koşullama: DWPose anahtar noktaları gri tek kanallı görüntü olarak girdiye ekleniyor.
- Örnekleme: rectified-flow Euler, varsayılan **30 adım**, CFG ölçeği 1.5 (son 1 adımda CFG atlanıyor) → yaklaşık 59 model ileri geçişi (CFG batch'li).
- Parametre: **972M** (proje sayfası; HF metadata "1.0B").
- Eğitim verisi: 18M maskeli prova çifti + 4M sentetik üçlü (proje sayfası). **Verinin kaynağı/hakları açıklanmamış → UNKNOWN.**

### 1.3 Çözünürlük, donanım, gecikme, boyut
- Giriş/çıkış: **576×864** (kodda `input_shape=(864, 576)`; sayfa bunu sınırlama olarak belirtiyor).
- Gecikme iddiası: **~5 s / görüntü, NVIDIA H100** (sayfa + HF kartı). ~8 GB VRAM (HF kartı). Ampere+ GPU'da bf16, diğerlerinde fp32.
- Ağırlık: `model.safetensors` = **1.943.668.048 bayt (~1,94 GB, bf16)** (HF API). Ek: DWPose ONNX (`yolox_l.onnx`, `dw-ll_ucoco_384.onnx`; boyut UNKNOWN), human parser ~244 MB (README). README toplamı "~2 GB" + parser.
- Python bağımlılıkları (`pyproject.toml`): torch≥2.0, torchvision, safetensors, huggingface_hub, pillow, numpy, opencv-python, einops, **onnxruntime-gpu**, matplotlib, **fashn-human-parser**. CUDA odaklı.
- Bilinen sınırlar (sayfa): 1K altı çözünürlük; beden özellikleri hafif kayabiliyor; maskesiz modda eski giysi tam silinmeyebiliyor (uzundan kısaya vb.).

### 1.4 Lisans — kritik bulgu
- **Kod:** Apache-2.0 (`LICENSE`, `pyproject.toml`). GitHub API "NOASSERTION" gösteriyor ama dosya standart Apache-2.0 metni ("Copyright 2025 FASHN AI").
- **Çekirdek ağırlıklar:** HF metadata `license: apache-2.0`; kart "released under the Apache-2.0 License" diyor; erişim kapısı (gating) yok. Proje sayfası "ilk izin verici (permissive) açık kaynak VTON modeli" ve "araştırma ve ticari kullanım" diyor. → **Çekirdek model ticari kullanıma açık.**
- **Ancak boru hattı temiz değil:** `pipeline.py` her çağrıda `FashnHumanParser.predict()`'i hem kişi hem giysi görüntüsü için çalıştırıyor (maskesiz modda bile). `fashn-human-parser` README'si ve HF metadata'sı: **"NVIDIA Source Code License for SegFormer"** (`license_name: nvidia-segformer`). Bu lisansın 3.3 maddesi: eser ve türevleri yalnız ticari olmayan amaçla, yani **"yalnız araştırma veya değerlendirme"** için kullanılabilir (https://github.com/NVlabs/SegFormer/blob/master/LICENSE). → **Hazır boru hattı haliyle ticari üründe kullanılamaz.** Ticari kullanım için parser'ın ticari-uygun bir segmentasyonla değiştirilmesi (ör. Apple Vision kişi segmentasyonu + kendi etiketli giysi segmentasyonu) ve modelin bu değişiklikle kalitesinin yeniden doğrulanması gerekir. Maskesiz + flat-lay modda parser çıktısının gerçekten kullanılıp kullanılmadığı (yani atlanabilir mi) **UNKNOWN** — `preprocessing/agnostic.py` ve `masks.py` satır satır incelenmeli.
- DWPose ve YOLOX: README'de Apache-2.0. DWPose ağırlıklarının eğitildiği veri setlerinin (COCO-WholeBody vb.) şartları **UNKNOWN**.
- Eğitim verisi hakları (18M çift) **UNKNOWN**; Apache-2.0 bu konuda güvence vermez.

### 1.5 iPhone'da cihaz içi çalışabilir mi?
- Upstream'de **hiçbir mobil/cihaz içi iddia yok** (sayfa ve README).
- **Core ML dönüşümü — teknik olarak makul ama kanıtsız:** Mimari standart Transformer blokları (LayerNorm, RMSNorm/QKNorm, RoPE, attention, MLP) ve konvolüsyonsuz patch embed; VAE olmaması avantaj. Apple'ın `ml-stable-diffusion` deposu SD3 MMDiT'i Core ML'e dönüştürme yolunu belgeliyor (https://github.com/apple/ml-stable-diffusion, "Using Stable Diffusion 3"), yani MMDiT → Core ML emsali var. FASHN için dönüşüm yapılmadı → **UNKNOWN**.
- **Bellek (TAHMİN):** fp16 ağırlık ~1,94 GB; 6-bit palettization ile ~0,75 GB; 4-bit ile ~0,5 GB. Aktivasyon: 576×864 / 12² = 3.456 token/görüntü, kişi+giysi ≈ 6.900 token ortak dikkat → dikkat matrisleri büyük; Neural Engine'de SPLIT_EINSUM tarzı yeniden yazım gerekir. 6–8 GB RAM'li iPhone'larda "increased memory limit" entitlement'ı ile sığabilir, ölçülmedi.
- **Gecikme (TAHMİN, ölçülmedi):** ileri geçiş başına ≈ 2·0,97e9·6.900 ≈ 13 TFLOP + dikkat ≈ 6 TFLOP ≈ ~19 TFLOP; 30 adım × CFG ≈ 59 geçiş ≈ ~1,1 PFLOP/görüntü. Gerçekçi 3–10 TFLOPS efektif iPhone hızıyla **~2–6 dakika/görüntü** mertebesi. Referans: Apple'ın kendi ölçümü SDXL-iOS 768×768'i iPhone 15 Pro Max'te ~31 s'de üretiyor (4-bit karışık palettization), SD 2.1 512×512 iPhone 14 Pro Max'te ~7,9 s. FASHN'ın 30 adım + CFG + 7k token ortak dikkat yükü bunların çok üstünde.
- Adım damıtma (ör. 4–8 adım) veya CFG damıtma gecikmeyi kabaca 4–15× düşürebilir ama **eğitim = sunucu GPU harcaması → insan onayı gerekir**; ayrıca eğitim verisi gerekir.
- **Hüküm:** Bugün için **yalnız sunucu tarafı** (kendi GPU'muz, rızalı yol). Cihaz içi = araştırma spike'ı (`ondevice-vton-benchmark`), canlı ayna için asla gerçek zamanlı değil (tek kare, dakikalar).

---

## 2. Mobile-VTON (tmllab, CVPR 2026)

Kaynaklar: https://github.com/tmllab/2026_CVPR_Mobile-VTON · https://arxiv.org/abs/2603.00947 (HTML: https://arxiv.org/html/2603.00947) · https://zhenchenwan.github.io/Mobile-VTON/ · https://huggingface.co/FlashStight/Mobile-VTON

### 2.1 Ne?
"High-Fidelity On-Device Virtual Try-On". Tek kullanıcı görüntüsü + tek giysi görüntüsü → 2D prova görüntüsü, tamamen çevrimdışı hedefli. Gizlilik motivasyonu açıkça belirtilmiş.

### 2.2 Mimari (makale)
- **TeacherNet–GarmentNet–TryonNet (TGT)** modüler yapı. Öğretmen: **Stable Diffusion 3.5 Large** tabanlı. Öğrenci: **SnapGen**'den uyarlanmış (yazarlar resmî kod olmadığı için yeniden yazmış).
- Feature-Guided Adversarial (FGA) distillation, GarmentNet için trajectory-consistency loss, TryonNet'te latent birleştirme + hafif çapraz-modal koşullama.
- **Metin kodlayıcı var:** CLIP-L + CLIP-G (çift). Görüntü kodlayıcı: DINOv2-base (Light-Adapter). VAE: paylaşılan encoder + SnapGen tabanlı hafif decoder.
- Repo kodu IP-Adapter tabanlı; diffusers 0.32.2 / transformers 4.42 / PyTorch 2.0.1 + **CUDA 11.8**, `accelerate` ile 4 süreçli GPU çıkarımı (`inference.sh`).

### 2.3 Çözünürlük, cihaz, gecikme, boyut
- Çözünürlük: **1024×768** (makale + `inference.sh`: 28 adım, guidance 2.5, bf16).
- Parametre: makale **"only 415M parameters"** / 0,41B. Bellek: tabloda **2,84 GB** "Usage (G)" (tepe cihaz belleği olduğu açıkça yazmıyor).
- **Test edilen cihaz:** yalnız **Xiaomi 17 Pro Max, Snapdragon 8 Gen 5, Qualcomm Hexagon NPU**, uçak modunda, **INT8**, **~80 saniye/görüntü** (makale Ek A). GarmentNet ve TryonNet NPU'da paralel; VAE encode CPU, decode NPU. Dağıtım çatısı (QNN/MNN/TFLite vb.) **belirtilmemiş → UNKNOWN**. Adım azaltma uygulanmadığı söyleniyor.
- **iPhone / Core ML:** makalede ve repoda **hiçbir iPhone testi veya Core ML yolu yok → UNKNOWN**.
- **Yayınlanan checkpoint gerçek boyutu (HF API):** denoiser 840 MB + denoiser_garment 759 MB + image_encoder 173 MB + text_encoder 247 MB + **text_encoder_2 1.389 MB** + vae 335 MB + vae_decoder 7,6 MB ≈ **3,75 GB** (diffusers formatı, muhtemelen fp32/fp16 karışık; dtype UNKNOWN). "415M" sayısı metin kodlayıcıları/VAE'yi dahil etmiyor gibi görünüyor → **UNKNOWN**, makale alt ağ dağılımı vermiyor.

### 2.4 Kod/ağırlık gerçekten yayınlandı mı?
- **Evet, çıkarım kodu + ağırlıklar yayınlandı** (repo Mart 2026'da; HF'de gating yok). **Eğitim kodu, damıtma kodu ve mobil dağıtım (NPU) kodu yok.** Repo yalnız VITON-HD/DressCode benchmark çıkarım betiği; `.pyc` ve `.DS_Store` dosyaları commit edilmiş (olgunluk sinyali zayıf). Son anlamlı commit 2026-03-27; 2026-08 yalnız README.

### 2.5 Lisans
- README: **"The codes and checkpoints in this repository are under the CC BY-NC-SA 4.0 license."** HF metadata: `cc-by-nc-sa-4.0`. GitHub API'de LICENSE dosyası yok (license: null).
- → **Ticari kullanım yasak** (NonCommercial) + ShareAlike. Kabinsiz ticari uygulamasına giremez (anayasa R17-ML-01 ile uyumlu).
- Ek zincir riskleri (yazarlardan ticari izin alınsa bile): öğretmen **SD 3.5 Large** (Stability AI Community License — türev/damıtma şartları ayrıca incelenmeli, UNKNOWN), eğitim/değerlendirme verisi **VITON-HD ve DressCode** (her ikisi de araştırma amaçlı/ticari olmayan veri setleri olarak bilinir; şartlar bu çalışmada ayrıca açılmadı → UNKNOWN), CLIP-G/CLIP-L ve DINOv2 ağırlıklarının kendi lisansları.
- **Hüküm:** Akademik referans ve mimari ilham (SnapGen-tarzı öğrenci, NPU paralel bölme) olarak değerli; kod/ağırlık **lisans-bloke**.

---

## 3. Diğer yaklaşımlar ve "AnyWear"

### 3.1 "AnyWear" / "Anywear" = Decart Anywear (bulut, gerçek zamanlı)
- **Ürün:** Decart'ın canlı sanal prova ürünü; Chrome eklentisi, Shopify/mağaza widget'ı, mobil web uygulaması. Beta süresince ücretsiz, hesap gerektirmiyor (https://anywear.decart.ai/live-virtual-try-on, https://anywear.decart.ai/virtual-try-on-for-shopify).
- **Model:** Decart **Lucy VTON** (video modeli). Doküman: `lucy-vton-latest` → **`lucy-vton-3.6`**; `lucy-vton-3.5` 720p'de hâlâ mevcut (https://docs.platform.decart.ai/models/realtime/virtual-try-on.md). Girdi: canlı kamera akışı veya MP4 + metin prompt + isteğe bağlı giysi referans görüntüsü. Çıktı: dönüştürülmüş video; batch 1280×720 vb.
- **İşlem yeri: bulut.** Kamera akışı `wss://api.decart.ai/v1/stream` (WebRTC oturumları) ile Decart sunucularına gider. **Cihaz içi seçenek yok.** Pazarlama sayfası "akış oturum boyunca var, görüntü olarak saklanmıyor" diyor; saklama/DPA ayrıntısı gizlilik politikasına havale → **UNKNOWN**.
- SDK'lar: JS, Python, Android, **Swift** (`DecartAI/decart-ios`, **MIT**). SDK lisansı modeli kullanma hakkı vermez; API şartları + ücret ayrı.
- Fiyat: Decart platformu "2 kredi / 1 s @720p"; fal.ai listesi **$0,02/s** (arama sonucu özeti; https://fal.ai/models/decart/lucy2-vton/realtime/playground). Anayasa LM21-01 aynı rakamları kaydetmiş. Fast mod 2× ücret (doküman).
- İsim karışıklığı: `anywear.pro` ayrı şirket (anayasa LM21-01 notu); "AnyTry", "AnyDress" WooCommerce eklentileri, akademik "Wear-Any-Way", "AnyFit", "Any2AnyTryon" ayrı işler.

### 3.2 Instagram reel (https://www.instagram.com/reel/DfMi-cDsECb/)
- Giriş yapılmadan kısmen görüntülenebildi (giriş yapılmadı). Hesap: `belek.asrar`; açıklama yalnız "Текнолоджия"; ~521 beğeni, 23 yorum; 2026-11-01 tarihli. Yorumcular aracın adını soruyor; görünen kısımda **araç adı yok**. Videonun içeriği (hangi ürün/model) metin olarak çıkarılamadı → **UNKNOWN**. Anywear ile bağlantısı **doğrulanamadı**.

### 3.3 Diğer açık VTON modelleri (2D görüntü, sunucu sınıfı)
| Model | Lisans | Not |
|---|---|---|
| CatVTON (ICLR 2025) https://github.com/Zheng-Chong/CatVTON | CC BY-NC-SA 4.0 (kod+checkpoint+demo) | 899M param, <8 GB VRAM @1024×768 (repo açıklaması) |
| IDM-VTON (ECCV 2024) https://github.com/yisol/IDM-VTON | CC BY-NC-SA 4.0 | SDXL tabanlı, ağır |
| OOTDiffusion https://github.com/levihsu/OOTDiffusion | CC BY-NC-SA 4.0 | — |
| StableVITON https://github.com/rlawjdghek/StableVITON | Lisans dosyası yok | Varsayılan tüm haklar saklı |
| Any2AnyTryon https://github.com/logn-2024/Any2anyTryon | Lisans dosyası yok | Temel model lisansı UNKNOWN |
| Leffa (CVPR 2025) https://github.com/franciszzj/Leffa | Kod MIT | Ağırlık/temel model lisansı UNKNOWN — doğrulanmadan kullanılamaz |

Sonuç: Açık VTON dünyasında **ticari olarak temiz tek ciddi aday FASHN VTON v1.5 çekirdeği** (parser değiştirilmek şartıyla).

### 3.4 360° avatar için parametrik beden modelleri
| Model | Lisans | Ticari | Not |
|---|---|---|---|
| SMPL https://smpl.is.tue.mpg.de/modellicense.html | SMPL-Model License (ticari olmayan bilimsel araştırma) | **Hayır**; ticari lisans Meshcapade / smpl@max-planck-innovation.de (ücretli → insan onayı) | Ekosistemin çoğu (LHM, birçok VTON/3D yöntem) buna bağımlı |
| SMPL-X https://smpl-x.is.tuebingen.mpg.de/modellicense.html | Akademik | **Hayır** (aynı yol) | Anayasa C bölümü zaten yasaklıyor |
| **Meta MHR** https://github.com/facebookresearch/MHR | **Apache-2.0** (repo LICENSE) | **Evet** (indirilen asset paketinin ayrı şartı varsa teyit edilmeli) | İskelet + skinned mesh, 7 LOD, beden blendshape'leri, poz düzelticiler, 72 yüz ifadesi; PyTorch/TorchScript. Cihazda: mesh + blendshape'ler RealityKit'e dışa aktarılabilir (TAHMİN); nöral poz düzeltici Core ML'e çevrilmeli veya devre dışı |
| **NAVER Anny** https://github.com/naver/anny | **Apache-2.0** kod; MakeHuman/MPFB2 asset'leri **CC0 1.0** | **Evet** | "Tüm yaşlar için serbest, yorumlanabilir" beden modeli; MakeHuman tabanlı olduğu için Blender boru hattıyla doğal uyumlu. Kabinsiz'in nötr gri, cinsiyet vurgusuz avatar kuralına en uygun aday |
| MakeHuman / MPFB2 (Blender) | Asset'ler CC0 (Anny lisans notu üzerinden) | **Evet** | Doğrudan Blender'da rig/morph → USDZ |
| Meta SAM 3D Body https://github.com/facebookresearch/sam-3d-body | **SAM License** (2025-11-19) | Evet, kısıtlı (ticaret kontrolü/ITAR, Meta'ya dava açılırsa fesih, tazminat) | Tek görüntüden MHR beden kestirimi; sunucu ölçekli; iPhone'a dönüşüm UNKNOWN. Beden fotoğrafı girdi olduğu için sunucuda koşarsa rıza yolu gerekir |
| LHM / LHM++ https://github.com/aigc3d/LHM | Apache-2.0 | **Dolaylı hayır**: SMPL-X parametrelerine dayanıyor | Tek görüntüden animasyonlu Gaussian insan; 14–24 GB GPU |

### 3.5 Apple yerel API'leri (lisans sorunu yok, cihaz içi)
- **Vision:** `VNDetectHumanBodyPoseRequest` (2D), `VNDetectHumanBodyPose3DRequest` (iOS 17+, 3D eklem), `VNGeneratePersonSegmentationRequest` (kişi maskesi). Ölçü motoru değildir (anayasa LM21-04 notu).
- **ARKit `ARBodyTrackingConfiguration`:** A12+; **arka kamera** ile çalışır, ön kamera desteklemez (Apple sayfası JS ile yüklendiği için metin çekilemedi; bu bilgi genel bilgi düzeyindedir → cihazda teyit edilmeli). Yani "selfie ayna" için ARKit gövde takibi değil, Vision 2D/3D poz + kendi rig retarget gerekir; arka kamera + tripod/ayna senaryosunda ARKit kullanılabilir.
- **RealityKit / Metal:** USDZ avatar + giysi mesh'i, parmakla 360° döndürme, LOD.
- **Core ML + coremltools palettization:** büyük difüzyon modellerinin iPhone'da koşma emsali (Apple ml-stable-diffusion, MIT): SD 2.1 512² ≈ 7,9 s (iPhone 14 Pro Max, 6-bit), SDXL-iOS 768² ≈ 31 s (iPhone 15 Pro Max, ~4-bit). Bu sayılar VTON'un da ancak "saniyeler–dakikalar"lık tek kare olabileceğini, canlı olamayacağını gösteriyor.

### 3.6 Gerçek zamanlı cihaz içi "generatif" VTON
- Kasım 2026 itibarıyla iPhone'da **gerçek zamanlı (≥24 fps) generatif VTON için açık, ticari-temiz, kanıtlı bir model bulunamadı.** Gerçek zamanlı ürünler ya bulut (Decart Lucy) ya da klasik AR mesh bindirme (Snap Camera Kit benzeri; ticari SDK sözleşmesi gerekir, bu çalışmada incelenmedi → UNKNOWN).

---

## 4. Kabinsiz için önerilen mimari (seçenekler ve takaslar)

Kısıtlar: çevrimdışı-öncelik; beden fotoğrafı/ölçüsü açık rıza olmadan cihazdan çıkmaz; ücretli harcama/hesap/sunucu GPU/model lisansı insan onayı; ticari olmayan (NC) lisanslı hiçbir şey ticari build'e girmez (R17-ML-01); generatif görüntü beden kanıtı değildir (R17-ML-02).

### Katman A — Şimdi cihazda gönderilebilir (lisans temiz, rıza gerektirmez)
1. **360° kişisel avatar:** **Anny (Apache-2.0 + CC0 asset)** veya **MHR (Apache-2.0)** tabanlı parametrik gövde → Blender'da çevrimdışı rig/morph/LOD → USDZ → RealityKit. Kullanıcı ölçüleri (cm) → şekil parametreleri yerelde, şifreli vault'ta. Nötr gri bodysuit, yüz/fotogerçeklik kapalı (anayasa avatar kuralları).
   - Takas: Anny = MakeHuman/Blender ile doğal uyum, tüm yaşlar, CC0 asset → en düşük lisans riski; MHR = daha zengin rig/poz düzeltici, Meta bakımında, ama nöral düzelticinin iPhone'a taşınması ek iş ve asset paketi şartlarının teyidi gerekir. SMPL/SMPL-X **seçilmemeli** (ücretli ticari lisans + bağımlılık kilidi).
2. **Yerel Canlı Ayna (LM21 "Local Live Mirror"):** AVFoundation ön kamera → Vision 2D/3D poz + kişi maskesi → rig retarget → lisanslı/üretilmiş USDZ giysi mesh'i → RealityKit/Metal kompozit. Gerçek zamanlı, veri dışarı çıkmaz.
   - Takas: Fotogerçekçi değil; kalite giysi asset'ine ve takibe bağlı; ön kamerada ARKit gövde takibi yok → kendi poz yumuşatma/retarget katmanı gerekir.
3. **Avatar üzerinde giysi:** her ürün için lisanslı CAD/3D veya elle üretilmiş USDZ; yoksa dürüst "2D referans / 3D hazır değil" etiketi (anayasa C §88).

### Katman B — Rızalı sunucu yolu gerektirir (ayrı açık rıza + sözleşme + maliyet onayı)
4. **Fotogerçekçi tek-kare "AI önizleme" (G3):** **FASHN VTON v1.5 çekirdeği**, Kabinsiz'in kendi kontrolündeki sunucu GPU'sunda (≈8 GB VRAM, H100'de ~5 s).
   - Önkoşullar: (a) `fashn-human-parser` (NVIDIA SegFormer NC lisansı) **çıkarılmalı veya ticari-uygun segmentasyonla değiştirilmeli** ve kalite yeniden ölçülmeli; (b) DWPose ağırlık veri şartları teyidi; (c) sunucu GPU harcaması + barındırma bölgesi + saklama/silme politikası insan onayı; (d) kullanıcı başına açık rıza, fotoğraf işleme sonrası silme, PrecisionFit'ten tamamen ayrı "görsel tahmin" etiketi.
   - Takas: Kendi sunucumuz = veri bizde kalır, üçüncü taraf işleyici yok, NC lisans yok; ama altyapı/ops maliyeti, KVKK sorumluluğu ve 576×864 çözünürlük sınırı bizde.
5. **Canlı generatif ayna (LM21 "AI Live Mirror"):** **Decart Lucy VTON** (bulut, WebRTC, Swift SDK MIT). Anayasa LM21'deki tüm kapılar: ayrı açık rıza ekranı, sağlayıcı sözleşmesi + DPA + saklama teyidi, oturum süre/maliyet tavanı (≈$0,02/s → 30 s ≈ $0,60), mikrofon kapalı, gerçek iPhone testi.
   - Takas: Tek gerçek zamanlı fotogerçekçi seçenek; ama üçüncü tarafa canlı yüz/beden videosu gider, internet ve oturum ücreti gerekir, kıyafet/logo/vücut biçimini değiştirebilir. Mevcut durumu `BLOCKED_EXTERNAL` (sözleşme yok).

### Katman C — Araştırma spike'ı (ticari build'e girmez)
6. **FASHN → Core ML fizibilite spike'ı:** yalnız çekirdek MMDiT, 6/4-bit palettization, Mac'te dönüşüm, iPhone 15 Pro/16 Pro'da tek kare süre + tepe bellek + termal ölçümü. Beklenti (TAHMİN): dakikalar mertebesi; damıtma olmadan ürünleşmez. Damıtma eğitimi = sunucu GPU harcaması → insan onayı.
7. **Mobile-VTON:** yalnız makale/mimari okuma; kod/ağırlık **CC BY-NC-SA → kullanılmaz**. Yazarlardan ticari lisans istenmesi düşünülürse SD 3.5 Large türev şartı ve VITON-HD/DressCode veri hakları da çözülmeli — düşük olasılıklı yol.

### Lisans-bloke (ticari build'e kesinlikle girmez)
Mobile-VTON, CatVTON, IDM-VTON, OOTDiffusion (CC BY-NC-SA 4.0); StableVITON, Any2AnyTryon (lisanssız); `fashn-human-parser` ağırlıkları (NVIDIA SegFormer NC); SMPL/SMPL-X (ücretli ticari lisans alınmadıkça); LHM (SMPL-X bağımlılığı nedeniyle); Leffa (ağırlık lisansı doğrulanana kadar).

### Önerilen sıra
A1 (Anny/MHR avatar) + A2 (yerel ayna) hemen; paralelde C6 ölçüm spike'ı; B4 için önce parser değişimi + hukuk onayı; B5 yalnız sözleşme/DPA/maliyet onayı sonrası. Hiçbir modda generatif çıktı beden kararına geri beslenmez.

---

## 5. Açık sorular / UNKNOWN listesi
- FASHN maskesiz + flat-lay modda human parser çıktısı gerçekten gerekli mi? (`preprocessing/agnostic.py`, `masks.py` incelemesi)
- FASHN eğitim verisi (18M çift) kaynağı ve hakları.
- DWPose ağırlıklarının eğitim verisi şartları.
- MHR indirilen asset paketinin (`mhr-download-assets`) ayrı lisans şartı var mı?
- Mobile-VTON "415M" sayısının kapsamı; NPU dağıtım çatısı; checkpoint dtype'ı; SD 3.5 Large türev şartları.
- Decart veri saklama/DPA/bölgesel barındırma; 18 yaş altı kullanım şartları.
- Instagram reel'deki aracın kimliği.
- ARKit gövde takibinin ön kamera desteği (Apple dokümanından metin olarak teyit edilemedi).

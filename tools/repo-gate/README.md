# Repo kapısı (V37-08)

Dış bir araştırma reposunu (VTON, poz, segmentasyon modeli …) bu Mac'te çalıştırmadan önce geçilen kapı. v3.4 kuralı: önce lisans ve güvenlik incelemesi, sonra çalıştırma. NC (ticari olmayan) lisanslı hiçbir şey uygulamaya giremez.

## Kullanım

```bash
tools/repo-gate/run_gated.sh --repo <git adresi ya da yerel yol> --workdir <çalışma klasörü> \
    [--ref <dal|etiket>] [--i-reviewed] [-- <komut> [argümanlar…]]
```

- `--` ile komut verilmezse **hiçbir şey çalıştırılmaz**. Yalnız klonlanır, taranır ve rapor yazılır.
- Rapor klonun yanına yazılır: `<workdir>/<ad>-<tarih>-<pid>.gate-report.txt`.
- `--workdir` olarak repo dışında bir yer seç (ör. `~/research-gate`). Kabinsiz reposunun içine klonlama.

## Adımlar

1. **Klon (çalıştırma yok).** Her seferinde yeni bir klasöre `--depth 1` ile klonlanır. Şunlar kapalıdır:
   - git hook'ları (`core.hooksPath=/dev/null`);
   - alt modüller;
   - LFS indirme/smudge filtreleri;
   - sembolik linkler;
   - `ext::` protokolü.
2. **Lisans.** Kökteki `LICENSE*`, `LICENCE*`, `COPYING*`, `NOTICE*` metninden SPDX tahmini yapılır (MIT, Apache-2.0, BSD, ISC, GPL/AGPL/LGPL, MPL …). Bu tahmin hukuki görüş değildir. Ardından lisans, README, model kartı, `requirements`, `setup.py` ve `pyproject` dosyalarında araştırma kısıtı aranır: "non-commercial", "CC BY-NC", "research purposes only", "academic use only", NVIDIA "Source Code License-NC", SMPL / SMPL-X / `smplx` / Max Planck, MANO, FLAME. Böyle bir iz bulunursa SPDX tahmini ne olursa olsun daha sıkı karar kazanır.
3. **Gizli anahtar taraması.** Taranan desenler:
   - AWS anahtarları;
   - özel anahtar blokları;
   - GitHub, GitLab, Slack, OpenAI, Anthropic, Google ve Hugging Face token'ları;
   - `api_key = "…"` ve `password = "…"` biçimindeki atamalar.

   Değerler çıktıda maskelenir: ilk 6 karakter ve uzunluk gösterilir.
4. **Kurulum betikleri ve kod çalıştıran dosyalar.** Bunlar insan incelemesi için listelenir:
   - `setup.py`, `pyproject.toml`, `requirements*.txt`, `Makefile`, `CMakeLists.txt`, `build.rs`, `Dockerfile`, `install*.sh`, `download*.sh`, `hubconf.py`, `.gitmodules`, `.gitattributes`;
   - yaşam döngüsü script'i olan `package.json` dosyaları;
   - pickle biçimli ağırlıklar (`.pt`, `.pth`, `.ckpt`, `.pkl`, `.bin`): yüklemek kod çalıştırır;
   - çalıştırılabilir dosyalar.
5. **Kum havuzunda çalıştırma.** Komut, `gate.sb` profiliyle `sandbox-exec` altında ve klon klasöründe çalışır. Profilin kuralları:
   - **ağ tamamen kapalı** (internet ve localhost);
   - **dışarıda bir şey başlatılamaz:** `open` (LaunchServices; tarayıcı ağ yasağını aşardı), `launchctl` ve launchd işleri, `osascript`, `security` (Keychain) ve pano kapalı;
   - **klon klasörü dışına yazma yok** (`/tmp` dahil), klonun `.git` klasörüne de yok: oraya konan `core.fsmonitor` ya da hook bir sonraki korumasız `git` komutunda çalışırdı;
   - **ev klasörünün tamamı okunamaz** (öteki repolar, kabuk geçmişi, token'lar, uygulama verileri, Keychain); yalnız klonun kendisi okunur;
   - **terminal yok:** komut stdin olarak `/dev/null`, çıktı olarak boru alır; `/dev/tty` ve `/dev/ttys*` kapalı (TIOCSTI ile kabuğuna komut yazamaz).

   2026-11-05 bağımsız inceleme (AG-12) sonrası sahte repoda denendi: `cat ~/.zshrc`, `ls ~/Projectkabinsiz`, `open -a Calculator`, `launchctl list`, `.git/config` yazma, `/tmp` yazma, `security`, `curl` ve `/dev/tty` reddedildi; `python3 betik.py` ve klon içine yazma çalıştı.

   Ortam `env -i` ile sıfırlanır, böylece hiçbir token komuta geçmez. `HOME` ve `TMPDIR` klonun içine taşınır. `PIP_NO_INDEX=1`, `HF_HUB_OFFLINE=1` ve `TRANSFORMERS_OFFLINE=1` ayarlanır.

## Kararlar

| Karar | Anlamı | Komut çalışır mı? |
|---|---|---|
| `RESEARCH_ONLY_NEVER_SHIP` | NC, yalnız araştırma ya da SMPL ailesi. İncelenebilir, uygulamaya **asla** giremez: kod, ağırlık ve çıktılar dahil. | Evet, kum havuzunda; uyarı basılır |
| `BLOCKED` | Lisans yok ya da tanınmadı. Kullanma hakkı belirsiz. | **Hayır** (çıkış 3) |
| `PERMISSIVE_REVIEW` | MIT, Apache-2.0, BSD, ISC, Unlicense, CC0. Çalıştırılabilir. Uygulamaya girmesi için yine de `docs/architecture/V35_LICENSE_GATE.md` incelemesi gerekir. | Evet |
| `COPYLEFT_REVIEW` | GPL, AGPL, LGPL ya da MPL. iOS uygulamasına girmesi hukuk incelemesi ister. | Evet |

3. ya da 4. adımda bulgu varsa komut ancak `--i-reviewed` ile çalışır (aksi halde çıkış 4). Bu bayrak "listelenen dosyaları okudum" demektir.

## Sınırlar (dürüstçe)

- `sandbox-exec` Apple tarafından "deprecated" olarak işaretli. macOS 26.4'te (Darwin 25.4) çalıştığı 2026-11-05'te doğrulandı. İleride kaldırılırsa bu kapı `BLOCKED` olur. Yerine VM ya da ayrı kullanıcı gerekir.
- Profil ev klasörü dışındaki sistem dosyalarını (ör. `/usr`, `/Library`) okumaya izin verir; araçların çalışması için gerekir. Ev klasöründeki dosyaların yalnız var olup olmadığı (metadata) görülebilir, içerikleri değil. Klon klasörü çalıştırılan kodun çıktısını taşır: paylaşma ya da push etme.
- Klonlama adımı ağı kullanır (git). Kum havuzu yalnız 5. adımdaki komutu kapsar.
- Lisans tespiti metin desenine dayanır. Model ağırlıklarının ayrı lisansı (Hugging Face kartı, Google Drive linki) repo içinde yazmıyorsa görülmez. Bu durumda insan incelemesi gerekir.
- Gizli anahtar taraması desen tabanlıdır. Kaçırabilir ya da yanlış alarm verebilir.
- Bağımlılık kurulumu (`pip install`) ağ kapalı olduğu için kum havuzunda çalışmaz. Bağımlılıklar önceden, incelenmiş tekerleklerle klonun içine konmalıdır. Bu bilinçli bir tercih.

## Kanıt (2026-11-05, yerel sahte repolarla, internetsiz)

Scratch alanında üç yerel git reposu oluşturuldu ve kapıdan geçirildi:

| Repo | Sonuç |
|---|---|
| MIT lisanslı (sahte `AKIA…` anahtarı ve `setup.py` ile) | `PERMISSIVE_REVIEW`; 2 gizli anahtar bulgusu (maskeli), 1 kurulum dosyası. `--i-reviewed` olmadan komut reddedildi. |
| Lisanssız | `BLOCKED`; komut çalıştırılmadı. |
| CC BY-NC | `RESEARCH_ONLY_NEVER_SHIP`. Kum havuzundaki komutun sonuçları: |

CC BY-NC reposunda kum havuzundaki komutun sonuçları:
- `python3 main.py` çalıştı.
- Klon içine yazma başarılı oldu.
- `curl http://127.0.0.1:18765` (kapı dışında aynı anda çalışan yerel sunucu; kontrol isteği başarılıydı): `exit=7 Couldn't connect`.
- `curl https://example.com`: `exit=6`.
- Klon dışına ve `/tmp`'ye yazma: `Operation not permitted`.
- `~/.ssh` okuma: `Operation not permitted`.
- Ortamda token yok.

Ayrıntılı çıktı V37-08 raporunda.

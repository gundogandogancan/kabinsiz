# Reality Baseline v1.5 (WP15-01, §133 adım 2)

Tarih: 2026-11-03. Yalnız bu oturumda komutla görülen değerler. Görülmeyen her şey `UNKNOWN`.

| Konu | Değer | Nasıl görüldü |
|---|---|---|
| Mac | Apple M5, 16 GB, macOS 26.4 (25E246), arm64 | `sw_vers`, `sysctl` |
| Disk | 13 GB boş (460 GB) | `df -h /` |
| Xcode / Swift | Xcode 26.6 (17F113), Swift 6.3.3 | `xcodebuild -version` |
| XcodeGen | 2.42.0, `~/.local/bin` | `--version` |
| Blender | 5.2.3 LTS, `~/Applications/Blender.app`. SHA-256 resmi dosyayla eşleşti, Blender Foundation imzalı ve notarize | `shasum -c`, `spctl` |
| gh | `~/.local/bin/gh` var (önceki notlarda yok yazıyordu) | `command -v` |
| brew, docker, uv | yok | `command -v` |
| Simülatör | iPhone 17, iOS 26.5 açık; 26.4 runtime'ları da var | `simctl` |
| Fiziksel cihaz | iPhone 16 Pro, 14 Pro Max, 13 Pro Max: hepsi `unavailable` | `devicectl list devices` |
| İmza | 2 geçerli kimlik; ücretli Individual takım `47XQMQZLF6` Xcode'da oturum açık | `security find-identity`, Xcode tercihleri |
| Apple hesabı | **Program License Agreement güncellemesi kabul edilmemiş**: provisioning reddediliyor | `xcodebuild -allowProvisioningUpdates` hatası |
| Repo | `main`, `origin` = github.com/gundogandogancan/kabinsiz (SSH) | `git` |
| Testler | 101 paket testi + 2 UI testi geçiyor (SIMULATOR_ONLY) | `scripts/check.sh` |

## Engeller

- `REAL_DEVICE_BLOCKED`: üç iPhone da bağlı değil.
- `BLOCKED_EXTERNAL`: WeatherKit. Kod ve entitlement hazır; Apple, PLA kabul edilmeden App ID / profil oluşturmuyor. Kabulü yalnız hesap sahibi yapabilir.
- Blender artık var: WP15-07 aracı açıldı.

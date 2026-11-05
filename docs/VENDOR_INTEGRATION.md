# Vendor repo entegrasyonu — 2026-11-03

10 repo `vendor/` altına `--depth 1` ile klonlandı. `vendor/` git'e girmez (~430 MB); kaynak olarak kalır. Projede yalnız Kabinsiz'e (iOS-first, offline, gizlilik odaklı) yarayan parçalar kullanılıyor.

| Repo | Commit | Ne | Kabinsiz'de kullanım |
|---|---|---|---|
| obra/superpowers | 2ce8aa1 | TDD, planlama, debugging, verification metodolojisi | **Global kurulu** (15/15 skill). Anayasadaki SPEC→TEST→EVIDENCE döngüsünün iskeleti. |
| OthmanAdi/planning-with-files | b6580cd | Dosya tabanlı plan/ilerleme | **Global kurulu.** Uzun iş paketlerinde `task_plan.md` ve `progress.md`. |
| pbakaus/impeccable | 6f269c4 | Tasarım kelime dağarcığı, critique/audit, slop dedektörü | **Global kurulu.** SwiftUI ekranlarının tasarım review'u. |
| nextlevelbuilder/ui-ux-pro-max-skill | 713eef5 | UI stilleri, renk/tipografi veritabanı | **Global kurulu** (7 skill). Görsel dil ve token seçimi. |
| plugin87/ux-ui-agent-skills | def84a7 | Tasarım doktrini, 52 gate, DTCG token, a11y | **Global kurulu** (25 skill). Anayasa §4.3 token sözleşmesi ve §4.8 tasarım kapısı. |
| muratcankoylan/Agent-Skills-for-Context-Engineering | 9ff0c99 | Context ve harness mühendisliği | **Global kurulu** (18 skill). §28 Octopus Cognition (yerel uzman modüller + tek beyin) tasarımında referans. |
| trailofbits/skills | 711af09 | Güvenlik analizi ve test | 15 skill global kurulu. **Projeye eklendi:** `spec-to-code-compliance` (REQ→kod izlenebilirliği), `differential-review`, `sharp-edges`, `audit-context-building`. Blockchain, fuzzing ve C/Rust odaklı olanlar alınmadı. |
| kylezantos/design-motion-principles | 4a9ca87 | Hareket/etkileşim tasarımı (create + audit), Emil Kowalski / Jakub Krehel / Jhey Tompkins bakışları | **Projeye eklendi** (`.claude/skills/design-motion-principles`, MIT, LICENSE dosyasıyla). Yalnız markdown; çalıştırılabilir kod yok. Kullanıcının "doğallık, canlılık, elitlik" hedefi için SwiftUI hareket kararlarında referans (D-015). |
| affaan-m/ECC | b38be6a | 1000+ skill, ajan harness'ı | **Projeye eklendi:** `swiftui-patterns`, `swift-concurrency-6-2`, `swift-actor-persistence`, `swift-protocol-di-testing`, `ios-icon-gen`. Harness, hook ve diğer diller alınmadı; global ayarları değiştirir ve kapsam dışı. |
| msitarzewski/agency-agents | b37b5bb | 330 ajan persona | **Projeye 20 ajan eklendi** (`.claude/agents/`). Eşleme CLAUDE.md'de. `name` alanı Claude Code uyumu için dosya adına çevrildi. |
| naver/anny | 8f35dc2 | Parametrik insan gövde modeli (PyTorch), MakeHuman tabanlı | **Fırınlama girdisi (2026-11-04, ADR-010; şablonlar 2026-11-05, ADR-011).** Kod Apache-2.0, `data/mpfb2` CC0. Uygulamaya yalnız `scripts/avatar/bake_sculpted_body.py --template {neutral,female,male}` çıktısı girer (`BodyGeometry/Resources/SculptedBody-*.*` + `NOTICE.md`); Anny/PyTorch uygulamada çalışmaz. Venv `vendor/.venv-anny` (Python 3.13, torch, scipy), önbellek `vendor/.anny-cache`. Ticari olmayan `smplx`/`smpl` topolojileri **kullanılmadı**. Repodaki `CLAUDE.md`/`AGENTS.md` talimat olarak değil, belge olarak okundu. |
| ANSUR II (ABD Ordusu NSRDEC, 2012) | indirme 2026-11-05; sha256 kadın `ed7e800a…`, erkek `0547aea0…`, MFR `0b7f419b…` | Antropometri veri seti (kadın 1986, erkek 4082 kişi), "UNLIMITED PUBLIC RELEASE" | **Uydurma girdisi (ADR-011, kullanıcı onayı "İndir, kullan").** `vendor/ansur2/` altında; `tools.openlab.psu.edu/publicData/` adresinden indirildi. Yalnız `scripts/avatar/fit_ansur_estimate.py` okur ve yalnız boy, kilo ve dört ölçü sütununu kullanır (ırk, etnik köken ve diğer demografik sütunlar okunmaz). Uygulamaya yalnız katsayılar girer (`BodyGeometry/AnthropometricEstimate.swift`); CSV uygulamada yok. |
| matank001/clodfarm | 2c839ec | Çoklu Claude "çiftliği" (Python sunucu, Docker/AWS) | **Kullanılmadı.** Docker yok, AWS ve dış hesap gerektiriyor; anayasa §17.1 "15 ajanı sürekli paralel koşturma" ve maliyet kuralıyla çelişiyor. Gerekirse ayrı onayla değerlendirilir. |

## Güvenlik notu

- Kopyalanan skill'ler komut taraması yapıldı.
- `ios-icon-gen/scripts/iconify_gen.sh` yalnız `api.iconify.design` adresine curl atıyor. Bu bir dış ağ çağrısı; kullanıldığında gizlilik egress envanterine yazılmalı.
- `sharp-edges` içindeki tehlikeli komut eşleşmeleri sadece referans dokümanlardaki örnekler.
- Hiçbir hook kurulmadı.

## Güncelleme

```bash
cd vendor/<repo> && git pull --depth 1
```

Sonra ilgili klasörü `.claude/skills/` veya `.claude/agents/` altına yeniden kopyala ve farkı review et.

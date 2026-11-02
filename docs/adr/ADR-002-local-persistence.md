# ADR-002 — Yerel kalıcılık: sürümlü Codable JSON, actor üzerinden

- Durum: KABUL (P0 için) · 2026-11-03 · Anayasa §3.1 ADR-006, §47 Storage, §68

## Karar

P0'da SwiftData yerine her kayıt türü için ayrı dosya: `Application Support/Kabinsiz/<collection>.json`.

- `Envelope { schemaVersion, savedAt, payload }` ile sürümlenir.
- `LocalStore` actor'ü yazmaları sıraya koyar. Yazma atomik (`.atomic`), iOS'ta `completeFileProtectionUntilFirstUserAuthentication`.
- Bilinmeyen daha yeni `schemaVersion` **okunmaz** (fail closed, veri silinmez). Daha eski sürüm migration fonksiyonundan geçer.
- Hava önbelleği seyahat planından ayrı dosyada. Seyahat silinince ikisi de temizlenir (§47).
- iCloud ve sync yok.

## Gerekçe

- macOS `swift test` ile tamamen test edilebilir (SwiftData model container testleri simulator ister).
- Veri hacmi küçük: 500 giysi ve 14 günlük seyahat birkaç yüz KB.
- Migration davranışı açık ve test edilebilir.

## Ne zaman yeniden değerlendirilir

Dolap 5.000 öğeyi geçerse, fotoğraf meta verileri gelirse veya sorgu ihtiyacı doğarsa SQLite/SwiftData POC yapılır (ADR-006 orijinal metni).

## Geri alma

Depo protokol arkasında (`TripRepository`, `FitPassportRepository`). Implementasyon değiştirilebilir.

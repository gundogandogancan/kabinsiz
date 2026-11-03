# ADR-006 — Kanon v2.1 ve öncelik zinciri

- Durum: KABUL · 2026-11-03 · V19-17 (canon ADR), V21-01 · Kullanıcı kararı: "sıraya al" (D-014)

## Karar

- Kanonik metin `docs/constitution/KABINSIZ_GOD_LEVEL_CLAUDE_MASTER_EXECUTION_CONSTITUTION_v2.1.md`. İçeriği v1.5 + v1.6..v2.1 ekleri; yalnız başlık ve ayraç satırları farklı. Bu, satır bazlı difflib ile doğrulandı (`docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md` §1).
- Öncelik sırası: hukuk/KVKK/platform → kullanıcı rızası ve yerel-öncelikli mahremiyet → güvenlik/kanıt ve v1.9 fail-closed → v2.1 LM21 (yalnız canlı ayna konularında) → v2.0 UI → v1.8 → v1.7 → v1.6 → v1.5 → kanıtlı repo durumu → eski ADR.
- Daha sıkı güvenlik kuralı her zaman kazanır. Daha zayıf bir yeni kural, eski bir güvenlik kontrolünü ancak bu dosyadaki gibi bir ADR ile ve gerekçesi yazılarak gevşetebilir.
- İş sırası `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md`. WP15-01..05 TESTED; v1.6–v1.9 eklerinin eski commit'e (`77e00ff`) dayanan "vault yok / egress yalnız beyan" bulguları geçersizdir (WP15-03/04 kapattı).

## Neden

Altı ek ve beş ana metin aynı ürünü farklı açılardan büyütüyor; tek bir kanon ve tek bir öncelik zinciri olmadan her iş paketi farklı bir belgeye göre "bitmiş" sayılabilirdi.

## Sonuç

- `CLAUDE.md` ve `DECISION_REGISTER.md` (D-014) bu kanona işaret eder; D-004 yerini D-014'e bıraktı.
- Eski V15 haritası yalnız geçmiş içindir.

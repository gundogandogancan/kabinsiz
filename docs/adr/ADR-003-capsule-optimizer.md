# ADR-003 — Kapsül valiz optimizer: deterministik iki aşama + brute-force referansı

- Durum: KABUL · 2026-11-03 · Anayasa §45.2, §53.1, T-TRV-042/043/044/046/047/056

## Karar

1. **Aday üretimi** (`OutfitCandidateGenerator`): her slot (gün × etkinlik) için sahip olunan giysilerden kombinler kurulur (üst+alt veya elbise, ayakkabı, gerekirse dış katman). Kesin kurallar: formalite, durum (`IN_LAUNDRY`/`UNAVAILABLE` hariç), hava evidence'ı varsa katman ihtiyacı, yürüyüşte rahat ayakkabı. Her aday `why` sebepleri ve `gaps` taşır.
2. **Kapsül seçimi** (`CapsuleOptimizer`): lexicographic hedefler.
   (a) her zorunlu slot kapsanır, kapsanamayan slot **gizlenmez**, `uncoveredSlots` listesine girer;
   (b) kilitli kombinler korunur;
   (c) tekrar giyim sınırları (kategori başına, kullanıcı ayarı) aşılmaz;
   (d) toplam benzersiz parça sayısı minimize edilir; `LIGHT ↔ VARIETY` tercihi eşitlik bozmayı değiştirir;
   (e) yeniden kullanım ve renk uyumu eşitlik bozucu.
   Algoritma: kilitler sabitlenir → slotlar en az adaylı önce sırayla greedy seçim (zaten paketlenmiş parçaya bonus) → yerel onarım (bir slotu değiştirip benzersiz parça azalıyorsa kabul). Tüm sıralamalar ID ile kararlı.
3. **Referans** (`BruteForceCapsuleSolver`): küçük fixture'larda (≤ 6 slot, slot başına ≤ 6 aday) tüm kombinasyonları dener. Test, greedy sonucun optimal benzersiz parça sayısına eşit olduğunu doğrular (T-TRV-043).

## Bilinmeyenler

- Ağırlık bilinmiyorsa 0 sayılmaz. Toplam ağırlık yalnız tüm parçaların ağırlığı biliniyorsa verilir, yoksa `nil` ve "bilinmiyor" (T-TRV-053).
- Çorap ve iç çamaşırı adedi kullanıcı ayarı (varsayılan gün sayısı, çamaşır yoksa).

## Neden ILP/solver değil

Bağımlılık yok, cihazda deterministik, açıklanabilir. Brute-force karşılaştırması optimalite kaybını ölçmeye yetiyor. Performans hedefi (§49.2: 100 giysi/5 gün, p95 ≤ 2 sn, sıcak) önce macOS'ta ölçülür, sonra cihazda (`BLOCKED_DEVICE`).

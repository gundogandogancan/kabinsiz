# ADR-005 — Fit Passport: kapsamlı, açıklanabilir kural tablosu (model yok)

- Durum: KABUL · 2026-11-03 · Anayasa §61.3, T-V13-011..020

## Karar

- `FitObservation` yalnız cihazda saklanır. Hiçbir ağ DTO'sunda alan olarak yer almaz.
- Beden ipucu yalnız **aynı marka + aynı kategori** gözlemlerinden türetilir. Farklı kategori veya marka için ipucu üretilmez (T-V13-013/014).
- Ürün `catalogRevision` değeri gözlemdekinden farklıysa ipucu "eski kalıp" diye işaretlenir ve abstain eder (T-V13-015).
- En az **2** tutarlı gözlem olmadan "olası beden" denmez. Tek gözlemde yalnız "Daha önce M aldın: tam oldu" gibi geçmiş gösterilir. Yüzde/olasılık sayısı hiç üretilmez (T-V13-019).
- Gözlem düzenlenebilir ve silinebilir. Türetilmiş ipucu her seferinde gözlemlerden yeniden hesaplanır, önbellek yok. Böylece silinen kayıt çıkarımı da geri alır (T-V13-016/017).
- Beden tablosu (sentetik) varsa ve kullanıcı ölçü girdiyse tablo eşlemesi ayrı kaynak olarak gösterilir. Yoksa abstain (T-V13-006).

## Neden

Core ML updatable gerekmez (§61.3). Kural tablosu açıklanabilir, test edilebilir ve geri alınabilir.

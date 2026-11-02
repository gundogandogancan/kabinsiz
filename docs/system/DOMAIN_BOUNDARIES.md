# Domain sahiplik matrisi (§102.3, §106.1, §133.3)

Her domain'in tek bir kanonik sahibi var. "Kod" sütunu bugün gerçekten var olan tipi gösterir; boşsa o domain henüz `SPEC_ONLY`.

| Domain | Kanonik kaynak | Sahip modül | Veri sınıfı | Kod (bugün) | Yazabilen | Çıkabilir mi? |
|---|---|---|---|---|---|---|
| Vücut ölçüleri | Kullanıcının girdiği / onayladığı değerler | OCT-07 Body Geometry | LOCAL_SENSITIVE | `FitPassport.UserMeasurements` (göğüs/bel) | Kullanıcı (MyModelView) | Hayır |
| Avatar geometrisi | Ölçülerin deterministik dönüşümü | OCT-07 → OCT-08 okur | LOCAL_SENSITIVE | — (WP15-07/08) | Yalnız OCT-07 | Hayır |
| Dolap | Kullanıcının onayladığı parça | OCT-18 Wardrobe Steward | LOCAL_PRIVATE | `WardrobeDomain.Wardrobe` | Kullanıcı | Hayır |
| Seyahat | Kullanıcının oluşturduğu seyahat | OCT-19 Capsule Travel | LOCAL_PRIVATE | `TravelEngine.Trip`, `TripPlan`, `PackingList` | Kullanıcı, planlayıcı | Yalnız şehir merkezi → hava, açık dokunuşla |
| Hava | Zaman damgalı sağlayıcı | OCT-16 Weather Context | PUBLIC (veri) / LOCAL_PRIVATE (istek) | `WeatherSnapshot`, `AppleWeatherProvider` | Sağlayıcı | İstek: bkz. EGRESS_REGISTER |
| Ürün kimliği | Doğrulanmış GTIN + varyant | OCT-09 Product Identifier | PUBLIC_PRODUCT | `ShoppingCopilot.ProductResolver` (sentetik katalog) | Katalog | Henüz ağ yok |
| Ürün ölçüsü / beden tablosu | Lisanslı üretici verisi | OCT-10 | PUBLIC_PRODUCT | `SizeChart` (sentetik) → `EvidenceRecord` | Katalog | — |
| Fit geçmişi | Kullanıcının deneme kayıtları | OCT-12 okur, OCT-20 yazar | LOCAL_SENSITIVE | `FitPassport` | Kullanıcı | Hayır |
| Rıza / izin | Rıza defteri | OCT-02 Consent Guardian | LOCAL_PRIVATE | — (WP15-03) | Kullanıcı | Hayır |
| Cihaz kaynağı | OS sinyalleri | OCT-03 Device Governor | REDACTED_DIAGNOSTIC | `DeviceBudget` (tablo; governor WP15-06) | OS | Hayır |
| Kanıt / köken | Lisanslı kaynak kaydı | OCT-21 | PUBLIC_PRODUCT | `EvidenceRecord` | Katalog | — |

Kurallar: render `AvatarSnapshot` tüketir, ölçü yazamaz. Hiçbir modül tüm veritabanını görmez; yetkiler `ModuleRegistry.p0Descriptors` içinde.

# Renk kontrast raporu (UI20-WP02, ADR-009)

Üretildi: `DesignTokensTests` (`REGENERATE_DESIGN_REPORT=1 swift test --filter DesignTokensTests`). Elle düzenlemeyin; test bu dosyayı koddan yeniden üretip karşılaştırır.

Hesap: WCAG 2.x göreli parlaklık, düz (opak) zemin. Saydamlık, fotoğraf üzeri metin ve sistem malzemeleri (Liquid Glass) bu tabloya dahil değildir; bunlar cihazda ölçülür (UI20-T-003, cihaz BLOCKED).

Eşikler: metin 4.5:1 (Increase Contrast'ta 7:1), metin dışı öğe 3:1 (Increase Contrast'ta 4.5:1).

## light

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #26221E | `canvas.primary` #F8F6F1 | text | 14.62 | 4.50 | PASS |
| `text.primary` #26221E | `surface.primary` #FFFCF8 | text | 15.44 | 4.50 | PASS |
| `text.primary` #26221E | `surface.secondary` #F0EAE2 | text | 13.21 | 4.50 | PASS |
| `text.primary` #26221E | `surface.sand` #E8DED1 | text | 11.88 | 4.50 | PASS |
| `text.secondary` #5C544C | `canvas.primary` #F8F6F1 | text | 6.88 | 4.50 | PASS |
| `text.secondary` #5C544C | `surface.primary` #FFFCF8 | text | 7.26 | 4.50 | PASS |
| `text.secondary` #5C544C | `surface.secondary` #F0EAE2 | text | 6.21 | 4.50 | PASS |
| `brand.primary` #654632 | `canvas.primary` #F8F6F1 | text | 7.85 | 4.50 | PASS |
| `brand.primary` #654632 | `surface.primary` #FFFCF8 | text | 8.29 | 4.50 | PASS |
| `on.brand` #FFFCF8 | `brand.primary` #654632 | text | 8.29 | 4.50 | PASS |
| `accent.copper` #9C6048 | `canvas.primary` #F8F6F1 | text | 4.65 | 4.50 | PASS |
| `accent.copper` #9C6048 | `surface.primary` #FFFCF8 | text | 4.91 | 4.50 | PASS |
| `brand.secondary` #62684B | `canvas.primary` #F8F6F1 | text | 5.40 | 4.50 | PASS |
| `status.success` #35694B | `canvas.primary` #F8F6F1 | text | 5.94 | 4.50 | PASS |
| `status.success` #35694B | `surface.primary` #FFFCF8 | text | 6.27 | 4.50 | PASS |
| `status.warning` #825A1C | `canvas.primary` #F8F6F1 | text | 5.67 | 4.50 | PASS |
| `status.warning` #825A1C | `surface.primary` #FFFCF8 | text | 5.99 | 4.50 | PASS |
| `status.danger` #9E3B3D | `canvas.primary` #F8F6F1 | text | 6.18 | 4.50 | PASS |
| `status.danger` #9E3B3D | `surface.primary` #FFFCF8 | text | 6.52 | 4.50 | PASS |
| `border.control` #8C8174 | `canvas.primary` #F8F6F1 | nonText | 3.53 | 3.00 | PASS |
| `border.control` #8C8174 | `surface.primary` #FFFCF8 | nonText | 3.73 | 3.00 | PASS |
| `brand.primary` #654632 | `canvas.primary` #F8F6F1 | nonText | 7.85 | 3.00 | PASS |
| `brand.primary` #654632 | `surface.primary` #FFFCF8 | nonText | 8.29 | 3.00 | PASS |

## dark

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #F6F0E7 | `canvas.primary` #151411 | text | 16.26 | 4.50 | PASS |
| `text.primary` #F6F0E7 | `surface.primary` #201D19 | text | 14.81 | 4.50 | PASS |
| `text.primary` #F6F0E7 | `surface.secondary` #2A251F | text | 13.40 | 4.50 | PASS |
| `text.primary` #F6F0E7 | `surface.sand` #332D26 | text | 12.00 | 4.50 | PASS |
| `text.secondary` #C4B9AC | `canvas.primary` #151411 | text | 9.55 | 4.50 | PASS |
| `text.secondary` #C4B9AC | `surface.primary` #201D19 | text | 8.70 | 4.50 | PASS |
| `text.secondary` #C4B9AC | `surface.secondary` #2A251F | text | 7.87 | 4.50 | PASS |
| `brand.primary` #C99D7A | `canvas.primary` #151411 | text | 7.53 | 4.50 | PASS |
| `brand.primary` #C99D7A | `surface.primary` #201D19 | text | 6.86 | 4.50 | PASS |
| `on.brand` #1A1612 | `brand.primary` #C99D7A | text | 7.36 | 4.50 | PASS |
| `accent.copper` #D4A18B | `canvas.primary` #151411 | text | 8.13 | 4.50 | PASS |
| `accent.copper` #D4A18B | `surface.primary` #201D19 | text | 7.41 | 4.50 | PASS |
| `brand.secondary` #ADB598 | `canvas.primary` #151411 | text | 8.63 | 4.50 | PASS |
| `status.success` #8CC7A1 | `canvas.primary` #151411 | text | 9.47 | 4.50 | PASS |
| `status.success` #8CC7A1 | `surface.primary` #201D19 | text | 8.63 | 4.50 | PASS |
| `status.warning` #E0B36A | `canvas.primary` #151411 | text | 9.50 | 4.50 | PASS |
| `status.warning` #E0B36A | `surface.primary` #201D19 | text | 8.65 | 4.50 | PASS |
| `status.danger` #EE9A9C | `canvas.primary` #151411 | text | 8.54 | 4.50 | PASS |
| `status.danger` #EE9A9C | `surface.primary` #201D19 | text | 7.78 | 4.50 | PASS |
| `border.control` #8A7F72 | `canvas.primary` #151411 | nonText | 4.70 | 3.00 | PASS |
| `border.control` #8A7F72 | `surface.primary` #201D19 | nonText | 4.28 | 3.00 | PASS |
| `brand.primary` #C99D7A | `canvas.primary` #151411 | nonText | 7.53 | 3.00 | PASS |
| `brand.primary` #C99D7A | `surface.primary` #201D19 | nonText | 6.86 | 3.00 | PASS |

## lightIncreasedContrast

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #1C1915 | `canvas.primary` #F8F6F1 | text | 16.21 | 7.00 | PASS |
| `text.primary` #1C1915 | `surface.primary` #FFFCF8 | text | 17.12 | 7.00 | PASS |
| `text.primary` #1C1915 | `surface.secondary` #F0EAE2 | text | 14.65 | 7.00 | PASS |
| `text.primary` #1C1915 | `surface.sand` #E8DED1 | text | 13.18 | 7.00 | PASS |
| `text.secondary` #4A433C | `canvas.primary` #F8F6F1 | text | 9.00 | 7.00 | PASS |
| `text.secondary` #4A433C | `surface.primary` #FFFCF8 | text | 9.51 | 7.00 | PASS |
| `text.secondary` #4A433C | `surface.secondary` #F0EAE2 | text | 8.14 | 7.00 | PASS |
| `brand.primary` #553A28 | `canvas.primary` #F8F6F1 | text | 9.62 | 7.00 | PASS |
| `brand.primary` #553A28 | `surface.primary` #FFFCF8 | text | 10.15 | 7.00 | PASS |
| `on.brand` #FFFCF8 | `brand.primary` #553A28 | text | 10.15 | 7.00 | PASS |
| `accent.copper` #7A4632 | `canvas.primary` #F8F6F1 | text | 7.07 | 7.00 | PASS |
| `accent.copper` #7A4632 | `surface.primary` #FFFCF8 | text | 7.47 | 7.00 | PASS |
| `brand.secondary` #4F543B | `canvas.primary` #F8F6F1 | text | 7.30 | 7.00 | PASS |
| `status.success` #285239 | `canvas.primary` #F8F6F1 | text | 8.25 | 7.00 | PASS |
| `status.success` #285239 | `surface.primary` #FFFCF8 | text | 8.71 | 7.00 | PASS |
| `status.warning` #6A4914 | `canvas.primary` #F8F6F1 | text | 7.55 | 7.00 | PASS |
| `status.warning` #6A4914 | `surface.primary` #FFFCF8 | text | 7.97 | 7.00 | PASS |
| `status.danger` #832E30 | `canvas.primary` #F8F6F1 | text | 8.11 | 7.00 | PASS |
| `status.danger` #832E30 | `surface.primary` #FFFCF8 | text | 8.56 | 7.00 | PASS |
| `border.control` #6E655B | `canvas.primary` #F8F6F1 | nonText | 5.29 | 4.50 | PASS |
| `border.control` #6E655B | `surface.primary` #FFFCF8 | nonText | 5.59 | 4.50 | PASS |
| `brand.primary` #553A28 | `canvas.primary` #F8F6F1 | nonText | 9.62 | 4.50 | PASS |
| `brand.primary` #553A28 | `surface.primary` #FFFCF8 | nonText | 10.15 | 4.50 | PASS |

## darkIncreasedContrast

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #FBF7F1 | `canvas.primary` #151411 | text | 17.26 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.primary` #201D19 | text | 15.73 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.secondary` #2A251F | text | 14.23 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.sand` #332D26 | text | 12.74 | 7.00 | PASS |
| `text.secondary` #DDD3C7 | `canvas.primary` #151411 | text | 12.47 | 7.00 | PASS |
| `text.secondary` #DDD3C7 | `surface.primary` #201D19 | text | 11.36 | 7.00 | PASS |
| `text.secondary` #DDD3C7 | `surface.secondary` #2A251F | text | 10.28 | 7.00 | PASS |
| `brand.primary` #DDB896 | `canvas.primary` #151411 | text | 9.97 | 7.00 | PASS |
| `brand.primary` #DDB896 | `surface.primary` #201D19 | text | 9.09 | 7.00 | PASS |
| `on.brand` #1A1612 | `brand.primary` #DDB896 | text | 9.74 | 7.00 | PASS |
| `accent.copper` #E6BBA8 | `canvas.primary` #151411 | text | 10.56 | 7.00 | PASS |
| `accent.copper` #E6BBA8 | `surface.primary` #201D19 | text | 9.62 | 7.00 | PASS |
| `brand.secondary` #C3CAAF | `canvas.primary` #151411 | text | 10.87 | 7.00 | PASS |
| `status.success` #A6DDB9 | `canvas.primary` #151411 | text | 11.99 | 7.00 | PASS |
| `status.success` #A6DDB9 | `surface.primary` #201D19 | text | 10.92 | 7.00 | PASS |
| `status.warning` #F0C985 | `canvas.primary` #151411 | text | 11.75 | 7.00 | PASS |
| `status.warning` #F0C985 | `surface.primary` #201D19 | text | 10.71 | 7.00 | PASS |
| `status.danger` #F5B5B6 | `canvas.primary` #151411 | text | 10.67 | 7.00 | PASS |
| `status.danger` #F5B5B6 | `surface.primary` #201D19 | text | 9.72 | 7.00 | PASS |
| `border.control` #A89D90 | `canvas.primary` #151411 | nonText | 6.92 | 4.50 | PASS |
| `border.control` #A89D90 | `surface.primary` #201D19 | nonText | 6.31 | 4.50 | PASS |
| `brand.primary` #DDB896 | `canvas.primary` #151411 | nonText | 9.97 | 4.50 | PASS |
| `brand.primary` #DDB896 | `surface.primary` #201D19 | nonText | 9.09 | 4.50 | PASS |

## Eski → yeni token eşlemesi (C-14)

| Eski ad | Eski açık | Eski koyu | Yeni rol | Yeni açık | Yeni koyu |
|---|---|---|---|---|---|
| `surfaceBase` | #F7F7F5 | #111315 | `canvas.primary` | #F8F6F1 | #151411 |
| `surfaceCard` | #FFFFFF | #1B1E20 | `surface.primary` | #FFFCF8 | #201D19 |
| `textPrimary` | #17191B | #F5F6F6 | `text.primary` | #26221E | #F6F0E7 |
| `textSecondary` | #667078 | #ACB4B8 | `text.secondary` | #5C544C | #C4B9AC |
| `brandInk` | #283D46 | #8DAFBE | `brand.primary` | #654632 | #C99D7A |
| `accentWarm` | #CEB79C | #B69A7B | `surface.sand` | #E8DED1 | #332D26 |
| `borderHairline` | #E7E8E5 | #303638 | `border.soft` | #D9D0C4 | #494238 |
| `statusOK` | #217354 | #83D3AE | `status.success` | #35694B | #8CC7A1 |
| `statusCaution` | #946A23 | #E9C077 | `status.warning` | #825A1C | #E0B36A |
| `statusError` | #A23738 | #F1A09E | `status.danger` | #9E3B3D | #EE9A9C |

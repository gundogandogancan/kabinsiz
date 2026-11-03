# Renk kontrast raporu (UI20-WP02, ADR-009)

Üretildi: `DesignTokensTests` (`REGENERATE_DESIGN_REPORT=1 swift test --filter DesignTokensTests`). Elle düzenlemeyin; test bu dosyayı koddan yeniden üretip karşılaştırır.

Hesap: WCAG 2.x göreli parlaklık, düz (opak) zemin. Saydamlık, fotoğraf üzeri metin ve sistem malzemeleri (Liquid Glass) bu tabloya dahil değildir; bunlar cihazda ölçülür (UI20-T-003, cihaz BLOCKED).

Eşikler: metin 4.5:1 (Increase Contrast'ta 7:1), metin dışı öğe 3:1 (Increase Contrast'ta 4.5:1).

## light

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #2B1E18 | `canvas.primary` #F7F1E7 | text | 14.36 | 4.50 | PASS |
| `text.primary` #2B1E18 | `surface.primary` #FFFBF4 | text | 15.64 | 4.50 | PASS |
| `text.primary` #2B1E18 | `surface.secondary` #F1E8DA | text | 13.29 | 4.50 | PASS |
| `text.primary` #2B1E18 | `surface.sand` #E6D8C6 | text | 11.53 | 4.50 | PASS |
| `text.secondary` #5E4E43 | `canvas.primary` #F7F1E7 | text | 7.06 | 4.50 | PASS |
| `text.secondary` #5E4E43 | `surface.primary` #FFFBF4 | text | 7.69 | 4.50 | PASS |
| `text.secondary` #5E4E43 | `surface.secondary` #F1E8DA | text | 6.53 | 4.50 | PASS |
| `brand.primary` #93562F | `canvas.primary` #F7F1E7 | text | 5.17 | 4.50 | PASS |
| `brand.primary` #93562F | `surface.primary` #FFFBF4 | text | 5.63 | 4.50 | PASS |
| `on.brand` #FFFBF4 | `brand.primary` #93562F | text | 5.63 | 4.50 | PASS |
| `accent.copper` #9A5D3C | `canvas.primary` #F7F1E7 | text | 4.67 | 4.50 | PASS |
| `accent.copper` #9A5D3C | `surface.primary` #FFFBF4 | text | 5.08 | 4.50 | PASS |
| `brand.secondary` #5D6845 | `canvas.primary` #F7F1E7 | text | 5.29 | 4.50 | PASS |
| `status.success` #35694B | `canvas.primary` #F7F1E7 | text | 5.71 | 4.50 | PASS |
| `status.success` #35694B | `surface.primary` #FFFBF4 | text | 6.22 | 4.50 | PASS |
| `status.warning` #825A1C | `canvas.primary` #F7F1E7 | text | 5.45 | 4.50 | PASS |
| `status.warning` #825A1C | `surface.primary` #FFFBF4 | text | 5.94 | 4.50 | PASS |
| `status.danger` #9E3B3D | `canvas.primary` #F7F1E7 | text | 5.94 | 4.50 | PASS |
| `status.danger` #9E3B3D | `surface.primary` #FFFBF4 | text | 6.47 | 4.50 | PASS |
| `border.control` #8C7A6A | `canvas.primary` #F7F1E7 | nonText | 3.66 | 3.00 | PASS |
| `border.control` #8C7A6A | `surface.primary` #FFFBF4 | nonText | 3.99 | 3.00 | PASS |
| `brand.primary` #93562F | `canvas.primary` #F7F1E7 | nonText | 5.17 | 3.00 | PASS |
| `brand.primary` #93562F | `surface.primary` #FFFBF4 | nonText | 5.63 | 3.00 | PASS |

## dark

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #F7F1E7 | `canvas.primary` #1B1410 | text | 16.19 | 4.50 | PASS |
| `text.primary` #F7F1E7 | `surface.primary` #2B1E18 | text | 14.36 | 4.50 | PASS |
| `text.primary` #F7F1E7 | `surface.secondary` #35271F | text | 12.79 | 4.50 | PASS |
| `text.primary` #F7F1E7 | `surface.sand` #3F2F26 | text | 11.36 | 4.50 | PASS |
| `text.secondary` #CDBDAE | `canvas.primary` #1B1410 | text | 9.95 | 4.50 | PASS |
| `text.secondary` #CDBDAE | `surface.primary` #2B1E18 | text | 8.82 | 4.50 | PASS |
| `text.secondary` #CDBDAE | `surface.secondary` #35271F | text | 7.86 | 4.50 | PASS |
| `brand.primary` #D8A07A | `canvas.primary` #1B1410 | text | 8.00 | 4.50 | PASS |
| `brand.primary` #D8A07A | `surface.primary` #2B1E18 | text | 7.09 | 4.50 | PASS |
| `on.brand` #1B1410 | `brand.primary` #D8A07A | text | 8.00 | 4.50 | PASS |
| `accent.copper` #DDA585 | `canvas.primary` #1B1410 | text | 8.49 | 4.50 | PASS |
| `accent.copper` #DDA585 | `surface.primary` #2B1E18 | text | 7.53 | 4.50 | PASS |
| `brand.secondary` #B3BB97 | `canvas.primary` #1B1410 | text | 9.07 | 4.50 | PASS |
| `status.success` #8CC7A1 | `canvas.primary` #1B1410 | text | 9.36 | 4.50 | PASS |
| `status.success` #8CC7A1 | `surface.primary` #2B1E18 | text | 8.30 | 4.50 | PASS |
| `status.warning` #E0B36A | `canvas.primary` #1B1410 | text | 9.38 | 4.50 | PASS |
| `status.warning` #E0B36A | `surface.primary` #2B1E18 | text | 8.32 | 4.50 | PASS |
| `status.danger` #EE9A9C | `canvas.primary` #1B1410 | text | 8.44 | 4.50 | PASS |
| `status.danger` #EE9A9C | `surface.primary` #2B1E18 | text | 7.48 | 4.50 | PASS |
| `border.control` #948272 | `canvas.primary` #1B1410 | nonText | 4.93 | 3.00 | PASS |
| `border.control` #948272 | `surface.primary` #2B1E18 | nonText | 4.38 | 3.00 | PASS |
| `brand.primary` #D8A07A | `canvas.primary` #1B1410 | nonText | 8.00 | 3.00 | PASS |
| `brand.primary` #D8A07A | `surface.primary` #2B1E18 | nonText | 7.09 | 3.00 | PASS |

## lightIncreasedContrast

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #1F1511 | `canvas.primary` #F7F1E7 | text | 15.93 | 7.00 | PASS |
| `text.primary` #1F1511 | `surface.primary` #FFFBF4 | text | 17.35 | 7.00 | PASS |
| `text.primary` #1F1511 | `surface.secondary` #F1E8DA | text | 14.74 | 7.00 | PASS |
| `text.primary` #1F1511 | `surface.sand` #E6D8C6 | text | 12.78 | 7.00 | PASS |
| `text.secondary` #46392F | `canvas.primary` #F7F1E7 | text | 9.91 | 7.00 | PASS |
| `text.secondary` #46392F | `surface.primary` #FFFBF4 | text | 10.79 | 7.00 | PASS |
| `text.secondary` #46392F | `surface.secondary` #F1E8DA | text | 9.17 | 7.00 | PASS |
| `brand.primary` #6A3A1E | `canvas.primary` #F7F1E7 | text | 8.36 | 7.00 | PASS |
| `brand.primary` #6A3A1E | `surface.primary` #FFFBF4 | text | 9.10 | 7.00 | PASS |
| `on.brand` #FFFBF4 | `brand.primary` #6A3A1E | text | 9.10 | 7.00 | PASS |
| `accent.copper` #6E3F2B | `canvas.primary` #F7F1E7 | text | 7.76 | 7.00 | PASS |
| `accent.copper` #6E3F2B | `surface.primary` #FFFBF4 | text | 8.45 | 7.00 | PASS |
| `brand.secondary` #434D30 | `canvas.primary` #F7F1E7 | text | 7.98 | 7.00 | PASS |
| `status.success` #285239 | `canvas.primary` #F7F1E7 | text | 7.93 | 7.00 | PASS |
| `status.success` #285239 | `surface.primary` #FFFBF4 | text | 8.64 | 7.00 | PASS |
| `status.warning` #6A4914 | `canvas.primary` #F7F1E7 | text | 7.26 | 7.00 | PASS |
| `status.warning` #6A4914 | `surface.primary` #FFFBF4 | text | 7.90 | 7.00 | PASS |
| `status.danger` #832E30 | `canvas.primary` #F7F1E7 | text | 7.79 | 7.00 | PASS |
| `status.danger` #832E30 | `surface.primary` #FFFBF4 | text | 8.49 | 7.00 | PASS |
| `border.control` #6E655B | `canvas.primary` #F7F1E7 | nonText | 5.09 | 4.50 | PASS |
| `border.control` #6E655B | `surface.primary` #FFFBF4 | nonText | 5.54 | 4.50 | PASS |
| `brand.primary` #6A3A1E | `canvas.primary` #F7F1E7 | nonText | 8.36 | 4.50 | PASS |
| `brand.primary` #6A3A1E | `surface.primary` #FFFBF4 | nonText | 9.10 | 4.50 | PASS |

## darkIncreasedContrast

| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |
|---|---|---|---:|---:|---|
| `text.primary` #FBF7F1 | `canvas.primary` #1B1410 | text | 17.05 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.primary` #2B1E18 | text | 15.12 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.secondary` #35271F | text | 13.46 | 7.00 | PASS |
| `text.primary` #FBF7F1 | `surface.sand` #3F2F26 | text | 11.95 | 7.00 | PASS |
| `text.secondary` #E4D8CB | `canvas.primary` #1B1410 | text | 12.98 | 7.00 | PASS |
| `text.secondary` #E4D8CB | `surface.primary` #2B1E18 | text | 11.51 | 7.00 | PASS |
| `text.secondary` #E4D8CB | `surface.secondary` #35271F | text | 10.25 | 7.00 | PASS |
| `brand.primary` #EEC9A8 | `canvas.primary` #1B1410 | text | 11.75 | 7.00 | PASS |
| `brand.primary` #EEC9A8 | `surface.primary` #2B1E18 | text | 10.41 | 7.00 | PASS |
| `on.brand` #1B1410 | `brand.primary` #EEC9A8 | text | 11.75 | 7.00 | PASS |
| `accent.copper` #F0C8B0 | `canvas.primary` #1B1410 | text | 11.78 | 7.00 | PASS |
| `accent.copper` #F0C8B0 | `surface.primary` #2B1E18 | text | 10.44 | 7.00 | PASS |
| `brand.secondary` #CDD3B6 | `canvas.primary` #1B1410 | text | 11.77 | 7.00 | PASS |
| `status.success` #A6DDB9 | `canvas.primary` #1B1410 | text | 11.84 | 7.00 | PASS |
| `status.success` #A6DDB9 | `surface.primary` #2B1E18 | text | 10.50 | 7.00 | PASS |
| `status.warning` #F0C985 | `canvas.primary` #1B1410 | text | 11.61 | 7.00 | PASS |
| `status.warning` #F0C985 | `surface.primary` #2B1E18 | text | 10.29 | 7.00 | PASS |
| `status.danger` #F5B5B6 | `canvas.primary` #1B1410 | text | 10.54 | 7.00 | PASS |
| `status.danger` #F5B5B6 | `surface.primary` #2B1E18 | text | 9.35 | 7.00 | PASS |
| `border.control` #A89D90 | `canvas.primary` #1B1410 | nonText | 6.84 | 4.50 | PASS |
| `border.control` #A89D90 | `surface.primary` #2B1E18 | nonText | 6.06 | 4.50 | PASS |
| `brand.primary` #EEC9A8 | `canvas.primary` #1B1410 | nonText | 11.75 | 4.50 | PASS |
| `brand.primary` #EEC9A8 | `surface.primary` #2B1E18 | nonText | 10.41 | 4.50 | PASS |

## Eski → yeni token eşlemesi (C-14)

| Eski ad | Eski açık | Eski koyu | Yeni rol | Yeni açık | Yeni koyu |
|---|---|---|---|---|---|
| `surfaceBase` | #F7F7F5 | #111315 | `canvas.primary` | #F7F1E7 | #1B1410 |
| `surfaceCard` | #FFFFFF | #1B1E20 | `surface.primary` | #FFFBF4 | #2B1E18 |
| `textPrimary` | #17191B | #F5F6F6 | `text.primary` | #2B1E18 | #F7F1E7 |
| `textSecondary` | #667078 | #ACB4B8 | `text.secondary` | #5E4E43 | #CDBDAE |
| `brandInk` | #283D46 | #8DAFBE | `brand.primary` | #93562F | #D8A07A |
| `accentWarm` | #CEB79C | #B69A7B | `surface.sand` | #E6D8C6 | #3F2F26 |
| `borderHairline` | #E7E8E5 | #303638 | `border.soft` | #DCCDBB | #524036 |
| `statusOK` | #217354 | #83D3AE | `status.success` | #35694B | #8CC7A1 |
| `statusCaution` | #946A23 | #E9C077 | `status.warning` | #825A1C | #E0B36A |
| `statusError` | #A23738 | #F1A09E | `status.danger` | #9E3B3D | #EE9A9C |

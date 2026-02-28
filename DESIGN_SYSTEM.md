# Helpi Design System

> Ovaj dokument opisuje KOMPLETAN vizualni stil Helpi aplikacije.
> Koristi ga kao referencu kod izrade bilo kojeg novog ekrana ili komponente.
> Student app i Senior app dijele ISTI dizajn sustav.

---

## 1. Boje

### Primarne
| Naziv | Hex | Uporaba |
|-------|-----|---------|
| **Coral** (primary) | `#EF5B5B` | CTA gumbi, tab underline (active), cancel link, login gumb, logo krug pozadina |
| **Teal** (secondary/accent) | `#009D9D` | Outlined gumbi, chipovi (active), status badge, input field ikone, text linkovi, bottom nav selected |

### Pozadine
| Naziv | Hex | Uporaba |
|-------|-----|---------|
| **Warm off-white** | `#F9F7F4` | Scaffold background — svi ekrani |
| **Surface (white)** | `#FFFFFF` | Kartice, input fieldovi, bottom nav, modali |
| **Pastel teal** | `#E0F5F5` | Chip pozadina (neaktivni servisi) |

### Pastelne boje za kartice
| Naziv | Hex |
|-------|-----|
| Card Mint | `#E8F5F1` |
| Card Lavender | `#F0EBFA` |
| Card Cream | `#FFF8E7` |
| Card Blue | `#E8F1FB` |

### ColorScheme dopune
| Naziv | Hex |
|-------|-----|
| Primary container | `#FFE8E5` |
| Secondary container | `#D4F0F0` |
| Error | `#C62828` |

### Tekst boje
| Naziv | Hex | Uporaba |
|-------|-----|---------|
| **Text primary** | `#2D2D2D` | Naslovi, body tekst |
| **Text secondary** | `#757575` | Subtitles, labels, hintovi |
| **Border grey** | `#E0E0E0` | Card borders, input borders, social button borders |
| **Inactive tab text** | `#9E9E9E` | Tab tekst kad nije selektiran |
| **Divider** | `#EEEEEE` | Separator linije |
| **Nav unselected** | `#B0B0B0` | Bottom nav neselektirane ikone |

### Specijalne
| Naziv | Hex | Uporaba |
|-------|-----|---------|
| **Star yellow** | `#FFC107` | Zvjezdice za ocjene |
| **Facebook blue** | `#1877F2` | Facebook logo |

---

## 2. Border Radius

| Vrijednost | Koristi se za |
|------------|---------------|
| **16** | Kartice, gumbi (svi tipovi), input fieldovi, service chipovi — STANDARDNI radius |
| **12** | Status chipovi, review kartice — manji elementi proporcionalno |
| **24** | Chat bubble — balloon efekt |
| **20** | BottomSheet gornji kutovi |
| **2** | Tab underline indikator (namjerno tanki) |

> **PRAVILO:** Za nove komponente koristi **16** osim ako je elelement manji (chip → 12) ili je poseban oblik (chat → 24).

---

## 3. Dimenzije

| Konstanta | Vrijednost | Opis |
|-----------|------------|------|
| `buttonHeight` | 56 | Standardna visina ElevatedButton i OutlinedButton |
| `buttonRadius` | 16 | Border radius svih gumba |
| `cardRadius` | 16 | Border radius svih kartica |
| Login CTA visina | 52 | LoginScreen gumb je nešto manji |

---

## 4. Tipografija (TextTheme)

| TextTheme slot | Veličina | Weight | Boja |
|---------------|----------|--------|------|
| `headlineLarge` | 30 | w800 | `#2D2D2D` |
| `headlineMedium` | 26 | w700 | `#2D2D2D` |
| `headlineSmall` | 20 | w700 | `#2D2D2D` |
| `bodyLarge` | 18 | w400 | `#2D2D2D` |
| `bodyMedium` | 16 | w400 | `#2D2D2D` |
| `bodySmall` | 14 | w400 | `#757575` |
| `labelLarge` | 18 | w600 | white |

---

## 5. Komponente

### 5.1 ElevatedButton (Primary CTA)
```dart
ElevatedButton.styleFrom(
  backgroundColor: Color(0xFFEF5B5B),  // coral
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  elevation: 0,
)
```

### 5.2 OutlinedButton (Secondary)
```dart
OutlinedButton.styleFrom(
  foregroundColor: Color(0xFF009D9D),  // teal
  minimumSize: Size(double.infinity, 56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  side: BorderSide(color: Color(0xFF009D9D), width: 2),
  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
)
```

### 5.3 TextButton
```dart
TextButton.styleFrom(
  foregroundColor: Color(0xFF009D9D),  // teal
  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

### 5.4 Card
- Pozadina: white
- Elevation: 0
- Border: `Border.all(color: Color(0xFFE0E0E0))` — sivi border
- Border radius: 16
- Margin: horizontal 16, vertical 8

### 5.5 Input Field (TextField)
- Filled: true, fillColor: white
- Border: `OutlineInputBorder(borderRadius: 16, borderSide: Color(0xFFE0E0E0))`
- Focus border: teal `#009D9D`, width 2
- Error border: `#C62828`, width 2
- Prefix ikone: teal boja
- Content padding: horizontal 20, vertical 18
- Label/hint style: fontSize 16, color `#757575`

### 5.6 Tab Toggle (custom, nije TabBar)
- **Active tab:** coral text + 3px coral underline
- **Inactive tab:** `#9E9E9E` text + 1px `#E0E0E0` underline
- Implementirano kao Row od GestureDetector + Column(Text, Container underline)
- Sve tabove jednako širi s `Expanded`

### 5.7 Service Chip
- Bijeli background, `#E0E0E0` border
- Selektirani: teal background + bijeli tekst
- Border radius: 16
- Padding: horizontal 16, vertical 10

### 5.8 Status Chip (na order karticama)
- Border radius: 12
- `U obradi` / `Processing`: teal text + teal/12% background
- `Aktivna` / `Active`: `#4CAF50` text + green/12% background
- `Završena` / `Completed`: `#757575` text + grey/12% background

### 5.9 Social Login Button (krug)
```dart
Container(
  width: 56, height: 56,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
  child: Center(
    child: SvgPicture.asset(assetPath, width: 24, height: 24),
  ),
)
```
- Google, Apple, Facebook — SVG logotipi u `assets/images/`
- Razmak između: 16

### 5.10 Bottom Navigation Bar
- Pozadina: white
- Selected item: teal `#009D9D`
- Unselected item: `#B0B0B0`
- Selected label: fontSize 14, w600
- Unselected label: fontSize 14
- Type: fixed
- Elevation: 0
- Shadow: `BoxShadow(color: black/alpha10, blurRadius: 12, offset: Offset(0, -4))`
- Ikone: size 28

### 5.11 AppBar
- Pozadina: `#F9F7F4` (ista kao scaffold)
- Foreground: `#2D2D2D`
- Elevation: 0
- Center title: true
- Title style: fontSize 22, w700

### 5.12 Logo (Login ekran)
```dart
Container(
  width: 100, height: 100,
  decoration: BoxDecoration(color: coral, shape: BoxShape.circle),
  child: SvgPicture.asset('h_logo.svg', width: 50, height: 50,
    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
)
```

---

## 6. Layout Patterns

### 6.1 Login/Register Screen
- `LayoutBuilder` + `ConstrainedBox(minHeight: constraints.maxHeight)` + `MainAxisAlignment.center`
- `SingleChildScrollView` za keyboard safety
- Horizontal padding: 28
- Sadržaj se vertikalno centrira na većim ekranima, scrollabilno na manjim

### 6.2 Standardni Content Screen
- `SafeArea` wrapping body
- `SingleChildScrollView` ili `ListView` za scrollabilni sadržaj
- Padding: 16 horizontal

### 6.3 Screen s tabovima (npr. Orders)
- Custom tab toggle (NE Material TabBar)
- Ispod tabova: odgovarajuća lista ili empty state

### 6.4 Empty State
- Centered icon (size 80, secondary color withAlpha(100))
- Heading (headlineMedium)
- Subtitle (bodyLarge, secondary text)
- CTA button ispod

---

## 7. Spacing Konvencije

| Razmak | Koristi se za |
|--------|---------------|
| 8 | Između title i subtitle |
| 12 | Između password fielda i forgot password |
| 16 | Između input fieldova, između kartica, chip spacing |
| 20 | Iznad CTA gumba |
| 24 | Između sekcija (logo→title, divider→social buttons) |
| 32 | Veći razmak (social→toggle, toggle→language picker) |
| 40 | Između subtitle i prvog input fielda |

---

## 8. Ikone

- Stil: **Outlined** (Material Icons) — `Icons.xxx_outlined`
- Bottom nav veličina: 28
- Input prefix veličina: default (24)
- Boja: teal za input ikone, tema za ostalo

---

## 9. SVG Asseti

Svi SVG-ovi u `assets/images/`:
- `h_logo.svg` — Helpi H logo
- `logo.svg` — Full Helpi logo
- `google_logo.svg` — Google 4-color G
- `apple_logo.svg` — Apple jabuka (crna)
- `facebook_logo.svg` — Facebook F (plavi #1877F2)
- Servisne ikone: `shopping.svg`, `household.svg`, `activities.svg`, `socializing.svg`, `technology.svg`, `pets.svg`, `transport.svg`, `administration.svg`, `support.svg`

---

## 10. Animacije & Interakcije

- `HapticFeedback.selectionClick()` na bottom nav tap i key actions
- Nema custom animacija — sve standardni Flutter transitions
- `GestureDetector` za social buttone i kartice (tap-to-detail)

---

## 11. Responsive Pattern

- Fiksni paddinging, `double.infinity` za gumbe
- `LayoutBuilder` + `ConstrainedBox` za vertikalno centriranje (login)
- Nema breakpointova — mobile-only app

---

## 12. Dependency-ji

```yaml
flutter_svg: ^2.2.3           # SVG rendering
flutter_localizations: sdk     # i18n
```

---

## 13. Brza Referenca: Najčešći Pattern

```dart
// Coral CTA
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFEF5B5B),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
  ),
  child: Text('Action'),
)

// Teal Outlined
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF009D9D),
    side: BorderSide(color: Color(0xFF009D9D), width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  child: Text('Secondary'),
)

// Standardna kartica
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE0E0E0)),
  ),
  padding: EdgeInsets.all(16),
  child: ...,
)
```

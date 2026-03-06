# Helpi Student — Code Audit

> Date: March 6, 2026  
> Baseline: `flutter analyze` → **0 errors, 0 warnings, 0 issues**  
> Files: 18 Dart files in `lib/`

---

## 1. Duplicirani kod (Copy-Paste Patterns)

### 1.1 `_formatTime(TimeOfDay)` — 4 kopije

Identičan helper za formatiranje `TimeOfDay` u `HH:mm` string postoji u:

| #   | Fajl                            | Metoda          |
| --- | ------------------------------- | --------------- |
| 1   | `schedule_screen.dart` L89-93   | `_formatTime()` |
| 2   | `job_detail_screen.dart` L29-33 | `_formatTime()` |
| 3   | `onboarding_screen.dart` L51-53 | `_formatTime()` |
| 4   | `profile_screen.dart` L77-79    | `_formatTime()` |

**Identičan kod:**

```dart
String _formatTime(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
```

### 1.2 `_formatDate(DateTime)` — 2 kopije + varijanta

| #   | Fajl                                     | Format                                     |
| --- | ---------------------------------------- | ------------------------------------------ |
| 1   | `schedule_screen.dart` L85-87            | `d.M.yyyy.`                                |
| 2   | `job_detail_screen.dart` L35-37          | `dd.MM.yyyy.` (padLeft)                    |
| 3   | `statistics_screen.dart` L98-99          | `dd.MM.` (kratki)                          |
| 4   | `statistics_screen.dart` L101-102        | `dd.MM.yyyy.` (puni)                       |
| 5   | `profile_screen.dart` L322-323           | `dd.MM.yyyy.` (u `_buildDatePicker`)       |
| 6   | `registration_data_screen.dart` L204-206 | `dd.MM.yyyy.` (u `_buildDatePicker`)       |
| 7   | `job_detail_screen.dart` L167-168        | inline datum format u `_onReviewSubmitted` |

**Problem:** Nekonzistentan format — `schedule_screen` koristi `d.M.yyyy.` dok ostali koriste `dd.MM.yyyy.`.

### 1.3 `_dayName(String key)` — 2 identične kopije

Switch/case koji mapira `dayKey` na `AppStrings` getter postoji u:

| #   | Fajl                            |
| --- | ------------------------------- |
| 1   | `onboarding_screen.dart` L33-48 |
| 2   | `profile_screen.dart` L50-65    |

**Identičan kod (7 case-ova):**

```dart
String _dayName(String key) {
  switch (key) {
    case 'dayMonFull': return AppStrings.dayMonFull;
    case 'dayTueFull': return AppStrings.dayTueFull;
    // ... 5 more cases
    default: return key;
  }
}
```

### 1.4 `_statusLabel()` / `_statusColor()` / `_statusBgColor()` — 2 kopije svake

Tri switch/case funkcije za `JobStatus` su identične u:

| Metoda             | Fajl 1                          | Fajl 2                          |
| ------------------ | ------------------------------- | ------------------------------- |
| `_statusLabel()`   | `schedule_screen.dart` L107-113 | `job_detail_screen.dart` L59-65 |
| `_statusColor()`   | `schedule_screen.dart` L115-122 | `job_detail_screen.dart` L67-74 |
| `_statusBgColor()` | `schedule_screen.dart` L124-131 | `job_detail_screen.dart` L76-83 |

### 1.5 `_serviceLabel(ServiceType)` — 1 kopija, ali treba biti shared

Postoji samo u `job_detail_screen.dart` L41-57, ali će trebati i u `schedule_screen` kad se doda service prikaz u kartice.

### 1.6 `_buildDayRow()` — 2 gotovo identične kopije

Availability day row widget postoji u:

| #   | Fajl                              | Razlika                         |
| --- | --------------------------------- | ------------------------------- |
| 1   | `onboarding_screen.dart` L130-185 | Checkbox uvijek aktivan         |
| 2   | `profile_screen.dart` L207-270    | Checkbox zavisi od `_isEditing` |

**~95% identičan kod** — jedina razlika je `onChanged` (uvijek aktivan vs. `_isEditing` guard).

### 1.7 `_timeChip()` — 2 identične kopije

| #   | Fajl                              |
| --- | --------------------------------- |
| 1   | `onboarding_screen.dart` L187-207 |
| 2   | `profile_screen.dart` L272-293    |

### 1.8 `_pickTime()` logika — 2 gotovo identične kopije

Time picking logika s `showTimeSlotPicker` + auto-snap "Do" na Od+1h:

| #   | Fajl                            |
| --- | ------------------------------- |
| 1   | `onboarding_screen.dart` L55-77 |
| 2   | `profile_screen.dart` L81-105   |

### 1.9 Star rating display — 3 kopije

Generiranje `Icons.star` / `Icons.star_border` reda:

| #   | Fajl                              | Kontekst                   |
| --- | --------------------------------- | -------------------------- |
| 1   | `job_detail_screen.dart` L117-130 | Review sheet (interactive) |
| 2   | `job_detail_screen.dart` L254-260 | Review display (read-only) |
| 3   | `statistics_screen.dart` L518-522 | Rating section (read-only) |
| 4   | `statistics_screen.dart` L707-712 | Review card (read-only)    |

### 1.10 Review card layout — 2 kopije

Prikaz recenzije (avatar + ime + datum + zvjezdice + komentar):

| #   | Fajl                              |
| --- | --------------------------------- | -------------------- |
| 1   | `job_detail_screen.dart` L245-278 | inline u build()     |
| 2   | `statistics_screen.dart` L665-720 | `_buildReviewCard()` |

### 1.11 `_buildGenderPicker()` — 2 kopije

| #   | Fajl                                     |
| --- | ---------------------------------------- |
| 1   | `registration_data_screen.dart` L187-213 |
| 2   | `profile_screen.dart` L295-335           |

Razlika: profile verzija ima `_isEditing` guard.

### 1.12 `_buildDatePicker()` — 2 kopije

| #   | Fajl                                     |
| --- | ---------------------------------------- |
| 1   | `registration_data_screen.dart` L215-250 |
| 2   | `profile_screen.dart` L337-385           |

Razlika: profile verzija ima `_isEditing` guard i drugačiji stil za disabled stanje.

---

## 2. Hardkodirane boje (Magic Colors)

Boje se definiraju u `theme.dart` i u `HelpiTheme`, ali ekrani **ne koriste temu konzistentno** — umjesto toga, kopiraju hex boje.

### 2.1 Hardkodirani `_coral` i `_teal`

| Boja             | Hex            | Pojavljuje se u                                                                                                                                                 |
| ---------------- | -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Coral / Primary  | `0xFFEF5B5B`   | `login_screen.dart` (2x), `onboarding_screen.dart`, `registration_data_screen.dart`, `statistics_screen.dart`, `schedule_screen.dart`, `job_detail_screen.dart` |
| Teal / Secondary | `0xFF009D9D`   | `login_screen.dart` (5x), `statistics_screen.dart`, `job_detail_screen.dart` (SnackBar bg)                                                                      |
| Grey text        | `0xFF757575`   | `login_screen.dart`, `onboarding_screen.dart`, `registration_data_screen.dart`, `schedule_screen.dart`, `statistics_screen.dart`                                |
| Off-white bg     | `0xFFF9F7F4`   | `login_screen.dart` L52, `onboarding_screen.dart` L91, `registration_data_screen.dart` L73, `statistics_screen.dart`, `job_detail_screen.dart` L256             |
| Border grey      | `0xFFE0E0E0`   | 10+ mjesta kroz cijeli projekt                                                                                                                                  |
| Star color       | `0xFFFFC107`   | `job_detail_screen.dart` L127, `statistics_screen.dart` L20                                                                                                     |
| Card bg white    | `Colors.white` | 15+ mjesta                                                                                                                                                      |
| Green assigned   | `0xFF4CAF50`   | `schedule_screen.dart`, `job_detail_screen.dart`                                                                                                                |
| Light green bg   | `0xFFE8F5E9`   | `schedule_screen.dart`, `job_detail_screen.dart`                                                                                                                |
| Cancel red bg    | `0xFFFFEBEE`   | `schedule_screen.dart`, `job_detail_screen.dart`                                                                                                                |
| Bar bg           | `0xFFF0F0F0`   | `statistics_screen.dart` 3x, `job_detail_screen.dart`                                                                                                           |
| Avatar teal bg   | `0xFFE0F5F5`   | `job_detail_screen.dart` L225, `statistics_screen.dart` L681                                                                                                    |

**Ove boje bi trebale biti iz `HelpiTheme` ili `Theme.of(context).colorScheme`.**

---

## 3. Hardkodirane dimenzije (Magic Numbers)

| Vrijednost | Opis               | Pojavljuje se u                                           |
| ---------- | ------------------ | --------------------------------------------------------- |
| `16`       | Border radius      | 15+ Container dekoracija                                  |
| `12`       | Chip border radius | 8+ mjesta                                                 |
| `24`       | Padding            | 10+ mjesta                                                |
| `16`       | Standard padding   | 10+ mjesta                                                |
| `56`       | Button height      | `onboarding_screen.dart`, `registration_data_screen.dart` |
| `52`       | Button height      | `login_screen.dart`                                       |
| `44`       | Avatar size        | `job_detail_screen.dart`                                  |
| `36`       | Avatar size        | `statistics_screen.dart`                                  |

**Theme već definira `buttonHeight=56`, `buttonRadius=16`, `cardRadius=16`, ali se ne koriste.**

---

## 4. Nekonzistentni widgeti

### 4.1 Button stilovi — ad-hoc vs. tema

| Ekran                           | Problem                                                 |
| ------------------------------- | ------------------------------------------------------- |
| `login_screen.dart`             | ElevatedButton s inline `style:` umjesto teme           |
| `onboarding_screen.dart`        | ElevatedButton s inline `style:` umjesto teme           |
| `registration_data_screen.dart` | ElevatedButton s inline `style:` umjesto teme           |
| `job_detail_screen.dart`        | ElevatedButton.icon s potpuno custom style za "Ocijeni" |

**Theme definira `elevatedButtonTheme` koji bi trebao pokriti većinu slučajeva.**

### 4.2 Card/Container dekoracije — duplicirana BoxDecoration

Gotovo identičan `BoxDecoration` (white bg, border 0xFFE0E0E0, radius 16) pojavljuje se u:

- `schedule_screen.dart` (\_JobCard)
- `job_detail_screen.dart` (Card 1, Card 2)
- `statistics_screen.dart` (4 sekcije)
- `profile_screen.dart` (\_buildDayRow)
- `onboarding_screen.dart` (\_buildDayRow)

### 4.3 SnackBar — inline umjesto helper

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(AppStrings.reviewSent),
    backgroundColor: const Color(0xFF009D9D),
  ),
);
```

Pojavljuje se u `job_detail_screen.dart` 2x. Treba shared helper.

### 4.4 Bottom Sheet stil — dupliciran

Isti `showModalBottomSheet` s identičnim `shape` i `backgroundColor` na 4 mjesta:

- `job_detail_screen.dart` L93-97 (review sheet)
- `job_detail_screen.dart` L310-315 (decline sheet)
- `statistics_screen.dart` L598-603 (all reviews sheet)
- `time_slot_picker.dart` L63-67 (time picker)

---

## 5. Hardkodirani stringovi u UI-ju

### 5.1 Primjeri pronađeni

| Fajl                     | Line     | String                                       | Problem                                                     |
| ------------------------ | -------- | -------------------------------------------- | ----------------------------------------------------------- |
| `login_screen.dart`      | dropdown | `'Hrvatski'`, `'English'`                    | Hardkodirane jezične opcije                                 |
| `profile_screen.dart`    | dropdown | `'Hrvatski'`, `'English'`                    | Isti problem                                                |
| `profile_screen.dart`    | footer   | `'Helpi v1.0.0'`                             | Hardkodiran version string                                  |
| `statistics_screen.dart` | L128-139 | `_monthNames` lista                          | Lokalni hardkodirani mjeseci umjesto AppStrings.monthName() |
| `statistics_screen.dart` | L126     | `_dayLabels = ['P','U','S','Č','P','S','N']` | Hardkodirani HR dan labeli                                  |

### 5.2 Stringovi koji su u AppStrings ali se ne koriste iz teme

Mnogo AppStrings ključeva postoji u mapi koji se trenutno uopće ne koriste u UI-ju (preneseni iz senior app-a). To nije bug, ali treba cleanup.

---

## 6. Manja pitanja

### 6.1 `mounted` vs `context.mounted`

| Fajl                                      | Koristi                       |
| ----------------------------------------- | ----------------------------- |
| `onboarding_screen.dart` L67              | `mounted` (stari stil)        |
| `job_detail_screen.dart` L163, L314, L335 | `mounted` (stari stil)        |
| `profile_screen.dart` L102                | `context.mounted` (novi stil) |
| `registration_data_screen.dart` L239      | `mounted` (stari stil)        |

**Nekonzistentno** — kodeks rada traži `context.mounted`.

### 6.2 Mock data u modelu

`MockJobs` klasa s 21 job-om je u `job_model.dart` (350+ linija mock data u istom fajlu s modelom).

### 6.3 `_ChatMessage` model u screen fajlu

Model `_ChatMessage` je definiran unutar `chat_list_screen.dart` — trebao bi biti u `core/models/`.

### 6.4 Neiskorišteni AppStrings ključevi

Mnogo ključeva iz senior app-a se ne koristi u student appu. Ovo nije greška (shared i18n), ali dodaje nepotrebnu veličinu.

---

## Sažetak

| Kategorija                        | Broj instanci             |
| --------------------------------- | ------------------------- |
| Duplicirane funkcije (copy-paste) | 12 patterna / ~30 kopija  |
| Hardkodirane boje                 | ~40+ instanci             |
| Hardkodirani stringovi            | 5 instanci                |
| Nekonzistentni widget stilovi     | 4 patterna                |
| Magic numbers (dimenzije)         | ~20+ instanci             |
| `mounted` vs `context.mounted`    | 4 nekonzistentne upotrebe |

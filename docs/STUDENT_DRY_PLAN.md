# Helpi Student — DRY Refactor Plan

> Date: March 6, 2026  
> Baseline: `flutter analyze` → **0 errors, 0 warnings, 0 issues**  
> Svi koraci su sortirani po prioritetu i ovisnostima.

---

## Faza 1: Shared Utilities (core/utils/)

### Korak 1.1 — `formatters.dart`

Kreiraj `lib/core/utils/formatters.dart` sa zajedničkim formaterima.

```
core/utils/formatters.dart
├── String formatTime(TimeOfDay t)         → "HH:mm"
├── String formatDateShort(DateTime d)     → "dd.MM."
├── String formatDateFull(DateTime d)      → "dd.MM.yyyy."
└── String dayName(String dayKey)          → AppStrings getter za puni naziv dana
```

**Utječe na:** `schedule_screen.dart`, `job_detail_screen.dart`, `onboarding_screen.dart`, `profile_screen.dart`, `statistics_screen.dart`, `registration_data_screen.dart`  
**Briše:** 4 kopije `_formatTime`, 5+ kopija date formatiranja, 2 kopije `_dayName`

---

### Korak 1.2 — `job_helpers.dart`

Kreiraj `lib/core/utils/job_helpers.dart` za JobStatus/ServiceType mapiranja.

```
core/utils/job_helpers.dart
├── String statusLabel(JobStatus s)        → AppStrings getter
├── Color statusColor(JobStatus s)         → assigned=green, completed=grey, cancelled=red
├── Color statusBgColor(JobStatus s)       → light background varijanta
└── String serviceLabel(ServiceType t)     → AppStrings getter
```

**Utječe na:** `schedule_screen.dart`, `job_detail_screen.dart`  
**Briše:** 2×3 identičnih switch/case funkcija = 6 kopija

---

## Faza 2: Shared Widgets (core/widgets/)

### Korak 2.1 — `status_chip.dart`

Kreiraj `lib/core/widgets/status_chip.dart`.

```dart
class StatusChip extends StatelessWidget {
  const StatusChip({required this.status});
  final JobStatus status;
  // Koristi job_helpers.dart za boje i label
}
```

**Utječe na:** `schedule_screen.dart` (\_JobCard), `job_detail_screen.dart` (Card 1)  
**Briše:** 2 identična Container + BoxDecoration bloka za status chip

---

### Korak 2.2 — `star_rating.dart`

Kreiraj `lib/core/widgets/star_rating.dart`.

```dart
class StarRating extends StatelessWidget {
  const StarRating({required this.rating, this.size = 20, this.interactive = false, this.onChanged});
  final int rating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onChanged;
}
```

**Utječe na:** `job_detail_screen.dart` (2 mjesta), `statistics_screen.dart` (2 mjesta)  
**Briše:** 4 kopije star row generiranja

---

### Korak 2.3 — `review_card.dart`

Kreiraj `lib/core/widgets/review_card.dart`.

```dart
class ReviewCard extends StatelessWidget {
  const ReviewCard({required this.seniorName, required this.review});
  final String seniorName;
  final ReviewModel review;
  // Avatar + ime + datum + StarRating + komentar
}
```

**Utječe na:** `job_detail_screen.dart` L245-278, `statistics_screen.dart` L665-720  
**Briše:** 2 kopije review prikaza

---

### Korak 2.4 — `availability_day_row.dart`

Kreiraj `lib/core/widgets/availability_day_row.dart`.

```dart
class AvailabilityDayRow extends StatelessWidget {
  const AvailabilityDayRow({
    required this.day,
    required this.editable,     // true za onboarding, _isEditing za profil
    required this.onEnabledChanged,
    required this.onFromTap,
    required this.onToTap,
  });
}
```

Uključuje i `_timeChip` kao privatnu klasu unutar istog fajla.

**Utječe na:** `onboarding_screen.dart` L130-207, `profile_screen.dart` L207-293  
**Briše:** 2 kopije `_buildDayRow` + 2 kopije `_timeChip` + 2 kopije `_pickTime` logike

---

### Korak 2.5 — `form_fields.dart`

Kreiraj `lib/core/widgets/form_fields.dart`.

```dart
class HelpiGenderPicker extends StatelessWidget {
  const HelpiGenderPicker({required this.value, this.enabled = true, required this.onChanged});
}

class HelpiDatePicker extends StatelessWidget {
  const HelpiDatePicker({required this.label, required this.date, this.enabled = true, required this.onChanged});
}
```

**Utječe na:** `registration_data_screen.dart`, `profile_screen.dart`  
**Briše:** 2 kopije `_buildGenderPicker` + 2 kopije `_buildDatePicker`

---

## Faza 3: Theme Constants (core/theme/)

### Korak 3.1 — Dodati boje u `HelpiTheme`

Proširiti `theme.dart` s nedostajućim javnim konstantama:

```dart
// Dodati u HelpiTheme:
static const Color star = Color(0xFFFFC107);
static const Color border = Color(0xFFE0E0E0);
static const Color avatarBg = Color(0xFFE0F5F5);
static const Color offWhite = Color(0xFFF9F7F4);   // već postoji kao _background
static const Color textSecondary = Color(0xFF757575); // već postoji kao _textSecondary
static const Color barBg = Color(0xFFF0F0F0);

// Status boje (za job_helpers.dart):
static const Color statusGreen = Color(0xFF4CAF50);
static const Color statusGreenBg = Color(0xFFE8F5E9);
static const Color statusRedBg = Color(0xFFFFEBEE);
```

**Utječe na:** Sve screen fajlove  
**Briše:** ~40 hardkodiranih Color() instanci

### Korak 3.2 — Koristiti `Theme.of(context)` umjesto inline stilova

Zamijeniti inline `ElevatedButton.styleFrom(...)` s tematskim stilovima gdje je moguće:

- `login_screen.dart` — coral button
- `onboarding_screen.dart` — coral button
- `registration_data_screen.dart` — coral button

---

## Faza 4: Hardkodirani stringovi → AppStrings

### Korak 4.1 — Jezične opcije

```dart
// Dodati u AppStrings:
static String get langHrvatski => _t('langHrvatski');  // 'Hrvatski'
static String get langEnglish => _t('langEnglish');    // 'English'
```

**Utječe na:** `login_screen.dart`, `profile_screen.dart`

### Korak 4.2 — Version string

```dart
// Dodati u AppStrings:
static String appVersion(String version) => _t('appVersion', params: {'version': version});
```

**Utječe na:** `profile_screen.dart`

### Korak 4.3 — Statistics day labels i month names

Zamijeniti hardkodirane `_dayLabels` i `_monthNames` u `statistics_screen.dart` s postojećim `AppStrings.dayMonShort` ... i `AppStrings.monthName()`.

**Utječe na:** `statistics_screen.dart`

---

## Faza 5: Drobne korekcije

### Korak 5.1 — `mounted` → `context.mounted`

Zamijeniti sve `mounted` provjere s `context.mounted` za konzistentnost:

- `onboarding_screen.dart` L67
- `job_detail_screen.dart` L163, L314, L335
- `registration_data_screen.dart` L239

### Korak 5.2 — SnackBar helper

```dart
// lib/core/utils/snackbar_helper.dart
void showHelpiSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    ),
  );
}
```

**Utječe na:** `job_detail_screen.dart` (2 mjesta)

### Korak 5.3 — Odvajanje mock data

Premjestiti `MockJobs` iz `job_model.dart` u zasebni `lib/core/models/mock_data.dart`:

- Čišći model fajl
- Lakše ukloniti kad dođe backend

### Korak 5.4 — `_ChatMessage` model

Premjestiti `_ChatMessage` iz `chat_list_screen.dart` u `lib/core/models/chat_message_model.dart`.

---

## Faza 6: Bottom Sheet Pattern

### Korak 6.1 — `showHelpiBottomSheet()` helper

```dart
Future<T?> showHelpiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}
```

**Utječe na:** `job_detail_screen.dart` (2x), `statistics_screen.dart` (1x), `time_slot_picker.dart` (1x)

---

## Predložena nova struktura

```
lib/core/
├── l10n/
│   ├── app_strings.dart
│   └── locale_notifier.dart
├── models/
│   ├── availability_model.dart
│   ├── chat_message_model.dart    ← NOVO (iz chat_list_screen)
│   ├── job_model.dart             ← CLEANUP (bez MockJobs)
│   ├── mock_data.dart             ← NOVO (MockJobs premješten)
│   └── review_model.dart
├── utils/                         ← NOVO
│   ├── formatters.dart            ← formatTime, formatDate, dayName
│   ├── job_helpers.dart           ← statusLabel/Color, serviceLabel
│   └── snackbar_helper.dart       ← showHelpiSnackBar
└── widgets/
    ├── availability_day_row.dart  ← NOVO (shared day row + timeChip)
    ├── form_fields.dart           ← NOVO (GenderPicker, DatePicker)
    ├── review_card.dart           ← NOVO (shared review display)
    ├── star_rating.dart           ← NOVO (interactive + read-only)
    ├── status_chip.dart           ← NOVO (JobStatus chip)
    └── time_slot_picker.dart      ← POSTOJI
```

---

## Redoslijed izvršavanja

| Korak   | Opis                        | Ovisnosti | Procjena (fajlova)     |
| ------- | --------------------------- | --------- | ---------------------- |
| 1.1     | `formatters.dart`           | Nema      | 6 fajlova za ažurirati |
| 1.2     | `job_helpers.dart`          | Nema      | 2 fajla                |
| 2.1     | `status_chip.dart`          | 1.2, 3.1  | 2 fajla                |
| 2.2     | `star_rating.dart`          | 3.1       | 2 fajla                |
| 2.3     | `review_card.dart`          | 2.2       | 2 fajla                |
| 2.4     | `availability_day_row.dart` | 1.1       | 2 fajla                |
| 2.5     | `form_fields.dart`          | Nema      | 2 fajla                |
| 3.1     | Theme constants             | Nema      | 1 fajl + svi ekrani    |
| 3.2     | Theme inline cleanup        | 3.1       | 3 fajla                |
| 4.1-4.3 | AppStrings cleanup          | Nema      | 3 fajla                |
| 5.1     | `context.mounted` fix       | Nema      | 3 fajla                |
| 5.2     | SnackBar helper             | 3.1       | 1 novi + 1 ažuriran    |
| 5.3     | Mock data odvajanje         | Nema      | 2 fajla                |
| 5.4     | ChatMessage model           | Nema      | 2 fajla                |
| 6.1     | Bottom sheet helper         | Nema      | 4 fajla                |

**Ukupno novih fajlova:** 8  
**Ukupno ažuriranih fajlova:** ~12  
**Procjena eliminiranih dupliciranih linija:** ~300-400

---

## Napomena

Svi koraci slijede principe iz kodeksa rada:

- Svaki korak = 1 fajl promjena → `flutter analyze` → potvrda
- Nema novih errora
- Svi novi stringovi idu u `AppStrings._localizedValues` (HR + EN)
- Nema `// ignore` direktiva
- `context.mounted` nakon svakog `await`

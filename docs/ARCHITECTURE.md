# Architecture

> Technical reference for the Helpi Student Flutter app.  
> Last updated: March 2026.

---

## 1. Folder Structure

```
lib/
├── main.dart                              # Entry point — runApp(HelpiStudentApp())
├── app/
│   ├── app.dart                           # Root widget: auth state, onboarding, locale
│   ├── main_shell.dart                    # BottomNavigationBar (4 tabs) + IndexedStack
│   └── theme.dart                         # Centralized ThemeData (identical to Senior app)
├── auth/
│   └── presentation/
│       └── login_screen.dart              # Login/Register (social login removed)
├── core/
│   ├── l10n/
│   │   ├── app_strings.dart               # i18n strings (HR + EN) — Gemini Hybrid pattern
│   │   └── locale_notifier.dart           # ValueNotifier<Locale> for language switching
│   ├── models/
│   │   ├── availability_model.dart        # DayAvailability + AvailabilityNotifier
│   │   ├── job_model.dart                 # Job, ServiceType, JobStatus, MockJobs (21 jobs)
│   │   └── review_model.dart              # ReviewModel (rating + comment + date)
│   └── widgets/
│       └── time_slot_picker.dart          # Custom CupertinoPicker time picker
└── features/
    ├── onboarding/
    │   └── presentation/
    │       └── onboarding_screen.dart     # Post-login availability setup
    ├── chat/
    │   └── presentation/
    │       └── chat_list_screen.dart       # Chat / Messages (placeholder)
    ├── schedule/
    │   └── presentation/
    │       ├── schedule_screen.dart        # Weekly strip + daily job list
    │       └── job_detail_screen.dart      # Job detail view + review display + decline
    ├── statistics/
    │   └── presentation/
    │       └── statistics_screen.dart      # Weekly/monthly bar charts + avg rating + reviews
    └── profile/
        └── presentation/
            └── profile_screen.dart        # Student profile (data, availability, settings)
```

---

## 2. State Management

**No external packages** — the app uses Flutter's built-in primitives:

| Pattern                                       | Usage                                                |
| --------------------------------------------- | ---------------------------------------------------- |
| `ValueNotifier<T>` + `ValueListenableBuilder` | Global/shared state (locale, availability)           |
| `setState()`                                  | Local widget state (form fields, toggles, tab index) |

### Key notifiers

| Class                  | Type                                   | Shared between                              | Purpose                      |
| ---------------------- | -------------------------------------- | ------------------------------------------- | ---------------------------- |
| `LocaleNotifier`       | `ValueNotifier<Locale>`                | app.dart ↔ ProfileScreen ↔ LoginScreen      | Language switching (HR/EN)   |
| `AvailabilityNotifier` | `ValueNotifier<List<DayAvailability>>` | app.dart ↔ OnboardingScreen ↔ ProfileScreen | 7-day availability (Mon–Sun) |

### Key models

| Class         | File                | Purpose                                                            |
| ------------- | ------------------- | ------------------------------------------------------------------ |
| `Job`         | `job_model.dart`    | Job with date, time, senior, address, serviceTypes, status, review |
| `ServiceType` | `job_model.dart`    | Enum: shopping, houseHelp, socializing, walking, escort, other     |
| `JobStatus`   | `job_model.dart`    | Enum: assigned, completed, cancelled                               |
| `ReviewModel` | `review_model.dart` | Rating (1-5) + comment + date string                               |
| `MockJobs`    | `job_model.dart`    | 21 mock jobs spanning ~45 days for chart/schedule data             |

### Why no Riverpod / Bloc / Provider?

The app is a UI prototype with mock data. `ValueNotifier` keeps things simple, readable, and dependency-free. When a real backend is added, migrating to a more robust solution (Riverpod, Bloc) can be considered.

---

## 3. Internationalization (i18n) — Gemini Hybrid Pattern

All user-visible text goes through the `AppStrings` class. **No hardcoded strings in widgets.**

### How it works

```dart
// 1. Define strings in _localizedValues map
static final Map<String, Map<String, String>> _localizedValues = {
  'hr': {
    'loginTitle': 'Dobrodošli',
    'loginSubtitle': 'Prijavite se u svoj račun',
    // ...
  },
  'en': {
    'loginTitle': 'Welcome',
    'loginSubtitle': 'Sign in to your account',
    // ...
  },
};

// 2. Create a static getter for each string
static String get loginTitle => _t('loginTitle');

// 3. Parameterized strings use params map
static String deleteConfirm(String item) =>
    _t('deleteConfirm', params: {'item': item});

// 4. Use in widgets
Text(AppStrings.loginTitle)
```

### Locale switching

```
User taps language toggle → LocaleNotifier.setLocale('EN')
    → AppStrings.setLocale(locale)
    → ValueListenableBuilder on MaterialApp rebuilds UI
```

### Rules

- Every new string → add to `_localizedValues['hr']` AND `_localizedValues['en']`
- Create a `static String get` (or parameterized method) for each key
- Use only `AppStrings.xxx` in widget code — never raw strings

---

## 4. Design System

The student app uses the **exact same** design system as the Senior app. Full details in [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) (Croatian).

### Quick reference

| Token            | Value                                                                      |
| ---------------- | -------------------------------------------------------------------------- |
| Primary (Coral)  | `#EF5B5B` — CTA buttons, active tab underline                              |
| Secondary (Teal) | `#009D9D` — outlined buttons, chips, input icons, nav selected, bar charts |
| Background       | `#F9F7F4` — scaffold background (warm off-white)                           |
| Surface          | `#FFFFFF` — cards, inputs, bottom nav                                      |
| Text primary     | `#2D2D2D`                                                                  |
| Text secondary   | `#757575`                                                                  |
| Border           | `#E0E0E0`                                                                  |
| Chip bg          | `#F0F0F0` — service chips, total hours label bg                            |
| Star yellow      | `#FFC107` — review stars                                                   |
| Senior bg        | `#E0F5F5` — senior avatar circle bg                                        |
| Border radius    | 16 (standard), 12 (small chips/status), 24 (chat), 20 (bottom sheet)       |
| Button height    | 56px, full width                                                           |
| Elevation        | 0 everywhere                                                               |

### Theme file

`lib/app/theme.dart` defines `HelpiTheme.light` which is applied in `MaterialApp`. All component styles (buttons, inputs, cards, app bar, bottom nav) are centralized here. **Never override styles inline** — use the theme.

---

## 5. Navigation

### Tab structure (BottomNavigationBar)

| Index | Tab                     | Icon             | Screen             |
| ----- | ----------------------- | ---------------- | ------------------ |
| 0     | Raspored (Schedule)     | `calendar_today` | `ScheduleScreen`   |
| 1     | Poruke (Messages)       | `chat_bubble`    | `ChatScreen`       |
| 2     | Statistika (Statistics) | `bar_chart`      | `StatisticsScreen` |
| 3     | Profil (Profile)        | `person`         | `ProfileScreen`    |

### Implementation

`MainShell` uses `IndexedStack` to preserve tab state. Each tab tap triggers `HapticFeedback.selectionClick()`.

---

## 6. Dependencies

```yaml
flutter_svg: ^2.2.3 # SVG asset rendering (logo, icons)
flutter_localizations: # Material/Cupertino localizations
  sdk: flutter
cupertino_icons: ^1.0.8 # iOS-style icons
```

No state management packages, no HTTP packages (no backend yet), no code generation.

---

## 7. Assets

All assets live in `assets/images/`:

- `h_logo.svg` — Helpi "H" logo
- `logo.svg` — Full Helpi logo
- `google_logo.svg`, `apple_logo.svg`, `facebook_logo.svg` — Social login icons
- Service icons: `shopping.svg`, `household.svg`, `activities.svg`, etc.

---

## 8. Project Conventions

| Rule                    | Detail                                                         |
| ----------------------- | -------------------------------------------------------------- |
| **Pre-flight check**    | `dart analyze` before AND after every code change              |
| **Zero linter issues**  | No `// ignore` directives ever — fix the code instead          |
| **No `dynamic`**        | Always cast: `as Map<String, dynamic>`                         |
| **Async safety**        | `if (!context.mounted) return;` after every `await` in UI      |
| **Incremental changes** | One file at a time, verify before moving on                    |
| **Commit format**       | `feat/fix/refactor: description (result: X errors → Y errors)` |

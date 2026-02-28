# Helpi Student — Progress

## Module Completion

| Module                                           | Status                                      | %    |
| ------------------------------------------------ | ------------------------------------------- | ---- |
| Infrastructure (theme, i18n, locale)             | ✅ Done                                     | 100% |
| Auth (LoginScreen)                               | ✅ Done (copied from Senior, imports fixed) | 100% |
| App shell (main.dart, app.dart, main_shell.dart) | ✅ Done                                     | 100% |
| Onboarding (availability setup)                  | ✅ Done                                     | 100% |
| Profile (data, availability, settings)           | ✅ Done                                     | 100% |
| Time Slot Picker (custom CupertinoPicker)        | ✅ Done                                     | 100% |
| Raspored (Schedule)                              | ✅ Done                                     | 100% |
| Poruke (Chat / Messages)                         | ⬜ Placeholder                              | 0%   |
| Statistika (Statistics)                          | ⬜ Placeholder                              | 0%   |
| Documentation                                    | ✅ Done                                     | 100% |

## Checklist — Completed

- [x] Read DESIGN_SYSTEM.md and PROJECT_CONTEXT.md from Senior app
- [x] pubspec.yaml — added flutter_svg, flutter_localizations, assets/images/
- [x] locale_notifier.dart — fixed import (helpi_senior → helpi_student)
- [x] login_screen.dart — fixed imports (helpi_senior → helpi_student)
- [x] app_strings.dart — all student-specific keys (HR + EN + getters)
- [x] app.dart — root widget with auth state, onboarding flow, locale
- [x] main_shell.dart — 4 tabs: Raspored, Poruke, Statistika, Profil
- [x] main.dart — clean entry point
- [x] widget_test.dart — updated smoke test
- [x] Onboarding screen — availability setup, ≥1 day required
- [x] Profile screen — personal data, availability, terms, language, logout
- [x] Availability model — shared AvailabilityNotifier between onboarding & profile
- [x] Time slot picker — hours 8-20, 15-min intervals, minTime validation, min 1h duration
- [x] Disabled button color fix — grey #E0E0E0 instead of coral
- [x] Tab restructure — removed Dashboard, added Statistika
- [x] Documentation — docs/ folder with ARCHITECTURE, APP_FLOW, BUSINESS_LOGIC
- [x] dart analyze: 0 errors maintained throughout
- [x] Schedule screen — weekly strip + daily job list, job cards, decline dialog
- [x] Job model — mock data with 6 jobs, ServiceType enum, JobStatus enum, canDecline rule

## Next Steps (awaiting user confirmation)

1. **Statistika screen** — earnings, completed jobs count, ratings
2. **Chat screen** — conversation list + chat messages

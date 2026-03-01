# Helpi Student — Progress

> Last updated: March 2026.

## Module Completion

| Module                                           | Status                         | %    |
| ------------------------------------------------ | ------------------------------ | ---- |
| Infrastructure (theme, i18n, locale)             | ✅ Done                        | 100% |
| Auth (LoginScreen)                               | ✅ Done (social login removed) | 100% |
| App shell (main.dart, app.dart, main_shell.dart) | ✅ Done                        | 100% |
| Onboarding (availability setup)                  | ✅ Done                        | 100% |
| Profile (data, availability, settings)           | ✅ Done                        | 100% |
| Time Slot Picker (custom CupertinoPicker)        | ✅ Done                        | 100% |
| Raspored (Schedule)                              | ✅ Done                        | 100% |
| Job Detail + Review system                       | ✅ Done                        | 100% |
| Statistika (Statistics)                          | ✅ Done                        | 100% |
| Poruke (Chat / Messages)                         | ⬜ Placeholder                 | 0%   |
| Documentation                                    | ✅ Done                        | 100% |

## Checklist — Completed

- [x] Read DESIGN_SYSTEM.md and PROJECT_CONTEXT.md from Senior app
- [x] pubspec.yaml — added flutter_svg, flutter_localizations, assets/images/
- [x] locale_notifier.dart — fixed import (helpi_senior → helpi_student)
- [x] login_screen.dart — fixed imports, social login fully removed
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
- [x] Schedule screen — weekly strip + daily job list, simplified job cards
- [x] Job model — mock data with 21 jobs, ServiceType enum, JobStatus enum (assigned/completed/cancelled), canDecline rule
- [x] Multi-service support — Job.serviceTypes is List<ServiceType>, chips display
- [x] Job detail screen — full detail view with service chips, status badge, decline dialog
- [x] Review system — seniors rate students, ReviewModel, star display + comment
- [x] Status refactor — JobStatus: assigned, completed, cancelled (removed pending/inProgress/declined)
- [x] Card simplification — time+status, korisnik, adresa, "Prikaži više >"
- [x] Icon updates — elderly_woman (walking), assist_walker (escort), place (location)
- [x] Statistics screen — weekly + monthly bar charts, comparison %, total hours, avg rating
- [x] Reviews section — 3 preview + "Prikaži sve" bottom sheet with SafeArea
- [x] i18n stats strings — HR + EN complete (weekly, monthly, compare, period, showAll)

## Next Steps (awaiting user confirmation)

1. **Chat screen** — conversation list + chat messages
2. **Backend integration** — replace mock data with real API calls

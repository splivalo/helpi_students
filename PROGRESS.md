# Helpi Student — Progress

## Postotak dovršenosti po modulu

| Modul                                            | Status                                            | %    |
| ------------------------------------------------ | ------------------------------------------------- | ---- |
| Infrastruktura (theme, i18n, locale)             | ✅ Done                                           | 100% |
| Auth (LoginScreen)                               | ✅ Done (kopiran iz seniora, importi popravljeni) | 100% |
| App shell (main.dart, app.dart, main_shell.dart) | ✅ Done                                           | 100% |
| Dashboard                                        | ⬜ Placeholder                                    | 0%   |
| Raspored (Schedule)                              | ⬜ Placeholder                                    | 0%   |
| Poruke (Chat)                                    | ⬜ Placeholder                                    | 0%   |
| Profil                                           | ⬜ Placeholder                                    | 0%   |

## Checklist — Završene stavke

- [x] Pročitani DESIGN_SYSTEM.md i PROJECT_CONTEXT.md
- [x] pubspec.yaml — dodani flutter_svg, flutter_localizations, assets/images/
- [x] locale_notifier.dart — popravljen import (helpi_senior → helpi_student)
- [x] login_screen.dart — popravljeni importi (helpi_senior → helpi_student)
- [x] app_strings.dart — dodani navDashboard i navSchedule (HR + EN + getteri), doc komentar ažuriran
- [x] app.dart — root widget s auth stateom, locale (ValueListenableBuilder), HelpiTheme
- [x] main_shell.dart — BottomNavigationBar (4 taba: Dashboard, Raspored, Poruke, Profil) + IndexedStack + placeholder ekrani
- [x] main.dart — čisti entry point koji pokreće HelpiStudentApp
- [x] widget_test.dart — ažuriran smoke test
- [x] dart analyze: 21 errors → 0 errors

## Next Steps (čeka potvrdu korisnika)

1. Dashboard ekran — lista narudžbi za prihvaćanje (mock data)
2. Schedule ekran — prihvaćene narudžbe, kalendar
3. Chat ekran — komunikacija sa seniorima/podrškom
4. Profil ekran — osobni podaci, zarada, dostupnost, ocjene

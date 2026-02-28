# Helpi Student

Flutter mobile app for **students** who provide everyday assistance to senior citizens through the Helpi platform.

> **Companion app:** This is the student-facing side of Helpi. The senior-facing app ([Helpi Senior](https://github.com/splivalo/helpi_students_2.0)) lets seniors order services; this app lets students manage their schedule, receive assignments, and communicate.

## Quick Start

```bash
# Prerequisites: Flutter SDK ≥ 3.10.7
flutter pub get
flutter run
```

## Project Status

**Current phase:** UI Prototype (no backend)

| Module          | Status         |
| --------------- | -------------- |
| Infrastructure  | ✅ Complete    |
| Auth / Login    | ✅ Complete    |
| Onboarding      | ✅ Complete    |
| Profile         | ✅ Complete    |
| Chat (Messages) | ✅ Placeholder |
| Schedule        | ⬜ Placeholder |
| Statistics      | ⬜ Placeholder |

## Documentation

All detailed docs live in the [`docs/`](docs/) folder:

| Document                                      | Description                                                     |
| --------------------------------------------- | --------------------------------------------------------------- |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md)       | Folder structure, state management, i18n, design system         |
| [APP_FLOW.md](docs/APP_FLOW.md)               | User flows: login → onboarding → main app, time picker, profile |
| [BUSINESS_LOGIC.md](docs/BUSINESS_LOGIC.md)   | Business model, job assignment, availability, services          |
| [PROGRESS.md](docs/PROGRESS.md)               | Completed features checklist & next steps                       |
| [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)     | Visual style guide (colors, typography, components) — Croatian  |
| [PROJECT_CONTEXT.md](docs/PROJECT_CONTEXT.md) | Platform overview & Senior app reference — Croatian             |

## Tech Stack

- **Flutter / Dart** (SDK ^3.10.7)
- **State management:** `ValueNotifier` + `ValueListenableBuilder` (no Riverpod/Bloc)
- **i18n:** Custom `AppStrings` class (HR + EN) — "Gemini Hybrid" pattern
- **Dependencies:** `flutter_svg`, `flutter_localizations`, `cupertino_icons`

## Repository

- **Repo:** `splivalo/helpi_students` — branch `main`
- **Commit format:** `feat/fix/refactor: description (result: X errors → Y errors)`

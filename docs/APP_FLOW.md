# App Flow

> Step-by-step description of every user flow in the Helpi Student app.  
> Last updated: February 2025.

---

## 1. App Launch & Auth Flow

```
main.dart
  └─ runApp(HelpiStudentApp())
       └─ app.dart — _HelpiStudentAppState
            ├── _isLoggedIn == false  →  LoginScreen
            ├── _isLoggedIn == true, _hasCompletedOnboarding == false  →  OnboardingScreen
            └── _isLoggedIn == true, _hasCompletedOnboarding == true   →  MainShell (4 tabs)
```

### Auth state (mock)

Currently there is no real authentication. Two boolean flags control the flow:

- `_isLoggedIn` — toggled by `_handleLogin()` / `_handleLogout()`
- `_hasCompletedOnboarding` — toggled by `_handleOnboardingComplete()`

On logout, both flags reset and `_availabilityNotifier.reset()` clears availability data.

---

## 2. Login Screen

**File:** `lib/auth/presentation/login_screen.dart`

### What the user sees

- Helpi logo (coral circle + white H)
- Welcome title + subtitle
- Email & password fields
- "Forgot password?" link
- Coral CTA button (Login / Register)
- Divider with "or"
- Social login buttons (Google, Apple, Facebook)
- Toggle between Login and Register mode
- Language toggle (HR / EN) at the bottom

### Behavior

- All social buttons and the main CTA call `onLoginSuccess` — no real auth
- Language toggle calls `localeNotifier.setLocale()` and rebuilds the entire app

---

## 3. Onboarding Screen

**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

### Purpose

First-time setup after login. Student sets their weekly availability before entering the app.

### What the user sees

1. Title: "Set up your availability"
2. Subtitle explaining the purpose
3. List of 7 days (Monday – Sunday), each with:
   - Checkbox to enable/disable the day
   - "Od" (From) time display — tappable
   - "Do" (To) time display — tappable
4. "Završi" (Finish) button at the bottom

### Behavior

- **Button disabled** (grey `#E0E0E0`) until at least 1 day is enabled
- Tapping "Od" opens the time picker; tapping "Do" opens it with `minTime` constraint
- On complete → `_handleOnboardingComplete()` → navigates to MainShell

---

## 4. Main Shell (Tab Navigation)

**File:** `lib/app/main_shell.dart`

4 tabs via `BottomNavigationBar` + `IndexedStack`:

| Tab | Label      | Screen        | Status          |
| --- | ---------- | ------------- | --------------- |
| 0   | Raspored   | Placeholder   | Not implemented |
| 1   | Poruke     | ChatScreen    | Placeholder     |
| 2   | Statistika | Placeholder   | Not implemented |
| 3   | Profil     | ProfileScreen | Complete        |

Haptic feedback on every tab tap.

---

## 5. Profile Screen

**File:** `lib/features/profile/presentation/profile_screen.dart`

### Sections

1. **Personal data** — Name, email, phone (read-only → editable in edit mode)
2. **Availability** — Same 7-day layout as onboarding, shared `AvailabilityNotifier`
3. **Terms & conditions** — Link/info section
4. **Language** — HR/EN toggle
5. **Logout button**

### Edit mode

- Toggled via pencil icon in the app bar
- `_isEditing` boolean controls whether fields are editable
- When editing: save button appears, cancel button reverts changes

### Availability editing

- Same time picker as onboarding
- Changes propagate through `AvailabilityNotifier` (shared state)
- "Do" picker automatically receives `minTime` = "Od" time + 45 minutes (snaps to +1h)

---

## 6. Time Slot Picker

**File:** `lib/core/widgets/time_slot_picker.dart`

### Design

Custom bottom sheet with two `CupertinoPicker` wheels:

| Wheel   | Values         | Range               |
| ------- | -------------- | ------------------- |
| Hours   | 8, 9, 10 … 20  | Working hours only  |
| Minutes | 00, 15, 30, 45 | 15-minute intervals |

### API

```dart
Future<TimeOfDay?> showTimeSlotPicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TimeOfDay? minTime,           // Optional minimum constraint
})
```

### Constraints

- **Working hours only:** 08:00 – 20:00
- **15-minute intervals:** No arbitrary minute values
- **Minimum duration:** When used for "Do" (end time), `minTime` is set to "Od" + 45min, which snaps to "Od" + 1h via `_snapAfterMin()`. This ensures **minimum 1-hour service duration**.
- **Auto-snap:** If the user scrolls to a time ≤ minTime, the picker automatically snaps forward to the next valid slot.

### Header

- Cancel (left) — closes without selection
- "Select time" title (center)
- Confirm (right) — returns selected `TimeOfDay`

---

## 7. Chat Screen

**File:** `lib/features/chat/presentation/chat_list_screen.dart`

Currently a placeholder. Will support communication with:

- Helpi support team
- Assigned seniors (per-job chat)

---

## 8. Logout Flow

```
ProfileScreen → Logout button → onLogout callback
  → app.dart: _handleLogout()
    → _isLoggedIn = false
    → _hasCompletedOnboarding = false
    → _availabilityNotifier.reset()
    → UI rebuilds → LoginScreen shown
```

---

## 9. Flow Diagram

```
┌─────────────┐
│  App Launch  │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────────┐     ┌───────────────┐
│ LoginScreen  │────▶│ OnboardingScreen  │────▶│   MainShell   │
│              │     │ (availability)    │     │ (4 tabs)      │
└─────────────┘     └──────────────────┘     └───────┬───────┘
       ▲                                              │
       │              ┌──────────────────┐            │
       └──────────────│ Logout (Profile) │◀───────────┘
                      └──────────────────┘
```

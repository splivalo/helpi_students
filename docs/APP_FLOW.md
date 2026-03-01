# App Flow

> Step-by-step description of every user flow in the Helpi Student app.  
> Last updated: March 2026.

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

| Tab | Label      | Screen           | Status      |
| --- | ---------- | ---------------- | ----------- |
| 0   | Raspored   | ScheduleScreen   | Complete    |
| 1   | Poruke     | ChatScreen       | Placeholder |
| 2   | Statistika | StatisticsScreen | Complete    |
| 3   | Profil     | ProfileScreen    | Complete    |

Haptic feedback on every tab tap.

---

## 5. Schedule Screen (Raspored)

**File:** `lib/features/schedule/presentation/schedule_screen.dart`

### What the user sees

- **AppBar:** "Raspored" title
- **Weekly strip:** Mon–Sun horizontal scroll, today highlighted (teal circle), selectable days
- **Daily job list:** Cards for each job on the selected day

### Job card layout (simplified)

Each card shows 3 rows separated by dividers:

1. **Time + status** — "09:00 – 11:00" left, status chip right (assigned=teal, completed=grey, cancelled=red)
2. **Senior name** — person icon + "Ivka Mandić"
3. **Address** — place icon + "Ilica 45, Zagreb"
4. **Footer** — "Prikaži više >" teal link

### Behavior

- Tap on a day in the weekly strip → shows that day's jobs
- Tap "Prikaži više >" → navigates to Job Detail screen
- Empty state shown if no jobs for selected day

---

## 6. Job Detail Screen

**File:** `lib/features/schedule/presentation/job_detail_screen.dart`

### What the user sees

1. **AppBar:** "Detalji posla" title
2. **Time section:** clock icon + "09:00 – 11:00"
3. **Senior section:** person icon + name
4. **Address section:** place icon + full address
5. **Service types:** work icon + Wrap of grey chips (e.g. "Kupovina", "Čišćenje")
6. **Status badge:** colored chip (Dodijeljen/Završen/Otkazan)
7. **Review section** (if completed + has review): star rating + comment
8. **Decline button** (if assigned + >24h): coral "Otkaži posao" button

### Decline flow

- Tap "Otkaži posao" → bottom sheet with TextFormField for reason
- Must enter ≥10 characters
- Submit changes job status to cancelled
- **CRITICAL:** Do NOT call `controller.dispose()` in bottom sheets — causes crash

### Service chips

- Icon: `work_outline` (grey, 20px) on the left
- Chips: text-only, #F0F0F0 background, #757575 text, horizontal:12 vertical:2 padding, borderRadius:12
- `crossAxisAlignment: CrossAxisAlignment.start` — icon aligns with first row of chips

---

## 7. Statistics Screen (Statistika)

**File:** `lib/features/statistics/presentation/statistics_screen.dart`

### What the user sees

1. **Tjedni pregled (Weekly review):**
   - Navigation arrows (< >) to change week
   - Date range label "dd.mm. – dd.mm.yyyy."
   - Bar chart: 7 teal bars (Mon–Sun), height proportional to hours worked
   - Comparison: trending up/down/flat icon + "X% više/manje sati nego prošli tjedan"
   - Total hours label in grey pill

2. **Mjesečni pregled (Monthly review):**
   - Navigation arrows to change month
   - Month name (Siječanj, Veljača, ...)
   - Bar chart: bars per week of month, date labels below
   - Comparison with previous month
   - Total hours label

3. **Prosječna ocjena (Average rating):**
   - 5 star icons (filled/empty) + numeric value (e.g. "4.6")

4. **Posljednje ocjene (Recent reviews):**
   - Max 3 review cards shown
   - "Prikaži sve ocjene" button if >3 reviews
   - Opens DraggableScrollableSheet bottom sheet with full list
   - Each review card: avatar circle + senior name + date + stars + comment

### Technical

- StatefulWidget (needs state for week/month navigation)
- Pure Flutter bar charts (Container-based, no external packages)
- Data computed from MockJobs.all filtered by status == completed
- HapticFeedback.selectionClick() on navigation arrows
- SafeArea(top: false) on the all-reviews bottom sheet ListView

---

## 8. Profile Screen

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

## 9. Time Slot Picker

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

## 10. Chat Screen

**File:** `lib/features/chat/presentation/chat_list_screen.dart`

Currently a placeholder. Will support communication with:

- Helpi support team
- Assigned seniors (per-job chat)

---

## 11. Logout Flow

```
ProfileScreen → Logout button → onLogout callback
  → app.dart: _handleLogout()
    → _isLoggedIn = false
    → _hasCompletedOnboarding = false
    → _availabilityNotifier.reset()
    → UI rebuilds → LoginScreen shown
```

---

## 12. Flow Diagram

```
┌─────────────┐
│  App Launch  │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────────┐     ┌───────────────────────────────┐
│ LoginScreen  │────▶│ OnboardingScreen  │────▶│          MainShell            │
│              │     │ (availability)    │     │   (4 tabs)                    │
└─────────────┘     └──────────────────┘     ├───────────────────────────────┤
       ▲                                      │ 0: ScheduleScreen             │
       │                                      │    └─▶ JobDetailScreen         │
       │                                      │ 1: ChatScreen (placeholder)   │
       │                                      │ 2: StatisticsScreen           │
       │                                      │    └─▶ All Reviews BottomSheet│
       │              ┌──────────────────┐    │ 3: ProfileScreen              │
       └──────────────│ Logout (Profile) │◀───┴───────────────────────────────┘
                      └──────────────────┘
```

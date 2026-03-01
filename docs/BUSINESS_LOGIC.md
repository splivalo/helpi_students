# Business Logic

> Business rules and domain logic for the Helpi Student app.  
> Last updated: March 2026.

---

## 1. What is Helpi?

**Helpi** is a platform that connects **senior citizens** with **students** who provide everyday assistance — shopping, companionship, household chores, tech help, pet care, and more.

**Analogy:** Uber has two apps (rider + driver). Helpi has two apps:

- **Helpi Senior** — seniors order services
- **Helpi Student** — students fulfill those services

---

## 2. Job Assignment Model

### How students get jobs

> **Manual assignment by the Helpi team.** There is no auto-matching algorithm.

```
Senior creates a service request (via Senior app or call)
    → Helpi back-office team reviews the request
    → Team manually assigns a student based on:
        - Student's availability
        - Location proximity
        - Student's skills / experience
        - Service type
    → Student receives the assignment in their app (Raspored tab)
```

### Why not auto-assignment?

Previously attempted — proved impractical due to:

- Complex scheduling constraints
- Need for human judgment (matching personality, special needs)
- Quality control requirements
- Small initial user base where manual matching is feasible

### Student response options

Students **cannot choose or approve** individual jobs. They can only:

| Action                | Condition                                | Behavior                                  |
| --------------------- | ---------------------------------------- | ----------------------------------------- |
| **Accept** (implicit) | Default                                  | Job appears in Raspored; student shows up |
| **Decline**           | Must be **>24 hours** before the service | Student must provide a written reason     |
| **Cannot decline**    | **≤24 hours** before the service         | Button hidden or disabled                 |

> The decline threshold may change (currently set at 24h). The student enters a free-text reason which goes to the Helpi team for review.

---

## 3. Availability System

### What it controls

Students set their **weekly availability** — which days and hours they are available for assignments. The Helpi team uses this data when manually assigning jobs.

### Data model

```dart
class DayAvailability {
  String dayKey;     // e.g. 'dayMonFull'
  bool enabled;      // Is this day available?
  TimeOfDay from;    // Start time (e.g. 08:00)
  TimeOfDay to;      // End time (e.g. 16:00)
}
```

7 days (Mon–Sun), each independently toggleable with its own time range.

### Constraints

| Rule             | Value                                 | Reason                                  |
| ---------------- | ------------------------------------- | --------------------------------------- |
| Working hours    | 08:00 – 20:00                         | Seniors' reasonable hours               |
| Time intervals   | 15-minute increments (00, 15, 30, 45) | Practical scheduling granularity        |
| Minimum duration | 1 hour per day                        | A service cannot be shorter than 1 hour |
| Default times    | 08:00 – 16:00                         | Pre-filled when a day is first enabled  |

### Where it's set

1. **Onboarding** — first-time setup after login (mandatory, ≥1 day required)
2. **Profile** — can be edited anytime in the Availability section

Both screens share the same `AvailabilityNotifier` instance to keep data in sync.

---

## 4. Services Offered

| Key                    | Croatian    | English       |
| ---------------------- | ----------- | ------------- |
| `serviceShopping`      | Kupovina    | Shopping      |
| `serviceHousehold`     | Kućanstvo   | Household     |
| `serviceCompanionship` | Pratnja     | Companionship |
| `serviceActivities`    | Aktivnosti  | Activities    |
| `serviceTechHelp`      | Tehnologija | Tech Help     |
| `servicePets`          | Ljubimci    | Pets          |

Students may be assigned any service type. Future: student can indicate which services they prefer or are trained for.

---

## 5. App Tabs & Their Business Purpose

| Tab                         | Purpose                                                   | Business value                    |
| --------------------------- | --------------------------------------------------------- | --------------------------------- |
| **Raspored** (Schedule)     | View assigned jobs with weekly strip + daily list         | Know when and where to show up    |
| **Poruke** (Messages)       | Chat with Helpi support (and later directly with seniors) | Coordinate details, report issues |
| **Statistika** (Statistics) | Weekly/monthly hours charts, average rating, reviews      | Track performance and progress    |
| **Profil** (Profile)        | Manage personal data, availability, settings              | Keep info current for assignments |

---

## 6. User Lifecycle

```
1. Student signs up (registration)
2. Student sets weekly availability (onboarding — required)
3. Helpi team reviews student profile and approves them
4. Helpi team starts assigning jobs based on availability
5. Student sees jobs in Raspored tab
6. Student performs the service at the scheduled time
7. Senior rates the student after the service
8. Student earns money (tracked in Statistika)
9. Student can adjust availability anytime via Profile
10. Student can decline future jobs (>24h notice + reason)
```

---

## 7. Key Business Rules Summary

| Rule              | Detail                                               |
| ----------------- | ---------------------------------------------------- |
| No self-selection | Students don't browse or choose jobs                 |
| Manual assignment | Helpi team assigns based on availability + judgment  |
| Decline window    | >24h before service, must provide reason             |
| Minimum service   | 1 hour                                               |
| Working hours     | 08:00 – 20:00                                        |
| Rating            | Seniors rate students (not vice versa)               |
| Payment           | Students earn per completed service (tracked in app) |

---

## 8. Senior vs. Student App Comparison

| Aspect             | Senior App                      | Student App                             |
| ------------------ | ------------------------------- | --------------------------------------- |
| **Role**           | Orders services                 | Receives & fulfills services            |
| **Tab 1**          | "Naruči" (order wizard)         | "Raspored" (assigned jobs calendar)     |
| **Tab 2**          | "Narudžbe" (my orders)          | "Poruke" (chat)                         |
| **Tab 3**          | "Poruke" (chat with support)    | "Statistika" (earnings, stats)          |
| **Tab 4**          | "Profil" (personal data, cards) | "Profil" (data, availability, settings) |
| **Unique feature** | Creates orders                  | Sets availability, can decline          |
| **Rating**         | Rates students                  | Receives ratings                        |
| **Payment**        | Pays for service                | Earns from service                      |

---

## 9. Current Limitations (Prototype Phase)

- **No backend** — all data is in-memory (21 mock jobs), resets on app restart
- **No real auth** — login is mock (any tap logs in)
- **No push notifications** — students won't be notified of new assignments
- **No payment integration** — earnings tracking not yet implemented
- **Chat is placeholder** — no real messaging functionality
- **Social login removed** — only email/password mock login

These will be addressed as the app moves from prototype to production.

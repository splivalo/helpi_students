# Helpi — Kontekst Projekta

> Ovaj dokument daje novom chatu/agentu KOMPLETAN kontekst o projektu Helpi.
> Pročitaj ga zajedno s DESIGN_SYSTEM.md i imat ćeš sve što ti treba.

---

## 1. Što je Helpi?

**Helpi** je platforma koja spaja **starije osobe (seniore)** sa **studentima** koji im pružaju svakodnevnu pomoć.

- Seniori (ili njihovi ukućani) naručuju usluge: kupovina, pratnja, čišćenje, društvo, tehnološka pomoć itd.
- Studenti prihvaćaju narudžbe, dolaze kod seniora, obavljaju uslugu i zarađuju.

**Analogija:** Uber, ali za svakodnevnu pomoć starijima. Uber ima 2 app-e (putnik + vozač), Helpi ima 2 app-e (senior + student).

---

## 2. Arhitektura — 2 Odvojene Aplikacije

### Helpi Senior (gotova)
- **Što radi:** Senior naručuje pomoć
- **Ekrani:** Login → Naruči pomoć → Moje narudžbe (3 taba) → Chat s podrškom → Profil
- **Projekt:** `helpi_senior/`
- **Repo:** `splivalo/helpi_students_2.0`, branch `main`

### Helpi Student (za napraviti)
- **Što radi:** Student prima i obavlja narudžbe
- **Ekrani (plan):**
  - Login/Register (ISTI dizajn kao senior)
  - Dashboard — lista dolazećih narudžbi za prihvaćanje
  - Moje narudžbe — prihvaćene narudžbe i raspored
  - Chat — komunikacija sa seniorima / podrškom
  - Profil — osobni podaci, zarada, dostupnost, ocjene
- **Isti dizajn sustav:** Boje, border radius, gumbi, kartice, fontovi — SVE isto kao senior app
- **Dijeli assets:** Logo, SVG ikone, social login SVG-ovi

---

## 3. Struktura Senior App-a (referenca za student)

```
lib/
├── main.dart                        # Entry point
├── app/
│   ├── app.dart                     # Root widget, auth state, locale
│   ├── main_shell.dart              # BottomNavigationBar (4 taba)
│   └── theme.dart                   # CENTRALIZIRANI theme — SVE boje i stilovi
├── core/
│   ├── l10n/
│   │   ├── app_strings.dart         # i18n (HR + EN) — Gemini Hybrid pattern
│   │   └── locale_notifier.dart     # ValueNotifier<Locale>
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── login_screen.dart    # Login/Register s social auth
│   ├── order/
│   │   └── presentation/
│   │       ├── order_screen.dart    # "Naruči pomoć" entry point
│   │       └── order_flow_screen.dart # 3-step wizard (Kada → Što → Pregled)
│   ├── booking/
│   │   ├── data/
│   │   │   └── order_model.dart     # Order model + OrdersNotifier + mock data
│   │   └── presentation/
│   │       ├── orders_screen.dart   # Lista narudžbi (3 taba)
│   │       └── order_detail_screen.dart # Detalji narudžbe + ocjenjivanje
│   ├── chat/
│   │   └── presentation/
│   │       └── chat_list_screen.dart # Chat s Helpi podrškom
│   ├── profile/
│   │   └── presentation/
│   │       └── profile_screen.dart  # Profil s sekcijama
│   ├── payment/
│   └── reviews/
├── shared/
│   └── widgets/
└── di/
```

---

## 4. Ključni Patterini (koristi iste u student app-u)

### 4.1 i18n — Gemini Hybrid Pattern
- **NIKAD** hardkodirati tekst u widgete
- Sve ide kroz `AppStrings` klasu
- `_localizedValues` mapa s HR i EN
- Static getteri: `static String get loginTitle => _t('loginTitle');`
- Parametrizirani: `static String orderNumber(String number) => _t('orderNumber', params: {'number': number});`

### 4.2 Auth Flow (mock)
```
LoginScreen (onLoginSuccess callback)
    ↓ klik Login/Register
_isLoggedIn = true → MainShell prikazan
    ↓ klik Logout u profilu
_isLoggedIn = false → LoginScreen prikazan
```
- Nema prave autentikacije — sve je UI prototip
- Social buttoni (Google, Apple, Facebook) svi zovu `onLoginSuccess`

### 4.3 Locale Management
```
LocaleNotifier (ValueNotifier<Locale>)
    ↓ setLocale('HR' ili 'EN')
AppStrings.setLocale(locale)
    ↓
ValueListenableBuilder na MaterialApp rebuilda UI
```

### 4.4 Navigacija
- `MainShell` — `IndexedStack` + `BottomNavigationBar`
- 4 taba: Naruči | Narudžbe | Poruke | Profil
- Student app će imati drugačije tabove, ali ISTI pattern

### 4.5 State Management
- `ValueNotifier` + `ValueListenableBuilder` (lokale, narudžbe)
- `setState` za lokalni UI state
- Nema Riverpod/Bloc/Provider — jednostavno i čisto

### 4.6 Async Safety
- Obavezan `if (!context.mounted) return;` nakon svakog `await` u UI sloju

---

## 5. Student App — Razlike od Senior-a

| Aspekt | Senior | Student |
|--------|--------|---------|
| **Uloga** | Naručuje usluge | Prima i obavlja narudžbe |
| **Tab 1** | "Naruči" (wizard za novu narudžbu) | "Dashboard" (lista novih narudžbi za prihvaćanje) |
| **Tab 2** | "Narudžbe" (moje narudžbe, 3 taba) | "Raspored" (prihvaćene narudžbe, kalendar) |
| **Tab 3** | "Poruke" (chat s podrškom) | "Poruke" (chat sa seniorima + podrška) |
| **Tab 4** | "Profil" (osobni podaci, kartice) | "Profil" (osobni podaci, zarada, dostupnost, ocjene) |
| **Order flow** | Kreira narudžbu | Prihvaća/odbija narudžbu |
| **Ocjenjivanje** | Ocjenjuje studente | Prima ocjene od seniora |
| **Plaćanje** | Plaća za uslugu | Prima uplatu za uslugu |

---

## 6. Usluge koje Helpi nudi

| Ključ | HR | EN |
|-------|-----|-----|
| `serviceShopping` | Kupovina | Shopping |
| `serviceHousehold` | Kućanstvo | Household |
| `serviceCompanionship` | Pratnja | Companionship |
| `serviceActivities` | Aktivnosti | Activities |
| `serviceTechHelp` | Tehnologija | Tech Help |
| `servicePets` | Ljubimci | Pets |

Plus u order flow-u: Pomoć u kući, Društvo, Šetnja, Ostalo

---

## 7. Mock Data Pattern

Trenutno SVE je mock data — nema backenda.
- `OrdersNotifier` (ValueNotifier) drži listu narudžbi u memoriji
- Studenti su hardkodirani s imenima, slikama (`student_1.jpg` itd.), ocjenama
- Slike studenata u `assets/images/`
- Order statusi: `processing` → `active` → `completed`

Za student app: isti pristup — mock data, bez backenda, čisti UI prototip.

---

## 8. Git & Repo

- **Repo:** `splivalo/helpi_students_2.0`
- **Branch:** `main`
- **Commit format:** `feat/fix/refactor: opis (rezultat: X errors → Y errors)`

---

## 9. Kodeks Rada (pravila za agenta)

Ova pravila su u `kodeks rada za fakturist projekt.instructions.md` i MORAJU se poštovati:

1. **Pre-flight check:** `dart analyze` prije i poslije svake izmjene
2. **0 linter issues:** Nikad `// ignore`, nikad `dynamic` bez casta
3. **Nema hardkodiranja teksta:** Sve kroz `AppStrings`
4. **Async safety:** `if (!context.mounted) return;` nakon `await`
5. **Incremental changes:** Jedan fajl po jedan, čekaj potvrdu
6. **Bez tehničkog duga:** Pobriši test skripte nakon korištenja
7. **Manual UI testing:** Napiši upute za testiranje
8. **Verification protocol:** 3-5 koraka za ručnu provjeru
9. **Živa dokumentacija:** Održavaj PROGRESS.md
10. **Roadmap disciplina:** Ne započinji task bez izričite potvrde

---

## 10. Kako Početi Student App

### Korak 1: Novi Flutter projekt
```bash
flutter create helpi_student
```

### Korak 2: Kopiraj iz senior app-a
- `theme.dart` → `lib/app/theme.dart` (IDENTIČAN)
- `app_strings.dart` strukturu → ali s drugim stringovima za studenta
- `locale_notifier.dart` → `lib/core/l10n/`
- SVG assete → `assets/images/` (logo, social ikone, service ikone)
- `login_screen.dart` → `lib/features/auth/` (IDENTIČAN ili gotovo identičan)

### Korak 3: Dodaj dependencies
```yaml
flutter_svg: ^2.2.3
flutter_localizations:
  sdk: flutter
```

### Korak 4: Struktura foldera
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── main_shell.dart     # Drugačiji tabovi!
│   └── theme.dart          # Kopija iz seniora
├── core/
│   └── l10n/
│       ├── app_strings.dart
│       └── locale_notifier.dart
├── features/
│   ├── auth/               # Login — gotovo identičan
│   ├── dashboard/          # NOVO — lista narudžbi za prihvaćanje
│   ├── schedule/           # NOVO — moj raspored
│   ├── chat/               # Slično senioru ali s višestruke konverzacije
│   └── profile/            # Drugačije sekcije (zarada, dostupnost)
```

### Korak 5: U novom chatu reci
> "Pročitaj DESIGN_SYSTEM.md i PROJECT_CONTEXT.md u root-u projekta. Radimo student app za Helpi. Koristi ISTI dizajn sustav. Krećemo s [ekran koji želiš]."

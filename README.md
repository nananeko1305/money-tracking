# Money Tracking (Flutter)

A monthly budget tracking app built with Flutter. Rewritten from an earlier
Expo/React Native version, which is preserved on the `expo-legacy` branch.

## Features

- **Budget** — categories with budget and spending, progress bars, totals and
  days until reset (in dinars).
- **Monthly income** — enter your salary (or total monthly budget) to see how
  much is allocated to categories or moved to savings, what is unallocated and
  what is left after spending. It carries over to the next month.
- **Fixed costs** — recurring monthly items (rent, utilities, subscriptions)
  with their amounts and the monthly total; kept across months.
- **Savings** — funds (e.g. emergency fund, holiday) with an optional opening
  balance and goal; record deposits and withdrawals, with history per fund.
  Net savings for the month count against the monthly income.
- **Loans** — who owes you and whom you owe, with repayments, what is left and
  the net balance; settled loans are kept in a collapsed section.
- **Lists** — from the drawer: named checklists (groceries, a trip, car
  parts) with items, an optional planned amount each and a tick when bought or
  done; the total and what is left sit on top. Lists are plans: they stay out
  of the budget and the reports, and nothing on them resets by itself.
- **Reports** — monthly archive (last 12 months), saved automatically on the
  1st of each month.
- **Transaction history** — every expense is stored individually (amount,
  description, date); tap a category to see the list, swipe left to delete.
- **Category editing** — edit button to change a category's name and budget.
- **Export / Import** — from the drawer; back up to a JSON file and import it
  back.
- **Update notifications** — every new release sends a push notification
  (Firebase Cloud Messaging); tapping it offers the APK download.
- **Drawer** — navigation plus all options (export/import, language, theme).
- **Themes** — light and dark, green/gold palette (green like paper money,
  gold like gold); System / Light / Dark, remembered between launches.
- **Languages** — Serbian (Latin) and English, toggled from the drawer and
  remembered.

## Accounts and data

- **Sign-in is required** (email + password, Firebase Auth). There is no
  registration in the app: the admin creates accounts in the Firebase console
  (Authentication → Users → Add user). A forgotten password is reset by email
  from the login screen; the drawer has *Change password* and *Sign out*.
- **Data lives in Cloud Firestore** under `users/{uid}/…` (project
  `money-tracking-261007`, location `europe-west3`), so the same account sees
  the same data on every phone. Firestore keeps an offline cache: the app works
  without a connection and syncs when it is back.
- **Security rules** (`firestore.rules`) let an account read and write only its
  own documents. Deploy after changing them:
  `firebase deploy --only firestore --project money-tracking-261007`.
- **Data from before accounts existed** (kept on the phone in
  `shared_preferences`) is offered for moving to the account the first time an
  empty account signs in on that phone.
- Language and theme settings stay on the phone (`shared_preferences`).

## Structure

```
lib/
├── main.dart                        # App root, navigation, drawer, settings
├── app_scope.dart                   # InheritedWidget: language, theme, strings
├── theme.dart                       # Color palette (ThemeExtension) and themes
├── l10n/strings.dart                # Localized strings + locale-aware formatting
├── models/budget.dart               # Category, Transaction, MonthlyReport, AppData
├── services/
│   ├── storage.dart                 # Persistence + monthly reset
│   └── backup.dart                  # Export (share) / import (file picker)
├── screens/
│   ├── dashboard_screen.dart        # "Budget" screen
│   ├── reports_screen.dart          # "Reports" screen
│   └── category_detail_screen.dart  # Transaction history
└── widgets/
    └── category_card.dart           # Category card
```

## Running

```bash
flutter pub get
flutter run                    # on a connected device / emulator
flutter build apk --release    # release APK for Android
flutter test                   # tests
```

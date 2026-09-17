# Money Tracking (Flutter)

A monthly budget tracking app built with Flutter. Rewritten from an earlier
Expo/React Native version, which is preserved on the `expo-legacy` branch.

## Features

- **Budget** — categories with budget and spending, progress bars, totals and
  days until reset (in dinars).
- **Reports** — monthly archive (last 12 months), saved automatically on the
  1st of each month.
- **Transaction history** — every expense is stored individually (amount,
  description, date); tap a category to see the list, swipe left to delete.
- **Category editing** — edit button to change a category's name and budget.
- **Export / Import** — from the drawer; back up to a JSON file and import it
  back.
- **Drawer** — navigation plus all options (export/import, language, theme).
- **Themes** — light and dark, green/gold palette (green like paper money,
  gold like gold); System / Light / Dark, remembered between launches.
- **Languages** — Serbian (Latin) and English, toggled from the drawer and
  remembered.

App data and settings (language, theme) are stored locally via
`shared_preferences`.

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

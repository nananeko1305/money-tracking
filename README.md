# Money Tracking (Flutter)

Aplikacija za praćenje mesečnog budžeta, napisana u Flutter-u. Prepisana iz
ranije Expo/React Native verzije — ona je sačuvana u git grani `expo-legacy`.

## Funkcionalnosti

- **Budžet** — kategorije sa budžetom i potrošnjom, progress barovi, ukupne
  cifre, dani do reseta (u dinarima).
- **Izveštaji** — mesečna arhiva (poslednjih 12 meseci), automatski se čuva
  svakog 1. u mesecu.
- **Istorija transakcija** — svaki trošak se pamti pojedinačno (iznos, opis,
  datum); tapni na kategoriju da vidiš listu, prevuci ulevo za brisanje.
- **Izmena kategorije** — edit dugme za izmenu naziva i budžeta.
- **Export / Import** — u draweru; backup u JSON fajl i uvoz nazad.
- **Drawer** — navigacija + sve opcije (izvoz/uvoz, jezik, tema).
- **Teme** — svetla i tamna, zeleno-zlatna paleta (zeleno = papirni novac,
  zlatno = zlato); izbor Sistemska / Svetla / Tamna, pamti se.
- **Jezici** — srpski (latinica) i engleski, prekidač u draweru, pamti se.

Podaci i podešavanja (jezik, tema) se čuvaju lokalno preko
`shared_preferences`.

## Struktura

```
lib/
├── main.dart                       # App root, navigacija, export/import meni
├── theme.dart                      # Boje i teme
├── format.dart                     # Formatiranje valute i datuma
├── models/budget.dart             # Category, Transaction, MonthlyReport, AppData
├── services/
│   ├── storage.dart               # Perzistencija + mesečni reset
│   └── backup.dart                # Export (share) / import (file picker)
├── screens/
│   ├── dashboard_screen.dart      # Ekran "Budžet"
│   ├── reports_screen.dart        # Ekran "Izveštaji"
│   └── category_detail_screen.dart # Istorija transakcija
└── widgets/
    └── category_card.dart         # Kartica kategorije
```

## Pokretanje

```bash
flutter pub get
flutter run                    # na povezanom uređaju / emulatoru
flutter build apk --release    # release APK za Android
flutter test                   # testovi
```

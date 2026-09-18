import 'strings.dart';

/// Serbian (Latin) translations.
class StringsSr extends AppStrings {
  const StringsSr();

  @override
  String get localeCode => 'sr';
  @override
  String get appName => 'Money Tracking';
  @override
  String get navBudget => 'Budžet';
  @override
  String get navReports => 'Izveštaji';
  @override
  String get totalBudget => 'Ukupan budžet:';
  @override
  String get totalSpent => 'Ukupno potrošeno:';
  @override
  String get remaining => 'Preostalo:';
  @override
  String get spent => 'Potrošeno:';
  @override
  String get budget => 'Budžet:';
  @override
  String get addCategory => 'Dodaj kategoriju';
  @override
  String get newCategory => 'Nova kategorija';
  @override
  String get editCategory => 'Izmeni kategoriju';
  @override
  String get name => 'Naziv';
  @override
  String get nameHint => 'npr. Hrana';
  @override
  String get budgetHint => 'npr. 40000';
  @override
  String get cancel => 'Otkaži';
  @override
  String get save => 'Sačuvaj';
  @override
  String get invalidCategory => 'Unesi validan naziv i budžet';
  @override
  String get deleteCategoryTitle => 'Obriši kategoriju';
  @override
  String get delete => 'Obriši';
  @override
  String get amountHint => 'Iznos';
  @override
  String get descHint => 'Opis (opciono)';
  @override
  String get invalidAmount => 'Unesi validan iznos';
  @override
  String get expense => 'Trošak';
  @override
  String get noTransactions => 'Nema zabeleženih troškova';
  @override
  String get categoryNotFound => 'Kategorija nije pronađena';
  @override
  String get reportsTitle => 'Izveštaji';
  @override
  String get archiveSubtitle => 'Arhiva mesečnih budžeta (poslednja godina)';
  @override
  String get noReports => 'Nema sačuvanih izveštaja';
  @override
  String get noReportsSub => 'Izveštaji se automatski čuvaju svakog 1. u mesecu';
  @override
  String get remainingAtEnd => 'Preostalo na kraju:';
  @override
  String get byCategory => 'Po kategorijama:';
  @override
  String get dataSection => 'Podaci';
  @override
  String get exportData => 'Izvezi podatke';
  @override
  String get importData => 'Uvezi podatke';
  @override
  String get settingsSection => 'Podešavanja';
  @override
  String get language => 'Jezik';
  @override
  String get theme => 'Tema';
  @override
  String get themeSystem => 'Sistemska';
  @override
  String get themeLight => 'Svetla';
  @override
  String get themeDark => 'Tamna';
  @override
  String get importConfirmTitle => 'Uvezi podatke';
  @override
  String get importConfirmMsg =>
      'Uvoz će zameniti sve trenutne podatke sačuvanim backup-om. Da li želiš da nastaviš?';
  @override
  String get import => 'Uvezi';
  @override
  String get importSuccess => 'Podaci su uspešno uvezeni';
  @override
  String get importInvalid => 'Neispravan backup fajl';
  @override
  String get shareUnavailable => 'Deljenje nije dostupno na ovom uređaju';
  @override
  String get exportSaved => 'Sačuvano u fasciklu Download/MoneyTracking';
  @override
  String get exportFailed => 'Čuvanje nije uspelo';
  @override
  String get storagePermissionDenied => 'Pristup fajlovima je odbijen';
  @override
  String get restorePromptTitle => 'Vrati podatke';
  @override
  String get restorePromptMsg =>
      'Ako imaš sačuvan backup na telefonu, mogu da ga pronađem i uvezem. Da proverim?';
  @override
  String get check => 'Proveri';
  @override
  String get notNow => 'Ne sada';
  @override
  String get restoreFoundTitle => 'Pronađen backup';
  @override
  String get noBackupsFound => 'Nema sačuvanih backup-ova';
  @override
  String get updateAvailableTitle => 'Nova verzija';
  @override
  String get download => 'Preuzmi';
  @override
  String get howItWorks => 'Kako radi';
  @override
  String get onbWelcomeTitle => 'Dobrodošli 👋';
  @override
  String get onbWelcomeBody =>
      'Money Tracking vam pomaže da pratite mesečni budžet. Svi podaci ostaju na vašem telefonu — privatno i offline.';
  @override
  String get onbCategoriesTitle => 'Napravite kategorije';
  @override
  String get onbCategoriesBody =>
      'Dodajte kategorije poput Hrane ili Prevoza i zadajte mesečni budžet za svaku.';
  @override
  String get onbExpensesTitle => 'Beležite troškove';
  @override
  String get onbExpensesBody =>
      'Upisujte troškove u kategoriju. Aplikacija prati potrošeno i preostalo, uz jasnu traku napretka.';
  @override
  String get onbReportsTitle => 'Izveštaji i backup';
  @override
  String get onbReportsBody =>
      'Svakog 1. u mesecu budžet se arhivira kao izveštaj. Izvezite podatke na telefon i vratite ih kad god zatreba.';
  @override
  String get onbSkip => 'Preskoči';
  @override
  String get onbNext => 'Dalje';
  @override
  String get onbStart => 'Kreni';

  @override
  List<String> get monthNames => const [
        'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Jun',
        'Jul', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar',
      ];
  @override
  String get currency => 'din';

  @override
  String daysUntilReset(int n) => '$n ${n == 1 ? 'dan' : 'dana'} do reseta';

  @override
  String deleteCategoryMsg(String categoryName) =>
      'Da li si siguran da želiš da obrišeš "$categoryName"?';

  @override
  String updateAvailableMsg(String version) =>
      'Dostupna je nova verzija ($version). Preuzmi je sada?';

  @override
  String restoreFoundMsg(String isoDate) =>
      'Pronađen je backup od ${date(isoDate)}. Želiš li da ga uvezeš?';

  @override
  String savedOn(String isoDate) => 'Sačuvano: ${date(isoDate)}';

  @override
  String spentPercent(String percent) => 'Potrošeno: $percent%';
}

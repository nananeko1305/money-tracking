import 'package:intl/intl.dart';

/// All user-facing strings plus locale-aware formatting, for the two supported
/// languages: Serbian (Latin) and English.
class AppStrings {
  static const List<String> _monthsSr = [
    'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Jun',
    'Jul', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar',
  ];

  static const List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const AppStrings sr = AppStrings._(
    localeCode: 'sr',
    appName: 'Money Tracking',
    navBudget: 'Budžet',
    navReports: 'Izveštaji',
    totalBudget: 'Ukupan budžet:',
    totalSpent: 'Ukupno potrošeno:',
    remaining: 'Preostalo:',
    spent: 'Potrošeno:',
    budget: 'Budžet:',
    addCategory: 'Dodaj kategoriju',
    newCategory: 'Nova kategorija',
    editCategory: 'Izmeni kategoriju',
    name: 'Naziv',
    nameHint: 'npr. Hrana',
    budgetHint: 'npr. 40000',
    cancel: 'Otkaži',
    save: 'Sačuvaj',
    invalidCategory: 'Unesi validan naziv i budžet',
    deleteCategoryTitle: 'Obriši kategoriju',
    delete: 'Obriši',
    amountHint: 'Iznos',
    descHint: 'Opis (opciono)',
    invalidAmount: 'Unesi validan iznos',
    expense: 'Trošak',
    noTransactions: 'Nema zabeleženih troškova',
    categoryNotFound: 'Kategorija nije pronađena',
    reportsTitle: 'Izveštaji',
    archiveSubtitle: 'Arhiva mesečnih budžeta (poslednja godina)',
    noReports: 'Nema sačuvanih izveštaja',
    noReportsSub: 'Izveštaji se automatski čuvaju svakog 1. u mesecu',
    remainingAtEnd: 'Preostalo na kraju:',
    byCategory: 'Po kategorijama:',
    dataSection: 'Podaci',
    exportData: 'Izvezi podatke',
    importData: 'Uvezi podatke',
    settingsSection: 'Podešavanja',
    language: 'Jezik',
    theme: 'Tema',
    themeSystem: 'Sistemska',
    themeLight: 'Svetla',
    themeDark: 'Tamna',
    importConfirmTitle: 'Uvezi podatke',
    importConfirmMsg:
        'Uvoz će zameniti sve trenutne podatke sačuvanim backup-om. Da li želiš da nastaviš?',
    import: 'Uvezi',
    importSuccess: 'Podaci su uspešno uvezeni',
    importInvalid: 'Neispravan backup fajl',
    shareUnavailable: 'Deljenje nije dostupno na ovom uređaju',
    monthNames: _monthsSr,
    currency: 'din',
  );
  static const AppStrings en = AppStrings._(
    localeCode: 'en',
    appName: 'Money Tracking',
    navBudget: 'Budget',
    navReports: 'Reports',
    totalBudget: 'Total budget:',
    totalSpent: 'Total spent:',
    remaining: 'Remaining:',
    spent: 'Spent:',
    budget: 'Budget:',
    addCategory: 'Add category',
    newCategory: 'New category',
    editCategory: 'Edit category',
    name: 'Name',
    nameHint: 'e.g. Food',
    budgetHint: 'e.g. 40000',
    cancel: 'Cancel',
    save: 'Save',
    invalidCategory: 'Enter a valid name and budget',
    deleteCategoryTitle: 'Delete category',
    delete: 'Delete',
    amountHint: 'Amount',
    descHint: 'Description (optional)',
    invalidAmount: 'Enter a valid amount',
    expense: 'Expense',
    noTransactions: 'No recorded expenses',
    categoryNotFound: 'Category not found',
    reportsTitle: 'Reports',
    archiveSubtitle: 'Monthly budget archive (last year)',
    noReports: 'No saved reports',
    noReportsSub: 'Reports are saved automatically on the 1st of each month',
    remainingAtEnd: 'Remaining at end:',
    byCategory: 'By category:',
    dataSection: 'Data',
    exportData: 'Export data',
    importData: 'Import data',
    settingsSection: 'Settings',
    language: 'Language',
    theme: 'Theme',
    themeSystem: 'System',
    themeLight: 'Light',
    themeDark: 'Dark',
    importConfirmTitle: 'Import data',
    importConfirmMsg:
        'Importing will replace all current data with the backup. Do you want to continue?',
    import: 'Import',
    importSuccess: 'Data imported successfully',
    importInvalid: 'Invalid backup file',
    shareUnavailable: 'Sharing is not available on this device',
    monthNames: _monthsEn,
    currency: 'din',
  );

  final String localeCode;
  // Navigation / app
  final String appName;
  final String navBudget;
  final String navReports;
  // Dashboard
  final String totalBudget;
  final String totalSpent;
  final String remaining;
  final String spent;
  final String budget;
  final String addCategory;
  final String newCategory;
  final String editCategory;
  final String name;
  final String nameHint;
  final String budgetHint;
  final String cancel;
  final String save;
  final String invalidCategory;
  final String deleteCategoryTitle;

  final String delete;
  final String amountHint;
  final String descHint;

  final String invalidAmount;
  // Category detail
  final String expense;
  final String noTransactions;
  final String categoryNotFound;
  // Reports
  final String reportsTitle;
  final String archiveSubtitle;

  final String noReports;
  final String noReportsSub;
  final String remainingAtEnd;
  final String byCategory;
  // Drawer / settings
  final String dataSection;
  final String exportData;
  final String importData;
  final String settingsSection;
  final String language;
  final String theme;
  final String themeSystem;
  final String themeLight;
  final String themeDark;
  final String importConfirmTitle;
  final String importConfirmMsg;

  final String import;
  final String importSuccess;

  final String importInvalid;

  final String shareUnavailable;

  final List<String> monthNames;

  final String currency; // "din"

  const AppStrings._({
    required this.localeCode,
    required this.appName,
    required this.navBudget,
    required this.navReports,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.spent,
    required this.budget,
    required this.addCategory,
    required this.newCategory,
    required this.editCategory,
    required this.name,
    required this.nameHint,
    required this.budgetHint,
    required this.cancel,
    required this.save,
    required this.invalidCategory,
    required this.deleteCategoryTitle,
    required this.delete,
    required this.amountHint,
    required this.descHint,
    required this.invalidAmount,
    required this.expense,
    required this.noTransactions,
    required this.categoryNotFound,
    required this.reportsTitle,
    required this.archiveSubtitle,
    required this.noReports,
    required this.noReportsSub,
    required this.remainingAtEnd,
    required this.byCategory,
    required this.dataSection,
    required this.exportData,
    required this.importData,
    required this.settingsSection,
    required this.language,
    required this.theme,
    required this.themeSystem,
    required this.themeLight,
    required this.themeDark,
    required this.importConfirmTitle,
    required this.importConfirmMsg,
    required this.import,
    required this.importSuccess,
    required this.importInvalid,
    required this.shareUnavailable,
    required this.monthNames,
    required this.currency,
  });

  // ---- Formatting helpers (locale-aware) ----

  String amount(num value) =>
      NumberFormat('#,##0.##', localeCode).format(value);

  String date(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${_two(d.day)}.${_two(d.month)}.${d.year}.';
  }

  String dateTime(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${date(iso)} ${_two(d.hour)}:${_two(d.minute)}';
  }

  String daysUntilReset(int n) {
    if (localeCode == 'en') {
      return '$n ${n == 1 ? 'day' : 'days'} until reset';
    }
    return '$n ${n == 1 ? 'dan' : 'dana'} do reseta';
  }

  String deleteCategoryMsg(String categoryName) => localeCode == 'en'
      ? 'Are you sure you want to delete "$categoryName"?'
      : 'Da li si siguran da želiš da obrišeš "$categoryName"?';

  String din(num value) => '${amount(value)} $currency';

  String monthYear(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final month = int.tryParse(parts[1]) ?? 1;
    return '${monthNames[(month - 1).clamp(0, 11)]} ${parts[0]}';
  }

  String savedOn(String isoDate) => localeCode == 'en'
      ? 'Saved: ${date(isoDate)}'
      : 'Sačuvano: ${date(isoDate)}';
  String spentPercent(String percent) =>
      localeCode == 'en' ? 'Spent: $percent%' : 'Potrošeno: $percent%';

  static AppStrings of(String code) => code == 'en' ? en : sr;

  static String _two(int v) => v.toString().padLeft(2, '0');
}

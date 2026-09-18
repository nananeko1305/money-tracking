import 'package:intl/intl.dart';

import 'strings_en.dart';
import 'strings_sr.dart';

/// Contract for all user-facing strings plus locale-aware formatting.
///
/// The actual translations live in one file per language: Serbian in
/// [StringsSr], English in [StringsEn]. Shared, language-neutral formatting
/// (numbers, dates) is implemented here.
abstract class AppStrings {
  const AppStrings();

  String get localeCode;
  // Navigation / app
  String get appName;
  String get navBudget;
  String get navReports;
  // Dashboard
  String get totalBudget;
  String get totalSpent;
  String get remaining;
  String get spent;
  String get budget;
  String get addCategory;
  String get newCategory;
  String get editCategory;
  String get name;
  String get nameHint;
  String get budgetHint;
  String get cancel;
  String get save;
  String get invalidCategory;
  String get deleteCategoryTitle;
  String get delete;
  String get amountHint;
  String get descHint;
  String get invalidAmount;
  // Category detail
  String get expense;
  String get noTransactions;
  String get categoryNotFound;
  // Reports
  String get reportsTitle;
  String get archiveSubtitle;
  String get noReports;
  String get noReportsSub;
  String get remainingAtEnd;
  String get byCategory;
  // Drawer / settings
  String get dataSection;
  String get exportData;
  String get importData;
  String get settingsSection;
  String get language;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get importConfirmTitle;
  String get importConfirmMsg;
  String get import;
  String get importSuccess;
  String get importInvalid;
  String get shareUnavailable;
  // Backup save / restore
  String get exportSaved;
  String get exportFailed;
  String get storagePermissionDenied;
  String get restorePromptTitle;
  String get restorePromptMsg;
  String get check;
  String get notNow;
  String get restoreFoundTitle;
  String get noBackupsFound;
  // Update check
  String get updateAvailableTitle;
  String get download;
  // Onboarding
  String get howItWorks;
  String get onbWelcomeTitle;
  String get onbWelcomeBody;
  String get onbCategoriesTitle;
  String get onbCategoriesBody;
  String get onbExpensesTitle;
  String get onbExpensesBody;
  String get onbReportsTitle;
  String get onbReportsBody;
  String get onbSkip;
  String get onbNext;
  String get onbStart;

  List<String> get monthNames;
  String get currency; // "din"

  // ---- Locale-specific phrases (implemented per language) ----

  String daysUntilReset(int n);
  String deleteCategoryMsg(String categoryName);
  String updateAvailableMsg(String version);
  String restoreFoundMsg(String isoDate);
  String savedOn(String isoDate);
  String spentPercent(String percent);

  // ---- Shared, language-neutral formatting ----

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

  String din(num value) => '${amount(value)} $currency';

  String monthYear(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final month = int.tryParse(parts[1]) ?? 1;
    return '${monthNames[(month - 1).clamp(0, 11)]} ${parts[0]}';
  }

  static AppStrings of(String code) =>
      code == 'en' ? const StringsEn() : const StringsSr();

  static String _two(int v) => v.toString().padLeft(2, '0');
}

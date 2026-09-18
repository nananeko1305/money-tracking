import 'strings.dart';

/// English translations.
class StringsEn extends AppStrings {
  const StringsEn();

  @override
  String get localeCode => 'en';
  @override
  String get appName => 'Money Tracking';
  @override
  String get navBudget => 'Budget';
  @override
  String get navReports => 'Reports';
  @override
  String get totalBudget => 'Total budget:';
  @override
  String get totalSpent => 'Total spent:';
  @override
  String get remaining => 'Remaining:';
  @override
  String get spent => 'Spent:';
  @override
  String get budget => 'Budget:';
  @override
  String get addCategory => 'Add category';
  @override
  String get newCategory => 'New category';
  @override
  String get editCategory => 'Edit category';
  @override
  String get name => 'Name';
  @override
  String get nameHint => 'e.g. Food';
  @override
  String get budgetHint => 'e.g. 40000';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get invalidCategory => 'Enter a valid name and budget';
  @override
  String get deleteCategoryTitle => 'Delete category';
  @override
  String get delete => 'Delete';
  @override
  String get amountHint => 'Amount';
  @override
  String get descHint => 'Description (optional)';
  @override
  String get invalidAmount => 'Enter a valid amount';
  @override
  String get expense => 'Expense';
  @override
  String get noTransactions => 'No recorded expenses';
  @override
  String get categoryNotFound => 'Category not found';
  @override
  String get reportsTitle => 'Reports';
  @override
  String get archiveSubtitle => 'Monthly budget archive (last year)';
  @override
  String get noReports => 'No saved reports';
  @override
  String get noReportsSub =>
      'Reports are saved automatically on the 1st of each month';
  @override
  String get remainingAtEnd => 'Remaining at end:';
  @override
  String get byCategory => 'By category:';
  @override
  String get dataSection => 'Data';
  @override
  String get exportData => 'Export data';
  @override
  String get importData => 'Import data';
  @override
  String get settingsSection => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get importConfirmTitle => 'Import data';
  @override
  String get importConfirmMsg =>
      'Importing will replace all current data with the backup. Do you want to continue?';
  @override
  String get import => 'Import';
  @override
  String get importSuccess => 'Data imported successfully';
  @override
  String get importInvalid => 'Invalid backup file';
  @override
  String get shareUnavailable => 'Sharing is not available on this device';
  @override
  String get exportSaved => 'Saved to Download/MoneyTracking';
  @override
  String get exportFailed => 'Save failed';
  @override
  String get storagePermissionDenied => 'File access was denied';
  @override
  String get restorePromptTitle => 'Restore data';
  @override
  String get restorePromptMsg =>
      'If you have a saved backup on your phone, I can find and import it. Check now?';
  @override
  String get check => 'Check';
  @override
  String get notNow => 'Not now';
  @override
  String get restoreFoundTitle => 'Backup found';
  @override
  String get noBackupsFound => 'No saved backups found';
  @override
  String get updateAvailableTitle => 'Update available';
  @override
  String get download => 'Download';
  @override
  String get howItWorks => 'How it works';
  @override
  String get onbWelcomeTitle => 'Welcome 👋';
  @override
  String get onbWelcomeBody =>
      'Money Tracking helps you follow your monthly budget. All data stays on your phone — private and offline.';
  @override
  String get onbCategoriesTitle => 'Create categories';
  @override
  String get onbCategoriesBody =>
      'Add categories like Food or Transport and set a monthly budget for each.';
  @override
  String get onbExpensesTitle => 'Log expenses';
  @override
  String get onbExpensesBody =>
      'Add expenses to a category. The app tracks spent and remaining with a clear progress bar.';
  @override
  String get onbReportsTitle => 'Reports & backup';
  @override
  String get onbReportsBody =>
      'On the 1st of each month your budget is archived as a report. Export your data to the phone and restore it whenever you need.';
  @override
  String get onbSkip => 'Skip';
  @override
  String get onbNext => 'Next';
  @override
  String get onbStart => 'Get started';

  @override
  List<String> get monthNames => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
  @override
  String get currency => 'din';

  @override
  String daysUntilReset(int n) => '$n ${n == 1 ? 'day' : 'days'} until reset';

  @override
  String deleteCategoryMsg(String categoryName) =>
      'Are you sure you want to delete "$categoryName"?';

  @override
  String updateAvailableMsg(String version) =>
      'A new version ($version) is available. Download it now?';

  @override
  String restoreFoundMsg(String isoDate) =>
      'Found a backup from ${date(isoDate)}. Do you want to import it?';

  @override
  String savedOn(String isoDate) => 'Saved: ${date(isoDate)}';

  @override
  String spentPercent(String percent) => 'Spent: $percent%';
}

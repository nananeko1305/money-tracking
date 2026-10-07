/// Strings for signing in, the account section of the drawer, moving the
/// on-phone data to the account and sync errors. Mixed into [AppStrings];
/// each language implements it in its own file.
mixin AccountStrings {
  // Login
  String get loginSubtitle;
  String get email;
  String get password;
  String get invalidEmail;
  String get minChars6;
  String get signIn;
  String get wait;
  String get forgotPassword;
  String get resetSent;
  String get showPassword;
  // Account section
  String get accountSection;
  String get signOut;
  String get signOutTitle;
  String get signOutMsg;
  String get changePassword;
  String get currentPassword;
  String get newPassword;
  String get confirmPassword;
  String get requiredField;
  String get passwordsNoMatch;
  String get passwordChanged;
  // Moving the on-phone data to the account
  String get moveDataTitle;
  String get moveDataMsg;
  String get moveData;
  String get moveDataDone;
  // Loading the account's data
  String get retrying;
  // Errors
  String get errInvalidEmail;
  String get errWrongCredentials;
  String get errUserDisabled;
  String get errTooManyRequests;
  String get errNotEnabled;
  String get errWeakPassword;
  String get errNoNetwork;
  String get errPermission;
  String get errGeneric;
}

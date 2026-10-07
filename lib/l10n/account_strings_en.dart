import 'account_strings.dart';

/// English account strings.
mixin AccountStringsEn implements AccountStrings {
  @override
  String get loginSubtitle => 'Sign in with the account the admin made for you.';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get invalidEmail => 'Enter a valid email';
  @override
  String get minChars6 => 'At least 6 characters';
  @override
  String get signIn => 'Sign in';
  @override
  String get wait => 'Please wait...';
  @override
  String get forgotPassword => 'Forgot password?';
  @override
  String get resetSent => 'A password reset email has been sent.';
  @override
  String get showPassword => 'Show password';
  @override
  String get accountSection => 'Account';
  @override
  String get signOut => 'Sign out';
  @override
  String get signOutTitle => 'Sign out';
  @override
  String get signOutMsg =>
      'Sign out on this phone? Your data stays saved in your account.';
  @override
  String get changePassword => 'Change password';
  @override
  String get currentPassword => 'Current password';
  @override
  String get newPassword => 'New password';
  @override
  String get confirmPassword => 'Confirm new password';
  @override
  String get requiredField => 'Required';
  @override
  String get passwordsNoMatch => 'Passwords do not match';
  @override
  String get passwordChanged => 'Password changed.';
  @override
  String get moveDataTitle => 'Move data to your account';
  @override
  String get moveDataMsg =>
      'This phone has data from before. Move it to your account so it is '
      'available on every phone you sign in on?';
  @override
  String get moveData => 'Move';
  @override
  String get moveDataDone => 'Your data has been moved to your account.';
  @override
  String get retrying => 'Retrying...';
  @override
  String get errInvalidEmail => 'The email is not valid.';
  @override
  String get errWrongCredentials => 'Wrong email or password.';
  @override
  String get errUserDisabled => 'This account has been disabled.';
  @override
  String get errTooManyRequests =>
      'Too many attempts. Wait a little and try again.';
  @override
  String get errNotEnabled => 'Email sign-in is not enabled on the server.';
  @override
  String get errWeakPassword => 'The password is too weak (min. 6 characters).';
  @override
  String get errNoNetwork => 'No internet connection.';
  @override
  String get errPermission => 'You do not have permission to do that.';
  @override
  String get errGeneric => 'Something went wrong. Please try again.';
}

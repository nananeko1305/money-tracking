import 'share_strings.dart';

/// English share strings.
mixin ShareStringsEn implements ShareStrings {
  @override
  String get shareApp => 'Share the app';
  @override
  String get shareAppMsg =>
      'Scan the code with another phone to download the latest version.';
  @override
  String get shareAccountHint =>
      'Signing in needs an account made by the admin.';
  @override
  String get copyLink => 'Copy link';
  @override
  String get linkCopied => 'Link copied';
  @override
  String get close => 'Close';
}

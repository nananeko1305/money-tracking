import 'share_strings.dart';

/// Serbian (Latin) share strings.
mixin ShareStringsSr implements ShareStrings {
  @override
  String get shareApp => 'Podeli aplikaciju';
  @override
  String get shareAppMsg =>
      'Skeniraj kod drugim telefonom da preuzmeš najnoviju verziju.';
  @override
  String get shareAccountHint =>
      'Za prijavu je potreban nalog koji pravi admin.';
  @override
  String get copyLink => 'Kopiraj link';
  @override
  String get linkCopied => 'Link je kopiran';
  @override
  String get close => 'Zatvori';
}

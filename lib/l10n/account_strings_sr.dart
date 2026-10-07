import 'account_strings.dart';

/// Serbian (Latin) account strings.
mixin AccountStringsSr implements AccountStrings {
  @override
  String get loginSubtitle => 'Prijavi se nalogom koji ti je napravio admin.';
  @override
  String get email => 'Email';
  @override
  String get password => 'Lozinka';
  @override
  String get invalidEmail => 'Unesi ispravan email';
  @override
  String get minChars6 => 'Najmanje 6 karaktera';
  @override
  String get signIn => 'Prijavi se';
  @override
  String get wait => 'Sačekaj...';
  @override
  String get forgotPassword => 'Zaboravljena lozinka?';
  @override
  String get resetSent => 'Poslat je email za promenu lozinke.';
  @override
  String get showPassword => 'Prikaži lozinku';
  @override
  String get accountSection => 'Nalog';
  @override
  String get signOut => 'Odjavi se';
  @override
  String get signOutTitle => 'Odjava';
  @override
  String get signOutMsg =>
      'Odjaviti se sa ovog telefona? Podaci ostaju sačuvani na nalogu.';
  @override
  String get changePassword => 'Promeni lozinku';
  @override
  String get currentPassword => 'Trenutna lozinka';
  @override
  String get newPassword => 'Nova lozinka';
  @override
  String get confirmPassword => 'Potvrdi novu lozinku';
  @override
  String get requiredField => 'Obavezno polje';
  @override
  String get passwordsNoMatch => 'Lozinke se ne poklapaju';
  @override
  String get passwordChanged => 'Lozinka je promenjena.';
  @override
  String get moveDataTitle => 'Prenesi podatke na nalog';
  @override
  String get moveDataMsg =>
      'Na ovom telefonu postoje podaci od ranije. Da ih prenesem na tvoj nalog, '
      'da budu dostupni na svakom telefonu na kom se prijaviš?';
  @override
  String get moveData => 'Prenesi';
  @override
  String get moveDataDone => 'Podaci su preneti na nalog.';
  @override
  String get retrying => 'Pokušavam ponovo...';
  @override
  String get errInvalidEmail => 'Email nije ispravan.';
  @override
  String get errWrongCredentials => 'Pogrešan email ili lozinka.';
  @override
  String get errUserDisabled => 'Ovaj nalog je onemogućen.';
  @override
  String get errTooManyRequests =>
      'Previše pokušaja. Sačekaj malo pa pokušaj ponovo.';
  @override
  String get errNotEnabled => 'Prijava emailom nije uključena na serveru.';
  @override
  String get errWeakPassword => 'Lozinka je preslaba (min. 6 karaktera).';
  @override
  String get errNoNetwork => 'Nema internet konekcije.';
  @override
  String get errPermission => 'Nemaš dozvolu za ovu akciju.';
  @override
  String get errGeneric => 'Nešto nije u redu. Pokušaj ponovo.';
}

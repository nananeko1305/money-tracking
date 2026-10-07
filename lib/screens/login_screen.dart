import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/error_text.dart';
import '../services/auth_service.dart';
import '../services/saved_emails.dart';
import '../theme.dart';
import '../widgets/email_autocomplete_field.dart';

/// Email + password sign-in. Accounts are created by the admin only, so there
/// is no registration here; a forgotten password is reset by email.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, this.savedEmails});

  final AuthService auth;

  /// Injected by tests; defaults to the phone's saved emails.
  final SavedEmails? savedEmails;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final SavedEmails _saved = widget.savedEmails ?? SavedEmails();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  List<String> _savedEmails = const [];
  bool _busy = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _saved.load().then((list) {
      if (mounted) setState(() => _savedEmails = list);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _removeSaved(String email) async {
    final list = await _saved.remove(email);
    if (!mounted) return;
    setState(() => _savedEmails = list);
    // Nudge the text so the suggestion list rebuilds without the removed one.
    final value = _email.value;
    _email.value = value.copyWith(text: '${value.text} ');
    _email.value = value;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppScope.of(context).strings;
    setState(() => _busy = true);
    try {
      await widget.auth.signIn(_email.text, _password.text);
      await _saved.add(_email.text);
    } catch (e) {
      _show(errorText(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final t = AppScope.of(context).strings;
    if (!_email.text.contains('@')) {
      _show(t.invalidEmail);
      return;
    }
    try {
      await widget.auth.sendPasswordReset(_email.text);
      _show(t.resetSent);
    } catch (e) {
      _show(errorText(t, e));
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: pal.green,
                      child: const Icon(Icons.show_chart,
                          color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(t.loginSubtitle, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  EmailAutocompleteField(
                    controller: _email,
                    focusNode: _emailFocus,
                    suggestions: _savedEmails,
                    onSelected: (_) => _passwordFocus.requestFocus(),
                    onRemove: _removeSaved,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: t.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: t.showPassword,
                        icon: Icon(_obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? t.minChars6 : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? t.wait : t.signIn),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _resetPassword,
                    child: Text(t.forgotPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/error_text.dart';
import '../services/auth_service.dart';

/// Current password + the new one twice. Needs the network, so unlike data
/// writes it waits for Firebase and shows the error inline.
Future<void> showChangePasswordDialog(BuildContext context, AuthService auth) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ChangePasswordDialog(auth: auth),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.auth});

  final AuthService auth;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.changePassword(_current.text, _next.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(t.passwordChanged)));
    } catch (e) {
      if (mounted) setState(() => _error = errorText(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    return AlertDialog(
      title: Text(t.changePassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_current, t.currentPassword,
                (v) => (v == null || v.isEmpty) ? t.requiredField : null),
            const SizedBox(height: 12),
            _field(_next, t.newPassword,
                (v) => (v == null || v.length < 6) ? t.minChars6 : null),
            const SizedBox(height: 12),
            _field(_confirm, t.confirmPassword,
                (v) => v != _next.text ? t.passwordsNoMatch : null),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? t.wait : t.save),
        ),
      ],
    );
  }
}

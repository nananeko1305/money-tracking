import 'package:flutter/material.dart';

import '../app_scope.dart';

/// The drawer's account section: who is signed in, changing the password and
/// signing out. Each action closes the drawer first.
class DrawerAccountSection extends StatelessWidget {
  const DrawerAccountSection({
    super.key,
    required this.email,
    required this.onChangePassword,
    required this.onSignOut,
  });

  final String? email;
  final VoidCallback onChangePassword;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            t.accountSection.toUpperCase(),
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
        if (email != null)
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(email!, overflow: TextOverflow.ellipsis),
          ),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: Text(t.changePassword),
          onTap: () {
            Navigator.pop(context);
            onChangePassword();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(t.signOut),
          onTap: () {
            Navigator.pop(context);
            onSignOut();
          },
        ),
      ],
    );
  }
}

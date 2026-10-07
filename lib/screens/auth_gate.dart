import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_session.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Shows the login screen while signed out, otherwise the app for the signed
/// in account. Owns that account's [UserSession]: one per uid, disposed when
/// the account signs out or another one signs in.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth, required this.firestore});

  final AuthService auth;
  final FirebaseFirestore firestore;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _authState = widget.auth.authStateChanges();
  UserSession? _session;

  UserSession _sessionFor(User user) {
    final current = _session;
    if (current != null && current.uid == user.uid) return current;
    _disposeLater(current);
    return _session = UserSession(
      firestore: widget.firestore,
      uid: user.uid,
      email: user.email,
    );
  }

  /// The old shell still unsubscribes from the session while this frame
  /// replaces it, so the session goes once the frame is done.
  void _disposeLater(UserSession? session) {
    if (session == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => session.dispose());
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          _disposeLater(_session);
          _session = null;
          return LoginScreen(auth: widget.auth);
        }
        // Keyed by uid so switching accounts resets all state below.
        return HomeShell(
          key: ValueKey(user.uid),
          session: _sessionFor(user),
          auth: widget.auth,
        );
      },
    );
  }
}

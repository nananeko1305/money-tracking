import 'package:firebase_auth/firebase_auth.dart';

import 'strings.dart';

/// Turns a Firebase error into a message the user can read.
String errorText(AppStrings t, Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return t.errInvalidEmail;
      // With email enumeration protection on, Firebase answers every wrong
      // email or password with invalid-credential.
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'missing-password':
        return t.errWrongCredentials;
      case 'user-disabled':
        return t.errUserDisabled;
      case 'too-many-requests':
        return t.errTooManyRequests;
      case 'operation-not-allowed':
        return t.errNotEnabled;
      case 'weak-password':
        return t.errWeakPassword;
      case 'network-request-failed':
        return t.errNoNetwork;
    }
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return t.errPermission;
      case 'unavailable':
        return t.errNoNetwork;
    }
  }
  return t.errGeneric;
}

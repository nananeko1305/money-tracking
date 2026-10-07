import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) => FlutterError.presentError(details);
    // Accounts and their data live in Firebase, so it is ready before the
    // first frame.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const AppRoot());
  }, (error, stack) {
    // Last-resort guard so an uncaught async error never silently kills the app.
    debugPrint('Uncaught error: $error\n$stack');
  });
}

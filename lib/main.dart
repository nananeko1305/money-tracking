import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) => FlutterError.presentError(details);
    runApp(const AppRoot());
  }, (error, stack) {
    // Last-resort guard so an uncaught async error never silently kills the app.
    debugPrint('Uncaught error: $error\n$stack');
  });
}

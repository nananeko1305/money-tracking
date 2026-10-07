import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Release notifications over Firebase Cloud Messaging.
///
/// Every install subscribes to [releasesTopic]; CI sends one message to it
/// after publishing a new APK. While the app is closed or in the background,
/// Android shows the notification itself. When a release message arrives in
/// the foreground, or the user taps the notification, [onRelease] fires so the
/// UI can offer the update.
class PushService {
  static const String releasesTopic = 'releases';

  final StreamController<void> _releases = StreamController<void>.broadcast();
  bool _started = false;

  /// Emits whenever a release notification was received or opened.
  Stream<void> get onRelease => _releases.stream;

  /// Safe to call more than once. Failures (no Play services, offline) are
  /// swallowed: the start-up update check still works, and the next app start
  /// tries again.
  Future<void> start() async {
    if (_started || !_supported) return;
    _started = true;
    try {
      FirebaseMessaging.onMessage.listen(_handle);
      FirebaseMessaging.onMessageOpenedApp.listen(_handle);
      // Android 13+ shows the system permission prompt once.
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic(releasesTopic);
    } catch (_) {}
  }

  // Firebase is configured for Android only, the one platform releases ship
  // for (APKs).
  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _handle(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
  }
}

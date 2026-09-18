import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the first-launch onboarding guide has been shown.
class OnboardingStore {
  static const String _key = 'onboarding_seen';

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

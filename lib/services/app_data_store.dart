import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';

/// Low-level persistence of [AppData] as a single JSON blob in
/// [SharedPreferences]. Knows nothing about budget rules — it only reads and
/// writes bytes, seeding an empty store on first run and recovering from a
/// corrupt payload.
class AppDataStore {
  static const String _storageKey = 'budget_app_data';

  Future<AppData> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      final data = AppData.empty();
      await write(data);
      return data;
    }
    try {
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppData.empty();
    }
  }

  Future<void> write(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }
}

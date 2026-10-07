import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';

/// The data the app kept on the phone before accounts existed: one JSON blob
/// in [SharedPreferences]. Read once, to move it to the account; the blob is
/// never changed afterwards and stays as a last-resort copy.
class LegacyLocalData {
  static const String _dataKey = 'budget_app_data';
  static const String _movedKey = 'budget_app_data_moved_to';

  /// The on-phone data still waiting to be moved, or null when there is
  /// none, it is empty or unreadable, or it was moved already.
  Future<AppData?> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    if (raw == null || prefs.getString(_movedKey) != null) return null;
    try {
      final data = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return data.isEmpty ? null : data;
    } catch (_) {
      return null;
    }
  }

  /// Records that the data now lives in the account [uid].
  Future<void> markMoved(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_movedKey, uid);
  }
}

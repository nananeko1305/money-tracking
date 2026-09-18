import 'package:permission_handler/permission_handler.dart';

/// Requests and checks the "All files access" permission. Backups live in a
/// shared public folder that survives reinstalls, and reading / writing there
/// on Android 11+ requires this permission.
class StoragePermission {
  Future<bool> isGranted() => Permission.manageExternalStorage.isGranted;

  /// Returns true if access is already granted or the user grants it now.
  Future<bool> ensureGranted() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  /// Opens the system app-settings screen so the user can grant access manually.
  Future<void> openSettings() => openAppSettings();
}

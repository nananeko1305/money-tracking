import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'semantic_version.dart';

/// An available newer release of the app.
class AppUpdate {
  final String versionName;
  final String downloadUrl;
  final String releaseUrl;

  const AppUpdate({
    required this.versionName,
    required this.downloadUrl,
    required this.releaseUrl,
  });
}

/// Checks GitHub Releases for a newer version than the one installed. There is
/// no app store here, so this is how users learn a new version exists.
///
/// Compares the installed version (major.minor.patch, set by CI) with the one
/// the latest release tag starts with (`v<version>-build.<n>`; the build
/// suffix only serves installs from before semantic versions).
class UpdateChecker {
  static const String _latestApi =
      'https://api.github.com/repos/nananeko1305/money-tracking/releases/latest';

  final http.Client _client;

  UpdateChecker({http.Client? client}) : _client = client ?? http.Client();

  Future<AppUpdate?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();

      final res = await _client.get(
        Uri.parse(_latestApi),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = json['tag_name'] as String? ?? '';
      final latest = versionFromTag(tag);
      if (latest == null || compareVersions(latest, info.version) <= 0) {
        return null;
      }

      final assets = (json['assets'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final apk = assets.firstWhere(
        (a) => (a['name'] as String?)?.toLowerCase().endsWith('.apk') ?? false,
        orElse: () => const <String, dynamic>{},
      );
      final downloadUrl = apk['browser_download_url'] as String?;
      if (downloadUrl == null) return null;

      return AppUpdate(
        versionName: latest,
        downloadUrl: downloadUrl,
        releaseUrl: json['html_url'] as String? ?? downloadUrl,
      );
    } catch (_) {
      return null;
    }
  }
}

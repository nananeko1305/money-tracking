import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// An available newer release of the app.
class AppUpdate {
  final int buildNumber;
  final String versionName;
  final String downloadUrl;
  final String releaseUrl;

  const AppUpdate({
    required this.buildNumber,
    required this.versionName,
    required this.downloadUrl,
    required this.releaseUrl,
  });
}

/// Checks GitHub Releases for a newer build than the one installed. There is no
/// app store here, so this is how users learn a new version exists.
///
/// Compares the installed build number (Android versionCode) against the build
/// number encoded in the latest release tag (`v<version>-build.<n>`).
class UpdateChecker {
  static const String _latestApi =
      'https://api.github.com/repos/nananeko1305/money-tracking/releases/latest';

  final http.Client _client;

  UpdateChecker({http.Client? client}) : _client = client ?? http.Client();

  Future<AppUpdate?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final res = await _client.get(
        Uri.parse(_latestApi),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final tag = json['tag_name'] as String? ?? '';
      final latestBuild = _buildFromTag(tag);
      if (latestBuild == null || latestBuild <= currentBuild) return null;

      final assets = (json['assets'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final apk = assets.firstWhere(
        (a) => (a['name'] as String?)?.toLowerCase().endsWith('.apk') ?? false,
        orElse: () => const <String, dynamic>{},
      );
      final downloadUrl = apk['browser_download_url'] as String?;
      if (downloadUrl == null) return null;

      return AppUpdate(
        buildNumber: latestBuild,
        versionName: _versionFromTag(tag),
        downloadUrl: downloadUrl,
        releaseUrl: json['html_url'] as String? ?? downloadUrl,
      );
    } catch (_) {
      return null;
    }
  }

  // "v1.0.0+1-build.42" -> 42
  static int? _buildFromTag(String tag) {
    final m = RegExp(r'-build\.(\d+)').firstMatch(tag);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  // "v1.0.0+1-build.42" -> "1.0.0"
  static String _versionFromTag(String tag) {
    final m = RegExp(r'^v?(\d+\.\d+\.\d+)').firstMatch(tag);
    return m?.group(1) ?? tag;
  }
}

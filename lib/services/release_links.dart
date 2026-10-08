/// Where the app's releases are published: GitHub Releases of the repository,
/// built by the release workflow.
class ReleaseLinks {
  static const String _repo = 'nananeko1305/money-tracking';

  /// The newest release, for the update check.
  static const String latestApi =
      'https://api.github.com/repos/$_repo/releases/latest';

  /// Always the newest APK: GitHub redirects /latest/download/ to the asset
  /// of the newest release. The file name must match APK_NAME in
  /// .github/workflows/release-apk.yml.
  static const String latestApk =
      'https://github.com/$_repo/releases/latest/download/budget-tracker.apk';
}

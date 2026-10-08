/// Orders two `major.minor.patch` versions: negative when [a] is older, zero
/// when they match, positive when [a] is newer. Missing or unreadable parts
/// count as zero, so a malformed version is simply old.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
        for (var i = 0; i < 3; i++)
          int.tryParse(
                  v.split('.').elementAtOrNull(i)?.split(RegExp('[-+]')).first ??
                      '') ??
              0,
      ];
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < 3; i++) {
    if (left[i] != right[i]) return left[i] - right[i];
  }
  return 0;
}

/// The version a release tag starts with: "v1.2.0-build.14" -> "1.2.0", and
/// the older "v1.0.0+1-build.12" -> "1.0.0". Null when there is none.
String? versionFromTag(String tag) =>
    RegExp(r'^v?(\d+\.\d+\.\d+)').firstMatch(tag)?.group(1);

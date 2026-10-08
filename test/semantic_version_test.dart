import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/services/semantic_version.dart';

void main() {
  test('versions compare part by part, as numbers', () {
    expect(compareVersions('1.1.0', '1.0.9'), greaterThan(0));
    expect(compareVersions('1.10.0', '1.9.0'), greaterThan(0));
    expect(compareVersions('2.0.0', '1.99.99'), greaterThan(0));
    expect(compareVersions('1.0.1', '1.0.1'), 0);
    expect(compareVersions('1.0.0', '1.0.1'), lessThan(0));
  });

  test('suffixes and malformed parts do not break the comparison', () {
    expect(compareVersions('1.0.0+1', '1.0.0'), 0);
    expect(compareVersions('1.1.0', '1.1'), 0);
    expect(compareVersions('garbage', '0.0.1'), lessThan(0));
  });

  test('the version is read from old and new release tags', () {
    expect(versionFromTag('v1.0.0+1-build.13'), '1.0.0');
    expect(versionFromTag('v1.1.0-build.14'), '1.1.0');
    expect(versionFromTag('v2.0.0'), '2.0.0');
    expect(versionFromTag('nightly'), isNull);
  });

  test('an install from before semantic versions sees the first one', () {
    // Old builds carried the pubspec version, 1.0.0.
    expect(compareVersions(versionFromTag('v1.1.0-build.14')!, '1.0.0'),
        greaterThan(0));
  });
}

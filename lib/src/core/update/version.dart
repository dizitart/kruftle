// SPDX-License-Identifier: GPL-3.0-or-later

/// The version this build of Kruftle is.
///
/// A plain constant, not `PackageInfo.fromPlatform()`. That reads the version
/// back out of the packaged app at runtime — the executable's version resource
/// on Windows, a generated JSON file beside the bundle on Linux, `Info.plist`
/// on macOS. Three platform paths, three ways to come back empty or
/// unparseable, and every one of them fails the same way: `tryParse` returns
/// null, the update check gives up before it starts, and the user is told
/// nothing at all — which is what Windows was doing, with no way to tell from
/// the outside which of the three had gone wrong.
///
/// A constant is identical on every platform, needs no plugin, and cannot come
/// back wrong. `version_test.dart` holds it to `pubspec.yaml`, and the release
/// workflow refuses to build a tag that disagrees with it.
const kAppVersion = '0.2.7';

/// A semantic version, enough of one to decide whether a release is newer.
///
/// Deliberately not a package dependency: comparing three integers and an
/// optional pre-release tag is twenty lines, and this is the only place the app
/// needs it.
class Version implements Comparable<Version> {
  const Version(this.major, this.minor, this.patch, [this.preRelease]);

  final int major;
  final int minor;
  final int patch;

  /// `beta.1` in `1.2.0-beta.1`. A pre-release always sorts *before* the same
  /// version without one, per semver.
  final String? preRelease;

  static final _pattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
  );

  /// Parses `1.2.3`, `v1.2.3`, `1.2.3-beta.1`, `1.2.3+42`. Returns null for
  /// anything else rather than throwing: a release tag we cannot read simply is
  /// not an upgrade candidate.
  static Version? tryParse(String source) {
    final match = _pattern.firstMatch(source.trim());
    if (match == null) return null;
    return Version(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      match.group(4),
    );
  }

  bool get isPreRelease => preRelease != null;

  @override
  int compareTo(Version other) {
    for (final (a, b) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    if (preRelease == other.preRelease) return 0;
    if (preRelease == null) return 1; // a release beats its own pre-releases
    if (other.preRelease == null) return -1;
    return preRelease!.compareTo(other.preRelease!);
  }

  bool operator >(Version other) => compareTo(other) > 0;
  bool operator <(Version other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) => other is Version && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);

  @override
  String toString() =>
      '$major.$minor.$patch${preRelease == null ? '' : '-$preRelease'}';
}

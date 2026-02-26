import 'package:pub_semver/pub_semver.dart';

extension VersionManipulation on Version {
  /// Changes the given parts, returning a new instance on [Version]
  Version change(
          {int? major,
          int? minor,
          int? patch,
          List<dynamic>? build,
          List<dynamic>? preRelease}) =>
      Version(
        major ?? this.major,
        minor ?? this.minor,
        patch ?? this.patch,
        build: (build ?? this.build).asString,
        pre: (preRelease ?? this.preRelease).asString,
      );

  /// Returns a new instance of Version with the next build:
  /// - empty build will be set to `1`: 1.2.3 -> 1.2.3+1
  /// - build with a non-numeric last segment gets `.1` appended: 1.2.3+foo42 -> 1.2.3+foo42.1
  /// - build with a numeric last segment gets the last segment incremented: 1.2.3+foo.1.2.3 -> 1.2.3+foo.1.2.4
  Version get nextBuild => change(build: build.next);

  /// Returns a new instance of Version with the next pre-release:
  /// - pre-release with a non-numeric last segment gets `.1` appended: 1.2.3-foo42 -> 1.2.3-foo42.1
  /// - pre-release with a numeric last segment gets the last segment incremented: 1.2.3-foo.1.2.3 -> 1.2.3-foo.1.2.4
  /// - empty pre-release can not be incremented. Throws a [StateError]
  Version get nextPreRelease {
    if (preRelease.isEmpty) throw StateError('Can not bump empty pre-release');
    return change(preRelease: preRelease.next, build: []);
  }

  /// Promotes a pre-release to a release by clearing the pre-release and the build
  /// - empty pre-release can not be promoted. Throws a [StateError]
  Version get release {
    if (preRelease.isEmpty) throw StateError('Not a pre-release');
    return change(preRelease: [], build: []);
  }
}

extension _List on List {
  List get next {
    if (isNotEmpty && last is int) {
      final next = toList();
      next.last++;
      return next;
    }
    return [...this, '1'];
  }

  String? get asString => isNotEmpty ? join('.') : null;
}

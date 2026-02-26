import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:version_manipulation/version_extension.dart';

void main() {
  final version = Version.parse('0.1.3-alpha+foo.1');
  test('Change', () {
    expect(version.change(build: ['moo']).toString(), '0.1.3-alpha+moo');
    expect(version.change(preRelease: ['beta']).toString(), '0.1.3-beta+foo.1');
    expect(version.change(major: 42).toString(), '42.1.3-alpha+foo.1');
    expect(version.change(minor: 42).toString(), '0.42.3-alpha+foo.1');
    expect(version.change(patch: 42).toString(), '0.1.42-alpha+foo.1');
    expect(
        version.change(
            major: 42,
            minor: 42,
            patch: 42,
            preRelease: ['gamma', 'omega'],
            build: ['foo', 'bar', '42']).toString(),
        '42.42.42-gamma.omega+foo.bar.42');
  });

  group('Build', () {
    test('empty build will be set to `1`', () {
      expect(Version.parse('1.2.3').nextBuild.toString(), '1.2.3+1');
    });

    test('build with a non-numeric last segment gets `.1` appended', () {
      expect(
          Version.parse('1.2.3+foo42').nextBuild.toString(), '1.2.3+foo42.1');
    });

    test('build with a numeric last segment gets the last segment incremented',
        () {
      expect(Version.parse('1.2.3+foo.1.2.3').nextBuild.toString(),
          '1.2.3+foo.1.2.4');
    });
  });

  group('Pre-release', () {
    test('bumping empty pre-release throws an exception', () {
      expect(() => Version.parse('1.2.3').nextPreRelease, throwsStateError);
    });

    test('pre-release with a non-numeric last segment gets `.1` appended', () {
      expect(Version.parse('1.2.3-foo42').nextPreRelease.toString(),
          '1.2.3-foo42.1');
    });

    test(
        'pre-release with a numeric last segment gets the last segment incremented',
        () {
      expect(Version.parse('1.2.3-foo.1.2.3').nextPreRelease.toString(),
          '1.2.3-foo.1.2.4');
    });
  });
}

import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:version_manipulation/mutations.dart';

void main() {
  group('Mutations', () {
    test('BumpBreaking', () {
      check(BumpBreaking(), {'0.2.3-alpha+42': '0.3.0'});
    });
    test('BumpMajor', () {
      check(BumpMajor(), {'0.2.3-alpha+42': '1.0.0'});
    });
    test('BumpMinor', () {
      check(BumpMinor(), {'0.2.3-alpha+42': '0.3.0'});
    });
    test('BumpPatch', () {
      check(BumpPatch(), {'0.2.3-alpha+42': '0.2.3'});
    });
    test('Release', () {
      check(Release(), {'0.2.3-alpha+42': '0.2.3'});
    });
    test('Release throws when not a pre-release', () {
      expect(() => Release()(Version.parse('1.2.3')), throwsStateError);
    });
    test('SetBuild', () {
      check(SetBuild('foo'), {'0.2.3-alpha+42': '0.2.3-alpha+foo'});
    });
    test('SetPreRelease', () {
      check(SetPreRelease('foo'), {'0.2.3-alpha+42': '0.2.3-foo+42'});
    });
    test('Sequence', () {
      check(Sequence([SetPreRelease('foo'), SetBuild('bar')]),
          {'0.2.3-alpha+42': '0.2.3-foo+bar'});
    });
    test('BumpBuild', () {
      check(BumpBuild(), {
        '0.2.3': '0.2.3+1',
        '0.2.3-alpha': '0.2.3-alpha+1',
        '0.2.3-alpha+42': '0.2.3-alpha+43',
        '0.2.3-alpha+foo': '0.2.3-alpha+foo.1',
        '0.2.3-alpha+foo.42.2': '0.2.3-alpha+foo.42.3',
      });
    });
    test('BumpPreRelease', () {
      check(BumpPreRelease(), {
        '0.2.3-42+42': '0.2.3-43',
        '0.2.3-foo': '0.2.3-foo.1',
        '0.2.3-foo.42.2': '0.2.3-foo.42.3',
      });
    });
    test('KeepBuild', () {
      check(KeepBuild(BumpBreaking()), {
        '0.2.3-alpha+foo.1.2.3': '0.3.0+foo.1.2.3',
        '0.2.3': '0.3.0',
      });
      check(KeepBuild(BumpMajor()), {
        '0.2.3-alpha+foo.1.2.3': '1.0.0+foo.1.2.3',
        '0.2.3': '1.0.0',
      });
      check(KeepBuild(BumpMinor()), {
        '0.2.3-alpha+foo.1.2.3': '0.3.0+foo.1.2.3',
        '0.2.3': '0.3.0',
      });
      check(KeepBuild(BumpPatch()), {
        '0.2.3-alpha+foo.1.2.3': '0.2.3+foo.1.2.3',
        '0.2.3': '0.2.4',
      });
      check(KeepBuild(BumpPreRelease()), {
        '0.2.3-alpha+foo.1.2.3': '0.2.3-alpha.1+foo.1.2.3',
      });
      check(KeepBuild(Release()), {
        '0.2.3-alpha+foo.1.2.3': '0.2.3+foo.1.2.3',
      });
      check(KeepBuild(BumpBuild()), {
        '0.2.3-alpha+foo.1.2.3': '0.2.3-alpha+foo.1.2.3',
        '0.2.3': '0.2.3',
      });
    });
  });
}

void check(VersionMutation mutation, Map<String, String> changes) {
  changes.forEach((from, to) {
    expect(mutation(Version.parse(from)).toString(), to);
  });
}

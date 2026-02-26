/// Mutations which can be applied to the [Version]
library mutations;

import 'package:pub_semver/pub_semver.dart';
import 'package:version_manipulation/version_extension.dart';

/// A mutation which can be applied to the [Version]
abstract class VersionMutation {
  Version call(Version version);
}

/// A mutation sequence
class Sequence implements VersionMutation {
  Sequence(this.mutations);

  final Iterable<VersionMutation> mutations;

  @override
  Version call(Version version) => mutations.fold(
      version, (previousValue, element) => element(previousValue));
}

/// Bumps the breaking version
class BumpBreaking implements VersionMutation {
  const BumpBreaking();

  @override
  Version call(Version version) => version.nextBreaking;
}

/// Bumps the major version
class BumpMajor implements VersionMutation {
  const BumpMajor();

  @override
  Version call(Version version) => version.nextMajor;
}

/// Bumps the minor version
class BumpMinor implements VersionMutation {
  const BumpMinor();

  @override
  Version call(Version version) => version.nextMinor;
}

/// Bumps the patch version
class BumpPatch implements VersionMutation {
  const BumpPatch();

  @override
  Version call(Version version) => version.nextPatch;
}

/// Bumps the build version
class BumpBuild implements VersionMutation {
  const BumpBuild();

  @override
  Version call(Version version) => version.nextBuild;
}

/// Sets the build version
class SetBuild implements VersionMutation {
  const SetBuild(this.value);

  final String value;

  @override
  Version call(Version version) => version.change(build: value.split('.'));
}

/// Bumps the pre-release version
class BumpPreRelease implements VersionMutation {
  const BumpPreRelease();

  @override
  Version call(Version version) => version.nextPreRelease;
}

/// Promotes a pre-release to a release keeping the main version
class Release implements VersionMutation {
  const Release();

  @override
  Version call(Version version) => version.release;
}

/// Sets the pre-release version
class SetPreRelease implements VersionMutation {
  const SetPreRelease(this.value);

  final String value;

  @override
  Version call(Version version) => version.change(preRelease: value.split('.'));
}

/// A wrapper that keeps the original build
class KeepBuild implements VersionMutation {
  const KeepBuild(this.wrapped);

  final VersionMutation wrapped;

  @override
  Version call(Version version) =>
      wrapped.call(version.change(build: [])).change(build: version.build);
}

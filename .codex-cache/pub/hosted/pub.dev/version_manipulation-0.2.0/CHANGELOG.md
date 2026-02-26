# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2023-11-26
### Added
- Bump dependencies

## [0.1.2] - 2023-09-15
### Changed
- Allow SDK v3.0.0

## [0.1.1] - 2022-12-07
### Added
- "Release" version mutation

## [0.1.0] - 2021-04-11
### Changed
- Migrated to null safety.
- The build and pre-release parts are bumped by incrementing the last segment or by appending `.1`.
- `MutationChain` renamed to `Sequence`.

### Removed
- `KeepPreRelease`.

## [0.0.5] - 2020-09-12
### Added
- Chain mutations

## [0.0.4] - 2020-09-08
### Fixed
- KeepPreRelease wrapper strips the pre-release tag to allow for patch bumping

## [0.0.3] - 2020-09-01
### Added
- KeepPreRelease wrapper
- `preRelease` argument to `change()`

### Fixed
- KeepBuild should not clear pre-release part

## [0.0.2] - 2020-07-18
### Added
- Mutations

## 0.0.1 - 2020-07-18
### Added
- `nextBuild`
- `set`

[0.2.0]: https://github.com/f3ath/dart-version-manipulation/compare/0.1.2...0.2.0
[0.1.2]: https://github.com/f3ath/dart-version-manipulation/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/f3ath/dart-version-manipulation/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/f3ath/dart-version-manipulation/compare/0.0.5...0.1.0
[0.0.5]: https://github.com/f3ath/dart-version-manipulation/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/f3ath/dart-version-manipulation/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/f3ath/dart-version-manipulation/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/f3ath/dart-version-manipulation/compare/0.0.1...0.0.2

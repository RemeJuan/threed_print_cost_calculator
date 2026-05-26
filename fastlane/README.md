fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### metadata_pull_all

```sh
[bundle exec] fastlane metadata_pull_all
```

Pull metadata from both App Store Connect and Google Play

### metadata_check_all

```sh
[bundle exec] fastlane metadata_check_all
```

Check credentials and connectivity for both stores

### metadata_push_all

```sh
[bundle exec] fastlane metadata_push_all
```

Push metadata to both stores

### screenshot_push_all

```sh
[bundle exec] fastlane screenshot_push_all
```

Push screenshots to both stores

----


## iOS

### ios metadata_check

```sh
[bundle exec] fastlane ios metadata_check
```

Verify iOS credentials are valid and present

### ios metadata_pull

```sh
[bundle exec] fastlane ios metadata_pull
```

Pull iOS metadata from App Store Connect

### ios metadata_push

```sh
[bundle exec] fastlane ios metadata_push
```

Push metadata to App Store Connect (no binary, no screenshots)

### ios release_notes_push

```sh
[bundle exec] fastlane ios release_notes_push
```

Push iOS release notes only to App Store Connect (no binary, no screenshots)

### ios screenshot_push

```sh
[bundle exec] fastlane ios screenshot_push
```

Push screenshots to App Store Connect (no metadata, no binary)

----


## Android

### android metadata_check

```sh
[bundle exec] fastlane android metadata_check
```

Verify Android credentials and Google Play connectivity

### android metadata_pull

```sh
[bundle exec] fastlane android metadata_pull
```

Pull Android metadata from Google Play Console

### android metadata_push

```sh
[bundle exec] fastlane android metadata_push
```

Push metadata to Google Play Console (no APK)

### android changelog_push

```sh
[bundle exec] fastlane android changelog_push
```

Push Android changelogs only to Google Play Console (no APK)

### android screenshot_push

```sh
[bundle exec] fastlane android screenshot_push
```

Push screenshots to Google Play Console (no metadata, no APK)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

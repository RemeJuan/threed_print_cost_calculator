# Change Log

All notable changes to the "localizely_sdk" will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.7.5 - 2025-11-21

- Improve the `build_runner` builder configuration so it relies on all ARB files as inputs

## 2.7.4 - 2025-09-15

- Update `package_info_plus` dependency

- Fix static analysis issues

## 2.7.3 - 2025-09-10

- Update `build` dependency

## 2.7.2 - 2025-09-01

- Update `build` dependency

## 2.7.1 - 2025-07-07

- Update `petitparser` dependency

## 2.7.0 - 2025-06-02

- Update the code generator for gen_l10n to use the new default value for the `synthetic-package` config option  
  Starting with Flutter 3.32.0 (Dart 3.8.0), the default value for the `synthetic-package` option in the `l10n.yaml` file has changed from `true` to `false`

## 2.6.4 - 2025-03-06

- Escape characters with special meaning within metadata

## 2.6.3 - 2025-03-05

- Improve the Localizely localizations delegate

## 2.6.2 - 2025-03-04

- Disable lint rules for the generated localization file

- Improve the indentation in the generated localization file

## 2.6.1 - 2025-02-28

- Update `intl` dependency

## 2.6.0 - 2025-02-27

- Update the parser and code generator for gen_l10n

- Add support for `relax-syntax`, `use-escaping`, and `use-named-parameters` in the gen_l10n localization configuration  
  The Localizely SDK now processes the above-mentioned configurations from the `l10n.yaml` file and generates compatible localization code accordingly

Note: These improvements align with the latest version of the gen_l10n tool, which is included in Flutter 3.29.0.

## 2.5.10 - 2025-02-13

- Update `shared_preferences` dependency

- Migrate from `dart:html` to `package:web`

- Improve Localizely localizations delegate generation for better alignment with gen_l10n

## 2.5.9 - 2024-12-24

- Update `intl` dependency

- Make `localizely_builder` more robust

- Update documentation

## 2.5.8 - 2024-09-20

- Update `web_socket_channel` dependency

- Update documentation

## 2.5.7 - 2024-05-20

- Update documentation

## 2.5.6 - 2024-05-16

- Update `package_info_plus` dependency

## 2.5.5 - 2024-04-03

- Update `package_info_plus` dependency

## 2.5.4 - 2023-12-25

- Update `intl` and `package_info_plus` dependencies

- Fix deprecation and lint warnings

## 2.5.3 - 2023-10-10

- Update `logger`, `uuid`, and `petitparser` dependencies

- Migrate from `package_info` to `package_info_plus`

## 2.5.2 - 2023-06-01

- Update `http` dependency

- Update `.gitignore` file

- Update deprecated widget styles

## 2.5.1 - 2023-02-23

- Update `intl` dependency

## 2.5.0 - 2022-12-01

- Add support for Over-the-Air in projects that use Flutter's gen_l10n tool for localization

- Remove `mobile_scanner` dependency

- Improve metadata generation for gen_l10n tool

## 2.4.1 - 2022-09-10

- Update `mobile_scanner` and `petitparser` dependencies

- Fix issue with `build_runner` invocation when gen_l10n tool is not used for localization

## 2.4.0 - 2022-05-22

- Add in-context editing

- Increase min platform versions:

    - Android: Require Android SDK 21 or newer

    - iOS: Require iOS 11 or newer

## 2.3.0 - 2021-11-05

- Add support for json strings

- Migrate from pedantic to lints package

## 2.2.0 - 2021-07-13

- Fix issue with translations that contain tags

## 2.1.0 - 2021-04-26

- Add support for the compound messages

## 2.0.0 - 2021-03-09

- Migrate to null-safety

## 1.3.0 - 2021-01-18

- Add persistence of translations

## 1.2.2 - 2020-10-07

- Improve error messages

- Update logger version

## 1.2.1 - 2020-08-08

- Update `petitparser` dependency

## 1.2.0 - 2020-05-26

- Add support for Flutter web

## 1.1.0 - 2020-05-11

- Improve API communication

## 1.0.0 - 2020-05-11

- Initial release

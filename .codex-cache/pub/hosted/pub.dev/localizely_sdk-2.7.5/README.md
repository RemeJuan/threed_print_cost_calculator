# Localizely SDK

[![pub package](https://img.shields.io/pub/v/localizely_sdk.svg)](https://pub.dev/packages/localizely_sdk)

This package provides [Over-the-Air translation updates](#over-the-air-translation-updates) and [In-Context Editing](#in-context-editing) from the Localizely platform.

## Platform Support

| Android | iOS | Web | MacOS | Linux | Windows |
| :-----: | :-: | :-: | :---: | :---: | :-----: |
|    ✔    |  ✔  |  ✔  |   ✔   |   ✔   |    ✔    |

## Over-the-Air translation updates

Update translations for your Flutter applications over the air. [Learn more](https://localizely.com/flutter-over-the-air/)

Works with projects that use Flutter's `gen_l10n` approach for internationalization, and with projects that use Flutter Intl IDE plugin / `intl_utils`.

### Setup for gen_l10n

1\. Update `pubspec.yaml` file

<pre>
dependencies:
  ...
  <b>localizely_sdk: ^2.7.5</b>
</pre>

2\. Generate localization files

<pre>
dart run localizely_sdk:generate
</pre>

3\. Update `localizationsDelegates` and `supportedLocales` props of the `MaterialApp` widget.

<pre>
<b>import 'package:flutter_gen/gen_l10n/localizely_localizations.dart';</b>

class MyApp extends StatelessWidget {
  ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ...
      <b>localizationsDelegates: LocalizelyLocalizations.localizationsDelegates,
      supportedLocales: LocalizelyLocalizations.supportedLocales,</b>
      ...
    );
  }
}
</pre>

4\. Initialize Localizely SDK

<pre>
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/localizely_localizations.dart';
<b>import 'package:localizely_sdk/localizely_sdk.dart';</b>

void main() {
  <b>Localizely.init('&lt;SDK_TOKEN&gt;', '&lt;DISTRIBUTION_ID&gt;');</b> // Init sdk
  <b>Localizely.setPreRelease(true);</b> // Add this only if you want to use prereleases
  <b>Localizely.setAppVersion('&lt;APP_VERSION&gt;');</b> // Add this only if you want to explicitly set the application version, or in cases when automatic detection is not possible (e.g. Flutter web apps)

  runApp(MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: LocalizelyLocalizations.localizationsDelegates,
      supportedLocales: LocalizelyLocalizations.supportedLocales,
      home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  State&lt;StatefulWidget&gt; createState() => _HomePageState();
}

class _HomePageState extends State&lt;HomePage&gt; {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    <b>Localizely.updateTranslations().then(</b> // Call 'updateTranslations' after localization delegates initialization
        <b>(response) => setState(() {
              _isLoading = false;
            }),
        onError: (error) => setState(() {
              _isLoading = false;
            }));</b>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.pageHomeTitle)),
        body: Center(
            child: _isLoading ? CircularProgressIndicator() : Column(children: &lt;Widget&gt;[Text(AppLocalizations.of(context)!.welcome)])));
  }
}
</pre>

5\. Run the app

### Setup for Flutter Intl

1\. Update `pubspec.yaml` file

<pre>
dependencies:
  ...
  <b>localizely_sdk: ^2.7.5</b>

flutter_intl:
  ...
  <b>localizely:
    ota_enabled: true</b> # Required for Over-the-Air translation updates
</pre>

2\. Trigger localization files generation by Flutter Intl IDE plugin or by [intl_utils](https://pub.dev/packages/intl_utils) library

3\. Initialize Localizely SDK

<pre>
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
<b>import 'package:localizely_sdk/localizely_sdk.dart';</b>
import 'generated/l10n.dart';

void main() {
  <b>Localizely.init('&lt;SDK_TOKEN&gt;', '&lt;DISTRIBUTION_ID&gt;');</b> // Init sdk 
  <b>Localizely.setPreRelease(true);</b> // Add this only if you want to use prereleases
  <b>Localizely.setAppVersion('&lt;APP_VERSION&gt;');</b> // Add this only if you want to explicitly set the application version, or in cases when automatic detection is not possible (e.g. Flutter web apps)

  runApp(MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  State&lt;StatefulWidget&gt; createState() => _HomePageState();
}

class _HomePageState extends State&lt;HomePage&gt; {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    <b>Localizely.updateTranslations().then(</b> // Call 'updateTranslations' after localization delegates initialization
        <b>(response) => setState(() {
              _isLoading = false;
            }),
        onError: (error) => setState(() {
              _isLoading = false;
            }));</b>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).pageHomeTitle)),
        body: Center(
            child: _isLoading ? CircularProgressIndicator() : Column(children: &lt;Widget&gt;[Text(S.of(context).welcome)])));
  }
}
</pre>

5\. Run the app

<br/>

## In-Context Editing

Instantly see how your translations fit on a real device without unnecessary app builds. [Learn more](https://localizely.com/flutter-in-context-editing/).

Works with projects that use Flutter's `gen_l10n` approach for internationalization, and with projects that use Flutter Intl IDE plugin / `intl_utils`.

### Setup for gen_l10n

1\. Update `pubspec.yaml` file

<pre>
dependencies:
  ...
  <b>localizely_sdk: ^2.7.5</b>
</pre>

2\. Generate localization files

<pre>
dart run localizely_sdk:generate
</pre>

3\. Update `localizationsDelegates` and `supportedLocales` props of the `MaterialApp` widget.

<pre>
<b>import 'package:flutter_gen/gen_l10n/localizely_localizations.dart';</b>

class MyApp extends StatelessWidget {
  ...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ...
      <b>localizationsDelegates: LocalizelyLocalizations.localizationsDelegates,
      supportedLocales: LocalizelyLocalizations.supportedLocales,</b>
      ...
    );
  }
}
</pre>

4\. Wrap the root of the app

<pre>
<b>import 'package:localizely_sdk/localizely_sdk.dart';</b>

void main() {
  runApp(
    <b>LocalizelyInContextEditing(
      enabled: true,</b> // set to false to disable In-Context Editing for production app builds
      <b>child: MyApp(),
    ),</b>
  );
}
</pre>

5\. Connect to Localizely

Run Flutter app on a real device and connect with Localizely.

### Setup for Flutter Intl

1\. Update `pubspec.yaml` file

<pre>
dependencies:
  ...
  <b>localizely_sdk: ^2.7.5</b>

flutter_intl:
  ...
  <b>localizely:
    ota_enabled: true</b> # Required for In-Context Editing
</pre>

2\. Trigger localization files generation by Flutter Intl IDE plugin or by [intl_utils](https://pub.dev/packages/intl_utils) library

3\. Wrap the root of the app

<pre>
<b>import 'package:localizely_sdk/localizely_sdk.dart';</b>

void main() {
  runApp(
    <b>LocalizelyInContextEditing(
      enabled: true,</b> // set to false to disable In-Context Editing for production app builds
      <b>child: MyApp(),
    ),</b>
  );
}
</pre>

4\. Connect to Localizely

Run Flutter app on a real device and connect with Localizely.

## Notes

- If you're not seeing updated translations in your app after an OTA retrieval, please check if you've followed all the necessary steps. Verify that you've created a new release on Localizely with the latest changes. Confirm whether you're working with prereleases enabled or disabled. Make sure the languages on Localizely match those in your app, and check if rebuilding the widget tree is required after the OTA request.

- To automate the generation of necessary code for `gen_l10n`, you can utilize the [`build_runner`](https://pub.dev/packages/build_runner) package. The `localizely_builder` relies on your `gen_l10n` configuration and generates the required code accordingly.

- In Flutter `3.22.0`, running the command `dart run localizely_sdk:generate` may produce false analyzer errors. This issue has been resolved in Flutter `3.22.1`. If you need to use `3.22.0` and encounter these errors, running `flutter pub get` again should fix the problem.

- The `localizely_sdk >=2.4.0 <2.5.0` requires an update of min platform versions:

  - Android: Require Android SDK 21 or newer

  - iOS: Require iOS 11 or newer

  As of version `2.5.0`, these updates are no longer required due to changes in implementation.

## Want to learn more?

- [Complete Over-the-Air documentation](https://localizely.com/flutter-over-the-air/)

- [Sample app with Over-the-Air translation updates](https://github.com/localizely/flutter-ota-sample-app)

- [Complete In-Context Editing documentation](https://localizely.com/flutter-in-context-editing/)

- [Sample app with In-Context Editing](https://github.com/localizely/flutter-in-context-editing-example)

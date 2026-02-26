import 'package:glob/glob.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import 'generator.dart';
import 'gen_l10n_types.dart';

Builder localizelyBuilder(BuilderOptions options) => LocalizelyBuilder();

class LocalizelyBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions {
    try {
      final config = getGenL10nConfigSync();
      final outputDir = _normalizePath(config.outputDir);

      final syntheticPackageConfig = {
        r'$package$': [
          '.dart_tool/flutter_gen/gen_l10n/localizely_localizations.dart',
        ],
      };

      final regularPackageConfig = {
        '$outputDir/${config.outputLocalizationFile}': [
          '$outputDir/localizely_localizations.dart',
        ],
      };

      return config.syntheticPackage
          ? syntheticPackageConfig
          : regularPackageConfig;
    } on GenL10nException {
      // Fallback to the default buildExtensions config.
      return {
        r'$package$': [
          '.dart_tool/flutter_gen/gen_l10n/localizely_localizations.dart',
        ],
      };
    }
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      final config = getGenL10nConfigSync();

      final arbDir = _normalizePath(config.arbDir);
      final arbGlob = Glob(path.posix.join(arbDir, '*.arb'));
      final pathToContent = <String, String>{};

      await for (final arbId in buildStep.findAssets(arbGlob)) {
        final content = await buildStep.readAsString(arbId);
        pathToContent[arbId.path] = content;
      }

      final templateArbPath = path.posix.join(arbDir, config.templateArbFile);
      final templateArbContent = pathToContent[templateArbPath];
      if (templateArbContent == null) return;

      final arb = AppResourceBundle.fromString(
        templateArbPath,
        templateArbContent,
      );

      final arbCollection = AppResourceBundleCollection.fromStrings(
        pathToContent,
      );

      await _generate(buildStep, config, arb, arbCollection);
    } on GenL10nException {
      // skip - missing config for gen_l10n indicates that another tool is used for localization (e.g. Flutter Intl)
    }
  }

  Future<void> _generate(
    BuildStep buildStep,
    GenL10nConfig config,
    AppResourceBundle arb,
    AppResourceBundleCollection arbCollection,
  ) async {
    final contents = generateLyLocalizationsContents(
      arb,
      arbCollection,
      config,
    );

    final outputPath = path.join(
      config.outputDir,
      'localizely_localizations.dart',
    );

    final outputId = AssetId(buildStep.inputId.package, outputPath);

    await buildStep.writeAsString(outputId, contents);
  }

  String _normalizePath(String p) => p.replaceAll('\\', '/');
}

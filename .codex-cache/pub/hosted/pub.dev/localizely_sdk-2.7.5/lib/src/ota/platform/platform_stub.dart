import 'platform.dart';

/// Implemented in `browser_platform.dart` and `io_platform.dart`.
Platform createPlatform() => throw UnsupportedError(
  'Cannot create a platform without dart:html or dart:io.',
);

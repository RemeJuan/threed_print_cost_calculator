class PlatformException implements Exception {
  final String? message;

  PlatformException([this.message]);

  @override
  String toString() => 'PlatformException: ${message ?? ""}';
}

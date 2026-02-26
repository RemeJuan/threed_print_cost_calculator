class SdkException implements Exception {
  final String message;

  SdkException(this.message);

  @override
  String toString() {
    return 'SdkException: $message';
  }
}

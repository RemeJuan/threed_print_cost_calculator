class BundleInfo {
  final String file;
  final int version;

  BundleInfo({required this.file, required this.version});

  BundleInfo.fromJson(Map<String, dynamic> json)
    : file = json['file'],
      version = json['version'];
}

import 'release_data.dart';

class PersistedReleaseData {
  final String distributionId;
  final ReleaseData releaseData;

  PersistedReleaseData(this.distributionId, this.releaseData);

  PersistedReleaseData.fromJson(Map<String, dynamic> json)
    : distributionId = json['distributionId'],
      releaseData = ReleaseData.fromJson(json['releaseData']);

  Map<String, dynamic> toJson() => {
    'distributionId': distributionId,
    'releaseData': releaseData,
  };
}

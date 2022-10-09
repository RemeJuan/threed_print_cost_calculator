part of 'app.dart';

class MinimumAppVersion extends StatelessWidget {
  const MinimumAppVersion({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        } else {
          return UpgradeAlert(
            upgrader: Upgrader(
              minAppVersion: snapshot.data,
              dialogStyle: Platform.I.operatingSystem == OperatingSystem.iOS
                  ? UpgradeDialogStyle.cupertino
                  : UpgradeDialogStyle.material,
            ),
            child: child,
          );
        }
      },
    );
  }

  Future<String> init() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults(const <String, dynamic>{
      'minimumAppVersion': '1.0.7',
    });

    await remoteConfig.fetchAndActivate();

    return remoteConfig.getString('minimumAppVersion');
  }
}

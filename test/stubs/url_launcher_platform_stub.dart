import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

// Implémentation factice de UrlLauncherPlatform
class UrlLauncherPlatformStub extends UrlLauncherPlatform {
  bool launchUrlCalled = false;
  String? launchedUrl;

  @override
  Future<bool> canLaunch(String url) async {
    return true;
  }

  @override
  Future<bool> launch(
      String url, {
        required bool useSafariVC,
        required bool useWebView,
        required bool enableJavaScript,
        required bool enableDomStorage,
        required bool universalLinksOnly,
        required Map<String, String> headers,
        String? webOnlyWindowName,
      }) async {
    launchUrlCalled = true;
    launchedUrl = url;
    return true;
  }

  @override
  LinkDelegate? get linkDelegate => null;
}
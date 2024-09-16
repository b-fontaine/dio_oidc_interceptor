import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Credential> createCredentialWithRefreshToken(Client client, String refreshToken) async {
  return client.createCredential(refreshToken: refreshToken);
}

Future<Credential?> authenticate(
  Client client, {
  List<String> scopes = const [],
  Map<String, String>? queryParameters,
}) async {
  // create a function to open a browser with an url
  Future<bool> urlLauncher(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri) || UniversalPlatform.isAndroid) {
      return await launchUrl(uri, webOnlyWindowName: '_self');
    } else {
      throw 'Could not launch $url';
    }
  }

  // create an authenticator
  var authenticator = io.Authenticator(client,
      scopes: scopes, port: 4000, urlLancher: urlLauncher);

  // starts the authentication
  var c = await authenticator.authorize();

  // close the webview when finished
  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    closeInAppWebView();
  }

  return c;
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  return null;
}

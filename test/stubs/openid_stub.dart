// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';

import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Classe OpenIdStub pour injecter les dépendances
class OpenIdStub extends OpenId {
  final http.Client httpClient;
  final LocalStorage localStorage;

  OpenIdStub({
    required super.configuration,
    super.dio,
    required this.httpClient,
    required this.localStorage,
  });

  @override
  Future<void> logout() async {
    final url = Uri.parse(
        "https://connect.listo.pro/realms/ante-prod/.well-known/openid-configuration");
    try {
      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var logoutUri = data['end_session_endpoint'];
        final Uri logoutUrl = Uri.parse(
            '$logoutUri?post_logout_redirect_uri=http%3A%2F%2Flocalhost:6900%2F&client_id=flutter-connect');
        localStorage.clear();
        if (logoutUri != null &&
            await UrlLauncherPlatform.instance
                .canLaunch(logoutUrl.toString())) {
          await UrlLauncherPlatform.instance.launch(
            logoutUrl.toString(),
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: <String, String>{},
          );
        }
      } else {
        throw Exception('Erreur lors de la requête: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception rencontrée: $e');
    }
  }
}

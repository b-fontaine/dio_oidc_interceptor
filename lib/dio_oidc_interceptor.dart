library dio_oidc_interceptor;

import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'openid/openid_io.dart'
    if (dart.library.html) 'openid/openid_browser.dart';

class OpenIdConfiguration {
  final String clientId;
  final String clientSecret;
  final Uri uri;
  final List<String> scopes;

  OpenIdConfiguration(
      {required this.clientId,
      required this.clientSecret,
      required this.uri,
      required this.scopes});
}

class OpenId extends Interceptor {
  final OpenIdConfiguration configuration;
  final Dio? dio;
  late final Clock _clock;
  Client? _client;

  final String _accessTokenField = "access_token";
  final String _refrshTokenField = "refresh_token";
  final String _tokenTypeField = "token_type";
  final String _expireTokenField = "expire_at";

  Dio get dioInstance => dio ?? Dio();

  Future<String?> getStorageValue(String key) async {
    await initLocalStorage();
    return localStorage.getItem(key);
  }

  Future<void> setStorageValue(String key, String value) async {
    await initLocalStorage();
    localStorage.setItem(key, value);
  }

  OpenId({
    required this.configuration,
    this.dio,
  }) {
    _clock = const Clock();
  }

  Future<bool> get isConnected => _alreadyAuthenticated();

  Future<Client> getClient() async {
    if (_client == null) {
      var issuer = await Issuer.discover(configuration.uri);
      _client = Client(
        issuer,
        configuration.clientId,
        clientSecret: configuration.clientSecret,
      );
    }
    return _client!;
  }

  Future<void> logout() async {
    final url = Uri.parse(
        "https://connect.listo.pro/realms/ante-prod/.well-known/openid-configuration");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var logoutUri = data['end_session_endpoint'];
        final Uri _logoutUrl = Uri.parse(
            '$logoutUri?post_logout_redirect_uri=http%3A%2F%2Flocalhost:6900%2F&client_id=flutter-connect');
        localStorage.clear();
        if (logoutUri != null && await canLaunchUrl(_logoutUrl)) {
          await launchUrl(_logoutUrl, webOnlyWindowName: '_self');
        }
      } else {
        throw Exception('Erreur lors de la requête: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception rencontrée: $e');
    }
  }

  Future<void> login({Map<String, String>? queryParameters}) async {
    if (await _alreadyAuthenticated()) {
      return;
    }
    var client = await getClient();
    var refreshToken = await getStorageValue(_refrshTokenField);
    Credential? credential;
    print('refreshToken == null: ${refreshToken == null}');
    if (refreshToken == null) {
      credential = await authenticate(client,
          scopes: configuration.scopes, queryParameters: queryParameters);
    } else {
      credential = client.createCredential(refreshToken: refreshToken);
    }
    print('credential == null: ${credential == null}');
    if (credential != null) {
      var tokens = await credential.getTokenResponse();
      if (tokens.accessToken == null) {
        throw Exception("Authentication failed !");
      }

      await setStorageValue(_accessTokenField, tokens.accessToken ?? "");
      await setStorageValue(_refrshTokenField, tokens.refreshToken ?? "");
      await setStorageValue(_tokenTypeField, tokens.tokenType ?? "Bearer");
      await setStorageValue(
          _expireTokenField, tokens.expiresAt?.toIso8601String() ?? "");
    }
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions? opt = err.response?.requestOptions;
    if (err.response?.statusCode == 401) {
      await login();
      if (opt != null) {
        return await dioInstance.request(
          opt.path,
          cancelToken: opt.cancelToken,
          data: opt.data,
          onReceiveProgress: opt.onReceiveProgress,
          onSendProgress: opt.onSendProgress,
          queryParameters: opt.queryParameters,
          options: Options(
            contentType: opt.contentType,
            headers: opt.headers,
            method: opt.method,
          ),
        );
      }
    }
  }

  Future<bool> _alreadyAuthenticated() async {
    if (await getStorageValue(_accessTokenField) == null) {
      return false;
    }
    final expiresAt =
        DateTime.tryParse(await getStorageValue(_expireTokenField) ?? "");
    if (expiresAt != null && expiresAt.isBefore(_clock.now())) {
      return false;
    }
    return true;
  }

  Future<String?> getAccessToken() async {
    if (await getStorageValue(_accessTokenField) == null) {
      await login();
    }

    final expiresAt =
        DateTime.tryParse(await getStorageValue(_expireTokenField) ?? "");
    if (expiresAt != null && expiresAt.isBefore(_clock.now())) {
      await login();
    }

    return await getStorageValue(_accessTokenField);
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getAccessToken();
    final tokenType = await getStorageValue(_tokenTypeField) ?? "Bearer";
    if (token != null) {
      options.headers['Authorization'] = '$tokenType $token';
    }
  }
}

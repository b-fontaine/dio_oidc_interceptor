library;

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'dio_oidc_interceptor_io.dart'
    if (dart.library.html) 'dio_oidc_interceptor_browser.dart';

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

  Future<void> clearStorageValues() async {
    await initLocalStorage();
    localStorage.removeItem(_accessTokenField);
    localStorage.removeItem(_refrshTokenField);
    localStorage.removeItem(_tokenTypeField);
    localStorage.removeItem(_expireTokenField);
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
    var accessToken = await getStorageValue(_accessTokenField);
    if ((accessToken ?? "").isEmpty) {
      return;
    }
    var logoutUrl = "${configuration.uri}/protocol/openid-connect/logout";
    await clearStorageValues();
    await launchUrlString(logoutUrl, webOnlyWindowName: "_self");
  }

  Future<void> login({Map<String, String>? queryParameters}) async {
    if (await _alreadyAuthenticated()) {
      return;
    }
    var client = await getClient();
    var refreshToken = await getStorageValue(_refrshTokenField);
    Credential? credential;
    if (refreshToken == null) {
      credential = await authenticate(client, scopes: configuration.scopes);
    } else {
      credential = client.createCredential(refreshToken: refreshToken);
    }
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
    super.onError(err, handler);
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

    super.onRequest(options, handler);
  }
}

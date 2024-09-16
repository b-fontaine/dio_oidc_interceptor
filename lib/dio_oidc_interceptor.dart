library dio_oidc_interceptor;

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String _refreshTokenField = "refresh_token";
  final String _idTokenField = "id_token";
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

  logout(Uri fallbackLogoutUrl) async {
    var accessToken = await getStorageValue(_accessTokenField);
    if ((accessToken ?? "").isEmpty) {
      return;
    }
    var idToken = await getStorageValue(_idTokenField);

    Uri? logoutUrl;
    if (idToken != null) {
      var client = await getClient();
      var credential =
          client.createCredential(accessToken: accessToken, idToken: idToken);
      logoutUrl = credential.generateLogoutUrl();
    }

    var url = logoutUrl ?? fallbackLogoutUrl;
    if (await canLaunchUrl(url)) {
      await launchUrl(url, webOnlyWindowName: '_self');
      localStorage.clear();
    }
  }

  Future<void> login({Map<String, String>? queryParameters}) async {
    if (await _alreadyAuthenticated()) {
      return;
    }
    var client = await getClient();
    Credential? credential;

    credential = await _handleRefreshToken(client);

    credential ??= await authenticate(client, scopes: configuration.scopes);

    if (credential != null) {
      var tokens = await credential.getTokenResponse();
      if (tokens.accessToken == null) {
        throw Exception("Authentication failed !");
      }

      await setStorageValue(_accessTokenField, tokens.accessToken ?? "");
      await setStorageValue(_refreshTokenField, tokens.refreshToken ?? "");
      await setStorageValue(
          _idTokenField, tokens.idToken.toCompactSerialization() ?? "");
      await setStorageValue(_tokenTypeField, tokens.tokenType ?? "Bearer");
      await setStorageValue(
          _expireTokenField, tokens.expiresAt?.toIso8601String() ?? "");
    }
  }

  Future<void> updatePassword(String clientId, String baseUrl) async {
    await launchUrl(Uri.parse(
        "$baseUrl/protocol/openid-connect/auth?client_id=$clientId&redirect_uri=$baseUrl%2Faccount%2Faccount-security%2Fsigning-in&state=e45365da-a970-4728-847b-7af70027ca77&response_mode=query&response_type=code&scope=openid&kc_action=UPDATE_PASSWORD"));
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

  Future<Credential?> _handleRefreshToken(Client client) async {
    var refreshToken = await getStorageValue(_refreshTokenField);
    Credential? credential;

    if (refreshToken != null) {
      credential = client.createCredential(refreshToken: refreshToken);
      try {
        var userInfo = await credential.getUserInfo();
        if (userInfo.email == null) {
          credential = null;
        }
      } catch (e) {
        credential = null;
      }
    }

    if (credential == null) {
      localStorage.clear();
    }

    return credential;
  }

  Future<bool> _alreadyAuthenticated() async {
    if (await getStorageValue(_accessTokenField) == null) {
      return false;
    }

    return !(await _isExpired());
  }

  Future<bool> _isExpired() async {
    final expiresAt =
        DateTime.tryParse(await getStorageValue(_expireTokenField) ?? "");
    if (expiresAt != null && expiresAt.isBefore(_clock.now())) {
      return true;
    }
    return false;
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

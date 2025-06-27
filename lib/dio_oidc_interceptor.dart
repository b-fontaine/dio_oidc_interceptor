library;

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart' show JwtDecoder;
import 'package:localstorage/localstorage.dart';
import 'package:openid_client/openid_client.dart';

import 'dio_oidc_interceptor_io.dart'
    if (dart.library.html) 'dio_oidc_interceptor_browser.dart';

/// Configuration for OpenId
///
/// [clientId] is the client id of the application
/// [clientSecret] is the client secret of the application
/// [uri] is the uri of the OpenId server
/// [scopes] is the list of scopes to request
///
/// Examplefor local Keycloak server:
/// ```dart
/// OpenIdConfiguration(
///  clientId: "example-id",
///  clientSecret: "example-clientSecret",
///  uri: Uri.parse("http://localhost:8080/realm/master"),
///  scopes: ["openid", "profile"],
///  );
///  ```
///
/// [OpenId] is an interceptor for Dio that handles OpenId authentication
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

/// OpenId Interceptor for Dio
///
/// [configuration] is the OpenId configuration
/// [dio] is the Dio instance to use
///
/// Example:
/// ```dart
/// OpenId(
///  configuration: OpenIdConfiguration(
///     clientId: "example-id",
///     clientSecret: "example-clientSecret",
///     uri: Uri.parse("http://localhost:8080/realm/master"),
///     scopes: ["openid", "profile"],
///   ),
///  );
///  ```
///
/// [OpenId] is an interceptor for Dio that handles OpenId authentication
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

  Future<String?> _getStorageValue(String key) async {
    await initLocalStorage();
    return localStorage.getItem(key);
  }

  Future<void> _setStorageValue(String key, String value) async {
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

  /// Constructor for OpenId
  /// [configuration] is the OpenId configuration
  /// [dio] is the Dio instance to use
  OpenId({
    required this.configuration,
    this.dio,
  }) {
    _clock = const Clock();
  }

  /// Check if user is connecter
  /// Return true if user is connected
  /// Return false if user is not connected
  /// Return false if user is connected but token is expired
  Future<bool> get isConnected async {
    if (await _alreadyAuthenticated()) {
      return true;
    }
    if (await _getStorageValue(_refrshTokenField) != null) {
      await _silentLogin();
    }
    return await _alreadyAuthenticated();
  }

  Future<void> _silentLogin() async {
    var client = await _getClient();
    var refreshToken = await _getStorageValue(_refrshTokenField);
    Credential? credential;
    if (refreshToken != null) {
      try {
        credential = client.createCredential(refreshToken: refreshToken);
      } catch (_) {}
    }
    if (credential != null &&
        credential.toJson()["token"]["access_token"] != null) {
      var tokens = await credential.getTokenResponse();
      if (tokens.accessToken == null) {
        await clearStorageValues();
      } else {
        await _setStorageValue(_accessTokenField, tokens.accessToken ?? "");
        await _setStorageValue(_refrshTokenField, tokens.refreshToken ?? "");
        await _setStorageValue(_tokenTypeField, tokens.tokenType ?? "Bearer");
        await _setStorageValue(
            _expireTokenField, tokens.expiresAt?.toIso8601String() ?? "");
      }
    }
  }

  Future<Client> _getClient() async {
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

  /// Logout the user
  ///
  /// Invalidate the token and clear the storage
  Future<void> logout() async {
    final token = await _getAccessToken();
    final tokenType = await _getStorageValue(_tokenTypeField) ?? "Bearer";
    final refreshToken = await _getStorageValue(_refrshTokenField) ?? "";
    BaseOptions options = BaseOptions(
      baseUrl: Uri.base.toString(),
      headers: {
        "Authorization": '$tokenType $token',
        'Content-type': 'application/x-www-form-urlencoded',
      },
    );
    var dio = Dio(options);

    var configUrl = "${configuration.uri}/.well-known/openid-configuration";
    var result = await dio.get(configUrl);
    Map<String, dynamic>? config = result.data;
    if (config != null) {
      var endSessionUrl = config["end_session_endpoint"] as String?;
      if (endSessionUrl != null) {
        var logout = await dio.post(
          endSessionUrl,
          data:
              "client_id=${configuration.clientId}&client_secret=${configuration.clientSecret}&refresh_token=$refreshToken",
        );
        if (logout.statusCode != 204) {
          throw Exception("Logout failed");
        }
        await clearStorageValues();
      }
    }
  }

  /// Login the user
  ///
  /// Authenticate the user and store the token in the storage
  /// [queryParameters] is the query parameters to pass to the authentication if needed
  ///
  /// Example:
  /// ```dart
  /// await openId.login(queryParameters: {"prompt": "login"});
  /// ```
  ///
  Future<void> login({Map<String, String>? queryParameters}) async {
    if (await _alreadyAuthenticated()) {
      return;
    }
    var client = await _getClient();
    var refreshToken = await _getStorageValue(_refrshTokenField);
    Credential? credential;
    if (refreshToken != null) {
      try {
        credential = client.createCredential(refreshToken: refreshToken);
      } catch (_) {}
    }
    if (credential?.toJson()["token"]["access_token"] == null) {
      await clearStorageValues();
      credential = await authenticate(
        client,
        scopes: configuration.scopes,
        queryParameters: queryParameters,
      );
    }
    if (credential != null) {
      var tokens = await credential.getTokenResponse();
      if (tokens.accessToken == null) {
        throw Exception("Authentication failed !");
      }

      await _setStorageValue(_accessTokenField, tokens.accessToken ?? "");
      await _setStorageValue(_refrshTokenField, tokens.refreshToken ?? "");
      await _setStorageValue(_tokenTypeField, tokens.tokenType ?? "Bearer");
      await _setStorageValue(
          _expireTokenField, tokens.expiresAt?.toIso8601String() ?? "");
    }
  }

  /// Executed when an error occurs
  ///
  /// If the error is a 401, try to login again
  /// Else call the error handler
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
    if (await _getStorageValue(_accessTokenField) == null) {
      return false;
    }
    final expiresAt =
        DateTime.tryParse(await _getStorageValue(_expireTokenField) ?? "");
    if (expiresAt != null && expiresAt.isBefore(_clock.now())) {
      return false;
    }
    return true;
  }

  Future<String?> _getAccessToken() async {
    if (await _getStorageValue(_accessTokenField) == null) {
      await login();
    }

    final expiresAt =
        DateTime.tryParse(await _getStorageValue(_expireTokenField) ?? "");
    if (expiresAt != null && expiresAt.isBefore(_clock.now())) {
      await login();
    }

    return await _getStorageValue(_accessTokenField);
  }

  /// Executed before a request
  ///
  /// Add the token to the request headers
  /// Refresh the token if needed
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _getAccessToken();
    final tokenType = await _getStorageValue(_tokenTypeField) ?? "Bearer";
    if (token != null) {
      options.headers['Authorization'] = '$tokenType $token';
    }

    super.onRequest(options, handler);
  }

  Future<String?> get accessToken => _getAccessToken();

  Future<Map<String, dynamic>> get userInfo async {
    var token = await _getAccessToken();
    if (token == null) {
      return {};
    }
    try {
      var tokenType = await _getStorageValue(_tokenTypeField) ?? "Bearer";
      var dio = Dio();
      var result = await dio.get(
        '${configuration.uri}/userinfo',
        options: Options(
          headers: {
            "Authorization": '$tokenType $token',
          },
        ),
      );
      return result.data;
    } catch (_) {
      return JwtDecoder.decode(token);
    }
  }
}

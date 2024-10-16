import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'stubs/local_storage_stub.dart';
import 'stubs/openid_stub.dart';
import 'stubs/url_launcher_platform_stub.dart';

void main() async {
  late Dio dio;
  late DioAdapter dioAdapter;

  Response<dynamic> response;

  test('Logout, should clear local storage and launch logout URL', () async {
    // Stubber l'appel HTTP
    final mockHttpClient = MockClient((request) async {
      if (request.url.toString() ==
          'https://connect.listo.pro/realms/ante-prod/.well-known/openid-configuration') {
        final response = {
          'end_session_endpoint': 'https://logout.url/logout',
        };
        return http.Response(jsonEncode(response), 200);
      }
      return http.Response('Not Found', 404);
    });

    // Fournir une implémentation factice pour localStorage
    final fakeLocalStorage = LocalStorageStub();

    // Remplacer UrlLauncherPlatform.instance par une implémentation factice
    final fakeUrlLauncherPlatform = UrlLauncherPlatformStub();
    UrlLauncherPlatform.instance = fakeUrlLauncherPlatform;

    // Créer une instance de OpenId en utilisant les stubs
    final openId = OpenIdStub(
      configuration: OpenIdConfiguration(
        clientId: 'flutter-connect',
        clientSecret: 'your_client_secret',
        uri: Uri.parse(
            'https://connect.listo.pro/realms/ante-prod/.well-known/openid-configuration'),
        scopes: ['openid', 'profile', 'email'],
      ),
      httpClient: mockHttpClient,
      localStorage: fakeLocalStorage,
    );

    // Appeler la méthode logout
    await openId.logout();

    // Vérifier que localStorage.clear() a été appelé
    expect(fakeLocalStorage.clearCalled, isTrue);

    // Vérifier que launchUrl a été appelé avec l'URL attendue
    expect(fakeUrlLauncherPlatform.launchUrlCalled, isTrue);
    expect(
      fakeUrlLauncherPlatform.launchedUrl,
      'https://logout.url/logout?post_logout_redirect_uri=http%3A%2F%2Flocalhost:6900%2F&client_id=flutter-connect',
    );
  });

  group('Basic', () {
    const baseUrl = 'https://example.com';

    setUp(() {
      //// Exact body check
      // dio = Dio(BaseOptions(contentType: Headers.jsonContentType));
      // dioAdapter = DioAdapter(
      //  dio: dio,
      //  matcher: const FullHttpRequestMatcher(needsExactBody: true),
      // );

      dio = Dio(BaseOptions(baseUrl: baseUrl));
      dioAdapter = DioAdapter(
        dio: dio,

        // [FullHttpRequestMatcher] is a default matcher class
        // (which actually means you haven't to pass it manually) that matches entire URL.
        //
        // Use [UrlRequestMatcher] for matching request based on the path of the URL.
        //
        // Or create your own http-request matcher via extending your class from  [HttpRequestMatcher].
        // See -> issue:[124] & pr:[125]
        matcher: const FullHttpRequestMatcher(needsExactBody: true),
      );
    });

    test('returns a response with 200 OK success status code', () async {
      const route = '/';

      dioAdapter.onGet(
        route,
        (server) => server.reply(200, null),
      );

      dioAdapter.onPost(route, (server) {
        return server.reply(200, null);
      }, data: {'key': 'value'});

      response = await dio.get(route);

      expect(response.statusCode, 200);
    });
  });

  group('Accounts', () {
    const baseUrl = 'https://example.com';

    const userCredentials = <String, dynamic>{
      'email': 'test@example.com',
      'password': 'password',
    };

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: baseUrl));
      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );
    });

    test('signs up user', () async {
      const route = '/signup';

      dioAdapter.onPost(
        route,
        (server) => server.reply(
          201,
          null,
          delay: const Duration(seconds: 1),
        ),
        data: userCredentials,
      );

      response = await dio.post(route, data: userCredentials);

      expect(response.statusCode, 201);
    });

    test('signs in user and fetches account information', () async {
      const signInRoute = '/signin';
      const accountRoute = '/account';

      const accessToken = <String, dynamic>{
        'token': 'ACCESS_TOKEN',
      };

      final headers = <String, dynamic>{
        'Authentication': 'Bearer $accessToken',
      };

      const userInformation = <String, dynamic>{
        'id': 1,
        'email': 'test@example.com',
        'password': 'password',
        'email_verified': false,
      };

      dioAdapter
        ..onPost(
          signInRoute,
          (server) => server.throws(
            401,
            DioException(
              requestOptions: RequestOptions(
                path: signInRoute,
              ),
            ),
          ),
        )
        ..onPost(
          signInRoute,
          (server) => server.reply(200, accessToken),
          data: userCredentials,
        )
        ..onGet(
          accountRoute,
          (server) => server.reply(200, userInformation),
          headers: headers,
        );

      expect(
        () async => await dio.post(signInRoute),
        throwsA(isA<DioException>()),
      );

      response = await dio.post(signInRoute, data: userCredentials);

      expect(response.data, accessToken);

      response = await dio.get(
        accountRoute,
        options: Options(headers: headers),
      );

      expect(response.data, userInformation);
    });
  });
}

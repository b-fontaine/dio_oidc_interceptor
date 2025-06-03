// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' show window;

import 'package:dio/dio.dart';
import 'package:openid_client/openid_client.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Credential?> authenticate(
  Client client, {
  List<String> scopes = const [],
  Map<String, String>? queryParameters,
}) async {
  var q = queryParameters;

  AuthorizationCodeParameters? parameters;

  if (q != null &&
      q.containsKey('state') &&
      q.containsKey('code') &&
      q.containsKey('session_state')) {
    parameters = AuthorizationCodeParameters(
      code: q['code']!,
      state: q['state']!,
      sessionState: q['session_state']!,
      iss: q['iss']!,
    );
  }

  if (parameters != null) {
    window.history.replaceState('', '', makeReturnUrl());
    window.localStorage.remove('openid_client:state');
    window.localStorage['openid_client:state'] = parameters.state;
    return authenticateWithAuthorizationCode(
      client,
      parameters.code,
      parameters.state,
      parameters.sessionState,
      parameters.iss,
    );
  }

  var flow = makeFlow(client, scopes: scopes);
  window.localStorage['openid_client:state'] = flow.state;

  var result =
      await launchUrl(flow.authenticationUri, webOnlyWindowName: '_self');

  if (!result) {
    throw Exception('Action annulée.');
  }
  return null;
}

Future<Credential> authenticateWithAuthorizationCode(
  Client client,
  String code,
  String state,
  String sessionState,
  String iss,
) async {
  Map<String, String> queryParameters = {
    'grant_type': 'authorization_code',
    'client_id': client.clientId,
    'code': code,
    'redirect_uri': makeReturnUrl(),
    'state': state,
    'session_state': sessionState,
    'iss': iss,
    'client_secret': client.clientSecret!,
  };

  BaseOptions options = BaseOptions(
    baseUrl: makeReturnUrl(),
    headers: {
      "Accept": "application/json",
      'Content-type': 'application/x-www-form-urlencoded',
    },
  );

  var dio = Dio(options);
  var data = queryParameters.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  try {
    /*final response = await dio.post(
      'https://corsproxy.io/?${Uri.encodeComponent(client.issuer.metadata.tokenEndpoint.toString())}',
      data: data,
    );*/
    final response = await dio.postUri(
      client.issuer.metadata.tokenEndpoint!,
      data: data,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get token: ${response.data}');
    }

    var token = TokenResponse.fromJson(response.data);

    return client.createCredential(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      expiresIn: token.expiresIn,
    );
  } catch (e) {
    throw Exception('Failed to get token: $e');
  }
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  return null;
}

Flow makeFlow(Client client, {List<String> scopes = const []}) {
  return Flow.authorizationCode(
    client,
    state: window.localStorage['openid_client:state'],
    scopes: scopes,
    redirectUri: Uri.parse(window.location.href).removeFragment(),
  );
}

String makeReferer() {
  final uri = Uri.parse(window.location.href);
  var result = '${uri.scheme}://${uri.host}';
  if (uri.port != 80 && uri.port != 443) {
    result += ':${uri.port}';
  }
  return result;
}

String makeReturnUrl() {
  final uri = Uri.parse(window.location.href);
  var result = '${uri.scheme}://${uri.host}';
  if (uri.port != 80 && uri.port != 443) {
    result += ':${uri.port}';
  }
  result += uri.path;
  return result;
}

class AuthorizationCodeParameters {
  final String code;
  final String state;
  final String sessionState;
  final String iss;

  AuthorizationCodeParameters({
    required this.code,
    required this.state,
    required this.sessionState,
    required this.iss,
  });
}

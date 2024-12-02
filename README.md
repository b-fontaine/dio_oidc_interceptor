# [EN] Flutter OIDC Interceptor for Dio

A Flutter Dio Interceptor for OpenID Connect (OIDC) authentication.

## Getting Started

Add package to your `pubspec.yaml`:

```shell
flutter pub add dio_oidc_interceptor
```

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';

void main() async {
  final dio = Dio();
  final interceptor = OidcInterceptor(
        configuration: OpenIdConfiguration(
      clientId: 'your-client-id',
      clientSecret: 'your-client-secret',
      uri: 'https://your-oidc-provider.com',
      scopes: ['openid', 'profile', 'email'],
    ));
  dio.interceptors.add(interceptor);
  
  await dio.login();
  final response = await dio.get('https://api.example.com');
}
```

### Use with Retrofit

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'backend_client.g.dart';

@RestApi(baseUrl: 'https://website/api/version/')
abstract class BackendClient {
  factory BackendClient(Dio dio, {String baseUrl}) = _BackendClient;
}

class Backend {
  late final Dio _dio;
  late final BackendClient _backendClient;
  final interceptor = OidcInterceptor(
      configuration: OpenIdConfiguration(
        clientId: 'your-client-id',
        clientSecret: 'your-client-secret',
        uri: 'https://your-oidc-provider.com',
        scopes: ['openid', 'profile', 'email'],
      ));

  Backend(Authentication auth, Configuration configuration) {
    _dio = Dio()..interceptors.add(interceptor);
    _backendClient = BackendClient(_dio, baseUrl: 'https://website/api/version/');
  }

  Dio get dio => _dio;
  BackendClient get backendClient => _backendClient;
}
```

# [FR] Intercepteur OIDC Flutter pour Dio

Un intercepteur Dio pour Flutter, dédié à l'authentification OpenID Connect (OIDC).

## Prise en main

Ajoutez le package dans votre fichier `pubspec.yaml` :

```shell
flutter pub add dio_oidc_interceptor
```

## Utilisation

```dart
import 'package:dio/dio.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';

void main() async {
  final dio = Dio();
  final interceptor = OidcInterceptor(
        configuration: OpenIdConfiguration(
      clientId: 'votre-client-id',
      clientSecret: 'votre-client-secret',
      uri: 'https://votre-fournisseur-oidc.com',
      scopes: ['openid', 'profile', 'email'],
    ));
  dio.interceptors.add(interceptor);
  
  await dio.login();
  final response = await dio.get('https://api.exemple.com');
}
```

### Utilisation avec Retrofit

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'backend_client.g.dart';

@RestApi(baseUrl: 'https://website/api/version/')
abstract class BackendClient {
  factory BackendClient(Dio dio, {String baseUrl}) = _BackendClient;
}

class Backend {
  late final Dio _dio;
  late final BackendClient _backendClient;
  final interceptor = OidcInterceptor(
      configuration: OpenIdConfiguration(
        clientId: 'votre-client-id',
        clientSecret: 'votre-client-secret',
        uri: 'https://votre-fournisseur-oidc.com',
        scopes: ['openid', 'profile', 'email'],
      ));

  Backend(Authentication auth, Configuration configuration) {
    _dio = Dio()..interceptors.add(interceptor);
    _backendClient = BackendClient(_dio, baseUrl: 'https://website/api/version/');
  }

  Dio get dio => _dio;
  BackendClient get backendClient => _backendClient;
}
```

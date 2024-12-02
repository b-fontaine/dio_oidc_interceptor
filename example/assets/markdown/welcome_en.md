# Welcome

Here, you'll learn how to use the OIDC interceptor for Dio.

## What is OIDC?

OpenID Connect (OIDC) is an authentication protocol built on top of OAuth 2.0. It allows applications to securely verify a user's identity and obtain basic profile information (such as name or email) through an authorization server. OIDC adds an identity layer to OAuth 2.0, which focuses solely on authorization, by providing a standardized mechanism for handling authentication.

OIDC relies on JSON Web Tokens (JWT) as the format for transmitting authentication data between parties, ensuring a compact, secure, and easy-to-verify structure. It defines several authentication flows, such as the *Authorization Code Flow*, *Implicit Flow*, and *Hybrid Flow*, tailored to different use cases.

### Benefits of OIDC

1. **Centralized Authentication**: OIDC allows user authentication to be centralized through an Identity Provider (IdP). This simplifies access to multiple applications while enhancing the user experience, for instance, via Single Sign-On (SSO).

2. **Enhanced Security**: By leveraging JWTs and standards such as HTTPS, OIDC ensures that exchanged data is authentic and has not been altered or intercepted by malicious parties.

3. **Reduced Client-Side Responsibility**: By delegating authentication to an identity provider, client applications (or *relying parties*) avoid directly handling sensitive information like passwords, reducing the risk of security breaches.

4. **Interoperability**: As an open standard, OIDC is compatible with many services and platforms. This enables developers to easily integrate authentication features with popular providers like Google, Microsoft, or Okta.

5. **Access to User Data**: Beyond authentication, OIDC allows applications to retrieve additional user information via claims included in the token, such as email address, first name, or roles, to personalize the user experience.

In summary, OIDC combines OAuth 2.0's authorization capabilities with a robust identity layer, addressing modern security and usability needs in distributed systems.

## Using the OIDC Interceptor for Dio

To use the OIDC interceptor with Dio, follow these steps:

### Add the Required Dependencies

Ensure you have the Dio and optionally Retrofit dependencies installed in your Flutter project. Add the `dio_oidc_interceptor` package to your `pubspec.yaml` file by running the following command:

```shell
flutter pub add dio_oidc_interceptor
```

### Configure the OIDC Interceptor

Create an instance of `OidcInterceptor` by specifying the required OIDC configuration, such as `clientId`, `clientSecret`, the OIDC provider URI, and the required scopes. Add this interceptor to your Dio client.

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

### Using the Interceptor with Retrofit

If you use Retrofit to manage network calls, you can also integrate the OIDC interceptor into your service interfaces.

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

### Using the Listo Starter Kit for Flutter

You can use the Listo Starter Kit for Flutter to quickly start a project with clean architecture, configured dependency injection, and test-driven development with Gherkin.

To do this, fork the [Listo Starter Kit](https://github.com/Listo-Paye/listo_starter_kit) project and follow the README instructions to get started.

Then, follow the example in this application to integrate the OIDC interceptor into your project.

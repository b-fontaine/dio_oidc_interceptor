# Flutter OIDC Interceptor for Dio

> You can see then French version of the README file [here](./README_FR.md).

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

# Login

The login process follows the OpenID Connect flow. To log in, the user is redirected to the application's login page. Once authenticated, the user is redirected back to the page that initiated the login process.

> **IMPORTANT** The protocol used is authorization_code.

![authorization code flow](https://raw.githubusercontent.com/Listo-Paye/dio_oidc_interceptor/refs/heads/main/example/assets/images/authorization_code.png)

## What About the Code?

Using the `dio_oidc_interceptor` package, clean architecture, and dependency injection, the implementation proceeds as follows:

First, define an authentication service contract:

```dart
abstract class Authentication {
  Interceptor get oAuthInterceptor;
  Future<void> login({Map<String, String>? queryParameters});
  Future<void> refreshToken();
}
```

Then, create an implementation for this contract:

```dart
@dev
@prod
@Singleton(as: Authentication)
class AuthenticationImpl implements Authentication {
  late final OpenId _oAuth;

  AuthenticationImpl(Configuration configuration) {
    _oAuth = OpenId(
        configuration: OpenIdConfiguration(
      clientId: configuration.authClientId,
      clientSecret: configuration.authClientSecret,
      uri: Uri.parse(configuration.authTokenUrl),
      scopes: ['openid', 'profile', 'email'],
    ));
  }

  @override
  Future<void> login({Map<String, String>? queryParameters}) =>
      _oAuth.login(queryParameters: queryParameters);

  @override
  Interceptor get oAuthInterceptor => _oAuth;

  @override
  Future<void> refreshToken() => _oAuth.login();
}
```

You may notice that refreshToke` is simply a login without parameters. Indeed, the first thing the dio_oidc_interceptor package does is check if the refresh_token is available and use it if possible. If not, it initiates a full authentication flow.

## queryParameters

The use of `queryParameters` is exclusive to web redirection scenarios. When a user is redirected to a login page, the page typically includes parameters in the URL. These parameters are captured by the browser and can be passed to the application. You can retrieve them as follows:

```dart
var queryParameters = Map.fromEntries(Uri.base.queryParameters.entries);
if (queryParameters.containsKey("code") &&
    queryParameters.containsKey("state") &&
    queryParameters.containsKey("session_state")) {
    await authentication.login(queryParameters: queryParameters);
}
```

## Complete Usage Example

Below is an example using clean architecture and the BLoC pattern:

**BLoC**

```dart
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginInteractor _loginInteractor;

  LoginBloc(this._loginInteractor) : super(LoginInitial()) {
    on<LoginInitialEvent>(_onLoginInitialEvent);
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginInitialEvent(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
  ) async {
    await _loginInteractor();
    Map<String, String> queryParameters = Uri.base.queryParameters.isNotEmpty
        ? Uri.base.queryParameters
        : _toMap(Uri.base.fragment);
    print(queryParameters.entries
        .map((e) => "${e.key} ${e.value}")
        .toList()
        .join("\n"));
    if (queryParameters.containsKey('code')) {
      await _loginInteractor.login(queryParameters: queryParameters);
      Uri.base.removeFragment();
      await _loginInteractor();
    }
    await emit.onEach(
      _loginInteractor.isConnected,
      onData: (isConnected) {
        if (isConnected) {
          emit(LoginLoaded());
        } else {
          emit(NotLoggedIn());
        }
      },
    );
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    await _loginInteractor.login();
    emit(LoginLoading());
  }

  Map<String, String> _toMap(String fragment) {
    var data = fragment
        .split('&')
        .map((e) => e.split('='))
        .map((e) => MapEntry(e.first, e.last));
    return Map.fromEntries(data);
  }
}
```

**Interactor**

```dart
@singleton
class LoginInteractor {
  final IsConnectedUseCase _isConnectedUseCase;
  final LoginUseCase _loginUseCase;

  LoginInteractor(this._isConnectedUseCase, this._loginUseCase);

  Stream<bool> get isConnected => _isConnectedUseCase.stream;

  FutureOr<void> call() => _isConnectedUseCase();

  FutureOr<void> login({Map<String, String>? queryParameters}) async {
    await _loginUseCase(queryParameters: queryParameters);
    await _isConnectedUseCase();
  }
}
```

**View**

```dart
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginLoaded) {
          context.push("/logout");
        }
      },
      builder: (context, state) {
        if (state is LoginInitial) {
          context.read<LoginBloc>().add(LoginInitialEvent());
        }
        if (state is LoginLoading) {
          return ScaffoldWithDoc(
            title: "login",
            buttonLabel: "Local connect with default login (admin/admin)",
            isLoading: true,
            onButtonPressed: () {},
          );
        }
        return ScaffoldWithDoc(
          title: "login",
          buttonLabel: "Local connect with default login (admin/admin)",
          onButtonPressed: () {
            context.read<LoginBloc>().add(LoginButtonPressed());
          },
        );
      },
    );
  }
}
```

Take note of the interactions between the view and the BLoC. When the view is initialized, the BLoC is notified of the initial event. The BLoC checks if there are parameters in the URL and uses them to log in. It then verifies if the user is logged in and notifies the view of the result.

The use of streams is particularly handy for state change notifications. Every time you make a call, it updates the stream, so you don’t have to handle it manually.

These are the main files for handling login behavior. I encourage you to review the example’s source code to analyze all the details.

# Retrofit Call and Logout

## Retrofit Call

Based on the [Starter Kit Listo](https://github.com/Listo-Paye/flutter_starter_kit), you first need to configure dependency injection:

In `lib/core/di/network`, add the Retrofit configuration:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
}
```

Then, create an overlay for the `ApiClient` interface to add interceptors:

```dart
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

import '../di_module.dart';

@dev
@prod
@Singleton(as: ApiModule)
class ApiModuleImpl implements ApiModule {
  late final Dio _dio;
  late final ApiClient _client;

  ApiModuleImpl(Configuration configuration) {
    var cache = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
    );
    _dio = Dio()
      ..interceptors.addAll([
        DioCacheInterceptor(options: cache),
      ]);
    _client = ApiClient(_dio, baseUrl: configuration.apiBaseUrl);
  }

  @override
  ApiClient get client => _client;

  @override
  Dio get dio => _dio;
}
```

The reference interface allows easy creation of a stub for testing:

```dart
import 'package:dio/dio.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:injectable/injectable.dart';

import '../di_module.dart';

@test
@Singleton(as: ApiModule)
class ApiModuleStub implements ApiModule {
  late final Dio _dio;
  late final ApiClient _client;

  ApiModuleStub(Configuration configuration) {
    _dio = Dio()..interceptors.add(MockInterceptor(basePath: 'mocks/api'));
    _client = ApiClient(_dio, baseUrl: configuration.apiBaseUrl);
  }

  @override
  ApiClient get client => _client;

  @override
  Dio get dio => _dio;
}
```

Now, simply add your service in the configuration file:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
  
  @GET('/api/client/{clientId}/contacts')
  Future<Map<String, dynamic>> getContacts(@Path('clientId') String clientId);
}
```

For more information about using Retrofit, consult the [official documentation](https://pub.dev/packages/retrofit).

## Logout

The package handles logout in two steps:
1. A POST logout call to the `end_session_endpoint` (ensure the server supports this feature).
2. If the POST call is successful, authentication data is deleted.

### If Your Server Does Not Support POST to `end_session_endpoint`

You can redirect to the same URL (`end_session_endpoint` provided in the `.well-known` configuration). More information can be found in the OpenID official documentation: [https://openid.net/specs/openid-connect-session-1_0.html#RPLogout](https://openid.net/specs/openid-connect-session-1_0.html#RPLogout).

### Logout Example

Here’s how logout is managed in our application:

**View**

```dart
class LogoutView extends StatelessWidget {
  const LogoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          context.push("/login");
        }
      },
      builder: (context, state) {
        return ScaffoldWithDoc(
          title: "logout",
          buttonLabel: "Log out and return to login",
          onButtonPressed: () {
            context.read<LogoutBloc>().add(LogoutEventLogout());
          },
        );
      },
    );
  }
}
```

**Bloc**

```dart
@injectable
class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutInteractor _logoutInteractor;

  @factoryMethod
  LogoutBloc(this._logoutInteractor) : super(LogoutInitialState()) {
    on<LogoutEventLogout>(_onLogoutButtonPressed);
  }

  Future<void> _onLogoutButtonPressed(
    LogoutEventLogout event,
    Emitter<LogoutState> emit,
  ) async {
    await _logoutInteractor();
    emit(LogoutSuccessState());
  }
}
```

**Interactor**

```dart
@singleton
class LogoutInteractor {
  final LogoutUseCase _logoutUseCase;

  LogoutInteractor(this._logoutUseCase);

  FutureOr<void> call() => _logoutUseCase();
}
```

You’ll notice the simplicity of the logout process. It’s important to note that the logout process is backend-managed. Therefore, ensure that the backend supports this functionality.

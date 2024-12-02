# Login

The login process follows the OpenID Connect flow. To log in, the user is redirected to the application's login page. Once authenticated, the user is redirected back to the page that initiated the login process.  

> **IMPORTANT** The protocol used is authorization_code.  

![authorization code flow](resource:assets/images/authorization_code.png)

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

# Connexion

Le principe de connexion suit le processus OpenID Connect. Pour se connecter, l'utilisateur doit être redirigé vers la page de connexion de l'application. Une fois connecté, l'utilisateur est redirigé vers la page qui a lancé sa connexion.

> **ATTENTION** Le protocole utilisé est l'authorization_code.

![authorization code flow](resource:assets/images/authorization_code.png)

## Et dans le code ?

En utilisant le package `dio_oidc_interceptor`, la clean archi et l'injection de dépendance, je procède comme suit

Le mets en place un contrat de service d'authentification :

```dart
abstract class Authentication {
  Interceptor get oAuthInterceptor;
  Future<void> login({Map<String, String>? queryParameters});
  Future<void> refreshToken();
}
```

Je crée une implémentation de ce contrat :

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

Vous remarquerez que le refreshToken est simplement un login sans paramètres. Oui, la première chose que fait le package dio_oidc_interceptor est de vérifier si le refresh_token est disponible et de l'utiliser si possible.
S'il n'y arrive pas, il lance une authentification complète.

## queryParameters

L'utilisation de queryParameters est exclusif aux problématiques web de redirection. En effet, lorsqu'un utilisateur est redirigé vers une page de connexion, il est redirigé vers une page de connexion avec des paramètres dans l'URL. Ces paramètres sont récupérés par le navigateur et peuvent être transmis à l'application.
Vous pouvez les récupérer ainsi :

```dart
var queryParameters = Map.fromEntries(Uri.base.queryParameters.entries);
 if (queryParameters.containsKey("code") &&
    queryParameters.containsKey("state") &&
    queryParameters.containsKey("session_state")) {
    await authentication.login(queryParameters: queryParameters);
}
```

## Exemple complet d'utilisation

Voici un exemple en utilisant la clean archi et le pattern BLoC :

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

Il faut bien regarder les interractions entre la view et le bloc. Au démarrage de la vue, le bloc est notifié de l'événement initial. Le bloc vérifie si des paramètres sont présents dans l'URL et les utilise pour se connecter. Ensuite, il vérifie si l'utilisateur est connecté et notifie la vue du résultat.

L'utilisation des Streams est particulièrement pratique pour les notifications de changement d'état. A chaque fois que vous lancez un appel, celui-ci met à jour le stream et vous n'avez pas à le traiter.

Ce sont ici les principaux fichiers pour le comportement de connexion, je vous invite à regarder le code source de l'exemple pour analyser les tenants et aboutissants.

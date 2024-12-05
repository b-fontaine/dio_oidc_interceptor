# Intercepteur Flutter OIDC pour Dio

## Qu'est-ce que l'OIDC ?

L'OpenID Connect (OIDC) est un protocole d'authentification basé sur le protocole OAuth 2.0, conçu pour permettre aux applications de vérifier l'identité d'un utilisateur de manière sécurisée et d'obtenir des informations de profil utilisateur de base (comme le nom ou l'email) via un serveur d'autorisation. OIDC ajoute une couche d'identité à OAuth 2.0, qui se concentre uniquement sur l'autorisation, en fournissant un mécanisme standardisé pour gérer l'authentification.

OIDC repose sur des JSON Web Tokens (JWT) comme format pour transmettre les données d'authentification entre les parties, garantissant une structure compacte, sécurisée, et facile à vérifier. Il définit plusieurs flux d'authentification (ou "flows"), comme le *Authorization Code Flow*, le *Implicit Flow*, et le *Hybrid Flow*, adaptés à différents scénarios d'utilisation.

### Utilité de l'OIDC

1. **Authentification centralisée** : OIDC permet de centraliser l'authentification des utilisateurs via un fournisseur d'identité (Identity Provider ou IdP). Cela simplifie l'accès aux applications multiples tout en offrant une meilleure expérience utilisateur (par exemple, un SSO ou Single Sign-On).

2. **Sécurité renforcée** : Grâce à l'usage des JWT et de normes comme HTTPS, OIDC garantit que les données échangées sont authentiques et qu'elles n'ont pas été altérées ou interceptées par des tiers malveillants.

3. **Réduction des responsabilités côté client** : En déléguant l'authentification à un fournisseur d'identité, les applications clientes (ou *relying parties*) n'ont pas à gérer directement des informations sensibles comme les mots de passe, ce qui réduit le risque de failles de sécurité.

4. **Interopérabilité** : En tant que standard ouvert, OIDC est compatible avec de nombreux services et plateformes. Cela permet aux développeurs d'intégrer facilement des fonctionnalités d'authentification avec des fournisseurs populaires comme Google, Microsoft, ou Okta.

5. **Accessibilité des données utilisateur** : En plus de l'authentification, OIDC permet aux applications de récupérer des informations supplémentaires sur l'utilisateur grâce à des "claims" incluses dans le token, comme l'adresse email, le prénom ou des informations de rôle, pour personnaliser l'expérience utilisateur.

Pour résumer, OIDC combine l'efficacité d'OAuth 2.0 pour la gestion des autorisations avec une couche d'identité robuste, répondant aux besoins modernes de sécurité et de convivialité dans les systèmes distribués.

## Utilisation de l'intercepteur OIDC pour Dio

Pour utiliser l'intercepteur OIDC avec Dio, vous devez suivre les étapes suivantes :

### Ajouter les dépendances nécessaires

Assurez-vous d'avoir les dépendances Dio et, en option, Retrofit installées dans votre projet Flutter.
Ajoutez le package `dio_oidc_interceptor` à votre fichier `pubspec.yaml` en exécutant la commande suivante :

```shell
flutter pub add dio_oidc_interceptor
```

### Configurer l'intercepteur OIDC

Créez une instance de `OidcInterceptor` en spécifiant la configuration OIDC requise, comme le `clientId`, le `clientSecret`, l'URI du fournisseur OIDC, et les scopes nécessaires. Ajoutez cet intercepteur à votre client Dio.

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

### Utiliser l'intercepteur avec Retrofit

Si vous utilisez Retrofit pour gérer vos appels réseau, vous pouvez également intégrer l'intercepteur OIDC dans vos interfaces de service.

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

### Utiliser le starter kit Listo pour Flutter

Vous pouvez utiliser le Starter Kit Listo pour Flutter pour démarrer rapidement un projet avec une Clean Archi, l'injection de dépendances configurée ainsi que de quoi piloter vos développements par les tests Gherkin.

Pour ça, vous pouvez créer un fork du projet [Listo Starter Kit](https://github.com/Listo-Paye/listo_starter_kit) et suivre les instructions du README pour démarrer votre projet.

Ensuite, il vous suffira de suivre l'exemple de cette application pour intégrer l'intercepteur OIDC à votre projet.

# Connexion

Le principe de connexion suit le processus OpenID Connect. Pour se connecter, l'utilisateur doit être redirigé vers la page de connexion de l'application. Une fois connecté, l'utilisateur est redirigé vers la page qui a lancé sa connexion.

> **ATTENTION** Le protocole utilisé est l'authorization_code.

![authorization code flow](https://raw.githubusercontent.com/Listo-Paye/dio_oidc_interceptor/refs/heads/main/example/assets/images/authorization_code.png)

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

# Appel Retrofit et déconnexion

## Appel Retrofit

En se basant sur le [Starter Kit Listo](https://github.com/Listo-Paye/flutter_starter_kit), il faut d'abord configurer l'injection de dépendance :

Dans lib/core/di/network, ajouter la configuration retrofit :

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
}

```

Puis créer une surcouche de l'interface ApiClient pour ajouter des intercepteurs :

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

L'interface de référence permet de créer facilement un Stub pour les tests :

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

Voilà, il ne vous reste qu'à ajouter votre service dans le fichier de configuration :

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
Pour plus d'information sur l'utilisation de Retrofit, vous pouvez consulter la [documentation officielle](https://pub.dev/packages/retrofit).

## Déconnexion

Le package vous déconnecte en 2 étapes :
1. Appel POST de déconnexion via le end_session_endpoint (attention, il faut que le serveur supporte cette fonctionnalité)
2. Si l'appel POST a fonctionné, les données d'authentification sont supprimées.

### Si votre serveur ne supporte pas l'appel du end_session_endpoint en POST

Vous pouvez débrancher vers cette même URL (end_session_endpoint fournie dans le .well-known). Vous trouverez plus d'information dans la documentation officielle OpenID : [https://openid.net/specs/openid-connect-session-1_0.html#RPLogout](https://openid.net/specs/openid-connect-session-1_0.html#RPLogout)

### Exemple de déconnexion

Voyons comment nous gérons la déconnexion dans notre application :

**Vue**

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

Vous pourrez remarquer la simplicité du processus de déconnexion. Il est important de noter que le processus de déconnexion est géré par le backend. Il est donc nécessaire de s'assurer que le backend supporte cette fonctionnalité.

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

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

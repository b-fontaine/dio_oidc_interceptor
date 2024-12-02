import 'package:dio_oidc_interceptor_example/core/di/di_module.dart';
import 'package:injectable/injectable.dart';

@injectable
class IsAuthenticatedRepository {
  final Authentication _authentication;

  @factoryMethod
  IsAuthenticatedRepository(this._authentication);

  Future<bool> call() => _authentication.isAuthenticated;
}

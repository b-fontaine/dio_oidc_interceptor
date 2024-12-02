import 'package:dio_oidc_interceptor_example/core/di/di_module.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutRepository {
  final Authentication _authentication;

  @factoryMethod
  LogoutRepository(this._authentication);

  Future<void> call() => _authentication.logout();
}

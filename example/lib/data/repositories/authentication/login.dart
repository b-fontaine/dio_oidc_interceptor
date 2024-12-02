import 'package:dio_oidc_interceptor_example/core/di/di_module.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginRepository {
  final Authentication _authentication;

  @factoryMethod
  LoginRepository(this._authentication);

  Future<void> call({Map<String, String>? queryParameters}) =>
      _authentication.login(queryParameters: queryParameters);
}

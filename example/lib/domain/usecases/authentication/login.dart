import 'package:dio_oidc_interceptor_example/data/data_module.dart';
import 'package:injectable/injectable.dart';

@singleton
class LoginUseCase {
  final LoginRepository _loginRepository;

  LoginUseCase(this._loginRepository);

  Future<void> call({Map<String, String>? queryParameters}) =>
      _loginRepository(queryParameters: queryParameters);
}

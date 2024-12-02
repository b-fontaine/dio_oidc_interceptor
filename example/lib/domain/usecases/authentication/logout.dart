import 'package:dio_oidc_interceptor_example/data/data_module.dart';
import 'package:injectable/injectable.dart';

@singleton
class LogoutUseCase {
  final LogoutRepository _logoutRepository;

  LogoutUseCase(this._logoutRepository);

  Future<void> call() => _logoutRepository();
}

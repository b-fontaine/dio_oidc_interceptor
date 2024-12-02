import 'dart:async';

import 'package:dio_oidc_interceptor_example/domain/domain_module.dart';
import 'package:injectable/injectable.dart';

@singleton
class LogoutInteractor {
  final LogoutUseCase _logoutUseCase;

  LogoutInteractor(this._logoutUseCase);

  FutureOr<void> call() => _logoutUseCase();
}

import 'dart:async';

import 'package:dio_oidc_interceptor_example/domain/domain_module.dart';
import 'package:injectable/injectable.dart';

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

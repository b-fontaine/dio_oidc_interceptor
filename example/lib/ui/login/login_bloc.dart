import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'login_event.dart';
import 'login_interactor.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginInteractor _loginInteractor;

  @factoryMethod
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

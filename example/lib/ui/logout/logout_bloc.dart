import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'logout_event.dart';
import 'logout_interactor.dart';
import 'logout_state.dart';

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

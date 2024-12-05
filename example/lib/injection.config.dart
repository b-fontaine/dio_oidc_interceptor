// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/di/authentication/authentication_impl.dart' as _i588;
import 'core/di/authentication/authentication_stub.dart' as _i690;
import 'core/di/configuration/configuration.dart' as _i459;
import 'core/di/configuration/configuration_dev.dart' as _i404;
import 'core/di/configuration/configuration_prod.dart' as _i658;
import 'core/di/configuration/configuration_test.dart' as _i595;
import 'core/di/di_module.dart' as _i268;
import 'core/di/network/api_module_impl.dart' as _i1022;
import 'core/di/network/api_module_stub.dart' as _i763;
import 'data/data_module.dart' as _i947;
import 'data/repositories/authentication/is_connected.dart' as _i698;
import 'data/repositories/authentication/login.dart' as _i74;
import 'data/repositories/authentication/logout.dart' as _i45;
import 'domain/domain_module.dart' as _i230;
import 'domain/usecases/authentication/is_connected.dart' as _i883;
import 'domain/usecases/authentication/login.dart' as _i834;
import 'domain/usecases/authentication/logout.dart' as _i696;
import 'ui/login/login_bloc.dart' as _i795;
import 'ui/login/login_interactor.dart' as _i73;
import 'ui/login/login_module.dart' as _i379;
import 'ui/logout/logout_bloc.dart' as _i293;
import 'ui/logout/logout_interactor.dart' as _i928;
import 'ui/logout/logout_module.dart' as _i699;
import 'ui/router.dart' as _i766;
import 'ui/ui_module.dart' as _i887;

const String _test = 'test';
const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i459.Configuration>(
      () => _i595.ConfigurationDev(),
      registerFor: {_test},
    );
    gh.singleton<_i459.Configuration>(
      () => _i404.ConfigurationDev(),
      registerFor: {_dev},
    );
    gh.singleton<_i459.Configuration>(
      () => _i658.ConfigurationDev(),
      registerFor: {_prod},
    );
    gh.singleton<_i268.Authentication>(
      () => _i588.AuthenticationImpl(gh<_i268.Configuration>()),
      registerFor: {
        _dev,
        _prod,
      },
    );
    gh.singleton<_i766.AppRouter>(
      () => _i766.AppRouter(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i268.Authentication>(
      () => _i690.AuthenticationStub(),
      registerFor: {_test},
    );
    gh.singleton<_i699.LogoutModule>(
        () => _i699.LogoutModule(gh<_i887.AppRouter>()));
    gh.singleton<_i379.LoginModule>(
        () => _i379.LoginModule(gh<_i766.AppRouter>()));
    gh.factory<_i698.IsAuthenticatedRepository>(
        () => _i698.IsAuthenticatedRepository(gh<_i268.Authentication>()));
    gh.factory<_i74.LoginRepository>(
        () => _i74.LoginRepository(gh<_i268.Authentication>()));
    gh.factory<_i45.LogoutRepository>(
        () => _i45.LogoutRepository(gh<_i268.Authentication>()));
    gh.singleton<_i883.IsConnectedUseCase>(
        () => _i883.IsConnectedUseCase(gh<_i947.IsAuthenticatedRepository>()));
    gh.singleton<_i268.ApiModule>(
      () => _i763.ApiModuleStub(gh<_i268.Configuration>()),
      registerFor: {_test},
    );
    gh.singleton<_i696.LogoutUseCase>(
        () => _i696.LogoutUseCase(gh<_i947.LogoutRepository>()));
    gh.singleton<_i834.LoginUseCase>(
        () => _i834.LoginUseCase(gh<_i947.LoginRepository>()));
    gh.singleton<_i73.LoginInteractor>(() => _i73.LoginInteractor(
          gh<_i230.IsConnectedUseCase>(),
          gh<_i230.LoginUseCase>(),
        ));
    gh.singleton<_i928.LogoutInteractor>(
        () => _i928.LogoutInteractor(gh<_i230.LogoutUseCase>()));
    gh.factory<_i293.LogoutBloc>(
        () => _i293.LogoutBloc(gh<_i928.LogoutInteractor>()));
    gh.singleton<_i268.ApiModule>(
      () => _i1022.ApiModuleImpl(
        gh<_i268.Authentication>(),
        gh<_i268.Configuration>(),
      ),
      registerFor: {
        _dev,
        _prod,
      },
    );
    gh.factory<_i795.LoginBloc>(
        () => _i795.LoginBloc(gh<_i73.LoginInteractor>()));
    return this;
  }
}

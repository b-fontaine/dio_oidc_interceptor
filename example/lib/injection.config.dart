// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/di/configuration/configuration.dart' as _i459;
import 'core/di/configuration/configuration_dev.dart' as _i404;
import 'core/di/configuration/configuration_prod.dart' as _i658;
import 'core/di/configuration/configuration_test.dart' as _i595;
import 'core/di/di_module.dart' as _i268;
import 'core/di/network/api_module_impl.dart' as _i1022;
import 'core/di/network/api_module_stub.dart' as _i763;
import 'ui/router.dart' as _i766;

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
    gh.singleton<_i766.AppRouter>(
      () => _i766.AppRouter(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i268.ApiModule>(
      () => _i763.ApiModuleImpl(gh<_i268.Configuration>()),
      registerFor: {_test},
    );
    gh.singleton<_i268.ApiModule>(
      () => _i1022.ApiModuleImpl(gh<_i268.Configuration>()),
      registerFor: {
        _dev,
        _prod,
      },
    );
    return this;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'injection.dart';
import 'ui/app.dart';

/// [EN] Example of an app using oidc_interceptor package.
/// [FR] Exemple d'application utilisant le package oidc_interceptor.
///
/// [EN] You can see the implementation on lib/core/di/authentication_impl.dart
/// [FR] Vous pouvez voir l'implémentation dans lib/core/di/authentication_impl.dart
///
/// [EN] After that, all the code follow clean architecture pattern.
/// [FR] Après cela, tout le code suit le pattern de clean architecture.
FutureOr<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR', null);
  configureDependencies();
  runApp(App());
}

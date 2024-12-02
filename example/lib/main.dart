import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'injection.dart';
import 'ui/app.dart';

FutureOr<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR', null);
  configureDependencies();
  runApp(App());
}

import 'dart:ui';

import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:dio_oidc_interceptor_example/flavors.dart';
import 'package:dio_oidc_interceptor_example/injection.dart';
import 'package:dio_oidc_interceptor_example/ui/ui_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Usage: L'application démarre depuis la route {'/'}
Future<void> lapplicationDemarreDepuisLaRoute(
    WidgetTester tester, String route) async {
  MockInterceptor.clearHistory();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR', null);
  F.appFlavor = Flavor.test;
  getIt.allowReassignment = true;
  configureDependencies();
  TestWidgetsFlutterBinding.ensureInitialized();
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1;
  tester.view.platformDispatcher.textScaleFactorTestValue = 0.5;
  await tester.pumpAndSettle();
  await tester.pumpWidget(App(
    initialRoute: route,
  ));
  await tester.pumpAndSettle();
  expect(getIt<AppRouter>().goRouter.routeInformationProvider.value.uri,
      equals(Uri.parse(route)));

  getIt<AppRouter>().goRouter.refresh();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

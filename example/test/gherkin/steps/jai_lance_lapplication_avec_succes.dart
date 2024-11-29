import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:dio_oidc_interceptor_example/flavors.dart';
import 'package:dio_oidc_interceptor_example/injection.dart';
import 'package:dio_oidc_interceptor_example/ui/ui_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> jaiLanceLapplicationAvecSucces(WidgetTester tester) async {
  MockInterceptor.clearHistory();
  F.appFlavor = Flavor.test;
  getIt.allowReassignment = true;
  configureDependencies();
  TestWidgetsFlutterBinding.ensureInitialized();
  await tester.pumpWidget(App());
  await tester.pumpAndSettle();
  tester.view.physicalSize = const Size(1900, 1200);
  tester.view.devicePixelRatio = 1;
  tester.view.platformDispatcher.textScaleFactorTestValue = 0.5;
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

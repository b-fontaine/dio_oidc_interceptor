import 'package:flutter_test/flutter_test.dart';

/// Usage: Je vois le texte {'dio_oidc_interceptor: logout'}
Future<void> jeVoisLeTexte(WidgetTester tester, String param1) async {
  expect(find.text(param1), findsOneWidget);
}

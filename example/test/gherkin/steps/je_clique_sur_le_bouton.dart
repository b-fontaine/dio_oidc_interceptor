import 'package:flutter_test/flutter_test.dart';

/// Usage: Je clique sur le bouton {'Local connect with default login (admin/admin)'}
Future<void> jeCliqueSurLeBouton(WidgetTester tester, String param1) async {
  await tester.tap(find.text(param1));
  await tester.pumpAndSettle();
}

import 'package:flutter_test/flutter_test.dart';

import 'je_vois_le_texte.dart';

/// Usage: I see the text {'dio_oidc_interceptor: login'}
Future<void> iSeeTheText(WidgetTester tester, String param1) =>
    jeVoisLeTexte(tester, param1);

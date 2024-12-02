import 'package:flutter_test/flutter_test.dart';

import 'je_clique_sur_le_bouton.dart';

/// Usage: I click on the button {'Go to login'}
Future<void> iClickOnTheButton(WidgetTester tester, String param1) =>
    jeCliqueSurLeBouton(tester, param1);

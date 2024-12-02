// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../steps/jai_lance_lapplication_avec_succes.dart';
import './../steps/je_clique_sur_le_bouton.dart';
import './../steps/je_vois_le_texte.dart';

void main() {
  group('''example''', () {
    testWidgets('''Je me connecte''', (tester) async {
      await jaiLanceLapplicationAvecSucces(tester);
      await jeCliqueSurLeBouton(tester, 'Go to login');
      await jeCliqueSurLeBouton(
          tester, 'Local connect with default login (admin/admin)');
      await jeVoisLeTexte(tester, 'dio_oidc_interceptor: logout');
    });
    testWidgets('''Je me déconnecte''', (tester) async {
      await jaiLanceLapplicationAvecSucces(tester);
      await jeCliqueSurLeBouton(tester, 'Go to login');
      await jeCliqueSurLeBouton(
          tester, 'Local connect with default login (admin/admin)');
      await jeCliqueSurLeBouton(tester, 'Log out and return to login');
      await jeVoisLeTexte(tester, 'dio_oidc_interceptor: login');
    });
  });
}

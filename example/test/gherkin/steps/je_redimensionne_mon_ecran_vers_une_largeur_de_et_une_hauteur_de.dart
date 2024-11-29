import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: Je redimensionne mon écran vers une largeur de {1900} et une hauteur de {1080}
Future<void> jeRedimensionneMonEcranVersUneLargeurDeEtUneHauteurDe(
    WidgetTester tester, double largeur, double hauteur) async {
  tester.view.physicalSize = Size(largeur, hauteur);
  tester.view.devicePixelRatio = 1;
  tester.view.platformDispatcher.textScaleFactorTestValue = 0.5;
  await tester.pumpAndSettle();
  addTearDown(() => tester.view.reset());
}

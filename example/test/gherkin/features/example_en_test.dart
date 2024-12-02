// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../gherkin/steps/i_have_successfully_launched_the_application.dart';
import '../../gherkin/steps/i_click_on_the_button.dart';
import '../../gherkin/steps/i_see_the_text.dart';

void main() {
  group('''example''', () {
    testWidgets('''I log in''', (tester) async {
      await iHaveSuccessfullyLaunchedTheApplication(tester);
      await iClickOnTheButton(tester, 'Go to login');
      await iClickOnTheButton(
          tester, 'Local connect with default login (admin/admin)');
      await iSeeTheText(tester, 'dio_oidc_interceptor: logout');
    });
    testWidgets('''I log out''', (tester) async {
      await iHaveSuccessfullyLaunchedTheApplication(tester);
      await iClickOnTheButton(tester, 'Go to login');
      await iClickOnTheButton(
          tester, 'Local connect with default login (admin/admin)');
      await iClickOnTheButton(tester, 'Log out and return to login');
      await iSeeTheText(tester, 'dio_oidc_interceptor: login');
    });
  });
}

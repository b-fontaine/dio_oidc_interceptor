// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:septeo_design_system/septeo_design_system.dart';

import '../flavors.dart';
import '../injection.dart';
import 'router.dart';

class App extends StatelessWidget {
  final AppRouter _router = getIt<AppRouter>();
  final String? initialRoute;
  App({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: F.title,
      theme: SepteoDesignSystem.themes.main,
      routerConfig: (initialRoute == null)
          ? _router.goRouter
          : _router.initWithRoute(initialRoute!),
    );
  }
}

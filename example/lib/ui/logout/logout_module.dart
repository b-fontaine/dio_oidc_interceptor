import 'package:injectable/injectable.dart';

import '../ui_module.dart';
import 'view/logout_page.dart';

@singleton
class LogoutModule {
  final AppRouter _appRouter;

  LogoutModule(
    this._appRouter,
  ) {
    configure();
  }

  void configure() {
    _appRouter.addRoute(
      path: "/logout",
      builder: (context, state) => LogoutPage(),
    );
  }
}

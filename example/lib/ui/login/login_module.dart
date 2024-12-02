import 'package:injectable/injectable.dart';

import '../router.dart';
import 'view/login_page.dart';

@singleton
class LoginModule {
  final AppRouter _appRouter;

  LoginModule(
    this._appRouter,
  ) {
    configure();
  }

  void configure() {
    _appRouter.addRoute(
      path: "/login",
      builder: (context, state) => LoginPage(),
    );
  }
}

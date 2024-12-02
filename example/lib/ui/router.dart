// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'common/common_module.dart';

@singleton
class AppRouter {
  GoRouter? _goRouter;
  late final ValueNotifier<RoutingConfig> _routingConfiguration;

  AppRouter() {
    _routingConfiguration = ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          ShellRoute(
            builder: (context, state, child) {
              return child; // Ajouter ici le socle commun de toute votre application
            },
            routes: [
              transitionGoRoute(
                path: '/',
                builder: (context, state) => ScaffoldWithDoc(
                  title: "welcome",
                  buttonLabel: "Go to login",
                  onButtonPressed: () => context.push('/login'),
                ),
              )
            ],
          )
        ],
      ),
    );
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  GoRouter initWithRoute(String route) {
    _goRouter = GoRouter.routingConfig(
      routingConfig: _routingConfiguration,
      initialLocation: route,
    );
    return _goRouter!;
  }

  GoRouter get goRouter {
    _goRouter ??= GoRouter.routingConfig(routingConfig: _routingConfiguration);
    return _goRouter!;
  }

  void addRoute({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    _routingConfiguration.value.routes[0].routes.add(
      transitionGoRoute(
        path: path,
        builder: builder,
      ),
    );
  }

  void go(String path) {
    goRouter.go(path);
  }

  @disposeMethod
  void dispose() {
    goRouter.dispose();
    _routingConfiguration.dispose();
  }
}

GoRoute transitionGoRoute({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      child: builder(context, state),
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeIn).animate(animation),
          child: child,
        );
      },
    ),
  );
}

// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  GoRouter? _goRouter;
  late final ValueNotifier<RoutingConfig> _routingConfiguration;
  final String _fragment = Uri.base.fragment;
  Map<String, String> _params =
      Map.fromEntries(Uri.base.queryParameters.entries);

  Map<String, String> get queryParameters =>
      _params.isNotEmpty ? _params : _toMap(_fragment);

  set queryParameters(Map<String, String> params) {
    _params = params;
  }

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
                builder: (context, state) => Center(child: const Text("En construction")), // Route racine, les autres seront ajoutées par injection de dépendance
              )
            ],
          )
        ],
      ),
    );

    Uri.base.removeFragment();
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

  Map<String, String> _toMap(String fragment) {
    var data = fragment
        .split('&')
        .map((e) => e.split('='))
        .map((e) => MapEntry(e.first, e.last));
    return Map.fromEntries(data);
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

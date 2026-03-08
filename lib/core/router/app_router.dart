import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Minimal router shell. Auth redirect and bottom-nav shell added in Stage 2/5.
class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Kigali City Services – Placeholder'),
          ),
        ),
      ),
    ],
  );
}

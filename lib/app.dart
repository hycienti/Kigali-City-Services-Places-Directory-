import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/router/auth_refresh_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AuthRefreshNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthRefreshNotifier();
    _router = createAppRouter(_authNotifier);
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen is only valid inside build. Keep router's redirect in sync with auth.
    ref.listen(authStateProvider, (prev, next) {
      _authNotifier.update(next);
    });
    _authNotifier.update(ref.read(authStateProvider));
    return MaterialApp.router(
      title: 'Kigali City Services',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

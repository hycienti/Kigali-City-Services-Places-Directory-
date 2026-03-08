import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import 'auth_refresh_notifier.dart';

/// Builds the app router with auth redirect. [authNotifier] is used by
/// redirect and refreshListenable so route updates when auth state changes.
GoRouter createAppRouter(AuthRefreshNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = authNotifier.value;
      return auth.when(
        data: (AuthUser? user) {
          final path = state.uri.path;
          if (user == null) {
            if (path == '/login' || path == '/sign-up') return null;
            return '/login';
          }
          if (!user.emailVerified) {
            if (path == '/verify-email') return null;
            return '/verify-email';
          }
          if (path == '/login' || path == '/sign-up' || path == '/verify-email') {
            return '/';
          }
          return null;
        },
        loading: () => null,
        error: (error, stackTrace) => null,
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/auth_user.dart';

/// Notifier used by GoRouter's refreshListenable.
/// When auth state changes, update() is called and redirect runs again.
class AuthRefreshNotifier extends ChangeNotifier {
  AsyncValue<AuthUser?> _value = const AsyncValue.loading();

  AsyncValue<AuthUser?> get value => _value;

  void update(AsyncValue<AuthUser?> v) {
    _value = v;
    notifyListeners();
  }
}

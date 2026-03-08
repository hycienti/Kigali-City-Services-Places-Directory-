import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyLocationNotifications = 'location_notifications_enabled';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// Whether location-based notifications are enabled (simulation; persisted locally).
final notificationPreferenceProvider =
    AsyncNotifierProvider<NotificationPreferenceNotifier, bool>(() {
  return NotificationPreferenceNotifier();
});

class NotificationPreferenceNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool(_keyLocationNotifications) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(_keyLocationNotifications, value);
      state = AsyncValue.data(value);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

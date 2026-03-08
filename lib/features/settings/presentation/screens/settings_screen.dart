import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final uid = user?.uid ?? '';
    final profileAsync = ref.watch(userProfileProvider(uid));
    final notificationsAsync = ref.watch(notificationPreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (user != null) ...[
            _ProfileRow(
              label: 'Email',
              value: user.email,
            ),
            profileAsync.when(
              data: (profile) => _ProfileRow(
                label: 'Display name',
                value: profile?.displayName ?? '—',
              ),
              loading: () => const _ProfileRow(
                label: 'Display name',
                value: '…',
              ),
              error: (_, __) => const _ProfileRow(
                label: 'Display name',
                value: '—',
              ),
            ),
          ] else
            const Text('Not signed in'),
          const SizedBox(height: 24),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          notificationsAsync.when(
            data: (enabled) => SwitchListTile(
              title: const Text('Enable location-based notifications'),
              subtitle: const Text(
                'Simulation: preference is saved locally.',
                style: TextStyle(fontSize: 12),
              ),
              value: enabled,
              activeColor: AppTheme.accent,
              onChanged: (value) async {
                await ref
                    .read(notificationPreferenceProvider.notifier)
                    .setEnabled(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications simulation enabled.'
                            : 'Notifications simulation disabled.',
                      ),
                    ),
                  );
                }
              },
            ),
            loading: () => const ListTile(
              title: Text('Enable location-based notifications'),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const ListTile(
              title: Text('Enable location-based notifications'),
              subtitle: Text('Failed to load preference'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kigali City Services v1.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

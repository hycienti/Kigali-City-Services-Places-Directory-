import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/listing_providers.dart';
import '../widgets/listing_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid ?? '';
    final myListingsAsync = ref.watch(myListingsProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: myListingsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have no listings yet.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/listing/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add listing'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final listing = list[index];
              return ListingCard(
                listing: listing,
                showActions: true,
                canEdit: listing.createdBy == uid,
                onEdit: () => context.push('/listing/edit/${listing.id}'),
                onDelete: () => _confirmDelete(context, ref, listing.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(myListingsProvider(uid)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/listing/new'),
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text(
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await ref.read(listingCrudProvider.notifier).deleteListing(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }
}

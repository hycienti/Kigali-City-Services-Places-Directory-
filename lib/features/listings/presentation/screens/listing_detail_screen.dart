import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/listing_providers.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing details'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return const Center(child: Text('Listing not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  listing.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.category.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accent,
                      ),
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Address', value: listing.address),
                _DetailRow(label: 'Contact', value: listing.contactNumber),
                _DetailRow(label: 'Description', value: listing.description),
                _DetailRow(
                  label: 'Location',
                  value: '${listing.latitude}, ${listing.longitude}',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Map and directions will be added in Stage 6.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
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
                onPressed: () =>
                    ref.invalidate(listingDetailProvider(listingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}

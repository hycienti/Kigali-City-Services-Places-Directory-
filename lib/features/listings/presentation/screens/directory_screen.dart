import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing.dart';
import '../providers/listing_providers.dart';
import '../widgets/listing_card.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: selectedCategory == null,
                  onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
                ),
                ...ListingCategory.values.map(
                  (c) => _FilterChip(
                    label: c.displayName,
                    selected: selectedCategory == c.name,
                    onTap: () =>
                        ref.read(selectedCategoryProvider.notifier).state = c.name,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: filteredAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No listings match your search.'),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => ListingCard(
                    listing: list[index],
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
                          ref.invalidate(listingsStreamProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

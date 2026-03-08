import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
  });

  final Listing listing;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (showActions && canEdit) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                listing.category.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              if (listing.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  listing.address,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

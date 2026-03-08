import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _iconForCategory(listing.category),
                      color: AppTheme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.category.displayName,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        if (listing.address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  listing.address,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showActions && canEdit)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onEdit,
                          style: IconButton.styleFrom(
                            foregroundColor: AppTheme.primaryDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(ListingCategory category) {
    switch (category) {
      case ListingCategory.hospital:
        return Icons.local_hospital_outlined;
      case ListingCategory.policeStation:
        return Icons.local_police_outlined;
      case ListingCategory.library:
        return Icons.local_library_outlined;
      case ListingCategory.restaurant:
        return Icons.restaurant_outlined;
      case ListingCategory.cafe:
        return Icons.coffee_outlined;
      case ListingCategory.park:
        return Icons.park_outlined;
      case ListingCategory.touristAttraction:
        return Icons.tour_outlined;
      case ListingCategory.utilityOffice:
        return Icons.business_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}

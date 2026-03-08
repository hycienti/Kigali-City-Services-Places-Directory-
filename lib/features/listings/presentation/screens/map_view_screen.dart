import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/osm_poi.dart';
import '../providers/listing_providers.dart';
import '../providers/overpass_providers.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<MapEvent>? _mapEventSub;

  static final LatLng _kigaliCenter = LatLng(kKigaliLat, kKigaliLng);

  @override
  void initState() {
    super.initState();
    _mapEventSub = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        final center = _mapController.camera.center;
        ref.read(mapPoiCenterProvider.notifier).state =
            (lat: center.latitude, lng: center.longitude);
      }
    });
  }

  @override
  void dispose() {
    _mapEventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(filteredListingsProvider);
    final poisAsync = ref.watch(overpassPoisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _kigaliCenter,
              initialZoom: 13,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) {},
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: AppConstants.osmPackageName,
              ),
              listingsAsync.when(
                data: (listings) => MarkerLayer(
                  markers: listings
                  .where((l) => l.latitude != 0 || l.longitude != 0)
                  .map((l) => Marker(
                        point: LatLng(l.latitude, l.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showListingSheet(context, l),
                          child: const Icon(
                            Icons.place,
                            color: AppTheme.accent,
                            size: 36,
                          ),
                        ),
                      ))
                  .toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
              poisAsync.when(
                data: (pois) => MarkerLayer(
                  markers: pois
                  .map((p) => Marker(
                        point: LatLng(p.latitude, p.longitude),
                        width: 28,
                        height: 28,
                        child: GestureDetector(
                          onTap: () => _showOsmPoiSheet(context, p),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ))
                  .toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),
            ],
          ),
          poisAsync.when(
            data: (_) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'OSM POIs could not be loaded. Move the map to retry.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showListingSheet(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.place, color: AppTheme.accent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.name,
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            listing.category.displayName,
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push('/listing/${listing.id}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOsmPoiSheet(BuildContext context, OsmPoi poi) {
    final name = poi.name ?? poi.amenity ?? 'POI';
    final subtitle = [poi.amenity, poi.tagsSummary]
        .where((x) => x != null && x.isNotEmpty)
        .join(' · ');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _openDirections(ctx, poi.latitude, poi.longitude);
                  },
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text('Get directions'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDirections(
      BuildContext context, double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }
}

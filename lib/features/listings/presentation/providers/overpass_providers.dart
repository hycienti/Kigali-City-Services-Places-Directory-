import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overpass/flutter_overpass.dart';

import '../../domain/entities/osm_poi.dart';

/// Kigali city center (default map center).
const double kKigaliLat = -1.9536;
const double kKigaliLng = 30.0606;

/// Radius in meters for Overpass POI fetch.
const double kOverpassRadius = 2500;

/// Grid step for cache key (~1.1 km). Same area reuses cache and avoids rate limits.
const double _cacheGridStep = 0.01;

const int _maxCacheEntries = 25;

final _flutterOverpass = FlutterOverpass();

/// In-memory cache: rounded (lat,lng) -> POIs. Reduces Overpass calls and keeps POIs when API fails.
String _cacheKey(double lat, double lng) {
  final rlat = (lat / _cacheGridStep).round() * _cacheGridStep;
  final rlng = (lng / _cacheGridStep).round() * _cacheGridStep;
  return '${rlat.toStringAsFixed(3)}_${rlng.toStringAsFixed(3)}';
}

final _poiCache = <String, List<OsmPoi>>{};
List<OsmPoi> _lastSuccessfulPois = [];

/// Current map center used to fetch OSM POIs. Map screen updates this on move end.
final mapPoiCenterProvider =
    StateProvider<({double lat, double lng})>((ref) => (lat: kKigaliLat, lng: kKigaliLng));

/// OSM POIs near the current [mapPoiCenterProvider]. Uses in-memory cache and fallback so POIs don't disappear on rate limit/errors.
final overpassPoisProvider = FutureProvider<List<OsmPoi>>((ref) async {
  final c = ref.watch(mapPoiCenterProvider);
  final key = _cacheKey(c.lat, c.lng);

  if (_poiCache.containsKey(key)) {
    return _poiCache[key]!;
  }

  try {
    final pois = await _fetchOverpassPois(c.lat, c.lng);
    if (_poiCache.length >= _maxCacheEntries) {
      final firstKey = _poiCache.keys.first;
      _poiCache.remove(firstKey);
    }
    _poiCache[key] = pois;
    _lastSuccessfulPois = pois;
    return pois;
  } catch (_) {
    if (_lastSuccessfulPois.isNotEmpty) {
      return _lastSuccessfulPois;
    }
    return [];
  }
});

/// Fetches OSM POIs from Overpass API (no cache).
Future<List<OsmPoi>> _fetchOverpassPois(double lat, double lng) async {
  final response = await _flutterOverpass.getNearbyNodes(
    latitude: lat,
    longitude: lng,
    radius: kOverpassRadius,
  );
  final elements = response.elements ?? [];
  final pois = <OsmPoi>[];
  for (final e in elements) {
    if (e.lat == null || e.lon == null) continue;
    final name = e.tags?.name;
    final amenity = e.tags?.amenity;
    final raw = e.tags?.rawTags ?? {};
    final tagsSummary = raw.entries
        .where((x) => x.key != 'name' && x.value != null)
        .take(3)
        .map((x) => '${x.key}=${x.value}')
        .join(', ');
    pois.add(OsmPoi(
      id: 'osm_${e.id}',
      latitude: e.lat!,
      longitude: e.lon!,
      name: name,
      amenity: amenity,
      tagsSummary: tagsSummary.isEmpty ? null : tagsSummary,
    ));
  }
  return pois.take(80).toList();
}

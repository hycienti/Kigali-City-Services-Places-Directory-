/// Simple POI from Overpass (OSM) for map display.
class OsmPoi {
  const OsmPoi({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.name,
    this.amenity,
    this.tagsSummary,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String? name;
  final String? amenity;
  final String? tagsSummary;
}

/// Category for a place or service listing. Stored as string in Firestore.
enum ListingCategory {
  hospital,
  policeStation,
  library,
  restaurant,
  cafe,
  park,
  touristAttraction,
  utilityOffice,
  other;

  String get displayName {
    switch (this) {
      case ListingCategory.hospital:
        return 'Hospital';
      case ListingCategory.policeStation:
        return 'Police Station';
      case ListingCategory.library:
        return 'Library';
      case ListingCategory.restaurant:
        return 'Restaurant';
      case ListingCategory.cafe:
        return 'Café';
      case ListingCategory.park:
        return 'Park';
      case ListingCategory.touristAttraction:
        return 'Tourist Attraction';
      case ListingCategory.utilityOffice:
        return 'Utility Office';
      case ListingCategory.other:
        return 'Other';
    }
  }

  static ListingCategory fromString(String value) {
    return ListingCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ListingCategory.other,
    );
  }
}

/// A place or service listing. Plain Dart; no Flutter/Firebase imports.
class Listing {
  final String id;
  final String name;
  final ListingCategory category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;

  const Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  Listing copyWith({
    String? id,
    String? name,
    ListingCategory? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Listing &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          address == other.address &&
          contactNumber == other.contactNumber &&
          description == other.description &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          createdBy == other.createdBy &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      Object.hash(id, name, category, address, contactNumber, description,
          latitude, longitude, createdBy, timestamp);
}

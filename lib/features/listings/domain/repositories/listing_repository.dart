import '../entities/listing.dart';

/// Listings data abstraction; no Firestore/Flutter types in signature.
/// Implemented by [FirestoreListingRepository] in data layer.
abstract class ListingRepository {
  Stream<List<Listing>> streamListings();

  Stream<List<Listing>> streamListingsByCategory(String category);

  Stream<List<Listing>> streamMyListings(String uid);

  Future<Listing?> getListing(String id);

  Future<String> createListing(Listing listing);

  Future<void> updateListing(Listing listing);

  Future<void> deleteListing(String id);
}

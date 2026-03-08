import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/errors/listing_exception.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listings_firestore_service.dart';

/// Firestore implementation of [ListingRepository].
/// Maps Firestore documents to [Listing]; uses [ListingsFirestoreService].
class FirestoreListingRepository implements ListingRepository {
  FirestoreListingRepository({
    ListingsFirestoreService? service,
    firebase_auth.FirebaseAuth? auth,
  })  : _service = service ?? ListingsFirestoreService(),
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  final ListingsFirestoreService _service;
  final firebase_auth.FirebaseAuth _auth;

  @override
  Stream<List<Listing>> streamListings() {
    return _service.streamListings().map(_listFromSnapshot);
  }

  @override
  Stream<List<Listing>> streamListingsByCategory(String category) {
    return _service
        .streamListingsByCategory(category)
        .map(_listFromSnapshot);
  }

  @override
  Stream<List<Listing>> streamMyListings(String uid) {
    return _service.streamMyListings(uid).map(_listFromSnapshot);
  }

  @override
  Future<Listing?> getListing(String id) async {
    try {
      final doc = await _service.getListing(id);
      if (doc == null || !doc.exists) return null;
      return _listingFromDoc(doc);
    } on FirebaseException catch (e) {
      throw ListingException(e.message ?? 'Failed to load listing', e.code);
    }
  }

  @override
  Future<String> createListing(Listing listing) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const ListingException('You must be signed in to create a listing.');
    }
    try {
      final data = _toFirestore(listing);
      data['createdBy'] = uid;
      data['timestamp'] = FieldValue.serverTimestamp();
      return await _service.createListing(data);
    } on FirebaseException catch (e) {
      throw ListingException(
        e.message ?? 'Failed to create listing',
        e.code,
      );
    }
  }

  @override
  Future<void> updateListing(Listing listing) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const ListingException('You must be signed in to update a listing.');
    }
    if (listing.createdBy != uid) {
      throw const ListingException('You can only update your own listings.');
    }
    try {
      final data = _toFirestore(listing);
      data['timestamp'] = FieldValue.serverTimestamp();
      await _service.updateListing(listing.id, data);
    } on FirebaseException catch (e) {
      throw ListingException(
        e.message ?? 'Failed to update listing',
        e.code,
      );
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
    } on FirebaseException catch (e) {
      throw ListingException(
        e.message ?? 'Failed to delete listing',
        e.code,
      );
    }
  }

  List<Listing> _listFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => _listingFromDoc(doc))
        .whereType<Listing>()
        .toList();
  }

  Listing? _listingFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;
    final ts = d['timestamp'];
    final timestamp = ts is Timestamp
        ? ts.toDate()
        : DateTime.now();
    return Listing(
      id: doc.id,
      name: d['name'] as String? ?? '',
      category: ListingCategory.fromString(d['category'] as String? ?? ''),
      address: d['address'] as String? ?? '',
      contactNumber: d['contactNumber'] as String? ?? '',
      description: d['description'] as String? ?? '',
      latitude: (d['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: d['createdBy'] as String? ?? '',
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> _toFirestore(Listing listing) {
    return {
      'name': listing.name,
      'category': listing.category.name,
      'address': listing.address,
      'contactNumber': listing.contactNumber,
      'description': listing.description,
      'latitude': listing.latitude,
      'longitude': listing.longitude,
      'createdBy': listing.createdBy,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Raw Firestore access for listings. No domain types; repository does mapping.
class ListingsFirestoreService {
  ListingsFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamListings() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamListingsByCategory(
      String category) {
    return _listings
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyListings(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getListing(String id) async {
    final doc = await _listings.doc(id).get();
    return doc.exists ? doc : null;
  }

  Future<String> createListing(Map<String, dynamic> data) async {
    final ref = await _listings.add(data);
    return ref.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _listings.doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }
}

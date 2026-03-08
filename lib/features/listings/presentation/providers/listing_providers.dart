import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../data/repositories/firestore_listing_repository.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return FirestoreListingRepository();
});

final listingsStreamProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingRepositoryProvider).streamListings();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final listingsAsync = ref.watch(listingsStreamProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return listingsAsync.when(
    data: (list) {
      var result = list;
      if (category != null && category.isNotEmpty) {
        result = result.where((l) => l.category.name == category).toList();
      }
      if (query.isNotEmpty) {
        result =
            result.where((l) => l.name.toLowerCase().contains(query)).toList();
      }
      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final myListingsProvider = StreamProvider.family<List<Listing>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return ref.watch(listingRepositoryProvider).streamMyListings(uid);
});

final listingDetailProvider =
    FutureProvider.family<Listing?, String>((ref, id) async {
  if (id.isEmpty) return null;
  return ref.read(listingRepositoryProvider).getListing(id);
});

enum CrudStatus { idle, loading, success, error }

final listingCrudProvider =
    StateNotifierProvider<ListingCrudNotifier, CrudStatus>((ref) {
  return ListingCrudNotifier(ref);
});

class ListingCrudNotifier extends StateNotifier<CrudStatus> {
  ListingCrudNotifier(this._ref) : super(CrudStatus.idle);

  final Ref _ref;

  Future<void> createListing(Listing listing) async {
    state = CrudStatus.loading;
    try {
      await _ref.read(listingRepositoryProvider).createListing(listing);
      _ref.invalidate(listingsStreamProvider);
      _ref.invalidate(myListingsProvider(_ref.read(currentUserProvider)?.uid ?? ''));
      state = CrudStatus.success;
    } catch (_) {
      state = CrudStatus.error;
      rethrow;
    }
  }

  Future<void> updateListing(Listing listing) async {
    state = CrudStatus.loading;
    try {
      await _ref.read(listingRepositoryProvider).updateListing(listing);
      _ref.invalidate(listingsStreamProvider);
      _ref.invalidate(myListingsProvider(listing.createdBy));
      _ref.invalidate(listingDetailProvider(listing.id));
      state = CrudStatus.success;
    } catch (_) {
      state = CrudStatus.error;
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    state = CrudStatus.loading;
    try {
      await _ref.read(listingRepositoryProvider).deleteListing(id);
      final uid = _ref.read(currentUserProvider)?.uid ?? '';
      _ref.invalidate(listingsStreamProvider);
      _ref.invalidate(myListingsProvider(uid));
      _ref.invalidate(listingDetailProvider(id));
      state = CrudStatus.success;
    } catch (_) {
      state = CrudStatus.error;
      rethrow;
    }
  }

  void reset() {
    state = CrudStatus.idle;
  }
}

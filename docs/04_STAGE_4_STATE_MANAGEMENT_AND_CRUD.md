# Stage 4: State Management and CRUD

This stage connects the listings feature to Riverpod: stream providers for all listings and “my listings,” filtered listings (category + search), detail provider, and notifiers for create/update/delete. The UI must not call Firestore or the repository directly—only through these providers.

---

## 1. Repository and dependency injection

- **File:** `lib/features/listings/presentation/providers/listing_providers.dart` (and optionally a separate file for notifiers)

Ensure `ListingRepository` is provided to the app. For example:

- `listingRepositoryProvider`: `Provider<ListingRepository>` that returns `FirestoreListingRepository` (with its dependencies, e.g. Firestore instance and Auth). If you use a service class, inject that into the repository and the repository into this provider.

---

## 2. Stream and read-only providers

All of these should expose `AsyncValue<T>` (or equivalent) so the UI can handle loading, data, and error.

| Provider | Type | Source | Purpose |
|----------|------|--------|---------|
| `listingsStreamProvider` | `StreamProvider<List<Listing>>` or `FutureProvider` over stream | `listingRepository.streamListings()` | All listings for Directory and Map View |
| `filterStateProvider` or `listingsFilterProvider` | `StateNotifierProvider` or two `StateProvider`s | — | Hold selected category (nullable string) and search query (string). UI updates these. |
| `filteredListingsProvider` | `Provider` or `FutureProvider` | Depends on `listingsStreamProvider` + filter state | Filters the stream by category and name query in memory (or use repository `streamListingsByCategory` / `streamListingsByQuery` if implemented). Returns filtered `List<Listing>`. |
| `myListingsProvider` | `StreamProvider<List<Listing>>` | `listingRepository.streamMyListings(uid)` | Requires current user uid (from auth provider). Used on My Listings screen. |
| `listingDetailProvider(id)` | `FutureProvider<Listing?>` or `StreamProvider<Listing?>` | `listingRepository.getListing(id)` (or a stream if you add one) | Single listing for detail page. Parameter: listing id. |

Implementation notes:

- For `filteredListingsProvider`: watch `listingsStreamProvider` and the filter state; when stream emits, apply category and name filter and return the list. Use `AsyncValue.guard` or similar to preserve loading/error from the stream.
- For `myListingsProvider`: take `uid` from `ref.watch(currentUserProvider)` (or auth equivalent); if null, return empty or loading. Pass uid to `streamMyListings(uid)`.

---

## 3. CRUD notifiers

Create/update/delete must go through the repository and then invalidate the relevant providers so the UI updates in real time.

**Option A – Notifier class**

- `ListingCrudNotifier` (or `ListingFormNotifier`): holds reference to `ListingRepository` and `Ref`. Methods: `create(Listing)`, `update(Listing)`, `delete(String id)`. After each success: call `ref.invalidate(listingsStreamProvider)`, `ref.invalidate(myListingsProvider)`, and if applicable `ref.invalidate(listingDetailProvider(id))` so the next read fetches fresh data.
- Expose as `listingCrudProvider` = `StateNotifierProvider<ListingCrudNotifier, ...>` (state can be unit or a status enum for “idle / loading / success / error”).

**Option B – Simple async methods in a provider**

- `createListingProvider`: returns a method `Future<void> Function(Listing)` that calls `repository.createListing`, then `ref.invalidate(...)` on the stream and my-listings providers.
- Same for update and delete.

Use whichever fits your style; the important part is: **no Firestore calls in widgets**—only calls to these notifiers/providers.

---

## 4. Loading and error handling

- All list and detail providers should expose `AsyncValue<T>` (loading / data / error). In the UI: use `.when()` or `.whenData()` to show loading indicator, list/detail content, or error message.
- For create/update/delete: capture exceptions (e.g. permission denied, network). Show SnackBar or inline error; do not leave the app in a broken state. Invalidate providers after success so streams refetch.

---

## 5. Ownership checks (edit/delete)

- Only the creator can update or delete a listing. Enforce in Firestore rules; in the UI, before calling update/delete, check `listing.createdBy == currentUser?.uid` and hide or disable edit/delete for others.
- Get `currentUser` from your auth provider (e.g. `ref.watch(currentUserProvider)` or `authStateProvider`).

---

## 6. Verification checklist

- [ ] No widget contains `FirebaseFirestore` or `ListingRepository` direct calls; all access via Riverpod providers.
- [ ] `listingsStreamProvider` and `filteredListingsProvider` (or equivalent) feed the Directory screen (Stage 5).
- [ ] `myListingsProvider` feeds the My Listings screen.
- [ ] `listingDetailProvider(id)` feeds the detail screen.
- [ ] Create listing: form submits → notifier/create provider → repository.createListing → invalidate stream and my-listings → UI updates.
- [ ] Update/delete: same pattern; only allowed when `listing.createdBy == currentUser.uid`.
- [ ] Loading and error states are visible in the UI (e.g. circular progress, error SnackBar).

---

## 7. Next stage

Proceed to [05_STAGE_5_DIRECTORY_AND_NAVIGATION.md](05_STAGE_5_DIRECTORY_AND_NAVIGATION.md) to build the bottom navigation, Directory screen (with search and category filter), and My Listings screen.

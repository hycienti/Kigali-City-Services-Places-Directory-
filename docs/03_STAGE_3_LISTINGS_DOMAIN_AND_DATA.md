# Stage 3: Listings Domain and Data Layer

This stage implements the Listing entity, the `ListingRepository` interface, and the Firestore-based implementation with real-time streams. No UI logic or Riverpod in this stage—only domain and data layers.

---

## 1. Domain Layer

### 1.1 Listing entity

**File:** `lib/features/listings/domain/entities/listing.dart`

Plain Dart class; no Flutter or Firebase imports. All assignment-required fields:

| Field | Type | Description |
|-------|------|-------------|
| id | String | Document ID (set when loading from Firestore) |
| name | String | Place or service name |
| category | String | One of the categories below |
| address | String | Full address |
| contactNumber | String | Phone or contact |
| description | String | Free text |
| latitude | double | Geographic latitude |
| longitude | double | Geographic longitude |
| createdBy | String | Firebase Auth UID of creator |
| timestamp | DateTime | Create/update time (convert from Firestore Timestamp in data layer) |

**Category values** (use an enum in code, store as string in Firestore): e.g. Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction, Utility Office, Other. Define in the same file or in `lib/core/constants/` and use `listing.category` when writing to Firestore as the enum’s string value.

Include `copyWith` for updates and equality so that listing updates can be compared.

### 1.2 Listing repository interface

**File:** `lib/features/listings/domain/repositories/listing_repository.dart`

Abstract class or abstract interface. No Firestore or Flutter types in method signatures—only domain types (`Listing`, `Stream`, `Future`).

Methods:

- `Stream<List<Listing>> streamListings()` – all listings, real-time.
- `Stream<List<Listing>> streamListingsByCategory(String category)` – filtered by category (optional; can be implemented by filtering `streamListings()` in the provider if preferred).
- `Stream<List<Listing>> streamListingsByQuery(String nameQuery)` – filter by name (contains/prefix); optional to implement in repository or in provider from `streamListings()`.
- `Stream<List<Listing>> streamMyListings(String uid)` – listings where `createdBy == uid`.
- `Future<Listing?> getListing(String id)` – single listing by id (for detail page).
- `Future<void> createListing(Listing listing)` – add new listing; set `createdBy` to current user; generate id or let Firestore generate.
- `Future<void> updateListing(Listing listing)` – update existing; enforce in data layer that `resource.data.createdBy == request.auth.uid`.
- `Future<void> deleteListing(String id)` – delete; enforce same ownership.

All methods that write should throw on failure (e.g. permission denied, network error); map Firestore exceptions in the implementation to domain exceptions if you have a `core/errors` layer.

---

## 2. Data Layer

### 2.1 Firestore collection structure

- **Collection:** `listings`
- **Document ID:** Auto-generated (or custom; must be unique)
- **Fields:** name (string), category (string), address (string), contactNumber (string), description (string), latitude (number), longitude (number), createdBy (string), timestamp (Firestore Timestamp)

Store `timestamp` as `FieldValue.serverTimestamp()` on create/update, or set client-side `Timestamp.fromDate(DateTime.now())`. When reading, map to `DateTime` in the entity.

### 2.2 Listings Firestore service (optional but recommended)

**File:** `lib/features/listings/data/datasources/listings_firestore_service.dart`

Encapsulates all Firestore calls for listings:

- `Stream<QuerySnapshot> streamListings()` – `listings` collection, order by `timestamp` descending (or another order). Use `snapshots()` for real-time.
- `Stream<QuerySnapshot> streamListingsByCategory(String category)` – `where('category', isEqualTo: category)`.
- `Stream<QuerySnapshot> streamListingsByQuery(String nameQuery)` – if you do server-side search: `where('name', isGreaterThanOrEqualTo: nameQuery).where('name', isLessThanOrEqualTo: nameQuery + '\uf8ff')` (for prefix), or filter in memory from `streamListings()` in repository.
- `Stream<QuerySnapshot> streamMyListings(String uid)` – `where('createdBy', isEqualTo: uid)`.
- `Future<DocumentSnapshot?> getListing(String id)` – `listings.doc(id).get()`.
- `Future<void> createListing(Map<String, dynamic> data)` – `listings.add(data)` or `doc().set(data)`; include all fields + `createdBy` from Auth, `timestamp`.
- `Future<void> updateListing(String id, Map<String, dynamic> data)` – `listings.doc(id).update(data)` (or set with merge).
- `Future<void> deleteListing(String id)` – `listings.doc(id).delete()`.

Map Firestore `DocumentSnapshot` / `QuerySnapshot` to `Listing` (and entity to Map) in the repository, not in the service, so the service stays “raw” Firestore and the repository owns the domain mapping.

### 2.3 Firestore listing repository implementation

**File:** `lib/features/listings/data/repositories/firestore_listing_repository.dart`

- Implements `ListingRepository`.
- Depends on `ListingsFirestoreService` (or equivalent) and optionally `FirebaseAuth` to get `currentUser.uid` for create.
- For each stream method: call the service’s stream, map each snapshot to `List<Listing>` (parse documents and convert Timestamp → DateTime, map `id` from document id).
- `getListing(id)`: get document, map to `Listing?`.
- `createListing`: build map from entity (including `createdBy` from current user), call service create. If Firestore generates id, either return the new id or have the service return it and update the entity in the caller if needed.
- `updateListing` / `deleteListing`: call service; ensure only allowed for owner (enforced by Firestore rules; app can also check `listing.createdBy == currentUser.uid` before calling).

Mapping helper (in repository or a separate mapper file in data):

- `Listing fromFirestore(DocumentSnapshot doc)` – doc.id, doc.get('name'), ..., Timestamp → DateTime.
- `Map<String, dynamic> toFirestore(Listing listing)` – for create/update; use `timestamp` as Timestamp.

---

## 3. Firestore Indexes

Create composite indexes when the console prompts you (or proactively):

- Collection `listings`, fields: `category` (Ascending), `timestamp` (Descending) – for category stream.
- Collection `listings`, fields: `createdBy` (Ascending), `timestamp` (Descending) – for “my listings” stream.

---

## 4. Firestore Security Rules (listings)

```text
match /listings/{listingId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.resource.data.createdBy == request.auth.uid;
  allow update, delete: if request.auth != null && resource.data.createdBy == request.auth.uid;
}
```

Combine with your existing `users` rules in the same `match /databases/{database}/documents { ... }` block.

---

## 5. Verification Checklist

- [ ] `Listing` entity has all required fields; category is consistent (enum → string).
- [ ] `ListingRepository` interface has no Firestore/types from Firebase in its API.
- [ ] `FirestoreListingRepository` implements all methods; streams emit domain `Listing` objects; create/update/delete use Firestore and map exceptions appropriately.
- [ ] Firestore `listings` collection has the correct field names and types; timestamp stored as Timestamp.
- [ ] Security rules allow read for all authenticated users; create only with `createdBy == request.auth.uid`; update/delete only for owner.
- [ ] No UI or Riverpod in this stage—only domain and data layers. Repository can be tested or used in Stage 4.

---

## 6. Next Stage

Proceed to [04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md](04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md) to wire listings to Riverpod providers and implement CRUD from the UI.

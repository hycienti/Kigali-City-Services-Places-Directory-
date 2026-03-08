# Design Summary

**Purpose:** 1–2 pages explaining Firestore database structure, how listings were modelled, how state management was implemented, and any design trade-offs or technical challenges. Fill this in by the end of Stage 7.

---

## 1. Firestore database structure

### 1.1 Collections and documents

| Collection | Document ID | Purpose |
|------------|-------------|---------|
| `users` | Firebase Auth UID | One document per user; stores profile (email, displayName, emailVerified, createdAt). |
| `listings` | Auto-generated or custom ID | One document per place/service listing; see listing model below. |

*(Add any subcollections or additional collections if you used them.)*

### 1.2 Rationale

- **users:** Single document per user for simple profile reads and updates; no need for subcollections for this assignment.
- **listings:** Flat collection for simple queries (all listings, by category, by createdBy); indexes as needed for category and createdBy.

---

## 2. Listing model

### 2.1 Domain entity (in code)

*(Briefly list the Listing entity fields and types, e.g. id, name, category, address, contactNumber, description, latitude, longitude, createdBy, timestamp.)*

- **Category:** Stored as string in Firestore; enum (or sealed type) in Dart. Values: …

### 2.2 Firestore document shape

*(List field names and types as stored: name string, category string, …, timestamp Timestamp.)*

- **Mapping:** Firestore Timestamp ↔ DateTime in repository; document id ↔ Listing.id.

---

## 3. State management (Riverpod)

### 3.1 How Firestore is exposed to the UI

- **Rule:** No direct Firestore (or Auth) calls in widgets. All access through repository interfaces and Riverpod providers.
- **Streams:** Listing data is exposed via `StreamProvider` (e.g. `listingsStreamProvider`, `myListingsProvider`) that listen to repository streams. UI uses `ref.watch(...)` and handles `AsyncValue` (loading, data, error).
- **Mutations:** Create/update/delete go through notifiers (or async providers) that call the repository and then invalidate the relevant stream/detail providers so the UI updates in real time.

### 3.2 Key providers

| Provider | Role |
|----------|------|
| *(e.g. listingsStreamProvider)* | *(e.g. All listings stream for Directory and Map.)* |
| *(e.g. filteredListingsProvider)* | *(e.g. Listings filtered by category and search query.)* |
| *(e.g. myListingsProvider)* | *(e.g. Listings created by current user.)* |
| *(e.g. listingDetailProvider(id))* | *(e.g. Single listing for detail page.)* |
| *(e.g. listingCrudNotifier / create/update/delete)* | *(e.g. Mutations and provider invalidation.)* |

*(Adjust names to match your actual implementation.)*

---

## 4. Design trade-offs and technical challenges

### 4.1 Trade-offs

- **Filtering:** Filtering by category and search in memory (from full stream) vs. separate Firestore queries. *(Which did you choose and why?)*
- **Map:** Using flutter_map + OSM + Overpass instead of Google Maps. *(Benefits: no API key, OSM POIs; trade-off: different UX or rate limits.)*
- **Email verification:** Redirect vs. manual “I’ve verified” button. *(What you chose and why.)*

### 4.2 Technical challenges

- *(e.g. Overpass rate limits or query design; map viewport and debouncing; Firestore security rules for update/delete; router redirect with async auth state.)*

---

## 5. Diagram (optional)

*(Optional: add a simple diagram of data flow, e.g. UI → Riverpod → Repository → Firestore/Auth.)*

---

*Replace all placeholder text above with your actual design summary before submission.*

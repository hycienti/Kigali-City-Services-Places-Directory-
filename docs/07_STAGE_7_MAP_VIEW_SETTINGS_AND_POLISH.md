# Stage 7: Map View, Settings, and Final Documents

This stage implements the full Map View screen (flutter_map with Firestore listings and Overpass OSM POIs), the Settings screen (profile and notification toggle), and the final deliverables: README, Implementation Reflection, and Design Summary.

---

## 1. Map View screen

**File:** `lib/features/listings/presentation/screens/map_view_screen.dart`

### 1.1 Requirements

- Full-screen map using **flutter_map** and OpenStreetMap tiles (same setup as detail page: User-Agent, TileLayer, latlong2).
- Two marker layers:
  1. **User-generated listings** from Firestore: use `listingsStreamProvider` or `filteredListingsProvider` (so category/search filter from Directory can apply if you share that state). Each listing is a marker at its lat/lng; tap → show bottom sheet with name/category and “View detail” (navigate to listing detail) or open detail directly.
  2. **OSM POIs** from Overpass API: query by current map viewport (bounds) and optionally by category (e.g. amenity=cafe, hospital, etc.) so the map is not limited to user-only data. Use `flutter_overpass` or `osm_overpass` (or raw HTTP to Overpass). Display as a second marker layer; tap → bottom sheet with OSM node name/tags (no “View detail” for Firestore; optional link to OSM or directions).

### 1.2 Implementation notes

- **Viewport:** When the map moves or zooms, get current bounds from flutter_map (if the API exposes it), then call Overpass with a query like `node(around:radius,lat,lng)` or a bbox query for the visible area. Debounce (e.g. 500 ms) to avoid too many requests. Cache or limit results (e.g. top 50) for performance.
- **Overpass query example (Kigali area, cafes):**  
  `[out:json]; node["amenity"="cafe"](around:5000,-1.9536,30.0606); out body;`  
  Adjust radius and center to the current map center; repeat for other categories or a generic “amenity” query.
- **Marker differentiation:** Use different pin colors or icons for “your listings” vs “OSM” so users can tell them apart.
- **Initial position:** Center on a default (e.g. Kigali city center) or on device location (geolocator); then load Firestore listings and Overpass POIs for that area.

### 1.3 State

- Listings: already in `listingsStreamProvider` / `filteredListingsProvider`; read in the map screen and build MarkerLayer.
- OSM POIs: add a provider (e.g. `overpassPoisProvider`) that takes center lat/lng and radius (or bounds) and returns a list of simple POI objects (id, lat, lng, name, tags). The map screen watches this provider and builds a second MarkerLayer. Invalidate or refetch when the map center/bounds change (with debounce).

---

## 2. Settings screen

**File:** `lib/features/settings/presentation/screens/settings_screen.dart`

### 2.1 Content

- **User profile:** Display name, email (from Firestore `users/{uid}` or Firebase Auth). Use `userProfileProvider(uid)` or auth provider. Optionally allow editing display name (update Firestore and show success).
- **Location-based notifications toggle:** A switch for “Enable location-based notifications.” Persist the value locally only (simulation): e.g. `shared_preferences` or `flutter_secure_storage`. Key such as `location_notifications_enabled`. On toggle, write the boolean and show a SnackBar (“Preference saved” or “Notifications simulation enabled/disabled”).
- **Log out:** Button that calls `authRepository.signOut()` and lets the router redirect to login.

### 2.2 Providers

- **Notification preference:** e.g. `notificationPreferenceProvider` – reads/writes the boolean from/to SharedPreferences; use a StateNotifier or FutureProvider + mutation so the switch reflects current value and updates it on toggle.

---

## 3. Polish

- Run `flutter analyze` and fix lints.
- Ensure email verification gate and auth redirects work; “created by” checks for edit/delete are consistent.
- Test on Android and iOS (or at least one device/emulator) for map, directions, and auth flows.
- Optionally: add a simple “About” or app version on Settings.

---

## 4. README (project root)

**File:** `README.md` at project root. Make it comprehensive so a new developer can run and understand the project.

Suggested sections:

1. **Project title and short description** – Kigali City Services & Places Directory; helps residents find and navigate to services and places.
2. **Features** – Bullet list: auth (sign up, login, logout, email verification), listing CRUD, directory with search and category filter, detail page with map and directions, map view with user + OSM POIs, settings with profile and notification toggle.
3. **Architecture** – Short summary: clean architecture (domain/data/presentation), Riverpod, Firebase Auth + Firestore, flutter_map + OSM + Overpass. Link to [docs/00_ARCHITECTURE_AND_OVERVIEW.md](00_ARCHITECTURE_AND_OVERVIEW.md).
4. **Folder structure** – High-level `lib/` layout (core, features with auth/listings/settings).
5. **Prerequisites** – Flutter SDK version (e.g. from pubspec), Firebase project, FlutterFire CLI.
6. **Setup** – Steps: clone, `flutter pub get`, `flutterfire configure` (and create Firebase project, enable Auth and Firestore), run on device/emulator. Mention that `firebase_options.dart` is generated.
7. **Running the app** – `flutter run`; optional: how to run tests.
8. **Firestore** – Short note: collections `users` and `listings`; link to architecture doc for schema and rules.
9. **State management and navigation** – Riverpod for state; go_router for routes; bottom nav (Directory, My Listings, Map View, Settings).
10. **Maps** – flutter_map + OpenStreetMap; Overpass for OSM POIs; url_launcher for directions (no Google Maps API key for in-app map).
11. **Screenshots** – Placeholder: “Add screenshots of main screens here.”
12. **License** – As appropriate (e.g. MIT or course policy).

---

## 5. Implementation Reflection

**File:** `docs/IMPLEMENTATION_REFLECTION.md`

Write a short reflection (1–2 pages) covering:

- Experience integrating Firebase (Auth and Firestore) with Flutter.
- Challenges encountered (e.g. email verification flow, Firestore rules, real-time listeners, platform setup).
- Screenshots of relevant error messages and how you resolved them (e.g. build errors, auth errors, permission denied in Firestore).

Use the template in [IMPLEMENTATION_REFLECTION.md](IMPLEMENTATION_REFLECTION.md) and fill it in as you implement or after Stage 7.

---

## 6. Design Summary

**File:** `docs/DESIGN_SUMMARY.md`

Write 1–2 pages covering:

- **Firestore structure** – How you structured the database (collections, documents, fields); why (e.g. one document per user, one per listing).
- **Listing model** – How listings are modelled in domain vs Firestore (field names, types, category enum).
- **State management** – How Riverpod is used (stream vs future providers, notifiers, invalidation); how the UI stays in sync with Firestore.
- **Design trade-offs and technical challenges** – e.g. filtering in memory vs Firestore queries; Overpass rate limits; map performance; email verification UX.

Use the template in [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md) and fill it in by the end of Stage 7.

---

## 7. Verification checklist

- [ ] Map View shows Firestore listings and OSM POIs as two marker layers; tap listing → detail; tap OSM → bottom sheet (or similar).
- [ ] Settings shows profile (email, display name) and notification toggle; toggle state persisted locally; log out works.
- [ ] README is complete and someone can follow it to run the app.
- [ ] Implementation Reflection and Design Summary are written and saved in `docs/`.
- [ ] No linter errors; app runs on at least one platform.

---

## 8. End of implementation

After Stage 7, all assignment requirements are covered: auth, listing CRUD, directory search/filter, detail page with map and directions, state management, bottom nav (Directory, My Listings, Map View, Settings), and Settings with profile and notification toggle, plus README, Implementation Reflection, and Design Summary.

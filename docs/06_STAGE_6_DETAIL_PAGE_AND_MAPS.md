# Stage 6: Detail Page and Map Integration

This stage implements the listing detail screen with all listing fields, an embedded open-source map (flutter_map + OpenStreetMap) with one marker, and a “Get directions” button that opens Google Maps or OpenStreetMap via url_launcher. No Google Maps API key is required for the in-app map.

---

## 1. Detail screen layout

**File:** `lib/features/listings/presentation/screens/listing_detail_screen.dart`

- **AppBar:** Title = listing name (or “Listing detail”); back button; if current user is owner, optional “Edit” action that navigates to edit form.
- **Body (scrollable):**
  - **Map block:** Fixed height (e.g. 200–250 px) containing a flutter_map with one marker at listing lat/lng. Center the map on the marker; zoom level appropriate for a single place (e.g. 15–16).
  - **Details:** Name, category, address, contact number, description, coordinates (lat/lng as text), “Created by” (optional; can show “You” if owner).
  - **Button:** “Get directions” – opens external app/browser for turn-by-turn (see section 3).

Data: use `ref.watch(listingDetailProvider(listingId))`; handle loading and error; if listing is null (e.g. deleted), show message and pop or redirect.

---

## 2. Embedded map (flutter_map + OSM)

### 2.1 Dependencies

Already added in Stage 1: `flutter_map`, `latlong2`. Do not use `google_maps_flutter` for this map.

### 2.2 User-Agent for OSM tiles

OpenStreetMap tile usage policy requires a valid User-Agent. Set it when building the tile URL or use a tile provider that allows custom headers. Example: use `TileLayer` with a custom `urlTemplate` and pass headers (if the package supports it) or use a well-known OSM tile URL that allows app identification. Check flutter_map docs for the current way to set headers (e.g. `TileLayer` may have `additionalOptions` or you may need to use a custom tile provider). Example URL template: `https://tile.openstreetmap.org/{z}/{x}/{y}.png` with User-Agent set in HTTP client if required by the package.

Use a constant from `lib/core/constants/app_constants.dart` (e.g. `AppConstants.osmUserAgent`) so it can be changed in one place.

### 2.3 Map widget structure

- **Package:** `flutter_map`
- **Widget:** `FlutterMap` with:
  - **options:** `MapOptions` with `initialCenter: LatLng(listing.latitude, listing.longitude)`, `initialZoom: 15` (or 16), `interactionOptions: InteractionOptions()` as needed.
  - **children:**
    - **TileLayer:** OpenStreetMap tiles. Example:
      ```dart
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.kigali_city_services', // or set userAgent if supported
      )
      ```
      If flutter_map does not expose User-Agent on TileLayer, check for `HttpHeaders` or a custom `TileProvider` that sets the User-Agent to avoid being blocked by OSM.
    - **MarkerLayer:** One `Marker` at `LatLng(listing.latitude, listing.longitude)` with a suitable icon (e.g. pin or place icon).

Use `latlong2` for `LatLng` (e.g. `LatLng(listing.latitude, listing.longitude)`).

### 2.4 Map size

Wrap `FlutterMap` in a `SizedBox` or `AspectRatio` so the map has a fixed height (e.g. 200–250) and does not expand infinitely. The rest of the detail content can be below in the same scroll view.

---

## 3. “Get directions” button

Use the `url_launcher` package to open an external URL. No in-app API key needed.

**Option A – Google Maps (opens in app or browser):**

```dart
final uri = Uri.parse(
  'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}'
);
if (await canLaunchUrl(uri)) {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

**Option B – OpenStreetMap (open-source):**

```dart
final uri = Uri.parse(
  'https://www.openstreetmap.org/directions?to=${listing.latitude}%2C${listing.longitude}'
);
if (await canLaunchUrl(uri)) {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

You can offer one button that uses one of these, or two buttons (“Open in Google Maps” / “Open in OSM”). Handle `canLaunchUrl` returning false (e.g. show SnackBar “Could not open maps”).

---

## 4. Edit / delete on detail screen

If the current user is the owner (`listing.createdBy == currentUser.uid`):

- Show “Edit” in the AppBar → navigate to listing form (edit mode) with this listing’s id.
- Show “Delete” button (e.g. in the body or as an action) → confirm dialog → call delete notifier → invalidate `listingDetailProvider` and list providers → pop back to previous screen.

---

## 5. Verification checklist

- [ ] Detail screen shows all listing fields and a map with one marker at listing coordinates.
- [ ] Map uses flutter_map and OpenStreetMap tiles (no Google Maps API key).
- [ ] OSM tile requests use a valid User-Agent (configured in app or via package options).
- [ ] “Get directions” opens Google Maps or OSM URL and works on device/emulator.
- [ ] Edit/delete only visible and allowed for owner; after delete, user is taken back and list updates.

---

## 6. Next stage

Proceed to [07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md](07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md) to implement the full Map View (Firestore + Overpass POIs), Settings screen, README, Implementation Reflection, and Design Summary.

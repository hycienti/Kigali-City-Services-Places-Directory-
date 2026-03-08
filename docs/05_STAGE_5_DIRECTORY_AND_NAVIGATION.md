# Stage 5: Directory and Navigation

This stage implements the main navigation shell with a BottomNavigationBar (Directory, My Listings, Map View, Settings), the Directory screen with search and category filter, and the My Listings screen with add/edit/delete. List and detail UI use only Riverpod providers from Stage 4.

---

## 1. Navigation shell

### 1.1 Bottom navigation (4 items)

- **Directory** – Browse all listings (search + category filter).
- **My Listings** – Listings created by the current user; FAB or button to add; tap to view/edit/delete.
- **Map View** – Full-screen map (implemented in Stage 7; placeholder or simple map in this stage if desired).
- **Settings** – User profile and notification toggle (profile in this stage; full Settings in Stage 7).

Use a single `Scaffold` with `BottomNavigationBar` and a body that switches by selected index (e.g. `IndexedStack` or conditional child). Selected index can be held in:

- A `StateProvider<int>` (e.g. `bottomNavIndexProvider`), or
- Part of the router state (e.g. path `/directory`, `/my-listings`, `/map`, `/settings`).

Recommended: one shell route (e.g. `/` or `/home`) that shows the scaffold and switches body by index; keep the 4 tab routes as logical names for deep linking if needed.

### 1.2 Router integration

- Authenticated and verified users land on the shell with default index 0 (Directory).
- Unauthenticated or unverified users are redirected per [02_STAGE_2_AUTHENTICATION.md](02_STAGE_2_AUTHENTICATION.md). Ensure the shell is only reachable when the user is logged in and verified.

---

## 2. Directory screen

**File:** `lib/features/listings/presentation/screens/directory_screen.dart`

### 2.1 Layout

- **AppBar:** Title “Kigali City” or “Directory”; optional back button only if you push this screen on top of something else (otherwise no back).
- **Body:**
  - **Category chips:** Horizontal scrollable row of chips (or choice chips) for each listing category (from your category enum). One chip for “All” (clear category filter). Tapping a chip updates the filter state (e.g. `listingsFilterProvider` or `selectedCategoryProvider`).
  - **Search bar:** Text field; on change or on submit, update search query in filter state (e.g. `searchQueryProvider`). Debouncing (e.g. 300 ms) is optional but improves UX.
  - **List:** ListView (or ListView.builder for performance) of listing cards. Data source: `filteredListingsProvider` (from Stage 4). Use `ref.watch(filteredListingsProvider)` and handle `AsyncValue`: loading → progress indicator; error → error message + retry; data → list of cards.

### 2.2 Listing card (widget)

- **File:** e.g. `lib/features/listings/presentation/widgets/listing_card.dart`
- **Content:** Name, category, optional distance (if you have device location and compute distance; otherwise omit or show “—”), optional rating placeholder for future. Tap → navigate to listing detail screen with `listing.id` (e.g. `/listing/:id` or push `ListingDetailScreen(listingId: id)`).

### 2.3 Filter behavior

- Category and search query are applied together: filtered list = listings where category matches (if selected) and name contains query (if non-empty). Filtering can be done in `filteredListingsProvider` (in memory from full stream) or via repository streams; see [04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md](04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md).
- When Firestore data changes, the stream emits and the list updates automatically (real-time).

---

## 3. My Listings screen

**File:** `lib/features/listings/presentation/screens/my_listings_screen.dart`

- **AppBar:** Title “My Listings”.
- **Body:** List from `myListingsProvider` (same AsyncValue handling: loading, error, data). Each item: listing card with edit/delete actions (icon buttons or long-press menu). Only the owner sees edit/delete (you already enforce in repository; hide buttons if `listing.createdBy != currentUser.uid`).
- **FAB or prominent button:** “Add listing” → navigate to listing form screen (create mode). Form screen: all fields (name, category, address, contact, description, lat, lng); lat/lng can be from a map picker (Stage 6/7) or two number fields for now. On submit → call create notifier → then pop and invalidate providers so the list refreshes.

### 3.1 Listing form screen (create / edit)

**File:** `lib/features/listings/presentation/screens/listing_form_screen.dart`

- **Create mode:** All fields empty; submit → `createListing(listing)` with `createdBy = currentUser.uid`, timestamp set in repository.
- **Edit mode:** Prefilled with existing listing; submit → `updateListing(listing)`. Only show for listings where `listing.createdBy == currentUser.uid`.
- Validation: required fields non-empty; lat/lng valid numbers. Show validation errors inline or via SnackBar.

---

## 4. Map View and Settings placeholders

- **Map View tab:** For Stage 5, a simple placeholder (e.g. “Map View – coming in Stage 7”) or a minimal flutter_map with no markers is enough. Full implementation in [07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md](07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md).
- **Settings tab:** Show a simple “Settings” title and placeholder for “Profile” and “Notifications” (Stage 7). Optionally show current user email from auth provider.

---

## 5. Navigation routes summary

Ensure these routes exist and are reachable:

- `/login`, `/sign-up`, `/verify-email` (Stage 2).
- `/` or `/home` (shell with bottom nav; default tab = Directory).
- `/listing/:id` (or equivalent) → Listing detail screen (Stage 6).
- `/listing/new` → Create form; `/listing/edit/:id` → Edit form (or pass id via argument).

Use `GoRouter`’s `go`, `push`, and `context.go`/`context.push` from the shell and from listing cards/form.

---

## 6. Verification checklist

- [ ] Bottom nav has exactly 4 items: Directory, My Listings, Map View, Settings.
- [ ] Directory screen shows category chips and search bar; list shows filtered results from `filteredListingsProvider`; tap card → detail screen (can be placeholder until Stage 6).
- [ ] My Listings screen shows only current user’s listings; FAB/button opens create form; submit creates listing and list updates; edit/delete only for owner.
- [ ] No direct Firestore or repository calls in any widget; all data from providers.
- [ ] Authenticated and verified user lands on shell; unauthenticated/unverified redirected to login or verify-email.

---

## 7. Next stage

Proceed to [06_STAGE_6_DETAIL_PAGE_AND_MAPS.md](06_STAGE_6_DETAIL_PAGE_AND_MAPS.md) to implement the listing detail page with embedded flutter_map and “Get directions” button.

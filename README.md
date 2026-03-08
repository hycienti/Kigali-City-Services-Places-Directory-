# Kigali City Services – Documentation Index

Start here for implementation. Read in order when building the app.

| Document | Description |
|----------|-------------|
| [00_ARCHITECTURE_AND_OVERVIEW.md](00_ARCHITECTURE_AND_OVERVIEW.md) | Clean architecture, folder structure, tech stack (Firebase, Riverpod, flutter_map + OSM + Overpass), Firestore schema, navigation map. |
| [01_STAGE_1_PROJECT_SETUP.md](01_STAGE_1_PROJECT_SETUP.md) | Dependencies, Firebase setup, folder scaffolding, theme, router shell, main.dart bootstrap. |
| [02_STAGE_2_AUTHENTICATION.md](02_STAGE_2_AUTHENTICATION.md) | Sign up, login, logout, email verification, Firestore user profile, auth providers and routing. |
| [03_STAGE_3_LISTINGS_DOMAIN_AND_DATA.md](03_STAGE_3_LISTINGS_DOMAIN_AND_DATA.md) | Listing entity, ListingRepository interface, Firestore collection and repository implementation. |
| [04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md](04_STAGE_4_STATE_MANAGEMENT_AND_CRUD.md) | Riverpod providers (streams, filters, detail, my listings), CRUD notifiers, invalidation. |
| [05_STAGE_5_DIRECTORY_AND_NAVIGATION.md](05_STAGE_5_DIRECTORY_AND_NAVIGATION.md) | Bottom nav shell, Directory screen (search + category filter), My Listings screen, listing form. |
| [06_STAGE_6_DETAIL_PAGE_AND_MAPS.md](06_STAGE_6_DETAIL_PAGE_AND_MAPS.md) | Listing detail screen, embedded flutter_map (OSM), “Get directions” (url_launcher). |
| [07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md](07_STAGE_7_MAP_VIEW_SETTINGS_AND_POLISH.md) | Map View (Firestore + Overpass POIs), Settings (profile + notification toggle), README, Implementation Reflection, Design Summary. |
| [IMPLEMENTATION_REFLECTION.md](IMPLEMENTATION_REFLECTION.md) | Template: Firebase integration experience, challenges, error screenshots and resolutions. |
| [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md) | Template: Firestore structure, listing model, state management, trade-offs (1–2 pages). |

**Implementation order:** Stage 1 → 2 → 3 → 4 → 5 → 6 → 7. Fill in Implementation Reflection and Design Summary during or after Stage 7.

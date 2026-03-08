# Stage 1: Project Setup and Foundation

This stage sets up dependencies, Firebase, folder structure, theme, routing shell, and fixes the default `main.dart`. No auth or Firestore logic yet.

---

## 1. Dependencies (pubspec.yaml)

Add the following under `dependencies:` (keep existing `flutter` and `cupertino_icons`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0

  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Routing
  go_router: ^14.6.2

  # Map (open-source: no API key for tiles)
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_overpass: ^0.0.3   # or osm_overpass – Overpass API for OSM POIs

  # Location & directions
  geolocator: ^13.0.2
  url_launcher: ^6.3.1

  # Local preferences (notification toggle simulation)
  shared_preferences: ^2.3.3
```

Add under `dev_dependencies:` (keep `flutter_test` and `flutter_lints`):

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  riverpod_generator: ^2.6.2
  build_runner: ^2.4.13
```

Do **not** add `google_maps_flutter`; the in-app map uses `flutter_map` + OpenStreetMap.

Run:

```bash
flutter pub get
```

---

## 2. Firebase Setup

1. **Create a Firebase project** (if needed) at [Firebase Console](https://console.firebase.google.com).
2. **Enable Authentication** – Email/Password provider.
3. **Create a Firestore database** – Start in test mode for development; you will replace with security rules in Stage 2/3.
4. **Install FlutterFire CLI** and configure:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This creates/updates `lib/firebase_options.dart` and adds the required config to `android/` and `ios/`.
5. Ensure **Android**: `android/app/build.gradle.kts` applies `com.google.gms.google-services` and has `minSdkVersion` at least 21 (or as required by Firebase).
6. Ensure **iOS**: CocoaPods installed; run `pod install` in `ios/` if needed after adding Firebase.

No auth or Firestore code in this stage—only initialization in `main.dart`.

---

## 3. Folder Scaffolding

Create the following directories (empty for now; add files in later stages):

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── router/
│   ├── errors/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── domain/entities/
│   │   ├── domain/repositories/
│   │   ├── data/repositories/
│   │   ├── data/datasources/
│   │   └── presentation/providers/
│   │   └── presentation/screens/
│   ├── listings/
│   │   ├── domain/entities/
│   │   ├── domain/repositories/
│   │   ├── data/repositories/
│   │   ├── data/datasources/
│   │   └── presentation/providers/
│   │   └── presentation/screens/
│   │   └── presentation/widgets/
│   └── settings/
│       └── presentation/providers/
│       └── presentation/screens/
```

You can add `.gitkeep` in empty folders or create placeholder files; the exact files are created in Stages 2–7.

---

## 4. Core Files (Minimal Shell)

### 4.1 lib/core/constants/app_constants.dart

Create a simple constants file (e.g. for OSM User-Agent used in Stage 6/7):

```dart
class AppConstants {
  AppConstants._();
  static const String osmUserAgent = 'KigaliCityServices/1.0';
}
```

### 4.2 lib/core/theme/app_theme.dart

Define a theme that matches the sample UI (dark blue app bar, accent color):

```dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color primaryDark = Color(0xFF1A237E);   // dark blue
  static const Color accent = Color(0xFFFFB300);       // amber/yellow

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: primaryDark,
      secondary: accent,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryDark,
      selectedItemColor: accent,
      unselectedItemColor: Colors.white70,
    ),
  );
}
```

### 4.3 lib/core/router/app_router.dart

Minimal router that shows a placeholder; you will add auth redirect and bottom-nav shell in Stage 2 and 5:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Kigali City Services – Placeholder')),
        ),
      ),
    ],
  );
}
```

### 4.4 lib/app.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kigali City Services',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
```

---

## 5. main.dart – Bootstrap and Fix

Replace the contents of `lib/main.dart` with:

- `WidgetsFlutterBinding.ensureInitialized()`
- `Firebase.initializeApp()` using default options (from `firebase_options.dart` generated by `flutterfire configure`)
- `runApp(ProviderScope(child: App()))`

Fix any existing typos in the current file (e.g. `ColorScheme.fromSeed` and `MainAxisAlignment.center` are no longer needed because the counter UI is removed).

Example:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: App()));
}
```

Ensure `firebase_options.dart` exists after `flutterfire configure` (it is generated and should not be edited manually for keys).

---

## 6. Verification Checklist

- [ ] `flutter pub get` succeeds.
- [ ] `flutterfire configure` has been run; `lib/firebase_options.dart` exists.
- [ ] App runs with `flutter run` and shows the placeholder screen (“Kigali City Services – Placeholder”) with the dark blue theme.
- [ ] No Firestore or Auth calls in the app yet—only Firebase init.
- [ ] All folders under `lib/core/` and `lib/features/` exist as per [00_ARCHITECTURE_AND_OVERVIEW.md](00_ARCHITECTURE_AND_OVERVIEW.md).

---

## 7. Next Stage

Proceed to [02_STAGE_2_AUTHENTICATION.md](02_STAGE_2_AUTHENTICATION.md) to implement sign up, login, logout, email verification, and Firestore user profile.

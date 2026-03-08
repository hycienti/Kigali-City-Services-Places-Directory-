# Stage 2: Authentication

This stage implements Firebase Authentication (email/password), email verification, Firestore user profile, and auth-gated navigation. All auth access from the UI goes through Riverpod providers and the `AuthRepository` interface.

---

## 1. Domain Layer

### 1.1 User profile entity

**File:** `lib/features/auth/domain/entities/user_profile.dart`

- Plain Dart class; no Flutter/Firebase imports.
- Fields: `uid`, `email`, `displayName`, `emailVerified`, `createdAt` (DateTime or equivalent).
- Implement equality (and `copyWith` if useful for updates).

Example shape:

```dart
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
    this.createdAt,
  });
}
```

### 1.2 Auth repository interface

**File:** `lib/features/auth/domain/repositories/auth_repository.dart`

Abstract interface (no Firebase types in signature). Methods:

- `Stream<User?> get authStateChanges` – Firebase Auth current user stream (expose as `User?` from Firebase Auth in the implementation; domain can depend on a minimal type or you keep Firebase `User` in data layer and map to `UserProfile` when needed for UI).
- `Future<User?> get currentUser` – current user or null.
- `Future<void> signUp({required String email, required String password})` – create user; throw on failure.
- `Future<void> signIn({required String email, required String password})` – sign in; throw on failure.
- `Future<void> signOut()`.
- `Future<void> sendEmailVerification()` – send verification email to current user.
- `Future<UserProfile?> getUserProfile(String uid)` – read from Firestore `users/{uid}` and return `UserProfile` (for Settings screen).

Optionally: `Future<void> createOrUpdateUserProfile(UserProfile profile)` – write to Firestore `users/{uid}` (call after first sign-up and when updating display name).

Use a minimal auth user type in domain if you want zero Firebase in domain (e.g. an `AuthUser` with `uid`, `email`, `emailVerified`); otherwise the interface can return Firebase `User` in the data implementation and you map to profile in presentation. Document the choice in [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md).

---

## 2. Data Layer

### 2.1 Firestore users collection

- Collection: `users`
- Document ID: Firebase Auth `uid`
- Fields: `email`, `displayName` (optional), `emailVerified`, `createdAt` (Timestamp).

Create the profile document on first sign-up (after `createUserWithEmailAndPassword`).

### 2.2 Firebase Auth repository implementation

**File:** `lib/features/auth/data/repositories/firebase_auth_repository.dart`

- Implements `AuthRepository`.
- Depends on Firebase Auth and a Firestore reference (for `users`).
- `signUp`: create user with Firebase Auth, then set `createdBy` and write to `users/{uid}` (email, displayName, emailVerified from Auth, createdAt = now). Send email verification after sign-up if required.
- `signIn`: `signInWithEmailAndPassword`.
- `authStateChanges`: expose `FirebaseAuth.instance.authStateChanges()`.
- `currentUser`: `FirebaseAuth.instance.currentUser`.
- `sendEmailVerification`: call on current user.
- `getUserProfile(uid)`: get `users/$uid` from Firestore and map to `UserProfile`.
- `createOrUpdateUserProfile`: set or update Firestore document.

Handle Firebase exceptions and rethrow as domain-friendly exceptions (e.g. in `core/errors/`) so the UI can show messages without depending on Firebase error codes in the presentation layer.

---

## 3. Presentation Layer

### 3.1 Auth state provider

**File:** `lib/features/auth/presentation/providers/auth_providers.dart`

- `authStateProvider`: `StreamProvider<User?>` (or your domain auth user type) that listens to `authRepository.authStateChanges`. Use the repository instance (injected via provider).
- `currentUserProvider`: reads from auth state.
- `userProfileProvider(uid)`: `FutureProvider` or `StreamProvider` that fetches `getUserProfile(uid)` (or a stream if you add one).

Inject `AuthRepository` with a provider (e.g. `authRepositoryProvider` that returns `FirebaseAuthRepository`).

### 3.2 Auth flow and routing

- **Unauthenticated** (`currentUser == null`): redirect to `/login` (or `/sign-up` as entry).
- **Authenticated but not verified** (`emailVerified == false`): redirect to `/verify-email`.
- **Authenticated and verified**: redirect to main app (e.g. `/home` or `/directory`).

Implement this in the router (e.g. `GoRouter` with `redirect` that reads `authStateProvider` and returns the appropriate path). Use `ref.listen` or a redirect callback that checks auth state.

### 3.3 Screens

**Login screen** (`lib/features/auth/presentation/screens/login_screen.dart`)

- Email and password text fields; “Log in” button; link to “Sign up”.
- On submit: call `authRepository.signIn(...)`. On success, router will redirect (to verify-email or main app). On failure: show SnackBar or error text (from caught exception).
- No direct Firebase calls—use a notifier or async callback that uses `authRepositoryProvider`.

**Sign-up screen** (`lib/features/auth/presentation/screens/sign_up_screen.dart`)

- Email, password, optional display name; “Sign up” button; link to “Log in”.
- On submit: call `authRepository.signUp(...)`, then create/update Firestore profile, then send email verification. Redirect to verify-email screen.
- Show validation (e.g. password length, email format).

**Verify email screen** (`lib/features/auth/presentation/screens/verify_email_screen.dart`)

- Message: “Please verify your email. Check your inbox and click the link.”
- “Resend verification email” button → `sendEmailVerification()`; show confirmation or error.
- When user is verified, redirect to main app (router can re-check on each build or use a short poll; or rely on user pressing “I’ve verified” and then re-reading auth state).

---

## 4. Router Update

In `lib/core/router/app_router.dart` (or equivalent):

- Add routes: `/login`, `/sign-up`, `/verify-email`, and the main app route (e.g. `/` or `/directory` with bottom nav shell).
- Implement redirect logic: read auth state (from Riverpod); if null → `/login`; if not verified → `/verify-email`; else → main app.
- Ensure `ProviderScope` is above the `MaterialApp.router` so `ref.read(authStateProvider)` is available in redirect (e.g. pass a `Ref` into the router config or use a top-level provider that the router can access).

---

## 5. Firestore Security Rules (users)

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Add `listings` rules in Stage 3; for now you can leave only `users` or add a placeholder for `listings`.

---

## 6. Verification Checklist

- [ ] User can sign up with email/password; document is created in `users/{uid}`.
- [ ] User can log in and log out.
- [ ] After sign-up, user is directed to verify-email screen; “Resend” sends the verification email.
- [ ] When `emailVerified` is true, user is directed to the main app (placeholder shell is fine until Stage 5).
- [ ] No direct Firebase Auth or Firestore calls in UI code—only through `AuthRepository` and providers.
- [ ] Firestore rules allow read/write only for `users/{request.auth.uid}`.

---

## 7. Next Stage

Proceed to [03_STAGE_3_LISTINGS_DOMAIN_AND_DATA.md](03_STAGE_3_LISTINGS_DOMAIN_AND_DATA.md) to implement the Listing entity, `ListingRepository`, and Firestore listings collection.

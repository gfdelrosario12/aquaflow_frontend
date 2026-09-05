## 1. Domain Models & Service Abstractions

- [x] 1.1 Add `flutter_secure_storage` dependency to `pubspec.yaml`.
- [x] 1.2 Implement `AuthToken` and `UserSession` domain models in `lib/features/auth/domain/models/`.
- [x] 1.3 Implement `SecureStorageService` interface and implementation in `lib/core/services/secure_storage_service.dart`.
- [x] 1.4 Implement `AuthService` interface and `MockAuthService` implementation supporting login, token refresh, and validation in `lib/features/auth/data/datasources/`.
- [x] 1.5 Implement `AuthRepository` interface and `AuthRepositoryImpl` in `lib/features/auth/data/repositories/`.

## 2. Authentication State Management & Routing

- [x] 2.1 Implement `AuthNotifier` / `AuthState` state management in `lib/features/auth/presentation/controllers/auth_controller.dart`.
- [x] 2.2 Implement protected router guard in `lib/main.dart` to switch between `LoginScreen` and `AppShell`.

## 3. UI Presentation Layer

- [x] 3.1 Implement responsive `LoginScreen` in `lib/features/auth/presentation/login_screen.dart` with input validation, password toggle, loading spinner, and error banners using AquaFlow design tokens.
- [x] 3.2 Add Logout action and active user session badge to `SettingsScreen` and App Bar header.

## 4. Verification & Testing

- [x] 4.1 Write unit tests for `AuthRepositoryImpl` verifying login, token caching, logout, and token expiration handling.
- [x] 4.2 Write widget tests verifying `LoginScreen` rendering, credential validation, error states, and session redirection.
- [x] 4.3 Run `flutter analyze` and `flutter test` to ensure clean static analysis and test execution.

## Context

The AquaFlow mobile application requires an authentication layer to secure access to telemetry monitoring and centralized physical irrigation controls.

## Goals / Non-Goals

**Goals:**
- Provide a responsive, accessible Login screen using AquaFlow design tokens (`AquaCard`, `AquaButton`, `AppColors`, `AppTypography`).
- Build an authentication domain layer (`UserSession`, `AuthToken`) and repository/service abstractions (`AuthRepository`, `AuthService`).
- Store access tokens, refresh tokens, and user session credentials securely via a secure storage service abstraction (`SecureStorageService` backed by `flutter_secure_storage`).
- Handle authentication state management (`AuthBloc` or `AuthNotifier`) with states: `Unauthenticated`, `Authenticating`, `Authenticated`, `AuthError`.
- Implement protected routing: redirect unauthenticated users to `LoginScreen`; redirect authenticated users to `AppShell`.
- Handle session expiration and 401 Unauthorized errors automatically by clearing credentials and routing to Login with an alert message.
- Support login, logout, credential validation, loading indicators, and error feedback.

**Non-Goals:**
- Real OAuth2/OIDC server deployment or physical REST backend infrastructure (mock service interface prepares for HTTPS API integration).
- Modifying zone telemetry logic (Q1–Q4 remain strictly independent telemetry monitoring zones).

## Architecture & Data Flow

```
[ LoginScreen ] / [ AppShell ]
       │
       ▼
[ AuthNotifier / AuthState ]
       │
       ▼
[ AuthRepositoryImpl ]
   ├──> [ AuthService (Mock / REST Ready) ] -> HTTPS / API
   └──> [ SecureStorageService ] ---------> Encrypted Storage
```

## Decisions

### Decision 1: Authentication State Notification & Protected Router Guard
- **Decision**: Expose `AuthNotifier` at root app level (`main.dart`), wrapping `MaterialApp` to dynamically switch between `LoginScreen` and `AppShell` based on `AuthState`.
- **Rationale**: Ensures immediate, non-bypassable view protection upon token invalidation or logout.

### Decision 2: Secure Storage Abstraction
- **Decision**: Abstract token storage behind `SecureStorageService` interface using `flutter_secure_storage` key-value encrypted storage.
- **Rationale**: Avoids storing sensitive auth tokens in plain `SharedPreferences`.

### Decision 3: Service Layer Abstraction for Future HTTPS REST API
- **Decision**: Define `AuthService` interface with `login(username, password)`, `logout()`, `refreshToken()`, and `validateToken()`.
- **Rationale**: Allows replacing `MockAuthService` with `RestAuthService` when backend endpoints are ready without modifying UI logic.

## Risks / Trade-offs

- **[Risk] Web build platform compatibility with secure storage** → **Mitigation**: Provide fallback memory/storage adapter for web environment if secure storage plugin is unavailable on web targets.

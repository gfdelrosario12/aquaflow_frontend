## Why

The AquaFlow mobile application requires secure user authentication to prevent unauthorized field operation and control of centralized irrigation infrastructure. Introducing a secure login flow, token management (access & refresh tokens), session persistence, and protected routing ensures that only authenticated operators can view field telemetry and trigger physical irrigation actions while preparing the app for HTTPS REST API integration.

## What Changes

- **Authentication Flow**: Add Login screen with email/username and password input, loading states, error feedback, and logout functionality.
- **Session & Token Management**: Implement access-token and refresh-token handling using secure platform storage (`flutter_secure_storage`).
- **Protected Routing**: Guard application shell navigation behind authentication state; unauthenticated users are redirected to the Login view.
- **Service Abstraction**: Create `AuthRepository` and `AuthService` abstractions for clean separation of concerns, backed by a mock authentication service ready for future HTTPS REST API endpoints.
- **Unauthorized Session Handling**: Automatically clear credentials and route to Login upon session expiration or 401 Unauthorized responses.

## Capabilities

### New Capabilities
- `user-authentication`: User login, logout, token management (access/refresh), secure credential persistence, and protected session state management.

### Modified Capabilities
- `mobile-app-shell`: Guard app navigation shell and protected routes behind authenticated session state.

## Impact

- **Frontend Codebase**: Scaffolds `lib/features/auth/` containing domain models (`AuthToken`, `UserSession`), repository abstractions, mock auth service, secure storage service, and presentation UI (`LoginScreen`).
- **App Navigation**: Modifies `main.dart` and `AppShell` to enforce authentication state guards.
- **No Domain Violations**: Preserves Q1–Q4 as monitoring zones and centralized field irrigation architecture.

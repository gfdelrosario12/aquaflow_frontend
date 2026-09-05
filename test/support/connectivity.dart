// Re-exports FakeConnectivityProbe for test use.
// The canonical definition lives in the library so all test files
// can import this single helper without repeating the library import.

export 'package:aquaflow_frontend/core/offline/connectivity_service.dart'
    show FakeConnectivityProbe, ConnectivityNotifier, ConnectivityState;

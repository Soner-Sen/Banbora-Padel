# Architecture Documentation

This document provides detailed information about the architecture of the Sonrize Padel application.

## Overview

The application follows **Clean Architecture** principles with a **Feature-First** approach, ensuring:

- Clear functional boundaries
- Real module ownership per feature
- Strong separation of concerns
- Cubit-based state management
- Offline-first persistence strategy
- Release-ready engineering discipline

## Directory Structure

```
lib/
├── app/                    # Application composition root
│   ├── app.dart           # Root widget, theme, l10n, router
│   ├── bootstrap.dart     # Startup sequence, initialization
│   ├── di.dart           # Dependency injection setup
│   └── router.dart       # GoRouter configuration, guards
├── core/                   # Shared cross-cutting capabilities
│   ├── analytics/         # Event tracking contracts & adapters
│   ├── config/            # Environment & build flavor config
│   ├── design_system/     # UI primitives, tokens, themes
│   ├── error/             # Failure models, error handling
│   ├── feature_flags/     # Remote/local flag system
│   ├── local_storage/     # Shared persistence helpers
│   ├── logging/           # Structured logging abstractions
│   ├── monitoring/        # Crash/error monitoring hooks
│   ├── network/           # HTTP client wrappers
│   └── testing/           # Test fixtures, mocks, helpers
└── features/               # Feature modules
    └── [feature]/
        ├── data/          # Data sources, DTOs, mappers, repos
        ├── domain/        # Entities, use cases, repository contracts
        └── presentation/  # Cubits, screens, widgets
```

## Layer Rules

### Dependency Direction

```
Presentation → Domain ← Data
App → Features/Core
Core stays independent
```

### Presentation Layer

- Contains Cubits, Screens, and Widgets
- **MUST NOT**:
  - Know transport details
  - Parse raw API payloads
  - Contain persistence logic
  - Have long-lived business rules
- **SHOULD**:
  - Depend on domain contracts/use cases
  - Use design system components
  - Remain easy to widget test

### Domain Layer

- Contains Entities, Value Objects, Repository Contracts, Use Cases
- **MUST NOT**:
  - Depend on Flutter
  - Depend on data layer implementations
  - Leak DTO or storage structure
- **SHOULD**:
  - Model business language
  - Be highly testable
  - Be stable across infrastructure changes

### Data Layer

- Contains DTOs, Remote/Local Data Sources, Mappers, Repository Implementations
- **MUST**:
  - Handle all infrastructure details
  - Implement domain repository contracts
  - Translate between domain and infrastructure
- **SHOULD BE**:
  - Designed for unreliable networks
  - Include retry logic where appropriate
  - Have explicit persistence strategy

## State Management

### Cubit Pattern

We use **Cubit** as the default state management pattern:

```dart
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final IAnalyticsService _analyticsService;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required IAnalyticsService analyticsService,
  })  : _loginUseCase = loginUseCase,
        _analyticsService = analyticsService,
        super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    // ... business logic
  }
}
```

### State Rules

1. States are immutable (use `copyWith` or construct new)
2. Use status enums for lifecycle states when applicable
3. One cubit = one primary presentation responsibility
4. Methods represent user intent

## Use Case Policy

Use Cases are expected in this architecture. However, they must be **meaningful**:

Use a use case when:
- It captures a business action
- It coordinates multiple steps
- It improves readability
- It improves testability
- It creates a stable boundary

Don't create ceremonial use cases that simply forward one repository call without adding value.

## Offline/Persistence Strategy

Each feature should explicitly answer:

1. What is stored locally?
2. What is cached temporarily?
3. What is the source of truth?
4. What happens when network is unavailable?
5. Is the feature offline-readable?
6. Is the feature offline-writable with sync?
7. Is there queued sync?
8. How are conflicts resolved?

### Persistence Modes

- **Remote First**: Always fetch from network
- **Cache Assisted**: Use cache when offline
- **Offline Readable**: Full offline functionality
- **Offline Writable with Sync**: Local-first with background sync

## Error Handling

All failures extend a common `Failure` type:

```dart
abstract class Failure {
  final String message;
  final String? code;
  final Object? originalError;
}
```

Types:
- `NetworkFailure`: No connection, timeout
- `ServerFailure`: API errors (5xx)
- `ValidationFailure`: Input validation errors
- `AuthFailure`: Authentication/authorization errors
- `CacheFailure`: Local storage errors
- `UnknownFailure`: Unexpected errors

## Testing Strategy

### Test Pyramid

- **Unit Tests**: Domain, use cases, entities, mappers
- **Cubit Tests**: State transitions, business logic
- **Repository Tests**: Mapping, error behavior
- **Widget Tests**: Screen behavior, state rendering
- **Integration Tests**: Critical user flows

### What to Test

- Domain rules
- Use case input/output
- Repository success/failure paths
- Cubit lifecycle and transitions
- Offline/cache behavior

## Build Configuration

### Environment Variables

```dart
// Accessed via AppConfig
AppConfig.instance.environment    // development, staging, production
AppConfig.instance.isDevelopment // true if development
AppConfig.instance.apiBaseUrl    // Base URL for API
AppConfig.instance.apiTimeout    // Request timeout
```

### Build Flavors

- `development`: Local development
- `staging`: Staging environment
- `production`: Production release

## Security Considerations

1. **Token Storage**: Use `flutter_secure_storage` for tokens
2. **API Calls**: Always use HTTPS
3. **Error Logging**: Never log sensitive data
4. **Local Storage**: Encrypt sensitive local data

## Performance Guidelines

1. **Lazy Loading**: Load features on demand
2. **Caching**: Cache API responses appropriately
3. **Image Optimization**: Use cached_network_image
4. **List Virtualization**: Use ListView.builder for large lists

## Monitoring & Analytics

### Analytics Events

All events follow naming convention:
- `auth_login_attempt`
- `auth_login_success`
- `auth_login_failed`

### Error Monitoring

All unhandled exceptions are captured via `MonitoringService`.

## CI/CD Pipeline

### Codemagic Configuration

See `codemagic.yaml` for full pipeline:

1. Static analysis (`flutter analyze`)
2. Unit tests (`flutter test`)
3. Widget tests
4. Build verification (Android/iOS)
5. Distribution

### Release Process

1. Create release branch
2. Run full CI pipeline
3. Verify builds
4. Merge to main
5. Create GitHub release
6. Codemagic auto-deploys

## Appendix: Core Module Responsibilities

| Module | Purpose |
|--------|---------|
| `analytics` | Event tracking, naming standards |
| `config` | Environment, build flavors |
| `design_system` | Spacing, colors, typography, components |
| `error` | Failure models, error translation |
| `feature_flags` | Rollout control, kill switches |
| `local_storage` | Shared persistence |
| `logging` | Structured logging |
| `monitoring` | Crash reporting |
| `network` | HTTP client, connectivity |
| `testing` | Shared test utilities |

## Appendix: Feature Boundary Rules

A feature may expose:
- Presentation entry points (for routing)
- Domain contracts (entities, use cases)
- Carefully selected shared widgets

A feature must NOT:
- Import another feature's internal data layer
- Reuse another feature's private DTOs
- Use another feature's Cubit directly
- Use another feature as a utility bucket

Cross-feature interaction should go through:
- Domain contracts
- App-level routing
- Shared core abstractions
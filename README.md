# Sonrize Clean Project Flutter Starter

A production-ready Flutter starter template with Clean Architecture, feature-first organization, and comprehensive tooling. Perfect as a foundation for any Flutter project.

## Features

- 🔐 User Authentication (Login, Register, Logout)
- 📱 Cross-platform Flutter application
- 🎨 Clean Architecture with feature-first organization
- 🧪 TDD development methodology
- 📦 Offline-first persistence strategy
- 🚀 CI/CD ready with Codemagic
- 📋 Starter template with reusable core modules

## Architecture

This starter template follows **Clean Architecture** principles with a **feature-first** approach:

```
lib/
├── app/                    # Application composition
│   ├── app.dart           # Root widget
│   ├── bootstrap.dart     # Startup sequence
│   ├── di.dart           # Dependency injection
│   └── router.dart       # Navigation
├── core/                   # Shared cross-cutting capabilities
│   ├── analytics/        # Event tracking
│   ├── config/           # Environment configuration
│   ├── design_system/     # UI primitives
│   ├── error/            # Error handling
│   ├── feature_flags/    # Feature flag system
│   ├── local_storage/    # Persistence helpers
│   ├── logging/          # Structured logging
│   ├── monitoring/       # Crash reporting
│   ├── network/          # HTTP client
│   └── testing/          # Test utilities
└── features/              # Feature modules
    └── auth/             # Authentication feature
        ├── data/         # Data layer (DTOs, sources, repos)
        ├── domain/       # Domain layer (entities, usecases)
        └── presentation/ # Presentation layer (cubit, screens)
```

### Layer Dependencies

- **Presentation** → Domain (uses use cases)
- **Data** → Domain (implements repository contracts)
- **App** → Features/Core (composes everything)

### Key Architectural Decisions

1. **Feature-First**: Code organized by feature, not by technical type
2. **Clean Boundaries**: Domain has no dependencies on infrastructure
3. **Cubit for State**: Using Cubit for simpler state management
4. **Offline Strategy**: Each feature explicitly defines its persistence mode

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Dart 3.10+

### Installation

```bash
# Clone the repository
git clone https://github.com/Soner-Sen/sonrize-clean-project-flutter-starter.git

# Navigate to project
cd sonrize-clean-project-flutter-starter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Setup

Create a `.env` file or set environment variables:

```bash
# Android
flutter run --dart-define=ENVIRONMENT=development

# iOS
flutter run --dart-define=ENVIRONMENT=development
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## CI/CD

This project uses Codemagic for CI/CD pipeline:

- Static analysis
- Unit/widget/integration tests
- Build verification per platform
- Automatic deployment

## Contributing

This is a starter template - feel free to customize and extend for your specific project needs.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
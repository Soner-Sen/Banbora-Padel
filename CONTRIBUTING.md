# Contributing to Sonrize Padel

Thank you for your interest in contributing to Sonrize Padel! This document provides guidelines and instructions for contributing.

## Development Workflow

### 1. Branch Naming

```
feature/[feature-name]          # New features
fix/[issue-description]         # Bug fixes
hotfix/[critical-fix]           # Urgent production fixes
refactor/[area]                 # Code refactoring
docs/[area]                     # Documentation updates
```

### 2. Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `test`: Tests
- `chore`: Maintenance

**Example:**
```
feat(auth): add password reset functionality

- Implement password reset email flow
- Add reset token validation
- Update auth repository

Closes #123
```

### 3. Pull Request Process

1. Create a feature branch from `main`
2. Make your changes following the architecture guidelines
3. Ensure all tests pass
4. Update documentation if needed
5. Create a pull request with a clear description
6. Wait for code review
7. Address feedback
8. Squash and merge

### 4. Code Review Checklist

- [ ] Follows architecture guidelines
- [ ] No dependencies on feature internals
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No hardcoded values
- [ ] Error handling in place
- [ ] Logging where appropriate

## Architecture Guidelines

### Feature-First Organization

When adding a new feature:

```
lib/features/[feature-name]/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── screens/
    └── widgets/
```

### Layer Rules

1. **Presentation** → **Domain** → **Data**
2. Domain layer must NOT depend on Data
3. Use repository contracts (interfaces) in domain
4. Implement repositories in data layer

### State Management

Use Cubit pattern:
- States are immutable
- Methods represent user intent
- One Cubit = one responsibility

### Testing Requirements

- **Unit tests** for domain layer
- **Cubit tests** for state management
- **Widget tests** for screens
- **Integration tests** for critical flows

Run tests before committing:
```bash
flutter test
```

## Coding Standards

### Dart Style

Follow Effective Dart guidelines:
- Use meaningful names
- Keep functions small
- Avoid deep nesting
- Use trailing commas

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `AuthCubit` |
| Variables | snake_case | `access_token` |
| Constants | camelCase | `maxRetries` |
| Files | snake_case | `auth_cubit.dart` |
| Enums | PascalCase | `UserRole` |
| Enum values | camelCase | `UserRole.player` |

### Error Handling

- Use typed exceptions
- Log errors appropriately
- Never expose sensitive data in errors

## Environment Setup

### Required Tools

- Flutter SDK 3.10+
- Dart 3.10+
- VS Code / Android Studio

### Setup Steps

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter analyze` to verify setup

### Running the App

```bash
# Development
flutter run

# With environment
flutter run --dart-define=ENVIRONMENT=development
```

## Common Tasks

### Adding a New Feature

1. Create feature folder structure
2. Add domain layer (entities, repository contract, use cases)
3. Add data layer (DTOs, data sources, repository impl)
4. Add presentation layer (Cubit, screens, widgets)
5. Register in DI
6. Add routes
7. Add tests

### Adding a New Use Case

1. Create use case class in `domain/usecases/`
2. Takes repository as constructor parameter
3. Returns `Either<Failure, Result>`
4. Add validation logic
5. Delegate to repository
6. Add unit tests

### Adding a New Screen

1. Create screen class in `presentation/screens/`
2. Use BlocBuilder/BlocConsumer
3. Use design system components
4. Handle all states (loading, error, empty, data)
5. Add widget tests

## Communication

- **Issues**: Use GitHub Issues
- **Discussions**: Use GitHub Discussions
- **Urgent**: Contact maintainers directly

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
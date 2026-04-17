import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================================
// Matchers
// ============================================================================

/// Creates a matcher that asserts the value is not null.
Matcher isNotNull() => isNot(isNull);

/// Creates a matcher that asserts the value is a valid email.
Matcher isValidEmail() =>
    matches(RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'));

/// Creates a matcher that asserts the value is a non-empty string.
Matcher isNonEmptyString() =>
    allOf(isA<String>(), predicate<String>((s) => s.isNotEmpty));

// ============================================================================
// Test Fixtures
// ============================================================================

/// Creates a mock response map for API success.
Map<String, dynamic> mockSuccessResponse({
  Map<String, dynamic>? data,
  String? message,
}) => {'success': true, 'data': ?data, 'message': ?message};

/// Creates a mock error response map for API failure.
Map<String, dynamic> mockErrorResponse({
  required String error,
  String? code,
  int? statusCode,
}) => {
  'success': false,
  'error': error,
  'code': ?code,
  'statusCode': ?statusCode,
};

// ============================================================================
// Widget Test Helpers
// ============================================================================

/// Helper class for widget testing.
class WidgetTestHelpers {
  WidgetTestHelpers._();

  /// Wraps a widget for testing.
  static Widget wrapWithMaterialApp(Widget widget) =>
      WidgetTestHelpers.buildTestableWidget(
        widget: widget,
        providers: const [],
      );

  /// Builds a testable widget with providers.
  /// Note: This is a placeholder. In production, use actual providers.
  static Widget buildTestableWidget({
    required Widget widget,
    List<dynamic> providers = const [],
  }) =>
      widget;

  /// Finds a widget by key.
  static Finder findByKey(Key key) => find.byKey(key);

  /// Finds a widget by type.
  static Finder findByType(Type type) => find.byType(type);

  /// Finds text widgets by text.
  static Finder findText(String text) => find.text(text);
}

// ============================================================================
// Mock Data Helpers
// ============================================================================

/// Creates mock user data.
Map<String, dynamic> mockUserData({
  String? id,
  String? email,
  String? firstName,
  String? lastName,
}) => {
  'id': id ?? 'test-user-id',
  'email': email ?? 'test@example.com',
  'firstName': firstName ?? 'Test',
  'lastName': lastName ?? 'User',
  'phoneNumber': null,
  'avatarUrl': null,
  'isEmailVerified': true,
  'role': 'player',
  'createdAt': DateTime.now().toIso8601String(),
  'updatedAt': DateTime.now().toIso8601String(),
};

/// Creates mock auth result data.
Map<String, dynamic> mockAuthResultData({
  Map<String, dynamic>? user,
  String? accessToken,
  String? refreshToken,
  DateTime? expiresAt,
}) => {
  'user': user ?? mockUserData(),
  'accessToken': accessToken ?? 'mock-access-token',
  'refreshToken': refreshToken ?? 'mock-refresh-token',
  'expiresAt': (expiresAt ?? DateTime.now().add(const Duration(hours: 1)))
      .toIso8601String(),
};

// ============================================================================
// Async Test Helpers
// ============================================================================

/// Waits for a specific duration in tests.
Future<void> waitFor(Duration duration) => Future.delayed(duration);

/// Waits for the next frame in tests.
Future<void> waitForNextFrame() async {
  await Future<void>.delayed(Duration.zero);
}

/// Advances time in tests.
Future<void> advanceTime(Duration duration) async {
  await Future<void>.delayed(duration);
}

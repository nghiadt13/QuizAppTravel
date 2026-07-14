import 'package:mocktail/mocktail.dart';

/// Common test utilities
/// Import this file in all test files:
/// ```dart
/// import '../test_helper.dart';
/// ```

/// Call this in setUpAll to register fallback values
void setupFallbackValues() {
  // Register fallback values for custom types if needed
  // Example: registerFallbackValue(FakeHostUser());
}

/// Call this in tearDown to reset mocks
void resetAllMocks(List<Mock> mocks) {
  for (final mock in mocks) {
    reset(mock);
  }
}

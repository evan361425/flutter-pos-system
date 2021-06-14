import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/theme_provider.dart';

import '../mocks/mocks.dart';
import '../test_helpers/check_notifier.dart';

void main() {
  late ThemeProvider theme;
  group('#initialize', () {
    test('should set to default value', () {
      when(cache.get(any)).thenReturn(null);
      theme.initialize();

      expect(theme.darkMode, isFalse);
    });

    test('should set correct value', () {
      when(cache.get(any)).thenReturn(true);
      theme.initialize();

      expect(theme.darkMode, isTrue);
    });
  });

  group('#setDarkMode', () {
    test('should ignore if not changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn(true);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));
      theme.initialize();

      final action = () => theme.setDarkMode(true);

      expect(await checkNotifierCalled(theme, action), isFalse);
    });

    test('should changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn(false);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));
      theme.initialize();

      final action = () => theme.setDarkMode(true);

      expect(await checkNotifierCalled(theme, action), isTrue);
    });
  });

  setUp(() {
    theme = ThemeProvider();
  });

  setUpAll(() {
    initialize();
  });
}

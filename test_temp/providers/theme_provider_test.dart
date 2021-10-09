import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/theme_provider.dart';

import '../mocks/mock_cache.dart';
import '../test_helpers/check_notifier.dart';

void main() {
  late ThemeProvider theme;
  group('#initialize', () {
    test('should set to default value', () {
      when(cache.get(any)).thenReturn(null);
      theme.initialize();

      expect(theme.mode, equals(ThemeMode.system));
    });

    test('should set correct value', () {
      when(cache.get(any)).thenReturn(ThemeMode.dark.index);
      theme.initialize();

      expect(theme.mode, equals(ThemeMode.dark));
    });
  });

  group('#setDarkMode', () {
    test('should ignore if not changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn(ThemeMode.dark.index);
      when(cache.set(any, ThemeMode.dark.index))
          .thenAnswer((_) => Future.value(true));
      theme.initialize();

      final action = () => theme.setMode(ThemeMode.dark);

      expect(await checkNotifierCalled(theme, action), isFalse);
    });

    test('should changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn(ThemeMode.dark.index);
      when(cache.set(any, ThemeMode.light.index))
          .thenAnswer((_) => Future.value(true));
      theme.initialize();

      final action = () => theme.setMode(ThemeMode.light);

      expect(await checkNotifierCalled(theme, action), isTrue);
    });
  });

  setUp(() {
    theme = ThemeProvider();
  });

  setUpAll(() {
    initializeCache();
  });
}

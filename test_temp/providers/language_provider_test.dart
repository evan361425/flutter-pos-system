import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/language_provider.dart';

import '../mocks/mock_cache.dart';
import '../test_helpers/check_notifier.dart';

void main() {
  late LanguageProvider language;
  group('#initialize', () {
    test('should set to default value', () {
      when(cache.get(any)).thenReturn(null);
      language.initialize();

      expect(language.locale, equals(LanguageProvider.defaultLocale));

      when(cache.get(any)).thenReturn('');
      language.initialize();
      expect(language.locale, equals(LanguageProvider.defaultLocale));
    });

    test('should set correct locale', () {
      when(cache.get(any)).thenReturn('zh');
      language.initialize();

      expect(language.locale, equals(Locale('zh')));

      when(cache.get(any)).thenReturn('zh_TW');
      language.initialize();

      expect(language.locale, equals(Locale('zh', 'TW')));
    });
  });

  group('#setLocale', () {
    test('should ignore if not changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn('zh_TW');
      when(cache.set(any, 'zh_TW')).thenAnswer((_) => Future.value(true));
      language.initialize();

      final action = () => language.setLocale(Locale('zh', 'TW'));

      expect(await checkNotifierCalled(language, action), isFalse);
    });

    test('should changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn('zh_TW');
      when(cache.set(any, 'zh')).thenAnswer((_) => Future.value(true));
      language.initialize();

      final action = () => language.setLocale(Locale('zh'));

      expect(await checkNotifierCalled(language, action), isTrue);
    });
  });

  group('#localeListResolutionCallback', () {
    test('should get default locale', () {
      final result1 = language.localeListResolutionCallback(null, []);
      expect(result1, equals(LanguageProvider.defaultLocale));

      language = LanguageProvider();
      final result2 = language.localeListResolutionCallback([
        Locale('zh'),
      ], [
        Locale('en', 'US'),
        Locale('en', 'CA'),
      ]);
      expect(result2, equals(LanguageProvider.defaultLocale));
    });

    test('should ignore if already setting up', () {
      final result1 = language.localeListResolutionCallback(
        [Locale('en', 'US')],
        [Locale('en', 'US')],
      );
      expect(result1, equals(Locale('en', 'US')));

      final result2 = language.localeListResolutionCallback(
        [Locale('zh', 'TW')],
        [Locale('zh', 'TW')],
      );
      expect(result2, equals(Locale('en', 'US')));
    });

    test('should get support locale', () {
      expect(
          language.localeListResolutionCallback([
            Locale('ab', 'CD'),
          ], [
            Locale('zh', 'TW'),
            Locale('AB', 'CD'),
          ]),
          equals(Locale('AB', 'CD')));

      language = LanguageProvider();
      expect(
          language.localeListResolutionCallback([
            Locale('ab', 'CD'),
          ], [
            Locale('zh', 'TW'),
            Locale('AB', 'CD'),
            Locale('ab', 'cd'),
          ]),
          equals(Locale('ab', 'cd')));

      language = LanguageProvider();
      expect(
          language.localeListResolutionCallback([
            Locale('ab', 'CD'),
          ], [
            Locale('zh', 'TW'),
            Locale('ab', 'cd'),
            Locale('AB', 'cd'),
            Locale('ab', 'CD'),
          ]),
          equals(Locale('ab', 'CD')));
    });

    test('should always use first locale', () {
      expect(
          language.localeListResolutionCallback([
            Locale('ab', 'CD'),
            Locale('zh', 'TW'),
          ], [
            Locale('zh', 'TW'),
            Locale('AB', 'CD'),
          ]),
          equals(Locale('AB', 'CD')));
    });
  });

  setUp(() {
    language = LanguageProvider();
  });

  setUpAll(() {
    initializeCache();
  });
}

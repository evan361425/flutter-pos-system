import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/ui/home/elf_page.dart';

import '../../test_helpers/translator.dart';

void main() {
  group('Elf Page', () {
    testWidgets('should display chat button and navigate', (tester) async {
      bool navigatedToChat = false;
      
      final router = GoRouter(
        navigatorKey: Routes.rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: ElfPage()),
          ),
          GoRoute(
            path: '/chat',
            name: Routes.chat,
            builder: (_, __) {
              navigatedToChat = true;
              return const Scaffold(body: Text('Chat Page'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          locale: LanguageSetting.instance.language.locale,
          routerConfig: router,
        ),
      );

      // Verify the elf page is displayed
      expect(find.byKey(const Key('elf_page')), findsOneWidget);
      
      // Verify the chat button exists
      expect(find.byKey(const Key('elf.chat_button')), findsOneWidget);

      // Tap the chat button
      await tester.tap(find.byKey(const Key('elf.chat_button')));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatedToChat, isTrue);
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}

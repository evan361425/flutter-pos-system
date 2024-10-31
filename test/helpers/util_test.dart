import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:possystem/helpers/util.dart';

void main() {
  group('Util', () {
    test('#uuidV4', () {
      final id1 = Util.uuidV4();
      final id2 = Util.uuidV4();
      expect(id1, isNot(equals(id2)));
    });

    test('#toUTC', () {
      expect(
        Util.toUTC(now: DateTime.utc(2021, 6, 14, 2, 59, 33)),
        equals(1623639573),
      );

      final date = Util.toUTC(hour: 0);
      final utc = DateTime.now().timeZoneOffset.inSeconds + date;
      // should be 0 o'clock
      expect(utc / 86400, equals((utc / 86400).floor()));
    });

    test('#fromUTC', () {
      final date = Util.fromUTC(1623639573).toUtc();
      expect(date.year, equals(2021));
      expect(date.month, equals(6));
      expect(date.day, equals(14));
      expect(date.hour, equals(2));
      expect(date.minute, equals(59));
      expect(date.second, equals(33));
    });

    test('#formatCompact', () {
      initializeDateFormatting('en', null);
      DateTimeRange range = Util.getDateRange(now: DateTime.utc(2021, 6, 14), days: 3);

      expect(range.formatCompact('en'), equals('20210614 - 20210616'));
    });

    testWidgets('#handleSnapshot error', (WidgetTester tester) async {
      Object? gotten;
      final f = Util.handleSnapshot((context, data) => const SizedBox.shrink(), onError: (err) => gotten = err);
      const err = AsyncSnapshot<String>.withError(ConnectionState.done, 'test');

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (BuildContext context) => f(context, err)),
      ));

      expect(find.text('test'), findsOneWidget);
      expect(gotten, equals('test'));
    });
  });
}

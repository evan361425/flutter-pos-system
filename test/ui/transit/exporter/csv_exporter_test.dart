import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';

void main() {
  group('CSV Exporter', () {
    const exporter = CSVExporter();

    test('unexpected quote', () async {
      final result = await exporter.import(utf8.encode('"a"bc"'));

      expect(result[0][0], equals(['"a"bc"']));
    });

    test('quote multiline', () async {
      final result = await exporter.import(utf8.encode('"a\\nb""c",def'));

      expect(result[0][0], equals(['a\nb"c', 'def']));
    });
  });
}

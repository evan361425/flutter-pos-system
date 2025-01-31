import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/csv_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:share_plus/share_plus.dart';

import 'data_exporter.dart';

class CSVExporter extends DataExporter {
  final CSVFormatter formatter;

  const CSVExporter({this.formatter = const CSVFormatter()});

  static Future<List<List<String>>> import(Stream<List<int>> stream) async {
    final result = <List<String>>[];
    final buffer = StringBuffer();
    String left = '';

    int index = 0;
    safeSplit(String line) {
      try {
        index++;
        return CSVFormatter.split(line);
      } catch (e) {
        Log.out('parse csv failed at line ${index}: ${e.toString()}', 'csv');
        return [line];
      }
    }

    await for (final data in stream) {
      buffer.write(String.fromCharCodes(data));
      final lines = (left + buffer.toString()).split('\n');
      left = lines.removeLast();
      buffer.clear();

      for (final line in lines.where((e) => e.isNotEmpty)) {
        result.add(safeSplit(line));
      }
    }

    if (left.isNotEmpty) {
      result.add(safeSplit(left));
    }

    return result;
  }

  Future<bool> export(Formattable able) async {
    final text = formatter.getRows(able).map((row) => row.join(',')).join('\n');
    final result = await Share.shareXFiles(
      [XFile.fromData(utf8.encode(text), mimeType: 'text/plain')],
      fileNameOverrides: ['${S.transitModelName(able.name)}.csv'],
    );

    return result.status == ShareResultStatus.success;
  }
}

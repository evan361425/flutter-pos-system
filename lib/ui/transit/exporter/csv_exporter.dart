import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';

import 'data_exporter.dart';

class CSVExporter extends DataExporter {
  const CSVExporter();

  Future<List<List<List<String>>>> import(List<int> input) async {
    final text = utf8.decode(input);
    Log.out(text, 'csv');
    final parts = text.split('\n\n');

    int lineNo = 0;
    return parts.map((part) {
      final result = part.split('\n').where((e) {
        lineNo++;
        return e.isNotEmpty;
      }).map((line) {
        try {
          return split(line);
        } catch (e) {
          Log.out('parse csv failed at line $lineNo: ${e.toString()}', 'csv');
          return [line];
        }
      }).toList();

      lineNo += 2;
      return result;
    }).toList();
  }

  Future<bool> export({
    required String name,
    required List<Iterable<Iterable<String>>> data,
    required List<Iterable<String>> headers,
  }) async {
    assert(data.length == headers.length, 'length not match');

    if (data.every((e) => e.isEmpty)) {
      Log.out('no data to export', 'csv');
      return false;
    }

    final texts = <String>[];
    for (var i = 0; i < data.length; i++) {
      if (data[i].isNotEmpty) {
        texts.add('${join(headers[i])}\n${data[i].map((e) => join(e)).join('\n')}');
      }
    }

    Log.out('exporting file: $name.csv', 'csv');
    return await XFile.save(
      bytes: utf8.encode(texts.join('\n\n')),
      fileName: '$name.csv',
      dialogTitle: S.transitExportFileDialogTitle,
    );
  }

  static String join(Iterable<String> fields) {
    return fields.map((e) {
      final v = e.replaceAll('"', '""').replaceAll('\n', '\\n');
      return v.contains(',') || v.contains('"') || v.contains('\\n') ? '"$v"' : v;
    }).join(',');
  }

  /// Split a CSV line into fields
  static List<String> split(String line) {
    List<String> row = [];
    StringBuffer field = StringBuffer();
    bool inQuotes = false;
    bool skip = false;

    final chars = line.characters;
    for (final (i, char) in chars.indexed) {
      if (skip) {
        skip = false;
        continue;
      }

      if (char == '"') {
        // Handle escaped double quotes ("")
        if (inQuotes && chars.elementAtOrNull(i + 1) == '"') {
          field.write('"');
          skip = true;
          continue;
        }

        if (!inQuotes && field.isNotEmpty) {
          throw FormatException('Unexpected quote', line, i);
        }

        // Toggle quote state
        inQuotes = !inQuotes;
        continue;
      }

      if (char == ',' && !inQuotes) {
        // End of field
        row.add(field.toString().trim());
        field.clear();
        continue;
      }

      if (char == '\\' && chars.elementAtOrNull(i + 1) == 'n') {
        field.write('\n');
        skip = true;
        continue;
      }

      // Regular character and ignore carriage return
      if (char != '\r') {
        field.write(char);
      }
    }

    // Add the last field and row
    if (field.isNotEmpty) {
      row.add(field.toString().trim());
    }

    return row;
  }
}

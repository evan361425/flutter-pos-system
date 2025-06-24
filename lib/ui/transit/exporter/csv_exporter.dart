import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';

import 'data_exporter.dart';

class CSVExporter extends DataExporter {
  const CSVExporter();

  Future<List<List<String>>> import(List<int> input) async {
    final result = <List<String>>[];
    final string = utf8.decode(input);

    for (final (lineNo, line) in string.split('\n').indexed) {
      if (line.isNotEmpty) {
        try {
          result.add(split(line));
        } catch (e) {
          Log.out('parse csv failed at line $lineNo: ${e.toString()}', 'csv');
          result.add([line]);
        }
      }
    }

    return result;
  }

  Future<bool> export({
    required List<String> names,
    required List<Iterable<Iterable<String>>> data,
    required List<Iterable<String>> headers,
  }) async {
    assert(names.length == data.length && names.length == headers.length, 'length not match');

    final fileNames = names.whereIndexed((i, name) => data[i].isNotEmpty).map((name) => '$name.csv').toList();
    if (fileNames.isEmpty) {
      Log.out('no data to export', 'csv');
      return Future.value(false);
    }

    final bytes = data
        .mapIndexed((idx, rows) => [headers[idx], ...rows]
            .map((row) => row.map((e) {
                  final v = e.replaceAll('"', '""').replaceAll('\n', '\\n');
                  return v.contains(',') || v.contains('"') || v.contains('\\n') ? '"$v"' : v;
                }).join(','))
            .join('\n'))
        .map((e) => utf8.encode(e))
        .toList();

    Log.out('exporting with ${names.length} files: ${fileNames.join(', ')}', 'csv');
    return XFile.save(
      bytes: bytes.whereIndexed((i, _) => data[i].isNotEmpty).toList(),
      fileNames: fileNames,
      dialogTitle: S.transitExportFileDialogTitle,
    );
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

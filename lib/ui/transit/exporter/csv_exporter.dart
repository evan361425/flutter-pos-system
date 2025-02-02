import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart' as xx;
import 'package:share_plus/share_plus.dart';

import 'data_exporter.dart';

class CSVExporter extends DataExporter {
  const CSVExporter();

  Future<List<List<String>>> import(Stream<List<int>> stream) async {
    final result = <List<String>>[];
    final buffer = StringBuffer();
    String left = '';

    int index = 0;
    safeSplit(String line) {
      try {
        index++;
        return split(line);
      } catch (e) {
        Log.out('parse csv failed at line $index: ${e.toString()}', 'csv');
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

  Future<bool> export(List<String> names, List<Iterable<Iterable<String>>> data) async {
    assert(names.length == data.length, 'names and data length not match');

    final contents = data
        .map((rows) => rows
            .map((row) => row.map((e) {
                  final v = e.replaceAll('"', '""');
                  return v.contains(',') || v.contains('"') ? '"$v"' : v;
                }).join(','))
            .join('\n'))
        .toList();

    final dir = await xx.XFile.getRootPath();
    final path = xx.XFile.fs.path.join(dir, 'transit_temp');
    await (xx.XFile(path).dir).create();

    // put all files in the same directory
    final files = names.map((name) => xx.XFile(xx.XFile.fs.path.join(path, '$name.csv')).file);
    await Future.wait(files.map((file) => file.create()));
    await Future.wait(files.mapIndexed((i, file) => file.writeAsString(contents[i])));

    final result = await Share.shareXFiles(files.map((file) => XFile(file.path)).toList());

    await Future.wait(files.map((file) => file.delete()));

    return result.status == ShareResultStatus.success;
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

      // Regular character
      field.write(char);
    }

    // Add the last field and row
    if (field.isNotEmpty) {
      row.add(field.toString().trim());
    }

    return row;
  }
}

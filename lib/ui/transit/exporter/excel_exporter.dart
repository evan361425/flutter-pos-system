import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/xfile.dart' as xx;
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import 'data_exporter.dart';

class ExcelExporter extends DataExporter {
  const ExcelExporter();

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

  Future<bool> export(List<String> names, List<List<List<CellData>>> data) async {
    assert(names.length == data.length, 'names and data length not match');

    final workbook = Workbook();
    workbook.saveAsStream()
    for (final name in names) {
      workbook.worksheets.addWithName(name);
    }

    for (final (sheetIdx, rows) in data.indexed) {
      final sheet = workbook.worksheets[sheetIdx];
      for (final (rowIdx, row) in rows.indexed) {
        sheet.importList(row.map((c) => c.value).toList(), rowIdx + 1, 1, false);
      }
    }

    final bytes = workbook.saveAsStream();

    final dir = await xx.XFile.getRootPath();
    final path = xx.XFile.fs.path.join(dir, 'transit_temp');
    await (xx.XFile(path).dir).create();

    // put all files in the same directory
    final file = xx.XFile(xx.XFile.fs.path.join(path, 'POS System.csv')).file;
    await file.create();
    await file.writeAsBytes(bytes);

    final result = await Share.shareXFiles([XFile(file.path)]);

    await file.delete();

    return result.status == ShareResultStatus.success;
  }
}

import 'dart:typed_data';

import 'package:excel/excel.dart' hide CellValue;
import 'package:possystem/models/xfile.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

import 'data_exporter.dart';

class ExcelExporter extends DataExporter {
  const ExcelExporter();

  Excel decode(List<int> input) => Excel.decodeBytes(input);

  List<List<String>>? import(Excel excel, String sheetName) {
    final sheet = excel.sheets[sheetName];

    // skip first row which is header
    return sheet?.rows.skip(1).map((row) {
      return row.map((cell) => cell?.value?.toString() ?? '').toList();
    }).toList();
  }

  Future<bool> export({
    required List<String> names,
    required List<List<List<CellData>>> data,
    required List<List<CellData>> headers,
    required String fileName,
  }) async {
    assert(names.length == data.length && names.length == headers.length, 'length not match');

    final excel = Excel.createExcel();
    for (final (sheetIdx, rows) in data.indexed) {
      final sheet = excel[names[sheetIdx]];
      rows.insert(0, headers[sheetIdx]);

      for (final (rowIdx, row) in rows.indexed) {
        for (final (columnIdx, cell) in row.indexed) {
          final value = cell.string != null
              ? TextCellValue(cell.string!)
              : cell.number != null
                  ? DoubleCellValue(cell.number!.toDouble())
                  : null;
          if (value != null) {
            sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: columnIdx, rowIndex: rowIdx), value);
          }
        }
      }
    }
    excel.delete('Sheet1'); // remove default sheet if not used
    excel.setDefaultSheet(names.first);

    final bytes = excel.encode();
    return XFile.save(
      bytes: [Uint8List.fromList(bytes ?? [])],
      fileNames: [fileName],
      dialogTitle: S.transitExportFileDialogTitle,
    );
  }
}

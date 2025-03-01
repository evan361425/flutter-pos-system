import 'package:excel/excel.dart' hide CellValue;
import 'package:possystem/models/xfile.dart' as xx;
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:share_plus/share_plus.dart';

import 'data_exporter.dart';

class ExcelExporter extends DataExporter {
  const ExcelExporter();

  Excel decode(List<int> input) => Excel.decodeBytes(input);

  List<List<String>>? import(Excel excel, String sheetName) {
    final sheet = excel.sheets[sheetName];

    return sheet?.rows.map((row) {
      return row.map((cell) => cell?.value?.toString() ?? '').toList();
    }).toList();
  }

  Future<bool> export(List<String> names, List<List<List<CellData>>> data) async {
    assert(names.length == data.length, 'names and data length not match');

    final excel = Excel.createExcel();
    for (final (sheetIdx, rows) in data.indexed) {
      final sheet = excel[names[sheetIdx]];
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

    final bytes = excel.save();

    final dir = await xx.XFile.getRootPath();
    final path = xx.XFile.fs.path.join(dir, 'transit_temp');
    await (xx.XFile(path).dir).create();

    // put all files in the same directory
    final file = xx.XFile(xx.XFile.fs.path.join(path, '${S.transitExportBasicFileName}.xlsx')).file;
    await file.create();
    await file.writeAsBytes(bytes!);

    final result = await Share.shareXFiles([XFile(file.path)]);

    await file.delete();

    return result.status == ShareResultStatus.success;
  }
}

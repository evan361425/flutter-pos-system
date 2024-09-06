import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';

class SheetPreviewPage extends StatelessWidget {
  final SheetPreviewerDataTableSource source;

  final String title;

  final List<GoogleSheetCellData> header;

  final Widget? action;

  const SheetPreviewPage({
    super.key,
    required this.source,
    required this.title,
    required this.header,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return ResponsiveDialog(
      title: Text(title),
      action: action,
      fixedSizeOnDialog: const Size(800, 0),
      scrollable: false,
      content: SingleChildScrollView(
        child: Column(children: [
          PaginatedDataTable(
            columns: [
              for (final cell in header)
                DataColumn(
                  label: cell.note == null
                      ? Text(cell.toString(), style: style)
                      : Row(children: [
                          Text(cell.toString(), style: style),
                          const SizedBox(width: 4),
                          InfoPopup(cell.note!),
                        ]),
                ),
            ],
            source: source,
            showCheckboxColumn: false,
          ),
          const SizedBox(height: kFABSpacing),
        ]),
      ),
    );
  }
}

class SheetPreviewerDataTableSource extends DataTableSource {
  final List<List<Object?>> data;

  SheetPreviewerDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      for (final item in data[index])
        DataCell(Tooltip(
          message: item.toString(),
          child: Text(item.toString()),
        )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

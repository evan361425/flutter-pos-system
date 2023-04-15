import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';

class SheetPreviewer extends StatelessWidget {
  final SheetPreviewerDataTableSource source;

  final String title;

  final List<GoogleSheetCellData> header;

  final List<Widget>? actions;

  const SheetPreviewer({
    Key? key,
    required this.source,
    required this.title,
    required this.header,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const PopButton(),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            for (final cell in header)
              DataColumn(
                label: cell.note == null
                    ? Text(cell.toString(), style: style)
                    : Row(children: [
                        Text(cell.toString(), style: style),
                        const SizedBox(width: 4),
                        InfoPopupWidget(
                          contentTitle: cell.note,
                          contentTheme: const InfoPopupContentTheme(
                            infoTextAlign: TextAlign.start,
                          ),
                          child: const Icon(Icons.help_outline_sharp),
                        ),
                      ]),
              ),
          ],
          source: source,
          showCheckboxColumn: false,
        ),
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

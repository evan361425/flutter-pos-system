import 'package:flutter/material.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/range_order_info.dart';

class ExporterOrderScreen extends StatefulWidget {
  final DateTimeRange range;

  final GoogleSheetExporter exporter;

  const ExporterOrderScreen({
    Key? key,
    required this.range,
    required this.exporter,
  }) : super(key: key);

  @override
  State<ExporterOrderScreen> createState() => _ExporterOrderScreenState();
}

class _ExporterOrderScreenState extends State<ExporterOrderScreen> {
  final selector = GlobalKey<SpreadsheetSelectorState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector(
            key: selector,
            exporter: widget.exporter,
            cacheKey: 'export_order_google_sheet',
            existLabel: '匯出於指定表單',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            onUpdate: handleSpreadsheetUpdate,
            onExecute: exportData,
          ),
        ),
        _buildSheetNamer(),
        RangeOrderInfo(range: widget.range),
      ],
    );
  }

  Widget _buildSheetNamer() {
    return TextField(
      key: const Key('namer'),
      // controller: _controller,
      decoration: InputDecoration(
        labelText: '表單標題',
        hintText: '${RangeOrderInfo.rangeLabel(widget.range)} 的訂單',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Future<void> handleSpreadsheetUpdate(GoogleSpreadsheet? ss) async {}

  Future<void> exportData(GoogleSpreadsheet? ss) async {}
}

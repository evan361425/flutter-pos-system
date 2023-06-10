import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/order_loader.dart';

import 'sheet_namer.dart';

const _cacheKey = 'exporter_google_sheet';

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

  final orderLoader = GlobalKey<OrderLoaderState>();

  String get _sheetDefaultName {
    final f = DateFormat.MMMd(S.localeName);
    return '${f.format(widget.range.start)} 到 ${f.format(widget.range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector(
            key: selector,
            exporter: widget.exporter,
            cacheKey: _cacheKey,
            existLabel: '匯出於指定表單',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            onUpdate: handleSpreadsheetUpdate,
            onExecute: exportData,
          ),
        ),
        SheetNamer(
          label: 'order',
          labelText: '訂單',
          initialValue: _sheetDefaultName,
        ),
        OrderRangeInfo(range: widget.range),
        Expanded(
          child: OrderLoader(
            key: orderLoader,
            range: widget.range,
            formatOrder: formatOrder,
          ),
        ),
      ],
    );
  }

  Future<void> handleSpreadsheetUpdate(GoogleSpreadsheet? ss) async {}

  Future<void> exportData(GoogleSpreadsheet? ss) async {}

  Widget formatOrder(OrderObject order) {
    return const SizedBox.shrink();
  }
}

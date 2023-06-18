import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/launcher_snackbar_action.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/order_loader.dart';

import 'order_formatter.dart';
import 'order_properties_modal.dart';
import 'order_table.dart';

const _cacheKey = 'exporter_google_sheet';

class ExportOrderScreen extends StatefulWidget {
  final DateTimeRange range;

  final ValueNotifier<String> notifier;

  final GoogleSheetExporter exporter;

  const ExportOrderScreen({
    Key? key,
    required this.range,
    required this.notifier,
    required this.exporter,
  }) : super(key: key);

  @override
  State<ExportOrderScreen> createState() => _ExportOrderScreenState();
}

class _ExportOrderScreenState extends State<ExportOrderScreen> {
  final selector = GlobalKey<SpreadsheetSelectorState>();
  final orderLoader = GlobalKey<OrderLoaderState>();
  late OrderSpreadsheetProperties properties;

  @override
  Widget build(BuildContext context) {
    final names = properties.names.map((e) => '「$e」').join('、');
    return Column(
      children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector<SheetType>(
            key: selector,
            exporter: widget.exporter,
            cacheKey: _cacheKey,
            existLabel: '匯出於指定表單',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            sheetsToCreate: sheetsToCreate,
            onPrepared: exportData,
          ),
        ),
        OrderRangeInfo(range: widget.range),
        ListTile(
          title: Text('將匯出至$names'),
          subtitle: MetaBlock.withString(context, [
            '${properties.isOverwrite ? '會' : '不會'}覆寫',
            '${properties.withPrefix ? '有' : '沒有'}日期前綴',
          ]),
          onTap: editSheets,
          trailing: IconButton(
            icon: const Icon(KIcons.edit),
            onPressed: editSheets,
          ),
        ),
        Expanded(
          child: OrderLoader(
            key: orderLoader,
            range: widget.range,
            formatOrder: (order) => OrderTable(order: order),
          ),
        ),
      ],
    );
  }

  Map<SheetType, String> sheetsToCreate() {
    final f = DateFormat('MMdd', S.localeName);
    final p = '${f.format(widget.range.start)}-${f.format(widget.range.end)} ';
    return properties.sheetNames(p);
  }

  @override
  void initState() {
    super.initState();
    properties = OrderSpreadsheetProperties.fromCache();
  }

  /// [SpreadsheetSelector] 檢查基礎資料後，真正開始匯出。
  Future<void> exportData(
    GoogleSpreadsheet ss,
    Map<SheetType, GoogleSheetProperties> prepared,
  ) async {
    Future<void> exportOneByOne() async {
      final orders = orderLoader.currentState?.orders;
      if (orders != null) {
        Log.ger('ready', 'gs_export_order', ss.id);
        for (final entry in prepared.entries) {
          final label = entry.key.name;
          widget.notifier.value = S.exporterGSUpdateModelStatus(label);

          await widget.exporter.updateSheet(
            ss,
            entry.value,
            orders.map((e) {
              return OrderFormatter.formatOrder(e).map((o) {
                return o is String
                    ? GoogleSheetCellData(stringValue: o)
                    : GoogleSheetCellData(numberValue: o as num);
              }).toList();
            }).toList(),
            [], //TODO
          );
        }

        Log.ger('export finish', 'gs_export');
        if (mounted) {
          showSnackBar(
            context,
            S.actSuccess,
            action: LauncherSnackbarAction(
              label: '開啟表單',
              link: ss.toLink(),
              logCode: 'gs_export',
            ),
          );
        }
      }
    }

    widget.notifier.value = '_start';

    await showSnackbarWhenFailed(
      exportOneByOne(),
      context,
      'gs_export_failed',
    );

    widget.notifier.value = '_finish';
  }

  void editSheets() async {
    final other = await Navigator.of(context).push<OrderSpreadsheetProperties>(
      MaterialPageRoute(
        builder: (_) => OrderPropertiesModal(
          properties: properties,
          sheets: selector.currentState?.spreadsheet?.sheets,
        ),
      ),
    );

    if (other != null) {
      setState(() {
        properties = other;
      });
    }
  }
}

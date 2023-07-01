import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/launcher_snackbar_action.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/export_order_loader.dart';

import 'order_formatter.dart';
import 'order_properties_modal.dart';
import 'order_table.dart';

const _cacheKey = 'exporter_google_sheet';

class ExportOrderScreen extends StatefulWidget {
  final ValueNotifier<DateTimeRange> rangeNotifier;

  final ValueNotifier<String> statusNotifier;

  final GoogleSheetExporter exporter;

  const ExportOrderScreen({
    Key? key,
    required this.rangeNotifier,
    required this.statusNotifier,
    required this.exporter,
  }) : super(key: key);

  @override
  State<ExportOrderScreen> createState() => _ExportOrderScreenState();
}

class _ExportOrderScreenState extends State<ExportOrderScreen> {
  final selector = GlobalKey<SpreadsheetSelectorState>();
  final orderLoader = GlobalKey<ExportOrderLoaderState>();
  late OrderSpreadsheetProperties properties;

  @override
  Widget build(BuildContext context) {
    final names = properties.names.map((e) => '「$e」').join('、');
    return Column(
      children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector(
            key: selector,
            exporter: widget.exporter,
            cacheKey: _cacheKey,
            existLabel: '匯出於指定試算表',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            sheetsToCreate: sheetsToCreate,
            onPrepared: exportData,
          ),
        ),
        OrderRangeInfo(notifier: widget.rangeNotifier),
        ListTile(
          title: Text('將匯出至$names'),
          subtitle: MetaBlock.withString(context, [
            '${properties.isOverwrite ? '會' : '不會'}覆寫',
            '${properties.withPrefix ? '有' : '沒有'}日期前綴',
          ]),
          trailing: IconButton(
            icon: const Icon(KIcons.edit),
            onPressed: editSheets,
          ),
          onTap: editSheets,
        ),
        const Divider(),
        Expanded(
          child: ExportOrderLoader(
            key: orderLoader,
            notifier: widget.rangeNotifier,
            formatOrder: (order) => OrderTable(order: order),
          ),
        ),
      ],
    );
  }

  Map<SheetType, String> sheetsToCreate() {
    final f = DateFormat('MMdd', S.localeName);
    final p =
        '${f.format(widget.rangeNotifier.value.start)}-${f.format(widget.rangeNotifier.value.end)} ';
    return properties.sheetNames(p).map((key, value) => MapEntry(
          SheetType.values.firstWhere((e) => e.name == key.name),
          value,
        ));
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
      Log.ger('ready', 'gs_export_order', ss.id);

      final data = prepared.keys
          .map((key) => _format(key))
          .where((e) => e != null)
          .cast<Iterable<Iterable<GoogleSheetCellData>>>();
      await (properties.isOverwrite
          ? widget.exporter.updateSheet(
              ss,
              prepared.values,
              data,
              prepared.keys.map((key) => _chooseHeaders(key)
                  .map((e) => GoogleSheetCellData(stringValue: e))),
            )
          : widget.exporter.appendSheet(ss, prepared.values, data));

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

    widget.statusNotifier.value = '_start';

    await showSnackbarWhenFailed(
      exportOneByOne(),
      context,
      'gs_export_failed',
    );

    widget.statusNotifier.value = '_finish';
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

  Iterable<Iterable<GoogleSheetCellData>>? _format(SheetType type) {
    final orders = orderLoader.currentState?.orders;
    final method = _chooseFormatter(type);

    if (orders != null) {
      return orders.map((e) => method(e).map((o) => o is String
          ? GoogleSheetCellData(stringValue: o)
          : GoogleSheetCellData(numberValue: o as num)));
    }

    return null;
  }

  List<Object> Function(OrderObject) _chooseFormatter(SheetType type) {
    switch (type) {
      case SheetType.orderSetAttr:
        return OrderFormatter.formatOrderSetAttr;
      case SheetType.orderProduct:
        return OrderFormatter.formatOrderProduct;
      case SheetType.orderIngredient:
        return OrderFormatter.formatOrderIngredient;
      default:
        return OrderFormatter.formatOrder;
    }
  }

  List<String> _chooseHeaders(SheetType type) {
    switch (type) {
      case SheetType.orderSetAttr:
        return OrderFormatter.orderSetAttrHeaders;
      case SheetType.orderProduct:
        return OrderFormatter.orderProductHeaders;
      case SheetType.orderIngredient:
        return OrderFormatter.orderIngredientHeaders;
      default:
        return OrderFormatter.orderHeaders;
    }
  }
}

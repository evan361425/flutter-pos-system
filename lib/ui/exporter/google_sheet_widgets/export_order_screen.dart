import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/launcher_snackbar_action.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/export_order_loader.dart';

import 'order_formatter.dart';
import 'order_properties_modal.dart';
import 'order_table.dart';

const _cacheKey = 'exporter_order_google_sheet';

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
  late OrderSpreadsheetProperties properties;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
          child: SignInButton(
            signedInWidget: SpreadsheetSelector(
              key: selector,
              exporter: widget.exporter,
              cacheKey: _cacheKey,
              fallbackCacheKey: 'exporter_google_sheet',
              existLabel: '指定匯出',
              existHint: '將把訂單匯出至「%name」',
              emptyLabel: '建立匯出',
              emptyHint: '將建立新的試算表「${S.exporterBasicTitle}」，並把資料匯出至此',
              defaultName: S.exporterOrderTitle,
              requiredSheetTitles: requiredSheetTitles,
              onPrepared: exportData,
            ),
          ),
        ),
        OrderRangeInfo(notifier: widget.rangeNotifier),
        ListTile(
          key: const Key('edit_sheets'),
          title: const Text('表單設定'),
          subtitle: MetaBlock.withString(
            context,
            [
              '${properties.isOverwrite ? '會' : '不會'}覆寫',
              '${properties.withPrefix ? '有' : '沒有'}日期前綴',
              // 這個資訊可能突破兩行的限制，所以放最後
              properties.requiredSheets.map((e) => e.name).join('、'),
            ],
            maxLines: 2,
          ),
          isThreeLine: true,
          trailing: const Icon(KIcons.edit),
          onTap: editSheets,
        ),
        Expanded(
          child: ExportOrderLoader(
            notifier: widget.rangeNotifier,
            formatOrder: (order) => OrderTable(order: order),
            memoryPredictor: memoryPredictor,
            warningUrl: 'https://developers.google.com/sheets/api/limits#quota',
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    properties = OrderSpreadsheetProperties.fromCache();
  }

  Map<SheetType, String> requiredSheetTitles() {
    final prefix = properties.withPrefix
        ? widget.rangeNotifier.value.format(DateFormat('MMdd '))
        : '';

    return {
      for (final sheet in properties.requiredSheets)
        SheetType.values.firstWhere((e) => e.name == sheet.type.name):
            '$prefix${sheet.name}',
    };
  }

  /// [SpreadsheetSelector] 檢查基礎資料後，真正開始匯出。
  Future<void> exportData(
    GoogleSpreadsheet ss,
    Map<SheetType, GoogleSheetProperties> prepared,
  ) async {
    final orders = await Seller.instance.getOrderBetween(
      widget.rangeNotifier.value.start,
      widget.rangeNotifier.value.end,
      limit: null,
    );
    Log.ger('ready', 'gs_export_order', ss.id);

    final data = prepared.keys.map(chooseFormatter).map(
          (method) => orders.expand(
            (order) => method(order).map(
              (row) => row.map(
                (o) => o is String
                    ? GoogleSheetCellData(stringValue: o)
                    : GoogleSheetCellData(numberValue: o as num),
              ),
            ),
          ),
        );
    await (properties.isOverwrite
        ? widget.exporter.updateSheet(
            ss,
            prepared.values,
            data,
            prepared.keys.map((key) => chooseHeaders(key)
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

  static List<List<Object>> Function(OrderObject) chooseFormatter(
      SheetType type) {
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

  static List<String> chooseHeaders(SheetType type) {
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

  /// 這裡是一些實測的大小對應值：
  /// | productSize | attrSize | count | bytes | actual |
  /// | - | - | - | - |
  /// | 13195 | 34 | 17 | 6439 | 38.5KB |
  /// | 39672 | 92 | 46 | 18758 | 114KB |
  /// | 61751 | 142 | 71 | 29043 | 177KB |
  /// | 83775 | 200 | 100 | 39771 | 240K |
  static int memoryPredictor(OrderLoaderMetrics m) {
    return (m.productSize * 2.8 + m.attrSize * 2.8).toInt();
  }
}

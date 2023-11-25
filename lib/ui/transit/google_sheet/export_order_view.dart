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
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_order_range.dart';
import 'package:possystem/ui/transit/transit_order_list.dart';

import 'spreadsheet_selector.dart';
import 'order_formatter.dart';
import 'order_setting_page.dart';
import 'order_table.dart';

const _cacheKey = 'exporter_order_google_sheet';

class ExportOrderView extends StatefulWidget {
  final ValueNotifier<DateTimeRange> rangeNotifier;

  final ValueNotifier<String> statusNotifier;

  final GoogleSheetExporter exporter;

  const ExportOrderView({
    Key? key,
    required this.rangeNotifier,
    required this.statusNotifier,
    required this.exporter,
  }) : super(key: key);

  @override
  State<ExportOrderView> createState() => _ExportOrderViewState();
}

class _ExportOrderViewState extends State<ExportOrderView> {
  final selector = GlobalKey<SpreadsheetSelectorState>();
  late OrderSpreadsheetProperties properties;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SignInButton(
            signedInWidget: SpreadsheetSelector(
              key: selector,
              notifier: widget.statusNotifier,
              exporter: widget.exporter,
              cacheKey: _cacheKey,
              fallbackCacheKey: 'exporter_google_sheet',
              existLabel: '指定匯出',
              existHint: '匯出至試算表「%name」',
              emptyLabel: '建立匯出',
              emptyHint: '建立新的試算表「${S.transitOrderTitle}」，並把訂單匯出至此',
              defaultName: S.transitOrderTitle,
              requiredSheetTitles: requiredSheetTitles,
              onPrepared: exportData,
            ),
          ),
        ),
        TransitOrderRange(notifier: widget.rangeNotifier),
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
          trailing: const SizedBox(
            height: double.infinity,
            child: Icon(KIcons.edit),
          ),
          onTap: editSheets,
        ),
        Expanded(
          child: TransitOrderList(
            notifier: widget.rangeNotifier,
            formatOrder: (order) => OrderTable(order: order),
            memoryPredictor: memoryPredictor,
            warning: '這裡的容量代表網路傳輸所消耗的量，'
                '實際佔用的雲端記憶體可能是此值的百分之一而已。'
                '詳細容量限制說明可以參考[本文件](https://developers.google.com/sheets/api/limits#quota)。',
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
    widget.statusNotifier.value = '取得本地資料';
    final orders = await Seller.instance.getDetailedOrders(
      widget.rangeNotifier.value.start,
      widget.rangeNotifier.value.end,
    );
    Log.ger('ready', 'gs_export_order', ss.id);

    final data = prepared.keys
        .map(chooseFormatter)
        .map((method) => orders.expand((order) => method(order)));

    if (properties.isOverwrite) {
      widget.statusNotifier.value = '覆寫訂單資料';
      await widget.exporter.updateSheetValues(
        ss,
        prepared.values,
        data,
        prepared.keys.map((key) => chooseHeaders(key)),
      );
    } else {
      final it = data.iterator;
      for (final entry in prepared.entries) {
        it.moveNext();
        final name = S.transitType(entry.key.name);
        widget.statusNotifier.value = '附加進 $name';
        await widget.exporter.appendSheetValues(ss, entry.value, it.current);
      }
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

  void editSheets() async {
    final other = await Navigator.of(context).push<OrderSpreadsheetProperties>(
      MaterialPageRoute(
        builder: (_) => OrderSettingPage(
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

  /// 這裡是一些實測輸出結果：
  ///
  /// order:
  /// 1698067340,2023-10-28 14:51:23,356,295,356,115,241,5,4
  /// attr:
  /// 1698067340,用餐位置,內用
  /// product:
  /// 1698067340,起士漢堡,漢堡,1,60,30,60
  /// ingredient:
  /// 1698067340,起士,漢堡,,10
  ///
  /// 後來考慮壓縮之後，上述的值應該再乘以 0.45
  static int memoryPredictor(OrderMetrics m) {
    return (m.count * 30 +
            m.attrCount! * 10 +
            m.productCount! * 13 +
            m.ingredientCount! * 8)
        .toInt();
  }
}

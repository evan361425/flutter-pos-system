import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/snackbar_actions.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_order_list.dart';
import 'package:possystem/ui/transit/transit_order_range.dart';

import 'order_formatter.dart';
import 'order_setting_page.dart';
import 'order_table.dart';
import 'spreadsheet_selector.dart';

const _cacheKey = 'exporter_order_google_sheet';

class ExportOrderView extends StatefulWidget {
  final ValueNotifier<DateTimeRange> rangeNotifier;

  final ValueNotifier<String> statusNotifier;

  final GoogleSheetExporter exporter;

  const ExportOrderView({
    super.key,
    required this.rangeNotifier,
    required this.statusNotifier,
    required this.exporter,
  });

  @override
  State<ExportOrderView> createState() => _ExportOrderViewState();
}

class _ExportOrderViewState extends State<ExportOrderView> {
  final selector = GlobalKey<SpreadsheetSelectorState>();
  late OrderSpreadsheetProperties properties;

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      notifier: widget.rangeNotifier,
      formatOrder: (order) => OrderTable(order: order),
      memoryPredictor: memoryPredictor,
      warning: S.transitGSOrderMetaMemoryWarning,
      leading: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kHorizontalSpacing, kTopSpacing, kHorizontalSpacing, kInternalSpacing),
            child: SignInButton(
              signedInWidget: SpreadsheetSelector(
                key: selector,
                notifier: widget.statusNotifier,
                exporter: widget.exporter,
                cacheKey: _cacheKey,
                existLabel: S.transitGSSpreadsheetExportExistLabel,
                existHint: S.transitGSSpreadsheetExportExistHint,
                emptyLabel: S.transitGSSpreadsheetExportEmptyLabel,
                emptyHint: S.transitGSSpreadsheetExportEmptyHint(S.transitGSSpreadsheetOrderDefaultName),
                fallbackCacheKey: 'exporter_google_sheet',
                defaultName: S.transitGSSpreadsheetOrderDefaultName,
                requiredSheetTitles: requiredSheetTitles,
                onPrepared: exportData,
              ),
            ),
          ),
          TransitOrderRange(notifier: widget.rangeNotifier),
          ListTile(
            key: const Key('edit_sheets'),
            title: Text(S.transitGSOrderSettingTitle),
            subtitle: MetaBlock.withString(
              context,
              [
                S.transitGSOrderMetaOverwrite(properties.isOverwrite.toString()),
                S.transitGSOrderMetaTitlePrefix(properties.withPrefix.toString()),
                // This message may break the two lines limit, so put it at the end.
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
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    properties = OrderSpreadsheetProperties.fromCache();
  }

  Map<SheetType, String> requiredSheetTitles() {
    final prefix = properties.withPrefix ? '${widget.rangeNotifier.value.formatCompact(S.localeName)} ' : '';

    return {
      for (final sheet in properties.requiredSheets)
        SheetType.values.firstWhere((e) => e.name == sheet.type.name): '$prefix${sheet.name}',
    };
  }

  /// [SpreadsheetSelector] validate the basic data before actually exporting.
  Future<void> exportData(
    GoogleSpreadsheet ss,
    Map<SheetType, GoogleSheetProperties> prepared,
  ) async {
    widget.statusNotifier.value = S.transitGSProgressStatusFetchLocalOrders;
    final orders = await Seller.instance.getDetailedOrders(
      widget.rangeNotifier.value.start,
      widget.rangeNotifier.value.end,
    );
    Log.ger('gs_export', {'spreadsheet': ss.id, 'target': 'order'});

    final data = prepared.keys.map(chooseFormatter).map((method) => orders.expand((order) => method(order)));

    if (properties.isOverwrite) {
      widget.statusNotifier.value = S.transitGSProgressStatusOverwriteOrders;
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
        final name = S.transitModelName(entry.key.name);
        widget.statusNotifier.value = S.transitGSProgressStatusAppendOrders(name);
        await widget.exporter.appendSheetValues(ss, entry.value, it.current);
      }
    }

    Log.out('export finish', 'gs_export');
    if (mounted) {
      showSnackBar(
        S.actSuccess,
        context: context,
        action: LauncherSnackbarAction(
          label: S.transitGSSpreadsheetSnackbarAction,
          link: ss.toLink(),
          logCode: 'gs_export',
        ),
      );
    }
  }

  void editSheets() async {
    final other = await showAdaptiveDialog<OrderSpreadsheetProperties>(
      context: context,
      builder: (context) => OrderSettingPage(
        properties: properties,
        sheets: selector.currentState?.spreadsheet?.sheets,
      ),
    );

    if (other != null && mounted) {
      setState(() {
        properties = other;
      });
    }
  }

  static List<List<Object>> Function(OrderObject) chooseFormatter(SheetType type) {
    switch (type) {
      case SheetType.orderDetailsAttr:
        return OrderFormatter.formatOrderDetailsAttr;
      case SheetType.orderDetailsProduct:
        return OrderFormatter.formatOrderDetailsProduct;
      case SheetType.orderDetailsIngredient:
        return OrderFormatter.formatOrderDetailsIngredient;
      default:
        return OrderFormatter.formatOrder;
    }
  }

  static List<String> chooseHeaders(SheetType type) {
    switch (type) {
      case SheetType.orderDetailsAttr:
        return OrderFormatter.orderDetailsAttrHeaders;
      case SheetType.orderDetailsProduct:
        return OrderFormatter.orderDetailsProductHeaders;
      case SheetType.orderDetailsIngredient:
        return OrderFormatter.orderDetailsIngredientHeaders;
      default:
        return OrderFormatter.orderHeaders;
    }
  }

  /// These values are based on the actual data:
  ///
  /// order:
  /// 1698067340,2023-10-28 14:51:23,356,295,356,115,241,5,4
  /// attr:
  /// 1698067340,place,takeout
  /// product:
  /// 1698067340,cheese burger,burger,1,60,30,60
  /// ingredient:
  /// 1698067340,cheese,burger,,10
  ///
  /// After compression, the values should be multiplied by 0.5.
  static int memoryPredictor(OrderMetrics m) {
    return (m.count * 30 + m.attrCount! * 10 + m.productCount! * 13 + m.ingredientCount! * 8).toInt();
  }
}

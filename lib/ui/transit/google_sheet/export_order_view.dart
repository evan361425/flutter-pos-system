import 'package:flutter/material.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/snackbar_actions.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/order_widgets.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> ranger;
  final ValueNotifier<TransitOrderSettings> settings;
  final TransitStateNotifier stateNotifier;
  final GoogleSheetExporter exporter;

  const ExportOrderView({
    super.key,
    required this.ranger,
    required this.stateNotifier,
    required this.settings,
    required this.exporter,
  });

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      ranger: ranger,
      memoryPredictor: memoryPredictor,
      warning: S.transitGSOrderMetaMemoryWarning,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, kTopSpacing, 14.0, kInternalSpacing),
        child: SignInButton(
          signedInWidget: TransitOrderHead(
            stateNotifier: stateNotifier,
            title: '網路匯出',
            subtitle: '注意，由於 Google 的限流，有時會無法成功送出，需多次嘗試。\n建議大資料可以透過 Excel 或 CSV 匯出。',
            trailing: const Icon(Icons.cloud_upload_sharp),
            ranger: ranger,
            properties: settings,
            onExport: _export,
            onDone: _done,
          ),
        ),
      ),
    );
  }

  void _done(BuildContext context, String link) {
    if (link.isNotEmpty) {
      Log.out('export finish', 'gs_export');
      showSnackBar(
        S.actSuccess,
        // ignore: use_build_context_synchronously
        context: context,
        action: LauncherSnackbarAction(
          label: S.transitGSSpreadsheetSnackbarAction,
          link: link,
          logCode: 'gs_export',
        ),
      );
    }
  }

  /// Export all data to spreadsheet.
  ///
  /// 1. Ask user to select a spreadsheet.
  /// 2. Prepare the spreadsheet, make all sheets ready.
  /// 3. Export data to the spreadsheet.
  Future<String> _export(BuildContext context) async {
    // Step 1
    GoogleSpreadsheet? ss = await SpreadsheetDialog.show(
      context,
      exporter: exporter,
      cacheKey: importCacheKey,
      fallbackCacheKey: exportCacheKey,
    );
    if (ss == null || !context.mounted) {
      return '';
    }

    // Step 2
    final sheetTitles = settings.value.parseTitles(ranger.value);
    final ables = sheetTitles.keys.toList();
    final titles = sheetTitles.values.toList();
    final sheets = ss.sheets.where((e) => titles.contains(e.title)).toList();
    ss = await prepareSpreadsheet(
      context: context,
      exporter: exporter,
      stateNotifier: stateNotifier,
      defaultName: S.transitGSSpreadsheetModelDefaultName,
      cacheKey: exportCacheKey,
      sheets: titles,
      spreadsheet: ss,
    );
    if (ss == null || !context.mounted) {
      return '';
    }

    // Step 3
    Log.ger('gs_import', {'spreadsheet': ss.id, 'sheets': titles});

    final orders = await Seller.instance.getDetailedOrders(
      ranger.value.start,
      ranger.value.end,
    );
    final data = ables.map((able) => orders.expand((order) {
          return able.formatRows(order).map((l) {
            return l.map((v) => v.value).toList();
          });
        }));

    if (settings.value.isOverwrite) {
      stateNotifier.value = S.transitGSProgressStatusOverwriteOrders;
      await exporter.updateSheetValues(
        ss,
        sheets,
        data,
        ables.map((able) => able.formatHeader()),
      );

      return ss.toLink();
    }

    for (final (i, rows) in data.indexed) {
      stateNotifier.value = S.transitGSProgressStatusAppendOrders(ables[i].l10nName);
      await exporter.appendSheetValues(ss, sheets[i], rows);
    }

    return ss.toLink();
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

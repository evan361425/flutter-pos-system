import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';

class ExportOrderHeader extends TransitOrderHeader {
  const ExportOrderHeader({
    super.key,
    required super.stateNotifier,
    required super.ranger,
    required super.settings,
  });

  @override
  String get title => S.transitExportOrderTitleExcel;

  @override
  String get meta => 'Orders.xlsx';

  @override
  Future<void> onExport(BuildContext context, List<OrderObject> orders) async {
    final names = settings!.value.parseTitles(ranger.value);
    final headers = names.keys.map((e) => e.formatHeader().map((v) => CellData(string: v)).toList()).toList();
    final data = names.keys.map((e) => orders.expand((o) => e.formatRows(o)).toList()).toList();

    final ok = await const ExcelExporter().export(
      names: names.values.toList(),
      data: data,
      headers: headers,
      fileName: '${S.transitExportOrderFileName}.xlsx',
    );
    if (ok && context.mounted) {
      showSnackBar(S.transitExportOrderSuccessExcel, context: context);
    }
  }
}

class ExportOrderView extends TransitOrderList {
  const ExportOrderView({
    super.key,
    required super.ranger,
  });

  @override
  int memoryPredictor(OrderMetrics metrics) => _memoryPredictor(metrics);

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    const offset = 60 + 15 + 40 + 20; // headers
    return (offset + m.count * 40 + m.attrCount! * 20 + m.productCount! * 30 + m.ingredientCount! * 20).toInt();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
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
  String get meta => S.transitExportOrderSubtitleExcel;

  @override
  Future<void> onExport(BuildContext context) async {
    final orders = await Seller.instance.getDetailedOrders(
      ranger.value.start,
      ranger.value.end,
    );

    final names = settings!.value.parseTitles(ranger.value);
    final data = <List<List<CellData>>>[
      for (final e in names.keys)
        [
          e.formatHeader().map((e) => CellData(string: e)).toList(),
          ...orders.expand((o) => e.formatRows(o)),
        ]
    ];

    final ok = await const ExcelExporter().export(
      names: names.values.toList(),
      data: data,
      fileName: '${S.transitExportOrderFileName}.xlsx',
    );
    if (ok && context.mounted) {
      showSnackBar(S.transitExportOrderSuccessExcel, context: context);
    }
  }
}

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> ranger;

  const ExportOrderView({
    super.key,
    required this.ranger,
  });

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      ranger: ranger,
      memoryPredictor: _memoryPredictor,
      leading: OrderRangeView(notifier: ranger),
    );
  }

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    const offset = 60 + 15 + 40 + 20; // headers
    return (offset + m.count * 40 + m.attrCount! * 20 + m.productCount! * 30 + m.ingredientCount! * 20).toInt();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';

class ExportOrderHeader extends TransitOrderHeader {
  const ExportOrderHeader({
    super.key,
    required super.stateNotifier,
    required super.ranger,
    super.settings,
  });

  @override
  String get title => S.transitExportOrderTitleCsv;

  @override
  String get meta => S.transitExportOrderSubtitleCsv;

  @override
  Future<void> onExport(BuildContext context) async {
    final orders = await Seller.instance.getDetailedOrders(
      ranger.value.start,
      ranger.value.end,
    );

    final names = FormattableOrder.values.map((e) => e.l10nName).toList();
    final data = <List<List<String>>>[
      for (final e in FormattableOrder.values)
        [
          e.formatHeader(),
          ...orders.expand((o) {
            return e.formatRows(o).map((l) => l.map((v) => v.toString()).toList());
          }),
        ]
    ];

    final ok = await const CSVExporter().export(names: names, data: data);
    if (ok && context.mounted) {
      showSnackBar(S.transitExportOrderSuccessCsv, context: context);
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

import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/csv_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> ranger;
  final TransitStateNotifier stateNotifier;
  final CSVExporter exporter;

  const ExportOrderView({
    super.key,
    required this.ranger,
    required this.stateNotifier,
    this.exporter = const CSVExporter(),
  });

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      ranger: ranger,
      memoryPredictor: _memoryPredictor,
      leading: TransitOrderHead(
        stateNotifier: stateNotifier,
        title: S.transitExportOrderTitleCsv,
        subtitle: S.transitExportOrderSubtitleCsv,
        trailing: const Icon(Icons.share_outlined),
        ranger: ranger,
        onExport: _export,
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final orders = await Seller.instance.getDetailedOrders(
      ranger.value.start,
      ranger.value.end,
    );

    final names = <String>[];
    final data = <List<List<String>>>[];
    for (final e in FormattableOrder.values) {
      names.add(S.transitModelName(e.l10nName));
      data.add([
        e.formatHeader(),
        ...orders.expand((o) {
          return e.formatRows(o).map((l) => l.map((v) => v.toString()).toList());
        }),
      ]);
    }

    final ok = await exporter.export(names, data);
    if (context.mounted && ok) {
      showSnackBar(S.transitExportOrderSuccessCsv, context: context);
    }
  }

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    const offset = 60 + 15 + 40 + 20; // headers
    return (offset + m.count * 40 + m.attrCount! * 20 + m.productCount! * 30 + m.ingredientCount! * 20).toInt();
  }
}

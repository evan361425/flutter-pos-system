import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> ranger;
  final ValueNotifier<TransitOrderSettings> settings;
  final TransitStateNotifier stateNotifier;
  final ExcelExporter exporter;

  const ExportOrderView({
    super.key,
    required this.ranger,
    required this.stateNotifier,
    required this.settings,
    this.exporter = const ExcelExporter(),
  });

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      ranger: ranger,
      memoryPredictor: _memoryPredictor,
      leading: TransitOrderHead(
        stateNotifier: stateNotifier,
        title: S.transitExportOrderTitleExcel,
        subtitle: S.transitExportOrderSubtitleExcel,
        trailing: const Icon(Icons.share_outlined),
        ranger: ranger,
        properties: settings,
        onExport: _export,
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final orders = await Seller.instance.getDetailedOrders(
      ranger.value.start,
      ranger.value.end,
    );

    final names = settings.value.parseTitles(ranger.value);
    final data = <List<List<CellData>>>[
      for (final e in names.keys)
        [
          e.formatHeader().map((e) => CellData(string: e)).toList(),
          ...orders.expand((o) => e.formatRows(o)),
        ]
    ];

    final ok = await exporter.export(
      names: names.values.toList(),
      data: data,
      fileName: '${S.transitExportOrderFileName}.xlsx',
    );
    if (ok && context.mounted) {
      showSnackBar(S.transitExportOrderSuccessExcel, context: context);
    }
  }

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    const offset = 60 + 15 + 40 + 20; // headers
    return (offset + m.count * 40 + m.attrCount! * 20 + m.productCount! * 30 + m.ingredientCount! * 20).toInt();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/excel_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/transit_order_list.dart';
import 'package:possystem/ui/transit/transit_order_range.dart';
import 'package:possystem/ui/transit/widgets.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;
  final ValueNotifier<String> stateNotifier;
  final ExcelExporter exporter;

  const ExportOrderView({
    super.key,
    required this.notifier,
    required this.stateNotifier,
    this.exporter = const ExcelExporter(),
  });

  @override
  Widget build(BuildContext context) {
    return TransitOrderList(
      notifier: notifier,
      formatOrder: (order) => OrderTable(order: order),
      memoryPredictor: _memoryPredictor,
      leading: Column(
        children: [
          const SizedBox(height: 16.0),
          Card(
            key: const Key('export_btn'),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: Text(S.transitPTCopyBtn),
              subtitle: Text(S.transitPTCopyWarning),
              trailing: const Icon(Icons.share_outlined),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              onTap: () => _share(context),
            ),
          ),
          TransitOrderRange(notifier: notifier),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    if (stateNotifier.value != '_start') {
      try {
        stateNotifier.value = '_start';
        await showSnackbarWhenFutureError(
          _startShare(),
          'excel_export_failed',
          context: context,
        ).then((value) {
          if (context.mounted) {
            showSnackBar(S.transitPTCopySuccess, context: context);
          }
        });
      } finally {
        stateNotifier.value = '_finish';
      }
    }
  }

  Future<void> _startShare() async {
    final orders = await Seller.instance.getDetailedOrders(
      notifier.value.start,
      notifier.value.end,
    );

    final names = <String>[];
    final data = <List<List<CellData>>>[];
    for (final e in FormattableOrder.values) {
      names.add(S.transitModelName(e.l10nName));
      data.add([
        e.formatHeader().map((e) => CellData(string: e)).toList(),
        ...orders.expand((o) => e.formatRows(o)),
      ]);
    }

    await exporter.export(names, data);
  }

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    const offset = 60 + 15 + 40 + 20; // headers
    return (offset + m.count * 40 + m.attrCount! * 20 + m.productCount! * 30 + m.ingredientCount! * 20).toInt();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/sign_in_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/order_loader.dart';

import 'order_properties_modal.dart';

const _cacheKey = 'exporter_google_sheet';

class ExporterOrderScreen extends StatefulWidget {
  final DateTimeRange range;

  final GoogleSheetExporter exporter;

  const ExporterOrderScreen({
    Key? key,
    required this.range,
    required this.exporter,
  }) : super(key: key);

  @override
  State<ExporterOrderScreen> createState() => _ExporterOrderScreenState();
}

class _ExporterOrderScreenState extends State<ExporterOrderScreen> {
  final selector = GlobalKey<SpreadsheetSelectorState>();
  final orderLoader = GlobalKey<OrderLoaderState>();
  OrderSpreadsheetProperties properties =
      OrderSpreadsheetProperties.fromCache(_cacheKey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignInButton(
          signedInWidget: SpreadsheetSelector(
            key: selector,
            exporter: widget.exporter,
            cacheKey: _cacheKey,
            existLabel: '匯出於指定表單',
            existHint: '將匯出於「%name」',
            emptyLabel: '匯出後建立試算單',
            emptyHint: '你尚未選擇試算表，匯出時將建立新的',
            onExecute: exportData,
          ),
        ),
        OrderRangeInfo(range: widget.range),
        ListTile(
          title: Text('將匯出至以下表單的第 ${properties.headLine} 行'),
          subtitle: MetaBlock.withString(context, properties.names),
          trailing: IconButton(
            icon: const Icon(KIcons.edit),
            onPressed: editSheets,
          ),
        ),
        Expanded(
          child: OrderLoader(
            key: orderLoader,
            range: widget.range,
            formatOrder: formatOrder,
          ),
        ),
      ],
    );
  }

  Future<void> exportData(GoogleSpreadsheet? ss) async {
    // // check append or set

    // // set
    // await widget.exporter.updateSheet(
    //   ss,
    //   entry.value,
    //   formatter.getRows(entry.key),
    //   formatter.getHeader(entry.key),
    // );
  }

  void editSheets() async {
    final other = await Navigator.of(context).push<OrderSpreadsheetProperties>(
      MaterialPageRoute(
        builder: (_) => OrderPropertiesModal(properties: properties),
      ),
    );

    if (other != null) {
      properties = other;
    }
  }

  Widget formatOrder(OrderObject order) {
    return const SizedBox.shrink();
  }

  List<GoogleSheetCellData> _formatOrder(OrderObject order) {
    return [
      GoogleSheetCellData(stringValue: order.createdAt.toIso8601String()),
      GoogleSheetCellData(numberValue: order.totalPrice),
      GoogleSheetCellData(numberValue: order.productsPrice),
      GoogleSheetCellData(numberValue: order.paid),
      GoogleSheetCellData(numberValue: order.cost),
      GoogleSheetCellData(numberValue: order.totalCount),
      GoogleSheetCellData(numberValue: order.products.length),
      GoogleSheetCellData(
        stringValue:
            order.attributes.map((a) => '${a.name}:${a.optionName}').join('\n'),
      ),
      GoogleSheetCellData(stringValue: 'products'),
    ];
  }
}

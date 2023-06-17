import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/sheet_namer.dart';

const _cacheKey = 'exporter_google_sheet';

class OrderPropertiesModal extends StatefulWidget {
  final OrderSpreadsheetProperties properties;

  final List<GoogleSheetProperties>? sheets;

  const OrderPropertiesModal({
    Key? key,
    required this.properties,
    this.sheets,
  }) : super(key: key);

  @override
  State<OrderPropertiesModal> createState() => _OrderPropertiesModalState();
}

class _OrderPropertiesModalState extends State<OrderPropertiesModal>
    with ItemModal<OrderPropertiesModal> {
  final namers = <SheetType, GlobalKey<SheetNamerState>>{
    SheetType.order: GlobalKey<SheetNamerState>(),
    SheetType.orderSetAttr: GlobalKey<SheetNamerState>(),
    SheetType.orderProduct: GlobalKey<SheetNamerState>(),
  };

  late TextEditingController _headLiner;

  @override
  Widget? get title => const Text('匯出訂單設定');

  @override
  List<Widget> buildFormFields() {
    return [
      TextFormField(
        key: const Key('gs_export.head_line'),
        controller: _headLiner,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        validator: Validator.positiveInt('初始行數', minimum: 1),
        decoration: const InputDecoration(
          labelText: '初始行數',
          hintText: '1',
          helperText: '初始行數通常是表單的最後一行。\n只有設為「1」才會輸出欄位名稱。',
          helperMaxLines: 3,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
      for (final prop in widget.properties.sheets.entries)
        SheetNamer(
          key: namers[prop.key],
          label: prop.key.name,
          initialValue: prop.value.name,
          initialChecked: prop.value.isRequired,
          sheets: widget.sheets,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _headLiner = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _headLiner.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final sheets = <SheetType, OrderSheetProperties>{};
    for (final type in SheetType.values) {
      final key = '$_cacheKey.${type.name}';
      final namer = namers[type]?.currentState;
      if (namer != null) {
        await Cache.instance.set<String>(key, namer.name);
        await Cache.instance.set<bool>('$key.required', namer.checked);
        sheets[type] = OrderSheetProperties(namer.name, namer.checked);
      }
    }

    final properties = OrderSpreadsheetProperties(
      sheets: sheets,
      headLine: int.parse(_headLiner.text),
    );
    await Cache.instance.set<int>('$_cacheKey.headLine', properties.headLine);

    if (context.mounted) {
      Navigator.of(context).pop(properties);
    }
  }
}

class OrderSpreadsheetProperties {
  final Map<SheetType, OrderSheetProperties> sheets;

  final int headLine;

  const OrderSpreadsheetProperties({
    required this.sheets,
    this.headLine = 1,
  });

  factory OrderSpreadsheetProperties.fromCache(String prefix) {
    final sheets = <SheetType, OrderSheetProperties>{};
    for (final type in SheetType.values) {
      final key = '$_cacheKey.${type.name}';
      final name = Cache.instance.get<String>(key);
      final isRequired = Cache.instance.get<bool>('$key.required') ?? true;
      sheets[type] = OrderSheetProperties(
        name ?? '$prefix ${S.exporterGSDefaultSheetName(type.name)}',
        isRequired,
      );
    }

    return OrderSpreadsheetProperties(sheets: sheets);
  }

  Map<SheetType, String> get names => Map.fromEntries(sheets.entries
      .where((e) => e.value.isRequired)
      .map((e) => MapEntry(e.key, e.value.name)));
}

class OrderSheetProperties {
  final String name;

  final bool isRequired;

  const OrderSheetProperties(this.name, this.isRequired);
}

enum SheetType {
  order,
  orderSetAttr,
  orderProduct,
}

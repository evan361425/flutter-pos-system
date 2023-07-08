import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';

import 'sheet_namer.dart';

const _cacheKey = 'exporter_order_google_sheet';

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
  late final List<SheetNamerProperties> namers;

  late bool isOverwrite;

  late bool withPrefix;

  @override
  Widget? get title => const Text('匯出訂單設定');

  @override
  List<Widget> buildFormFields() {
    return [
      CheckboxListTile(
        key: const Key('gs_export.is_overwrite'),
        value: isOverwrite,
        title: const Text('是否覆寫表單'),
        subtitle: const Text('覆寫表單之後，將會從第一行開始匯出'),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              isOverwrite = value;
            });
          }
        },
      ),
      CheckboxListTile(
        key: const Key('gs_export.with_prefix'),
        value: withPrefix,
        title: const Text('加上日期前綴'),
        subtitle: const Text('表單名稱前面加上日期前綴，例如：0101-0131 表單名稱'),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              withPrefix = value;
            });
          }
        },
      ),
      for (final namer in namers) SheetNamer(prop: namer),
    ];
  }

  @override
  Future<void> updateItem() async {
    final sheets = <OrderSheetProperties>[];
    for (final namer in namers) {
      final key = '$_cacheKey.${namer.type.name}';
      await Cache.instance.set<String>(key, namer.name);
      await Cache.instance.set<bool>('$key.required', namer.checked);
      sheets.add(OrderSheetProperties(
        OrderSheetType.values.firstWhere((e) => e.name == namer.type.name),
        namer.name,
        namer.checked,
      ));
    }

    await Cache.instance.set<bool>('$_cacheKey.isOverwrite', isOverwrite);
    await Cache.instance.set<bool>('$_cacheKey.withPrefix', withPrefix);

    if (context.mounted) {
      Navigator.of(context).pop(OrderSpreadsheetProperties(
        sheets: sheets,
        isOverwrite: isOverwrite,
        withPrefix: withPrefix,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    isOverwrite = widget.properties.isOverwrite;
    withPrefix = widget.properties.withPrefix;
    namers = widget.properties.sheets.map((sheet) {
      return SheetNamerProperties(
        SheetType.values.firstWhere((e) => e.name == sheet.type.name),
        name: sheet.name,
        checked: sheet.isRequired,
        hints: widget.sheets?.map((e) => e.title),
      );
    }).toList();
  }
}

class OrderSpreadsheetProperties {
  final List<OrderSheetProperties> sheets;

  // 是否覆蓋表單的資料，預設是 true
  final bool isOverwrite;

  // 表單名稱是否前綴日期，預設是 true
  final bool withPrefix;

  const OrderSpreadsheetProperties({
    required this.sheets,
    required this.isOverwrite,
    required this.withPrefix,
  });

  factory OrderSpreadsheetProperties.fromCache() {
    final sheets = <OrderSheetProperties>[];
    for (final type in OrderSheetType.values) {
      final key = '$_cacheKey.${type.name}';
      final name = Cache.instance.get<String>(key);
      final isRequired = Cache.instance.get<bool>('$key.required') ?? true;
      sheets.add(OrderSheetProperties(
        type,
        name ?? S.exporterTypeName(type.name),
        isRequired,
      ));
    }

    return OrderSpreadsheetProperties(
      sheets: sheets,
      isOverwrite: Cache.instance.get<bool>('$_cacheKey.isOverwrite') ?? true,
      withPrefix: Cache.instance.get<bool>('$_cacheKey.withPrefix') ?? true,
    );
  }

  Iterable<String> get names =>
      sheets.where((e) => e.isRequired).map((e) => e.name);

  Map<OrderSheetType, String> sheetNames(String prefix) {
    prefix = withPrefix ? prefix : '';
    return Map.fromEntries(sheets
        .where((e) => e.isRequired)
        .map((e) => MapEntry(e.type, '$prefix${e.name}')));
  }
}

class OrderSheetProperties {
  final OrderSheetType type;

  final String name;

  final bool isRequired;

  const OrderSheetProperties(this.type, this.name, this.isRequired);

  get sheetType => OrderSheetType.values.firstWhere((e) => e.name == type.name);
}

enum OrderSheetType {
  order,
  orderSetAttr,
  orderProduct,
  orderIngredient,
}

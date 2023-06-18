import 'package:flutter/material.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
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
    SheetType.orderIngredient: GlobalKey<SheetNamerState>(),
  };

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

    await Cache.instance.set<bool>('$_cacheKey._orderIsOverwrite', isOverwrite);
    await Cache.instance.set<bool>('$_cacheKey._orderWithPrefix', withPrefix);

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
  }
}

class OrderSpreadsheetProperties {
  final Map<SheetType, OrderSheetProperties> sheets;

  final bool isOverwrite;

  final bool withPrefix;

  const OrderSpreadsheetProperties({
    required this.sheets,
    required this.isOverwrite,
    required this.withPrefix,
  });

  factory OrderSpreadsheetProperties.fromCache() {
    final sheets = <SheetType, OrderSheetProperties>{};
    for (final type in SheetType.values) {
      final key = '$_cacheKey.${type.name}';
      final name = Cache.instance.get<String>(key);
      final isRequired = Cache.instance.get<bool>('$key.required') ?? true;
      sheets[type] = OrderSheetProperties(
        name ?? S.exporterGSDefaultSheetName(type.name),
        isRequired,
      );
    }

    return OrderSpreadsheetProperties(
      sheets: sheets,
      isOverwrite:
          Cache.instance.get<bool>('$_cacheKey._orderIsOverwrite') ?? true,
      withPrefix:
          Cache.instance.get<bool>('$_cacheKey._orderWithPrefix') ?? true,
    );
  }

  Iterable<String> get names =>
      sheets.values.where((e) => e.isRequired).map((e) => e.name);

  Map<SheetType, String> sheetNames(String prefix) {
    prefix = withPrefix ? prefix : '';
    return Map.fromEntries(sheets.entries
        .where((e) => e.value.isRequired)
        .map((e) => MapEntry(e.key, '$prefix${e.value.name}')));
  }
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
  orderIngredient,
}

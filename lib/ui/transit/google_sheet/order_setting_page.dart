import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/card_info_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

import 'sheet_namer.dart';
import 'spreadsheet_selector.dart';

const _cacheKey = 'exporter_order_google_sheet';

class OrderSettingPage extends StatefulWidget {
  final OrderSpreadsheetProperties properties;

  final List<GoogleSheetProperties>? sheets;

  const OrderSettingPage({
    super.key,
    required this.properties,
    this.sheets,
  });

  @override
  State<OrderSettingPage> createState() => _OrderSettingPageState();
}

class _OrderSettingPageState extends State<OrderSettingPage> with ItemModal<OrderSettingPage> {
  late final List<SheetNamerProperties> namers;

  late bool isOverwrite;

  late bool withPrefix;

  @override
  String get title => S.transitGSOrderSettingTitle;

  @override
  List<Widget> buildFormFields() {
    return [
      CheckboxListTile(
        key: const Key('is_overwrite'),
        value: isOverwrite,
        title: Text(S.transitGSOrderSettingOverwriteLabel),
        subtitle: Text(S.transitGSOrderSettingOverwriteHint),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              isOverwrite = value;
            });
          }
        },
      ),
      CheckboxListTile(
        key: const Key('with_prefix'),
        value: withPrefix,
        title: Text(S.transitGSOrderSettingTitlePrefixLabel),
        subtitle: Text(S.transitGSOrderSettingTitlePrefixHint),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              withPrefix = value;
            });
          }
        },
      ),
      if (!isOverwrite && withPrefix)
        p(
          Center(
            child: Text(
              S.transitGSOrderSettingRecommendCombination,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      TextDivider(label: S.transitGSOrderSettingNameLabel),
      p(CardInfoText(
        child: Text(S.transitGSOrderSettingNameHelper),
      )),
      for (final namer in namers) SheetNamer(prop: namer),
    ];
  }

  @override
  Future<void> updateItem() async {
    final properties = OrderSpreadsheetProperties(
      sheets: namers
          .map((namer) => OrderSheetProperties(
                OrderSheetType.values.firstWhere((e) => e.name == namer.type.name),
                namer.name,
                namer.checked,
              ))
          .toList(),
      isOverwrite: isOverwrite,
      withPrefix: withPrefix,
    );
    await properties.cache();

    if (mounted) {
      Navigator.of(context).pop(properties);
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

  /// Whether to overwrite the data in the form, default is true
  final bool isOverwrite;

  /// Whether the form name is prefixed with the date, default is true
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
        name ?? S.transitModelName(type.name),
        isRequired,
      ));
    }

    return OrderSpreadsheetProperties(
      sheets: sheets,
      isOverwrite: Cache.instance.get<bool>('$_cacheKey.isOverwrite') ?? true,
      withPrefix: Cache.instance.get<bool>('$_cacheKey.withPrefix') ?? true,
    );
  }

  Iterable<OrderSheetProperties> get requiredSheets => sheets.where((e) => e.isRequired);

  Future<void> cache() async {
    for (var sheet in sheets) {
      final key = '$_cacheKey.${sheet.type.name}';
      await Cache.instance.set<String>(key, sheet.name);
      await Cache.instance.set<bool>('$key.required', sheet.isRequired);
    }

    await Cache.instance.set<bool>('$_cacheKey.isOverwrite', isOverwrite);
    await Cache.instance.set<bool>('$_cacheKey.withPrefix', withPrefix);
  }
}

class OrderSheetProperties {
  final OrderSheetType type;

  final String name;

  final bool isRequired;

  const OrderSheetProperties(this.type, this.name, this.isRequired);
}

enum OrderSheetType {
  order,
  orderDetailsAttr,
  orderDetailsProduct,
  orderDetailsIngredient,
}

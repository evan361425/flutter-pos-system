import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/date_range_picker.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/order_formatter.dart';
import 'package:possystem/ui/transit/widgets.dart';

enum ExportMemoryLevel {
  ok,
  warning,
  danger,
}

class TransitOrderList extends StatelessWidget {
  final ValueNotifier<DateTimeRange> ranger;

  /// Widget to show the order detail, if null, will show as a table.
  final Widget Function(OrderObject)? orderViewBuilder;

  /// Calculate the memory size of the order list, return the size in bytes.
  final int Function(OrderMetrics) memoryPredictor;

  /// Additional warning message to show in the memory info dialog.
  final String? warning;

  /// Leading widget of the list.
  final Widget leading;

  const TransitOrderList({
    super.key,
    required this.ranger,
    required this.memoryPredictor,
    required this.leading,
    this.orderViewBuilder,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      leading: leading,
      ranger: ranger,
      countingAll: true,
      emptyChild: Column(children: [
        leading,
        const SizedBox(height: kInternalSpacing),
        HintText(S.orderLoaderEmpty),
      ]),
      trailingBuilder: _buildMemoryInfo,
      builder: _buildOrder,
    );
  }

  /// Since exporting too much data will cause the service to crash,
  /// calculate the size as much as possible first.
  Widget _buildMemoryInfo(BuildContext context, OrderMetrics metrics) {
    final size = memoryPredictor(metrics);
    final level = size < 500000 // 500KB
        ? 0
        : size < 1000000 // 1MB
            ? 1
            : 2;
    showMemoryInfo() => showAdaptiveDialog(
          context: context,
          builder: (context) {
            return _buildWarningDialog(context, size, level);
          },
        );

    if (level == 0) {
      return IconButton(
        icon: const Icon(Icons.check_outlined),
        iconSize: 16.0,
        tooltip: S.transitOrderCapacityOk,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: showMemoryInfo,
      );
    }

    if (level == 1) {
      return IconButton(
        icon: const Icon(Icons.warning_amber_outlined),
        iconSize: 16.0,
        tooltip: S.transitOrderCapacityWarn,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
        ),
        onPressed: showMemoryInfo,
      );
    }

    return IconButton(
      icon: const Icon(Icons.dangerous_outlined),
      iconSize: 16.0,
      tooltip: S.transitOrderCapacityDanger,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: showMemoryInfo,
    );
  }

  Widget _buildOrder(BuildContext context, OrderObject order) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
      ),
      title: Text(S.transitOrderItemTitle(order.createdAt)),
      subtitle: MetaBlock.withString(context, [
        S.transitOrderItemMetaProductCount(order.productsCount),
        S.transitOrderItemMetaPrice(order.price.toCurrency()),
      ]),
      trailing: const Icon(Icons.expand_outlined),
      onTap: () async {
        final detailedOrder = await Seller.instance.getOrder(order.id!);
        if (detailedOrder != null && context.mounted) {
          await showAdaptiveDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(title: Text(S.transitOrderItemDialogTitle), children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: orderViewBuilder?.call(detailedOrder) ?? _OrderTable(detailedOrder),
                ),
              ]);
            },
          );
        }
      },
    );
  }

  Widget _buildWarningDialog(BuildContext context, int size, int level) {
    const style = TextStyle(fontWeight: FontWeight.bold);
    return AlertDialog.adaptive(
      actions: [
        PopButton(title: MaterialLocalizations.of(context).okButtonLabel),
      ],
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(children: [
          Text(S.transitOrderCapacityTitle(getMemoryWithUnit(size))),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.check_outlined,
                weight: level == 0 ? 24.0 : null,
              ),
              Icon(
                Icons.warning_amber_outlined,
                weight: level == 0 ? 24.0 : null,
              ),
              Icon(
                Icons.dangerous_outlined,
                weight: level == 0 ? 24.0 : null,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('<500KB', style: level == 0 ? style : null),
              Text('<1MB', style: level == 1 ? style : null),
              Text('≥1MB', style: level == 2 ? style : null),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
            child: Linkify.fromString([
              S.transitOrderCapacityContent,
              if (warning != null) '\n$warning',
            ].join('')),
          )
        ]),
      ),
    );
  }

  static String getMemoryWithUnit(int size) {
    var depth = size == 0 ? 0 : (math.log(size) / math.log(1024)).floor();

    String unit = 'MB';
    switch (depth) {
      case 0:
        return '<1KB';
      case 1:
        unit = 'KB';
        break;
      default:
        depth = 2;
        break;
    }
    final part = size / math.pow(1024, depth);
    return (part > 10 ? part.toInt().toString() : part.toStringAsFixed(1)) + unit;
  }
}

class TransitOrderHead extends StatelessWidget {
  final TransitStateNotifier stateNotifier;
  final String title;
  final String subtitle;
  final Icon trailing;
  final ValueNotifier<DateTimeRange> ranger;
  final ValueNotifier<TransitOrderSettings>? properties;
  final EdgeInsets margin;
  final Future<void> Function(BuildContext context) onExport;

  const TransitOrderHead({
    super.key,
    required this.stateNotifier,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.ranger,
    this.properties,
    this.margin = const EdgeInsets.fromLTRB(14.0, kTopSpacing, 14.0, kInternalSpacing),
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        key: const Key('transit.order_export'),
        margin: margin,
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: trailing,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          onTap: () => _onExport(context),
        ),
      ),
      _OrderRange(notifier: ranger),
      if (properties != null)
        ValueListenableBuilder(
          valueListenable: properties!,
          builder: (context, p, _) {
            return ListTile(
              key: const Key('transit.order_meta'),
              title: Text(S.transitOrderSettingTitle),
              subtitle: MetaBlock.withString(context, [
                S.transitOrderSettingMetaOverwrite(p.isOverwrite.toString()),
                S.transitOrderSettingMetaTitlePrefix(p.withPrefix.toString()),
              ]),
              trailing: const SizedBox(
                height: double.infinity,
                child: Icon(KIcons.edit),
              ),
              onTap: () => _showMetaSetting(context),
            );
          },
        ),
    ]);
  }

  void _onExport(BuildContext context) {
    stateNotifier.exec(() => showSnackbarWhenFutureError(
          onExport(context),
          'csv_export_failed',
          context: context,
        ));
  }

  void _showMetaSetting(BuildContext context) async {
    final other = await showAdaptiveDialog<TransitOrderSettings>(
      context: context,
      builder: (context) => _OrderSettingPage(properties: properties!.value),
    );

    if (other != null && context.mounted) {
      properties!.value = other;
    }
  }
}

class TransitOrderSettings {
  /// Whether to overwrite the data in the form, default is true
  final bool isOverwrite;

  /// Whether the form name is prefixed with the date, default is true
  final bool withPrefix;

  const TransitOrderSettings({
    required this.isOverwrite,
    required this.withPrefix,
  });

  factory TransitOrderSettings.fromCache() {
    return TransitOrderSettings(
      isOverwrite: Cache.instance.get<bool>('$_cacheKey.isOverwrite') ?? true,
      withPrefix: Cache.instance.get<bool>('$_cacheKey.withPrefix') ?? true,
    );
  }

  Map<FormattableOrder, String> parseTitles(DateTimeRange range) {
    final prefix = withPrefix ? '${range.formatCompact(S.localeName)} ' : '';

    return {
      for (final e in FormattableOrder.values) e: '$prefix${e.l10nName}',
    };
  }

  Future<void> cache() async {
    await Cache.instance.set<bool>('$_cacheKey.isOverwrite', isOverwrite);
    await Cache.instance.set<bool>('$_cacheKey.withPrefix', withPrefix);
  }
}

class _OrderRange extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const _OrderRange({required this.notifier});

  @override
  State<_OrderRange> createState() => _OrderRangeState();
}

class _OrderRangeState extends State<_OrderRange> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('transit.order.edit_range'),
      title: Text(S.transitOrderMetaRange(range.format(S.localeName))),
      subtitle: Text(S.transitOrderMetaRangeDays(range.duration.inDays)),
      onTap: pickRange,
      trailing: const Icon(Icons.date_range_outlined),
    );
  }

  DateTimeRange get range => widget.notifier.value;

  void pickRange() async {
    final result = await showMyDateRangePicker(context, range);

    if (result != null) {
      _updateRange(result.start, result.end);
    }
  }

  void _updateRange(DateTime start, DateTime end) {
    setState(() {
      widget.notifier.value = DateTimeRange(start: start, end: end);
    });
  }
}

class _OrderTable extends StatefulWidget {
  final OrderObject order;

  const _OrderTable(this.order);

  @override
  State<_OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<_OrderTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SimpleTable(
          headers: OrderFormatter.basicHeaders,
          data: OrderFormatter.formatBasic(widget.order),
          expandableIndexes: const [
            OrderFormatter.attrPosition,
            OrderFormatter.productPosition,
          ],
        ),
        TextDivider(label: S.transitFormatFieldOrderAttributeTitle),
        _SimpleTable(
          headers: OrderFormatter.attrHeaders,
          data: OrderFormatter.formatAttr(widget.order),
        ),
        TextDivider(label: S.transitFormatFieldOrderProductTitle),
        _SimpleTable(
          headers: OrderFormatter.productHeaders,
          data: OrderFormatter.formatProduct(widget.order),
          expandableIndexes: const [OrderFormatter.ingredientPosition],
        ),
        TextDivider(label: S.transitFormatFieldOrderIngredientTitle),
        _SimpleTable(
          headers: OrderFormatter.ingredientHeaders,
          data: OrderFormatter.formatIngredient(widget.order),
        ),
      ]),
    );
  }
}

class _SimpleTable extends StatelessWidget {
  final Iterable<String> headers;

  final Iterable<Iterable<Object>> data;

  final List<int> expandableIndexes;

  const _SimpleTable({
    required this.headers,
    required this.data,
    this.expandableIndexes = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(borderRadius: BorderRadius.circular(4.0)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            for (final header in headers)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  header.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ]),
          for (final row in data)
            TableRow(
              children: _rowWidgets(row).toList(),
            ),
        ],
      ),
    );
  }

  Iterable<Widget> _rowWidgets(Iterable<Object> row) sync* {
    int index = 0;
    for (final cell in row) {
      final idxOf = expandableIndexes.indexOf(index++);
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: idxOf != -1
            ? HintText(S.transitFormatFieldOrderExpandableHint)
            : Text(
                cell.toString(),
                textAlign: cell is String ? TextAlign.end : TextAlign.start,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
      );
    }
  }
}

const _cacheKey = 'exporter_order_meta';

class _OrderSettingPage extends StatefulWidget {
  final TransitOrderSettings properties;

  const _OrderSettingPage({required this.properties});

  @override
  State<_OrderSettingPage> createState() => _OrderSettingPageState();
}

class _OrderSettingPageState extends State<_OrderSettingPage> with ItemModal<_OrderSettingPage> {
  late bool isOverwrite;

  late bool withPrefix;

  @override
  String get title => S.transitOrderSettingTitle;

  @override
  List<Widget> buildFormFields() {
    return [
      CheckboxListTile(
        key: const Key('is_overwrite'),
        value: isOverwrite,
        title: Text(S.transitOrderSettingOverwriteLabel),
        subtitle: Text(S.transitOrderSettingOverwriteHint),
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
        title: Text(S.transitOrderSettingTitlePrefixLabel),
        subtitle: Text(S.transitOrderSettingTitlePrefixHint),
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
              S.transitOrderSettingRecommendCombination,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
    ];
  }

  @override
  Future<void> updateItem() async {
    final properties = TransitOrderSettings(
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
  }
}

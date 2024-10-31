import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class TransitOrderList extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final Widget Function(OrderObject) formatOrder;

  final int Function(OrderMetrics) memoryPredictor;

  final String? warning;

  final Widget leading;

  const TransitOrderList({
    super.key,
    required this.notifier,
    required this.formatOrder,
    required this.memoryPredictor,
    required this.leading,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      leading: leading,
      ranger: notifier,
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
                  child: formatOrder(detailedOrder),
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
    return AlertDialog(
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

enum ExportMemoryLevel {
  ok,
  warning,
  danger,
}

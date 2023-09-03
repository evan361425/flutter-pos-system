import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class AnalysisOrderListView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const AnalysisOrderListView({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      trailing: Tutorial(
        id: 'analysis.export',
        title: '訂單資料匯出',
        message: '把訂單匯出到外部，讓你可以做進一步分析或保存。\n你可以到「設定」去匯出多日訂單。',
        spotlightBuilder: const SpotlightRectBuilder(borderRadius: 8.0),
        child: _buildDropdown(context),
      ),
      builder: _buildOrder,
      ranger: notifier,
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final dropdown = DropdownButton<TransitMethod>(
      key: const Key('analysis.export'),
      value: null,
      isDense: true,
      hint: const Text('匯出'),
      style: theme.textTheme.bodyMedium!,
      underline: const SizedBox.shrink(),
      items: TransitMethod.values.map((TransitMethod value) {
        return DropdownMenuItem<TransitMethod>(
          value: value,
          child: Text(S.transitMethod(value.name)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.pushNamed(Routes.transitStation, pathParameters: {
            'method': value.name,
            'type': 'order',
          }, queryParameters: {
            'range': serializeRange(notifier.value)
          });
        }
      },
    );

    // let dropdown look like button
    return Theme(
      data: theme.copyWith(hintColor: theme.textTheme.bodyMedium!.color),
      child: dropdown,
    );
  }

  Widget _buildOrder(BuildContext context, OrderObject order) {
    final subtitle = MetaBlock.withString(context, [
      S.analysisOrderListItemMetaPrice(order.totalPrice),
      S.analysisOrderListItemMetaPaid(order.paid),
      S.analysisOrderListItemMetaIncome(order.income),
    ]);

    return ListTile(
      key: Key('analysis.order_list.${order.id}'),
      leading: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
      ),
      title: _buildOrderTitle(context, order),
      subtitle: subtitle,
      onTap: () => context.pushNamed(Routes.analOrderModal, extra: order),
    );
  }

  Widget _buildOrderTitle(BuildContext context, OrderObject order) {
    final theme = Theme.of(context);
    final products = order.products
        .map((product) => product.count == 1
            ? Text(product.productName)
            : Stack(clipBehavior: Clip.none, children: [
                Text(product.productName),
                Positioned(
                  top: 0,
                  right: -8,
                  child: DefaultTextStyle(
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onError,
                    ),
                    child: IntrinsicWidth(
                      child: Container(
                        height: 16,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: theme.colorScheme.error,
                          shape: const StadiumBorder(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        child: Text(product.count.toString()),
                      ),
                    ),
                  ),
                ),
              ]))
        .iterator;

    final widgets = <Widget>[];
    if (products.moveNext()) {
      widgets.add(products.current);
      while (products.moveNext()) {
        widgets.add(const Text(MetaBlock.string));
        widgets.add(products.current);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: widgets),
    );
  }
}

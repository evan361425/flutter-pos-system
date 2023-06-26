import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

import 'analysis_order_modal.dart';

class AnalysisOrderList extends StatefulWidget {
  final ValueNotifier<DateTime> notifier;

  const AnalysisOrderList({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  State<AnalysisOrderList> createState() => _AnalysisOrderListState();
}

class _AnalysisOrderListState extends State<AnalysisOrderList> {
  final loaderKey = OrderLoader.createKey();
  late DateTimeRange range;

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      loaderKey: loaderKey,
      ranger: () => range,
      builder: _buildOrder,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onRangeChanged);
    range = Util.getDateRange(now: widget.notifier.value);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onRangeChanged);
    super.dispose();
  }

  void _onRangeChanged() {
    range = Util.getDateRange(now: widget.notifier.value);
    loaderKey.currentState?.reset();
  }

  Widget _buildOrder(OrderObject order) {
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
      title: _buildOrderTitle(order),
      subtitle: subtitle,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AnalysisOrderModal(order)),
      ),
    );
  }

  Widget _buildOrderTitle(OrderObject order) {
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

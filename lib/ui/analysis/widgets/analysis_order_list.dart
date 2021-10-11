import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_product_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnalysisOrderList<T> extends StatefulWidget {
  final Future<List<OrderObject>> Function(T, int) handleLoad;

  AnalysisOrderList({Key? key, required this.handleLoad}) : super(key: key);

  @override
  AnalysisOrderListState<T> createState() => AnalysisOrderListState<T>();
}

class AnalysisOrderListState<T> extends State<AnalysisOrderList<T>> {
  final _scrollController = RefreshController();

  final List<OrderObject> _data = [];
  late T _params;
  bool? _isLoading;

  String totalPrice = '0';
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return CircularLoading();
    } else if (_isLoading == null) {
      return HintText(tt('analysis.unset'));
    } else if (_data.isEmpty) {
      return HintText(tt('analysis.empty'));
    }

    return Column(
      children: [
        Center(
          child: MetaBlock.withString(context, [
            tt('analysis.total_price', {'price': totalPrice}),
            tt('analysis.total_order', {'count': totalCount}),
          ]),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _scrollController,
            enablePullUp: true,
            enablePullDown: false,
            onLoading: () => _handleLoad(),
            footer: _OrderListFooter(),
            child: ListView.builder(
              itemBuilder: (context, index) => _OrderTile(_data[index]),
              itemCount: _data.length,
            ),
          ),
        ),
      ],
    );
  }

  void reset(T params, {required num totalPrice, required int totalCount}) =>
      setState(() {
        this.totalPrice = CurrencyProvider.n2s(totalPrice);
        this.totalCount = totalCount;
        _params = params;
        _data.clear();
        _isLoading = true;
        _handleLoad();
      });

  Future<void> _handleLoad() async {
    final data = await widget.handleLoad(_params, _data.length);

    _data.addAll(data);
    data.isEmpty
        ? _scrollController.loadNoData()
        : _scrollController.loadComplete();

    setState(() => _isLoading = false);
  }
}

class _AnalysisOrderModal extends StatelessWidget {
  final OrderObject order;

  const _AnalysisOrderModal(this.order);

  Iterable<CustomerSettingOption> get selectedCustomerSettingOptions sync* {
    for (final entry in order.customerSettings.entries) {
      final setting = CustomerSettings.instance.getItem(entry.key);
      final option = setting?.getItem(entry.value);

      if (option != null) {
        yield option;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // YYYY-MM-DD HH:mm:ss
    final createdAt = order.createdAt.toString().substring(0, 19);

    return Scaffold(
      appBar: AppBar(leading: PopButton()),
      body: Column(children: [
        HintText(createdAt),
        Expanded(
          child: OrderCashierProductList(
            customerSettings: selectedCustomerSettingOptions.toList(),
            products: order.products
                .map((product) => OrderProductTileData(
                    ingredientNames: product.ingredients.values
                        .map((e) => '${e.name} - ${e.quantityName}'),
                    productName: product.productName,
                    totalCount: product.count,
                    totalPrice: product.count * product.singlePrice))
                .toList(),
            productsPrice: order.productsPrice,
            totalPrice: order.totalPrice,
          ),
        ),
      ]),
    );
  }
}

class _OrderListFooter extends StatelessWidget {
  const _OrderListFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      height: 30,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.canLoading:
            return Center(child: Text('下拉以載入更多'));
          case LoadStatus.loading:
            return CircularLoading();
          case LoadStatus.failed:
            return Center(child: Text(tt('unknown_error')));
          case LoadStatus.noMore:
            return Center(child: Text(tt('analysis.allLoaded')));
          default:
            return Container();
        }
      },
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderObject order;

  const _OrderTile(this.order);

  Widget get leading {
    final hour = order.createdAt.hour.toString().padLeft(2, '0');
    final minute = order.createdAt.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing1),
      child: Text('$hour:$minute'),
    );
  }

  Widget get title {
    final title = order.products.map<String>((e) {
      final count = e.count > 1 ? ' * ${e.count}' : '';
      return '${e.productName}$count';
    }).join(MetaBlock.string);
    return Text(title);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = MetaBlock.withString(context, [
      tt('analysis.price', {'price': CurrencyProvider.n2s(order.totalPrice)}),
      tt('analysis.paid', {'paid': CurrencyProvider.n2s(order.paid!)}),
    ]);

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _AnalysisOrderModal(order)),
      ),
    );
  }
}

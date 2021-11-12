import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_product_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnalysisOrderList<T> extends StatefulWidget {
  final Future<List<OrderObject>> Function(T, int) handleLoad;

  const AnalysisOrderList({Key? key, required this.handleLoad})
      : super(key: key);

  @override
  AnalysisOrderListState<T> createState() => AnalysisOrderListState<T>();
}

class AnalysisOrderListState<T> extends State<AnalysisOrderList<T>> {
  final _scrollController = RefreshController();

  final List<OrderObject> _data = [];
  late T _params;
  bool? _isLoading;

  num totalPrice = 0;
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return const CircularLoading();
    } else if (_isLoading == null) {
      return HintText(S.analysisOrderListStatus('unset'));
    } else if (_data.isEmpty) {
      return HintText(S.analysisOrderListStatus('empty'));
    }

    return Column(
      children: [
        Center(
          child: MetaBlock.withString(context, [
            S.analysisOrderListMetaPrice(totalPrice),
            S.analysisOrderListMetaCount(totalCount),
          ]),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _scrollController,
            enablePullUp: true,
            enablePullDown: false,
            onLoading: () => _handleLoad(),
            footer: _buildFooter(),
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
        this.totalPrice = totalPrice;
        this.totalCount = totalCount;
        _params = params;
        _data.clear();
        _isLoading = true;
        _handleLoad();
      });

  Widget _buildFooter() {
    return CustomFooter(
      height: 30,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.canLoading:
            return Center(child: Text(S.analysisOrderListStatus('ready')));
          case LoadStatus.loading:
            return const CircularLoading();
          case LoadStatus.noMore:
            return Center(child: Text(S.analysisOrderListStatus('allLoaded')));
          default:
            return Container();
        }
      },
    );
  }

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
    final createdAt = DateFormat.MEd(S.localeName).format(order.createdAt) +
        ' ' +
        DateFormat.Hms(S.localeName).format(order.createdAt);

    return Scaffold(
      appBar: AppBar(leading: const PopButton()),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: HintText(createdAt),
        ),
        Expanded(
          child: OrderCashierProductList(
            customerSettings: selectedCustomerSettingOptions.toList(),
            products: order.products
                .map((product) => OrderProductTileData(
                    ingredientNames: product.ingredients.values
                        .map((e) => e.quantityName == null
                            ? S.orderProductIngredientDefaultName(e.name)
                            : S.orderProductIngredientName(
                                e.name,
                                e.quantityName!,
                              )),
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

class _OrderTile extends StatelessWidget {
  final OrderObject order;

  const _OrderTile(this.order);

  Widget get leading {
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing1),
      child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
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
      S.analysisOrderListItemMetaPrice(order.totalPrice),
      S.analysisOrderListItemMetaPaid(order.paid!),
    ]);

    return ListTile(
      key: Key('analysis.order_list.${order.id}'),
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _AnalysisOrderModal(order)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
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
  late final RefreshController _scrollController;

  final List<OrderObject> _data = [];
  late T _params;
  bool _isLoading = false;

  num totalPrice = 0;
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return const CircularLoading();
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
            enablePullDown: true,
            onRefresh: () => _handleRefresh(),
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

  @override
  void initState() {
    super.initState();
    _scrollController = RefreshController();
  }

  void reset(T params, {required num totalPrice, required int totalCount}) {
    setState(() {
      this.totalPrice = totalPrice;
      this.totalCount = totalCount;
      _params = params;
      _data.clear();
      _isLoading = true;
      _handleLoad();
    });
  }

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

  void _handleRefresh() async {
    _data.clear();
    await _handleLoad();
    _scrollController.refreshCompleted(resetFooterState: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('analysis.more'),
            onPressed: () => _showActions(context),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: HintText(_parseCreatedAt(order.createdAt)),
        ),
        Expanded(
          child: OrderCashierProductList(
            attributes: order.attributes.toList(),
            products: order.products
                .map((product) => OrderProductTileData(
                    ingredientNames:
                        product.ingredients.map((e) => e.quantityName == null
                            ? S.orderProductIngredientDefaultName(e.name)
                            : S.orderProductIngredientName(
                                e.name,
                                e.quantityName!,
                              )),
                    productName: product.productName,
                    totalCount: product.count,
                    totalCost: product.totalCost,
                    totalPrice: product.totalPrice))
                .toList(),
            productsPrice: order.productsPrice,
            totalPrice: order.totalPrice,
            productCost: order.cost,
            income: order.income,
          ),
        ),
      ]),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final form = GlobalKey<_WarningContextState>();
    await BottomSheetActions.withDelete<_Action>(
      context,
      deleteCallback: () => showSnackbarWhenFailed(
        Seller.instance.delete(order, form.currentState?.recoverOther ?? false),
        context,
        'analysis_delete_error',
      ),
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: _WarningContext(order, key: form),
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
      S.analysisOrderListItemMetaIncome(order.income),
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

class _WarningContext extends StatefulWidget {
  final OrderObject order;

  const _WarningContext(this.order, {Key? key}) : super(key: key);

  @override
  State<_WarningContext> createState() => _WarningContextState();
}

class _WarningContextState extends State<_WarningContext> {
  bool recoverOther = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('確定要刪除 ${_parseCreatedAt(widget.order.createdAt)} 的訂單嗎？'),
        const Text('\n此動作無法復原'),
        const Divider(height: 32),
        CheckboxListTile(
          key: const Key('analysis.tile_del_with_other'),
          autofocus: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: recoverOther,
          selected: recoverOther,
          onChanged: _onChanged,
          title: const Text('復原對應的庫存和收銀機資料'),
        ),
        if (recoverOther) ..._iterStockHint(context),
        if (recoverOther) ..._iterCashierHint(context),
      ]),
    );
  }

  Iterable<Widget> _iterStockHint(BuildContext context) sync* {
    final amounts = <String, num>{};
    widget.order.fillIngredient(amounts, add: true);

    for (final entry in amounts.entries) {
      final ing = Stock.instance.getItem(entry.key);
      if (ing != null && entry.value != 0) {
        final operator = entry.value > 0 ? '增加' : '減少';
        final v = entry.value > 0 ? entry.value : -entry.value;
        yield Text('${(ing.name)} 將$operator $v 單位');
      }
    }
  }

  Iterable<Widget> _iterCashierHint(BuildContext context) sync* {
    final amounts = <int, int>{};
    final status = Cashier.instance.smallChange(
      amounts,
      widget.order.totalPrice,
      add: false,
    );

    for (final entry in amounts.entries) {
      final e = Cashier.instance.at(entry.key);
      yield Text(
          '${e.unit} 元將減少 ${-entry.value} 個至 ${e.count + entry.value} 個');
    }

    String? errorText;
    switch (status) {
      case CashierUpdateStatus.notEnough:
        errorText = '收銀機將不夠錢換，不管了。';
        break;
      case CashierUpdateStatus.usingSmall:
        errorText = '收銀機要用小錢換才能滿足。';
        break;
      default:
        break;
    }
    if (errorText != null) {
      yield Text(
        errorText,
        style: TextStyle(color: Theme.of(context).errorColor),
      );
    }
  }

  void _onChanged(value) {
    setState(() {
      recoverOther = value ?? false;
    });
  }
}

enum _Action {
  delete,
}

String _parseCreatedAt(DateTime t) {
  return DateFormat('MEd Hms', S.localeName).format(t);
}

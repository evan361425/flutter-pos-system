import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExporterOrderScreen extends StatefulWidget {
  final DateTimeRange range;

  const ExporterOrderScreen({
    Key? key,
    required this.range,
  }) : super(key: key);

  @override
  State<ExporterOrderScreen> createState() => _ExporterOrderScreenState();
}

class _ExporterOrderScreenState extends State<ExporterOrderScreen> {
  late final RefreshController _scrollController;

  final List<OrderObject> _data = [];
  DateTime? usingDate;
  int? totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: MetaBlock.withString(context, [
            '搜尋 ${widget.range.duration.inDays} 天的資料',
            if (totalCount != null) '共 ${totalCount!} 個訂單',
          ]),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _scrollController,
            enablePullUp: true,
            enablePullDown: false,
            onLoading: _loadData,
            footer: _buildFooter(),
            child: ListView.builder(
              itemBuilder: (context, index) => _buildOrder(_data[index]),
              itemCount: _data.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showSnackbarWhenFailed(
      Seller.instance
          .getMetricBetween(widget.range.start, widget.range.end)
          .then((value) {
        setState(() => totalCount = value['count']!.toInt());
      }),
      context,
      'export_load_order_count',
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = RefreshController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final future = Seller.instance.getOrderBetween(
      widget.range.start,
      widget.range.end,
    );
    future.then((data) {
      _data.addAll(data);
      if (data.length != 10) {
        _scrollController.loadNoData();
      } else {
        _scrollController.loadComplete();
      }
    });
    showSnackbarWhenFailed(future, context, 'export_load_order');
  }

  Widget _buildOrder(OrderObject order) {
    final child = Card(child: Text(_format(order)));
    return _changeUsedDate(order.createdAt)
        ? Column(children: [
            TextDivider(
              label: DateFormat.MMMEd(S.localeName).format(order.createdAt),
            ),
            child,
          ])
        : child;
  }

  bool _changeUsedDate(DateTime dt) {
    if (usingDate != null && dt.difference(usingDate!).inDays == 0) {
      return false;
    }
    usingDate = DateTime(dt.year, dt.month, dt.day);
    return true;
  }

  String _format(OrderObject order) {
    final createdAt = DateFormat.Hm(S.localeName).format(order.createdAt);
    final attributes =
        order.attributes.map((a) => '${a.name}為${a.optionName}').join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        final amount = i.amount == 0 ? '' : '，使用 ${i.amount} 份';
        return '${i.name}（${i.quantityName ?? '預設'}$amount）';
      }).join('、');
      return '${p.productName}（${p.catalogName}）'
          '點了 ${p.count} 份共 ${p.totalPrice} 元'
          '（每份 ${p.singlePrice} 元），'
          '成份包括$ing';
    }).join('；');
    return [
      '$createdAt 點了 ${order.totalCount} 份餐點（${order.products.length} 種）',
      '共 ${order.totalPrice} 元。',
      if (order.productsPrice != order.totalPrice)
        '（其中的 ${order.productsPrice} 元是扣掉顧客選項後的產品價錢）',
      '。',
      if (attributes != '') '顧客的$attributes。',
      '餐點包括$products',
    ].join('');
  }

  Widget _buildFooter() {
    return CustomFooter(
      height: 30,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.idle:
            return const Center(child: Text('下拉以載入更多'));
          case LoadStatus.canLoading:
          case LoadStatus.loading:
            return const CircularLoading();
          case LoadStatus.noMore:
            return Center(child: Text('共 ${totalCount ?? '?'} 個訂單'));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

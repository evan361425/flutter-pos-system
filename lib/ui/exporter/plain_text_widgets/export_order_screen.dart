import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/range_order_info.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RangeOrderInfo(
          range: widget.range,
          trailing: ElevatedButton.icon(
            key: const Key('export_btn'),
            onPressed: () {
              showSnackbarWhenFailed(
                _export(),
                context,
                'pt_export_failed',
              ).then((value) => showSnackBar(context, '複製成功'));
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('複製文字'),
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _scrollController,
            enablePullUp: true,
            enablePullDown: false,
            onLoading: _loadData,
            footer: _buildFooter(),
            child: ListView.builder(
              itemBuilder: (context, index) => _buildOrder(_data[index], index),
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
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _export() {
    const exporter = PlainTextExporter();
    return exporter.exportToClipboard(_data
        .map((o) => [
              _formatCreatedAt(o),
              _formatHeader(o),
              _formatBody(o),
            ].join('\n'))
        .join('\n\n'));
  }

  void _loadData() {
    final future = Seller.instance
        .getOrderBetween(
      widget.range.start,
      widget.range.end,
      offset: _data.length,
      desc: false,
    )
        .then((data) {
      if (data.length != 10) {
        _scrollController.loadNoData();
      } else {
        _scrollController.loadComplete();
      }
      setState(() {
        _data.addAll(data);
      });
    });
    showSnackbarWhenFailed(future, context, 'export_load_order');
  }

  Widget? _buildOrder(OrderObject order, int index) {
    return ExpansionTile(
      leading: CircleAvatar(child: Text((index + 1).toString())),
      title: Text(_formatCreatedAt(order)),
      subtitle: Text(_formatHeader(order)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_formatBody(order)),
        ),
      ],
    );
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
            return const Center(child: Text('讀取完畢'));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  String _formatCreatedAt(OrderObject order) {
    return '${DateFormat.yMMMd(S.localeName).format(order.createdAt)}'
        ' '
        '${DateFormat.Hm(S.localeName).format(order.createdAt)}';
  }

  String _formatHeader(OrderObject order) {
    return [
      '${order.totalCount} 份餐點',
      '共 ${order.totalPrice.toCurrency()} 元',
    ].join(MetaBlock.string);
  }

  String _formatBody(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return '${a.name}為${a.optionName}';
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        final amount = i.amount == 0 ? '' : '，使用 ${i.amount} 個';
        return '${i.name}（${i.quantityName ?? '預設份量'}$amount）';
      }).join('、 ');
      return [
        '點了 ${p.count} 份 ${p.productName}（${p.catalogName}）',
        '共 ${p.totalPrice.toCurrency()} 元',
        ing == '' ? '沒有設定成分' : '成份包括 $ing',
      ].join('');
    }).join('；\n');
    final pl = order.products.length;
    final tc = order.totalCount;

    return [
      if (order.productsPrice != order.totalPrice)
        '${order.totalPrice.toCurrency()} 元'
            '中的 ${order.productsPrice.toCurrency()} 元是產品價錢。\n',
      if (attributes != '') '顧客的$attributes。\n',
      '餐點有 $tc 份',
      if (pl != tc) '（$pl 種）',
      '包括：\n$products',
    ].join('');
  }
}

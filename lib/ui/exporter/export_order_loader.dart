import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class ExportOrderLoader extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final Widget Function(OrderObject) formatOrder;

  final int Function(OrderLoaderMetrics) memoryPredictor;

  final String? warningUrl;

  const ExportOrderLoader({
    Key? key,
    required this.notifier,
    required this.formatOrder,
    required this.memoryPredictor,
    this.warningUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      ranger: notifier,
      trailingBuilder: _buildMemoryInfo,
      builder: _buildOrder,
    );
  }

  /// 因為匯出時過大的資訊量會導致服務崩潰，所以先盡可能的計算大小。
  Widget _buildMemoryInfo(BuildContext context, OrderLoaderMetrics metrics) {
    final size = memoryPredictor(metrics);
    showMemoryInfo() => showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(title: const Text('容量告警'), children: [
              Padding(
                key: const Key('order_memory_info'),
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text('預估容量為：${getMemoryWithUnit(size)}'),
                  const Divider(),
                  Linkify.fromString([
                    '過高的容量可能會讓執行錯誤，建議分次執行，不要一次匯出太多筆。',
                    if (warningUrl != null) '詳細容量限制說明可以參考[本文件]($warningUrl)。',
                  ].join())
                ]),
              ),
            ]);
          },
        );

    // 500KB
    if (size < 500000) {
      return FilledButton.icon(
        icon: const Icon(Icons.check_outlined),
        label: const Text('漂亮'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        onPressed: showMemoryInfo,
      );
    }

    // 1MB
    if (size < 1000000) {
      return FilledButton.icon(
        icon: const Icon(Icons.warning_amber_outlined),
        label: const Text('警告'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
        ),
        onPressed: showMemoryInfo,
      );
    }

    return FilledButton.icon(
      icon: const Icon(Icons.dangerous_outlined),
      label: const Text('危險'),
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
      title: Text(DateFormat('M月d日 HH:mm:ss').format(order.createdAt)),
      subtitle: Text([
        '${order.totalCount} 份餐點',
        '共 ${order.totalPrice.toCurrency()} 元',
      ].join(MetaBlock.string)),
      trailing: const Icon(Icons.expand_outlined),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(title: const Text('訂單細節'), children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: formatOrder(order),
              ),
            ]);
          },
        );
      },
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
    return (part > 10 ? part.toInt().toString() : part.toStringAsFixed(1)) +
        unit;
  }
}

enum ExportMemoryLevel {
  ok,
  warning,
  danger,
}

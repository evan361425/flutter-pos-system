import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/widgets/order_object_view.dart';

class HistoryOrderModal extends StatefulWidget {
  final int orderId;

  const HistoryOrderModal(this.orderId, {super.key});

  @override
  State<HistoryOrderModal> createState() => _HistoryOrderModalState();
}

class _HistoryOrderModalState extends State<HistoryOrderModal> {
  String? createdAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          MoreButton(
            key: const Key('order_modal.more'),
            onPressed: _showActions,
          ),
        ],
      ),
      body: FutureBuilder<OrderObject?>(
        future: Seller.instance.getOrder(widget.orderId),
        builder: Util.handleSnapshot((context, order) {
          if (order == null) {
            return const Center(child: Text('找不到相關訂單'));
          }

          createdAt = DateFormat.MMMEd(S.localeName).format(order.createdAt) +
              MetaBlock.string +
              DateFormat.Hms(S.localeName).format(order.createdAt);
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: HintText(createdAt!),
            ),
            Expanded(
              child: OrderObjectView(order: order),
            ),
          ]);
        }),
      ),
    );
  }

  Future<void> _showActions() async {
    if (createdAt == null) return;

    await BottomSheetActions.withDelete<_Action>(
      context,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      deleteCallback: () => showSnackbarWhenFailed(
        Seller.instance.delete(widget.orderId),
        context,
        'analysis_delete_error',
      ),
      warningContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('確定要刪除 $createdAt 的訂單嗎？'),
          const Text('\n將不會復原收銀機和庫存資料。'),
          const Text('\n此動作無法復原。'),
        ],
      ),
    );
  }
}

enum _Action {
  delete,
}

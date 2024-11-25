import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
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
    return ResponsiveDialog(
      title: Text(S.analysisHistoryOrderTitle(widget.orderId.toString())),
      scrollable: false,
      content: FutureBuilder<OrderObject?>(
        future: Seller.instance.getOrder(widget.orderId),
        builder: Util.handleSnapshot((context, order) {
          if (order == null) {
            createdAt = null;
            return Center(child: Text(S.analysisHistoryOrderNotFound));
          }

          createdAt = DateFormat.MMMEd(S.localeName).format(order.createdAt) +
              MetaBlock.string +
              DateFormat.Hms(S.localeName).format(order.createdAt);
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kHorizontalSpacing, kTopSpacing, kHorizontalSpacing, kInternalSpacing),
              child: Row(
                children: [
                  Expanded(child: Center(child: HintText(createdAt!))),
                  MoreButton(
                    key: const Key('order_modal.more'),
                    onPressed: _showActions,
                  ),
                ],
              ),
            ),
            Expanded(
              child: OrderObjectView(order: order),
            ),
          ]);
        }),
      ),
    );
  }

  void _showActions(BuildContext context) async {
    if (createdAt != null) {
      await BottomSheetActions.withDelete<_Action>(
        context,
        deleteValue: _Action.delete,
        popAfterDeleted: true,
        deleteCallback: () => showSnackbarWhenFutureError(
          Seller.instance.delete(widget.orderId),
          'analysis_delete_error',
          context: context,
        ),
        warningContent: Text(S.analysisHistoryOrderDeleteDialog(createdAt!)),
      );
    }
  }
}

enum _Action {
  delete,
}

import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class StockBatchActions extends StatelessWidget {
  static final selector = GlobalKey<_BatchItemSelectorState>();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StockBatchRepo>();
    if (!repo.isReady) return CircularLoading();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.stockBatchModal,
              arguments: selector.currentState!.currentBatch,
            ),
            child: Icon(KIcons.edit),
          ),
        ),
        Expanded(
          child: _BatchItemSelector(key: selector, batchRepo: repo),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add_circle_outline_sharp),
            label: Text('批量增加'),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColorLight,
            ),
            onPressed: () {
              final batch = selector.currentState!.currentBatch;
              if (batch != null) onApplyBatchUpdate(context, batch);
            },
          ),
        ),
      ],
    );
  }

  Future<void> onApplyBatchUpdate(
    BuildContext context,
    StockBatchModel batch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: '是否要套用 ${batch.name} ？',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('將會影響以下的成份：'),
            const SizedBox(height: kSpacing1),
            for (var id in batch.data.keys)
              Text('- ${StockModel.instance.getItem(id)?.name}'),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    selector.currentState!.currentBatch!.apply();
    selector.currentState!.clear();
  }
}

class _BatchItemSelector extends StatefulWidget {
  final StockBatchRepo batchRepo;

  const _BatchItemSelector({
    Key? key,
    required this.batchRepo,
  }) : super(key: key);

  @override
  _BatchItemSelectorState createState() => _BatchItemSelectorState();
}

class _BatchItemSelectorState extends State<_BatchItemSelector> {
  String? selectedBatchId;

  StockBatchModel? get currentBatch => selectedBatchId == null
      ? null
      : widget.batchRepo.getItem(selectedBatchId!);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedBatchId,
      hint: Text('選擇批量種類'),
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue == null) {
          Navigator.of(context).pushNamed(Routes.stockBatchModal);
        } else {
          setState(() => selectedBatchId = newValue);
        }
      },
      items: <StockBatchModel?>[null, ...widget.batchRepo.items]
          .map<DropdownMenuItem<String>>(
            (StockBatchModel? batch) => DropdownMenuItem<String>(
              value: batch?.id,
              child: Text(batch?.name ?? '增加新種類'),
            ),
          )
          .toList(),
    );
  }

  void clear() {
    setState(() => selectedBatchId = null);
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/ui/stock/stock_routes.dart';
import 'package:provider/provider.dart';

class StockBatchActions extends StatelessWidget {
  StockBatchActions({Key key}) : super(key: key);

  static final selector = GlobalKey<_BatchItemSelectorState>();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StockBatchRepo>();
    if (repo.isNotReady) return Center(child: CircularProgressIndicator());

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(KIcons.edit),
            onPressed: () => Navigator.of(context).pushNamed(
              StockRoutes.routeBatchModal,
              arguments: selector.currentState.currentBatch,
            ),
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
            onPressed: () => print('hi'),
          ),
        ),
      ],
    );
  }
}

class _BatchItemSelector extends StatefulWidget {
  const _BatchItemSelector({
    Key key,
    @required this.batchRepo,
  }) : super(key: key);

  final StockBatchRepo batchRepo;

  @override
  _BatchItemSelectorState createState() => _BatchItemSelectorState();
}

class _BatchItemSelectorState extends State<_BatchItemSelector> {
  String selectedBatchId;

  StockBatchModel get currentBatch => widget.batchRepo[selectedBatchId];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedBatchId,
      hint: Text('選擇批量種類'),
      isExpanded: true,
      onChanged: (String newValue) {
        if (newValue == null) {
          Navigator.of(context).pushNamed(StockRoutes.routeBatchModal);
        } else {
          setState(() => selectedBatchId = newValue);
        }
      },
      items: <StockBatchModel>[null, ...widget.batchRepo.batches.values]
          .map<DropdownMenuItem<String>>(
            (StockBatchModel batch) => DropdownMenuItem<String>(
              value: batch?.id,
              child: Text(batch?.name ?? '增加新種類'),
            ),
          )
          .toList(),
    );
  }
}

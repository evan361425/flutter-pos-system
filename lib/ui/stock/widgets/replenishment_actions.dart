import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class ReplenishmentActions extends StatelessWidget {
  static final selector = GlobalKey<_ReplenishmentSelectorState>();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<Replenisher>();
    if (!repo.isReady) return CircularLoading();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              Routes.stockReplenishmentModal,
              arguments: selector.currentState!.current,
            ),
            icon: Icon(KIcons.edit),
          ),
        ),
        Expanded(
          child: _ReplenishmentSelector(key: selector, replenisher: repo),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add_circle_outline_sharp),
            label: Text(tt('stock.replenisher.apply')),
            onPressed: () {
              final item = selector.currentState!.current;
              if (item != null) handleApply(context, item);
            },
          ),
        ),
      ],
    );
  }

  Future<void> handleApply(
    BuildContext context,
    Replenishment replenishment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: tt('stock.replenisher.confirm.title'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tt('stock.replenisher.confirm.content')),
            const SizedBox(height: kSpacing1),
            for (var id in replenishment.data.keys)
              Text('- ${Stock.instance.getItem(id)?.name}'),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    selector.currentState!.current!.apply();
    selector.currentState!.clear();
  }
}

class _ReplenishmentSelector extends StatefulWidget {
  final Replenisher replenisher;

  const _ReplenishmentSelector({
    Key? key,
    required this.replenisher,
  }) : super(key: key);

  @override
  _ReplenishmentSelectorState createState() => _ReplenishmentSelectorState();
}

class _ReplenishmentSelectorState extends State<_ReplenishmentSelector> {
  String? selectedId;

  Replenishment? get current =>
      selectedId == null ? null : widget.replenisher.getItem(selectedId!);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedId,
      hint: Text(tt('stock.replenisher.select_hint')),
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue == null) {
          Navigator.of(context).pushNamed(Routes.stockReplenishmentModal);
        } else {
          setState(() => selectedId = newValue);
        }
      },
      items: <Replenishment?>[null, ...widget.replenisher.items]
          .map<DropdownMenuItem<String>>(
            (Replenishment? item) => DropdownMenuItem<String>(
              value: item?.id,
              child: Text(item?.name ?? tt('stock.replenisher.add')),
            ),
          )
          .toList(),
    );
  }

  void clear() {
    setState(() => selectedId = null);
  }
}

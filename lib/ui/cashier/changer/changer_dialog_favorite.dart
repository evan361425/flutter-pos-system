import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';

class ChangerDialogFavorite extends StatefulWidget {
  final void Function() handleAdd;

  const ChangerDialogFavorite({
    Key? key,
    required this.handleAdd,
  }) : super(key: key);

  @override
  ChangerDialogFavoriteState createState() => ChangerDialogFavoriteState();
}

class ChangerDialogFavoriteState extends State<ChangerDialogFavorite> {
  static int? selectedFavorite;

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (!Cashier.instance.hasFavorites) {
      return EmptyBody(
        body: OutlinedButton(onPressed: widget.handleAdd, child: Text('立即設定')),
      );
    }

    final listView = ListView.builder(
      itemBuilder: (context, i) {
        final batch = Cashier.instance.favoriteAt(i);

        final radioTileList = RadioListTile<int>(
          value: i,
          title: Text('用 ${batch.source.count} 個 ${batch.source.unit} 元換'),
          subtitle: MetaBlock.withString(
            context,
            batch.targets.map<String>((e) => '${e.count} 個 ${e.unit} 元'),
            textOverflow: TextOverflow.visible,
          ),
          groupValue: selectedFavorite,
          onChanged: (selected) => setState(() {
            selectedFavorite = selected;
          }),
        );

        final moreButton = PopupMenuButton(
          icon: Icon(Icons.more_vert_sharp),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: ListTile(
                leading: Icon(KIcons.delete),
                onTap: () => handleDeletion(i),
                title: Text(tt('delete')),
              ),
            ),
          ],
        );

        return Row(children: [
          Expanded(
            child: GestureDetector(
              onLongPress: () => showActions(i),
              child: radioTileList,
            ),
          ),
          moreButton
        ]);
      },
      itemCount: Cashier.instance.favoriteLength,
    );

    return Column(children: [
      Text(
        '選完後請點選下方「套用」',
        style: Theme.of(context).textTheme.muted,
      ),
      Expanded(child: listView),
    ]);
  }

  void reset() {
    setState(() {});
  }

  void handleDeletion(int index) {
    print('delete $index');
  }

  Future<bool> handleApply() async {
    if (selectedFavorite == null) {
      await context.showToast('請選擇要套用的組合');
      return false;
    }

    final item = Cashier.instance.favoriteAt(selectedFavorite!);
    final isValid = await Cashier.instance.applyFavorite(item);

    if (!isValid) {
      await context.showToast('${item.source.unit} 元不夠換');
    }

    return isValid;
  }

  void showActions(int index) async {
    final result = await showCircularBottomSheet(context, actions: [
      ListTile(
        title: Text(tt('delete')),
        leading: Icon(KIcons.delete),
        onTap: () => Navigator.of(context).pop(true),
      )
    ]);

    if (result == true) handleDeletion(index);
  }
}

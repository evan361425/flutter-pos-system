import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:provider/provider.dart';

class ChangerFavoriteView extends StatefulWidget {
  final VoidCallback emptyAction;

  const ChangerFavoriteView({
    super.key,
    required this.emptyAction,
  });

  @override
  State<ChangerFavoriteView> createState() => ChangerFavoriteViewState();
}

class ChangerFavoriteViewState extends State<ChangerFavoriteView> {
  static FavoriteItem? selected;

  String? errorMessage;

  @override
  void didChangeDependencies() {
    context.watch<Cashier>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (Cashier.instance.favoriteIsEmpty) {
      return EmptyBody(
        helperText: '可以幫助你快速轉換不同幣值',
        onPressed: widget.emptyAction,
      );
    }

    final delegate = SlidableItemDelegate<FavoriteItem, int>(
      items: Cashier.instance.favoriteItems().toList(),
      deleteValue: 0,
      handleDelete: (item) => handleDeletion(item.index),
      tileBuilder: (context, item, index, showActions) => InkWell(
        onLongPress: showActions,
        child: RadioListTile<FavoriteItem>(
          key: Key('changer.favorite.$index'),
          value: item,
          title: Text('用 ${item.source.count} 個 ${item.source.unit} 元換'),
          subtitle: MetaBlock.withString(
            context,
            item.targets.map<String>((e) => '${e.count} 個 ${e.unit} 元'),
            textOverflow: TextOverflow.visible,
          ),
          secondary: EntryMoreButton(onPressed: showActions),
          groupValue: selected,
          selected: selected == item,
          onChanged: (item) => setState(() => selected = item),
        ),
      ),
    );

    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(kSpacing1),
        child: HintText('選完後請點選「套用」來使用該組合'),
      ),
      Expanded(child: SlidableItemList(delegate: delegate)),
    ]);
  }

  Future<bool> handleApply() async {
    if (selected == null) {
      showSnackBar(context, '請選擇要套用的組合');
      return false;
    }

    final isValid = await Cashier.instance.applyFavorite(selected!.item);

    if (!isValid && mounted) {
      showSnackBar(context, '${selected!.source.unit} 元不夠換');
    }

    return isValid;
  }

  Future<void> handleDeletion(int index) async {
    await Cashier.instance.deleteFavorite(index);

    setState(() => selected = null);
  }
}

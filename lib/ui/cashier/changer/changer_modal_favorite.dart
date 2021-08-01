import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/custom_styles.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';

class ChangerModalFavorite extends StatefulWidget {
  final void Function() handleAdd;

  const ChangerModalFavorite({
    Key? key,
    required this.handleAdd,
  }) : super(key: key);

  @override
  ChangerModalFavoriteState createState() => ChangerModalFavoriteState();
}

class ChangerModalFavoriteState extends State<ChangerModalFavorite> {
  static FavoriteItem? selected;

  final slidableItemList = GlobalKey<SlidableItemListState>();

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (Cashier.instance.favoriteIsEmpty) {
      return EmptyBody(onPressed: widget.handleAdd);
    }

    final listView = SlidableItemList<FavoriteItem>(
      key: slidableItemList,
      handleDelete: (_, item) => handleDeletion(item.index),
      tileBuilder: (_, item) => RadioListTile<FavoriteItem>(
        value: item,
        title: Text('用 ${item.source.count} 個 ${item.source.unit} 元換'),
        subtitle: MetaBlock.withString(
          context,
          item.targets.map<String>((e) => '${e.count} 個 ${e.unit} 元'),
          textOverflow: TextOverflow.visible,
        ),
        secondary: IconButton(
          onPressed: () => slidableItemList.currentState?.showActions(item),
          icon: Icon(Icons.more_vert_sharp),
        ),
        groupValue: selected,
        selected: selected == item,
        onChanged: (item) => setState(() => selected = item),
      ),
      items: Cashier.instance.favoriteItems(),
    );

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: Text(
          '選完後請點選「套用」來使用該組合',
          style: Theme.of(context).textTheme.muted,
        ),
      ),
      Expanded(child: listView),
    ]);
  }

  Future<bool> handleApply() async {
    if (selected == null) {
      showInfoSnackbar(context, '請選擇要套用的組合');
      return false;
    }

    final isValid = await Cashier.instance.applyFavorite(selected!.item);

    if (!isValid) {
      showInfoSnackbar(context, '${selected!.source.unit} 元不夠換');
    }

    return isValid;
  }

  Future<void> handleDeletion(int index) async {
    await Cashier.instance.deleteFavorite(index);

    setState(() => selected = null);
  }

  void reset() {
    setState(() {});
  }
}

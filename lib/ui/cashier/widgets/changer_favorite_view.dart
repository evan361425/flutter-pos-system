import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/cashier_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/translator.dart';
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
  Widget build(BuildContext context) {
    if (Cashier.instance.favoriteIsEmpty) {
      return EmptyBody(
        content: S.cashierChangerFavoriteEmptyBody,
        onPressed: widget.emptyAction,
      );
    }

    final delegate = SlidableItemDelegate<FavoriteItem, int>(
      items: Cashier.instance.favoriteItems().toList(),
      deleteValue: 0,
      handleDelete: (item) => handleDeletion(item.index),
      tileBuilder: (item, index, actorBuilder) => _Tile(
        item,
        index,
        actorBuilder,
        (item) => setState(() => selected = item),
      ),
    );

    return Column(children: [
      const SizedBox(height: kTopSpacing),
      HintText(S.cashierChangerFavoriteHint),
      const SizedBox(height: kInternalSpacing),
      for (final widget in delegate.items.mapIndexed(
        (index, item) => delegate.build(item, index),
      ))
        widget,
      const SizedBox(height: kFABSpacing),
    ]);
  }

  @override
  void didChangeDependencies() {
    context.watch<Cashier>();
    super.didChangeDependencies();
  }

  Future<bool> handleApply() async {
    if (selected == null) {
      showSnackBar(S.cashierChangerErrorNoSelection, context: context);
      return false;
    }

    final isValid = await Cashier.instance.applyFavorite(selected!.item);

    if (!isValid && mounted) {
      showSnackBar(S.cashierChangerErrorNotEnough(selected!.source.unit?.toCurrency() ?? ''), context: context);
    }

    return isValid;
  }

  Future<void> handleDeletion(int index) async {
    await Cashier.instance.deleteFavorite(index);

    setState(() => selected = null);
  }
}

class _Tile extends StatelessWidget {
  final FavoriteItem item;
  final int index;
  final ActorBuilder actorBuilder;
  final void Function(FavoriteItem?) onChanged;

  const _Tile(this.item, this.index, this.actorBuilder, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final actor = actorBuilder(context);
    return InkWell(
      onLongPress: actor,
      child: RadioListTile<FavoriteItem>(
        key: Key('changer.favorite.$index'),
        value: item,
        title: Text(S.cashierChangerFavoriteItemFrom(item.source.count!, item.source.unit!.toCurrency())),
        subtitle: MetaBlock.withString(
          context,
          item.targets.map<String>((e) => S.cashierChangerFavoriteItemTo(e.count!, e.unit!.toCurrency())),
          textOverflow: TextOverflow.visible,
        ),
        secondary: EntryMoreButton(onPressed: actor),
        groupValue: ChangerFavoriteViewState.selected,
        selected: ChangerFavoriteViewState.selected == item,
        onChanged: onChanged,
      ),
    );
  }
}

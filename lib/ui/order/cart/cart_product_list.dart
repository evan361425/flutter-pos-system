import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'cart_actions.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key? key}) : super(key: key);

  @override
  CartProductListState createState() => CartProductListState();
}

class CartProductListState extends State<CartProductList> {
  late ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    var count = 0;

    return SingleChildScrollView(
      key: const Key('cart.product_list'),
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final product in cart.products)
            ChangeNotifierProvider<OrderProduct>.value(
              value: product,
              child: _CartProductListTile(count++),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  Future<void> scrollToBottom() {
    return scrollController.animateTo(
      scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _CartProductListTile extends StatelessWidget {
  final int index;

  const _CartProductListTile(this.index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = context.watch<OrderProduct>();

    final leading = Checkbox(
      key: Key('cart.product.$index.select'),
      value: product.isSelected,
      onChanged: (checked) => product.toggleSelected(checked),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final trailing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(product.count.toString(), key: Key('cart.product.$index.count')),
        IconButton(
          key: Key('cart.product.$index.add'),
          icon: const Icon(Icons.add_circle_outline_sharp),
          onPressed: () => product.increment(),
        ),
        Text(
          // TODO: This should be num indeed, need to fix at
          // https://github.com/flutter/flutter/blob/36a0bc5b964cb2f49988bfd0410ef8601955f554/packages/flutter_tools/lib/src/localizations/gen_l10n.dart#L229
          S.orderCartItemPrice(product.price.toInt()),
          key: Key('cart.product.$index.price'),
        ),
      ],
    );

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: theme.textTheme.bodyText1!.color,
        child: ListTile(
          key: Key('cart.product.$index'),
          leading: leading,
          title: Text(product.name, overflow: TextOverflow.ellipsis),
          subtitle: product.isEmpty
              ? null
              : MetaBlock.withString(
                  context,
                  product.getIngredientNames(),
                ),
          trailing: trailing,
          onTap: () => Cart.instance.toggleAll(false, except: product),
          onLongPress: () {
            Cart.instance.toggleAll(false, except: product);
            CartActions.showActions(context);
          },
          selected: product.isSelected,
          selectedTileColor: theme.primaryColorLight,
        ),
      ),
    );
  }
}

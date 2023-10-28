import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'cart_actions.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key? key}) : super(key: key);

  @override
  State<CartProductList> createState() => _CartProductListState();
}

class _CartProductListState extends State<CartProductList> {
  late ScrollController scrollController;
  int lastLength = 0;

  @override
  Widget build(BuildContext context) {
    // if product length changed, rebuild it.
    final length = context.select<Cart, int>((cart) => cart.products.length);

    return SingleChildScrollView(
      key: const Key('cart.product_list'),
      controller: scrollController,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < length; i++)
            SlideToDelete(
              item: Cart.instance.products[i],
              onDismissed: () => Cart.instance.removeAt(i),
              child: ChangeNotifierProvider<CartProduct>.value(
                value: Cart.instance.products[i],
                child: _CartProductListTile(i),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    Cart.instance.removeListener(scrollToBottomIfAdded);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    Cart.instance.addListener(scrollToBottomIfAdded);
  }

  Future<void> scrollToBottomIfAdded() async {
    final length = Cart.instance.products.length;
    if (lastLength < length && mounted) {
      lastLength = length;
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

class _CartProductListTile extends StatelessWidget {
  final int index;

  const _CartProductListTile(this.index);

  @override
  Widget build(BuildContext context) {
    final product = context.watch<CartProduct>();
    final color = product.isSelected
        ? Theme.of(context).primaryColorLight
        : Colors.transparent;

    final leading = Checkbox(
      key: Key('cart.product.$index.select'),
      value: product.isSelected,
      onChanged: (checked) {
        product.toggleSelected(checked);
        Cart.instance.updateSelection();
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final trailing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(product.count.toString(), key: Key('cart.product.$index.count')),
        IconButton(
          key: Key('cart.product.$index.add'),
          icon: const Icon(KIcons.entryAdd),
          tooltip: '數量加一',
          onPressed: () {
            product.increment();
            Cart.instance.priceChanged();
          },
        ),
        Text(
          S.orderCartItemPrice(product.totalPrice),
          key: Key('cart.product.$index.price'),
        ),
      ],
    );

    final subtitle = product.quantities.map((e) => S.orderProductIngredientName(
          e.ingredient.name,
          e.name,
        ));

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: DefaultTextStyle.of(context).style.color,
        child: ColoredBox(
          color: color,
          child: ListTile(
            key: Key('cart.product.$index'),
            leading: leading,
            title: Text(product.name, overflow: TextOverflow.ellipsis),
            subtitle: MetaBlock.withString(
              context,
              subtitle,
              textOverflow: TextOverflow.visible,
            ),
            trailing: trailing,
            onTap: () => Cart.instance.toggleAll(false, except: product),
            onLongPress: () {
              Cart.instance.toggleAll(false, except: product);
              CartActions.showActions(context);
            },
            selected: product.isSelected,
            selectedTileColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

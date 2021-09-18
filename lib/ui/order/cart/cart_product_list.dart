import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';
import 'package:provider/provider.dart';

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

    return SingleChildScrollView(
      key: Key('order.cart.product_list'),
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final product in cart.products)
            ChangeNotifierProvider<OrderProduct>.value(
              value: product,
              child: _CartProductListTile(),
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
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _CartProductListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = context.watch<OrderProduct>();

    final leading = Checkbox(
      value: product.isSelected,
      onChanged: (checked) => product.toggleSelected(checked),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final trailing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(product.count.toString()),
        IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: () => product.increment(),
        ),
        Text(tt('order.list.price', {'price': product.price})),
      ],
    );

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: theme.textTheme.bodyText1!.color,
        child: ListTile(
          leading: leading,
          title: Text(product.name, overflow: TextOverflow.ellipsis),
          subtitle: product.isEmpty
              ? null
              : MetaBlock.withString(
                  context,
                  product.quantitiedIngredientNames,
                ),
          trailing: trailing,
          onTap: () => Cart.instance.toggleAll(false, except: product.id),
          onLongPress: () {
            Cart.instance.toggleAll(false, except: product.id);
            CartActions.showActions(context);
          },
          selected: product.isSelected,
          selectedTileColor: theme.primaryColorLight,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:provider/provider.dart';

import 'cart_product_list_tile.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key? key}) : super(key: key);

  @override
  CartProductListState createState() => CartProductListState();
}

class CartProductListState extends State<CartProductList> {
  ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var product in cart.products)
            CartProductListTile(
              value: product.isSelected,
              selected: product.isSelected,
              onChanged: (bool? checked) => _handleSelected(checked, product),
              onTap: () {
                cart.toggleAll(false);
                _handleSelected(true, product);
              },
              title: Text(
                product.product.name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: product.ingredients.isEmpty
                  ? null
                  : MetaBlock.withString(context, product.ingredientNames),
              trailing: _ProductCountAction(product: product),
            )
        ],
      ),
    );
  }

  void _handleSelected(bool? checked, OrderProductModel product) {
    if (checked != null && product.toggleSelected(checked)) {
      setState(() {});
    }
  }

  Future<void> scrollToBottom() {
    return scrollController!.animateTo(
      scrollController!.position.maxScrollExtent + 80,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }
}

class _ProductCountAction extends StatefulWidget {
  _ProductCountAction({
    Key? key,
    required this.product,
  }) : super(key: key);

  final OrderProductModel? product;

  @override
  _ProductCountActionState createState() => _ProductCountActionState();
}

class _ProductCountActionState extends State<_ProductCountAction> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(widget.product!.count.toString()),
        IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: () => setState(() => widget.product!.increment()),
        ),
        Text('${widget.product!.price} 元'),
      ],
    );
  }
}

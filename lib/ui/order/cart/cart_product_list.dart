import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_repo.dart';
import 'package:provider/provider.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key key}) : super(key: key);

  @override
  CartProductListState createState() => CartProductListState();
}

class CartProductListState extends State<CartProductList> {
  ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<CartRepo>().products;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var item in products)
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: item.isSelected,
              selected: item.isSelected,
              selectedTileColor: Theme.of(context).primaryColorLight,
              onChanged: (bool checked) => onSelected(checked, item),
              title: Text(
                item.product.name,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: item.ingredients.isEmpty
                  ? null
                  : MetaBlock.withString(context, item.ingredientNames),
              secondary: _ProductQuantityAction(product: item),
            )
        ],
      ),
    );
  }

  void onSelected(bool checked, OrderProductModel product) {
    if (product.toggleSelected(checked)) {
      setState(() {});
    }
  }

  Future<void> scrollToBottom() {
    return scrollController.animateTo(
      scrollController.position.maxScrollExtent + 80,
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

class _ProductQuantityAction extends StatefulWidget {
  _ProductQuantityAction({
    Key key,
    @required this.product,
  }) : super(key: key);

  final OrderProductModel product;

  @override
  _ProductQuantityActionState createState() => _ProductQuantityActionState();
}

class _ProductQuantityActionState extends State<_ProductQuantityAction> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(widget.product.count.toString()),
        IconButton(
          icon: Icon(Icons.add_circle_outline_sharp),
          onPressed: () => setState(() => widget.product.increment()),
        ),
        Text('${widget.product.price} 元'),
      ],
    );
  }
}

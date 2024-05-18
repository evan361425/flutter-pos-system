import 'package:flutter/material.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartProductStateSelector extends StatefulWidget {
  const CartProductStateSelector({super.key});

  @override
  State<CartProductStateSelector> createState() => _CartProductStateSelectorState();
}

class _CartProductStateSelectorState extends State<CartProductStateSelector> {
  late _Status status;
  CartProduct? product;
  late ProductIngredient ingredient;
  String? quantityId;

  @override
  Widget build(BuildContext context) {
    if (_Status.allowChoose != status) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SingleRowWrap(
          key: Key('order.ingredient.${status.name}'),
          color: Colors.transparent,
          children: <Widget>[
            ChoiceChip(
              selected: false,
              label: Text(S.orderCartIngredientStatus(status.name)),
            ),
          ],
        ),
        SingleRowWrap(
          color: Colors.transparent,
          children: <Widget>[
            ChoiceChip(
              selected: false,
              label: Text(S.orderCartQuantityNotAble),
            ),
          ],
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        SingleRowWrap(
          color: Colors.transparent,
          children: <Widget>[
            for (final item in product!.product.items)
              ChoiceChip(
                key: Key('order.ingredient.${item.id}'),
                selected: ingredient.id == item.id,
                onSelected: (selected) {
                  setState(() {
                    ingredient = item;
                    quantityId = product!.getQuantityId(item.id);
                  });
                },
                label: Text(item.name),
              ),
          ],
        ),
        SingleRowWrap(
          color: Colors.transparent,
          children: <Widget>[
            ChoiceChip(
              key: const Key('order.quantity.default'),
              onSelected: (_) => _changeQuantity(null),
              selected: quantityId == null,
              label: Text(S.orderCartQuantityDefaultLabel(ingredient.amount)),
            ),
            for (final q in ingredient.items)
              ChoiceChip(
                key: Key('order.quantity.${q.id}'),
                onSelected: (_) => _changeQuantity(q.id),
                selected: quantityId == q.id,
                label: Text(S.orderCartQuantityLabel(q.name, q.amount)),
              ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _changeProduct(Cart.instance.selectedProduct.value);
    Cart.instance.selectedProduct.addListener(_productChanged);
  }

  @override
  void dispose() {
    Cart.instance.selectedProduct.removeListener(_productChanged);
    super.dispose();
  }

  void _productChanged() {
    if (mounted) {
      setState(() {
        _changeProduct(Cart.instance.selectedProduct.value);
      });
    }
  }

  void _changeProduct(CartProduct? p) {
    product = p;
    if (p == null) {
      status = Cart.instance.isEmpty ? _Status.emptyCart : _Status.differentProducts;
      return;
    } else if (p.product.isEmpty) {
      status = _Status.noNeedIngredient;
      return;
    }

    status = _Status.allowChoose;
    ingredient = p.product.items.first;
    quantityId = product!.getQuantityId(ingredient.id);
  }

  void _changeQuantity(String? quantityId) {
    for (var product in Cart.instance.selected) {
      product.selectQuantity(ingredient.id, quantityId);
    }

    Cart.instance.priceChanged();
    setState(() => this.quantityId = quantityId);
  }
}

enum _Status {
  emptyCart,
  differentProducts,
  noNeedIngredient,
  allowChoose,
}

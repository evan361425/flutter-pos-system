import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key? key}) : super(key: key);

  @override
  CartProductListState createState() => CartProductListState();
}

class CartProductListState extends State<CartProductList> {
  ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var product in cart.products)
            _CartProductListTile(
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

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  Future<void> scrollToBottom() {
    return scrollController!.animateTo(
      scrollController!.position.maxScrollExtent + 80,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSelected(bool? checked, OrderProduct product) {
    if (checked != null && product.toggleSelected(checked)) {
      setState(() {});
    }
  }
}

class _CartProductListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool selected;

  const _CartProductListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget leading = Checkbox(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final theme = Theme.of(context);

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: theme.textTheme.bodyText1!.color,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
          selected: selected,
          selectedTileColor: theme.primaryColorLight,
        ),
      ),
    );
  }
}

class _ProductCountAction extends StatefulWidget {
  final OrderProduct product;

  _ProductCountAction({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ProductCountActionState createState() => _ProductCountActionState();
}

class _ProductCountActionState extends State<_ProductCountAction> {
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
        Text(tt('order.list.price', {'price': widget.product.price})),
      ],
    );
  }
}

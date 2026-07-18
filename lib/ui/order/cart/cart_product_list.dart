import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_quantity_swipe.dart';
import 'package:possystem/ui/order/cart/order_line_note_sheet.dart';
import 'package:provider/provider.dart';

class CartProductList extends StatefulWidget {
  final ScrollController? scrollController;

  final ValueNotifier<bool>? scrollable;

  const CartProductList({super.key, this.scrollController, this.scrollable});

  @override
  State<CartProductList> createState() => _CartProductListState();
}

class _CartProductListState extends State<CartProductList> {
  late ScrollController scrollController;
  late final ValueNotifier<bool> scrollable;
  int lastLength = 0;

  @override
  Widget build(BuildContext context) {
    // if product length changed, rebuild it.
    final length = context.select<Cart, int>((cart) => cart.products.length);

    return ValueListenableBuilder(
      valueListenable: scrollable,
      builder: (context, value, child) {
        return ListView(
          key: const Key('cart.product_list'),
          controller: scrollController,
          physics: value ? null : const NeverScrollableScrollPhysics(),
          prototypeItem: const ListTile(title: Text('a'), subtitle: Text('a')),
          semanticChildCount: length,
          children: [
            if (length == 0)
              ListTile(
                title: Center(child: HintText(S.orderCartSnapshotEmpty)),
                subtitle: const Text(''),
              ),
            for (var i = 0; i < length; i++)
              CartQuantitySwipe(
                key: ObjectKey(Cart.instance.products[i]),
                index: i,
                child: ChangeNotifierProvider<CartProduct>.value(
                  value: Cart.instance.products[i],
                  child: _CartProductListTile(i),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    Cart.instance.removeListener(scrollToBottomIfAdded);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollable = widget.scrollable ?? ValueNotifier<bool>(true);
    scrollController = widget.scrollController ?? ScrollController();
    Cart.instance.addListener(scrollToBottomIfAdded);
  }

  Future<void> scrollToBottomIfAdded() async {
    final length = Cart.instance.products.length;
    final isAdded = lastLength < length;

    if (isAdded && mounted && lastLength != 0 || length != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent - 30, // +80?
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    lastLength = length;
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
      materialTapTargetSize: .shrinkWrap,
    );

    final trailing = Wrap(
      crossAxisAlignment: .center,
      children: <Widget>[
        Text(product.count.toString(), key: Key('cart.product.$index.count')),
        IconButton(
          key: Key('cart.product.$index.add'),
          icon: const Icon(KIcons.entryAdd),
          tooltip: S.orderCartProductIncrease,
          onPressed: () {
            product.increment();
            Cart.instance.priceChanged();
          },
        ),
        Text(
          S.orderCartProductPrice(product.totalPrice.toCurrency()),
          key: Key('cart.product.$index.price'),
        ),
      ],
    );

    final subtitleParts = <String>[
      ...product.quantities.map(
        (e) => S.orderCartProductIngredient(e.ingredient.name, e.name),
      ),
      if (product.note.trim().isNotEmpty) product.note.trim(),
    ];

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: DefaultTextStyle.of(context).style.color,
        child: ColoredBox(
          color: color,
          child: ListTile(
            key: Key('cart.product.$index'),
            leading: leading,
            title: Text(product.name, overflow: .ellipsis),
            subtitle: subtitleParts.isEmpty
                ? HintText(S.orderCartProductDefaultQuantity)
                : MetaBlock.withString(
                    context,
                    subtitleParts,
                    textOverflow: .visible,
                  )!,
            trailing: trailing,
            onTap: () => Cart.instance.toggleAll(false, except: product),
            onLongPress: () => OrderLineNoteSheet.show(context, product),
            selected: product.isSelected,
            selectedTileColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

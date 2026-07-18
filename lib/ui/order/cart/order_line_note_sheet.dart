import 'package:flutter/material.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

/// Lightweight bottom sheet to edit a single cart line kitchen note.
class OrderLineNoteSheet extends StatefulWidget {
  final CartProduct product;

  const OrderLineNoteSheet({super.key, required this.product});

  /// Opens the sheet focused on [product]'s note field.
  static Future<void> show(BuildContext context, CartProduct product) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => OrderLineNoteSheet(product: product),
    );
  }

  @override
  State<OrderLineNoteSheet> createState() => _OrderLineNoteSheetState();
}

class _OrderLineNoteSheetState extends State<OrderLineNoteSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.product.note);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    Cart.instance.updateProductNote(widget.product, _controller.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: bottomInset + 16,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Text(
            S.orderCartProductNoteTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: .ellipsis,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('cart.product.note.field'),
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: .done,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: S.orderCartProductNoteHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('cart.product.note.save'),
            onPressed: _save,
            child: Text(S.orderCartProductNoteSave),
          ),
        ],
      ),
    );
  }
}

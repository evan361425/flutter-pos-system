import 'package:flutter/material.dart';
import 'package:possystem/helper/custom_styles.dart';

class MetaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: const Text('•'),
    );
  }

  static TextSpan span() {
    return const TextSpan(text: ' • ');
  }

  static Widget withString(BuildContext context, Iterable<String> data,
      [String emptyText, TextStyle style]) {
    if (data.isNotEmpty) {
      final children = <InlineSpan>[];
      data.forEach((value) {
        children.add(TextSpan(text: value));
        children.add(MetaBlock.span());
      });
      // remove last block
      children.removeLast();
      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: children,
          style: style,
        ),
      );
    } else if (emptyText != null) {
      return RichText(
        text: TextSpan(
          text: emptyText,
          style: Theme.of(context).textTheme.muted,
        ),
      );
    } else {
      return null;
    }
  }
}

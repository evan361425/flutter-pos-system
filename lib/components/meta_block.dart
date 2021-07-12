import 'package:flutter/material.dart';
import 'package:possystem/components/style/custom_styles.dart';

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

  static Widget? withString(
    BuildContext context,
    Iterable<String> data, {
    TextStyle? textStyle,
    String? emptyText,
  }) {
    if (data.isNotEmpty) {
      final children = data
          .expand((value) => [
                TextSpan(text: value),
                MetaBlock.span(),
              ])
          .toList();
      // remove last block
      children.removeLast();

      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: children,
          // disable parent text style
          style: textStyle ?? Theme.of(context).textTheme.bodyText1,
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

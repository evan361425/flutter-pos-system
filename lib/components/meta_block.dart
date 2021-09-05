import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';

class MetaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: const Text('•'),
    );
  }

  static TextSpan span() {
    return const TextSpan(text: string);
  }

  static const string = ' • ';

  static Widget? withString(
    BuildContext context,
    Iterable<String> data, {
    TextStyle? textStyle,
    String? emptyText,
    TextOverflow textOverflow = TextOverflow.ellipsis,
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
        overflow: textOverflow,
        text: TextSpan(
          children: children,
          // disable parent text style
          style: textStyle ?? Theme.of(context).textTheme.bodyText1,
        ),
      );
    } else if (emptyText != null) {
      return RichText(text: HintText.inSpan(context, emptyText));
    } else {
      return null;
    }
  }
}

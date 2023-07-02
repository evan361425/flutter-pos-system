import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';

class MetaBlock {
  static TextSpan span() {
    return const TextSpan(text: string);
  }

  static const string = '  •  ';

  /// Divide strings with [MetaBlock]
  ///
  /// return null if [emptyText] is not provided and [data] is empty
  static Widget? withString(
    BuildContext context,
    Iterable<String> data, {
    TextStyle? textStyle,
    String? emptyText,
    int? maxLines,
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
        maxLines: maxLines,
        text: TextSpan(
          children: children,
          // disable parent text style
          style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else if (emptyText != null) {
      return RichText(text: HintText.inSpan(context, emptyText));
    } else {
      return null;
    }
  }
}

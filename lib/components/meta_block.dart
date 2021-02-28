import 'package:flutter/material.dart';

class MetaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Text('•'),
    );
  }

  static TextSpan span() {
    return TextSpan(text: ' • ');
  }

  static Widget withString(Iterable<String> data, BuildContext context) {
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
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }

    return null;
  }
}

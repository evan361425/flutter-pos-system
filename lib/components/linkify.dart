import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final _regex = RegExp(r'\[(.+)\]\((https?:\/\/.*)\)');

Iterable<_Data> _parseText(String text) sync* {
  do {
    final match = _regex.firstMatch(text);
    if (match == null) {
      yield _Data(text);
      break;
    }

    yield _Data(text.substring(0, match.start));
    yield _Data(match.group(0)!, match.group(1));
    text = text.substring(match.end);
  } while (text.isNotEmpty);
}

class Linkify extends StatelessWidget {
  final Iterable<_Data> data;

  final void Function(String) onOpen;

  Linkify(String text, {Key? key, required this.onOpen})
      : data = _parseText(text),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyTheme = Theme.of(context).textTheme.bodyText2;
    final linkStyle = bodyTheme?.copyWith(
      color: Colors.blueAccent,
      decoration: TextDecoration.underline,
    );

    return SelectableText.rich(TextSpan(
      children: data
          .map<InlineSpan>(
            (element) => element.linkable
                ? TextSpan(
                    text: element.text,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => onOpen(element.link!),
                  )
                : TextSpan(
                    text: element.text,
                    style: bodyTheme,
                  ),
          )
          .toList(),
    ));
  }
}

class _Data {
  final String text;

  final String? link;

  const _Data(this.text, [this.link]);

  bool get linkable => link == null;
}

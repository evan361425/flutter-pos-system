import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final _regex = RegExp(r'\[([^\]]+)\]\((https?:\/\/[^\)]+)\)');

Iterable<_Data> _parseText(String text) sync* {
  do {
    final match = _regex.firstMatch(text);
    if (match == null) {
      yield _Data(text);
      break;
    }

    yield _Data(text.substring(0, match.start));
    yield _Data(match.group(1)!, match.group(2));
    text = text.substring(match.end);
  } while (text.isNotEmpty);
}

class Linkify extends StatelessWidget {
  final Iterable<_Data> data;

  final TextAlign? textAlign;

  Linkify(String text, {Key? key, this.textAlign})
      : data = _parseText(text),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyTheme = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = bodyTheme?.copyWith(
      color: Colors.blueAccent,
      decoration: TextDecoration.underline,
    );

    return SelectableText.rich(
      TextSpan(
        children: data
            .map<InlineSpan>(
              (element) => element.linkable
                  ? TextSpan(
                      text: element.text,
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launch(element.link!).ignore(),
                    )
                  : TextSpan(
                      text: element.text,
                      style: bodyTheme,
                    ),
            )
            .toList(),
      ),
      textAlign: textAlign,
    );
  }
}

class _Data {
  final String text;

  final String? link;

  const _Data(this.text, [this.link]);

  bool get linkable => link != null;
}

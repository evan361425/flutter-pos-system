import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/launcher.dart';

final _regex = RegExp(r'\[([^\]]+)\]\((https?:\/\/[^\)]+)\)');

class Linkify extends StatelessWidget {
  final Iterable<LinkifyData> data;

  final TextAlign? textAlign;

  const Linkify(this.data, {Key? key, this.textAlign}) : super(key: key);

  factory Linkify.fromString(text, {TextAlign? textAlign}) {
    return Linkify(_parseText(text), textAlign: textAlign);
  }

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
                        ..onTap = () => Launcher.launch(element.link!).ignore(),
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

class LinkifyData {
  final String text;

  final String? link;

  const LinkifyData(this.text, [this.link]);

  bool get linkable => link != null;
}

Iterable<LinkifyData> _parseText(String text) sync* {
  do {
    final match = _regex.firstMatch(text);
    if (match == null) {
      yield LinkifyData(text);
      break;
    }

    yield LinkifyData(text.substring(0, match.start));
    yield LinkifyData(match.group(1)!, match.group(2));
    text = text.substring(match.end);
  } while (text.isNotEmpty);
}

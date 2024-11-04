import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/launcher.dart';

final _regex = RegExp(r'\[([^\]]+)\]\((https?:\/\/|mailto:)([^\)]+)\)');

class Linkify extends StatelessWidget {
  final Iterable<LinkifyData> data;

  final TextAlign? textAlign;

  const Linkify(this.data, {super.key, this.textAlign});

  /// Not sure why need nullable text, since I got error in production
  ///
  /// Issue ID: 9e4fa89521982197e4212f2c0b1ee6b4
  /// ```txt
  /// type 'Null' is not a subtype of type 'String'. Error thrown .
  ///   at new Linkify.fromString(linkify.dart:15)
  ///   at Tutorial.build(tutorial.dart:107)
  /// ```
  factory Linkify.fromString(String text, {TextAlign? textAlign}) {
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
                      recognizer: TapGestureRecognizer()..onTap = element.launch,
                    )
                  : TextSpan(text: element.text),
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

  void launch() => Launcher.launch(link!).ignore();
}

Iterable<LinkifyData> _parseText(String text) sync* {
  do {
    final match = _regex.firstMatch(text);
    if (match == null) {
      yield LinkifyData(text);
      break;
    }

    yield LinkifyData(text.substring(0, match.start));
    yield LinkifyData(match.group(1)!, match.group(2)! + match.group(3)!);
    text = text.substring(match.end);
  } while (text.isNotEmpty);
}

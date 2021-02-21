import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    Key key,
    @required this.text,
    @required this.iconName,
    this.iconColor,
  }) : super(key: key);

  final String text;
  final String iconName;
  final String iconColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText1,
        children: [
          TextSpan(
            text: iconName,
            style: TextStyle(
              fontFamily: 'MaterialIcons',
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
          ),
          TextSpan(
            text: text,
          )
        ],
      ),
    );
  }
}

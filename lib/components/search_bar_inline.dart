import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatelessWidget {
  const SearchBarInline({
    Key key,
    @required this.heroTag,
    this.text,
    this.errorText,
    this.hintText,
    this.helperText,
    @required this.onTap,
  }) : super(key: key);

  final String heroTag;
  final String text;
  final String errorText;
  final String hintText;
  final String helperText;
  final Future<void> Function(BuildContext) onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      // transitionOnUserGestures: true,
      child: TextFormField(
        readOnly: true,
        initialValue: text,
        onTap: () => onTap(context),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(KIcons.search),
        ),
      ),
    );
  }
}

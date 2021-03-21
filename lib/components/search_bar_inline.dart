import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class SearchBarInline extends StatelessWidget {
  const SearchBarInline({
    Key key,
    @required this.heroTag,
    this.text,
    this.hintText,
    this.helperText,
    @required this.newPageBuilder,
  }) : super(key: key);

  final String heroTag;
  final String text;
  final String hintText;
  final String helperText;
  final Widget Function(BuildContext) newPageBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPadding),
      child: Hero(
        tag: heroTag,
        child: TextFormField(
          readOnly: true,
          initialValue: text,
          onTap: () => Navigator.of(context).push(CupertinoPageRoute(
            builder: newPageBuilder,
          )),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

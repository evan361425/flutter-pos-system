import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class SearchBar extends StatelessWidget {
  SearchBar({
    Key key,
    @required this.onChanged,
    this.hintText = '',
    String text = '',
  }) : super(key: key) {
    controller.text = text;
  }

  final String hintText;
  final void Function(String) onChanged;
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPadding),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: hintText,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

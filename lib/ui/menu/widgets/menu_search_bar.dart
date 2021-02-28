import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class MenuSearchBar extends StatelessWidget {
  const MenuSearchBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPadding),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: '搜尋種類、產品、成分',
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

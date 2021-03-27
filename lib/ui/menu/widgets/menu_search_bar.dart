import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';

class MenuSearchBar extends StatelessWidget {
  const MenuSearchBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kPadding),
      child: SearchBarInline(
        heroTag: 'hi',
        onTap: (BuildContext context) => Future.delayed(Duration.zero),
        hintText: '搜尋種類、產品、成份',
      ),
    );
  }

  void onChanged(String text) {
    debugPrint(text);
  }
}

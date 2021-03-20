import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar.dart';

class MenuSearchBar extends StatelessWidget {
  const MenuSearchBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchBar(onChanged: onChanged, hintText: '搜尋種類、產品、成份');
  }

  void onChanged(String text) {
    debugPrint(text);
  }
}

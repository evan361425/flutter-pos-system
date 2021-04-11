import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class ChartProductList extends StatefulWidget {
  const ChartProductList({Key key}) : super(key: key);

  @override
  _ChartProductListState createState() => _ChartProductListState();
}

class _ChartProductListState extends State<ChartProductList> {
  final items = {'a': false, 'b': true, 'c': false, 'd': true};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: listTiles,
      ),
    );
  }

  List<CheckboxListTile> get listTiles {
    final result = <CheckboxListTile>[];

    items.forEach((id, isChecked) {
      result.add(CheckboxListTile(
        value: isChecked,
        onChanged: (bool value) {
          setState(() => items[id] = value);
        },
        title: Text(id),
        secondary: IconButton(
          icon: Icon(KIcons.add),
          onPressed: () {},
        ),
      ));
    });

    return result;
  }
}

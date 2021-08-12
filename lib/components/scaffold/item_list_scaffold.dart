import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/pop_button.dart';

class ItemListScaffold extends StatelessWidget {
  final String title;

  final List<String> items;

  final int selected;

  const ItemListScaffold({
    Key? key,
    required this.title,
    required this.items,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: PopButton(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return CardTile(
            title: Text(items[index]),
            trailing: selected == index ? Icon(Icons.check_sharp) : null,
            onTap: () {
              if (selected != index) {
                Navigator.of(context).pop(index);
              }
            },
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/pop_button.dart';

class ItemListScaffold extends StatelessWidget {
  final String title;

  final List<String> items;

  /// It will use hint color
  final List<String?>? tips;

  final int selected;

  const ItemListScaffold({
    Key? key,
    required this.title,
    required this.items,
    required this.selected,
    this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(color: Theme.of(context).hintColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: const PopButton(),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (tips != null) {
            tips![index];
          }
          return CardTile(
            title: Text(items[index]),
            trailing: selected == index ? const Icon(Icons.check_sharp) : null,
            subtitle: tips != null && tips![index] != null
                ? Text(tips![index]!, style: hintStyle)
                : null,
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

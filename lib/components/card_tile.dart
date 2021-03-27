import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  const CardTile({Key key, this.title, this.onTap}) : super(key: key);

  final Widget title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: EdgeInsets.all(0),
      child: ListTile(
        title: title,
        onTap: onTap,
      ),
    );
  }
}

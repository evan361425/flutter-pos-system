import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CardTile({
    Key? key,
    this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0),
      child: ListTile(
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}

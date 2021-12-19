import 'package:flutter/material.dart';

class CardTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const CardTile({
    Key? key,
    this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0),
      child: ListTile(
        title: title,
        leading: leading,
        subtitle: subtitle,
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}

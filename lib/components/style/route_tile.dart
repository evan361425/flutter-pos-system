import 'package:flutter/material.dart';

class RouteTile extends StatelessWidget {
  final IconData icon;

  final String title;

  final String route;

  const RouteTile({
    Key? key,
    required this.icon,
    required this.route,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6;

    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20)],
      ),
      trailing: const Icon(Icons.navigate_next_outlined),
      onTap: () => Navigator.of(context).pushNamed(route),
      minLeadingWidth: 20,
      title: Text(title, style: style),
    );
  }
}

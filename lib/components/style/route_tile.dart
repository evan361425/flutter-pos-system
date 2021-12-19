import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';

class RouteTile extends StatelessWidget {
  final IconData icon;

  final String title;

  final String route;

  final String? Function()? preCheck;

  final bool popTrueShowSuccess;

  const RouteTile({
    Key? key,
    required this.icon,
    required this.route,
    required this.title,
    this.preCheck,
    this.popTrueShowSuccess = false,
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
      onTap: () async {
        if (preCheck != null) {
          final warnMessage = preCheck!();
          if (warnMessage != null) {
            return showInfoSnackbar(context, warnMessage);
          }
        }

        final result = await Navigator.of(context).pushNamed(route);

        if (result == true) {
          showSuccessSnackbar(context, S.actSuccess);
        }
      },
      minLeadingWidth: 20,
      title: Text(title, style: style),
    );
  }
}

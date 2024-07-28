import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/translator.dart';

class RouteElevatedIconButton extends StatelessWidget {
  final Icon icon;

  final String? route;

  final String label;

  final bool popTrueShowSuccess;

  const RouteElevatedIconButton({
    super.key,
    required this.icon,
    required this.route,
    required this.label,
    this.popTrueShowSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(label),
      onPressed: () async {
        final result = await context.pushNamed(route!);
        if (result == true && popTrueShowSuccess) {
          if (context.mounted) {
            showSnackBar(context, S.actSuccess);
          }
        }
      },
    );
  }
}

class RouteIconButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final String? route;
  final VoidCallback? onPressed;
  final bool popTrueShowSuccess;

  const RouteIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.route,
    this.onPressed,
    this.popTrueShowSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final bp = Breakpoint.find(width: MediaQuery.sizeOf(context).width);
    final iconWithLabel = bp <= Breakpoint.medium
        ? icon
        : Row(children: [
            icon,
            const SizedBox(width: 4),
            Text(tooltip),
          ]);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed ??
          () async {
            final result = await context.pushNamed(route!);
            if (result == true && popTrueShowSuccess) {
              if (context.mounted) {
                showSnackBar(context, S.actSuccess);
              }
            }
          },
      icon: iconWithLabel,
    );
  }
}

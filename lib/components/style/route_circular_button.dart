import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';

class RouteCircularButton extends StatelessWidget {
  final String text;

  final IconData icon;

  final String? route;

  final bool popTrueShowSuccess;

  final VoidCallback? onTap;

  const RouteCircularButton({
    Key? key,
    required this.text,
    required this.icon,
    this.route,
    this.popTrueShowSuccess = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(48)),
      splashColor: Colors.transparent,
      onTap: onTap ??
          () async {
            final result = await context.pushNamed(route!);
            if (result == true) {
              if (context.mounted) {
                showSnackBar(context, S.actSuccess);
              }
            }
          },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 96, maxWidth: 96),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 4),
              Text(text, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

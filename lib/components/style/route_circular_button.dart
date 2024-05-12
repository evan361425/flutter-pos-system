import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';

class RouteCircularButton extends StatelessWidget {
  final String text;

  final IconData icon;

  final String? route;

  final Map<String, String> routePathParameters;

  final bool popTrueShowSuccess;

  final VoidCallback? onTap;

  const RouteCircularButton({
    super.key,
    required this.text,
    required this.icon,
    this.route,
    this.routePathParameters = const <String, String>{},
    this.popTrueShowSuccess = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text, // text will be ellipsis, so show full text in tooltip
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
              maximumSize: const Size(96, 96),
            ),
            onPressed: onTap ??
                () async {
                  final result = await context.pushNamed(
                    route!,
                    pathParameters: routePathParameters,
                  );
                  if (result == true) {
                    if (context.mounted) {
                      showSnackBar(context, S.actSuccess);
                    }
                  }
                },
            child: Icon(icon, size: 32),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

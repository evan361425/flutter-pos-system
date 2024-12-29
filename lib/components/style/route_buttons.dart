import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/translator.dart';

class RouteElevatedIconButton extends StatelessWidget {
  final Icon icon;

  final String label;

  final String? route;

  final Map<String, String> pathParameters;

  final Map<String, String> queryParameters;

  const RouteElevatedIconButton({
    super.key,
    required this.icon,
    required this.route,
    required this.label,
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(label),
      onPressed: () => context.pushNamed(
        route!,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
    );
  }
}

class RouteIconButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final String? route;
  final Map<String, String> pathParameters;
  final VoidCallback? onPressed;
  final bool popTrueShowSuccess;
  final bool hideLabel;

  const RouteIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.route,
    this.pathParameters = const {},
    this.onPressed,
    this.popTrueShowSuccess = false,
    this.hideLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: hideLabel ? label : null,
      onPressed: onPressed ??
          () async {
            final result = await context.pushNamed(route!, pathParameters: pathParameters);
            if (result == true && popTrueShowSuccess) {
              if (context.mounted) {
                showSnackBar(S.actSuccess, context: context);
              }
            }
          },
      icon: _buildIcon(context),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (hideLabel) {
      return icon;
    }

    final bp = Breakpoint.find(width: MediaQuery.sizeOf(context).width);
    return bp <= Breakpoint.medium
        ? Column(spacing: 4, children: [
            icon,
            Text(label),
          ])
        : Row(spacing: 4, children: [
            icon,
            Text(label),
          ]);
  }
}

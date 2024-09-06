import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/translator.dart';

class EmptyBody extends StatelessWidget {
  /// title of the empty body, default: Oops! It's empty here.
  final String? title;

  /// content of the empty body
  final String? content;

  /// navigate to the route when the button is pressed, either this or [onPressed] must be provided
  final String? routeName;

  /// path parameters for the route
  final Map<String, String> pathParameters;

  final VoidCallback? onPressed;

  const EmptyBody({
    super.key,
    this.title,
    this.content,
    this.routeName,
    this.pathParameters = const <String, String>{},
    this.onPressed,
  }) : assert(routeName != null || onPressed != null, 'Either routeName or onPressed must be provided');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title ?? S.emptyBodyTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8.0, 16.0, 8.0),
              child: Text(content!),
            ),
          TextButton(
            key: const Key('empty_body'),
            onPressed: onPressed ?? () => context.pushNamed(routeName!, pathParameters: pathParameters),
            child: Text(S.emptyBodyAction),
          ),
        ],
      ),
    );
  }
}

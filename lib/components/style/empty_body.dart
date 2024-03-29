import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';

class EmptyBody extends StatelessWidget {
  final VoidCallback onPressed;

  final String? title;

  final String? helperText;

  const EmptyBody({
    super.key,
    this.title,
    required this.onPressed,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title ?? S.emptyBodyContent,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(helperText!, textAlign: TextAlign.center),
            ),
          TextButton(
            key: const Key('empty_body'),
            onPressed: onPressed,
            child: const Text('立即設定'),
          ),
        ],
      ),
    );
  }
}

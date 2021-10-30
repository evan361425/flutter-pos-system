import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';

class EmptyBody extends StatelessWidget {
  final VoidCallback onPressed;

  final String? title;

  const EmptyBody({Key? key, this.title, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title ?? tt('empty_body'),
            style: Theme.of(context).textTheme.headline6,
          ),
          OutlinedButton(
            key: const Key('empty_body'),
            onPressed: onPressed,
            child: const Text('立即設定'),
          ),
        ],
      ),
    );
  }
}

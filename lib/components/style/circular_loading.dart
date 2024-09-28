import 'package:flutter/material.dart';

class CircularLoading extends StatelessWidget {
  const CircularLoading({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size ?? 20,
        width: size ?? 20,
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
    );
  }
}

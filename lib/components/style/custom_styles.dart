import 'package:flutter/material.dart';

extension CustomStyles on TextTheme {
  TextStyle get muted => const TextStyle(
        fontSize: 12.0,
        inherit: true,
        color: Colors.grey,
      );
}

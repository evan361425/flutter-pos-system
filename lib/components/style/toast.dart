import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as base;

class Toast {
  static void show(BuildContext context, String message) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(width: 1.0, color: Colors.white),
        color: const Color(0xFF303030),
      ),
      child: Text(message, style: TextStyle(color: Colors.white)),
    );

    base.FToast()
      ..init(context)
      ..showToast(child: child);
  }
}

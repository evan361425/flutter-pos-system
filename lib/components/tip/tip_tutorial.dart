import 'package:flutter/material.dart';
import 'package:simple_tip/simple_tip.dart';

import 'cache_state_manager.dart';

class TipTutorial extends StatefulWidget {
  final Widget child;

  final String label;

  final String message;

  final String? title;

  final int version;

  final bool disabled;

  const TipTutorial({
    required this.label,
    this.version = 1,
    required this.message,
    this.title,
    required this.child,
    this.disabled = false,
  });

  bool get isDisabled =>
      disabled || !CacheStateManager.instance.shouldShowRaw(label, version);

  @override
  _TipTutorialState createState() => _TipTutorialState();
}

class _TipTutorialState extends State<TipTutorial> {
  late bool isDisbaled;

  @override
  void initState() {
    super.initState();
    isDisbaled = widget.isDisabled;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleTip(
      title: widget.title,
      message: widget.message,
      isDisabled: isDisbaled,
      onClosed: () async {
        await CacheStateManager.instance
            .tipReadRaw(widget.label, widget.version);
        setState(() => isDisbaled = true);
      },
      child: widget.child,
    );
  }
}

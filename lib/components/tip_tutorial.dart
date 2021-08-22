import 'package:flutter/material.dart';
import 'package:possystem/components/tip.dart';
import 'package:possystem/services/cache.dart';

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

  bool get isDisabled => disabled || !Cache.instance.neededTip(label, version);

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
    return Tip(
      title: widget.title,
      message: widget.message,
      disabled: isDisbaled,
      onClosed: () {
        Cache.instance.tipRead(widget.label, widget.version);
        setState(() => isDisbaled = true);
      },
      child: widget.child,
    );
  }
}

import 'package:flutter/material.dart';

class FeatureSwitch extends StatefulWidget {
  final bool value;

  final Function(bool) onChanged;

  final bool autofocus;

  const FeatureSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<FeatureSwitch> createState() => _FeatureSwitchState();
}

class _FeatureSwitchState extends State<FeatureSwitch> {
  late bool isEnable;

  @override
  Widget build(BuildContext context) {
    return Switch(
        value: isEnable,
        autofocus: widget.autofocus,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() => isEnable = value);
        });
  }

  @override
  void initState() {
    isEnable = widget.value;
    super.initState();
  }
}

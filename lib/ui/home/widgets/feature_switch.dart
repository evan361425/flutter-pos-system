import 'package:flutter/material.dart';

class FeatureSwitch extends StatefulWidget {
  final bool value;

  final Function(bool) onChanged;

  const FeatureSwitch({
    super.key,
    required this.value,
    required this.onChanged,
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

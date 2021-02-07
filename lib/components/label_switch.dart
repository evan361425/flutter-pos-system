import 'package:flutter/material.dart';
import 'package:possystem/localizations.dart';

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    @required this.label,
    this.padding,
    this.tooltip,
    @required this.value,
    @required this.onChanged,
  });

  final String label;
  final String tooltip;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Local.of(context).t(tooltip ?? ''),
      child: InkWell(
        onTap: () {
          onChanged(!value);
        },
        child: Padding(
          padding: padding ?? EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Align(
                  child: Text(Local.of(context).t(label)),
                  alignment: Alignment.centerRight,
                ),
              ),
              Switch(
                value: value,
                onChanged: (bool newValue) {
                  onChanged(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

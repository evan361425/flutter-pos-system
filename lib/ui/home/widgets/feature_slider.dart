import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';

class FeatureSlider extends StatefulWidget {
  final String title;

  final int value;

  final int min;

  final int max;

  final Function(int) onChanged;

  final String? minLabel;

  final String? maxLabel;

  final String? hintText;

  final Key? sliderKey;

  final bool autofocus;

  const FeatureSlider({
    super.key,
    this.sliderKey,
    required this.title,
    required this.value,
    this.min = 0,
    required this.max,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<FeatureSlider> createState() => _FeatureSliderState();
}

class _FeatureSliderState extends State<FeatureSlider> {
  late int value;

  @override
  Widget build(BuildContext context) {
    final label = value == widget.min
        ? widget.minLabel
        : value == widget.max
            ? widget.maxLabel
            : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(widget.title, style: const TextStyle(fontSize: 16.0)),
      ),
      Slider(
        key: widget.sliderKey,
        autofocus: widget.autofocus,
        value: value.toDouble(),
        min: widget.min.toDouble(),
        max: widget.max.toDouble(),
        divisions: widget.max - widget.min,
        label: label ?? value.toString(),
        onChanged: (value) {
          setState(() => this.value = value.toInt());
        },
        onChangeEnd: (value) => widget.onChanged(value.toInt()),
      ),
      if (widget.hintText != null)
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: HintText(widget.hintText!),
          ),
        ),
    ]);
  }

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }
}

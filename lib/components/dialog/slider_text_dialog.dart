import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';

class SliderTextDialog extends StatefulWidget {
  final String? Function(String?)? validator;
  final Widget? title;
  final InputDecoration? decoration;
  final num value;
  final double min;
  final double max;
  final Widget Function(Widget child)? builder;

  const SliderTextDialog({
    super.key,
    required this.value,
    required this.max,
    this.builder,
    this.min = 0.0,
    this.validator,
    this.decoration,
    this.title,
  });

  @override
  State<SliderTextDialog> createState() => _SliderTextDialogState();
}

class _SliderTextDialogState extends State<SliderTextDialog> {
  late TextEditingController textController;
  late double sliderValue;
  late final double sliderMax;
  late final bool withSlider;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);

    return AlertDialog.adaptive(
      title: widget.title,
      content: Form(
        key: form,
        child: widget.builder?.call(textWithSlider) ?? textWithSlider,
      ),
      actions: [
        PopButton(
          key: const Key('slider_dialog.cancel'),
          title: local.cancelButtonLabel,
        ),
        FilledButton(
          key: const Key('slider_dialog.confirm'),
          onPressed: () => onSubmit(textController.text),
          child: Text(local.okButtonLabel),
        ),
      ],
    );
  }

  Widget get textWithSlider => SingleChildScrollView(
        child: Column(children: [
          TextFormField(
            key: const Key('slider_dialog.text'),
            controller: textController,
            onSaved: onSubmit,
            onFieldSubmitted: onSubmit,
            autofocus: !withSlider,
            keyboardType: TextInputType.number,
            validator: widget.validator,
            decoration: widget.decoration,
            textInputAction: TextInputAction.done,
          ),
          if (withSlider)
            Slider(
              value: sliderValue,
              max: sliderMax,
              min: widget.min,
              label: sliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  textController.text = value.round().toString();
                  sliderValue = value;
                });
              },
            ),
        ]),
      );

  void onSubmit(String? value) {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.value.toString());
    sliderValue = widget.value.toDouble();
    sliderMax = max(widget.max, sliderValue);
    withSlider = widget.max > 0;
    if (!withSlider) {
      textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textController.text.length,
      );
    }
  }
}

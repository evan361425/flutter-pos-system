import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

class SliderTextDialog extends StatefulWidget {
  const SliderTextDialog({
    Key? key,
    required this.value,
    required this.max,
    this.min = 0.0,
    this.validator,
    this.decoration,
    this.title,
  }) : super(key: key);

  final String? Function(String?)? validator;
  final Widget? title;
  final InputDecoration? decoration;
  final num value;
  final double min;
  final double max;

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
    final textField = TextFormField(
      key: const Key('slider_dialog.text'),
      controller: textController,
      onSaved: onSubmit,
      onFieldSubmitted: onSubmit,
      autofocus: !withSlider,
      keyboardType: TextInputType.number,
      validator: widget.validator,
      decoration: widget.decoration,
      textInputAction: TextInputAction.done,
    );

    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(children: [
            textField,
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
        ),
      ),
      actions: [
        PopButton(key: const Key('slider_dialog.cancel'), title: S.btnCancel),
        FilledButton(
          key: const Key('slider_dialog.confirm'),
          onPressed: () => onSubmit(textController.text),
          child: Text(S.btnConfirm),
        ),
      ],
    );
  }

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

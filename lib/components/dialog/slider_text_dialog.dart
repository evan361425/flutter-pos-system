import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/models/repository/stock.dart';

class SliderTextDialog extends StatefulWidget {
  final String? Function(String?)? validator;
  final Widget? title;
  final InputDecoration? decoration;
  final num value;
  final double min;
  final double max;
  final Widget Function(Widget child, void Function(String?) onSubmit)? builder;
  final ValueNotifier<String?>? currentValue;

  const SliderTextDialog({
    super.key,
    required this.value,
    required this.max,
    this.builder,
    this.min = 0.0,
    this.validator,
    this.decoration,
    this.title,
    this.currentValue,
  });

  @override
  State<SliderTextDialog> createState() => _SliderTextDialogState();
}

class _SliderTextDialogState extends State<SliderTextDialog> {
  late final TextEditingController textController;
  late double sliderValue;
  late final double sliderMax;
  late final bool withSlider;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);

    Widget child = buildTextWithSlider();
    if (widget.builder != null) {
      child = widget.builder!.call(child, onSubmit);
    }

    return AlertDialog.adaptive(
      title: widget.title,
      content: SingleChildScrollView(child: Form(key: form, child: child)),
      actions: [
        PopButton(
          key: const Key('slider_dialog.cancel'),
          title: local.cancelButtonLabel,
        ),
        FilledButton(
          key: const Key('slider_dialog.confirm'),
          onPressed: () {
            if (widget.currentValue != null) {
              onSubmit(widget.currentValue!.value);
            } else {
              onSubmit(textController.text);
            }
          },
          child: Text(local.okButtonLabel),
        ),
      ],
    );
  }

  Widget buildTextWithSlider() {
    return Column(children: [
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
    ]);
  }

  void onSubmit(String? value) {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.value.toAmountString());
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

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

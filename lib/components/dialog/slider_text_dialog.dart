import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/util.dart';

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
  late ValueNotifier<double> sliderValue;
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
      scrollable: true,
      content: Form(key: form, child: child),
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
    return ListenableBuilder(
      listenable: sliderValue,
      builder: (_, __) => Column(children: [
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
            value: sliderValue.value,
            max: sliderMax,
            min: widget.min,
            label: sliderValue.value.round().toString(),
            onChanged: (double value) {
              textController.text = value.round().toString();
              widget.currentValue?.value = textController.text;
              sliderValue.value = value;
            },
          ),
      ]),
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
    textController = TextEditingController(text: widget.value.toShortString());
    sliderValue = ValueNotifier(widget.value.toDouble());
    sliderMax = max(widget.max, sliderValue.value);
    withSlider = widget.max > 0;
    if (!withSlider) {
      textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textController.text.length,
      );
    }

    textController.addListener(() {
      widget.currentValue?.value = textController.text;
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

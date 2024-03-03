import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/card_info_text.dart';

class ChoiceChipWithHelp<T> extends StatefulWidget {
  final List<T> values;

  final T selected;

  final Iterable<String> labels;

  final List<String> helpTexts;

  const ChoiceChipWithHelp({
    super.key,
    required this.values,
    required this.selected,
    required this.labels,
    required this.helpTexts,
  });

  @override
  State<ChoiceChipWithHelp<T>> createState() => ChoiceChipWithHelpState<T>();
}

class ChoiceChipWithHelpState<T> extends State<ChoiceChipWithHelp<T>> {
  late T selected;

  late int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final li = widget.labels.iterator;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  for (var value in widget.values)
                    ChoiceChip(
                      key: Key('choice_chip.$value'),
                      selected: value == selected,
                      onSelected: (isSelected) {
                        if (isSelected) {
                          updateSelected(value);
                        }
                      },
                      label: Text(li.moveNext() ? li.current : ''),
                      tooltip: li.current,
                    ),
                ],
              ),
            ),
          ),
          CardInfoText(child: Text(widget.helpTexts[selectedIndex])),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateSelected(widget.selected);
  }

  updateSelected(T value) {
    setState(() => _updateSelected(value));
  }

  updateSelectedIndex(double delta) {
    if (delta > 10 || delta < -10) {
      setState(() {
        final d = delta > 0 ? -1 : 1;
        final m = widget.values.length - 1;

        selectedIndex = max(0, min(m, selectedIndex + d));
        selected = widget.values[selectedIndex];
      });
    }
  }

  _updateSelected(T value) {
    selected = value;
    selectedIndex = widget.values.indexOf(value);
  }
}

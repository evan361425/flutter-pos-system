import 'package:flutter/material.dart';

class ChoiceChipWithHelp<T> extends StatefulWidget {
  final List<T> values;

  final T selected;

  final Iterable<String> labels;

  final List<String> helpTexts;

  const ChoiceChipWithHelp({
    Key? key,
    required this.values,
    required this.selected,
    required this.labels,
    required this.helpTexts,
  }) : super(key: key);

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
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(widget.helpTexts[selectedIndex])),
              ),
            ),
          )
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

  _updateSelected(T value) {
    selected = value;
    selectedIndex = widget.values.indexOf(value);
  }
}

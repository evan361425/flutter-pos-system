import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

typedef DeepFunction = void Function(void Function());

class RadioText extends StatefulWidget {
  static final _groups = <String, _Item>{};

  final VoidCallback onSelected;
  final Widget child;
  final String groupId;
  final String value;

  RadioText({
    Key? key,
    required this.groupId,
    required this.onSelected,
    required this.value,
    required this.child,
    bool? isSelected,
  }) : super(key: key) {
    // if not set, initialize a new one
    if (_groups[groupId] == null) {
      _groups[groupId] = _Item(isSelected == false ? null : value);
    } else if (isSelected == true && !group.isSelect(value)) {
      // if specific setting, update previous one to unchecked
      group.select(value);
    }
  }
  _Item get group => _groups[groupId]!;

  bool get isSelected => group.isSelect(value);

  @override
  _RadioTextState createState() => _RadioTextState();

  void dispose() {
    group.removeElement(value);

    if (group.isEmpty) {
      _groups.remove(groupId);
    }
  }

  void select() {
    group.select(value);
    onSelected();
  }

  static void clearSelected(String groupId) {
    _groups[groupId]?.select(null);
  }
}

class _Item {
  String? _selected;

  final _elements = <String, DeepFunction>{};

  _Item(this._selected);

  bool get isEmpty => _elements.isEmpty;

  void addElement(String id, DeepFunction rebuilder) {
    _elements[id] = rebuilder;
  }

  bool isSelect(String value) => _selected == value;

  void removeElement(String id) => _elements.remove(id);

  void select(String? value) {
    _selected = value;
    _elements.values.forEach((rebuilder) {
      rebuilder(() {});
    });
  }
}

class _RadioTextState extends State<RadioText> {
  static final BORDER_COLOR = Colors.grey.withAlpha(100);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final defaultColor = widget.isSelected ? primaryColor : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: defaultColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: defaultColor, blurRadius: 2.0),
        ],
        border: Border.all(
          width: 1.0,
          color: widget.isSelected ? defaultColor : BORDER_COLOR,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: InkWell(
        onTap: () => widget.select(),
        splashColor: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(kSpacing1),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.group.addElement(widget.value, setState);
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

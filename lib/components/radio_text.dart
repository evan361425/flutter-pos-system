import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

typedef DeepFunction = void Function(void Function());

class RadioText extends StatefulWidget {
  static final _groups = <String, _Group>{};

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
      _groups[groupId] = _Group(isSelected == false ? null : value);
    } else if (isSelected == true && !group.isSelect(value)) {
      // if specific setting, update previous one to unchecked
      group.select(value);
    }
  }

  static Widget empty([String? text]) {
    if (text == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0 + kSpacing1),
        child: const Text(''),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0 + kSpacing1),
        child: Text(text),
      );
    }
  }

  _Group get group => _groups[groupId]!;

  bool get isSelected => group.isSelect(value);

  @override
  _RadioTextState createState() => _RadioTextState();

  void dispose() {
    group.removeItem(value);

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

class _Group {
  String? _selected;

  final _items = <String, DeepFunction>{};

  _Group(this._selected);

  bool get isEmpty => _items.isEmpty;

  void addItem(String id, DeepFunction rebuilder) {
    _items[id] = rebuilder;
  }

  bool isSelect(String value) => _selected == value;

  void removeItem(String id) => _items.remove(id);

  void select(String? value) {
    _selected = value;
    _items.values.forEach((rebuilder) {
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
    widget.group.addItem(widget.value, setState);
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

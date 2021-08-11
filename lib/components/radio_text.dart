import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class RadioText extends StatefulWidget {
  static final _groups = <String, _Group>{};

  final VoidCallback onSelected;

  final String text;

  final String groupId;

  final String value;

  RadioText({
    Key? key,
    required this.groupId,
    required this.onSelected,
    required this.value,
    required this.text,
    bool? isSelected,
  }) : super(key: key) {
    // if not set, initialize a new one
    if (_groups[groupId] == null) {
      _groups[groupId] = _Group(isSelected == false ? null : value);
    } else if (isSelected == true && !group.isSelect(value)) {
      // if specific setting, update previous one to unchecked
      group.select(value);
    } else if (isSelected == false && group.isSelect(value)) {
      group.unselect();
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

  static void clearAll() => _groups.clear();

  static void clearSelected(String groupId) {
    _groups[groupId]?.select(null);
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
}

class _Group {
  String? _selected;

  final _items = <String, void Function()>{};

  _Group(this._selected);

  bool get isEmpty => _items.isEmpty;

  void addItem(String id, void Function() rebuilder) {
    _items[id] = rebuilder;
  }

  bool isSelect(String value) => _selected == value;

  void removeItem(String id) => _items.remove(id);

  void select(String? value) {
    _selected = value;
    _items.values.forEach((rebuilder) => rebuilder());
  }

  void unselect() {
    _selected = null;
  }
}

class _RadioTextState extends State<RadioText> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final defaultColor = widget.isSelected ? primaryColor : Colors.transparent;
    final borderColor = primaryColor.withAlpha(128);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      constraints: BoxConstraints(minWidth: 64.0),
      decoration: BoxDecoration(
        color: defaultColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: defaultColor, blurRadius: 2.0),
        ],
        border: Border.all(
          width: 1.0,
          color: widget.isSelected ? defaultColor : borderColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
      ),
      child: InkWell(
        onTap: () => widget.select(),
        splashColor: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(kSpacing1),
          child: Text(widget.text, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  void initState() {
    widget.group.addItem(widget.value, () {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}

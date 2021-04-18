import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class RadioText extends StatefulWidget {
  RadioText({
    Key key,
    @required this.onSelected,
    @required this.child,
    @required this.groupId,
    @required this.value,
    bool isSelected,
  }) : super(key: key) {
    // if not set initial a new one
    if (group == null) {
      group = _Item(isSelected == null || isSelected ? value : null);
    } else if (isSelected != null) {
      // if specific setting
      // update previous one to unchecked
      if (isSelected && group.selected != value) group.updateSelect(value);
    }
  }

  final void Function() onSelected;
  final Widget child;
  final String groupId;
  final String value;

  static final _groups = <String, _Item>{};
  static void clearSelected(String groupId) {
    _groups[groupId]?.updateSelect(null);
  }

  bool get isSelected => group?.checkSelect(value) ?? false;

  _Item get group => _groups[groupId];
  set group(_Item item) => _groups[groupId] = item;

  void dispose() {
    group.removeElement(value);
    if (group.isEmpty) _groups.remove(groupId);
  }

  @override
  _RadioTextState createState() => _RadioTextState();
}

class _RadioTextState extends State<RadioText> {
  @override
  Widget build(BuildContext context) {
    final defaultColor =
        widget.isSelected ? Theme.of(context).primaryColor : Colors.transparent;

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
        onTap: () {
          select();
          widget.onSelected();
        },
        splashColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(kPadding / 2),
          child: widget.child,
        ),
      ),
    );
  }

  void select() => widget.group?.updateSelect(widget.value);

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

  static final BORDER_COLOR = Colors.grey.withAlpha(100);
}

class _Item {
  _Item(this._selected);

  String _selected;
  final _elements = <String, Function(Function())>{};

  bool checkSelect(String value) => _selected == value;

  void updateSelect(String value) {
    _selected = value;
    _elements.values.forEach((rebuilder) {
      rebuilder(() {});
    });
  }

  void addElement(String id, Function rebuilder) {
    _elements[id] = rebuilder;
  }

  void removeElement(String id) {
    _elements.remove(id);
  }

  bool get isEmpty => _elements.isEmpty;
  String get selected => _selected;
}

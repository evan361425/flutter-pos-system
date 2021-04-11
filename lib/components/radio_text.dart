import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class RadioText extends StatefulWidget {
  const RadioText({
    Key key,
    @required this.onSelected,
    @required this.child,
    @required this.groupId,
    @required this.value,
  }) : super(key: key);

  static final _groups = <String, _Item>{};

  final void Function() onSelected;
  final Widget child;
  final String groupId;
  final String value;

  @override
  _RadioTextState createState() => _RadioTextState();

  bool get isSelected => group?.checkSelect(value) ?? false;

  _Item get group => _groups[groupId];

  void dispose() {
    group.removeElement(value);
    if (group.isEmpty) _groups.remove(groupId);
  }
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
          color: widget.isSelected ? defaultColor : Colors.grey,
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

  void select() =>
      RadioText._groups[widget.groupId]?.updateSelect(widget.value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (RadioText._groups[widget.groupId] == null) {
      RadioText._groups[widget.groupId] = _Item(widget.value);
    }
    RadioText._groups[widget.groupId].addElement(widget.value, setState);
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
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
}

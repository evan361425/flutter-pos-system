import 'package:flutter/material.dart';

class RadioText extends StatefulWidget {
  static final _groups = <String, _Group>{};

  final void Function(bool isSelected) onSelected;

  final String text;

  final String groupId;

  final String value;

  final bool isTogglable;

  final EdgeInsets margin;

  RadioText({
    Key? key,
    required this.groupId,
    required this.onSelected,
    required this.value,
    required this.text,
    this.isTogglable = false,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    bool? isSelected,
  }) : super(key: key) {
    // if not set, initialize a new one
    if (_groups[groupId] == null) {
      _groups[groupId] = _Group(isSelected == false ? null : value);
    } else if (isSelected == true && !group!.isSelect(value)) {
      // if specific setting, update previous one to unchecked
      group!.select(value);
    } else if (isSelected == false && group!.isSelect(value)) {
      group!.unselect();
    }
  }

  _Group? get group => _groups[groupId];

  bool get isSelected => group!.isSelect(value);

  @override
  _RadioTextState createState() => _RadioTextState();

  void dispose() {
    group?.removeItem(value);

    if (group?.isEmpty == true) {
      _groups.remove(groupId);
    }
  }

  void select() {
    if (group!.select(value, isTogglable: isTogglable)) {
      onSelected(isSelected);
    }
  }

  static void clearAll() => _groups.clear();

  static void clearSelected(String groupId) {
    _groups[groupId]?.select(null);
  }

  static Widget empty([String? text]) {
    if (text == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: const Text(''),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
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

  bool select(String? value, {bool isTogglable = false}) {
    if (_selected == value) {
      if (isTogglable) {
        _rebuildNeededRadio(value);
        _selected = null;
        return true;
      }
      return false;
    }

    _rebuildNeededRadio(value);
    _selected = value;
    return true;
  }

  void unselect() {
    _selected = null;
  }

  void _rebuildNeededRadio(String? newSelected) {
    final oldCb = _items[_selected];
    if (oldCb != null) oldCb();

    final newCb = _items[newSelected];
    if (newCb != null) newCb();
  }
}

class _RadioTextState extends State<RadioText> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    final textColor = theme.colorScheme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Container(
      margin: widget.margin,
      constraints: const BoxConstraints(minWidth: 64.0),
      decoration: BoxDecoration(
        color: widget.isSelected ? color : null,
        border: Border.all(
          color: widget.isSelected ? color : const Color(0xDD000000),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: InkWell(
        onTap: () => widget.select(),
        splashColor: color,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.isSelected ? TextStyle(color: textColor) : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  void initState() {
    widget.group!.addItem(widget.value, () {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }
}

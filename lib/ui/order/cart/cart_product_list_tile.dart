import 'package:flutter/material.dart';

class CartProductListTile extends StatelessWidget {
  const CartProductListTile({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  })  : assert(selected != null),
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final void Function() onTap;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Widget leading = Checkbox(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final theme = Theme.of(context);

    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: theme.accentColor,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap ?? () => onChanged(!value),
          selected: selected,
          selectedTileColor: theme.primaryColorLight,
        ),
      ),
    );
  }
}

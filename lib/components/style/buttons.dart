import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

class MoreButton extends StatelessWidget {
  final void Function(BuildContext) onPressed;

  const MoreButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPressed(context),
      enableFeedback: true,
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      icon: const Icon(KIcons.more),
    );
  }
}

class EntryMoreButton extends StatelessWidget {
  final void Function(BuildContext) onPressed;

  const EntryMoreButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPressed(context),
      enableFeedback: true,
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      icon: const Icon(KIcons.entryMore),
    );
  }
}

class NavToButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NavToButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: S.btnNavTo,
      icon: const Icon(Icons.open_in_new_outlined),
    );
  }
}

class ButtonGroup extends StatelessWidget {
  final List<Widget> buttons;

  const ButtonGroup({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[buttons.first];
    for (var i = 1; i < buttons.length; i++) {
      children.add(const SizedBox(height: 28, child: VerticalDivider()));
      children.add(buttons[i]);
    }

    return Material(
      elevation: 1.0,
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      child: Row(children: children),
    );
  }
}

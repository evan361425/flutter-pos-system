import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/translator.dart';

import 'spreadsheet_selector.dart';

class SheetNamer extends StatefulWidget {
  final SheetNamerProperties prop;

  final void Function(SheetNamerProperties prop)? action;

  final IconData? actionIcon;

  final String? actionTitle;

  const SheetNamer({
    super.key,
    required this.prop,
    this.action,
    this.actionIcon,
    this.actionTitle,
  });

  @override
  State<SheetNamer> createState() => SheetNamerState();
}

class SheetNamerState extends State<SheetNamer> {
  @override
  Widget build(BuildContext context) {
    final secondary = widget.action == null
        ? IconButton(
            icon: const Icon(KIcons.edit),
            tooltip: S.transitGSSheetNameUpdate,
            onPressed: editSheetName,
          )
        : EntryMoreButton(
            key: Key('sheet_namer.${widget.prop.type.name}.more'),
            onPressed: showActions,
          );

    return GestureDetector(
      onLongPress: Feedback.wrapForLongPress(
        widget.action == null ? editSheetName : showActions,
        context,
      ),
      child: CheckboxListTile(
        key: Key('sheet_namer.${widget.prop.type.name}'),
        controlAffinity: ListTileControlAffinity.leading,
        value: widget.prop.checked,
        secondary: secondary,
        title: Text(widget.prop.name),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              widget.prop.checked = value;
            });
          }
        },
      ),
    );
  }

  void showActions([BuildContext? ctx]) async {
    ctx ??= context;
    final result = await showCircularBottomSheet<int>(ctx, actions: [
      BottomSheetAction(
        key: const Key('btn.edit'),
        title: Text(S.transitGSSheetNameUpdate),
        leading: const Icon(KIcons.edit),
        returnValue: 0,
      ),
      BottomSheetAction(
        key: const Key('btn.custom'),
        title: Text(widget.actionTitle!),
        leading: Icon(widget.actionIcon),
        returnValue: 1,
      ),
    ]);

    switch (result) {
      case 0:
        editSheetName();
        break;
      case 1:
        widget.action!(widget.prop);
        break;
    }
  }

  void editSheetName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SingleTextDialog(
        validator: Validator.textLimit(widget.prop.labelText, 30),
        keyboardType: TextInputType.name,
        maxLength: 30,
        hints: widget.prop.hints,
        initialValue: widget.prop.name,
        title: Text(widget.prop.labelText),
      ),
    );

    if (result is String) {
      setState(() {
        widget.prop.name = result;
      });
    }
  }
}

class SheetNamerProperties {
  final SheetType type;

  /// The name of the sheet
  String name;

  /// Whether the sheet is enabled
  bool checked;

  /// Use as autocomplete
  Iterable<String>? hints;

  SheetNamerProperties(
    this.type, {
    required this.name,
    required this.checked,
    required this.hints,
  });

  String get labelText {
    return S.transitGSSheetNameLabel(S.transitModelName(type.name));
  }
}

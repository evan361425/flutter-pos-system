import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/spreadsheet_selector.dart';

class SheetNamer extends StatefulWidget {
  final SheetNamerProperties prop;

  final void Function(SheetNamerProperties prop)? action;

  final IconData? actionIcon;

  final String? actionTitle;

  const SheetNamer({
    Key? key,
    required this.prop,
    this.action,
    this.actionIcon,
    this.actionTitle,
  }) : super(key: key);

  @override
  State<SheetNamer> createState() => SheetNamerState();
}

class SheetNamerState extends State<SheetNamer> {
  @override
  Widget build(BuildContext context) {
    final secondary = widget.action == null
        ? IconButton(
            icon: const Icon(KIcons.edit),
            tooltip: '修改標題',
            onPressed: editSheetName,
          )
        : IconButton(
            key: Key('sheet_namer.${widget.prop.type.name}.more'),
            icon: const Icon(KIcons.more),
            onPressed: showActions,
          );
    return CheckboxListTile(
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
    );
  }

  void showActions() async {
    final result = await showCircularBottomSheet<int>(context, actions: [
      const BottomSheetAction(
        key: Key('btn.edit'),
        title: Text('修改標題'),
        leading: Icon(KIcons.edit),
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
        widget.action!.call(widget.prop);
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

  // 表單標題
  String name;

  // 初始是否啟用
  bool checked;

  // 用作 autocomplete
  Iterable<String>? hints;

  SheetNamerProperties(
    this.type, {
    required this.name,
    required this.checked,
    required this.hints,
  });

  String get labelText {
    return S.exporterGSSheetLabel(S.exporterTypeName(type.name));
  }
}

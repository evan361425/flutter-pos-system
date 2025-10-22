import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ReceiptTemplateModal extends StatefulWidget {
  final ReceiptTemplate? template;

  final bool isNew;

  const ReceiptTemplateModal({
    super.key,
    this.template,
  }) : isNew = template == null;

  @override
  State<ReceiptTemplateModal> createState() => _ReceiptTemplateModalState();
}

class _ReceiptTemplateModalState extends State<ReceiptTemplateModal> with ItemModal<ReceiptTemplateModal> {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  late bool isDefault;

  @override
  String get title => widget.isNew ? S.printerReceiptTemplateTitleCreate : S.printerReceiptTemplateTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      TextFormField(
        key: const Key('receipt_template.name'),
        controller: _nameController,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.printerReceiptTemplateNameLabel,
          hintText: widget.template?.name,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(
          S.printerReceiptTemplateNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.template?.name != name && ReceiptTemplates.instance.hasName(name)
                ? S.printerReceiptTemplateNameErrorRepeat
                : null;
          },
        ),
        onFieldSubmitted: handleFieldSubmit,
      ),
      CheckboxListTile(
        key: const Key('receipt_template.isDefault'),
        controlAffinity: ListTileControlAffinity.leading,
        value: isDefault,
        selected: isDefault,
        onChanged: _toggledDefault,
        title: Text(S.printerReceiptTemplateToDefaultLabel),
        subtitle: Text(S.printerReceiptTemplateToDefaultHelper),
      ),
      if (!widget.isNew)
        ListTile(
          leading: const Icon(Icons.edit),
          title: Text(S.printerReceiptTemplateEditComponents),
          subtitle: Text(S.printerReceiptComponentCount(widget.template!.components.length)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.pushNamed(
              Routes.printerReceiptTemplateComponentEditor,
              pathParameters: {'id': widget.template!.id},
            );
          },
        ),
    ];
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.template?.name);
    _nameFocusNode = FocusNode();

    isDefault = widget.template?.isDefault ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = ReceiptTemplateObject(
      name: _nameController.text,
      isDefault: isDefault,
      components: widget.template?.components,
    );

    // if turn to default or add default
    if (isDefault && widget.template?.isDefault != true) {
      await ReceiptTemplates.instance.clearDefault();
    }

    if (widget.isNew) {
      await ReceiptTemplates.instance.addItem(ReceiptTemplate(
        name: object.name!,
        isDefault: isDefault,
        components: ReceiptTemplate._getDefaultComponents(),
      ));
    } else {
      await widget.template!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  void _toggledDefault(bool? value) async {
    final defaultTemplate = ReceiptTemplates.instance.defaultTemplate;
    // warn if default template is going to be changed
    if (value == true && defaultTemplate != null && defaultTemplate.id != widget.template?.id) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: S.printerReceiptTemplateToDefaultConfirmChangeTitle,
        content: S.printerReceiptTemplateToDefaultConfirmChangeContent(defaultTemplate.name),
      );

      if (confirmed) {
        setState(() => isDefault = value!);
      }
    } else {
      setState(() => isDefault = value!);
    }
  }
}

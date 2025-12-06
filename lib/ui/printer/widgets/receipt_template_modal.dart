import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/menu_actions.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
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
  late List<ReceiptComponent> _components;
  late ValueNotifier<int> _componentsCount;
  late FocusNode _nameFocusNode;

  @override
  String get title => widget.isNew ? S.printerSettingsTitleTemplateCreate : S.printerSettingsTitleTemplateUpdate;

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(title),
      scrollable: false,
      action: TextButton(
        key: const Key('modal.save'),
        onPressed: () => handleSubmit(),
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
      scaffoldMessengerKey: scaffoldMessengerKey,
      content: Form(
        key: formKey,
        child: Column(children: [
          ...buildFormFields(),
          const SizedBox(height: kInternalSpacing),
          ValueListenableBuilder<int>(
            valueListenable: _componentsCount,
            builder: (context, value, child) {
              return MyReorderableList(items: _components, itemBuilder: buildComponentTile);
            },
          ),
          const SizedBox(height: kInternalSpacing),
          ElevatedButton.icon(
            key: const Key('receipt_tpl.add_component'),
            onPressed: onAddComponent,
            icon: const Icon(Icons.add),
            label: Text(S.printerReceiptComponentTitleAdd),
          ),
          const SizedBox(height: kDialogBottomSpacing),
        ]),
      ),
    );
  }

  @override
  List<Widget> buildFormFields() {
    return [
      TextFormField(
        key: const Key('receipt_tpl.name'),
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
    ];
  }

  Widget buildComponentTile(BuildContext context, ReceiptComponent item, Widget toggler) {
    return ListTile(
      title: Text(S.printerReceiptComponentType(item.type.name)),
      subtitle: item.buildDescription(context),
      leading: item.icon,
      onTap: () => context.pushNamed(
        Routes.printerSettingsTemplateComponentEditor,
        pathParameters: {'id': widget.template!.id},
        extra: item,
      ),
      trailing: toggler,
    );
  }

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.template?.name);
    _nameFocusNode = FocusNode();
    _components = widget.template?.components.toList() ?? [];
    _componentsCount = ValueNotifier<int>(_components.length);

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void onAddComponent() async {
    final result = await showPositionedMenu<ReceiptComponentType>(context, actions: [
      for (final type in ReceiptComponentType.values)
        MenuAction(
          title: Text(S.printerReceiptComponentType(type.name)),
          leading: ReceiptComponent.fromJson({'type': type.index}).icon,
          returnValue: type,
        ),
    ]);
    if (result != null) {
      setState(() {
        _components.add(ReceiptComponent.fromJson({'type': result.index}));
        _componentsCount.value = _components.length;
      });
    }
  }

  @override
  Future<void> updateItem() async {
    final object = ReceiptTemplateObject(
      name: _nameController.text,
      components: _components,
    );

    if (widget.isNew) {
      await ReceiptTemplates.instance.addItem(ReceiptTemplate(
        name: object.name!,
        components: object.components,
      ));
    } else {
      await widget.template!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }
}

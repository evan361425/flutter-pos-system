import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/menu_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(S.printerTitleSettings),
      scrollable: false,
      content: ListenableBuilder(
        listenable: ReceiptTemplates.instance,
        builder: _buildList,
        child: ButtonGroup(buttons: [
          RouteIconButton(
            key: const Key('printer.settings.template_create'),
            route: Routes.printerSettingsTemplateCreate,
            icon: const Icon(KIcons.add),
            label: S.printerSettingsTitleTemplateCreate,
          ),
          const _DensitySwitch(key: Key('printer.settings.density_switch')),
        ]),
      ),
    );
  }

  Widget _buildList(BuildContext context, Widget? leading) {
    return SlidableItemList<ReceiptTemplate, _Actions>(
      leading: leading,
      delegate: SlidableItemDelegate(
        handleDelete: (item) async {
          if (item.isDefault) {
            return showSnackBar(
              S.printerReceiptTemplateDefaultReadonlyWarning,
              context: context,
            );
          }
          return item.remove();
        },
        deleteValue: _Actions.delete,
        warningContentBuilder: (_, item) => S.dialogDeletionContent(item.name, ''),
        items: ReceiptTemplates.instance.itemList,
        actionBuilder: (item) => [
          if (!item.isDefault)
            MenuAction(
              title: Text(S.printerSettingsTitleTemplateUpdate),
              leading: const Icon(KIcons.modal),
              routePathParameters: {'id': item.id},
              route: Routes.printerSettingsTemplateUpdate,
            ),
          MenuAction(
            title: Text(S.printerReceiptTemplateSelectLabel),
            leading: const Icon(Icons.check_circle),
            returnValue: _Actions.select,
          ),
        ],
        handleAction: (item, action) async {
          if (action == _Actions.select) {
            await ReceiptTemplates.instance.changeSelected(item.id);
          }
        },
        tileBuilder: (item, index, actorBuilder) => _TemplateTile(
          template: item,
          actorBuilder: actorBuilder,
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final ReceiptTemplate template;
  final ActorBuilder actorBuilder;

  const _TemplateTile({
    required this.template,
    required this.actorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final selected = template.isSelected;
    final actor = actorBuilder(context);
    return ListTile(
      key: Key('receipt_tpl.${template.id}'),
      leading: Icon(
        selected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      selected: selected,
      title: Text(template.name),
      subtitle: Text(S.printerReceiptTemplateMetaComponentsCount(template.components.length)),
      trailing: EntryMoreButton(onPressed: actor),
      onTap: () {
        if (!template.isDefault) {
          context.pushNamed(
            Routes.printerSettingsTemplateUpdate,
            pathParameters: {'id': template.id},
          );
        }
      },
      onLongPress: actor,
    );
  }
}

class _DensitySwitch extends StatefulWidget {
  const _DensitySwitch({super.key});

  @override
  State<_DensitySwitch> createState() => _DensitySwitchState();
}

class _DensitySwitchState extends State<_DensitySwitch> {
  late PrinterDensity density;
  bool changing = false;

  @override
  Widget build(BuildContext context) {
    return Column(spacing: 4.0, children: [
      Switch(value: density == PrinterDensity.tight, onChanged: _onChanged),
      Row(spacing: 4.0, children: [
        Text(S.printerSettingsPaddingLabel),
        InfoPopup(S.printerSettingsPaddingHelper, margin: const EdgeInsets.all(0)),
      ]),
    ]);
  }

  @override
  initState() {
    density = Printers.instance.density;
    super.initState();
  }

  void _onChanged(bool value) async {
    if (mounted && !changing) {
      changing = true;

      setState(() {
        density = value ? PrinterDensity.tight : PrinterDensity.normal;
      });

      await showSnackbarWhenFutureError(Printers.instance.changeDensity(density), 'printer_density_change');

      changing = false;
    }
  }
}

enum _Actions {
  delete,
  select,
}

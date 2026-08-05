import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/menu_actions.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

class PrinterSettingsModal extends StatefulWidget {
  const PrinterSettingsModal({super.key});

  @override
  State<PrinterSettingsModal> createState() => _PrinterSettingsModalState();
}

class _PrinterSettingsModalState extends State<PrinterSettingsModal> {
  final density = ValueNotifier(Printers.instance.density);

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(S.printerTitleSettings),
      scrollable: false,
      content: ListenableBuilder(listenable: ReceiptTemplates.instance, builder: _buildList),
    );
  }

  Widget _buildList(BuildContext context, Widget? child) {
    return SlidableItemList<ReceiptTemplate, _Actions>(
      leading: _buildLeading(),
      delegate: SlidableItemDelegate(
        deletableChecker: (item) => !item.isDefault && !item.isSelected,
        handleDelete: (item) => item.remove(),
        deleteValue: .delete,
        warningContentBuilder: (_, item) => S.dialogDeletionContent(item.displayName, ''),
        items: ReceiptTemplates.instance.itemList,
        actionBuilder: (item) => [
          MenuAction(
            title: Text(S.printerSettingsTitleTemplateUpdate),
            leading: const Icon(KIcons.edit),
            routePathParameters: {'id': item.id},
            route: Routes.printerSettingsTemplateUpdate,
          ),
          MenuAction(
            title: Text(S.printerReceiptTemplateSelectLabel),
            leading: const Icon(Icons.check_circle),
            returnValue: .select,
          ),
        ],
        handleAction: (item, action) async {
          if (action == .select) {
            await item.select();
          }
        },
        tileBuilder: (item, index, actorBuilder) => _TemplateTile(template: item, actorBuilder: actorBuilder),
      ),
    );
  }

  Widget _buildLeading() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: density,
          builder: (context, value, child) {
            return SwitchListTile(
              title: Text(S.printerSettingsPaddingLabel),
              subtitle: Text(S.printerSettingsPaddingHelper),
              value: value == PrinterDensity.tight,
              onChanged: (value) async {
                density.value = value ? PrinterDensity.tight : PrinterDensity.normal;
                await showSnackbarWhenFutureError(
                  Printers.instance.changeDensity(density.value),
                  'printer_density_change',
                );
              },
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: RouteElevatedIconButton(
                key: const Key('printer.settings.template_create'),
                route: Routes.printerSettingsTemplateCreate,
                label: S.printerSettingsTitleTemplateCreate,
                icon: const Icon(KIcons.add),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final ReceiptTemplate template;
  final ActorBuilder actorBuilder;

  const _TemplateTile({required this.template, required this.actorBuilder});

  @override
  Widget build(BuildContext context) {
    final selected = template.isSelected;
    final actor = actorBuilder(context);
    return ListTile(
      key: Key('receipt_tpl.${template.id}'),
      leading: IconButton(
        icon: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: template.select,
      ),
      selected: selected,
      title: Text(template.displayName),
      subtitle: Text(S.printerReceiptTemplateMetaComponentsCount(template.components.length)),
      trailing: EntryMoreButton(onPressed: actor),
      onTap: () {
        context.pushNamed(Routes.printerSettingsTemplateUpdate, pathParameters: {'id': template.id});
      },
      onLongPress: actor,
    );
  }
}

enum _Actions { delete, select }

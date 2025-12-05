import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ReceiptEditorPage extends StatelessWidget {
  const ReceiptEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(S.printerReceiptEditorTitle),
      scrollable: false,
      content: ListenableBuilder(
        listenable: ReceiptTemplates.instance,
        builder: (context, child) {
          return _buildList(
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('receipt_tpl.add'),
                  onPressed: () => context.pushNamed(Routes.printerReceiptTemplateCreate),
                  label: Text(S.printerReceiptTemplateTitleCreate),
                  icon: const Icon(KIcons.add),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildList(Widget leading) {
    return SlidableItemList<ReceiptTemplate, _Actions>(
      leading: leading,
      delegate: SlidableItemDelegate(
        handleDelete: (item) => item.remove(),
        deleteValue: _Actions.delete,
        warningContentBuilder: (_, item) => S.dialogDeletionContent(item.name, ''),
        items: ReceiptTemplates.instance.itemList,
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
    return ListTile(
      key: Key('receipt_tpl.${template.id}'),
      leading: Icon(
        template.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
        color: template.isDefault ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(template.name),
      subtitle: Text(S.printerReceiptTemplateMetaComponentsCount(template.components.length)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.pushNamed(
        Routes.printerReceiptTemplateUpdate,
        pathParameters: {'id': template.id},
      ),
      onLongPress: actorBuilder(context),
    );
  }
}

enum _Actions {
  delete,
}

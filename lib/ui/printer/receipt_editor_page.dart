import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/receipt_template_modal.dart';

class ReceiptEditorPage extends StatelessWidget {
  const ReceiptEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.printerReceiptEditorTitle),
      ),
      body: ListenableBuilder(
        listenable: ReceiptTemplates.instance,
        builder: (context, _) {
          final templates = ReceiptTemplates.instance.itemList;
          if (templates.isEmpty) {
            return _EmptyView(onCreate: () => _createTemplate(context));
          }
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _TemplateTile(
                template: template,
                onTap: () => _editTemplate(context, template),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTemplate(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createTemplate(BuildContext context) {
    context.pushNamed(
      Routes.printerReceiptTemplateCreate,
    );
  }

  void _editTemplate(BuildContext context, ReceiptTemplate template) {
    context.pushNamed(
      Routes.printerReceiptTemplateUpdate,
      pathParameters: {'id': template.id},
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            S.printerReceiptEditorEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(S.printerReceiptEditorCreateFirst),
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final ReceiptTemplate template;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        template.isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
        color: template.isDefault ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(template.name),
      subtitle: Text(S.printerReceiptComponentCount(template.components.length)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

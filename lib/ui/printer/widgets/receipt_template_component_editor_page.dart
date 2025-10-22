import 'package:flutter/material.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/receipt_component_editor_dialog.dart';

class ReceiptTemplateComponentEditorPage extends StatefulWidget {
  final ReceiptTemplate template;

  const ReceiptTemplateComponentEditorPage({
    super.key,
    required this.template,
  });

  @override
  State<ReceiptTemplateComponentEditorPage> createState() => _ReceiptTemplateComponentEditorPageState();
}

class _ReceiptTemplateComponentEditorPageState extends State<ReceiptTemplateComponentEditorPage> {
  late List<ReceiptComponent> components;

  @override
  void initState() {
    super.initState();
    components = List.from(widget.template.components);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: Text(S.printerReceiptEditorReset),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: components.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = components.removeAt(oldIndex);
            components.insert(newIndex, item);
          });
          _saveComponents();
        },
        itemBuilder: (context, index) {
          final component = components[index];
          return _ComponentTile(
            key: ValueKey(component.id),
            component: component,
            onEdit: () => _editComponent(component),
            onDelete: () => _deleteComponent(component),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addComponent,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addComponent() {
    showDialog(
      context: context,
      builder: (context) => _ComponentTypeDialog(
        onSelected: (type) {
          setState(() {
            components.add(_createDefaultComponent(type));
          });
          _saveComponents();
        },
      ),
    );
  }

  void _editComponent(ReceiptComponent component) async {
    final result = await showDialog<ReceiptComponent>(
      context: context,
      builder: (context) => ReceiptComponentEditorDialog(component: component),
    );
    if (result != null) {
      setState(() {
        final index = components.indexWhere((c) => c.id == component.id);
        if (index != -1) {
          components[index] = result;
        }
      });
      _saveComponents();
    }
  }

  void _deleteComponent(ReceiptComponent component) {
    setState(() {
      components.removeWhere((c) => c.id == component.id);
    });
    _saveComponents();
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.printerReceiptEditorResetTitle),
        content: Text(S.printerReceiptEditorResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                components = ReceiptTemplate._getDefaultComponents();
              });
              _saveComponents();
              Navigator.of(context).pop();
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  void _saveComponents() {
    widget.template.update(ReceiptTemplateObject(
      components: components,
      // Keep other values
      name: widget.template.name,
      isDefault: widget.template.isDefault,
    ));
  }

  ReceiptComponent _createDefaultComponent(ReceiptComponentType type) {
    final id = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    switch (type) {
      case ReceiptComponentType.orderTable:
        return OrderTableComponent(id: id);
      case ReceiptComponentType.textField:
        return TextFieldComponent(id: id, text: 'Custom Text');
      case ReceiptComponentType.divider:
        return DividerComponent(id: id);
      case ReceiptComponentType.orderTimestamp:
        return OrderTimestampComponent(id: id);
      case ReceiptComponentType.orderId:
        return OrderIdComponent(id: id);
      case ReceiptComponentType.totalSection:
        return TotalSectionComponent(id: id);
      case ReceiptComponentType.paymentSection:
        return PaymentSectionComponent(id: id);
    }
  }
}

class _ComponentTile extends StatelessWidget {
  final ReceiptComponent component;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ComponentTile({
    super.key,
    required this.component,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIcon(component.type)),
      title: Text(_getTitle(component)),
      subtitle: Text(_getSubtitle(component)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }

  IconData _getIcon(ReceiptComponentType type) {
    switch (type) {
      case ReceiptComponentType.orderTable:
        return Icons.table_chart;
      case ReceiptComponentType.textField:
        return Icons.text_fields;
      case ReceiptComponentType.divider:
        return Icons.horizontal_rule;
      case ReceiptComponentType.orderTimestamp:
        return Icons.access_time;
      case ReceiptComponentType.orderId:
        return Icons.tag;
      case ReceiptComponentType.totalSection:
        return Icons.calculate;
      case ReceiptComponentType.paymentSection:
        return Icons.payment;
    }
  }

  String _getTitle(ReceiptComponent component) {
    switch (component.type) {
      case ReceiptComponentType.orderTable:
        return S.printerReceiptComponentOrderTable;
      case ReceiptComponentType.textField:
        final c = component as TextFieldComponent;
        return c.text.isEmpty ? S.printerReceiptComponentTextField : c.text;
      case ReceiptComponentType.divider:
        return S.printerReceiptComponentDivider;
      case ReceiptComponentType.orderTimestamp:
        return S.printerReceiptComponentTimestamp;
      case ReceiptComponentType.orderId:
        return S.printerReceiptComponentOrderId;
      case ReceiptComponentType.totalSection:
        return S.printerReceiptComponentTotalSection;
      case ReceiptComponentType.paymentSection:
        return S.printerReceiptComponentPaymentSection;
    }
  }

  String _getSubtitle(ReceiptComponent component) {
    switch (component.type) {
      case ReceiptComponentType.orderTable:
        final c = component as OrderTableComponent;
        final columns = <String>[];
        if (c.showProductName) columns.add(S.printerReceiptColumnName);
        if (c.showCount) columns.add(S.printerReceiptColumnCount);
        if (c.showPrice) columns.add(S.printerReceiptColumnPrice);
        if (c.showTotal) columns.add(S.printerReceiptColumnTotal);
        return columns.join(', ');
      case ReceiptComponentType.textField:
        final c = component as TextFieldComponent;
        return '${S.printerReceiptComponentFontSize}: ${c.fontSize.toInt()}';
      case ReceiptComponentType.divider:
        final c = component as DividerComponent;
        return '${S.printerReceiptComponentHeight}: ${c.height}';
      case ReceiptComponentType.orderTimestamp:
        final c = component as OrderTimestampComponent;
        return c.dateFormat;
      case ReceiptComponentType.orderId:
        return S.printerReceiptComponentOrderIdDesc;
      case ReceiptComponentType.totalSection:
        final c = component as TotalSectionComponent;
        final parts = <String>[];
        if (c.showDiscounts) parts.add(S.printerReceiptDiscountLabel);
        if (c.showAddOns) parts.add(S.printerReceiptAddOnsLabel);
        return parts.isEmpty ? S.printerReceiptTotal : parts.join(', ');
      case ReceiptComponentType.paymentSection:
        return S.printerReceiptComponentPaymentDesc;
    }
  }
}

class _ComponentTypeDialog extends StatelessWidget {
  final Function(ReceiptComponentType) onSelected;

  const _ComponentTypeDialog({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.printerReceiptComponentAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReceiptComponentType.values.map((type) {
            return ListTile(
              leading: Icon(_getIcon(type)),
              title: Text(_getTitle(type)),
              onTap: () {
                onSelected(type);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIcon(ReceiptComponentType type) {
    switch (type) {
      case ReceiptComponentType.orderTable:
        return Icons.table_chart;
      case ReceiptComponentType.textField:
        return Icons.text_fields;
      case ReceiptComponentType.divider:
        return Icons.horizontal_rule;
      case ReceiptComponentType.orderTimestamp:
        return Icons.access_time;
      case ReceiptComponentType.orderId:
        return Icons.tag;
      case ReceiptComponentType.totalSection:
        return Icons.calculate;
      case ReceiptComponentType.paymentSection:
        return Icons.payment;
    }
  }

  String _getTitle(ReceiptComponentType type) {
    switch (type) {
      case ReceiptComponentType.orderTable:
        return S.printerReceiptComponentOrderTable;
      case ReceiptComponentType.textField:
        return S.printerReceiptComponentTextField;
      case ReceiptComponentType.divider:
        return S.printerReceiptComponentDivider;
      case ReceiptComponentType.orderTimestamp:
        return S.printerReceiptComponentTimestamp;
      case ReceiptComponentType.orderId:
        return S.printerReceiptComponentOrderId;
      case ReceiptComponentType.totalSection:
        return S.printerReceiptComponentTotalSection;
      case ReceiptComponentType.paymentSection:
        return S.printerReceiptComponentPaymentSection;
    }
  }
}

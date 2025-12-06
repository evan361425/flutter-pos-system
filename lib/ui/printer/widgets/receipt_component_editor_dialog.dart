import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/translator.dart';

class ReceiptComponentEditorDialog extends StatefulWidget {
  final ReceiptComponent component;

  const ReceiptComponentEditorDialog({
    super.key,
    required this.component,
  });

  @override
  State<ReceiptComponentEditorDialog> createState() => _ReceiptComponentEditorDialogState();
}

class _ReceiptComponentEditorDialogState extends State<ReceiptComponentEditorDialog> {
  late ReceiptComponent _component;

  @override
  void initState() {
    super.initState();
    _component = widget.component.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(_getTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEditor(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_component),
                child: Text(MaterialLocalizations.of(context).saveButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_component.type) {
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

  Widget _buildEditor() {
    switch (_component.type) {
      case ReceiptComponentType.orderTable:
        return _buildOrderTableEditor();
      case ReceiptComponentType.textField:
        return _buildTextFieldEditor();
      case ReceiptComponentType.divider:
        return _buildDividerEditor();
      case ReceiptComponentType.orderTimestamp:
        return _buildTimestampEditor();
      case ReceiptComponentType.orderId:
        return _buildOrderIdEditor();
      case ReceiptComponentType.totalSection:
        return _buildTotalSectionEditor();
      case ReceiptComponentType.paymentSection:
        return _buildPaymentSectionEditor();
    }
  }

  Widget _buildOrderTableEditor() {
    final c = _component as OrderTableComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: Text(S.printerReceiptComponentShowProductName),
          value: c.showProductName,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showProductName: value);
            });
          },
        ),
        CheckboxListTile(
          title: Text(S.printerReceiptComponentShowCatalogName),
          value: c.showCatalogName,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showCatalogName: value);
            });
          },
        ),
        CheckboxListTile(
          title: Text(S.printerReceiptColumnCount),
          value: c.showCount,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showCount: value);
            });
          },
        ),
        CheckboxListTile(
          title: Text(S.printerReceiptColumnPrice),
          value: c.showPrice,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showPrice: value);
            });
          },
        ),
        CheckboxListTile(
          title: Text(S.printerReceiptColumnTotal),
          value: c.showTotal,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showTotal: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextFieldEditor() {
    final c = _component as TextFieldComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: c.text,
          decoration: InputDecoration(labelText: S.printerReceiptComponentText),
          maxLines: 3,
          onChanged: (value) {
            _component = c.copyWith(text: value);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text(S.printerReceiptComponentFontSize)),
            Text('${c.fontSize.toInt()}'),
          ],
        ),
        Slider(
          value: c.fontSize,
          min: 8,
          max: 32,
          divisions: 24,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(fontSize: value);
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TextAlign>(
          value: c.textAlign,
          decoration: InputDecoration(labelText: S.printerReceiptComponentAlignment),
          items: [
            DropdownMenuItem(value: TextAlign.left, child: Text(S.printerReceiptComponentAlignLeft)),
            DropdownMenuItem(value: TextAlign.center, child: Text(S.printerReceiptComponentAlignCenter)),
            DropdownMenuItem(value: TextAlign.right, child: Text(S.printerReceiptComponentAlignRight)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _component = c.copyWith(textAlign: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDividerEditor() {
    final c = _component as DividerComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(S.printerReceiptComponentHeight)),
            Text('${c.height}'),
          ],
        ),
        Slider(
          value: c.height,
          min: 1,
          max: 20,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(height: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimestampEditor() {
    final c = _component as OrderTimestampComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          value: c.dateFormat,
          decoration: InputDecoration(labelText: S.printerReceiptComponentDateFormat),
          items: [
            DropdownMenuItem(value: 'yMMMd Hms', child: Text(S.printerReceiptComponentDateFormatFull)),
            DropdownMenuItem(value: 'yMMMd', child: Text(S.printerReceiptComponentDateFormatDate)),
            DropdownMenuItem(value: 'Hms', child: Text(S.printerReceiptComponentDateFormatTime)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _component = c.copyWith(dateFormat: value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildOrderIdEditor() {
    final c = _component as OrderIdComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(S.printerReceiptComponentFontSize)),
            Text('${c.fontSize.toInt()}'),
          ],
        ),
        Slider(
          value: c.fontSize,
          min: 8,
          max: 32,
          divisions: 24,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(fontSize: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTotalSectionEditor() {
    final c = _component as TotalSectionComponent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: Text(S.printerReceiptDiscountLabel),
          value: c.showDiscounts,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showDiscounts: value);
            });
          },
        ),
        CheckboxListTile(
          title: Text(S.printerReceiptAddOnsLabel),
          value: c.showAddOns,
          onChanged: (value) {
            setState(() {
              _component = c.copyWith(showAddOns: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSectionEditor() {
    return Text(S.printerReceiptComponentPaymentDesc);
  }
}

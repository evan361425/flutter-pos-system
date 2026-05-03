import 'package:editor_ant/editor_ant.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/helpers/launcher.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/translator.dart';

class ReceiptComponentModal extends StatefulWidget {
  final ReceiptComponent component;

  const ReceiptComponentModal({
    super.key,
    required this.component,
  });

  @override
  State<ReceiptComponentModal> createState() => _ReceiptComponentModalState();
}

class _ReceiptComponentModalState extends State<ReceiptComponentModal> with ItemModal<ReceiptComponentModal> {
  late final ReceiptComponent component;
  ValueNotifier<double>? _notifier;
  Future<void> Function()? onUpdate;

  late final TextEditingController topCtrl;
  late final TextEditingController rightCtrl;
  late final TextEditingController bottomCtrl;
  late final TextEditingController leftCtrl;
  late final ValueNotifier<bool> paddingSplit;

  @override
  String get title => S.printerReceiptComponentType(component.type.name);

  @override
  List<Widget> buildFormFields() {
    return [
      ValueListenableBuilder(
        valueListenable: paddingSplit,
        builder: (context, isSplit, child) {
          final editor = isSplit
              ? GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildPaddingEditor(
                      topCtrl,
                      S.printerReceiptComponentLabelPaddingTop,
                      Icons.vertical_align_top,
                    ),
                    _buildPaddingEditor(
                      rightCtrl,
                      S.printerReceiptComponentLabelPaddingRight,
                      Icons.format_indent_increase,
                    ),
                    _buildPaddingEditor(
                      bottomCtrl,
                      S.printerReceiptComponentLabelPaddingBottom,
                      Icons.vertical_align_bottom,
                    ),
                    _buildPaddingEditor(
                      leftCtrl,
                      S.printerReceiptComponentLabelPaddingLeft,
                      Icons.format_indent_decrease,
                    ),
                  ],
                )
              : _buildPaddingEditor(null, S.printerReceiptComponentLabelPaddingAll, Icons.aspect_ratio);
          return Column(
            children: [
              ListTile(
                title: Text(S.printerReceiptComponentLabelPaddingLabel),
                subtitle: Text(S.printerReceiptComponentLabelPaddingHelper),
                trailing: IconButton(
                  icon: Icon(isSplit ? Icons.unfold_more : Icons.unfold_less),
                  onPressed: () => setState(() => paddingSplit.value = !paddingSplit.value),
                  tooltip:
                      isSplit ? S.printerReceiptComponentLabelPaddingAll : S.printerReceiptComponentLabelPaddingSplit,
                ),
              ),
              editor,
            ],
          );
        },
      ),
      const Divider(),
      ..._buildComponentListTiles(),
    ];
  }

  @override
  Future<void> updateItem() async {
    await onUpdate?.call();
    component.padding = EdgeInsets.fromLTRB(
      (int.tryParse(leftCtrl.text) ?? 0).toDouble(),
      (int.tryParse(topCtrl.text) ?? 0).toDouble(),
      (int.tryParse(rightCtrl.text) ?? 0).toDouble(),
      (int.tryParse(bottomCtrl.text) ?? 0).toDouble(),
    );
    if (mounted && context.canPop()) {
      context.pop(component);
    }
  }

  @override
  void initState() {
    // Create a copy of the component to edit, so that changes won't affect the original until saved.
    component = ReceiptComponent.fromJson(component.toJson());
    topCtrl = TextEditingController(text: component.padding.top.toInt().toString());
    rightCtrl = TextEditingController(text: component.padding.right.toInt().toString());
    bottomCtrl = TextEditingController(text: component.padding.bottom.toInt().toString());
    leftCtrl = TextEditingController(text: component.padding.left.toInt().toString());
    paddingSplit = ValueNotifier<bool>(component.padding.top != component.padding.right ||
        component.padding.top != component.padding.bottom ||
        component.padding.top != component.padding.left);
    super.initState();
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  Widget _buildPaddingEditor(TextEditingController? ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      initialValue: ctrl == null ? topCtrl.text : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: Validator.positiveInt(label),
      onChanged: ctrl == null
          ? (value) {
              topCtrl.text = value;
              rightCtrl.text = value;
              bottomCtrl.text = value;
              leftCtrl.text = value;
            }
          : null,
    );
  }

  List<Widget> _buildComponentListTiles() {
    switch (component.type) {
      case ReceiptComponentType.orderTable:
        return _buildOrderTableEditor();
      case ReceiptComponentType.discountTable:
        return _buildDiscountTableEditor();
      case ReceiptComponentType.attributeTable:
        return _buildAttributeTableEditor();
      case ReceiptComponentType.priceTable:
        return _buildPriceTableEditor();
      case ReceiptComponentType.textField:
        return _buildTextFieldEditor();
      case ReceiptComponentType.image:
        return _buildImageEditor();
      case ReceiptComponentType.divider:
        return _buildDividerEditor();
    }
  }

  List<Widget> _buildOrderTableEditor() {
    final c = component as OrderTableComponent;
    return [
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelProductName),
        value: c.showProductName,
        onChanged: (value) => setState(() => c.showProductName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelCatalogName),
        value: c.showCatalogName,
        onChanged: (value) => setState(() => c.showCatalogName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelQuantity),
        value: c.showQuantity,
        onChanged: (value) => setState(() => c.showQuantity = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelSinglePrice),
        value: c.showSinglePrice,
        onChanged: (value) => setState(() => c.showSinglePrice = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelSinglePrice),
        value: c.showSinglePrice,
        onChanged: (value) => setState(() => c.showSinglePrice = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelTotalPrice),
        value: c.showTotalPrice,
        onChanged: (value) => setState(() => c.showTotalPrice = value!),
      ),
    ];
  }

  List<Widget> _buildDiscountTableEditor() {
    final c = component as DiscountTableComponent;
    return [
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelProductName),
        value: c.showProductName,
        onChanged: (value) => setState(() => c.showProductName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelCatalogName),
        value: c.showCatalogName,
        onChanged: (value) => setState(() => c.showCatalogName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelQuantity),
        value: c.showQuantity,
        onChanged: (value) => setState(() => c.showQuantity = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelOriginPrice),
        value: c.showOriginPrice,
        onChanged: (value) => setState(() => c.showOriginPrice = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelSinglePrice),
        value: c.showSinglePrice,
        onChanged: (value) => setState(() => c.showSinglePrice = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelTotalPrice),
        value: c.showTotalPrice,
        onChanged: (value) => setState(() => c.showTotalPrice = value!),
      ),
    ];
  }

  List<Widget> _buildAttributeTableEditor() {
    final c = component as AttributeTableComponent;
    return [
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelAttributeName),
        value: c.showName,
        onChanged: (value) => setState(() => c.showName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelAttributeOption),
        value: c.showOptionName,
        onChanged: (value) => setState(() => c.showOptionName = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelAttributeAdjustment),
        value: c.showAdjustment,
        onChanged: (value) => setState(() => c.showAdjustment = value!),
      ),
    ];
  }

  List<Widget> _buildPriceTableEditor() {
    final c = component as PriceTableComponent;
    return [
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelPaid),
        value: c.showPaid,
        onChanged: (value) => setState(() => c.showPaid = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelPrice),
        value: c.showPrice,
        onChanged: (value) => setState(() => c.showPrice = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelChange),
        value: c.showChange,
        onChanged: (value) => setState(() => c.showChange = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelProductsQuantity),
        value: c.showProductsQuantity,
        onChanged: (value) => setState(() => c.showProductsQuantity = value!),
      ),
      CheckboxListTile(
        title: Text(S.printerReceiptComponentLabelProductsPrice),
        value: c.showProductsPrice,
        onChanged: (value) => setState(() => c.showProductsPrice = value!),
      ),
    ];
  }

  List<Widget> _buildTextFieldEditor() {
    return [
      _TextEditorView(
        component: component as TextFieldComponent,
        hooker: (v) => onUpdate = v,
      )
    ];
  }

  List<Widget> _buildDividerEditor() {
    final c = component as DividerComponent;
    if (_notifier == null) {
      _notifier = ValueNotifier<double>(c.height);
      _notifier!.addListener(() => c.height = _notifier!.value);
    }

    return [
      _buildSliderWithTitle(
        title: S.printerReceiptComponentLabelDivider,
        min: 1,
        max: 4,
        divisions: 29,
      )
    ];
  }

  List<Widget> _buildImageEditor() {
    final c = component as ImageComponent;
    if (_notifier == null) {
      _notifier!.value = c.widthRatio;
      _notifier!.addListener(() => c.widthRatio = _notifier!.value);
    }

    return [
      _buildSliderWithTitle(
        title: S.printerReceiptComponentLabelImageWidthRatio,
        helper: S.printerReceiptComponentLabelImageWidthRatioHelper,
        min: 0.1,
        max: 1.0,
        divisions: 9,
      ),
      EditImageHolder(
        path: c.imagePath == '' ? null : c.imagePath,
        onSelected: (image) => setState(() => c.imagePath = image),
      ),
    ];
  }

  Widget _buildSliderWithTitle({
    required String title,
    String? helper,
    required double min,
    required double max,
    required int divisions,
  }) {
    return Column(children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      if (helper != null) Text(helper),
      ValueListenableBuilder(
        valueListenable: _notifier!,
        builder: (context, value, child) => Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toShortString(),
          onChanged: (value) => _notifier!.value = value,
        ),
      ),
    ]);
  }
}

class _TextEditorView extends StatefulWidget {
  final TextFieldComponent component;

  final void Function(Future<void> Function()) hooker;

  const _TextEditorView({required this.component, required this.hooker});

  @override
  State<_TextEditorView> createState() => _TextEditorViewState();
}

class _TextEditorViewState extends State<_TextEditorView> {
  late final StyledEditingController<StyledText> _controller;
  late final FocusNode _focusNode;

  late final TextEditingController _fontSizeController;
  late final MenuController _colorController;
  late final MenuController _placeholderController;

  final ValueNotifier<TextAlign> _textAlign = ValueNotifier(TextAlign.left);
  final MenuController _textAlignController = MenuController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StyledWrapper(
      controller: _controller,
      focusNode: _focusNode,
      intents: [BoldIntent.basic(), ItalicIntent.basic(), StrikethroughIntent.basic(), UnderlineIntent.basic()],
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            height: 49,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(spacing: 2.0, children: _buildToolbarButtons()),
            ),
          ),
          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: double.infinity,
              child: _buildTextField(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToolbarButtons() {
    return [
      PlaceholderSelector(
        controller: _placeholderController,
        tooltip: S.printerReceiptComponentLabelTextPlaceholder,
        placeholders: TextFieldPlaceholderType.values
            .map((e) => e.buildPlaceholder(onMenuSelected: _onPlaceholderSelected))
            .toList(),
      ),
      // Font Styles
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      FontSizeField(
        key: const Key('editor_ant.font_size_field'),
        controller: _fontSizeController,
        maximum: 40,
      ),
      ColorSelector(
        tooltip: S.printerReceiptComponentLabelTextColor,
        controller: _colorController,
        colors: const [
          [null, Colors.black, Color(0xFF212121), Color(0xFF616161)],
          [Color(0xFF9E9E9E), Color(0xFFB0B0B0), Color(0xFFE0E0E0), Colors.white],
        ],
      ),
      // Style buttons
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      BoldButton(tooltip: S.printerReceiptComponentLabelTextBold),
      ItalicButton(tooltip: S.printerReceiptComponentLabelTextItalic),
      StrikethroughButton(tooltip: S.printerReceiptComponentLabelTextStrikeThrough),
      UnderlineButton(tooltip: S.printerReceiptComponentLabelTextUnderline),
      // Paragraph styles
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      TextAlignSelector(
        value: _textAlign,
        alignments: const [TextAlign.left, TextAlign.center, TextAlign.right, TextAlign.justify],
        alignmentNames: [
          S.printerReceiptComponentLabelTextAlignLeft,
          S.printerReceiptComponentLabelTextAlignCenter,
          S.printerReceiptComponentLabelTextAlignRight,
          S.printerReceiptComponentLabelTextAlignJustify,
        ],
        tooltip: S.printerReceiptComponentLabelTextAlign,
        controller: _textAlignController,
      ),
    ];
  }

  Widget _buildTextField() {
    return ValueListenableBuilder(
      valueListenable: _textAlign,
      builder: (context, value, child) {
        return TextFormField(
          key: const Key('editor_ant.editor'),
          controller: _controller,
          focusNode: _focusNode,
          textAlign: value,
          autofocus: true,
          maxLines: null,
          minLines: null,
          decoration: InputDecoration.collapsed(hintText: S.printerReceiptComponentLabelTextValue),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    widget.hooker(_onUpdate);

    _controller = StyledEditingController<StyledText>();
    _controller.fromParts(
      parts: widget.component.texts.map((e) => e.part).toList(),
      placeholderParser: (PlaceholderPart placeholder) {
        final text = S.printerReceiptComponentLabelTextPlaceholders(placeholder.text);
        return placeholder is MenuPlaceholderPart
            ? MenuPlaceholder(
                id: placeholder.text,
                text: text,
                meta: placeholder.meta,
                onMenuSelected: _onPlaceholderSelected,
              )
            : TextPlaceholder(id: placeholder.text, text: text);
      },
    );
    _focusNode = FocusNode();
    _colorController = MenuController();
    _fontSizeController = TextEditingController(text: defaultFontSize.toString());
    _placeholderController = MenuController();
  }

  @override
  void dispose() {
    _controller.activeStyle.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _fontSizeController.dispose();
    super.dispose();
  }

  Future<void> _onUpdate() async {
    final parts = _controller.toParts();
    widget.component.updateFromParts(parts);
  }

  Future<String?> _onPlaceholderSelected(MenuPlaceholder<String> ph) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SingleTextDialog(
          initialValue: ph.meta,
          validator: Validator.textLimit('日期格式', 1000),
          keyboardType: TextInputType.text,
          title: const Text('日期格式'),
          hints: const [
            'yy/M/d',
            'yyyy/M/d',
            'yyyy/MM/dd',
            'MM/dd/yyyy',
            'dd/MM/yyyy',
            'MMM dd, yyyy',
            'MMMM dd, yyyy',
            'yyyy-MM-dd HH:mm:ss',
          ],
          decoration: const InputDecoration(
            hintText: '例如 yyyy/MM/dd',
            border: OutlineInputBorder(),
          ),
          footers: [
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(color: theme.hintColor, fontSize: theme.textTheme.bodySmall?.fontSize),
                children: [
                  const TextSpan(text: '相關格式可以參考 '),
                  TextSpan(
                    text: '說明文件',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: theme.textTheme.bodySmall?.fontSize,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => Launcher.launch('https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

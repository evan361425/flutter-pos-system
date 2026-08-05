import 'package:editor_ant/editor_ant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/single_text_dialog.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/printer/widgets/printer_receipt_view.dart';

class ReceiptComponentModal extends StatefulWidget {
  final ReceiptComponent component;

  const ReceiptComponentModal({super.key, required this.component});

  @override
  State<ReceiptComponentModal> createState() => _ReceiptComponentModalState();
}

class _ReceiptComponentModalState extends State<ReceiptComponentModal> with ItemModal<ReceiptComponentModal> {
  late final OrderObject order;
  late final ReceiptComponent component;
  ValueNotifier<double>? _notifier;
  Future<void> Function()? onUpdate;
  bool _scrollable = true;

  late final TextEditingController topCtrl;
  late final TextEditingController rightCtrl;
  late final TextEditingController bottomCtrl;
  late final TextEditingController leftCtrl;
  late final ValueNotifier<bool> paddingSplit;

  @override
  bool get scrollable => _scrollable;

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
                    _buildPaddingEditor(topCtrl, S.printerReceiptComponentPaddingTop, Icons.vertical_align_top),
                    _buildPaddingEditor(rightCtrl, S.printerReceiptComponentPaddingRight, Icons.format_indent_increase),
                    _buildPaddingEditor(
                      bottomCtrl,
                      S.printerReceiptComponentPaddingBottom,
                      Icons.vertical_align_bottom,
                    ),
                    _buildPaddingEditor(leftCtrl, S.printerReceiptComponentPaddingLeft, Icons.format_indent_decrease),
                  ],
                )
              : _buildPaddingEditor(null, S.printerReceiptComponentPaddingAll, Icons.aspect_ratio);
          return Column(
            children: [
              ListTile(
                title: Text(S.printerReceiptComponentPaddingLabel),
                subtitle: Text(S.printerReceiptComponentPaddingHelper),
                onTap: () => setState(() => paddingSplit.value = !paddingSplit.value),
                trailing: Icon(isSplit ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ),
              p(editor),
            ],
          );
        },
      ),
      const Divider(),
      _buildComponentEditor(),
    ];
  }

  @override
  Future<void> updateItem() async {
    await onUpdate?.call();
    component.padding = _parsePadding();
    if (mounted && context.canPop()) {
      context.pop(component);
    }
  }

  @override
  void initState() {
    order = OrderObject.example();
    // Create a copy of the component to edit, so that changes won't affect the original until saved.
    component = ReceiptComponent.fromJson(widget.component.toJson());
    topCtrl = TextEditingController(text: component.padding.top.toInt().toString());
    rightCtrl = TextEditingController(text: component.padding.right.toInt().toString());
    bottomCtrl = TextEditingController(text: component.padding.bottom.toInt().toString());
    leftCtrl = TextEditingController(text: component.padding.left.toInt().toString());
    paddingSplit = ValueNotifier<bool>(
      component.padding.top != component.padding.right ||
          component.padding.top != component.padding.bottom ||
          component.padding.top != component.padding.left,
    );
    _scrollable = component.type != .textField;
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
      decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label, border: const OutlineInputBorder()),
      keyboardType: .number,
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

  Widget _buildComponentEditor() {
    return switch (component.type) {
      .orderTable => _buildOrderTableEditor(),
      .discountTable => _buildDiscountTableEditor(),
      .attributeTable => _buildAttributeTableEditor(),
      .priceTable => _buildPriceTableEditor(),
      .textField => _buildTextFieldEditor(),
      .image => _buildImageEditor(),
      .divider => _buildDividerEditor(),
    };
  }

  Widget _buildOrderTableEditor() {
    final c = component as OrderTableComponent;
    final left = (OrderTableColumn.values.toSet()..removeAll(OrderTableColumn.isNotSelectable))
        .difference(c.columns.map((e) => e.type).toSet())
        .toList();
    return _wrapReceiptView(
      Builder(
        builder: (context) {
          return PrinterReceiptView.buildOrderTable(
            c,
            order,
            context: context,
            actions: (int index) {
              final children = _buildActions<OrderTableColumn>(
                fixedIndex: 1,
                index: index,
                left: left,
                exist: c.columns,
                setter: (data) => c.columns[index] = TableColumnConfig.fromJson(data, OrderTableColumn.values),
                typeChanger: switch (index) {
                  0 => switch (c.columns[0].type) {
                    .productName => {.productNameWithCatalogName: S.printerReceiptComponentTableOrderTitleAddCatalog},
                    _ => {.productName: S.printerReceiptComponentTableOrderTitleRemoveCatalog},
                  },
                  _ => null,
                },
              );
              return children;
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscountTableEditor() {
    final c = component as DiscountTableComponent;
    final left = (DiscountTableColumn.values.toSet()..removeAll(DiscountTableColumn.isNotSelectable))
        .difference(c.columns.map((e) => e.type).toSet())
        .toList();
    return _wrapReceiptView(
      PrinterReceiptView.buildDiscountTable(
        c,
        order.discounted.toList(),
        actions: (int index) {
          final children = _buildActions<DiscountTableColumn>(
            fixedIndex: 1,
            index: index,
            left: left,
            exist: c.columns,
            setter: (data) => c.columns[index] = TableColumnConfig.fromJson(data, DiscountTableColumn.values),
            typeChanger: switch (index) {
              0 => switch (c.columns[0].type) {
                .productName => {.productNameWithCatalogName: S.printerReceiptComponentTableDiscountTitleAddCatalog},
                _ => {.productName: S.printerReceiptComponentTableDiscountTitleRemoveCatalog},
              },
              _ => null,
            },
          );
          return children;
        },
      ),
    );
  }

  Widget _buildAttributeTableEditor() {
    final c = component as AttributeTableComponent;
    final left = (AttributeTableColumn.values.toSet()..removeAll(AttributeTableColumn.isNotSelectable))
        .difference(c.columns.map((e) => e.type).toSet())
        .toList();
    return _wrapReceiptView(
      PrinterReceiptView.buildAttributesTable(
        c,
        order.effectiveAttributes.toList(),
        actions: (int index) {
          final children = _buildActions<AttributeTableColumn>(
            fixedIndex: 1,
            index: index,
            left: left,
            exist: c.columns,
            setter: (data) => c.columns[index] = TableColumnConfig.fromJson(data, AttributeTableColumn.values),
            typeChanger: switch (index) {
              0 => switch (c.columns[0].type) {
                .optionName => {.optionNameWithAttrName: S.printerReceiptComponentTableAttrTitleAddAttr},
                .attrName => {.optionNameWithAttrName: S.printerReceiptComponentTableAttrTitleAddOption},
                _ => {
                  .optionName: S.printerReceiptComponentTableAttrTitleRemoveAttr,
                  .attrName: S.printerReceiptComponentTableAttrTitleRemoveOption,
                },
              },
              _ => null,
            },
          );
          return children;
        },
      ),
    );
  }

  Widget _buildPriceTableEditor() {
    final c = component as PriceTableComponent;
    final left = PriceTableColumn.values.toSet().difference(c.columns.map((e) => e.type).toSet()).toList();
    return _wrapReceiptView(
      Builder(
        builder: (context) {
          return PrinterReceiptView.buildPriceTable(
            c,
            order,
            context: context,
            actions: (int index) {
              return _buildActions(
                fixedIndex: 1,
                index: index,
                left: left,
                exist: c.columns,
                setter: (data) => c.columns[index] = TableColumnConfig.fromJson(data, PriceTableColumn.values),
                axis: .vertical,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextFieldEditor() {
    return Expanded(
      child: _TextEditorView(component: component as TextFieldComponent, hooker: (v) => onUpdate = v),
    );
  }

  Widget _buildDividerEditor() {
    final c = component as DividerComponent;
    if (_notifier == null) {
      _notifier = ValueNotifier<double>(c.height);
      _notifier!.addListener(() => c.height = _notifier!.value);
    }

    return _buildSliderWithTitle(title: S.printerReceiptComponentDividerHeight, min: 1, max: 4, divisions: 30);
  }

  Widget _buildImageEditor() {
    final c = component as ImageComponent;
    if (_notifier == null) {
      _notifier = ValueNotifier<double>(c.widthRatio);
      _notifier!.addListener(() => c.widthRatio = _notifier!.value);
    }

    return Column(
      children: [
        _buildSliderWithTitle(
          title: S.printerReceiptComponentImageWidthRatio,
          helper: S.printerReceiptComponentImageWidthRatioHelper,
          min: 0.1,
          max: 1.0,
          divisions: 9,
        ),
        EditImageHolder(
          path: c.imagePath == '' ? null : c.imagePath,
          onSelected: (image) => setState(() => c.imagePath = image),
        ),
      ],
    );
  }

  Widget _buildSliderWithTitle({
    required String title,
    String? helper,
    required double min,
    required double max,
    required int divisions,
  }) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (helper != null) Text(helper),
        ValueListenableBuilder(
          valueListenable: _notifier!,
          builder: (context, value, child) => Slider(
            key: const Key('receipt_component.slider'),
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value == value.toInt() ? value.toInt().toString() : value.toStringAsFixed(1),
            onChanged: (value) => _notifier!.value = value,
          ),
        ),
      ],
    );
  }

  Widget _wrapReceiptView(Widget child) {
    return Card(
      color: Colors.white,
      margin: const .symmetric(horizontal: kHorizontalSpacing),
      child: Padding(
        padding: const .symmetric(horizontal: kHorizontalSpacing, vertical: kTopSpacing),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
          child: SizedBox(
            width: 320, // fixed width can provide same density of receipt
            child: DefaultTextStyle(
              style: PrinterReceiptView.defaultTextStyle,
              child: Padding(padding: _parsePadding(), child: child),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _parsePadding() {
    return .fromLTRB(
      (int.tryParse(leftCtrl.text) ?? 0).toDouble(),
      (int.tryParse(topCtrl.text) ?? 0).toDouble(),
      (int.tryParse(rightCtrl.text) ?? 0).toDouble(),
      (int.tryParse(bottomCtrl.text) ?? 0).toDouble(),
    );
  }

  /// [left] not used enum
  /// [exist] used enum with column object
  /// [fixedIndex] not editable index (exclusive)
  List<Widget> _buildActions<T extends Enum>({
    required int index,
    required List<T> left,
    required List<TableColumnConfig<T>> exist,
    required void Function(Map<String, Object?> data) setter,
    Axis axis = .horizontal,
    int fixedIndex = 0,
    Map<T, String>? typeChanger,
  }) {
    final isFixed = index < fixedIndex;
    return [
      if (typeChanger != null)
        for (final entry in typeChanger.entries)
          MenuItemButton(
            onPressed: () async {
              setState(() {
                setter(exist[index].toJson()..['type'] = entry.key.index);
              });
            },
            leadingIcon: const Icon(Icons.title_outlined),
            child: Text(entry.value),
          ),
      MenuItemButton(
        onPressed: () async {
          final item = exist[index];
          final result = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              final String title = (item.type as dynamic).title;
              return SingleTextDialog(
                validator: Validator.textLimit(S.printerReceiptComponentTableTitleLabel(title), 12),
                keyboardType: .text,
                selectAll: true,
                initialValue: item.title ?? title,
                title: Text(S.printerReceiptComponentTableTitleLabel(title)),
              );
            },
          );

          if (result != null) {
            setState(() {
              setter(item.toJson()..['title'] = result);
            });
          }
        },
        leadingIcon: const Icon(Icons.edit_sharp),
        child: Text(S.printerReceiptComponentTableTitleBtn),
      ),
      if (!isFixed && axis == .horizontal)
        MenuItemButton(
          onPressed: () async {
            final item = exist[index];
            final result = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                final double width = (item.type as dynamic).width;
                return SingleTextDialog(
                  validator: Validator.positiveInt(
                    S.printerReceiptComponentTableWidthLabel(title),
                    maximum: 300,
                    minimum: 10,
                  ),
                  keyboardType: .number,
                  selectAll: true,
                  initialValue: (item.width ?? width).toStringAsFixed(0),
                  title: Text(S.printerReceiptComponentTableWidthLabel(title)),
                );
              },
            );

            if (result != null) {
              setState(() {
                setter(item.toJson()..['width'] = (int.tryParse(result) ?? 10).toDouble());
              });
            }
          },
          leadingIcon: const Icon(Icons.open_in_full_sharp),
          child: Text(S.printerReceiptComponentTableWidthBtn),
        ),
      if (left.isNotEmpty && index >= fixedIndex)
        SubmenuButton(
          menuChildren: left
              .map(
                (e) => MenuItemButton(
                  onPressed: () => setState(() {
                    exist.insert(index, TableColumnConfig(e));
                  }),
                  child: Text((e as dynamic).title),
                ),
              )
              .toList(),
          leadingIcon: const Icon(Icons.add_sharp),
          child: Text(
            axis == .horizontal
                ? S.printerReceiptComponentTableInsertBtnLeft
                : S.printerReceiptComponentTableInsertBtnUp,
          ),
        ),
      if (left.isNotEmpty)
        SubmenuButton(
          menuChildren: left
              .map(
                (e) => MenuItemButton(
                  onPressed: () => setState(() {
                    exist.insert(index + 1, TableColumnConfig(e));
                  }),
                  child: Text((e as dynamic).title),
                ),
              )
              .toList(),
          leadingIcon: const Icon(Icons.add_sharp),
          child: Text(
            axis == .horizontal
                ? S.printerReceiptComponentTableInsertBtnRight
                : S.printerReceiptComponentTableInsertBtnDown,
          ),
        ),
      if (index > fixedIndex)
        MenuItemButton(
          onPressed: () => setState(() {
            final column = exist.removeAt(index);
            exist.insert(index - 1, column);
          }),
          leadingIcon: const Icon(Icons.swap_horiz_sharp),
          child: Text(
            axis == .horizontal ? S.printerReceiptComponentTableMoveBtnLeft : S.printerReceiptComponentTableMoveBtnUp,
          ),
        ),
      if (index < exist.length - 1 && index >= fixedIndex)
        MenuItemButton(
          onPressed: () => setState(() {
            final column = exist.removeAt(index);
            exist.insert(index + 1, column);
          }),
          leadingIcon: const Icon(Icons.swap_horiz_sharp),
          child: Text(
            axis == .horizontal
                ? S.printerReceiptComponentTableMoveBtnRight
                : S.printerReceiptComponentTableMoveBtnDown,
          ),
        ),
      if (exist.length > 1 && !isFixed)
        MenuItemButton(
          onPressed: () => setState(() {
            exist.removeAt(index);
          }),
          leadingIcon: const Icon(Icons.delete_sharp),
          child: Text(
            axis == .horizontal
                ? S.printerReceiptComponentTableDeleteBtnCol
                : S.printerReceiptComponentTableDeleteBtnRow,
          ),
        ),
    ];
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

  final ValueNotifier<TextAlign> _textAlign = ValueNotifier(.left);
  final MenuController _textAlignController = MenuController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final toolbarAbove = MediaQuery.sizeOf(context).width > Breakpoint.medium.max;
    final toolbar = Container(
      padding: const .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        borderRadius: const .only(topLeft: .circular(8), topRight: .circular(8)),
      ),
      height: 49,
      width: .infinity,
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Row(
          spacing: 2.0,
          children: _buildToolbarButtons(
            menuStyle: MenuStyle(alignment: toolbarAbove ? .bottomLeft : .topLeft),
            menuAlignmentOffset: Offset(0, toolbarAbove ? 1 : -1),
          ),
        ),
      ),
    );
    return StyledWrapper(
      controller: _controller,
      focusNode: _focusNode,
      intents: [BoldIntent.basic(), ItalicIntent.basic(), StrikethroughIntent.basic(), UnderlineIntent.basic()],
      child: Column(
        children: [
          if (toolbarAbove) toolbar,
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const .all(16),
              width: .infinity,
              height: .infinity,
              child: _buildTextField(),
            ),
          ),
          if (!toolbarAbove) toolbar,
        ],
      ),
    );
  }

  List<Widget> _buildToolbarButtons({required MenuStyle menuStyle, required Offset menuAlignmentOffset}) {
    return [
      PlaceholderSelector(
        controller: _placeholderController,
        tooltip: S.printerReceiptComponentTextPlaceholder,
        menuStyle: menuStyle,
        menuAlignmentOffset: menuAlignmentOffset,
        placeholders: TextFieldPlaceholderType.values
            .where((e) => !e.unSelectable)
            .map((e) => e.buildPlaceholder(onMenuSelected: _onPlaceholderSelected))
            .toList(),
        menuChildrenWrapper: (children) => [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              primary: false,
              child: Column(mainAxisSize: .min, children: children),
            ),
          ),
        ],
      ),
      // Font Styles
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      FontSizeField(key: const Key('editor_ant.font_size_field'), controller: _fontSizeController, maximum: 40),
      ColorSelector(
        tooltip: S.printerReceiptComponentTextColor,
        controller: _colorController,
        menuStyle: menuStyle,
        menuAlignmentOffset: menuAlignmentOffset,
        colors: const [
          [null, Colors.black, Color(0xFF212121), Color(0xFF616161)],
          [Color(0xFF9E9E9E), Color(0xFFB0B0B0), Color(0xFFE0E0E0), Colors.white],
        ],
      ),
      // Style buttons
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      BoldButton(tooltip: S.printerReceiptComponentTextBold),
      ItalicButton(tooltip: S.printerReceiptComponentTextItalic),
      StrikethroughButton(tooltip: S.printerReceiptComponentTextStrikeThrough),
      UnderlineButton(tooltip: S.printerReceiptComponentTextUnderline),
      // Paragraph styles
      const VerticalDivider(width: 1, thickness: 1, indent: 6, endIndent: 6),
      TextAlignSelector(
        value: _textAlign,
        menuStyle: menuStyle,
        menuAlignmentOffset: menuAlignmentOffset,
        alignments: const [TextAlign.left, TextAlign.center, TextAlign.right, TextAlign.justify],
        alignmentNames: [
          S.printerReceiptComponentTextAlignLeft,
          S.printerReceiptComponentTextAlignCenter,
          S.printerReceiptComponentTextAlignRight,
          S.printerReceiptComponentTextAlignJustify,
        ],
        tooltip: S.printerReceiptComponentTextAlign,
        controller: _textAlignController,
      ),
    ];
  }

  Widget _buildTextField() {
    return Theme(
      data: AppThemes.lightTheme,
      child: ValueListenableBuilder(
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
            decoration: .collapsed(hintText: S.printerReceiptComponentTextValue),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    widget.hooker(_onUpdate);

    _controller = StyledEditingController<StyledText>();
    _controller.fromParts(
      parts: widget.component.texts.map((e) => e.part).toList(),
      onPlaceholderPressed: _onPlaceholderSelected,
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

  Future<String?> _onPlaceholderSelected(MenuPlaceholder<String?> ph) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return SingleTextDialog(
          initialValue: ph.meta,
          validator: Validator.textLimit(S.printerReceiptComponentTextPlaceholderDateLabel, 1000),
          keyboardType: .text,
          title: Text(S.printerReceiptComponentTextPlaceholderDateLabel),
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
          decoration: InputDecoration(
            hintText: S.printerReceiptComponentTextPlaceholderDateHint,
            border: const OutlineInputBorder(),
            helper: Linkify.fromString(S.printerReceiptComponentTextPlaceholderDateHelper),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_search_scaffold.dart';

class IngredientModal extends StatefulWidget {
  final ProductIngredientModel? ingredient;
  final ProductModel product;

  final bool isNew;

  IngredientModal({
    Key? key,
    this.ingredient,
    required this.product,
  })  : isNew = ingredient == null,
        super(key: key);

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool isSaving = false;
  String? errorMessage;
  String ingredientId = '';
  String ingredientName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew
            ? '新增成份'
            : '設定成份「${widget.ingredient!.ingredient.name}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: _appBarTrailings(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: _form(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isNew) {
      _amountController.text = widget.ingredient!.amount.toString();
      ingredientId = widget.ingredient!.id;
      ingredientName = widget.ingredient!.ingredient.name;
    }
  }

  Iterable<Widget> _actions(BuildContext context) {
    return [
      ListTile(
        title: Text('刪除'),
        leading: Icon(KIcons.delete, color: kNegativeColor),
        onTap: () async {
          // pop off sheet
          Navigator.of(context).pop();
          await _handleDelete();
        },
      ),
    ];
  }

  List<Widget> _appBarTrailings() {
    final submit = TextButton(
      onPressed: () => _handleSubmit(),
      child: Text('儲存'),
    );

    return widget.isNew
        ? [submit]
        : [
            submit,
            IconButton(
              onPressed: () => showCircularBottomSheet(
                context,
                useRootNavigator: false,
                actions: _actions(context),
              ),
              icon: Icon(KIcons.more),
            )
          ];
  }

  Widget _fieldAmount(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '成份預設用量',
        filled: false,
      ),
      validator: Validator.positiveNumber('成份預設用量'),
    );
  }

  Widget _fieldIngredient(BuildContext context) {
    return SearchBarInline(
      heroTag: IngredientSearchScaffold.tag,
      text: ingredientName,
      hintText: '成份名稱，起司',
      errorText: errorMessage,
      helperText: '新增成份種類後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final result = await Navigator.of(context).pushNamed(
          MenuRoutes.productIngredientSearch,
          arguments: ingredientName,
        );

        if (result != null && result is IngredientModel) {
          final ingredient = result;
          print('User choose ingreidnet: ${ingredient.name}');
          setState(() {
            errorMessage = null;
            ingredientId = ingredient.id;
            ingredientName = ingredient.name;
          });
        }
      },
    );
  }

  Form _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _fieldIngredient(context),
          const SizedBox(height: kSpacing2),
          _fieldAmount(context),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (_) => widget.ingredient!.remove(),
        );
      },
    );
    if (isDeleted == true) Navigator.of(context).pop();
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    await _updateIngredient();

    Navigator.of(context).pop();
  }

  ProductIngredientObject _parseObject() {
    return ProductIngredientObject(
      id: ingredientId,
      amount: num.tryParse(_amountController.text),
    );
  }

  Future<void> _updateIngredient() {
    final object = _parseObject();

    if (!widget.isNew) {
      return widget.ingredient!.update(object);
    } else {
      final ingredient = ProductIngredientModel(
        ingredient: StockModel.instance.getItem(ingredientId),
        product: widget.product,
        amount: object.amount,
      );

      return widget.product.setItem(ingredient);
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;

    if (ingredientId.isEmpty) {
      setState(() => errorMessage = '必須設定成份種類。');
      return false;
    }
    if (widget.ingredient?.id != ingredientId &&
        widget.product.hasItem(ingredientId)) {
      setState(() => errorMessage = '成份重複。');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}

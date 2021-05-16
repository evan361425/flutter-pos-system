import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/danger_button.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_search_scaffold.dart';

class IngredientModal extends StatefulWidget {
  IngredientModal({
    Key key,
    this.ingredient,
  })  : isNew = ingredient.id == null,
        super(key: key);

  final ProductIngredientModel ingredient;
  final bool isNew;

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool isSaving = false;
  String errorMessage;
  String ingredientId = '';
  String ingredientName = '';

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    if (ingredientId.isEmpty) {
      return setState(() => errorMessage = '必須設定成份種類。');
    }
    if (widget.ingredient.id != ingredientId &&
        widget.ingredient.product.exist(ingredientId)) {
      return setState(() => errorMessage = '成份重複。');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateIngredient();

    Navigator.of(context).pop();
  }

  Future<void> _onDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (_) => widget.ingredient.remove(),
        );
      },
    );
    if (isDeleted == true) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew
            ? '新增成份'
            : '設定成份「${widget.ingredient.ingredient.name}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _ingredientSearchBar(context),
                    SizedBox(height: kMargin),
                    _amountField(context),
                  ],
                ),
              ),
              _deleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _updateIngredient() {
    final object = ProductIngredientObject(
      id: ingredientId,
      amount: num.tryParse(_amountController.text),
    );

    if (widget.isNew) {
      final ingredient = ProductIngredientModel(
        ingredient: StockModel.instance.getIngredient(ingredientId),
        product: widget.ingredient.product,
        amount: object.amount,
      );

      ingredient.product.updateIngredient(ingredient);
    } else {
      widget.ingredient.update(object);
    }
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularLoading()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _deleteButton() {
    if (widget.isNew) return Container();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kMargin),
      child: DangerButton(
        onPressed: _onDelete,
        child: Text(
            '刪除${widget.ingredient.product.name}的成份「${widget.ingredient.ingredient.name}」'),
      ),
    );
  }

  Widget _ingredientSearchBar(BuildContext context) {
    return SearchBarInline(
      heroTag: IngredientSearchScaffold.tag,
      text: ingredientName,
      hintText: '成份名稱，起司',
      errorText: errorMessage,
      helperText: '新增成份種類後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final ingredient = await Navigator.of(context).pushNamed(
          MenuRoutes.productIngredientSearch,
          arguments: ingredientName,
        );

        if (ingredient != null && ingredient is IngredientModel) {
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

  Widget _amountField(BuildContext context) {
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

  @override
  void initState() {
    super.initState();

    if (!widget.isNew) {
      _amountController.text = widget.ingredient.amount?.toString();
      ingredientId = widget.ingredient.id;
      ingredientName = widget.ingredient.ingredient.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_search_scaffold.dart';
import 'package:provider/provider.dart';

class IngredientModal extends StatefulWidget {
  IngredientModal({
    Key key,
    @required this.ingredient,
    this.ingredientName,
  }) : super(key: key);

  final ProductIngredientModel ingredient;
  final String ingredientName;

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool isSaving = false;
  String errorMessage;
  String ingredientId;
  String ingredientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ingredient.isNotReady
            ? '新增成份'
            : '設定成份「${widget.ingredientName}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: SafeArea(
        child: Center(child: _form(context)),
      ),
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;
    if (ingredientId.isEmpty) {
      return setState(() => errorMessage = '必須設定成份種類。');
    }
    if (widget.ingredient.id != ingredientId &&
        widget.ingredient.product.has(ingredientId)) {
      return setState(() => errorMessage = '成份重複。');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });
    if (widget.ingredient.isReady) {
      widget.ingredient.update(
        ingredientId: ingredientId,
        defaultAmount: num.parse(_amountController.text),
      );
      widget.ingredient.product.ingredientChanged();
    } else {
      final ingredient = ProductIngredientModel(
        ingredientId: ingredientId,
        product: widget.ingredient.product,
        defaultAmount: num.parse(_amountController.text),
      );
      widget.ingredient.product.addIngredient(ingredient);
    }
    Navigator.of(context).pop();
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _nameField(context),
          SizedBox(height: kMargin),
          _amountField(context),
        ],
      ),
    );
  }

  Widget _nameField(BuildContext context) {
    return SearchBarInline(
      heroTag: IngredientSearchScaffold.tag,
      text: ingredientName,
      hintText: '成份名稱，起司',
      errorText: errorMessage,
      helperText: '新增成份種類後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final ingredient =
            await Navigator.of(context).push<IngredientModel>(MaterialPageRoute(
          builder: (_) => IngredientSearchScaffold(text: ingredientName),
        ));

        if (ingredient != null) {
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
      textInputAction: TextInputAction.send,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '成份預設用量',
        filled: false,
      ),
      onFieldSubmitted: (_) => _onSubmit(),
      validator: Validator.positiveDouble('成份預設用量'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ingredientId = widget.ingredient.id ?? '';
    final stock = context.read<StockModel>();
    ingredientName = stock[ingredientId]?.name ?? '';
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.ingredient.defaultAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

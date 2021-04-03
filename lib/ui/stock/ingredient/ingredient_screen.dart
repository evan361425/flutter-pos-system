import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientScreen extends StatefulWidget {
  IngredientScreen({Key key, this.ingredient}) : super(key: key);

  final IngredientModel ingredient;

  @override
  _IngredientScreenState createState() => _IngredientScreenState();
}

class _IngredientScreenState extends State<IngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool isSaving = false;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_sharp),
        ),
        actions: [_trailingAction()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _nameField(),
                    _amountField(),
                  ],
                ),
              ),
            ),
          ),
          widget.ingredient == null ? Container() : _productList(),
        ],
      ),
    );
  }

  Expanded _productList() {
    final menu = context.read<MenuModel>();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var ingredient
                in menu.productContainsIngredient(widget.ingredient.id))
              Text(ingredient.product.name)
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;

    final name = _nameController.text;
    final stock = context.read<StockModel>();

    if (widget.ingredient?.name != name && stock.hasContain(name)) {
      return setState(() => errorMessage = '種類名稱重複');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateIngredient(name, stock);
    Navigator.of(context).pop();
  }

  void _updateIngredient(String name, StockModel stock) {
    final amount = double.parse(_amountController.text);

    if (widget.ingredient != null) {
      widget.ingredient.update(name: name, amount: amount);
    } else {
      stock.addIngredient(IngredientModel(name: name, currentAmount: amount));
    }

    stock.changedIngredient();
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
          );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '成份名稱，起司',
        errorText: errorMessage,
        filled: false,
      ),
      maxLength: 30,
      validator: Validator.textLimit('成份名稱', 30),
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '種類名稱，漢堡',
        errorText: errorMessage,
        filled: false,
      ),
      validator: Validator.positiveDouble('種類名稱'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.ingredient.name;
    _amountController.text = widget.ingredient.currentAmount?.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

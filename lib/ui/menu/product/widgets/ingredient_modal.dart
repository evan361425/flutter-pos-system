import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/product_ingredient_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientModal extends StatefulWidget {
  IngredientModal({
    Key key,
    @required this.ingredient,
  }) : super(key: key);

  final ProductIngredientModel ingredient;

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  StockModel stock;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_sharp),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _onSubmit(_nameController.text),
                child: Text('儲存'),
              ),
      ),
      child: SafeArea(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Center(child: _form()),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(String value) async {
    if (!isSaving && _formKey.currentState.validate()) {
      setState(() => isSaving = true);
      if (widget.ingredient.isReady) {
        await widget.ingredient.update(
          defaultAmount: num.parse(_amountController.text),
        );
      } else {
        final ingredient = ProductIngredientModel(
          ingredientId: 'todo',
          product: widget.ingredient.product,
          defaultAmount: num.parse(_amountController.text),
        );
        await widget.ingredient.product.addIngredient(ingredient);
      }
      Navigator.of(context).pop();
    }
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _nameField(),
          SizedBox(height: kMargin),
          _amountField(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '成份名稱，起司',
        filled: false,
        errorStyle: TextStyle(color: kNegativeColor),
      ),
      maxLength: 30,
      validator: (String value) {
        final errorMsg = Validator.textLimit('成份名稱', 30)(value);
        if (errorMsg != null) return errorMsg;
        // if (value != stock[widget.ingredient.id].name &&
        //     widget.ingredient.product.has(value)) {
        //   return '成份名稱重複';
        // }
        return null;
      },
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.send,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '成份預設用量',
        filled: false,
        errorStyle: TextStyle(color: kNegativeColor),
      ),
      onFieldSubmitted: _onSubmit,
      validator: Validator.positiveDouble('成份預設用量'),
    );
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.ingredient.defaultAmount.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    stock = context.watch<StockModel>();
    _nameController.text = stock[widget.ingredient.id].name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

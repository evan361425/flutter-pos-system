import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/product_ingredient_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_search_scaffold.dart';
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

  String _ingredientId;
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
                onPressed: () => _onSubmit(),
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

  Future<void> _onSubmit() async {
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
    final stock = context.read<StockModel>();
    final name = stock[_ingredientId]?.name ?? '';
    return SearchBarInline(
      heroTag: IngredientSearchScaffold.tag,
      text: name,
      hintText: '成份名稱，起司',
      helperText: '新增成份種類後，可至庫存設定相關資訊',
      newPageBuilder: (BuildContext _) => IngredientSearchScaffold(text: name),
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
      onFieldSubmitted: (_) => _onSubmit(),
      validator: Validator.positiveDouble('成份預設用量'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ingredientId = widget.ingredient.id;
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

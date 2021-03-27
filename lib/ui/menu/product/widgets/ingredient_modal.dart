import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/ingredient_model.dart';
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
  final _amountController = TextEditingController();

  bool isSaving = false;
  String errorMessage;
  String ingredientId;
  String ingredientName;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ingredientName.isEmpty ? '新增成份' : '設定成份「$ingredientName」'),
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
            child: Center(child: _form(context)),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!isSaving && _formKey.currentState.validate()) {
      if (ingredientId.isEmpty) {
        return setState(() => errorMessage = '必須設定成份種類。');
      }
      if (widget.ingredient.id != ingredientId &&
          widget.ingredient.product.has(ingredientId)) {
        setState(() => errorMessage = '成份重複。');
        return null;
      }

      setState(() => isSaving = true);
      if (widget.ingredient.isReady) {
        await widget.ingredient.update(
          defaultAmount: num.parse(_amountController.text),
        );
      } else {
        final ingredient = ProductIngredientModel(
          ingredientId: ingredientId,
          product: widget.ingredient.product,
          defaultAmount: num.parse(_amountController.text),
        );
        await widget.ingredient.product.addIngredient(ingredient);
      }
      Navigator.of(context).pop();
    }
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
        final ingredient = await Navigator.of(context)
            .push<IngredientModel>(CupertinoPageRoute(
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/ingredient_set_index_model.dart';
import 'package:possystem/models/product_ingredient_model.dart';
import 'package:possystem/models/product_ingredient_set_model.dart';
import 'package:possystem/models/product_model.dart';
import 'package:possystem/models/stock_model.dart';
import 'package:provider/provider.dart';

class IngredientSetModal extends StatelessWidget {
  IngredientSetModal({
    Key key,
    this.ingredientSet,
    this.product,
    this.ingredient,
  }) : super(key: key);

  final _formKey = GlobalKey<_IngredientSetFormState>();
  final ProductIngredientSetModel ingredientSet;
  final ProductIngredientModel ingredient;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final stock = context.read<StockModel>();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('設定${stock[ingredient.id].name}的特殊份量'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_rounded),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final newSet = _formKey.currentState.getData();
            if (newSet == null) return;

            if (ingredientSet.isNotReady) {
              await ingredient.add(newSet);
            } else {
              await ingredientSet.update(ingredient, newSet);
            }

            product.ingredientChanged();

            Navigator.of(context).pop();
          },
          child: Text(ingredientSet.isNotReady ? '新增' : '儲存'),
        ),
      ),
      child: SafeArea(
        child: Material(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(kPadding),
            child: _IngredientSetForm(
              key: _formKey,
              iSet: ingredientSet,
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientSetForm extends StatefulWidget {
  const _IngredientSetForm({
    Key key,
    @required this.iSet,
  }) : super(key: key);

  final ProductIngredientSetModel iSet;

  @override
  _IngredientSetFormState createState() => _IngredientSetFormState();
}

class _IngredientSetFormState extends State<_IngredientSetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '');
  final _ammountController = TextEditingController();
  final _additionalPriceController = TextEditingController();
  final _additionalCostController = TextEditingController();
  IngredientSetIndexModel ingredietSetIndex;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: '份量名稱',
              filled: false,
            ),
            maxLength: 30,
            validator: Validator.textLimit('份量名稱', 30),
          ),
          SizedBox(height: kMargin),
          TextFormField(
            controller: _ammountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '成分份量',
              filled: false,
            ),
            validator: Validator.positiveDouble('成分份量'),
          ),
          SizedBox(height: kMargin),
          TextFormField(
            controller: _additionalPriceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.loyalty_sharp),
              labelText: '額外售價',
              filled: false,
            ),
            validator: Validator.isDouble('額外售價'),
          ),
          SizedBox(height: kMargin / 2),
          TextFormField(
            controller: _additionalCostController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money_sharp),
              labelText: '額外成本',
              filled: false,
            ),
            validator: Validator.isDouble('額外成本'),
          ),
        ],
      ),
    );
  }

  ProductIngredientSetModel getData() {
    if (!_formKey.currentState.validate()) {
      return null;
    }

    return ProductIngredientSetModel(
      ingredientSetId: 'todo',
      amount: num.parse(_ammountController.text),
      additionalPrice: num.parse(_additionalPriceController.text),
      additionalCost: num.parse(_additionalCostController.text),
    );
  }

  @override
  void initState() {
    print(ingredietSetIndex);
    _ammountController.text = widget.iSet.amount.toString();
    _additionalPriceController.text = widget.iSet.additionalPrice.toString();
    _additionalCostController.text = widget.iSet.additionalCost.toString();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ingredietSetIndex = context.watch<IngredientSetIndexModel>();
    if (ingredietSetIndex.isReady) {
      _nameController.text = ingredietSetIndex[widget.iSet.id]?.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ammountController.dispose();
    _additionalPriceController.dispose();
    _additionalCostController.dispose();
    super.dispose();
  }
}

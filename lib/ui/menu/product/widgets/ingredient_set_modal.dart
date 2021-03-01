import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/models.dart';

class IngredientSetModal extends StatelessWidget {
  IngredientSetModal({
    Key key,
    this.ingredientSet,
    this.product,
    this.ingredient,
  }) : super(key: key);

  final _formKey = GlobalKey<_IngredientSetFormState>();
  final IngredientSet ingredientSet;
  final IngredientModel ingredient;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('設定${ingredient.name}的特殊份量'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(ingredientSet.isNotReady ? '新增' : '儲存'),
          onPressed: () async {
            final newSet = _formKey.currentState.getData();
            if (newSet == null) return;

            if (ingredientSet.isNotReady) {
              await ingredient.add(context, newSet);
            } else {
              await ingredientSet.update(context, newSet, ingredient);
            }

            product.changeIngredient();

            Navigator.of(context).pop();
          },
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

  final IngredientSet iSet;

  @override
  _IngredientSetFormState createState() => _IngredientSetFormState();
}

class _IngredientSetFormState extends State<_IngredientSetForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  TextEditingController _ammountController;
  TextEditingController _additionalPriceController;
  TextEditingController _additionalCostController;

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

  IngredientSet getData() {
    if (!_formKey.currentState.validate()) {
      return null;
    }

    return IngredientSet(
      name: _nameController.text,
      amount: num.parse(_ammountController.text),
      additionalPrice: num.parse(_additionalPriceController.text),
      additionalCost: num.parse(_additionalCostController.text),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.iSet.name);
    _ammountController = TextEditingController(
      text: widget.iSet.amount.toString(),
    );
    _additionalPriceController = TextEditingController(
      text: widget.iSet.additionalPrice.toString(),
    );
    _additionalCostController = TextEditingController(
      text: widget.iSet.additionalCost.toString(),
    );
  }
}

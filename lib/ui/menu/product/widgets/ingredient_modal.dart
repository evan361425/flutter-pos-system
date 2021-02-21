import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/ingredient_model.dart';

// TODO: working on it
class IngredientModal extends StatelessWidget {
  IngredientModal({Key key}) : super(key: key);

  final _formKey = GlobalKey<_IngredientSetFormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: get product name from provider
    final IngredientSet ingredientSet =
        ModalRoute.of(context).settings.arguments ?? IngredientSet(name: '');

    return Scaffold(
      appBar: AppBar(
        title: Text('成分特殊份量'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          FlatButton(
            child: Text(ingredientSet.name.isEmpty ? '新增' : '儲存'),
            onPressed: () {
              final newSet = _formKey.currentState.getData();
              if (newSet == null) return;

              if (ingredientSet.name.isEmpty) {
                // TODO: user provider product fire [addSet()]
              } else if (newSet.name != ingredientSet.name) {
                // TODO: user provider product fire [replaceSet()]
              } else {
                ingredientSet.update(newSet);
              }

              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: _IngredientSetForm(
          key: _formKey,
          iSet: ingredientSet,
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

  IngredientSet getData() {
    if (!_formKey.currentState.validate()) {
      return null;
    }

    return IngredientSet(
      name: _nameController.text,
      ammount: num.parse(_ammountController.text),
      additionalPrice: num.parse(_additionalPriceController.text),
      additionalCost: num.parse(_additionalCostController.text),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.iSet.name);
    _ammountController = TextEditingController(
      text: widget.iSet.ammount.toString(),
    );
    _additionalPriceController = TextEditingController(
      text: widget.iSet.additionalPrice.toString(),
    );
    _additionalCostController = TextEditingController(
      text: widget.iSet.additionalCost.toString(),
    );
  }

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
            ),
            maxLength: 30,
            validator: Validator.textLimit('份量名稱', 30),
          ),
          SizedBox(height: defaultMargin),
          TextFormField(
            controller: _ammountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '成分份量',
            ),
            validator: Validator.positiveDouble('成分份量'),
          ),
          SizedBox(height: defaultMargin),
          TextFormField(
            controller: _additionalPriceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.loyalty_sharp),
              labelText: '額外售價',
            ),
            validator: Validator.isDouble('額外售價'),
          ),
          TextFormField(
            controller: _additionalCostController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money_sharp),
              labelText: '額外成本',
            ),
            validator: Validator.isDouble('額外成本'),
          ),
        ],
      ),
    );
  }
}

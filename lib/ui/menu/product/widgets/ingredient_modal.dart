import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/models.dart';

class IngredientModal extends StatefulWidget {
  IngredientModal({
    Key key,
    @required this.ingredient,
    @required this.product,
  }) : super(key: key);

  final IngredientModel ingredient;
  final ProductModel product;

  @override
  _IngredientModalState createState() => _IngredientModalState();
}

class _IngredientModalState extends State<IngredientModal> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  TextEditingController _nameController;
  TextEditingController _amountController;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('儲存'),
                onPressed: () => _onSubmit(_nameController.text),
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
    if (_formKey.currentState.validate()) {
      setState(() => isSaving = true);
      if (widget.ingredient.isReady) {
        await widget.product.ingredients[widget.ingredient.name].update(
          context,
          widget.product,
          name: _nameController.text,
          amount: num.parse(_amountController.text),
        );
      } else {
        await widget.product.add(
          IngredientModel(
            _nameController.text,
            num.parse(_amountController.text),
          ),
          context,
        );
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
        if (value != widget.ingredient.name && widget.product.has(value)) {
          return '成份名稱重複';
        }
        return null;
      },
    );
  }

  Widget _amountField() {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '成份預設用量',
        filled: false,
        errorStyle: TextStyle(color: kNegativeColor),
      ),
      validator: Validator.positiveDouble('成份預設用量'),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _amountController =
        TextEditingController(text: widget.ingredient.defaultAmount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/components/custom_styles.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';

class IngredientScreen extends StatefulWidget {
  final IngredientModel? ingredient;

  final bool isNew;

  IngredientScreen({Key? key, this.ingredient})
      : isNew = ingredient == null,
        super(key: key);

  @override
  _IngredientScreenState createState() => _IngredientScreenState();
}

class _IngredientScreenState extends State<IngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool isSaving = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleSubmit(),
            child: Text('儲存'),
          ),
        ],
      ),
      body: Routes.setUpStockMode(context) ? _body() : CircularLoading(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameController.text = widget.ingredient?.name ?? '';
    _amountController.text = widget.ingredient?.currentAmount.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Column _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _fieldName(),
                _fieldAmount(),
              ],
            ),
          ),
        ),
        if (widget.ingredient != null) ..._fieldProducts(),
      ],
    );
  }

  Widget _fieldAmount() {
    return TextFormField(
      controller: _amountController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '庫存',
        errorText: errorMessage,
        filled: false,
      ),
      validator: Validator.positiveNumber('庫存'),
    );
  }

  Widget _fieldName() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '成份名稱，起司',
        errorText: errorMessage,
        filled: false,
      ),
      autofocus: widget.ingredient == null,
      maxLength: 30,
      validator: Validator.textLimit('成份名稱', 30),
    );
  }

  List<Widget> _fieldProducts() {
    final ingredients =
        MenuModel.instance.getIngredients(widget.ingredient!.id);

    return [
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
        child: Text(
          '使用 ${widget.ingredient!.name} 的產品',
          style: Theme.of(context).textTheme.muted,
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (var ingredient in ingredients)
                CardTile(
                  title: Text(
                    '${ingredient.product.catalog.name} - ${ingredient.product.name}',
                  ),
                  // TODO: add link to product
                  onTap: () {},
                )
            ],
          ),
        ),
      )
    ];
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    await _updateIngredient();

    Navigator.of(context).pop();
  }

  IngredientObject _parseObject() {
    return IngredientObject(
      name: _nameController.text,
      currentAmount: num.tryParse(_amountController.text),
    );
  }

  Future<void> _updateIngredient() async {
    final object = _parseObject();

    if (widget.isNew) {
      final ingredient = IngredientModel(
        name: object.name!,
        currentAmount: object.currentAmount!,
      );

      await StockModel.instance.setItem(ingredient);
    } else {
      await widget.ingredient!.update(object);
    }
  }

  bool _validate() {
    if (isSaving || !_formKey.currentState!.validate()) return false;

    final name = _nameController.text;

    if (widget.ingredient?.name != name && StockModel.instance.hasItem(name)) {
      setState(() => errorMessage = '成份名稱重複');
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}

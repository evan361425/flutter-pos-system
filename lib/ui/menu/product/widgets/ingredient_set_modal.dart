import 'package:flutter/material.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/repository/ingredient_set_index_model.dart';
import 'package:possystem/models/stock/ingredient_set_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_ingredient_set_model.dart';
import 'package:provider/provider.dart';

import 'ingredient_set_search_scaffold.dart';

class IngredientSetModal extends StatefulWidget {
  IngredientSetModal({
    Key key,
    this.ingredientSetName,
    this.ingredientSet,
    this.ingredient,
  }) : super(key: key);

  final String ingredientSetName;
  final ProductIngredientSetModel ingredientSet;
  final ProductIngredientModel ingredient;

  @override
  _IngredientSetModalState createState() => _IngredientSetModalState();
}

class _IngredientSetModalState extends State<IngredientSetModal> {
  final _formKey = GlobalKey<FormState>();
  final _ammountController = TextEditingController();
  final _additionalPriceController = TextEditingController();
  final _additionalCostController = TextEditingController();

  bool isSaving = false;
  String ingredientSetName;
  String ingredientSetId;
  String errorMessage;

  void _onSubmit() {
    final newSet = _getSet();
    if (newSet == null) return;

    if (widget.ingredientSet.isNotReady) {
      widget.ingredient.addIngredientSet(newSet);
    } else {
      widget.ingredientSet.update(widget.ingredient, newSet);
    }

    widget.ingredient.product.ingredientChanged();

    Navigator.of(context).pop();
  }

  ProductIngredientSetModel _getSet() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    if (ingredientSetId.isEmpty) {
      setState(() => errorMessage = '必須設定成份份量名稱。');
      return null;
    }
    if (widget.ingredientSet.id != ingredientSetId &&
        widget.ingredient.has(ingredientSetId)) {
      setState(() => errorMessage = '成份份量重複。');
      return null;
    }

    return ProductIngredientSetModel(
      ingredientSetId: ingredientSetId,
      amount: num.parse(_ammountController.text),
      additionalPrice: num.parse(_additionalPriceController.text),
      additionalCost: num.parse(_additionalCostController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ingredientSet.isNotReady
            ? '新增成份份量'
            : '設定成份份量「${widget.ingredientSetName}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        actions: [_trailingAction()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kPadding),
          child: _form(context),
        ),
      ),
    );
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          _nameSearchBar(),
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

  Widget _nameSearchBar() {
    return SearchBarInline(
      heroTag: IngredientSetSearchScaffold.tag,
      text: ingredientSetName,
      hintText: '成份份量名稱，例如：少量',
      errorText: errorMessage,
      helperText: '新增成份份量後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final ingredientSet = await Navigator.of(context)
            .push<IngredientSetModel>(MaterialPageRoute(
          builder: (_) => IngredientSetSearchScaffold(text: ingredientSetName),
        ));

        if (ingredientSet != null) {
          print('User choose ingreidnet set: ${ingredientSet.name}');
          setState(() {
            errorMessage = null;
            ingredientSetId = ingredientSet.id;
            ingredientSetName = ingredientSet.name;
            _updateByProportion(ingredientSet.defaultProportion);
          });
        }
      },
    );
  }

  void _updateByProportion(double proportion) {
    _ammountController.text =
        (widget.ingredient.defaultAmount * proportion).toString();
    _additionalPriceController.text =
        (widget.ingredient.product.price * proportion).toString();
    _additionalCostController.text =
        (widget.ingredient.product.cost * proportion).toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ingredientSetId = widget.ingredientSet.id ?? '';
    final ingredientSetIndex = context.read<IngredientSetIndexModel>();
    ingredientSetName = ingredientSetIndex[widget.ingredientSet.id]?.name ?? '';
  }

  @override
  void initState() {
    _ammountController.text = widget.ingredientSet.amount.toString();
    _additionalPriceController.text =
        widget.ingredientSet.additionalPrice.toString();
    _additionalCostController.text =
        widget.ingredientSet.additionalCost.toString();
    super.initState();
  }

  @override
  void dispose() {
    _ammountController.dispose();
    _additionalPriceController.dispose();
    _additionalCostController.dispose();
    super.dispose();
  }
}

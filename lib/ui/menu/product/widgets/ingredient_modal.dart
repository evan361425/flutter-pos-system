import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/ui/menu/product/widgets/ingredient_search_scaffold.dart';

class IngredientModal extends StatefulWidget {
  IngredientModal({
    Key key,
    this.product,
    this.ingredient,
    this.ingredientName,
  })  : isNew = ingredient == null,
        super(key: key);

  final ProductModel product;
  final ProductIngredientModel ingredient;
  final String ingredientName;
  final bool isNew;

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

  void _onDelete() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (BuildContext context) {
            widget.product.removeIngredient(widget.ingredient);
          },
        );
      },
    );
  }

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;
    if (ingredientId.isEmpty) {
      return setState(() => errorMessage = '必須設定成份種類。');
    }
    if (widget.ingredient?.id != ingredientId &&
        widget.product.has(ingredientId)) {
      return setState(() => errorMessage = '成份重複。');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateIngredient();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? '新增成份' : '設定成份「${widget.ingredientName}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _nameField(context),
                  SizedBox(height: kMargin),
                  _amountField(context),
                ],
              ),
            ),
            Spacer(),
            widget.isNew
                ? Container()
                : SingleChildScrollView(
                    child: ElevatedButton(
                      onPressed: _onDelete,
                      style: ElevatedButton.styleFrom(primary: kNegativeColor),
                      child: Text(
                        '刪除${widget.product.name}的成份 ${widget.ingredientName}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _updateIngredient() {
    final ingredient = widget.isNew
        ? ProductIngredientModel(
            ingredientId: ingredientId,
            product: widget.product,
            defaultAmount: num.parse(_amountController.text),
          )
        : widget.ingredient;

    if (!widget.isNew) {
      ingredient.update(
        ingredientId: ingredientId,
        defaultAmount: num.parse(_amountController.text),
      );
    }

    widget.product.updateIngredient(ingredient);
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularProgressIndicator()
        : TextButton(
            onPressed: () => _onSubmit(),
            child: Text('儲存'),
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
        final ingredient =
            await Navigator.of(context).push<IngredientModel>(MaterialPageRoute(
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
    ingredientId = widget.ingredient?.id ?? '';
    ingredientName = widget.ingredientName ?? '';
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.ingredient?.defaultAmount?.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

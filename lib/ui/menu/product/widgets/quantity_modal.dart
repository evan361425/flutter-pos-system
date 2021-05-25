import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/danger_button.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/search_bar_inline.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';

import 'quantity_search_scaffold.dart';

class QuantityModal extends StatefulWidget {
  QuantityModal({
    Key key,
    this.quantity,
  })  : isNew = quantity.id == null,
        assert(quantity.ingredient != null),
        super(key: key);

  final ProductQuantityModel quantity;
  final bool isNew;

  @override
  _QuantityModalState createState() => _QuantityModalState();
}

class _QuantityModalState extends State<QuantityModal> {
  final _formKey = GlobalKey<FormState>();
  final _ammountController = TextEditingController();
  final _additionalPriceController = TextEditingController();
  final _additionalCostController = TextEditingController();

  bool isSaving = false;
  String quantityName;
  String quantityId;
  String errorMessage;

  void _onSubmit() {
    if (isSaving || !_formKey.currentState.validate()) return;
    if (quantityId.isEmpty) {
      return setState(() => errorMessage = '必須設定成份份量名稱。');
    }
    if (widget.quantity.id != quantityId &&
        widget.quantity.ingredient.exist(quantityId)) {
      return setState(() => errorMessage = '成份份量重複。');
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    _updateQuantity();

    Navigator.of(context).pop();
  }

  Future<void> _onDelete() async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: Text('此動作將無法復原'),
          onDelete: (_) => widget.quantity.remove(),
        );
      },
    );
    if (isDeleted == true) Navigator.of(context).pop();
  }

  void _updateQuantity() {
    final object = ProductQuantityObject(
      id: quantityId,
      amount: num.tryParse(_ammountController.text),
      additionalPrice: num.tryParse(_additionalPriceController.text),
      additionalCost: num.tryParse(_additionalCostController.text),
    );

    if (widget.isNew) {
      final quantity = ProductQuantityModel(
        quantity: QuantityRepo.instance.getQuantity(object.id),
        ingredient: widget.quantity.ingredient,
        amount: object.amount,
        additionalPrice: object.additionalPrice,
        additionalCost: object.additionalCost,
      );

      quantity.ingredient.updateQuantity(quantity);
    } else {
      widget.quantity.update(object);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew
            ? '新增成份份量'
            : '設定成份份量「${widget.quantity.quantity.name}」'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [_trailingAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _form(context),
              _deleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    if (widget.isNew) return Container();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kSpacing2),
      child: DangerButton(
        onPressed: _onDelete,
        child: Text('刪除份量 ${widget.quantity.quantity.name}'),
      ),
    );
  }

  Widget _trailingAction() {
    return isSaving
        ? CircularLoading()
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
          _quantitySearchBar(),
          SizedBox(height: kSpacing2),
          TextFormField(
            controller: _ammountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '成分份量',
              filled: false,
            ),
            validator: Validator.positiveNumber('成分份量'),
          ),
          SizedBox(height: kSpacing2),
          TextFormField(
            controller: _additionalPriceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.loyalty_sharp),
              labelText: '額外售價',
              filled: false,
            ),
            validator: Validator.isNumber('額外售價'),
          ),
          SizedBox(height: kSpacing1),
          TextFormField(
            controller: _additionalCostController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money_sharp),
              labelText: '額外成本',
              filled: false,
            ),
            validator: Validator.isNumber('額外成本'),
          ),
        ],
      ),
    );
  }

  Widget _quantitySearchBar() {
    return SearchBarInline(
      heroTag: QuantitySearchScaffold.tag,
      text: quantityName,
      hintText: '成份份量名稱，例如：少量',
      errorText: errorMessage,
      helperText: '新增成份份量後，可至庫存設定相關資訊',
      onTap: (BuildContext context) async {
        final quantity = await Navigator.of(context).pushNamed(
          MenuRoutes.productQuantitySearch,
          arguments: quantityName,
        );

        if (quantity != null && quantity is QuantityModel) {
          print('User choose quantity: ${quantity.name}');
          setState(() {
            errorMessage = null;
            quantityId = quantity.id;
            quantityName = quantity.name;
            _updateByProportion(quantity.defaultProportion);
          });
        }
      },
    );
  }

  void _updateByProportion(num proportion) {
    _ammountController.text =
        (widget.quantity.ingredient.amount * proportion).toString();
    _additionalPriceController.text = '0';
    _additionalCostController.text = '0';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    quantityId = widget.quantity?.id ?? '';
    quantityName = widget.quantity?.quantity?.name ?? '';
  }

  @override
  void initState() {
    _ammountController.text = widget.quantity?.amount?.toString();
    _additionalPriceController.text =
        widget.quantity?.additionalPrice?.toString();
    _additionalCostController.text =
        widget.quantity?.additionalCost?.toString();
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

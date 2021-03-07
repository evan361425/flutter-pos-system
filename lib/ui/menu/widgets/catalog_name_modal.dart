import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helper/validator.dart';
import 'package:possystem/models/catalog_model.dart';
import 'package:possystem/models/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:provider/provider.dart';

class CatalogNameModal extends StatefulWidget {
  CatalogNameModal({Key key, this.oldName = ''}) : super(key: key);

  final String oldName;

  @override
  _CatalogNameModalState createState() => _CatalogNameModalState();
}

class _CatalogNameModalState extends State<CatalogNameModal> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  TextEditingController _controller;
  MenuModel menu;

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
                onPressed: () => _onSubmit(_controller.text),
              ),
      ),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Center(
            child: Form(
              key: _formKey,
              child: _nameField(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(String value) async {
    if (!isSaving && _formKey.currentState.validate()) {
      setState(() => isSaving = true);
      if (widget.oldName.isEmpty) {
        final catalog = CatalogModel(name: value, index: menu.length);
        await menu.add(catalog);
        await Navigator.of(context)
            .popAndPushNamed(Routes.catalog, arguments: catalog);
      } else {
        await menu[widget.oldName].update(menu, name: value);
        Navigator.of(context).pop();
      }
    }
  }

  Widget _nameField() {
    return TextFormField(
      controller: _controller,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: '種類名稱，漢堡',
        filled: false,
        errorStyle: TextStyle(color: kNegativeColor),
      ),
      onFieldSubmitted: _onSubmit,
      maxLength: 30,
      validator: (String value) {
        final errorMsg = Validator.textLimit('種類名稱', 30)(value);
        if (errorMsg != null) return errorMsg;
        if (value != widget.oldName && menu.has(value)) return '種類名稱重複';
        return null;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.oldName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    menu = context.read<MenuModel>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

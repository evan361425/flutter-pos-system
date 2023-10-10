import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';

mixin ItemModal<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  bool isSaving = false;

  String get title;

  Widget buildBody() {
    final fields = buildFormFields()
        .expand((field) => [field, const SizedBox(height: kSpacing2)])
        .toList();
    fields.removeLast();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: Center(child: buildForm(fields)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(title),
        actions: [
          TextButton(
            key: const Key('modal.save'),
            onPressed: () => handleSubmit(),
            child: Text(MaterialLocalizations.of(context).saveButtonLabel),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildForm(List<Widget> fields) {
    return Form(
      key: formKey,
      child: Column(
        children: fields,
      ),
    );
  }

  /// Fields in form
  List<Widget> buildFormFields();

  /// Handle user submission
  Future<void> handleSubmit() async {
    if (isSaving || !_validate()) return;

    await updateItem();
  }

  Future<void> updateItem();

  bool _validate() {
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    setState(() {
      isSaving = true;
    });

    return true;
  }
}

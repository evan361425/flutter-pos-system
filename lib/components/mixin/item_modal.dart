import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

mixin ItemModal<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  bool isSaving = false;

  String? errorMessage;

  Widget? get title => null;

  Widget body() {
    final fields = formFields()
        .expand((field) => [field, const SizedBox(height: kSpacing2)])
        .toList();
    fields.removeLast();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kSpacing3),
        child: Center(child: form(fields)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: title,
        actions: [
          AppbarTextButton(
            key: const Key('modal.save'),
            onPressed: () => handleSubmit(),
            child: Text(S.btnSave),
          ),
        ],
      ),
      body: body(),
    );
  }

  Widget form(List<Widget> fields) {
    return Form(
      key: formKey,
      child: Column(
        children: fields,
      ),
    );
  }

  /// Fields in form
  List<Widget> formFields();

  /// Handle user submission
  Future<void> handleSubmit() async {
    if (!_validate()) return;

    await updateItem();
  }

  Future<void> updateItem();

  String? validate();

  bool _validate() {
    if (isSaving || !formKey.currentState!.validate()) return false;

    final error = validate();
    if (error != null) {
      setState(() => errorMessage = error);
      return false;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    return true;
  }
}

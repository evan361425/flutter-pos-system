import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/constants/constant.dart';

mixin ItemModal<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  bool _isSaving = false;

  String get title;

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(title),
      action: TextButton(
        key: const Key('modal.save'),
        onPressed: () => handleSubmit(),
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
      scaffoldMessengerKey: scaffoldMessengerKey,
      floatingActionButton: buildFloatingActionButton(),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            ...buildFormFields(),
            const SizedBox(height: kDialogBottomSpacing),
          ],
        ),
      ),
    );
  }

  /// Fields in form
  List<Widget> buildFormFields();

  /// Build floating action button if needed
  Widget? buildFloatingActionButton() => null;

  /// Handle submission from input field (e.g. onFieldSubmitted)
  void handleFieldSubmit(String _) {
    handleSubmit();
  }

  /// Handle user submission
  Future<void> handleSubmit() async {
    if (_isSaving || !_validate()) return;

    _isSaving = true;

    try {
      await updateItem();
    } finally {
      _isSaving = false;
    }
  }

  /// Update item implementation, called when the form is valid
  Future<void> updateItem();

  bool _validate() {
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    return true;
  }

  /// Padding widget
  Widget p(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
      child: child,
    );
  }
}

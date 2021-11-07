import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';

class DeleteDialog extends StatelessWidget {
  final Widget content;

  const DeleteDialog({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(S.dialogDeletionTitle),
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        PopButton(title: S.btnCancel),
        ElevatedButton(
          key: const Key('delete_dialog.confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            primary: theme.errorColor,
            onPrimary: Colors.white,
          ),
          child: Text(S.btnDelete),
        ),
      ],
    );
  }

  /// Show [DeleteDialog]
  ///
  /// [warningContent] - Content of warning in [DeleteDialog], `null` to disable confirm
  /// [deleteCallback] - Callback after confirmed
  /// [popAfterDeleted] - Wheather `Navigator.of(context).pop` after deleted
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() deleteCallback,
    bool popAfterDeleted = false,
    Widget? warningContent,
  }) async {
    startDelete() async {
      await deleteCallback();
      showSuccessSnackbar(context, S.actSuccess);

      if (popAfterDeleted) {
        Navigator.of(context).pop();
      }
    }

    // Directly delete if no content given
    if (warningContent == null) {
      return startDelete();
    }

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteDialog(
        content: warningContent,
      ),
    );

    if (isConfirmed == true) {
      return startDelete();
    }
  }
}

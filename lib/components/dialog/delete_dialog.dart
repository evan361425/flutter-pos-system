import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/translator.dart';

class DeleteDialog extends StatelessWidget {
  final Widget content;

  const DeleteDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(S.dialogDeletionTitle),
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        PopButton(title: local.cancelButtonLabel),
        FilledButton(
          key: const Key('delete_dialog.confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
          ),
          child: Text(local.deleteButtonTooltip),
        ),
      ],
    );
  }

  /// Show [DeleteDialog]
  ///
  /// [warningContent] - Content of warning in [DeleteDialog], `null` to disable confirm
  /// [deleteCallback] - Callback after confirmed
  /// [popAfterDeleted] - Whether `Navigator.of(context).pop` after deleted
  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function() deleteCallback,
    bool popAfterDeleted = false,
    bool finishMessage = true,
    Widget? warningContent,
  }) async {
    startDelete() async {
      await deleteCallback();
      if (context.mounted && finishMessage) {
        showSnackBar(context, S.actSuccess);
      }

      if (popAfterDeleted) {
        if (context.mounted && context.canPop()) {
          context.pop();
        }
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
      await startDelete();
    }
    return isConfirmed;
  }
}

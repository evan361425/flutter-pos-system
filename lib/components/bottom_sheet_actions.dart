import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

import 'dialog/delete_dialog.dart';

Future<T?> showCircularBottomSheet<T>(
  BuildContext context, {
  required List<BottomSheetAction> actions,
  bool useRootNavigator = true,
}) {
  Feedback.forLongPress(context);
  final size = MediaQuery.of(context).size;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    clipBehavior: Clip.hardEdge,
    constraints: BoxConstraints(maxWidth: size.width - 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => SingleChildScrollView(
      child: BottomSheetActions(actions: actions),
    ),
  );
}

class BottomSheetAction<T> {
  final Widget title;

  final Widget? leading;

  final T? returnValue;

  final String? navigateRoute;

  final dynamic navigateArgument;

  final Key? key;

  const BottomSheetAction({
    required this.title,
    this.key,
    this.leading,
    this.returnValue,
    this.navigateRoute,
    this.navigateArgument,
  }) : assert(returnValue != null || navigateRoute != null);

  Widget toWidget(BuildContext context) {
    return ListTile(
      key: key,
      enableFeedback: true,
      leading: leading,
      title: title,
      onTap: () => navigateRoute == null
          ? Navigator.of(context).pop(returnValue)
          : Navigator.of(context).pushReplacementNamed(
              navigateRoute!,
              arguments: navigateArgument,
            ),
    );
  }
}

class BottomSheetActions extends StatelessWidget {
  final List<BottomSheetAction> actions;

  const BottomSheetActions({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _heading(context),
      ...[for (final action in actions) action.toWidget(context)],
      _cancelAction(context),
    ]);
  }

  Widget _cancelAction(BuildContext context) {
    return ListTile(
      title: Text(S.btnCancel),
      leading: const Icon(Icons.cancel_sharp),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _heading(BuildContext context) {
    return Container(
      height: 4.0,
      width: 36.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceTint,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  /// Add action with deletion
  ///
  /// [actions] - Custom actions
  /// [deleteValue] - Action type
  /// [warningContent] - Content of warning in [DeleteDialog], `null` to disable confirm
  /// [deleteCallback] - Callback after confirmed
  /// [popAfterDeleted] - Whether `Navigator.of(context).pop` after deleted
  static Future<T?> withDelete<T>(
    BuildContext context, {
    List<BottomSheetAction> actions = const [],
    required T deleteValue,
    Widget? warningContent,
    required Future<void> Function() deleteCallback,
    bool popAfterDeleted = false,
  }) async {
    final result = await showCircularBottomSheet<T>(context, actions: [
      ...actions,
      BottomSheetAction(
        key: const Key('btn.delete'),
        title: Text(S.btnDelete),
        leading: Icon(
          KIcons.delete,
          color: Theme.of(context).colorScheme.error,
        ),
        returnValue: deleteValue,
      ),
    ]);

    if (result == deleteValue) {
      if (context.mounted) {
        await DeleteDialog.show(
          context,
          deleteCallback: deleteCallback,
          warningContent: warningContent,
          popAfterDeleted: popAfterDeleted,
        );
      }

      return null;
    }

    return result;
  }
}

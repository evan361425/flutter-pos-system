import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

import 'dialog/delete_dialog.dart';

Future<T?> showCircularBottomSheet<T>(
  BuildContext context, {
  List<BottomSheetAction>? actions,
  bool useRootNavigator = true,
  WidgetBuilder? builder,
}) {
  assert(actions != null || builder != null);

  Feedback.forLongPress(context);

  return showMaterialModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    useRootNavigator: useRootNavigator,
    builder: builder ?? (_) => BottomSheetActions(actions: actions!),
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
    return Material(
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _title(context),
          ...[for (final action in actions) action.toWidget(context)],
          _cancelAction(context),
        ]),
      ),
    );
  }

  Widget _cancelAction(BuildContext context) {
    return ListTile(
      title: Text(S.btnCancel),
      leading: const Icon(Icons.cancel_sharp),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSpacing0),
      child: Center(child: Text(S.bottomSheetActionsTitle)),
    );
  }

  /// Add action with deletion
  ///
  /// [actions] - Custom actions
  /// [deleteValue] - Action type
  /// [warningContent] - Content of warning in [DeleteDialog], `null` to disable confirm
  /// [deleteCallback] - Callback after confirmed
  /// [popAfterDeleted] - Wheather `Navigator.of(context).pop` after deleted
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
          color: Theme.of(context).errorColor,
        ),
        returnValue: deleteValue,
      ),
    ]);

    if (result == deleteValue) {
      await DeleteDialog.show(
        context,
        deleteCallback: deleteCallback,
        warningContent: warningContent,
        popAfterDeleted: popAfterDeleted,
      );

      return null;
    }

    return result;
  }
}

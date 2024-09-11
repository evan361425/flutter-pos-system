import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';

import 'dialog/delete_dialog.dart';

Future<T?> showCircularBottomSheet<T>(
  BuildContext context, {
  required List<BottomSheetAction<T>> actions,
}) {
  Feedback.forLongPress(context);
  final size = MediaQuery.sizeOf(context);
  final bp = Breakpoint.find(width: size.width);

  if (bp <= Breakpoint.medium) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
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

  // copy from [flutter/src/material/popup_menu.dart]
  final RenderBox widget = context.findRenderObject()! as RenderBox;
  final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final Offset offset = Offset(0, widget.size.height);
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      widget.localToGlobal(offset, ancestor: overlay),
      widget.localToGlobal(widget.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  return showMenu(
    context: context,
    position: position,
    clipBehavior: Clip.hardEdge,
    items: [
      for (final action in actions) action.toPopupMenuItem(context),
    ],
  );
}

class BottomSheetAction<T> {
  final Widget title;

  final Widget leading;

  final T? returnValue;

  final String? route;

  final Key? key;

  final Map<String, String> routePathParameters;

  final Map<String, dynamic> routeQueryParameters;

  const BottomSheetAction({
    this.key,
    required this.title,
    required this.leading,
    this.returnValue,
    this.route,
    this.routePathParameters = const <String, String>{},
    this.routeQueryParameters = const <String, dynamic>{},
  }) : assert(returnValue != null || route != null);

  Widget toListTile(BuildContext context) {
    return ListTile(
      key: key,
      enableFeedback: true,
      leading: leading,
      title: title,
      onTap: () async {
        if (context.mounted) {
          Navigator.of(context).pop(returnValue);
        }
        await onTap(context);
      },
    );
  }

  PopupMenuItem<T> toPopupMenuItem(BuildContext context) {
    return PopupMenuItem<T>(
      key: key,
      value: returnValue,
      onTap: () => onTap(context),
      child: ListTile(leading: leading, title: title),
    );
  }

  Future<void> onTap(BuildContext context) async {
    if (route != null && context.mounted) {
      await context.pushNamed(
        route!,
        pathParameters: routePathParameters,
        queryParameters: routeQueryParameters,
      );
    }
  }
}

class BottomSheetActions extends StatelessWidget {
  final List<BottomSheetAction> actions;

  const BottomSheetActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _buildHeading(context),
      ...[for (final action in actions) action.toListTile(context)],
      _buildCancelAction(context),
    ]);
  }

  Widget _buildCancelAction(BuildContext context) {
    return ListTile(
      title: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      leading: const Icon(KIcons.cancel),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildHeading(BuildContext context) {
    return Container(
      height: 4.0,
      width: 36.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
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
    List<BottomSheetAction<T>> actions = const [],
    required T deleteValue,
    Widget? warningContent,
    required Future<void> Function() deleteCallback,
    bool popAfterDeleted = false,
  }) async {
    final local = MaterialLocalizations.of(context);
    final result = await showCircularBottomSheet<T>(context, actions: [
      ...actions,
      BottomSheetAction(
        key: const Key('btn.delete'),
        title: Text(local.deleteButtonTooltip),
        leading: const Icon(KIcons.delete),
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

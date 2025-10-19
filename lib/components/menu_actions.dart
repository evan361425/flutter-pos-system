import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/constants/icons.dart';

import 'dialog/delete_dialog.dart';

Future<T?> showPositionedMenu<T>(
  BuildContext context, {
  required List<MenuAction<T>> actions,
}) {
  // copy from [flutter/src/material/popup_menu.dart]
  final widget = context.findRenderObject();
  var position = const RelativeRect.fromLTRB(0, 0, 0, 0);
  if (widget is RenderBox) {
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Offset offset = Offset(0, widget.size.height);
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.localToGlobal(offset, ancestor: overlay),
        widget.localToGlobal(widget.size.bottomRight(Offset.zero) + offset, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
  }

  return showMenu(
    context: context,
    position: position,
    clipBehavior: Clip.hardEdge,
    items: [
      for (final action in actions) action.toPopupMenuItem(context),
    ],
  );
}

class MenuAction<T> {
  final Widget title;

  final Widget leading;

  final T? returnValue;

  final String? route;

  final Key? key;

  final Map<String, String> routePathParameters;

  final Map<String, dynamic> routeQueryParameters;

  const MenuAction({
    this.key,
    required this.title,
    required this.leading,
    this.returnValue,
    this.route,
    this.routePathParameters = const <String, String>{},
    this.routeQueryParameters = const <String, dynamic>{},
  }) : assert(returnValue != null || route != null);

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

class MenuActionGroup {
  /// Add action with deletion
  ///
  /// [actions] - Custom actions
  /// [deleteValue] - Action type
  /// [warningContent] - Content of warning in [DeleteDialog], `null` to disable confirm
  /// [deleteCallback] - Callback after confirmed
  /// [popAfterDeleted] - Whether `Navigator.of(context).pop` after deleted
  static Future<T?> withDelete<T>(
    BuildContext context, {
    List<MenuAction<T>> actions = const [],
    required T deleteValue,
    String? warningContent,
    required Future<void> Function() deleteCallback,
    bool popAfterDeleted = false,
  }) async {
    final local = MaterialLocalizations.of(context);
    final result = await showPositionedMenu<T>(context, actions: [
      ...actions,
      MenuAction(
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
          content: warningContent,
          deleteCallback: deleteCallback,
          popAfterDeleted: popAfterDeleted,
        );
      }

      return null;
    }

    return result;
  }
}

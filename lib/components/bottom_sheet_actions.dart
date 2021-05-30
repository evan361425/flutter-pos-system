import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:possystem/constants/constant.dart';

class BottomSheetActions extends StatelessWidget {
  final List<Widget>? actions;
  const BottomSheetActions({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _title(context),
          ...actions!,
          _cancelAction(context),
        ]),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSpacing0),
      child: Center(child: Text('執行動作')),
    );
  }

  Widget _cancelAction(BuildContext context) {
    return ListTile(
      title: Text('取消'),
      leading: Icon(Icons.cancel_sharp),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

Future<T?> showCircularBottomSheet<T>(
  BuildContext context, {
  Iterable<Widget>? actions,
  bool? useRootNavigator,
  Widget Function(BuildContext)? builder,
}) {
  return showMaterialModalBottomSheet<T>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    useRootNavigator: useRootNavigator ?? true,
    builder: builder ?? ((_) => BottomSheetActions(actions: actions as List<Widget>?)),
  );
}

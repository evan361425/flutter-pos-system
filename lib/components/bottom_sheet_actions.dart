import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

Future<T?> showCircularBottomSheet<T>(
  BuildContext context, {
  List<Widget>? actions,
  bool useRootNavigator = true,
  WidgetBuilder? builder,
}) {
  assert(actions != null || builder != null);

  return showMaterialModalBottomSheet<T>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    useRootNavigator: useRootNavigator,
    builder: builder ?? (_) => BottomSheetActions(actions: actions!),
  );
}

class BottomSheetActions extends StatelessWidget {
  final List<Widget> actions;

  const BottomSheetActions({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _title(context),
          ...actions,
          _cancelAction(context),
        ]),
      ),
    );
  }

  Widget _cancelAction(BuildContext context) {
    return ListTile(
      title: Text(tt('cancel')),
      leading: Icon(Icons.cancel_sharp),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSpacing0),
      child: Center(child: Text(tt('action_title'))),
    );
  }
}

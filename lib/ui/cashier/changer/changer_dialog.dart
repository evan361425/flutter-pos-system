import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog_custom.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog_favorite.dart';

class ChangerDialog extends StatefulWidget {
  ChangerDialog({Key? key}) : super(key: key);

  @override
  _ChangerDialogState createState() => _ChangerDialogState();
}

class _ChangerDialogState extends State<ChangerDialog>
    with TickerProviderStateMixin {
  late TabController controller;
  final customState = GlobalKey<ChangerDialogCustomState>();
  final favoriteState = GlobalKey<ChangerDialogFavoriteState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // tab widgets
    final tabBar = TabBar(
      controller: controller,
      indicatorColor: theme.primaryColor,
      labelColor: theme.primaryColor,
      unselectedLabelColor: theme.hintColor,
      tabs: [
        Tab(text: '常用'),
        Tab(text: '手動'),
      ],
    );
    final tabBarView = TabBarView(controller: controller, children: [
      ChangerDialogFavorite(
        key: favoriteState,
        handleAdd: () => controller.animateTo(1),
      ),
      ChangerDialogCustom(
        key: customState,
        handleFavoriteAdded: () {
          controller.animateTo(0);
          favoriteState.currentState?.reset();
        },
      ),
    ]);

    // copy from [AlertDialog]
    final actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.fromLTRB(kSpacing0, 0, kSpacing0, kSpacing0),
      child: OverflowBar(
          spacing: kSpacing0,
          overflowAlignment: OverflowBarAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tt('cancel')),
            ),
            ElevatedButton(
              onPressed: handleApply,
              child: Text('套用'),
            ),
          ]),
    );

    return SingleChildScrollView(
      child: Dialog(
        child: DefaultTabController(
          length: tabBar.tabs.length,
          child: Container(
            height: MediaQuery.of(context).size.height - 72.0,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              tabBar,
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(kSpacing2),
                    child: tabBarView),
              ),
              actions,
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleApply() async {
    final isValid = controller.index == 1
        ? await customState.currentState?.handleApply()
        : await favoriteState.currentState?.handleApply();

    if (isValid == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }
}

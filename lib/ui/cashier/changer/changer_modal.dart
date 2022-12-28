import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';

import 'changer_modal_custom.dart';
import 'changer_modal_favorite.dart';

class ChangerModal extends StatefulWidget {
  const ChangerModal({Key? key}) : super(key: key);

  @override
  ChangerModalState createState() => ChangerModalState();
}

class ChangerModalState extends State<ChangerModal>
    with TickerProviderStateMixin {
  late TabController controller;
  final customState = GlobalKey<ChangerModalCustomState>();
  final favoriteState = GlobalKey<ChangerModalFavoriteState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // tab widgets
    final tabBar = TabBar(
      controller: controller,
      labelColor: theme.indicatorColor,
      unselectedLabelColor: theme.hintColor,
      tabs: const [
        Tab(key: Key('cashier.changer.favorite'), text: '常用'),
        Tab(key: Key('cashier.changer.custom'), text: '手動'),
      ],
    );
    final tabBarView = TabBarView(controller: controller, children: [
      ChangerModalFavorite(
        key: favoriteState,
        emptyAction: () => controller.animateTo(1),
      ),
      ChangerModalCustom(
        key: customState,
        afterFavoriteAdded: () => controller.animateTo(0),
      ),
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const PopButton(),
        title: const Text('換錢'),
        actions: [
          AppbarTextButton(
            key: const Key('cashier.changer.apply'),
            onPressed: handleApply,
            child: const Text('套用'),
          ),
        ],
      ),
      body: DefaultTabController(
        length: tabBar.tabs.length,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          tabBar,
          Expanded(child: tabBarView),
        ]),
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

    if (isValid == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }
}

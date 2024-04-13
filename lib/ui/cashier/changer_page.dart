import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

import 'widgets/changer_custom_view.dart';
import 'widgets/changer_favorite_view.dart';

class ChangerModal extends StatefulWidget {
  const ChangerModal({super.key});

  @override
  State<ChangerModal> createState() => _ChangerModalState();
}

class _ChangerModalState extends State<ChangerModal> with TickerProviderStateMixin {
  late TabController controller;
  final customState = GlobalKey<ChangerCustomViewState>();
  final favoriteState = GlobalKey<ChangerFavoriteViewState>();

  @override
  Widget build(BuildContext context) {
    // tab widgets
    final tabBar = TabBar(
      controller: controller,
      tabs: [
        Tab(key: const Key('changer.favorite'), text: S.cashierChangerFavoriteTab),
        Tab(key: const Key('changer.custom'), text: S.cashierChangerCustomTab),
      ],
    );
    final tabBarView = TabBarView(controller: controller, children: [
      ChangerFavoriteView(
        key: favoriteState,
        emptyAction: () => controller.animateTo(1),
      ),
      ChangerCustomView(
        key: customState,
        afterFavoriteAdded: () => controller.animateTo(0),
      ),
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(S.cashierChangerTitle),
        actions: [
          TextButton(
            key: const Key('changer.apply'),
            onPressed: handleApply,
            child: Text(S.cashierChangerButton),
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

    if (isValid == true && mounted && context.canPop()) {
      context.pop(true);
    }
  }

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }
}

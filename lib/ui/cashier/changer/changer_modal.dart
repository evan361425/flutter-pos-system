import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/ui/cashier/changer/changer_modal_custom.dart';
import 'package:possystem/ui/cashier/changer/changer_modal_favorite.dart';

class ChangerModal extends StatefulWidget {
  const ChangerModal({Key? key}) : super(key: key);

  @override
  _ChangerModalState createState() => _ChangerModalState();
}

class _ChangerModalState extends State<ChangerModal>
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
      tabs: [
        Tab(text: '常用'),
        Tab(text: '手動'),
      ],
    );
    final tabBarView = TabBarView(controller: controller, children: [
      ChangerModalFavorite(
        key: favoriteState,
        handleAdd: () => controller.animateTo(1),
      ),
      ChangerModalCustom(
        key: customState,
        handleFavoriteAdded: () {
          controller.animateTo(0);
          favoriteState.currentState?.reset();
        },
      ),
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: PopButton(),
        title: Text('換錢'),
        actions: [
          AppbarTextButton(onPressed: handleApply, child: Text('套用')),
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

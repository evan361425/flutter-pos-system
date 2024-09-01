import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
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
    final bp = Breakpoint.find(width: MediaQuery.sizeOf(context).width);
    return ResponsiveDialog(
      scrollable: bp.max > Breakpoint.medium.max,
      title: Row(children: [
        Text(S.cashierChangerTitle),
        bp <= Breakpoint.medium
            ? const Spacer()
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) {
                      return SegmentedButton<int>(
                        selected: {controller.index},
                        onSelectionChanged: (value) => controller.index = value.first,
                        segments: [
                          ButtonSegment(value: 0, label: Text(S.cashierChangerFavoriteTab)),
                          ButtonSegment(value: 1, label: Text(S.cashierChangerCustomTab)),
                        ],
                      );
                    },
                  ),
                ),
              ),
      ]),
      action: TextButton(
        key: const Key('changer.apply'),
        onPressed: handleApply,
        child: Text(S.cashierChangerButton),
      ),
      content: _buildContent(bp),
    );
  }

  Widget _buildContent(Breakpoint bp) {
    if (bp <= Breakpoint.medium) {
      return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TabBar(
          controller: controller,
          tabs: [
            Tab(key: const Key('changer.favorite'), text: S.cashierChangerFavoriteTab),
            Tab(key: const Key('changer.custom'), text: S.cashierChangerCustomTab),
          ],
        ),
        Expanded(
          child: TabBarView(controller: controller, children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: kTopSpacing),
                child: ChangerFavoriteView(
                  key: favoriteState,
                  emptyAction: () => controller.animateTo(1),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: kTopSpacing),
                child: ChangerCustomView(
                  key: customState,
                  afterFavoriteAdded: () => controller.animateTo(0),
                ),
              ),
            ),
          ]),
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.only(top: kTopSpacing, bottom: kDialogBottomSpacing),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          if (controller.index == 0) {
            return ChangerFavoriteView(
              key: favoriteState,
              emptyAction: _moveToCustom,
            );
          }
          return ChangerCustomView(
            key: customState,
            afterFavoriteAdded: _moveToFavorite,
          );
        },
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

  void _moveToCustom() {
    controller.index = 1;
  }

  void _moveToFavorite() {
    controller.index = 0;
  }
}

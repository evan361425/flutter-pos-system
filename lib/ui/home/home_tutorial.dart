import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';

enum TutorialName { go_menu, introduce_features }

class HomeTutorial {
  static const STEPS = {
    TutorialName.go_menu: ['menu'],
    TutorialName.introduce_features: ['stock', 'cashier', 'analysis', 'order'],
  };

  static Tutorial steps(
    BuildContext context,
    TutorialName name,
    List<String> steps,
  ) {
    assert(steps.isNotEmpty);
    final storeIcons = HomeScreen.icons['home.types.store']!;
    final otherIcons = HomeScreen.icons['home.types.other']!;

    switch (name) {
      case TutorialName.go_menu:
        final menu = storeIcons['menu']!;

        return Tutorial(
            context,
            [
              TutorialStep(
                  key: menu.key as GlobalKey,
                  title: tt('home.tutorial.welcome'),
                  content: tt('home.tutorial.menu')),
            ],
            onClick: (_) => Navigator.of(context).pushNamed(menu.route));
      case TutorialName.introduce_features:
        final hasOrder = steps.contains('order');
        final infoSteps = steps.where((e) => e != 'order');

        return Tutorial(
          context,
          [
            ...infoSteps.map<TutorialStep>((e) {
              final key = storeIcons.containsKey(e)
                  ? storeIcons[e]!.key as GlobalKey
                  : otherIcons[e]!.key as GlobalKey;
              return TutorialStep(
                  key: key,
                  title: tt('home.$e'),
                  content: tt('home.tutorial.$e'));
            }),
            if (hasOrder)
              TutorialStep(
                  key: OrderInfo.orderButton,
                  content: '',
                  title: tt('home.tutorial.order'))
          ],
          hideSkip: false,
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeTutorial extends Tutorial {
  final List<Widget> child;

  HomeTutorial(
    BuildContext context,
    List<GlobalKey> targets, {
    bool hideSkip = true,
    Function(TargetFocus)? onClick,
    required this.child,
  }) : super(context, targets, hideSkip: hideSkip, onClick: onClick);

  factory HomeTutorial.icons(BuildContext context) {
    final stock = HomeScreen.icons['home.types.store']![1];
    final analysis = HomeScreen.icons['home.types.other']![0];
    final textTheme = Theme.of(context).textTheme;

    return HomeTutorial(
      context,
      [
        stock.key as GlobalKey,
        analysis.key as GlobalKey,
        OrderInfo.orderButton
      ],
      child: [
        Text(tt('home.tutorial.stock')),
        Text(tt('home.tutorial.analysis')),
        Text(tt('home.tutorial.order'), style: textTheme.headline4),
      ],
    );
  }

  factory HomeTutorial.menu(BuildContext context) {
    final menu = HomeScreen.icons['home.types.store']![0];
    final textTheme = Theme.of(context).textTheme;

    return HomeTutorial(context, [menu.key as GlobalKey],
        onClick: (_) => Navigator.of(context).pushNamed(menu.route),
        child: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tt('home.tutorial.welcome'), style: textTheme.headline4),
              Text(tt('home.tutorial.menu')),
            ],
          ),
        ]);
  }

  @override
  List<TargetFocus> createTargets(
      BuildContext context, List<GlobalKey> targets) {
    var count = 0;
    return targets.map<TargetFocus>((target) {
      return TargetFocus(
        identify: 'home.$count',
        keyTarget: target,
        enableOverlayTab: onClick == null,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(child: child[count++]),
          )
        ],
      );
    }).toList();
  }
}

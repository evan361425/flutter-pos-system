import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:possystem/components/tutorial.dart';
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
    final anaylsis = HomeScreen.icons['home.types.other']![0];
    return HomeTutorial(
      context,
      [
        stock.key as GlobalKey,
        anaylsis.key as GlobalKey,
        OrderInfo.orderButton
      ],
      child: [
        Text('庫存系統可以幫助計算現有庫存\n並同時設定成份相關資訊'),
        Text('統計分析可以幫助我們點餐後查看點餐的紀錄'),
        Text(
          '現在我們就可以準備點餐囉！',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }

  factory HomeTutorial.menu(BuildContext context) {
    final menu = HomeScreen.icons['home.types.store']![0];
    return HomeTutorial(context, [menu.key as GlobalKey],
        onClick: (_) => Navigator.of(context).pushNamed(menu.route),
        child: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '歡迎使用 POS 系統！',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text('在開始點餐前，我們先來建立菜單吧！'),
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

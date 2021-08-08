import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MenuTutorial {
  static const STEPS = ['catalog_intro'];

  static Tutorial build(
    BuildContext context,
    List<String> steps, {
    required GlobalKey addButton,
    required GlobalKey firstCatalog,
  }) {
    assert(steps.isNotEmpty);

    return Tutorial(
      context,
      [
        TutorialStep(
          key: addButton,
          contentAlignment: ContentAlign.top,
          skipAlignment: Alignment.topRight,
          content:
              '我們會把相似「產品」放在「產品種類」中，到時候點餐會比較方便。例如：\n「起司漢堡」、「蔬菜漢堡」整合進「漢堡」\n「塑膠袋」、「環保杯」整合進「其他」\n若需要新增產品種類，可以點此按鈕。',
          title: '產品種類',
        ),
        TutorialStep(
          key: firstCatalog,
          shape: ShapeLightFocus.RRect,
          content: '「長按」- 重新排序或編輯 產品種類\n「滑動」- 刪除 產品種類',
        ),
      ],
      skipAlignment: Alignment.bottomLeft,
    );
  }
}

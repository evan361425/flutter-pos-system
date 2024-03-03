import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/widgets/goals_card_view.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';

class AnalysisView extends StatelessWidget {
  final TutorialInTab? tab;

  const AnalysisView({super.key, this.tab});

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: tab,
      child: ListenableBuilder(
        listenable: Analysis.instance,
        builder: (context, child) => ListView.builder(
          itemCount: Analysis.instance.length + 6,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return child;
              case 1:
                return const GoalsCardView();
              case 2:
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '圖表分析',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        key: const Key('anal.add_chart'),
                        icon: const Icon(KIcons.add),
                        label: const Text('新增圖表'),
                        onPressed: () => context.pushNamed(
                          Routes.chartOrderModal,
                          pathParameters: {
                            'id': '0',
                          },
                        ),
                      ),
                    ],
                  ),
                );
            }

            index -= 3;
            if (Analysis.instance.length > index) {
              return Center(
                child: ChartCardView(
                  chart: Analysis.instance.items.elementAt(index),
                ),
              );
            }

            if (index == Analysis.instance.length) {
              return const SizedBox(height: 128.0);
            }
            return null;
          },
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RouteCircularButton(
              key: Key('anal.order'),
              icon: Icons.store_sharp,
              route: Routes.order,
              text: '點餐',
            ),
            SizedBox.square(dimension: 96.0),
            RouteCircularButton(
              key: Key('anal.history'),
              icon: Icons.calendar_month_sharp,
              route: Routes.history,
              text: '紀錄',
            ),
          ],
        ),
      ),
    );
  }
}

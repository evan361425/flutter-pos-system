import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/widgets/goals_card_view.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalysisView extends StatelessWidget {
  final TutorialInTab? tab;

  const AnalysisView({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: tab,
      child: ListenableBuilder(
        listenable: Analysis.instance,
        builder: (context, child) => ListView(children: [
          child!,
          const SizedBox(height: 4.0),
          const GoalsCardView(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text('圖表分析', style: Theme.of(context).textTheme.headlineSmall),
          ),
          for (final chart in Analysis.instance.items)
            ChartCardView(chart: chart),
          // TODO: time series with specific product, category, ingredient, order attrs.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: addChartButton(context),
          ),
          const SizedBox(height: 64.0),
        ]),
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

  Widget addChartButton(BuildContext context) {
    return Card(
      child: Stack(children: [
        SfCartesianChart(
          plotAreaBorderWidth: 0.7,
          enableAxisAnimation: false,
          selectionGesture: ActivationMode.none,
          primaryXAxis: const NumericAxis(
            labelFormat: ' ',
          ),
          primaryYAxis: const NumericAxis(
            minimum: 0,
            maximum: 6,
            interval: 1,
            labelFormat: ' ',
          ),
          series: [
            LineSeries<double, int>(
              dataSource: const [2, 1, 3.5, 4, 5, 3],
              xValueMapper: (_, i) => i,
              yValueMapper: (v, _) => v,
              color: Theme.of(context).primaryColor.withAlpha(36),
            ),
          ],
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => context.pushNamed(
              Routes.chartOrderModal,
              pathParameters: {
                'id': '0',
              },
            ),
            child: const AspectRatio(
              aspectRatio: 1.0,
              child: Column(
                children: [
                  Spacer(),
                  Icon(KIcons.add, size: 48.0),
                  Text('新增圖表'),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

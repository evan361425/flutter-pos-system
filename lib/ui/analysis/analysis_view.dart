import 'package:flutter/material.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/widgets/analysis_metrics_header.dart';

class AnalysisView extends StatelessWidget {
  final TutorialInTab? tab;

  const AnalysisView({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: tab,
      child: ListView(children: const [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          RouteCircularButton(
            key: Key('anal.order'),
            icon: Icons.store_sharp,
            route: Routes.order,
            text: '點餐',
          ),
          SizedBox.square(dimension: 96.0),
          RouteCircularButton(
            key: Key('anal.calendar'),
            icon: Icons.calendar_month_sharp,
            route: Routes.analCalendar,
            text: '紀錄',
          ),
        ]),
        SizedBox(height: 4.0),
        AnalysisMetricsHeader(),
      ]),
    );
  }
}

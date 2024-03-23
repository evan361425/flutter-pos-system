import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';
import 'package:possystem/ui/analysis/widgets/goals_card_view.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class AnalysisView extends StatefulWidget {
  final int? tabIndex;

  const AnalysisView({super.key, this.tabIndex});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView>
    with AutomaticKeepAliveClientMixin {
  late final TutorialInTab? tab;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TutorialWrapper(
      tab: tab,
      child: ListenableBuilder(
        listenable: Analysis.instance,
        builder: (context, child) {
          final items = Analysis.instance.itemList;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 76),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Column(children: [
                  Row(
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
                  GoalsCardView(),
                  _ChartTitle(),
                ]);
              }

              return Center(
                child: ChartCardView(
                  chart: items.elementAt(index - 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null
        ? null
        : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Text(
          '圖表分析',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tutorial(
                id: 'anal.add_chart',
                message: '開始設計圖表追蹤你的銷售狀況吧！',
                spotlightBuilder: const SpotlightRectBuilder(borderRadius: 28),
                child: ElevatedButton.icon(
                  key: const Key('anal.add_chart'),
                  onPressed: () => context.pushNamed(
                    Routes.chartOrderModal,
                    pathParameters: {
                      'id': '0',
                    },
                  ),
                  icon: const Icon(KIcons.add),
                  label: const Text('新增圖表'),
                ),
              ),
              MoreButton(onPressed: () => _showActions(context)),
            ],
          ),
        ),
      ]),
    );
  }

  void _showActions(BuildContext context) async {
    await showCircularBottomSheet<int>(
      context,
      actions: <BottomSheetAction<int>>[
        const BottomSheetAction(
          title: Text('排序圖表'),
          leading: Icon(KIcons.reorder),
          route: Routes.chartReorder,
        ),
      ],
    );
  }
}

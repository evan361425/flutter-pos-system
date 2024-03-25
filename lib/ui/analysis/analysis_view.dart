import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';
import 'package:possystem/ui/analysis/widgets/chart_range_page.dart';
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

  /// Range of the data to show in charts, it can updated by the user
  late ValueNotifier<DateTimeRange> range;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TutorialWrapper(
      tab: tab,
      child: ListenableBuilder(
        listenable: Analysis.instance,
        builder: (context, child) {
          final items = Analysis.instance.itemList;
          return CustomScrollView(slivers: <Widget>[
            child!,
            _buildChartHeader(),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 76),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: ChartCardView(
                      chart: items.elementAt(index),
                      range: range,
                    ),
                  );
                },
              ),
            ),
          ]);
        },
        child: SliverList.list(children: const [
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
        ]),
      ),
    );
  }

  SliverAppBar _buildChartHeader() {
    return SliverAppBar(
      pinned: true,
      title: const Text('圖表分析'),
      toolbarHeight: kToolbarHeight - 8, // hide shadow of action when pinned
      actions: [
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
      ],
      bottom: AppBar(
        primary: false,
        centerTitle: false,
        titleSpacing: 0,
        leading: const Icon(Icons.calendar_today_sharp, size: 16),
        title: ListenableBuilder(
          listenable: range,
          builder: (context, child) => TextButton(
            key: const Key('anal.chart_range'),
            onPressed: _goToChartRange,
            child: Text(
              range.value.format(DateFormat.MMMd(S.localeName)),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _updateRange(Duration(days: -interval)),
            iconSize: 16,
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          IconButton(
            onPressed: () => _updateRange(Duration(days: interval)),
            iconSize: 16,
            icon: const Icon(Icons.arrow_forward_ios_sharp),
          ),
          IconButton(
            onPressed: _showActions,
            enableFeedback: true,
            iconSize: 16,
            tooltip: '設定',
            icon: const Icon(Icons.settings_sharp),
          ),
        ],
      ),
    );
  }

  int get interval => range.value.duration.inDays;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null
        ? null
        : TutorialInTab(index: widget.tabIndex!, context: context);
    range = ValueNotifier(Util.getDateRange(
      now: DateTime.now().subtract(const Duration(days: 7)),
      days: 7,
    ));

    super.initState();
  }

  void _goToChartRange() async {
    final val = await Navigator.of(context).push<DateTimeRange>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ChartRangePage(
          range: range.value,
        ),
      ),
    );

    if (val != null) {
      range.value = val;
    }
  }

  void _updateRange(Duration dur) {
    range.value = Util.getDateRange(
      now: range.value.start.add(dur),
      days: interval,
    );
  }

  void _showActions() async {
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

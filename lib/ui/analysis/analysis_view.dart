import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/chart_card_view.dart';
import 'package:possystem/ui/analysis/widgets/chart_range_page.dart';
import 'package:possystem/ui/analysis/widgets/goals_card_view.dart';

class AnalysisView extends StatefulWidget {
  final int? tabIndex;

  final bool circularActions;

  const AnalysisView({
    super.key,
    this.tabIndex,
    this.circularActions = true,
  });

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> with AutomaticKeepAliveClientMixin {
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
          return LayoutBuilder(builder: (context, constraints) {
            final bp = Breakpoint.find(box: constraints);
            return CustomScrollView(slivers: <Widget>[
              child!,
              _buildChartHeader(),
              _buildCharts(Analysis.instance.itemList, bp),
            ]);
          });
        },
        child: SliverList.list(children: [
          GoalsCardView(
            action: RouteIconButton(
              key: const Key('anal.history'),
              route: Routes.history,
              icon: const Icon(Icons.calendar_month_sharp),
              tooltip: S.analysisHistoryBtn,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildChartHeader() {
    return SliverAppBar(
      pinned: true,
      // avoid drawer take precedence
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: Text(S.analysisChartTitle),
      toolbarHeight: kToolbarHeight - 8, // hide shadow of action when pinned
      actions: [
        Tutorial(
          id: 'anal.add_chart',
          title: S.analysisChartTutorialTitle,
          message: S.analysisChartTutorialContent,
          child: RouteIconButton(
            key: const Key('anal.add_chart'),
            route: Routes.chartNew,
            icon: const Icon(KIcons.add),
            tooltip: S.analysisChartTitleCreate,
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
            child: Text(range.value.format(S.localeName)),
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
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            icon: const Icon(Icons.settings_sharp),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(List<Chart> items, Breakpoint bp) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 76),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: bp.lookup<int>(expanded: 2, large: 3, compact: 1),
        ),
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
    );
  }

  int get interval => range.value.duration.inDays;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);
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
        BottomSheetAction(
          title: Text(S.analysisChartTitleReorder),
          leading: const Icon(KIcons.reorder),
          route: Routes.chartReorder,
        ),
        BottomSheetAction(
          title: Text(S.analysisChartTitleCreate),
          leading: const Icon(KIcons.add),
          route: Routes.chartNew,
        ),
      ],
    );
  }
}

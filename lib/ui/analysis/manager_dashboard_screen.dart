import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/analysis/dashboard_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';
import 'package:possystem/ui/analysis/widgets/dashboard_kpi_row.dart';
import 'package:possystem/ui/analysis/widgets/dashboard_payment_pie_chart.dart';
import 'package:possystem/ui/analysis/widgets/dashboard_peak_hours_chart.dart';
import 'package:possystem/ui/analysis/widgets/dashboard_range_selector.dart';
import 'package:possystem/ui/analysis/widgets/dashboard_top_sellers_list.dart';

/// Manager-only business intelligence dashboard.
class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  DashboardRangePreset _preset = DashboardRangePreset.today;
  late Future<DashboardMetrics> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DashboardMetrics> _load() {
    final range = _preset.toRange();
    return DashboardService.instance.fetchDashboardMetrics(range);
  }

  void _onPresetChanged(DashboardRangePreset preset) {
    setState(() {
      _preset = preset;
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    DashboardService.instance.invalidateCache();
    setState(() => _future = _load());
    try {
      await _future;
    } catch (e, stack) {
      Log.err(e, 'dashboard_refresh_failed', stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!EmployeeManagerService.instance.isManager) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          leading: const PopButton(),
        ),
        body: const Center(
          child: Text('Only managers can view the dashboard.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('dashboard.refresh'),
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          DashboardRangeSelector(
            selected: _preset,
            onChanged: _onPresetChanged,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<DashboardMetrics>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final metrics =
                    snapshot.data ??
                    DashboardMetrics.empty(_preset.toRange());

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 32),
                        children: [
                          DashboardKpiRow(metrics: metrics),
                          const SizedBox(height: 16),
                          DashboardPeakHoursChart(data: metrics.peakHours),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: wide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: DashboardPaymentPieChart(
                                          data:
                                              metrics.revenueByPaymentMethod,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DashboardTopSellersList(
                                          data: metrics.topSellers,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      DashboardPaymentPieChart(
                                        data: metrics.revenueByPaymentMethod,
                                      ),
                                      const SizedBox(height: 12),
                                      DashboardTopSellersList(
                                        data: metrics.topSellers,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

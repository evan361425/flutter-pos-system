import 'package:flutter/material.dart';

/// Preset range chips for the manager dashboard.
enum DashboardRangePreset {
  today,
  yesterday,
  thisWeek,
  thisMonth;

  String get label => switch (this) {
    .today => 'Today',
    .yesterday => 'Yesterday',
    .thisWeek => 'This week',
    .thisMonth => 'This month',
  };

  DateTimeRange toRange({DateTime? now}) {
    final n = now ?? DateTime.now();
    final startOfToday = DateTime(n.year, n.month, n.day);
    switch (this) {
      case .today:
        return DateTimeRange(
          start: startOfToday,
          end: startOfToday.add(const Duration(days: 1)),
        );
      case .yesterday:
        return DateTimeRange(
          start: startOfToday.subtract(const Duration(days: 1)),
          end: startOfToday,
        );
      case .thisWeek:
        final weekday = startOfToday.weekday; // Mon=1 … Sun=7
        final weekStart = startOfToday.subtract(Duration(days: weekday - 1));
        return DateTimeRange(
          start: weekStart,
          end: startOfToday.add(const Duration(days: 1)),
        );
      case .thisMonth:
        return DateTimeRange(
          start: DateTime(n.year, n.month),
          end: startOfToday.add(const Duration(days: 1)),
        );
    }
  }
}

/// Horizontal chip selector for dashboard date presets.
class DashboardRangeSelector extends StatelessWidget {
  const DashboardRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DashboardRangePreset selected;
  final ValueChanged<DashboardRangePreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final preset in DashboardRangePreset.values) ...[
            if (preset != DashboardRangePreset.today) const SizedBox(width: 8),
            ChoiceChip(
              key: Key('dashboard.range.${preset.name}'),
              label: Text(preset.label),
              selected: selected == preset,
              onSelected: (_) => onChanged(preset),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:possystem/models/tables/dining_table.dart';

/// Single floor-plan cell showing table name, seats and occupancy colour.
class FloorPlanTableTile extends StatelessWidget {
  const FloorPlanTableTile({
    super.key,
    required this.table,
    required this.onTap,
  });

  final DiningTable table;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupied = table.isOccupied;
    // Explicit green / red per dine-in UX (not theme-primary alone).
    const availableColor = Color(0xFF2E7D32);
    final Color accent = occupied ? theme.colorScheme.error : availableColor;
    final Color fill = occupied
        ? accent.withValues(alpha: 0.18)
        : availableColor.withValues(alpha: 0.08);

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: accent, width: occupied ? 2.5 : 1.5),
      ),
      child: InkWell(
        key: Key('floor_plan.table.${table.id}'),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                occupied ? Icons.event_seat : Icons.event_seat_outlined,
                color: accent,
              ),
              const SizedBox(height: 8),
              Text(
                table.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                table.seats > 0 ? '${table.seats} seats' : '—',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                occupied ? 'Occupied' : 'Available',
                style: theme.textTheme.labelSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

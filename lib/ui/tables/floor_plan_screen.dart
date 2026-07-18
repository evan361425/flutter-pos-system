import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/models/tables/dining_table.dart';
import 'package:possystem/models/tables/room.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/services/tables/table_manager_service.dart';
import 'package:possystem/ui/tables/floor_plan_pax_dialog.dart';
import 'package:possystem/ui/tables/floor_plan_table_tile.dart';

/// Visual restaurant floor plan: rooms as tabs, tables as a status-coloured grid.
class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  late Future<_FloorPlanData> _dataFuture;

  @override
  void initState() {
    super.initState();
    TableManagerService.instance.addListener(_reload);
    _dataFuture = _FloorPlanData.load();
  }

  @override
  void dispose() {
    TableManagerService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _dataFuture = _FloorPlanData.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shell tab: parent [HomePage] owns the AppBar. Keep a compact action row.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            key: const Key('floor_plan.close_register'),
            tooltip: 'Close Register',
            icon: const Icon(Icons.point_of_sale_outlined),
            onPressed: () => context.pushNamed(AppRouteNames.closeRegister),
          ),
        ),
        Expanded(
          child: FutureBuilder<_FloorPlanData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasError) {
                Log.err(snapshot.error!, 'floor_plan_load');
                return Center(child: Text('${snapshot.error}'));
              }

              final data = snapshot.data;
              if (data == null || data.rooms.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No rooms yet.\nCreate rooms and tables to start dine-in.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return _FloorPlanBody(data: data, onTableTap: _onTableTap);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onTableTap(DiningTable table) async {
    if (table.isAvailable) {
      await _startDineIn(table);
    } else {
      await _resumeOccupied(table);
    }
  }

  Future<void> _startDineIn(DiningTable table) async {
    final pax = await FloorPlanPaxDialog.show(
      context,
      tableName: table.name,
      maxSeats: table.seats > 0 ? table.seats : null,
    );
    if (pax == null || !mounted) return;

    if (!Cart.instance.isEmpty) {
      final ok = await ConfirmDialog.show(
        context,
        title: 'Replace current cart?',
        content: 'Starting a new table order will clear the current cart.',
      );
      if (!ok || !mounted) return;
      Cart.instance.clear();
    }

    Cart.instance.bindTable(tableId: table.id, pax: pax);
    if (!mounted) return;
    context.pushNamed(AppRouteNames.order);
  }

  Future<void> _resumeOccupied(DiningTable table) async {
    try {
      final order = await StashedOrders.instance.getByTableId(table.id);
      if (!mounted) return;

      if (order == null) {
        showSnackBar(
          'No open order found for ${table.name}.',
          context: context,
        );
        return;
      }

      if (!Cart.instance.isEmpty) {
        final ok = await ConfirmDialog.show(
          context,
          title: 'Replace current cart?',
          content: 'Restoring this table will replace the current cart.',
        );
        if (!ok || !mounted) return;
      }

      Cart.instance.restore(order);
      if (order.id != null) {
        await StashedOrders.instance.delete(order.id!);
      }

      if (!mounted) return;
      context.pushNamed(AppRouteNames.order);
    } catch (e, stack) {
      Log.err(e, 'floor_plan_resume', stack);
      if (mounted) {
        showSnackBar('Could not open table order.', context: context);
      }
    }
  }
}

class _FloorPlanBody extends StatelessWidget {
  const _FloorPlanBody({required this.data, required this.onTableTap});

  final _FloorPlanData data;
  final Future<void> Function(DiningTable table) onTableTap;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data.rooms.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [for (final room in data.rooms) Tab(text: room.name)],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final room in data.rooms)
                  _RoomTableGrid(
                    tables: data.tablesByRoom[room.id] ?? const [],
                    onTableTap: onTableTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomTableGrid extends StatelessWidget {
  const _RoomTableGrid({required this.tables, required this.onTableTap});

  final List<DiningTable> tables;
  final Future<void> Function(DiningTable table) onTableTap;

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const Center(child: Text('No tables in this room.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return FloorPlanTableTile(table: table, onTap: () => onTableTap(table));
      },
    );
  }
}

/// Snapshot loaded with two SQLite queries (rooms + all tables) — no N+1.
class _FloorPlanData {
  const _FloorPlanData({required this.rooms, required this.tablesByRoom});

  final List<Room> rooms;
  final Map<String, List<DiningTable>> tablesByRoom;

  static Future<_FloorPlanData> load() async {
    final rooms = await TableManagerService.instance.getRooms();
    final tables = await TableManagerService.instance.getTables();
    final byRoom = <String, List<DiningTable>>{};
    for (final table in tables) {
      byRoom.putIfAbsent(table.roomId, () => []).add(table);
    }
    return _FloorPlanData(rooms: rooms, tablesByRoom: byRoom);
  }
}

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/database.dart';

/// One row of the local ↔ external product ID bridge.
class ProductMapping {
  const ProductMapping({
    this.id,
    required this.localProductId,
    required this.externalProductId,
    this.externalVariantId,
  });

  final int? id;
  final String localProductId;
  final String externalProductId;
  final String? externalVariantId;

  factory ProductMapping.fromMap(Map<String, Object?> map) {
    return ProductMapping(
      id: map['id'] as int?,
      localProductId: map['local_product_id'] as String? ?? '',
      externalProductId: map['external_product_id'] as String? ?? '',
      externalVariantId: map['external_variant_id'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'local_product_id': localProductId,
    'external_product_id': externalProductId,
    'external_variant_id': externalVariantId,
  };
}

/// Lightweight repository for `product_mappings` (DB v16).
///
/// All queries use bound parameters (Law 2.1). Batch lookups use a single
/// `IN (?, …)` query to avoid N+1 (Law 2.2).
class CloudMappingRepository {
  CloudMappingRepository._();

  static final CloudMappingRepository instance = CloudMappingRepository._();

  static const table = 'product_mappings';

  /// Resolve external IDs for many local products in one query.
  Future<Map<String, ProductMapping>> getByLocalIds(
    Iterable<String> localIds,
  ) async {
    final ids = localIds.where((e) => e.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return const {};

    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await Database.instance.query(
      table,
      where: 'local_product_id IN ($placeholders)',
      whereArgs: ids,
    );

    final result = <String, ProductMapping>{};
    for (final row in rows) {
      final mapping = ProductMapping.fromMap(row);
      result[mapping.localProductId] = mapping;
    }
    return result;
  }

  /// Resolve a single local product from an external (product, variant) pair.
  Future<ProductMapping?> getByExternal({
    required String externalProductId,
    String? externalVariantId,
  }) async {
    if (externalProductId.isEmpty) return null;

    final List<Map<String, Object?>> rows;
    if (externalVariantId == null || externalVariantId.isEmpty) {
      rows = await Database.instance.query(
        table,
        where: 'external_product_id = ? AND external_variant_id IS NULL',
        whereArgs: [externalProductId],
        limit: 1,
      );
    } else {
      rows = await Database.instance.query(
        table,
        where: 'external_product_id = ? AND external_variant_id = ?',
        whereArgs: [externalProductId, externalVariantId],
        limit: 1,
      );
    }

    if (rows.isEmpty) return null;
    return ProductMapping.fromMap(rows.first);
  }

  /// Upsert by [ProductMapping.localProductId] (unique index).
  Future<void> upsert(ProductMapping mapping) async {
    final existing = await getByLocalIds([mapping.localProductId]);
    final current = existing[mapping.localProductId];
    if (current?.id != null) {
      await Database.instance.update(table, current!.id!, mapping.toMap());
    } else {
      await Database.instance.push(table, mapping.toMap());
    }
    Log.ger('cloud_mapping_upsert', {
      'local': mapping.localProductId,
      'external': mapping.externalProductId,
    });
  }

  Future<List<ProductMapping>> getAll({int limit = 200}) async {
    final rows = await Database.instance.query(
      table,
      orderBy: 'id ASC',
      limit: limit,
    );
    return rows.map(ProductMapping.fromMap).toList();
  }

  Future<void> delete(int id) async {
    await Database.instance.delete(table, id);
  }
}

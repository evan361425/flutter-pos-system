import 'dart:convert';

import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/settings/setting.dart';

class ReceiptSetting extends Setting<List<ReceiptComponent>> {
  static ReceiptSetting instance = ReceiptSetting._();

  ReceiptSetting._() {
    value = _getDefaultComponents();
  }

  @override
  String get key => 'receipt_components';

  /// Get default receipt components matching the current hardcoded layout
  static List<ReceiptComponent> _getDefaultComponents() {
    return [
      TextFieldComponent(
        id: 'title',
        text: 'Receipt',
        fontSize: 24.0,
        textAlign: TextAlign.center,
      ),
      OrderTimestampComponent(
        id: 'timestamp',
        dateFormat: 'yMMMd Hms',
      ),
      DividerComponent(id: 'divider1', height: 4.0),
      OrderTableComponent(
        id: 'order_table',
        showProductName: true,
        showCatalogName: false,
        showCount: true,
        showPrice: true,
        showTotal: true,
      ),
      DividerComponent(id: 'divider2', height: 4.0),
      TotalSectionComponent(
        id: 'total_section',
        showDiscounts: true,
        showAddOns: true,
      ),
      DividerComponent(id: 'divider3', height: 4.0),
      PaymentSectionComponent(id: 'payment_section'),
    ];
  }

  /// Reset to default components
  void resetToDefault() {
    update(_getDefaultComponents());
  }

  /// Add a new component
  Future<void> addComponent(ReceiptComponent component) {
    final newList = [...value, component];
    return update(newList);
  }

  /// Remove a component by id
  Future<void> removeComponent(String id) {
    final newList = value.where((c) => c.id != id).toList();
    return update(newList);
  }

  /// Update a component
  Future<void> updateComponent(String id, ReceiptComponent component) {
    final newList = value.map((c) => c.id == id ? component : c).toList();
    return update(newList);
  }

  /// Reorder components
  Future<void> reorderComponents(int oldIndex, int newIndex) {
    final newList = [...value];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    return update(newList);
  }

  @override
  void initialize() {
    final data = service.get<String>(key);
    if (data != null && data.isNotEmpty) {
      try {
        final json = _decodeComponents(data);
        value = json.map((e) => ReceiptComponent.fromJson(e)).toList();
      } catch (e) {
        // If parsing fails, use default
        value = _getDefaultComponents();
      }
    } else {
      value = _getDefaultComponents();
    }
  }

  @override
  Future<void> updateRemotely(List<ReceiptComponent> data) {
    final encoded = _encodeComponents(data);
    return service.set<String>(key, encoded);
  }

  /// Encode components to JSON string
  String _encodeComponents(List<ReceiptComponent> components) {
    final json = components.map((c) => c.toJson()).toList();
    return jsonEncode(json);
  }

  /// Decode components from JSON string
  List<Map<String, Object?>> _decodeComponents(String data) {
    final decoded = jsonDecode(data) as List;
    return decoded.cast<Map<String, Object?>>();
  }
}

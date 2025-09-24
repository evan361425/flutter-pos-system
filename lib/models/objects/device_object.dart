import 'package:possystem/models/model_object.dart';

/// Device connection object for persistence
class DeviceObject extends ModelObject<DeviceObject> {
  final String? id;
  final String? name;
  final String? address;
  final int? port;
  final bool? autoConnect;
  final String? deviceType;
  final String? publicKey;
  final bool? isPaired;

  const DeviceObject({
    this.id,
    this.name,
    this.address,
    this.port,
    this.autoConnect,
    this.deviceType,
    this.publicKey,
    this.isPaired,
  });

  factory DeviceObject.build(Map<String, Object?> data) {
    return DeviceObject(
      id: data['id'] as String?,
      name: data['name'] as String?,
      address: data['address'] as String?,
      port: data['port'] as int?,
      autoConnect: data['autoConnect'] as bool?,
      deviceType: data['deviceType'] as String?,
      publicKey: data['publicKey'] as String?,
      isPaired: data['isPaired'] as bool?,
    );
  }

  @override
  Map<String, Object?> diff(DeviceObject model) {
    final data = <String, Object?>{};

    if (name != model.name) data['name'] = model.name;
    if (address != model.address) data['address'] = model.address;
    if (port != model.port) data['port'] = model.port;
    if (autoConnect != model.autoConnect) data['autoConnect'] = model.autoConnect;
    if (deviceType != model.deviceType) data['deviceType'] = model.deviceType;
    if (publicKey != model.publicKey) data['publicKey'] = model.publicKey;
    if (isPaired != model.isPaired) data['isPaired'] = model.isPaired;

    return data;
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'port': port,
      'autoConnect': autoConnect,
      'deviceType': deviceType,
      'publicKey': publicKey,
      'isPaired': isPaired,
    };
  }
}
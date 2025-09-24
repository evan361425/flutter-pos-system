# Device Connection Feature

This feature allows connecting two or more POS devices to share order data in real-time. One device can serve as a cashier taking orders, while another can act as a kitchen display showing orders to prepare.

## Architecture

The device connection system follows the same architectural patterns as the existing printer system:

### Core Components

1. **Device Model** (`lib/models/device.dart`)
   - Manages individual device connections
   - Handles device state (connected/disconnected, paired/unpaired)
   - Supports auto-connect functionality

2. **Network Service** (`lib/services/network.dart`)
   - TCP-based communication layer
   - Device discovery using network scanning
   - Connection management and message handling

3. **Device Objects** (`lib/models/objects/device_object.dart`)
   - Persistence layer for device configurations
   - Stored in the `devices` store in the storage system

### UI Components

1. **Device Management Page** (`lib/ui/device/device_page.dart`)
   - Main interface for managing connected devices
   - Add, edit, and remove devices
   - View connection status

2. **Device Button View** (`lib/ui/order/widgets/device_button_view.dart`)
   - Integrated into the order page
   - Shows connection status during ordering
   - Auto-connects to configured devices

3. **Device Views and Modals**
   - Device configuration modal with discovery
   - Individual device status cards
   - Connection and pairing dialogs

## How It Works

### Device Discovery

The system uses TCP-based discovery similar to KDE Connect:

1. **Server Mode**: Each device runs a discovery server on port 8765
2. **Client Mode**: When discovering devices, scans the local network
3. **Handshake**: Uses JSON message exchange for device identification

### Device Pairing

For security, devices must be paired before sharing order data:

1. **PIN Generation**: 4-digit random PIN codes
2. **Pairing Request**: Initiated from one device
3. **PIN Validation**: Both devices must enter the same PIN
4. **Secure Connection**: Only paired devices can exchange order data

### Order Data Transmission

When an order is completed (checkout), the system:

1. **Broadcasts Order**: Sends order data to all connected devices
2. **JSON Format**: Uses structured JSON for order information
3. **Error Handling**: Reports failures and connection issues

## Integration Points

### Initialization

The device system is initialized in `main.dart`:

```dart
await Devices().initialize();
await NetworkService.instance.startDiscoveryServer();
```

### Order Integration

Order data is broadcast in `lib/models/repository/cart.dart`:

```dart
// Broadcast order data to connected devices
await Devices.instance.broadcastOrderData(data.toMap());
```

### UI Integration

The device button is added to the order page in `lib/ui/order/order_page.dart`:

```dart
const DeviceButtonView(),
```

## Device Types

The system supports different device types:

- **Cashier**: Primary order-taking device
- **Kitchen Display**: Shows orders for preparation
- **Display**: Customer-facing order status display

## Configuration

### Auto-Connect

Devices can be configured to auto-connect when starting to take orders, similar to printer auto-connect functionality.

### Network Settings

- Default port: 8765
- Configurable IP addresses
- Support for different subnets

## Testing

### Unit Tests

- Device model tests (`test/models/device_test.dart`)
- Network service tests (`test/services/network_test.dart`)

### Widget Tests

- Device button view tests (`test/ui/device/device_button_view_test.dart`)
- UI component validation

## Security Considerations

1. **PIN-based Pairing**: Prevents unauthorized connections
2. **Local Network Only**: Discovery limited to local subnet
3. **Connection Validation**: Verifies device identity before data exchange

## Usage Instructions

### Adding a Device

1. Navigate to the Device Management page
2. Tap "Add Device"
3. The system will scan for available devices
4. Select a discovered device or add manually
5. Configure device type and auto-connect settings

### Pairing Devices

1. Ensure both devices are connected to the same network
2. Connect to the device from the management page
3. Initiate pairing from one device
4. Enter the PIN shown on both devices
5. Devices are now paired and can share order data

### Using During Orders

1. Devices with auto-connect enabled will connect automatically
2. The device button in the order page shows connection status
3. Order data is automatically broadcast to connected devices
4. Kitchen displays will receive and show order information

## Future Enhancements

Potential improvements could include:

1. **Message Acknowledgments**: Ensure order data is received
2. **Order Status Updates**: Two-way communication for order status
3. **Multiple Kitchen Displays**: Support for multiple kitchen stations
4. **Custom Device Names**: User-configurable device identification
5. **Connection History**: Track and log device connections

## Troubleshooting

### Common Issues

1. **Discovery Fails**: Check network connectivity and firewall settings
2. **Pairing Issues**: Ensure both devices show the same PIN
3. **Connection Drops**: Verify network stability and IP addresses
4. **Order Data Not Received**: Check device pairing status

### Network Requirements

- All devices must be on the same local network
- Port 8765 must be accessible between devices
- Firewall may need configuration for TCP connections

## Files Modified/Added

### New Files
- `lib/models/device.dart`
- `lib/models/objects/device_object.dart`
- `lib/services/network.dart`
- `lib/ui/device/device_page.dart`
- `lib/ui/device/device_modal.dart`
- `lib/ui/device/widgets/device_view.dart`
- `lib/ui/order/widgets/device_button_view.dart`
- `assets/l10n/en/device.yaml`
- `assets/l10n/zh/device.yaml`
- `test/models/device_test.dart`
- `test/services/network_test.dart`
- `test/ui/device/device_button_view_test.dart`

### Modified Files
- `lib/main.dart` - Added device initialization
- `lib/services/storage.dart` - Added device storage
- `lib/models/repository/cart.dart` - Added order broadcasting
- `lib/ui/order/order_page.dart` - Added device button
- `lib/routes.dart` - Added device routes

## Next Steps

1. Run `make build-l10n` to generate localization files
2. Test device discovery and pairing functionality
3. Validate order data transmission between devices
4. Add integration tests for complete workflow
5. Consider additional security measures for production use
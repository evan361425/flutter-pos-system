# iOS Setup and Deployment Guide

## Overview
This document outlines the iOS support configuration for the POS system Flutter application.

## iOS Platform Configuration

### Minimum Requirements
- iOS 12.0+ (configured in Podfile and Xcode project)
- Xcode 13+ for development
- Apple Developer account for App Store deployment

### Key Configurations

#### 1. Podfile Setup
The iOS platform is configured in `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

#### 2. Permissions (Info.plist)
The following permissions are configured for POS system functionality:
- **Camera Access**: For QR code scanning and product photos
- **Photo Library**: For selecting product images
- **Bluetooth**: For connecting to printers and payment devices
- **Local Network**: For printer and POS device connectivity
- **Microphone**: For barcode scanning features
- **Location**: For location-based services

#### 3. Build Configurations
- Deployment Target: iOS 12.0
- Swift Version: 5.0
- Bundle Identifier: com.evanlu.possystem

## Package Compatibility

All major dependencies have been verified for iOS compatibility:

### Firebase Services ✅
- firebase_core ^3.15.2
- firebase_analytics ^11.6.0
- firebase_auth ^5.7.0
- firebase_crashlytics ^4.3.10
- firebase_in_app_messaging ^0.8.1+10
- firebase_performance ^0.10.1+10

### Database & Storage ✅
- sqflite ^2.4.2
- sembast ^3.8.5
- shared_preferences ^2.5.3
- path_provider ^2.1.5

### Media & Files ✅
- image_picker ^1.2.0
- file_picker ^10.3.3
- image_cropper ^9.1.0
- cached_network_image ^3.4.1
- flutter_svg ^2.2.1

### Platform Integration ✅
- google_sign_in ^6.3.0
- url_launcher ^6.3.2
- package_info_plus ^8.3.0
- wakelock_plus ^1.3.2

### UI Components ✅
- go_router ^16.2.1
- provider ^6.1.5
- table_calendar ^3.2.0
- syncfusion_flutter_charts ^30.2.6+1

## Build & Deployment

### Development Build
```bash
# Install dependencies
flutter pub get
cd ios && pod install

# Build for testing (no code signing)
flutter build ios --no-codesign --dart-define=appFlavor=dev

# Or use Fastlane
cd ios && fastlane build_dev
```

### Production Build
```bash
# Build for App Store
flutter build ios --dart-define=appFlavor=prod --dart-define=logLevel=info

# Or use Fastlane
cd ios && fastlane build_prod
```

### Fastlane Lanes
Available Fastlane lanes for iOS:
- `test`: Test build without code signing
- `build_dev`: Development build
- `build_prod`: Production build
- `beta`: Build and upload to TestFlight (requires certificates)
- `release`: Build and upload to App Store (requires certificates)

### CI/CD Integration
iOS builds are integrated into GitHub Actions:
- Automatic iOS build testing on macOS runners
- Pod installation verification
- Build verification without code signing

## Code Signing Setup (Future)

For App Store deployment, you'll need to configure:
1. Apple Developer certificates
2. Provisioning profiles
3. App Store Connect app registration
4. TestFlight beta testing setup

Update the Fastfile `beta` and `release` lanes with appropriate code signing configuration when ready for distribution.

## Testing

### Unit Tests
All existing Flutter tests run on iOS without modification.

### Integration Tests
iOS-specific testing can be added using Flutter's integration test framework.

### Device Testing
Test on physical iOS devices for full POS functionality validation, especially:
- Camera/barcode scanning
- Bluetooth printer connectivity
- Network connectivity features

## Troubleshooting

### Common Issues
1. **Pod install failures**: Ensure Xcode command line tools are installed
2. **Build failures**: Check iOS deployment target consistency
3. **Permission denials**: Verify Info.plist usage descriptions
4. **Network issues**: Check local network permission configuration

### Debugging
- Use Xcode for native iOS debugging
- Flutter inspector for Flutter-specific issues
- Console app for device logs

## Next Steps

1. Set up Apple Developer account
2. Configure code signing certificates
3. Test on physical iOS devices
4. Set up App Store Connect
5. Configure TestFlight for beta testing
6. Implement iOS-specific analytics and crash reporting
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Vehica';
  static const String appVersion = '1.0.0';

  // Base URLs
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8080/api/v1';
  static const String localhostBaseUrl = 'http://localhost:8080/api/v1';

  static String get baseUrl {
    // Can be overridden via --dart-define=API_BASE_URL=...
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Web runs on localhost
    if (kIsWeb) {
      return localhostBaseUrl;
    }

    // Android Emulator connects via 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }

    // iOS Simulator / Desktop uses localhost
    return localhostBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

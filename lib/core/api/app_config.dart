import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class AppConfig {
static String _baseUrl = ""; // Private variable

  static String get apiBaseUrl => _baseUrl;

  static Future<void> init() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String host = "";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      // Check if it's a physical device
      if (androidInfo.isPhysicalDevice) {
        host = "192.168.3.142:5233"; // Your Local PC IP
      } else {
        host = "10.0.2.2:5233";      // Emulator Bridge
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // iOS Simulators use 'localhost' because they share the Mac network stack
      host = iosInfo.isPhysicalDevice ? "192.168.3.142:5233" : "localhost:5233";
    }

    _baseUrl = "http://$host/api";
    print("Configured API Base URL: $_baseUrl");
  }
static final String notificationsHub = "$apiBaseUrl/notificationhub";

// Networking
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 40);
}
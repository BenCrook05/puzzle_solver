import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';


class ApiConfig {
//   static const String _customHost = '172.20.10.5'; // standard, currently for local network or hotspot
static const String _customHost = '10.9.110.21'; // for marshall wace guest network
  static String get baseUrl {
    if (_customHost.isNotEmpty) {
      return 'http://$_customHost:5000';
    }
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000'; // android
    }
    return 'http://127.0.0.1:5000'; // ios simulator
  }
  static Uri get solveImageUri => Uri.parse('$baseUrl/solve/image');
  static Uri get solveManualUri => Uri.parse('$baseUrl/solve/manual');
}
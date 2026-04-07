import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5294";
    }

    if (Platform.isAndroid) {
      return "http://192.168.1.144:5294";
    }

    return "http://localhost:5294";
  }
}

import 'package:flutter/foundation.dart';

class Endpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }

    return 'http://127.0.0.1:5000';
  }

  static const String health = '/health';
  static const String meal = '/predict/meal';
  static const String workout = '/predict/workout';
  static const String weight = '/predict/weight';
  static const String fitness = '/predict/fitness';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}

import 'package:flutter/material.dart';


Color circleColor1 = Colors.black;
Color circleColor2 = Colors.black;
Color circleColor3 = Colors.black;
Color circleColor4 = Colors.black;
Color circleColor5 = Colors.black;
Color circleColor6 = Colors.black;
Color circleColor7 = Colors.black;
Color circleColor8 = Colors.black;
Color circleColor9 = Colors.black;
Color circleColor10 = Colors.black;
Color circleColor11 = Colors.black;
Color circleColor12 = Colors.black;
Color circleColor13 = Colors.black;

class CircleData {
  double x; // 0.0 to 1.0 (relative to width)
  double y; // 0.0 to 1.0 (relative to height)
  Color color;

  CircleData({required this.x, required this.y, required this.color});
}

class Page3Backend extends ChangeNotifier {
  List<CircleData> circles = [
    CircleData(x: 0.05, y: 0.05, color: Colors.red),
    CircleData(x: 0.20, y: 0.15, color: circleColor2),
    CircleData(x: 0.25, y: 0.30, color: circleColor3),
    CircleData(x: 0.25, y: 0.50, color: circleColor4),
    CircleData(x: 0.25, y: 0.70, color: circleColor5),
    CircleData(x: 0.25, y: 0.95, color: circleColor6),
    CircleData(x: 0.50, y: 0.95, color: circleColor7),
    CircleData(x: 0.75, y: 0.95, color: circleColor8),
    CircleData(x: 0.75, y: 0.70, color: circleColor9),
    CircleData(x: 0.75, y: 0.50, color: circleColor10),
    CircleData(x: 0.75, y: 0.30, color: circleColor11),
    CircleData(x: 0.80, y: 0.15, color: circleColor12),
    CircleData(x: 0.95, y: 0.05, color: circleColor13),
  ];
// Checklist counts
  final Map<String, int> _checkCounts = {};

  int getCheckCount(String key) => _checkCounts[key] ?? 0;

  void incrementCheck(String key) {
    _checkCounts[key] = (_checkCounts[key] ?? 0) + 1;
    notifyListeners();
  }

  void resetChecks() {
    _checkCounts.clear();
    notifyListeners();
  }

  void printCheckCounts() {
    _checkCounts.forEach((key, value) {
      debugPrint('$key: $value');
    });
  }
  
  
}

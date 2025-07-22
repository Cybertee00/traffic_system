import 'package:flutter/material.dart';

class CircleData {
  final double x;
  final double y;
  final Color color;

  CircleData({required this.x, required this.y, required this.color});
}

class Page2Backend extends ChangeNotifier {
  double circleSize = 30.0;
  Color middleCardColor = Colors.grey.shade200;

  void setCircleSize(double newSize) {
    circleSize = newSize;
    notifyListeners();
  }

  void setCardBackgroundColor(Color color) {
    middleCardColor = color;
    notifyListeners();
  }

  // Circles positioning for middle card
  List<CircleData> circles = [
    CircleData(x: 0.9, y: 0.1, color: Colors.red),
    CircleData(x: 0.5, y: 0.1, color: Colors.red),
    CircleData(x: 0.1, y: 0.1, color: Colors.red),
    CircleData(x: 0.1, y: 0.5, color: Colors.red),
    CircleData(x: 0.1, y: 0.9, color: Colors.red),
    CircleData(x: 0.5, y: 0.9, color: Colors.red),
    CircleData(x: 0.9, y: 0.9, color: Colors.red),
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

import 'package:flutter/material.dart';

class HillStartBackend extends ChangeNotifier {
  double progressValue = 0.5;
  final Map<String, int> _checkCounts = {};

  // Simulate starting the test and updating progress
  void startTest() {
    progressValue = 0.75; // Example update
    notifyListeners();
  }

  double getProgress() => progressValue;

  int getCheckCount(String key) => _checkCounts[key] ?? 0;

  void incrementCheck(String key) {
    _checkCounts[key] = (_checkCounts[key] ?? 0) + 1;
    notifyListeners();
  }

  void resetChecks() {
    _checkCounts.clear();
    notifyListeners();
  }

  double calculateTotalPenalty(String sectionTitle, List<CheckItem> checks) {
    double total = 0;
    for (var check in checks) {
      final key = '$sectionTitle-${check.description}';
      final count = getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
}

class CheckItem {
  final String abbreviation;
  final String description;
  final int penaltyValue;

  CheckItem({
    required this.abbreviation,
    required this.description,
    required this.penaltyValue,
  });
}


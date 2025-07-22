import 'package:flutter/material.dart';

class CarDetailsBackend extends ChangeNotifier {
  String carLicence = '';
  String carReg = '';
  String carTransmission = '';
  String carWeather = '';

  void updateCarLicence(String licence) {
    carLicence = licence;
    notifyListeners();
  }

  void updateCarReg(String reg) {
    carReg = reg;
    notifyListeners();
  }

  void updateCarTransmission(String transmission) {
    carTransmission = transmission;
    notifyListeners();
  }

  void updateCarWeather(String weather) {
    carWeather = weather;
    notifyListeners();
  }

  void resetCarDetails() {
    carLicence = '';
    carReg = '';
    carTransmission = '';
    carWeather = '';
    notifyListeners();
  }
} 
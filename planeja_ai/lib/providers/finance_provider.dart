import 'package:flutter/material.dart';

class FinanceProvider extends ChangeNotifier {
  double _balance = 24500.0;
  double _income = 5200.0;
  double _expenses = 2700.0;

  double get balance => _balance;
  double get income => _income;
  double get expenses => _expenses;

  void addTransaction(double amount, bool isIncome) {
    if (isIncome) {
      _income += amount;
      _balance += amount;
    } else {
      _expenses += amount;
      _balance -= amount;
    }
    notifyListeners();
  }
}

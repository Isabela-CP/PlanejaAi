import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  Future<void> login(String email, String password) async {
    // Mock login delay
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _username = email.split('@')[0];
    notifyListeners();
  }

  Future<void> signup(String email, String password, String name) async {
    // Mock signup delay
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _username = name;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}

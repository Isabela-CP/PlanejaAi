import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  String? _username;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        _setLoading(false);
        return;
      }

      // Verify token by calling /me
      final response = await _apiService.get('/auth/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isAuthenticated = true;
        _username = data['name'];
        _userData = data;
        notifyListeners();
      } else {
        // Token is invalid or expired
        await prefs.remove('jwt_token');
      }
    } catch (e) {
      // In case of network errors, silently fail auto-login
      debugPrint("Auto-login failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        _isAuthenticated = true;
        _username = data['user']['name'];
        notifyListeners();
        // Fetch complete user data
        await fetchMe();
      } else {
        throw Exception(data['error'] ?? 'Falha na autenticação');
      }
    } on SocketException {
      throw Exception('Sem conexão com o servidor. Verifique sua internet.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String email, String password, String name) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        '/auth/register',
        body: {'email': email, 'password': password, 'name': name},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Automatically login after successful registration
        await login(email, password);
      } else {
        throw Exception(data['error'] ?? 'Falha ao criar conta');
      }
    } on SocketException {
      throw Exception('Sem conexão com o servidor. Verifique sua internet.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      _isAuthenticated = false;
      _username = null;
      _userData = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMe() async {
    final response = await _apiService.get('/auth/me');
    if (response.statusCode == 200) {
      _userData = json.decode(response.body);
      _username = _userData?['name'];
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final response = await _apiService.put(
        '/auth/me',
        body: data,
      );
      if (response.statusCode == 200) {
        await fetchMe();
      } else {
        final err = json.decode(response.body);
        throw Exception(err['error'] ?? 'Falha ao atualizar perfil');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadAvatar(List<int> fileBytes, String filename) async {
    _setLoading(true);
    try {
      final response = await _apiService.multipartPost(
        '/auth/avatar',
        'avatar',
        fileBytes,
        filename,
      );
      if (response.statusCode == 200) {
        await fetchMe();
      } else {
        final err = json.decode(response.body);
        throw Exception(err['error'] ?? 'Falha ao fazer upload da imagem');
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

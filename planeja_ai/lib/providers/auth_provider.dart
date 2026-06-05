import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  String? _username;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  bool get isLoading => _isLoading;

  String get _baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
  }

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    _setLoading(true);
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        _setLoading(false);
        return;
      }

      // Verify token by calling /me
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isAuthenticated = true;
        _username = data['name'];
      } else {
        // Token is invalid or expired
        await _storage.delete(key: 'jwt_token');
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'jwt_token', value: data['token']);
        _isAuthenticated = true;
        _username = data['user']['name'];
        notifyListeners();
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password, 'name': name}),
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
      await _storage.delete(key: 'jwt_token');
      _isAuthenticated = false;
      _username = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

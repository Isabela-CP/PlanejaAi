import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/models/category.dart';

class FinanceProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  List<AppCategory> _transactionCategories = [];
  List<AppCategory> _goalCategories = [];
  bool _isLoadingCategories = false;

  // Mudar depois para o backend
  double _balance = 24500.0;
  double _income = 5200.0;
  double _expenses = 2700.0;

  List<AppCategory> get transactionCategories => List.unmodifiable(_transactionCategories);
  List<AppCategory> get goalCategories => List.unmodifiable(_goalCategories);
  List<AppCategory> get categories => transactionCategories; // Antigas, adicionar depois
  bool get isLoadingCategories => _isLoadingCategories;

  double get balance => _balance;
  double get income => _income;
  double get expenses => _expenses;

  String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchCategories({String type = 'transaction'}) async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories?type=$type'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List;
        final loaded = data
            .map((e) => AppCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        
        if (type == 'goal') {
          _goalCategories = loaded;
        } else {
          _transactionCategories = loaded;
        }
      }
    } catch (e) {
      debugPrint('fetchCategories error: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllCategories() async {
    await Future.wait([
      fetchCategories(type: 'transaction'),
      fetchCategories(type: 'goal'),
    ]);
  }

  Future<void> addCategory(AppCategory category) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: await _headers,
      body: json.encode(category.toJson()),
    );
    if (response.statusCode == 201) {
      final newCat = AppCategory.fromJson(json.decode(response.body) as Map<String, dynamic>);
      if (newCat.type == 'goal') {
        _goalCategories.add(newCat);
      } else {
        _transactionCategories.add(newCat);
      }
      notifyListeners();
    } else {
      final msg = (json.decode(response.body) as Map<String, dynamic>)['error'] ??
          'Erro ao criar categoria';
      throw Exception(msg);
    }
  }

  Future<void> updateCategory(String id, AppCategory updated) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: await _headers,
      body: json.encode(updated.toJson()),
    );
    if (response.statusCode == 200) {
      final newCat = AppCategory.fromJson(json.decode(response.body) as Map<String, dynamic>);
      
      if (newCat.type == 'goal') {
        final idx = _goalCategories.indexWhere((c) => c.id == id);
        if (idx != -1) {
          _goalCategories[idx] = newCat;
          notifyListeners();
        }
      } else {
        final idx = _transactionCategories.indexWhere((c) => c.id == id);
        if (idx != -1) {
          _transactionCategories[idx] = newCat;
          notifyListeners();
        }
      }
    } else {
      final msg = (json.decode(response.body) as Map<String, dynamic>)['error'] ??
          'Erro ao atualizar categoria';
      throw Exception(msg);
    }
  }

  Future<void> deleteCategory(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      _transactionCategories.removeWhere((c) => c.id == id);
      _goalCategories.removeWhere((c) => c.id == id);
      notifyListeners();
    } else {
      final msg = (json.decode(response.body) as Map<String, dynamic>)['error'] ??
          'Erro ao remover categoria';
      throw Exception(msg);
    }
  }

  // Mudar depois para o backend
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

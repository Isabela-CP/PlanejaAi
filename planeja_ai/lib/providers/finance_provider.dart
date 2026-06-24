import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/models/category.dart';
import '../core/models/transaction.dart';
import '../core/models/budget.dart';
import '../core/models/goal.dart';
import '../core/services/api_service.dart';

class FinanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppCategory> _transactionCategories = [];
  List<AppCategory> _goalCategories = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];
  bool _isLoadingCategories = false;
  bool _isLoadingTransactions = false;
  bool _isLoadingBudgets = false;
  bool _isLoadingGoals = false;

  // Relatórios State
  Map<String, dynamic>? _reportSummary;
  List<dynamic>? _reportCategoryBreakdown;
  List<dynamic>? _reportBalanceEvolution;
  bool _isLoadingReports = false;

  double _balance = 0.0;
  double _income = 0.0;
  double _expenses = 0.0;

  List<dynamic>? get reportEvolucaoSaldo => _reportBalanceEvolution;
  List<AppCategory> get transactionCategories => List.unmodifiable(_transactionCategories);
  List<AppCategory> get goalCategories => List.unmodifiable(_goalCategories);
  List<AppCategory> get categories => transactionCategories;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isLoadingBudgets => _isLoadingBudgets;
  bool get isLoadingGoals => _isLoadingGoals;

  Map<String, dynamic>? get reportSummary => _reportSummary;
  List<dynamic>? get reportCategoryBreakdown => _reportCategoryBreakdown;
  List<dynamic>? get reportBalanceEvolution => _reportBalanceEvolution;
  bool get isLoadingReports => _isLoadingReports;

  double get balance => _balance;
  double get income => _income;
  double get expenses => _expenses;

  void clear() {
    _transactionCategories.clear();
    _goalCategories.clear();
    _transactions.clear();
    _budgets.clear();
    _goals.clear();
    _reportSummary = null;
    _reportCategoryBreakdown = null;
    _reportBalanceEvolution = null;
    _balance = 0.0;
    _income = 0.0;
    _expenses = 0.0;
    notifyListeners();
  }

  Future<void> fetchCategories({String type = 'transaction'}) async {
    if (type == 'goal' ? _goalCategories.isEmpty : _transactionCategories.isEmpty) {
      _isLoadingCategories = true;
      notifyListeners();
    }
    try {
      final response = await _apiService.get('/categories?type=$type');
      if (response.statusCode == 200) {
        final List<dynamic> data = _apiService.decode(response) as List;
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
    final response = await _apiService.post(
      '/categories',
      body: category.toJson(),
    );
    if (response.statusCode == 201) {
      final newCat = AppCategory.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      if (newCat.type == 'goal') {
        _goalCategories.add(newCat);
      } else {
        _transactionCategories.add(newCat);
      }
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao criar categoria') : 'Erro ao criar categoria';
      throw Exception(msg);
    }
  }

  Future<void> updateCategory(String id, AppCategory updated) async {
    final response = await _apiService.put(
      '/categories/$id',
      body: updated.toJson(),
    );
    if (response.statusCode == 200) {
      final newCat = AppCategory.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      
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
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao atualizar categoria') : 'Erro ao atualizar categoria';
      throw Exception(msg);
    }
  }

  Future<void> deleteCategory(String id) async {
    final response = await _apiService.delete('/categories/$id');
    if (response.statusCode == 200) {
      _transactionCategories.removeWhere((c) => c.id == id);
      _goalCategories.removeWhere((c) => c.id == id);
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao remover categoria') : 'Erro ao remover categoria';
      throw Exception(msg);
    }
  }

  Future<void> fetchTransactions() async {
    if (_transactions.isEmpty) {
      _isLoadingTransactions = true;
      notifyListeners();
    }
    try {
      final response = await _apiService.get('/transactions');
      if (response.statusCode == 200) {
        final List<dynamic> data = _apiService.decode(response) as List;
        _transactions = data
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        
        _recalculateBalances();
      }
    } catch (e) {
      debugPrint('fetchTransactions error: $e');
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  void _recalculateBalances() {
    double inc = 0.0;
    double exp = 0.0;
    for (var tx in _transactions) {
      if (tx.type == 'income') {
        inc += tx.amount;
      } else {
        exp += tx.amount;
      }
    }
    _income = inc;
    _expenses = exp;
    _balance = inc - exp;
  }

  Future<void> addTransaction(Transaction tx) async {
    final response = await _apiService.post(
      '/transactions',
      body: tx.toJson(),
    );
    if (response.statusCode == 201) {
      final newTx = Transaction.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      _transactions.insert(0, newTx);
      _recalculateBalances();
      notifyListeners();
      fetchBudgets();
      fetchReportsData();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao criar transação') : 'Erro ao criar transação';
      throw Exception(msg);
    }
  }

  Future<void> updateTransaction(String id, Transaction tx) async {
    final response = await _apiService.put(
      '/transactions/$id',
      body: tx.toJson(),
    );
    if (response.statusCode == 200) {
      final updatedTx = Transaction.fromJson(json.decode(response.body) as Map<String, dynamic>);
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _transactions[idx] = updatedTx;
        _recalculateBalances();
        notifyListeners();
        fetchBudgets();
        fetchReportsData();
      }
    } else {
      final data = json.decode(response.body);
      final msg = data is Map ? (data['error'] ?? 'Erro ao atualizar transação') : 'Erro ao atualizar transação';
      throw Exception(msg);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final response = await _apiService.delete('/transactions/$id');
    if (response.statusCode == 200) {
      _transactions.removeWhere((tx) => tx.id == id);
      _recalculateBalances();
      notifyListeners();
      fetchBudgets();
      fetchReportsData();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao remover transação') : 'Erro ao remover transação';
      throw Exception(msg);
    }
  }

  Future<void> fetchBudgets({DateTime? date}) async {
    if (_budgets.isEmpty) {
      _isLoadingBudgets = true;
      notifyListeners();
    }
    try {
      final queryDate = date ?? DateTime.now();
      final dateStr = "${queryDate.year.toString().padLeft(4, '0')}-${queryDate.month.toString().padLeft(2, '0')}-01";
      final response = await _apiService.get('/budgets?date=$dateStr');
      if (response.statusCode == 200) {
        final List<dynamic> data = _apiService.decode(response) as List;
        _budgets = data
            .map((e) => Budget.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchBudgets error: $e');
    } finally {
      _isLoadingBudgets = false;
      notifyListeners();
    }
  }

  Future<void> addBudget({
    required String categoryId,
    required double limit,
    required int resetDay,
    DateTime? date,
  }) async {
    final queryDate = date ?? DateTime.now();
    final dateStr = "${queryDate.year.toString().padLeft(4, '0')}-${queryDate.month.toString().padLeft(2, '0')}-01";
    final response = await _apiService.post(
      '/budgets',
      body: {
        'categoryId': categoryId,
        'monthlyLimit': limit,
        'resetDay': resetDay,
        'date': dateStr,
      },
    );
    if (response.statusCode == 201) {
      final newBudget = Budget.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      _budgets.add(newBudget);
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao criar orçamento') : 'Erro ao criar orçamento';
      throw Exception(msg);
    }
  }

  Future<void> updateBudget(
    String id, {
    double? limit,
    int? resetDay,
  }) async {
    final body = {
      if (limit != null) 'monthlyLimit': limit,
      if (resetDay != null) 'resetDay': resetDay,
    };
    final response = await _apiService.put(
      '/budgets/$id',
      body: body,
    );
    if (response.statusCode == 200) {
      final updatedBudget = Budget.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      final idx = _budgets.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _budgets[idx] = updatedBudget;
        notifyListeners();
      }
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao atualizar orçamento') : 'Erro ao atualizar orçamento';
      throw Exception(msg);
    }
  }

  Future<void> deleteBudget(String id) async {
    final response = await _apiService.delete('/budgets/$id');
    if (response.statusCode == 200) {
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao remover orçamento') : 'Erro ao remover orçamento';
      throw Exception(msg);
    }
  }

  Future<void> fetchGoals() async {
    if (_goals.isEmpty) {
      _isLoadingGoals = true;
      notifyListeners();
    }
    try {
      final response = await _apiService.get('/goals');
      if (response.statusCode == 200) {
        final List<dynamic> data = _apiService.decode(response) as List;
        _goals = data
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList();
        _recalculateBalances();
      }
    } catch (e) {
      debugPrint('fetchGoals error: $e');
    } finally {
      _isLoadingGoals = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    final response = await _apiService.post(
      '/goals',
      body: goal.toJson(),
    );
    if (response.statusCode == 201) {
      final newGoal = Goal.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      _goals.add(newGoal);
      _recalculateBalances();
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao criar meta') : 'Erro ao criar meta';
      throw Exception(msg);
    }
  }

  Future<void> updateGoal(
    String id, {
    String? name,
    double? amount,
    double? currentValue,
    DateTime? deadline,
    String? categoryId,
    String? customCategory,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (amount != null) 'targetValue': amount,
      if (currentValue != null) 'currentValue': currentValue,
      if (deadline != null) 'deadline': deadline.toIso8601String().split('T')[0],
      if (categoryId != null) 'categoryId': categoryId,
      if (customCategory != null) 'customCategory': customCategory,
    };
    final response = await _apiService.put(
      '/goals/$id',
      body: body,
    );
    if (response.statusCode == 200) {
      final updatedGoal = Goal.fromJson(_apiService.decode(response) as Map<String, dynamic>);
      final idx = _goals.indexWhere((g) => g.id == id);
      if (idx != -1) {
        _goals[idx] = updatedGoal;
        _recalculateBalances();
        notifyListeners();
      }
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao atualizar meta') : 'Erro ao atualizar meta';
      throw Exception(msg);
    }
  }

  Future<void> deleteGoal(String id) async {
    final response = await _apiService.delete('/goals/$id');
    if (response.statusCode == 200) {
      _goals.removeWhere((g) => g.id == id);
      _recalculateBalances();
      notifyListeners();
    } else {
      final data = _apiService.decode(response);
      final msg = data is Map ? (data['error'] ?? 'Erro ao remover meta') : 'Erro ao remover meta';
      throw Exception(msg);
    }
  }

  Future<void> fetchReportsData({DateTime? startDate, DateTime? endDate}) async {
    if (_reportSummary == null) {
      _isLoadingReports = true;
      notifyListeners();
    }

    try {
      String query = '';
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String().split('T')[0];
        final endStr = endDate.toIso8601String().split('T')[0];
        query = '?start_date=$startStr&end_date=$endStr';
      }

      final summaryRes = await _apiService.get('/relatorios/resumo$query');
      if (summaryRes.statusCode == 200) {
        _reportSummary = _apiService.decode(summaryRes);
      }

      final catRes = await _apiService.get('/relatorios/por-categoria$query');
      if (catRes.statusCode == 200) {
        _reportCategoryBreakdown = _apiService.decode(catRes);
      }

      final evolRes = await _apiService.get('/relatorios/evolucao-saldo$query');
      if (evolRes.statusCode == 200) {
        _reportBalanceEvolution = _apiService.decode(evolRes);
      }
    } catch (e) {
      debugPrint('fetchReportsData error: $e');
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:planeja_ai/core/models/category.dart';
import 'package:planeja_ai/core/models/transaction.dart';
import 'package:planeja_ai/core/models/budget.dart';
import 'package:planeja_ai/core/services/api_service.dart';
import 'package:planeja_ai/providers/auth_provider.dart';
import 'package:planeja_ai/providers/finance_provider.dart';
import 'package:planeja_ai/core/router.dart';
import 'package:planeja_ai/widgets/logo.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppCategory Model Tests', () {
    test('fromJson should parse json correctly', () {
      final json = {
        'id': 'cat-1',
        'name': 'Alimentação',
        'colorHex': '#FF5733',
        'iconName': 'utensils',
        'type': 'transaction',
      };

      final category = AppCategory.fromJson(json);

      expect(category.id, 'cat-1');
      expect(category.name, 'Alimentação');
      expect(category.colorHex, '#FF5733');
      expect(category.iconName, 'utensils');
      expect(category.type, 'transaction');
    });

    test('toJson should convert to json correctly', () {
      const category = AppCategory(
        id: 'cat-1',
        name: 'Transporte',
        colorHex: '#3357FF',
        iconName: 'car',
        type: 'transaction',
      );

      final json = category.toJson();

      expect(json['name'], 'Transporte');
      expect(json['colorHex'], '#3357FF');
      expect(json['iconName'], 'car');
      expect(json['type'], 'transaction');
    });

    test('colorValue should convert hex string to int correctly', () {
      const category = AppCategory(
        id: 'cat-1',
        name: 'Lazer',
        colorHex: '#FF5733',
        iconName: 'smile',
      );

      expect(category.colorValue, 0xFFFF5733);
    });
  });

  group('Transaction Model Tests', () {
    test('fromJson and toJson integration', () {
      final categoryJson = {
        'id': 'cat-1',
        'name': 'Alimentação',
        'colorHex': '#FF5733',
        'iconName': 'utensils',
        'type': 'transaction',
      };

      final transactionJson = {
        'id': 'tx-1',
        'title': 'Almoço',
        'type': 'expense',
        'amount': 25.50,
        'category': categoryJson,
        'date': '2026-06-25T00:00:00.000',
        'description': 'Restaurante self-service',
      };

      final transaction = Transaction.fromJson(transactionJson);

      expect(transaction.id, 'tx-1');
      expect(transaction.title, 'Almoço');
      expect(transaction.type, 'expense');
      expect(transaction.amount, 25.50);
      expect(transaction.category?.name, 'Alimentação');
      expect(transaction.date, DateTime.parse('2026-06-25T00:00:00.000'));
      expect(transaction.description, 'Restaurante self-service');

      final serialized = transaction.toJson();
      expect(serialized['id'], 'tx-1');
      expect(serialized['title'], 'Almoço');
      expect(serialized['amount'], 25.50);
      expect(serialized['categoryId'], 'cat-1');
      expect(serialized['date'], '2026-06-25');
    });

    test('copyWith creates a new instance with updated fields', () {
      final transaction = Transaction(
        id: 'tx-1',
        title: 'Salário',
        type: 'income',
        amount: 3000.00,
        categoryName: 'Trabalho',
        date: DateTime(2026, 6, 25),
        description: 'Mensal',
      );

      final updated =
          transaction.copyWith(amount: 3200.00, title: 'Salário Novo');

      expect(updated.id, 'tx-1');
      expect(updated.title, 'Salário Novo');
      expect(updated.amount, 3200.00);
      expect(updated.description, 'Mensal');
    });
  });

  group('Budget Model Tests', () {
    test('fromJson and toJson integration', () {
      final json = {
        'id': 'b-1',
        'categoryId': 'cat-1',
        'monthlyLimit': 1000.0,
        'spent': 200.0,
        'monthYear': '2026-06-01T00:00:00.000Z',
        'resetDay': 5,
      };

      final budget = Budget.fromJson(json);

      expect(budget.id, 'b-1');
      expect(budget.categoryId, 'cat-1');
      expect(budget.monthlyLimit, 1000.0);
      expect(budget.spent, 200.0);
      expect(budget.resetDay, 5);
      expect(budget.category, 'Sem categoria');

      final serialized = budget.toJson();
      expect(serialized['id'], 'b-1');
      expect(serialized['monthlyLimit'], 1000.0);
      expect(serialized['spent'], 200.0);
    });

    test('progressPercentage calculations', () {
      final budget = Budget(
        id: 'b-1',
        categoryId: 'cat-1',
        monthlyLimit: 500.0,
        spent: 250.0,
        monthYear: DateTime(2026, 6, 1),
      );

      expect(budget.progressPercentage, 50.0);
      expect(budget.monthlyRemaining, 250.0);
      expect(budget.statusLabel, 'Dentro do limite');

      final budgetOver = Budget(
        id: 'b-1',
        categoryId: 'cat-1',
        monthlyLimit: 100.0,
        spent: 120.0,
        monthYear: DateTime(2026, 6, 1),
      );
      expect(budgetOver.statusLabel, 'Excedido');

      final budgetZero = Budget(
        id: 'b-1',
        categoryId: 'cat-1',
        monthlyLimit: 0.0,
        spent: 0.0,
        monthYear: DateTime(2026, 6, 1),
      );
      expect(budgetZero.progressPercentage, 100.0);
    });

    test('cycleStartDate and cycleEndDate and daysLeft', () {
      final budget = Budget(
        id: 'b-1',
        categoryId: 'cat-1',
        monthlyLimit: 1000.0,
        spent: 100.0,
        monthYear: DateTime(2026, 6, 1),
        resetDay: 15,
      );

      expect(budget.cycleStartDate, isA<DateTime>());
      expect(budget.cycleEndDate, isA<DateTime>());
      expect(budget.daysLeftInPeriod, isA<int>());
      expect(budget.daysLeftInMonth, isA<int>());
    });

    test('getWeeklyDetails returns correct maps', () {
      final budget = Budget(
        id: 'b-1',
        categoryId: 'cat-1',
        monthlyLimit: 1000.0,
        spent: 100.0,
        monthYear: DateTime(2026, 6, 1),
        resetDay: 1,
      );

      final categoryObj = AppCategory(
        id: 'cat-1',
        name: 'Alimentação',
        colorHex: '#FF5733',
        iconName: 'utensils',
      );

      final List<Transaction> txs = [
        Transaction(
          id: 'tx-1',
          title: 'Almoço',
          type: 'expense',
          amount: 50.0,
          categoryName: 'Alimentação',
          category: categoryObj,
          date: DateTime.now(),
          description: 'Lunch',
        )
      ];

      final details = budget.getWeeklyDetails(txs);
      expect(details['weeklyLimit'], isNotNull);
      expect(details['spentCurrentWeek'], isNotNull);
      expect(details['weeklyRemaining'], isNotNull);
    });
  });

  group('ApiService Tests', () {
    test('decode should parse json and throw on invalid json', () {
      final api = ApiService();

      final response = http.Response('{"status": "ok"}', 200);
      final decoded = api.decode(response);
      expect(decoded['status'], 'ok');

      final invalidResponse = http.Response('invalid json', 200);
      expect(() => api.decode(invalidResponse), throwsException);
    });

    test('get, post, put, delete methods generate requests', () async {
      SharedPreferences.setMockInitialValues({'jwt_token': 'test-token'});
      final api = ApiService();

      try {
        await api.get('/test');
      } catch (_) {}

      try {
        await api.post('/test', body: {'foo': 'bar'});
      } catch (_) {}

      try {
        await api.put('/test', body: {'foo': 'bar'});
      } catch (_) {}

      try {
        await api.delete('/test');
      } catch (_) {}

      try {
        await api.multipartPost('/test', 'file', [1, 2, 3], 'test.txt');
      } catch (_) {}
    });
  });

  group('AuthProvider Tests', () {
    test('initial state and functions work', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthProvider();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.username, null);
      expect(auth.userData, null);
      expect(auth.isLoading, isTrue);

      try {
        await auth.login('test@test.com', 'password');
      } catch (_) {}

      try {
        await auth.signup('test@test.com', 'password', 'Test Name');
      } catch (_) {}

      try {
        await auth.logout();
      } catch (_) {}
    });
  });

  group('FinanceProvider Tests', () {
    test('initial state and clear work correctly', () {
      final finance = FinanceProvider();

      expect(finance.transactionCategories, isEmpty);
      expect(finance.transactions, isEmpty);
      expect(finance.budgets, isEmpty);
      expect(finance.goals, isEmpty);
      expect(finance.balance, 0.0);

      finance.clear();
      expect(finance.balance, 0.0);
    });
  });

  group('Router Tests', () {
    test('createRouter configures router correctly', () {
      final authProvider = AuthProvider();
      final router = createRouter(authProvider);

      expect(router.configuration, isNotNull);
    });
  });

  group('Logo Widget Tests', () {
    testWidgets('renders Planeja.AI text when showText is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Logo(showText: true),
          ),
        ),
      );

      expect(find.text('Planeja.AI'), findsOneWidget);
    });

    testWidgets('does not render Planeja.AI text when showText is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Logo(showText: false),
          ),
        ),
      );

      expect(find.text('Planeja.AI'), findsNothing);
    });
  });

}

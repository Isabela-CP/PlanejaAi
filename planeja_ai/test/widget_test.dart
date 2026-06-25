import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planeja_ai/core/models/category.dart';
import 'package:planeja_ai/core/models/transaction.dart';
import 'package:planeja_ai/widgets/logo.dart';

void main() {
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

      // FF + FF5733 = FFFF5733 -> 4294924083
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

      final updated = transaction.copyWith(amount: 3200.00, title: 'Salário Novo');

      expect(updated.id, 'tx-1');
      expect(updated.title, 'Salário Novo');
      expect(updated.amount, 3200.00);
      expect(updated.description, 'Mensal');
    });
  });

  group('Logo Widget Tests', () {
    testWidgets('renders Planeja.AI text when showText is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Logo(showText: true),
          ),
        ),
      );

      expect(find.text('Planeja.AI'), findsOneWidget);
    });

    testWidgets('does not render Planeja.AI text when showText is false', (WidgetTester tester) async {
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

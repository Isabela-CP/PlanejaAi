import 'category.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String categoryName;
  final AppCategory? category;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryName,
    this.category,
    required this.date,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    AppCategory? cat;
    if (json['category'] != null) {
      cat = AppCategory.fromJson(json['category'] as Map<String, dynamic>);
    }

    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryName: cat?.name ?? '',
      category: cat,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'categoryId': category?.id,
        'date': date.toIso8601String().split('T')[0],
        'description': description,
      };
}

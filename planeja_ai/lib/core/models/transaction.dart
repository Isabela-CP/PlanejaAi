import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final String type;
  final double amount;
  final String categoryName;
  final AppCategory? category;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.title,
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
      title: json['title'] as String? ?? '',
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
        'title': title,
        'type': type,
        'amount': amount,
        'categoryId': category?.id,
        'date': date.toIso8601String().split('T')[0],
        'description': description,
      };

  Transaction copyWith({
    String? id,
    String? title,
    String? type,
    double? amount,
    String? categoryName,
    AppCategory? category,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryName: categoryName ?? this.categoryName,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}

import 'category.dart';

class Goal {
  final String id;
  final String name;
  final double amount;
  final double currentAmount;
  final DateTime deadline;
  final String? categoryId;
  final AppCategory? categoryObj;
  final String? customCategory;
  final String status;

  Goal({
    required this.id,
    required this.name,
    required this.amount,
    required this.currentAmount,
    required this.deadline,
    this.categoryId,
    this.categoryObj,
    this.customCategory,
    this.status = 'in_progress',
  });

  String get category => categoryObj?.name ?? customCategory ?? 'Sem categoria';

  double get progressPercentage {
    if (amount <= 0) return 100.0;
    return (currentAmount / amount * 100).clamp(0.0, 100.0);
  }

  int get daysLeft {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final deadlineStart = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineStart.difference(todayStart).inDays;
  }

  double get remainingAmount => amount - currentAmount;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      amount: (json['targetValue'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now(),
      categoryId: json['categoryId'] as String?,
      categoryObj: json['category'] != null
          ? AppCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      customCategory: json['customCategory'] as String?,
      status: json['status'] as String? ?? 'in_progress',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetValue': amount,
        'currentValue': currentAmount,
        'deadline': deadline.toIso8601String().split('T')[0],
        'categoryId': categoryId,
        'customCategory': customCategory,
        'status': status,
      };
}

import 'category.dart';

class Budget {
  final String id;
  final String categoryId;
  final AppCategory? categoryObj;
  final double monthlyLimit;
  final double spent;
  final DateTime monthYear;
  final int resetDay;

  Budget({
    required this.id,
    required this.categoryId,
    this.categoryObj,
    required this.monthlyLimit,
    required this.spent,
    required this.monthYear,
    this.resetDay = 1,
  });

  String get category => categoryObj?.name ?? 'Sem categoria';

  double get progressPercentage {
    if (monthlyLimit == 0) return 100.0;
    return (spent / monthlyLimit * 100).clamp(0.0, 100.0);
  }

  double get monthlyRemaining => monthlyLimit - spent;

  int get daysLeftInPeriod {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime targetEnd;
    if (now.day < resetDay) {
      // O ciclo termina no dia resetDay - 1 deste mês
      targetEnd = DateTime(now.year, now.month, resetDay - 1);
    } else {
      // O ciclo termina no dia resetDay - 1 do próximo mês
      int nextMonth = now.month == 12 ? 1 : now.month + 1;
      int nextYear = now.month == 12 ? now.year + 1 : now.year;
      targetEnd = DateTime(nextYear, nextMonth, resetDay - 1);
    }
    
    final diff = targetEnd.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  // Compatibilidade com o layout existente
  int get daysLeftInMonth => daysLeftInPeriod;

  double get weeklyRemaining {
    final daysLeft = daysLeftInPeriod;
    final weeksLeft = daysLeft / 7.0;
    if (weeksLeft <= 0) return monthlyRemaining;
    return monthlyRemaining / weeksLeft;
  }

  String get statusLabel {
    final ratio = spent / monthlyLimit;
    if (ratio >= 1.0) return 'Excedido';
    if (ratio >= 0.8) return 'Atenção';
    return 'Dentro do limite';
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      categoryObj: json['category'] != null
          ? AppCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      monthYear: json['monthYear'] != null
          ? DateTime.parse(json['monthYear'] as String)
          : DateTime.now(),
      resetDay: json['resetDay'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'monthlyLimit': monthlyLimit,
        'spent': spent,
        'monthYear': monthYear.toIso8601String(),
        'resetDay': resetDay,
      };
}

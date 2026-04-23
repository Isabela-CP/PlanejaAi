class Budget {
  final String id;
  final String category;
  final double monthlyLimit;
  final double spent;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.spent,
    required this.createdAt,
  });

  double get progressPercentage {
    if (monthlyLimit == 0) return 100.0;
    return (spent / monthlyLimit * 100).clamp(0.0, 100.0);
  }

  double get monthlyRemaining => monthlyLimit - spent;

  int get daysLeftInMonth {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return nextMonth.difference(now).inDays;
  }

  double get weeklyRemaining {
    final daysLeft = daysLeftInMonth;
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
}

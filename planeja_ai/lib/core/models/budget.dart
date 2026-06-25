import 'category.dart';
import 'transaction.dart';

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

  DateTime get cycleStartDate {
    final now = DateTime.now();
    if (now.day < resetDay) {
      int prevMonth = now.month == 1 ? 12 : now.month - 1;
      int prevYear = now.month == 1 ? now.year - 1 : now.year;
      return DateTime(prevYear, prevMonth, resetDay);
    } else {
      return DateTime(now.year, now.month, resetDay);
    }
  }

  DateTime get cycleEndDate {
    final start = cycleStartDate;
    int nextMonth = start.month == 12 ? 1 : start.month + 1;
    int nextYear = start.month == 12 ? start.year + 1 : start.year;
    return DateTime(nextYear, nextMonth, resetDay)
        .subtract(const Duration(seconds: 1));
  }

  int get daysLeftInPeriod {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = cycleEndDate;
    final diff = end.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  // Compatibilidade com o layout existente
  int get daysLeftInMonth => daysLeftInPeriod;

  Map<String, double> getWeeklyDetails(List<Transaction> allTransactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = cycleStartDate;
    final end = cycleEndDate;

    // Filtrar transações de despesa da categoria deste orçamento que estejam no ciclo atual
    final categoryTxs = allTransactions.where((tx) {
      if (tx.category?.id != categoryId) return false;
      if (tx.type != 'expense') return false;

      final txDate = tx.date;
      return (txDate.isAfter(start) || txDate.isAtSameMomentAs(start)) &&
          (txDate.isBefore(end) || txDate.isAtSameMomentAs(end));
    }).toList();

    // Divide o mês logicamente em 4 semanas (a última semana "engole" os dias finais)
    final int totalWeeks = 4;

    // Dias transcorridos desde o início do ciclo
    final daysSinceStart = today.difference(start).inDays;

    // Determina a semana atual (0 a 3)
    int currentWeekIndex = (daysSinceStart / 7).floor();
    if (currentWeekIndex > 3) {
      currentWeekIndex =
          3; // A 4ª semana dura até o fim do ciclo (dia 22 em diante)
    }

    // Início exato do bloco da semana corrente
    final weekStart = start.add(Duration(days: currentWeekIndex * 7));

    double spentBefore = 0.0;
    double spentCurrent = 0.0;

    for (final tx in categoryTxs) {
      if (tx.date.isBefore(weekStart)) {
        spentBefore += tx.amount;
      } else {
        spentCurrent += tx.amount;
      }
    }

    // Quantas semanas faltam (incluindo a atual) para ratear a sobra
    final int weeksRemaining = totalWeeks - currentWeekIndex;
    final double remainingLimitBefore = monthlyLimit - spentBefore;

    // Limite disponível para esta semana (distribui o saldo passado nas semanas restantes)
    final double weeklyLimit = weeksRemaining > 0
        ? remainingLimitBefore / weeksRemaining
        : remainingLimitBefore;

    // Saldo semanal restante (pode ser negativo se gastou a mais nesta semana)
    final weeklyRemaining = weeklyLimit - spentCurrent;

    return {
      'weeklyLimit': weeklyLimit,
      'spentCurrentWeek': spentCurrent,
      'weeklyRemaining': weeklyRemaining,
    };
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

class Goal {
  final String id;
  final String name;
  final double amount;
  final double currentAmount;
  final DateTime deadline;
  final String category;

  Goal({
    required this.id,
    required this.name,
    required this.amount,
    required this.currentAmount,
    required this.deadline,
    required this.category,
  });

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
}

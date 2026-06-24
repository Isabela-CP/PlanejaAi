import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/models/budget.dart';
import '../providers/finance_provider.dart';

const _kIcons = <String, IconData>{
  'utensils': LucideIcons.utensils,
  'car': LucideIcons.car,
  'palmtree': LucideIcons.palmtree,
  'home': LucideIcons.home,
  'trending-up': LucideIcons.trendingUp,
  'shopping-cart': LucideIcons.shoppingCart,
  'bus': LucideIcons.bus,
  'ticket': LucideIcons.ticket,
  'sandwich': LucideIcons.sandwich,
  'book-open': LucideIcons.bookOpen,
  'help-circle': LucideIcons.helpCircle,
  'heart': LucideIcons.heart,
  'briefcase': LucideIcons.briefcase,
  'music': LucideIcons.music,
  'gamepad-2': LucideIcons.gamepad2,
  'plane': LucideIcons.plane,
  'dumbbell': LucideIcons.dumbbell,
  'baby': LucideIcons.baby,
  'shirt': LucideIcons.shirt,
  'wifi': LucideIcons.wifi,
  'zap': LucideIcons.zap,
  'gift': LucideIcons.gift,
  'coffee': LucideIcons.coffee,
  'dollar-sign': LucideIcons.dollarSign,
  'piggy-bank': LucideIcons.piggyBank,
  'graduation-cap': LucideIcons.graduationCap,
  'stethoscope': LucideIcons.stethoscope,
  'paw-print': LucideIcons.pawPrint,
  'film': LucideIcons.film,
};

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onDelete;
  final Function(Budget)? onEdit;

  const BudgetCard({
    Key? key,
    required this.budget,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final financeProvider = Provider.of<FinanceProvider>(context);

    // Calcular limite e saldo semanal dinâmico em tempo real
    final weeklyDetails = budget.getWeeklyDetails(financeProvider.transactions);
    final weeklyRemaining = weeklyDetails['weeklyRemaining'] ?? 0.0;
    
    final ratio = budget.spent / budget.monthlyLimit;
    final isDanger = ratio >= 1.0;
    final isWarning = !isDanger && ratio >= 0.8;
    
    final theme = Theme.of(context);
    final statusColor = isDanger 
        ? theme.colorScheme.error 
        : isWarning ? Colors.orange : Colors.green;

    final progressValue = budget.progressPercentage / 100.0;
    
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.6);

    final categoryColor = budget.categoryObj != null 
        ? Color(budget.categoryObj!.colorValue) 
        : theme.colorScheme.primary;

    final categoryIcon = budget.categoryObj != null
        ? (_kIcons[budget.categoryObj!.iconName] ?? LucideIcons.helpCircle)
        : LucideIcons.helpCircle;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da categoria, status e botão de deletar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(categoryIcon, color: categoryColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          budget.category,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            budget.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isDanger || isWarning) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.warning_amber_rounded, size: 12, color: statusColor),
                          ]
                        ],
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(LucideIcons.edit3, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
                        onPressed: () => onEdit!(budget),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(LucideIcons.trash2, size: 16, color: theme.colorScheme.error.withOpacity(0.7)),
                        onPressed: onDelete,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Usado e Limite Mensal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gasto este mês', style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor)),
                Text(currencyFormatter.format(budget.spent), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            
            // Barra de Progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),
            
            // Detalhes Abaixo da Barra
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${currencyFormatter.format(budget.spent)} de ${currencyFormatter.format(budget.monthlyLimit)}',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${budget.progressPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 4),

            // Disponível Mensal e Semanal
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, size: 14, color: mutedColor),
                          const SizedBox(width: 4),
                          Text('Mensal', style: TextStyle(color: mutedColor, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(budget.monthlyRemaining),
                        style: TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.bold,
                          color: budget.monthlyRemaining >= 0 ? Colors.green : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        '${budget.daysLeftInMonth} dias restantes',
                        style: TextStyle(color: mutedColor, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: theme.dividerColor),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 14, color: mutedColor),
                          const SizedBox(width: 4),
                          Text('Semanal', style: TextStyle(color: mutedColor, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(weeklyRemaining),
                        style: TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.bold,
                          color: weeklyRemaining >= 0 ? Colors.green : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        weeklyRemaining >= 0 ? 'disponível esta semana' : 'excedido esta semana',
                        style: TextStyle(
                          color: weeklyRemaining >= 0 ? mutedColor : theme.colorScheme.error.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: weeklyRemaining >= 0 ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

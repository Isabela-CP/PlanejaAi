import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    final ratio = budget.spent / budget.monthlyLimit;
    final isDanger = ratio >= 1.0;
    final isWarning = !isDanger && ratio >= 0.8;
    
    final theme = Theme.of(context);
    final statusColor = isDanger 
        ? theme.colorScheme.error 
        : isWarning ? Colors.orange : Colors.green;

    final progressValue = budget.progressPercentage / 100.0;
    
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da categoria e status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDanger || isWarning) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.warning_amber_rounded, size: 14, color: statusColor),
                      ]
                    ],
                  ),
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
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 8),

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
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: budget.monthlyRemaining >= 0 ? Colors.green : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        '${budget.daysLeftInMonth} dias restantes',
                        style: TextStyle(color: mutedColor, fontSize: 11),
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
                        currencyFormatter.format(budget.weeklyRemaining),
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: budget.weeklyRemaining >= 0 ? Colors.green : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        'disponível por semana',
                        style: TextStyle(color: mutedColor, fontSize: 11),
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

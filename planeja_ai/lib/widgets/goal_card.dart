import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/models/goal.dart';
import '../providers/finance_provider.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onDelete;
  final Function(Goal) onEdit;

  const GoalCard({
    Key? key,
    required this.goal,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    final percentage = goal.progressPercentage;
    final daysLeft = goal.daysLeft;

    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.6);

    String statusLabel = 'Em Progresso';
    Color statusColor = theme.colorScheme.primary;

    if (percentage >= 100) {
      statusLabel = 'Concluída';
      statusColor = Colors.green;
    } else if (daysLeft < 0) {
      statusLabel = 'Atrasada';
      statusColor = theme.colorScheme.error;
    } else if (daysLeft <= 30) {
      statusLabel = 'Próxima ao Fim';
      statusColor = Colors.orange[600] ?? Colors.orange;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row de Categoria, Título e Delete
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: mutedColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          goal.category,
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: theme.colorScheme.primary,
                      tooltip: 'Editar',
                      onPressed: () => onEdit(goal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: theme.colorScheme.error,
                      tooltip: 'Deletar',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Meta'),
                            content: Text(
                                'Tem certeza que deseja excluir "${goal.name}"? Esta ação não pode ser desfeita.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onDelete();
                                },
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badge de Status e Percentual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(0)}% Concluído',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100.0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 16),

            // Detalhes da Meta
            Column(
              children: [
                _buildDetailRow(
                  context: context,
                  icon: Icons.attach_money,
                  label: 'Progresso',
                  value:
                      '${currencyFormatter.format(goal.currentAmount)} / ${currencyFormatter.format(goal.amount)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context: context,
                  icon: Icons.calendar_today,
                  label: 'Prazo',
                  value: dateFormatter.format(goal.deadline),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context: context,
                  icon: Icons.timelapse,
                  label: 'Dias restantes',
                  value: daysLeft < 0
                      ? '${daysLeft.abs()} dias atrasados'
                      : '$daysLeft dias',
                  valueColor: daysLeft < 0
                      ? theme.colorScheme.error
                      : (daysLeft <= 30 ? Colors.orange[600] : mutedColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                final isOver = goal.currentAmount > goal.amount;
                final remainingVal = isOver
                    ? (goal.currentAmount - goal.amount)
                    : goal.remainingAmount;
                final label = isOver ? 'Excedente' : 'Faltam';
                final displayColor =
                    isOver ? Colors.green : theme.colorScheme.primary;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: TextStyle(fontSize: 12, color: mutedColor)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        currencyFormatter.format(remainingVal),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: displayColor),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showManageMoneyDialog(context),
                    icon: const Icon(Icons.add_card, size: 14),
                    label: const Text('Lançar Valor',
                        style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManageMoneyDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Lançar Valor na Meta\n"${goal.name}"',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo atual: R\$ ${goal.currentAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
            onPressed: () async {
              final text = controller.text.replaceAll(',', '.');
              final val = double.tryParse(text) ?? 0.0;
              if (val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Por favor, insira um valor válido maior que zero.'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              if (val > goal.currentAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Valor de resgate excede o saldo atual da meta.'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final newAmount = goal.currentAmount - val;
                await Provider.of<FinanceProvider>(context, listen: false)
                    .updateGoal(
                  goal.id,
                  currentValue: newAmount,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Resgatado R\$ ${val.toStringAsFixed(2)} da meta "${goal.name}"!'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Resgatar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.replaceAll(',', '.');
              final val = double.tryParse(text) ?? 0.0;
              if (val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Por favor, insira um valor válido maior que zero.'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                final newAmount = goal.currentAmount + val;
                await Provider.of<FinanceProvider>(context, listen: false)
                    .updateGoal(
                  goal.id,
                  currentValue: newAmount,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Guardado R\$ ${val.toStringAsFixed(2)} na meta "${goal.name}"!'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final mutedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: mutedColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: mutedColor)),
          ],
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: valueColor),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

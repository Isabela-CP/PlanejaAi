import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/models/budget.dart';
import '../providers/finance_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_form.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.fetchBudgets();
      provider.fetchAllCategories();
    });
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  Future<void> _handleAddBudget(String categoryId, double limit, int resetDay) async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    try {
      await provider.addBudget(
        categoryId: categoryId,
        limit: limit,
        resetDay: resetDay,
      );
      setState(() {
        _showForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orçamento definido com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar orçamento: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleDeleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Orçamento'),
        content: Text('Tem certeza que deseja remover o orçamento da categoria "${budget.category}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      try {
        await provider.deleteBudget(budget.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento removido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover orçamento: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final budgets = financeProvider.budgets;
    final isLoading = financeProvider.isLoadingBudgets;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header estilo Painel/Transações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Orçamentos',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms).slideX(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _toggleForm,
                  icon: Icon(_showForm ? Icons.close : Icons.add, size: 16),
                  label: Text(_showForm ? 'Fechar' : 'Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ).animate().fade().scale(),
              ],
            ),
            const SizedBox(height: 24),

            if (_showForm)
              BudgetForm(
                currentBudgets: budgets,
                onAddBudget: _handleAddBudget,
                onCancel: _toggleForm,
              ).animate()
               .fade(duration: 300.ms)
               .slideY(begin: -0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : budgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum orçamento configurado ainda.\nCrie um para começar a planejar!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            bool useTwoColumns = constraints.maxWidth >= 600;
                            
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: useTwoColumns ? 2 : 1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 260, 
                              ),
                              itemCount: budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgets[index];
                                return BudgetCard(
                                  budget: budget,
                                  onDelete: () => _handleDeleteBudget(budget),
                                )
                                .animate()
                                .fade(duration: 400.ms, delay: (50 * index).ms)
                                .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
